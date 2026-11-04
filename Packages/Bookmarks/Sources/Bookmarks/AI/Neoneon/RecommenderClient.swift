//
//  RecommenderClient.swift
//  Bookmarks
//

import Foundation

// MARK: - Seams

/// App Attest, behind a protocol so the client can be tested without a device.
/// `DeviceAppAttest` is the real one.
protocol AppAttestProviding: Sendable {
    var isSupported: Bool { get }
    func generateKey() async throws -> String
    func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data
    func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data
    func classify(_ error: any Error) -> AppAttestFailure
}

enum AppAttestFailure: Equatable, Sendable {
    /// The key no longer exists on this device — after a reinstall or a restore to another
    /// device. Not an error to report: generate and attest a new one.
    case invalidKey
    /// Apple's App Attest service is temporarily unavailable; try again later.
    case serviceUnavailable
    case other
}

/// Where the attested key's identifier is kept between launches.
protocol AppAttestKeyStoring: Sendable {
    func load() -> String?
    func save(_ keyID: String)
    func delete()
}

protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPTransport {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }
}

// MARK: - Client

/// Talks to neoneon's recommender: registers an App Attest key once per install, then signs
/// every recommendation request with an assertion. See `RecommenderAPI` for the wire format.
///
/// An actor so that two requests in flight never register two keys: the first registration is
/// shared by everyone who needs a key while it runs.
actor RecommenderClient {
    private let baseURL: URL
    private let transport: any HTTPTransport
    private let appAttest: any AppAttestProviding
    private let keyStore: any AppAttestKeyStoring
    private let now: @Sendable () -> Date

    private var registration: Task<String, any Error>?

    init(
        baseURL: URL = RecommenderAPI.baseURL,
        transport: any HTTPTransport,
        appAttest: any AppAttestProviding,
        keyStore: any AppAttestKeyStoring,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.baseURL = baseURL
        self.transport = transport
        self.appAttest = appAttest
        self.keyStore = keyStore
        self.now = now
    }

    func recommendations(for titles: [String]) async throws -> [RecommendedBook] {
        guard appAttest.isSupported else { throw RecommenderError.notSupported }

        let prepared = RecommenderAPI.prepareTitles(titles)
        guard !prepared.isEmpty else { throw RecommenderError.noTitles }
        let body = try JSONEncoder().encode(RecommenderAPI.RecommendationsRequest(titles: prepared))

        do {
            return try await requestRecommendations(body: body)
        } catch KeyRejected.rejected {
            // The stored key is gone (reinstall, restore to another device) or the server doesn't
            // know it. Normal, not an error: register a new key and try exactly once more.
            keyStore.delete()
            do {
                return try await requestRecommendations(body: body)
            } catch KeyRejected.rejected {
                throw RecommenderError.failed
            }
        }
    }

    /// Internal signal: the key must be replaced.
    private enum KeyRejected: Error {
        case rejected
    }

    private func requestRecommendations(body: Data) async throws -> [RecommendedBook] {
        let keyID = try await registeredKeyID()
        let timestamp = Int(now().timeIntervalSince1970)
        let payload = RecommenderAPI.canonicalPayload(
            method: "POST",
            path: RecommenderAPI.recommendationsPath,
            keyID: keyID,
            timestamp: timestamp,
            body: body
        )

        let assertion: Data
        do {
            assertion = try await appAttest.generateAssertion(
                keyID,
                clientDataHash: RecommenderAPI.sha256(Data(payload.utf8))
            )
        } catch {
            if appAttest.classify(error) == .invalidKey { throw KeyRejected.rejected }
            throw appAttestError(error)
        }

        var request = URLRequest(url: baseURL.appending(path: RecommenderAPI.recommendationsPath))
        request.httpMethod = "POST"
        request.timeoutInterval = 45  // the server gives the model 30 s
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(keyID, forHTTPHeaderField: RecommenderAPI.Header.keyID)
        request.setValue(String(timestamp), forHTTPHeaderField: RecommenderAPI.Header.timestamp)
        request.setValue(assertion.base64EncodedString(), forHTTPHeaderField: RecommenderAPI.Header.assertion)
        request.httpBody = body

        let (data, response) = try await send(request)
        guard response.statusCode == 200 else {
            if Self.errorCode(in: data) == "unknown_key" { throw KeyRejected.rejected }
            throw Self.error(status: response.statusCode, data: data)
        }
        guard let decoded = try? JSONDecoder().decode(RecommenderAPI.RecommendationsResponse.self, from: data) else {
            throw RecommenderError.failed
        }
        return decoded.recommendations.map { RecommendedBook(title: $0.title, author: $0.author) }
    }

    // MARK: Registration

    /// The stored key, or a newly registered one. Concurrent callers share one registration.
    private func registeredKeyID() async throws -> String {
        if let keyID = keyStore.load() { return keyID }
        if let registration { return try await registration.value }

        let task = Task { try await self.register() }
        registration = task
        defer { registration = nil }
        return try await task.value
    }

    /// Generate a key, attest it over a fresh challenge, and register it. The key is stored only
    /// once the server has accepted it, so a failed attempt starts over with a new key next time.
    private func register() async throws -> String {
        let keyID: String
        do {
            keyID = try await appAttest.generateKey()
        } catch {
            throw appAttestError(error)
        }

        let challenge = try await fetchChallenge()

        let attestation: Data
        do {
            attestation = try await appAttest.attestKey(
                keyID,
                clientDataHash: RecommenderAPI.attestationClientDataHash(challenge: challenge)
            )
        } catch {
            throw appAttestError(error)
        }

        var request = URLRequest(url: baseURL.appending(path: RecommenderAPI.keysPath))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RecommenderAPI.RegisterKeyRequest(
            keyID: keyID,
            attestation: attestation.base64EncodedString(),
            challenge: challenge
        ))

        let (data, response) = try await send(request)
        // 201 registered; 200 this exact attestation was already registered (a retry).
        guard response.statusCode == 201 || response.statusCode == 200 else {
            throw Self.error(status: response.statusCode, data: data)
        }

        keyStore.save(keyID)
        return keyID
    }

    private func fetchChallenge() async throws -> String {
        var request = URLRequest(url: baseURL.appending(path: RecommenderAPI.challengePath))
        request.httpMethod = "POST"

        let (data, response) = try await send(request)
        guard response.statusCode == 200 else {
            throw Self.error(status: response.statusCode, data: data)
        }
        guard let decoded = try? JSONDecoder().decode(RecommenderAPI.ChallengeResponse.self, from: data) else {
            throw RecommenderError.failed
        }
        return decoded.challenge
    }

    // MARK: Errors

    private func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            return try await transport.send(request)
        } catch {
            throw RecommenderError.network
        }
    }

    private func appAttestError(_ error: any Error) -> RecommenderError {
        appAttest.classify(error) == .serviceUnavailable ? .unavailable : .failed
    }

    static func errorCode(in data: Data) -> String? {
        (try? JSONDecoder().decode(RecommenderAPI.ErrorResponse.self, from: data))?.code
    }

    /// Maps the server's error `code` (`docs/btlb-recommender-api.md`) to what the app shows.
    static func error(status: Int, data: Data) -> RecommenderError {
        switch errorCode(in: data) {
        case "rate_limited": return .rateLimited
        case "unavailable": return .unavailable
        case "stale_timestamp": return .deviceClock
        default: return status == 429 ? .rateLimited : (status == 503 ? .unavailable : .failed)
        }
    }
}
