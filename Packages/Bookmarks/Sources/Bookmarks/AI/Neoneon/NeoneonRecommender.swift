//
//  NeoneonRecommender.swift
//  Bookmarks
//

import Foundation
import LibraryCore
import os

/// BTLB's AI book recommender, served by neoneon.dev.
///
/// The OpenRouter key and the prompt live on the server; the app sends only the titles of the
/// selected bookmarks and gets back up to three recommendations. Requests are signed with App
/// Attest so the server can tell BTLB apart from anyone else calling it. Contract:
/// `docs/btlb-recommender-api.md` in q231950/neoneon.
public struct NeoneonRecommender: RecommenderProtocol {
    private let appAttest: any AppAttestProviding
    private let client: RecommenderClient

    public init() {
        self.init(
            appAttest: DeviceAppAttest(),
            transport: URLSession.shared,
            keyStore: UserDefaultsAppAttestKeyStore()
        )
    }

    init(
        appAttest: any AppAttestProviding,
        transport: any HTTPTransport,
        keyStore: any AppAttestKeyStoring,
        baseURL: URL = RecommenderAPI.baseURL
    ) {
        self.appAttest = appAttest
        self.client = RecommenderClient(
            baseURL: baseURL,
            transport: transport,
            appAttest: appAttest,
            keyStore: keyStore,
            log: Self.log
        )
    }

    /// Diagnostics to the unified log (Xcode's console, Console.app): subsystem `com.elbedev.sync`,
    /// category `Recommender`. Public, because the messages hold only steps, statuses and the
    /// server's error codes and reasons — never titles.
    private static let log: @Sendable (String) -> Void = { message in
        Logger(subsystem: "com.elbedev.sync", category: "Recommender")
            .notice("\(message, privacy: .public)")
    }

    /// Without App Attest (the Simulator, some Macs) the server would refuse every request, so
    /// the recommender isn't offered at all.
    public var isAvailable: Bool {
        appAttest.isSupported
    }

    /// - Throws: `RecommenderError`, whose `localizedDescription` is ready to show.
    @MainActor
    public func recommendations(for titles: [String]) async throws -> Recommendation {
        let books = try await client.recommendations(for: titles)
        return Recommendation(recommendations: books.map {
            BookRecommendation(title: $0.title, author: $0.author)
        })
    }
}
