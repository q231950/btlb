//
//  RecommenderAPI.swift
//  Bookmarks
//

import CryptoKit
import Foundation

/// The wire contract of the BTLB recommender on neoneon.dev, as specified in
/// `docs/btlb-recommender-api.md` in q231950/neoneon.
///
/// The server verifies an App Attest assertion over `canonicalPayload(…)`, so everything that
/// goes into it must match the server byte for byte — one differing byte is a `401`. The shared
/// fixture in that document is asserted in `NeoneonRecommenderTests`.
enum RecommenderAPI {
    static let baseURL = URL(string: "https://neoneon.dev")!

    static let challengePath = "/btlb/recommender/challenge"
    static let keysPath = "/btlb/recommender/keys"
    static let recommendationsPath = "/btlb/recommender/recommendations"

    /// The server accepts 1–10 titles of at most 200 characters (after the same cleaning
    /// `clean(_:)` does). The selection screen caps at the same number.
    static let maximumTitles = 10
    static let maximumTitleLength = 200

    enum Header {
        static let keyID = "X-BTLB-Key-ID"
        static let timestamp = "X-BTLB-Timestamp"
        static let assertion = "X-BTLB-Assertion"
    }

    /// First line of every signed payload.
    static let payloadVersion = "btlb-recommender-v1"

    /// The exact text an assertion signs, as `clientDataHash = SHA256(UTF-8 of this)`:
    ///
    /// ```
    /// btlb-recommender-v1
    /// <METHOD>
    /// <path, exactly as sent>
    /// <X-BTLB-Key-ID, exactly as sent>
    /// <X-BTLB-Timestamp>
    /// <lower-case hex SHA-256 of the body>
    /// ```
    static func canonicalPayload(method: String, path: String, keyID: String, timestamp: Int, body: Data) -> String {
        [
            payloadVersion,
            method.uppercased(),
            path,
            keyID,
            String(timestamp),
            sha256Hex(body),
        ].joined(separator: "\n")
    }

    /// `clientDataHash` for `attestKey(_:clientDataHash:)`: SHA-256 of the challenge string's
    /// UTF-8 bytes, exactly as the server returned it.
    ///
    /// Not the raw bytes — the sample in Apple's Attestation Object Validation Guide passes its
    /// challenge unhashed, and the server rejects that with `attestation_invalid`.
    static func attestationClientDataHash(challenge: String) -> Data {
        sha256(Data(challenge.utf8))
    }

    static func sha256(_ data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Titles

    /// The titles to send: cleaned like the server cleans them, so the 200-character limit is
    /// counted the same way on both sides; truncated to that limit; empty ones and
    /// case-insensitive duplicates dropped; at most `maximumTitles`.
    static func prepareTitles(_ titles: [String]) -> [String] {
        var seen = Set<String>()
        var prepared: [String] = []
        for raw in titles {
            let title = String(clean(raw).prefix(maximumTitleLength))
                .trimmingCharacters(in: .whitespaces)
            guard !title.isEmpty, seen.insert(title.lowercased()).inserted else { continue }
            prepared.append(title)
            if prepared.count == maximumTitles { break }
        }
        return prepared
    }

    /// Mirrors the server's `RecommenderText.clean`: NFKC; every whitespace character (newlines
    /// included) becomes a single space; control and format characters (zero-width, bidi
    /// overrides) are removed; trimmed.
    static func clean(_ raw: String) -> String {
        var scalars = String.UnicodeScalarView()
        var pendingSpace = false

        for scalar in raw.precomposedStringWithCompatibilityMapping.unicodeScalars {
            if scalar.properties.isWhitespace {
                pendingSpace = !scalars.isEmpty
                continue
            }
            switch scalar.properties.generalCategory {
            case .control, .format:
                continue
            default:
                if pendingSpace {
                    scalars.append(" ")
                    pendingSpace = false
                }
                scalars.append(scalar)
            }
        }
        return String(scalars)
    }

    // MARK: - Bodies

    struct RecommendationsRequest: Encodable {
        let titles: [String]
    }

    struct RecommendationsResponse: Decodable {
        struct Item: Decodable {
            let title: String
            let author: String
        }

        let recommendations: [Item]
    }

    struct ChallengeResponse: Decodable {
        let challenge: String
    }

    struct RegisterKeyRequest: Encodable {
        let keyID: String
        let attestation: String
        let challenge: String
    }

    /// `{ "error": true, "code": "…", "reason": "…" }`. Clients branch on `code` only; `reason` is
    /// for logs (it never contains titles).
    struct ErrorResponse: Decodable {
        let code: String?
        let reason: String?
    }
}
