//
//  RecommenderError.swift
//  Bookmarks
//

/// Why recommendations could not be loaded, in terms a person can act on. Localized in
/// `RecommenderError+Localized.swift`.
public enum RecommenderError: Error, Equatable, Sendable {
    /// App Attest isn't available on this device (the Simulator, some Macs). The recommender is
    /// hidden there, so this should not be reachable from the UI.
    case notSupported
    /// No bookmark with a usable title was selected.
    case noTitles
    /// neoneon.dev couldn't be reached.
    case network
    /// This device asked too often (`429 rate_limited`).
    case rateLimited
    /// Switched off on the server, or today's budget is used up (`503 unavailable`), or Apple's
    /// App Attest service is temporarily unavailable.
    case unavailable
    /// The server rejected the request's timestamp (`stale_timestamp`): the device clock is off.
    case deviceClock
    /// Anything else, including a model reply the server refused to pass on (`upstream_failed`).
    case failed
}

/// One recommended book, as the server returned it.
struct RecommendedBook: Equatable, Sendable {
    let title: String
    let author: String
}
