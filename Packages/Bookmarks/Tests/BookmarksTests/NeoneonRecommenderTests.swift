import CryptoKit
import Foundation
import XCTest
@testable import Bookmarks

// MARK: - Stubs

struct InvalidKeyError: Error {}
struct ServiceUnavailableError: Error {}

/// Stands in for the Secure Enclave: hands out predictable keys and records what it signs.
final class StubAppAttest: AppAttestProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var _isSupported = true
    private var _keyCount = 0
    private var _attestations: [(keyID: String, clientDataHash: Data)] = []
    private var _assertions: [(keyID: String, clientDataHash: Data)] = []
    private var _invalidKeys: Set<String> = []
    private var _generateKeyError: (any Error)?

    private func locked<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }

    var isSupported: Bool {
        get { locked { _isSupported } }
        set { locked { _isSupported = newValue } }
    }
    var keyCount: Int { locked { _keyCount } }
    var attestations: [(keyID: String, clientDataHash: Data)] { locked { _attestations } }
    var assertions: [(keyID: String, clientDataHash: Data)] { locked { _assertions } }

    func invalidate(_ keyID: String) { locked { _ = _invalidKeys.insert(keyID) } }
    func failGenerateKey(with error: any Error) { locked { _generateKeyError = error } }

    func generateKey() async throws -> String {
        try locked { () throws -> String in
            if let error = _generateKeyError { throw error }
            _keyCount += 1
            return "key-\(_keyCount)"
        }
    }

    func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data {
        locked { _attestations.append((keyID, clientDataHash)) }
        return Data("attestation-for-\(keyID)".utf8)
    }

    func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data {
        try locked { () throws -> Data in
            if _invalidKeys.contains(keyID) { throw InvalidKeyError() }
            _assertions.append((keyID, clientDataHash))
            return Data("assertion-by-\(keyID)".utf8)
        }
    }

    func classify(_ error: any Error) -> AppAttestFailure {
        switch error {
        case is InvalidKeyError: return .invalidKey
        case is ServiceUnavailableError: return .serviceUnavailable
        default: return .other
        }
    }
}

final class MemoryKeyStore: AppAttestKeyStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var keyID: String?

    init(_ keyID: String? = nil) { self.keyID = keyID }

    func load() -> String? { lock.lock(); defer { lock.unlock() }; return keyID }
    func save(_ keyID: String) { lock.lock(); defer { lock.unlock() }; self.keyID = keyID }
    func delete() { lock.lock(); defer { lock.unlock() }; keyID = nil }
}

/// Answers by path, like neoneon would, and records every request.
final class StubTransport: HTTPTransport, @unchecked Sendable {
    typealias Handler = @Sendable (URLRequest) async throws -> (Int, String)

    private let lock = NSLock()
    private var _requests: [URLRequest] = []
    private let handler: Handler

    init(_ handler: @escaping Handler) { self.handler = handler }

    var requests: [URLRequest] { lock.lock(); defer { lock.unlock() }; return _requests }

    func requests(to path: String) -> [URLRequest] {
        requests.filter { $0.url?.path == path }
    }

    private func record(_ request: URLRequest) {
        lock.lock(); defer { lock.unlock() }
        _requests.append(request)
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        record(request)
        let (status, body) = try await handler(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
        return (Data(body.utf8), response)
    }

    /// The happy path: a challenge, a registered key, one recommendation.
    static func neoneon(
        delayChallenge: Bool = false,
        recommendations: @escaping @Sendable (URLRequest) -> (Int, String) = { _ in
            (200, #"{"recommendations":[{"title":"Stoner","author":"John Williams"}]}"#)
        }
    ) -> StubTransport {
        StubTransport { request in
            switch request.url?.path {
            case RecommenderAPI.challengePath:
                if delayChallenge { try await Task.sleep(nanoseconds: 50_000_000) }
                return (200, #"{"challenge":"c-1"}"#)
            case RecommenderAPI.keysPath:
                return (201, #"{"keyID":"ignored","environment":"production"}"#)
            case RecommenderAPI.recommendationsPath:
                return recommendations(request)
            default:
                return (404, #"{"error":true,"code":"not_found","reason":""}"#)
            }
        }
    }
}

private func errorBody(_ code: String, reason: String = "…") -> String {
    #"{"error":true,"code":"\#(code)","reason":"\#(reason)"}"#
}

/// Collects the client's diagnostics.
final class LogSink: @unchecked Sendable {
    private let lock = NSLock()
    private var _lines: [String] = []

    var lines: [String] { lock.lock(); defer { lock.unlock() }; return _lines }

    var log: @Sendable (String) -> Void {
        { [self] line in lock.lock(); _lines.append(line); lock.unlock() }
    }
}

// MARK: - Wire contract

final class RecommenderAPITests: XCTestCase {

    /// The shared fixture from neoneon's `docs/btlb-recommender-api.md`. The server asserts the
    /// same string; if both agree, an assertion made here verifies there.
    func testCanonicalPayloadMatchesTheServerFixture() {
        let payload = RecommenderAPI.canonicalPayload(
            method: "post",
            path: "/btlb/recommender/recommendations",
            keyID: "q83vEjRWeJCrze8SNFZ4kKvN7xI0VniQq83vEjRWeJA=",
            timestamp: 1_767_225_600,
            body: Data(#"{"titles":["Unterleuten"]}"#.utf8)
        )
        XCTAssertEqual(payload, """
            btlb-recommender-v1
            POST
            /btlb/recommender/recommendations
            q83vEjRWeJCrze8SNFZ4kKvN7xI0VniQq83vEjRWeJA=
            1767225600
            a5ae5374629d5c19e2dc24f4a6af7e19affa87af5e22adc3588bc4e5afac8162
            """)
    }

    /// The body the fixture signs is exactly what the client encodes.
    func testTheRequestBodyIsEncodedWithoutWhitespace() throws {
        let body = try JSONEncoder().encode(RecommenderAPI.RecommendationsRequest(titles: ["Unterleuten"]))
        XCTAssertEqual(String(decoding: body, as: UTF8.self), #"{"titles":["Unterleuten"]}"#)
    }

    /// The challenge is hashed — unlike Apple's sample, which neoneon would reject.
    func testAttestationHashesTheChallenge() {
        let hash = RecommenderAPI.attestationClientDataHash(challenge: "example_server_challenge")
        XCTAssertEqual(hash, Data(SHA256.hash(data: Data("example_server_challenge".utf8))))
        XCTAssertNotEqual(hash, Data("example_server_challenge".utf8))
    }

    func testTitlesAreCleanedLikeTheServerCleansThem() {
        XCTAssertEqual(
            RecommenderAPI.prepareTitles(["  Unter\u{200B}leuten\n\nRoman ", "evil\u{202E}txet", "Ｍｏｍｏ"]),
            ["Unterleuten Roman", "eviltxet", "Momo"]
        )
    }

    func testTitlesAreTruncatedDeduplicatedAndCapped() {
        let long = String(repeating: "a", count: 250)
        XCTAssertEqual(RecommenderAPI.prepareTitles([long]).first?.count, 200)

        // NFKC can lengthen a title ("ﬁ" → "fi"); the limit applies after cleaning, as on the server.
        XCTAssertEqual(RecommenderAPI.prepareTitles([String(repeating: "ﬁ", count: 150)]).first?.count, 200)

        XCTAssertEqual(RecommenderAPI.prepareTitles(["Momo", "momo", " ", "\u{200B}", "MOMO "]), ["Momo"])
        XCTAssertEqual(RecommenderAPI.prepareTitles((1...15).map { "Book \($0)" }).count, 10)
    }

    func testServerErrorCodesMapToWhatTheAppShows() {
        let cases: [(code: String?, status: Int, expected: RecommenderError)] = [
            ("rate_limited", 429, .rateLimited),
            ("unavailable", 503, .unavailable),
            ("stale_timestamp", 401, .deviceClock),
            ("upstream_failed", 502, .failed),
            ("assertion_invalid", 401, .failed),
            ("invalid_input", 400, .failed),
            (nil, 429, .rateLimited),
            (nil, 503, .unavailable),
            (nil, 500, .failed),
        ]
        for (code, status, expected) in cases {
            let body = code.map { errorBody($0) } ?? "<html>bad gateway</html>"
            XCTAssertEqual(RecommenderClient.error(status: status, data: Data(body.utf8)), expected, "\(code ?? "no code") \(status)")
        }
    }
}

// MARK: - Client

final class RecommenderClientTests: XCTestCase {

    private let fixedNow = Date(timeIntervalSince1970: 1_767_225_600)

    private func client(
        _ transport: StubTransport,
        appAttest: StubAppAttest = StubAppAttest(),
        keyStore: MemoryKeyStore = MemoryKeyStore()
    ) -> RecommenderClient {
        let now = fixedNow
        return RecommenderClient(transport: transport, appAttest: appAttest, keyStore: keyStore, now: { now })
    }

    /// The whole first-run path, and the property everything rests on: the assertion signs
    /// exactly the method, path, key header, timestamp header and body that are sent.
    func testRegistersAKeyThenSignsExactlyWhatItSends() async throws {
        let transport = StubTransport.neoneon()
        let appAttest = StubAppAttest()
        let keyStore = MemoryKeyStore()

        let books = try await client(transport, appAttest: appAttest, keyStore: keyStore)
            .recommendations(for: ["Unterleuten", "Der Trafikant"])
        XCTAssertEqual(books, [RecommendedBook(title: "Stoner", author: "John Williams")])

        // Registration: the key is attested over SHA256(challenge) and stored once accepted.
        XCTAssertEqual(appAttest.attestations.map(\.keyID), ["key-1"])
        XCTAssertEqual(appAttest.attestations.first?.clientDataHash, Data(SHA256.hash(data: Data("c-1".utf8))))
        let keysRequest = try XCTUnwrap(transport.requests(to: RecommenderAPI.keysPath).first)
        let registered = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(keysRequest.httpBody)) as? [String: String])
        XCTAssertEqual(registered["keyID"], "key-1")
        XCTAssertEqual(registered["challenge"], "c-1")
        XCTAssertEqual(registered["attestation"], Data("attestation-for-key-1".utf8).base64EncodedString())
        XCTAssertEqual(keyStore.load(), "key-1")

        // The signed request.
        let request = try XCTUnwrap(transport.requests(to: RecommenderAPI.recommendationsPath).first)
        XCTAssertEqual(request.url?.absoluteString, "https://neoneon.dev/btlb/recommender/recommendations")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: RecommenderAPI.Header.keyID), "key-1")
        XCTAssertEqual(request.value(forHTTPHeaderField: RecommenderAPI.Header.timestamp), "1767225600")
        XCTAssertEqual(
            request.value(forHTTPHeaderField: RecommenderAPI.Header.assertion),
            Data("assertion-by-key-1".utf8).base64EncodedString()
        )
        let body = try XCTUnwrap(request.httpBody)
        XCTAssertEqual(String(decoding: body, as: UTF8.self), #"{"titles":["Unterleuten","Der Trafikant"]}"#)

        // Rebuild the payload from the request as the server will, and compare with what was signed.
        let serverSide = RecommenderAPI.canonicalPayload(
            method: try XCTUnwrap(request.httpMethod),
            path: try XCTUnwrap(request.url?.path),
            keyID: try XCTUnwrap(request.value(forHTTPHeaderField: RecommenderAPI.Header.keyID)),
            timestamp: try XCTUnwrap(request.value(forHTTPHeaderField: RecommenderAPI.Header.timestamp).flatMap(Int.init)),
            body: body
        )
        XCTAssertEqual(appAttest.assertions.first?.clientDataHash, Data(SHA256.hash(data: Data(serverSide.utf8))))
    }

    func testAStoredKeyIsUsedWithoutRegistering() async throws {
        let transport = StubTransport.neoneon()
        let appAttest = StubAppAttest()

        _ = try await client(transport, appAttest: appAttest, keyStore: MemoryKeyStore("stored"))
            .recommendations(for: ["Momo"])

        XCTAssertEqual(appAttest.keyCount, 0)
        XCTAssertEqual(transport.requests.map { $0.url?.path }, [RecommenderAPI.recommendationsPath])
        XCTAssertEqual(appAttest.assertions.map(\.keyID), ["stored"])
    }

    /// `unknown_key` from the server: register a new key and retry, once.
    func testAnUnknownKeyIsReplacedOnce() async throws {
        let transport = StubTransport.neoneon { request in
            request.value(forHTTPHeaderField: RecommenderAPI.Header.keyID) == "old"
                ? (401, errorBody("unknown_key"))
                : (200, #"{"recommendations":[{"title":"Momo","author":"Michael Ende"}]}"#)
        }
        let appAttest = StubAppAttest()
        let keyStore = MemoryKeyStore("old")

        let books = try await client(transport, appAttest: appAttest, keyStore: keyStore).recommendations(for: ["Unterleuten"])

        XCTAssertEqual(books.map(\.title), ["Momo"])
        XCTAssertEqual(appAttest.keyCount, 1)
        XCTAssertEqual(keyStore.load(), "key-1")
        XCTAssertEqual(transport.requests(to: RecommenderAPI.recommendationsPath).count, 2)
    }

    /// The key is gone from the device (reinstall, restore): same recovery, without a round trip.
    func testAKeyGoneFromTheDeviceIsReplaced() async throws {
        let transport = StubTransport.neoneon()
        let appAttest = StubAppAttest()
        appAttest.invalidate("old")
        let keyStore = MemoryKeyStore("old")

        _ = try await client(transport, appAttest: appAttest, keyStore: keyStore).recommendations(for: ["Unterleuten"])

        XCTAssertEqual(keyStore.load(), "key-1")
        XCTAssertEqual(transport.requests(to: RecommenderAPI.recommendationsPath).count, 1)
    }

    func testGivesUpAfterOneReplacement() async throws {
        let transport = StubTransport.neoneon { _ in (401, errorBody("unknown_key")) }
        let appAttest = StubAppAttest()

        do {
            _ = try await client(transport, appAttest: appAttest, keyStore: MemoryKeyStore("old")).recommendations(for: ["Momo"])
            XCTFail("Expected a failure")
        } catch {
            XCTAssertEqual(error as? RecommenderError, .failed)
        }
        XCTAssertEqual(appAttest.keyCount, 1)
        XCTAssertEqual(transport.requests(to: RecommenderAPI.recommendationsPath).count, 2)
    }

    func testTwoRequestsAtOnceRegisterOneKey() async throws {
        let transport = StubTransport.neoneon(delayChallenge: true)
        let appAttest = StubAppAttest()
        let shared = client(transport, appAttest: appAttest)

        async let first = shared.recommendations(for: ["Momo"])
        async let second = shared.recommendations(for: ["Unterleuten"])
        _ = try await (first, second)

        XCTAssertEqual(appAttest.keyCount, 1)
        XCTAssertEqual(transport.requests(to: RecommenderAPI.challengePath).count, 1)
    }

    func testAnUnsupportedDeviceMakesNoRequests() async {
        let transport = StubTransport.neoneon()
        let appAttest = StubAppAttest()
        appAttest.isSupported = false

        await assertThrows(.notSupported) {
            try await self.client(transport, appAttest: appAttest).recommendations(for: ["Momo"])
        }
        XCTAssertTrue(transport.requests.isEmpty)
    }

    func testNothingUsableToSend() async {
        let transport = StubTransport.neoneon()
        await assertThrows(.noTitles) {
            try await self.client(transport).recommendations(for: ["  ", "\u{200B}"])
        }
        XCTAssertTrue(transport.requests.isEmpty)
    }

    func testAnUnreachableServerIsANetworkError() async {
        let transport = StubTransport { _ in throw URLError(.notConnectedToInternet) }
        await assertThrows(.network) {
            try await self.client(transport).recommendations(for: ["Momo"])
        }
    }

    func testAppAttestBeingDownIsUnavailable() async {
        let appAttest = StubAppAttest()
        appAttest.failGenerateKey(with: ServiceUnavailableError())
        await assertThrows(.unavailable) {
            try await self.client(StubTransport.neoneon(), appAttest: appAttest).recommendations(for: ["Momo"])
        }
    }

    /// The app shows one generic message for most failures; the log says which one it was, with
    /// the server's code and reason — and never the titles.
    func testARefusedRegistrationIsLoggedWithTheServersReason() async throws {
        let transport = StubTransport { request in
            switch request.url?.path {
            case RecommenderAPI.challengePath:
                return (200, #"{"challenge":"c-1"}"#)
            default:
                return (401, errorBody("attestation_invalid", reason: "Development-environment keys are not accepted"))
            }
        }
        let sink = LogSink()
        let client = RecommenderClient(
            transport: transport,
            appAttest: StubAppAttest(),
            keyStore: MemoryKeyStore(),
            log: sink.log
        )

        await assertThrows(.failed) { try await client.recommendations(for: ["Secret Diary"]) }

        XCTAssertEqual(sink.lines, [
            "POST /btlb/recommender/keys → HTTP 401 attestation_invalid: Development-environment keys are not accepted",
        ])
        XCTAssertFalse(sink.lines.joined().contains("Secret Diary"))
    }

    func testASuccessfulRunLogsEachStep() async throws {
        let sink = LogSink()
        let client = RecommenderClient(
            transport: StubTransport.neoneon(),
            appAttest: StubAppAttest(),
            keyStore: MemoryKeyStore(),
            log: sink.log
        )
        _ = try await client.recommendations(for: ["Momo"])
        XCTAssertEqual(sink.lines, [
            "POST /btlb/recommender/keys → HTTP 201, App Attest key registered",
            "POST /btlb/recommender/recommendations → HTTP 200, 1 recommendations",
        ])
    }

    func testARateLimitedDeviceIsTold() async {
        let transport = StubTransport.neoneon { _ in (429, errorBody("rate_limited")) }
        await assertThrows(.rateLimited) {
            try await self.client(transport, keyStore: MemoryKeyStore("stored")).recommendations(for: ["Momo"])
        }
    }

    private func assertThrows(
        _ expected: RecommenderError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () async throws -> [RecommendedBook]
    ) async {
        do {
            _ = try await body()
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? RecommenderError, expected, file: file, line: line)
        }
    }
}
