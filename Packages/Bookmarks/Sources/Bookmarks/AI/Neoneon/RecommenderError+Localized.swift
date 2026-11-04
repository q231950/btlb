//
//  RecommenderError+Localized.swift
//  Bookmarks
//

import Foundation
import Localization

extension RecommenderError: LocalizedError {
    public var errorDescription: String? {
        let key: String
        switch self {
        case .notSupported: key = "Recommender Error Not Supported"
        case .noTitles: key = "Recommender Error No Titles"
        case .network: key = "Recommender Error Network"
        case .rateLimited: key = "Recommender Error Rate Limited"
        case .unavailable: key = "Recommender Error Unavailable"
        case .deviceClock: key = "Recommender Error Device Clock"
        case .failed: key = "Recommender Error Failed"
        }
        return key.localized(bundle: .module)
    }
}
