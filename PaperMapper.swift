//
//  PaperMapper.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 27.12.24.
//  Copyright © 2024 neoneon. All rights reserved.
//
import Foundation
import Paper
import LibraryCore

// MARK: Recommender

public struct Recommender: LibraryCore.RecommenderProtocol {

    init() {}

    /// Asks AI for recommended book titles for a given list of book titles
    public func recommendations(for titles: [String]) async throws -> LibraryCore.Recommendation {
        try await Paper
            .Recommender()
            .getRecommendations(titles: titles, apiKey: BuildConfig.openRouterApiKey)
            .internalRecommendation
    }
}

extension Paper.Recommendation {
    var internalRecommendation: LibraryCore.Recommendation {
        Recommendation(recommendations: recommendations.map { $0.internalBookRecommendation })
    }
}

extension Paper.BookRecommendation {
    var internalBookRecommendation: LibraryCore.BookRecommendation {
        BookRecommendation(title: title, author: author)
    }
}

extension PaperErrorInternal {
    init(paperError: PaperError) {
        switch paperError {
        case .NotImplementedError: self = .NotImplementedError()
        case .GeneralError: self = .GeneralError
        case .LibraryNotSupportedError: self = .LibraryNotSupportedError
        case .SearchFailed: self = .SearchFailed
        case .FailedToRenew: self = .FailedToRenew
        case .RenewalTokenParserFailedToParseToken: self = .RenewalTokenParserFailedToParseToken
        case .MissingRenewalToken: self = .MissingRenewalToken
        case .FailedToParseRenewedLoan: self = .FailedToParseRenewedLoan
        case .FailedToParseLoans: self = .FailedToParseLoans
        case .FailedToRenewLoanBecauseItIsNotLoaned: self = .FailedToRenewLoanBecauseItIsNotLoaned
        case .LoginCurrentlyNotPossible: self = .LoginCurrentlyNotPossible
        case .IncorrectCredentials: self = .IncorrectCredentials
        case .CredentialsBadInput: self = .CredentialsBadInput
        case .FailedToReadSessionTokenResponseBody: self = .FailedToReadSessionTokenResponseBody
        case .FailedToGetSessionTokenResponse: self = .FailedToGetSessionTokenResponse
        case .FailedToGetRequestToken: self = .FailedToGetRequestToken
        case .FailedToGetResourceResponseContent: self = .FailedToGetResourceResponseContent
        case .ErrorGettingResourceResponse: self = .ErrorGettingResourceResponse
        case .FailedToCreateAccountInfoFromXml: self = .FailedToCreateAccountInfoFromXml
        case .IsInvalidBrwrNum: self = .IsInvalidBrwrNum
        case .ParseErrorAccountInfoName: self = .ParseErrorAccountInfoName
        case .ParseErrorAccountInfoAccountId: self = .ParseErrorAccountInfoAccountId
        case .ParseErrorAccountInfoAddress: self = .ParseErrorAccountInfoAddress
        case .ParseErrorAccountInfoEmail: self = .ParseErrorAccountInfoEmail
        case .ParseErrorAccountInfoPhone: self = .ParseErrorAccountInfoPhone
        case .ParseErrorAccountInfoServiceStatus: self = .ParseErrorAccountInfoServiceStatus
        case .ParseErrorSearchResultDetail: self = .ParseErrorSearchResultDetail
        case .ParseErrorAccountInfoServiceChargeInfo: self = .ParseErrorAccountInfoServiceChargeInfo
        case .ParseErrorAccountInfoServiceChargeAmount: self = .ParseErrorAccountInfoServiceChargeAmount
        case .ParseErrorAccountInfoBalance: self = .ParseErrorAccountInfoBalance
        case .ErrorParsingUrl: self = .ErrorParsingUrl
        case .ReqwestError: self = .ReqwestError
        case .IoError(let value): self = .IoError(value)
        case .ParserError(let value): self = .ParserError(value)
        case .ErrorWithMessage(let value): self = .ErrorWithMessage(value)
        }
    }
}

public struct AccountScraper: AccountServiceProviding {

    public func account(username: String?, password: String?, library: LibraryModel) async throws(PaperErrorInternal) -> InternalAccount? {

        guard let apiConfiguration = ApiConfiguration(library: library) else {
            throw .LibraryNotSupportedError
        }

        let configuration = Paper.Configuration(username: username, password: password, apiConfiguration: apiConfiguration)
        let scraper = LibraryScraper(configuration: configuration)

        do {
            return try await scraper.fetchAccount().internalAccount
        } catch let error as PaperError {
            if case PaperError.NotImplementedError = error {
                throw PaperErrorInternal.NotImplementedError(username: username)
            } else {
                throw PaperErrorInternal(paperError: error)
            }
        } catch {
            throw .unhandledError(error.localizedDescription)
        }
    }
}

/// This logic is not in Paper since the clients currently define the identifier of a library themselves.
extension Paper.ApiConfiguration {

    init?(library: LibraryModel) {
        guard let baseUrl = library.baseURL, let catalogUrl = library.catalogUrl else { return nil }

        if library.isPublicHamburg {
            self.init(api: .hamburgPublic, baseUrl: baseUrl, catalogUrl: catalogUrl)
        } else {
            self.init(api: .opc4v213vzg6, baseUrl: baseUrl, catalogUrl: catalogUrl)
        }
    }
}

public struct SearchScraper: SearchScraping {

    enum SearchScraperError: Error {
        /// this is thrown when a library was used that is not supported by Paper
        case unsupportedLibrary
    }

    public init() {}

    public func search(text: String, in library: LibraryModel, nextPageUrl: String?) async throws  -> LibraryCore.SearchResultList {

        guard let configuration = Paper.ApiConfiguration(library: library) else { throw SearchScraperError.unsupportedLibrary }

        let result = try await Paper.SearchScraper(configuration: configuration)
            .search(text: text, nextPageUrl: nextPageUrl)
        return result.asSearchResultList
    }
}

public struct SearchResultDetailScraper: LibraryCore.SearchResultDetailsProviding {
    public init() {}

    public enum SearchResultDetailScraperError: Error {
        case invalidURL
        /// this is thrown when a library was used that is not supported by Paper
        case unsupportedLibrary
    }

    /// - parameter url: "suchergebnis-detail/medium/T020861691.html"
    public func details(for url: URL?, in library: LibraryModel) async throws -> any LibraryCore.SearchResultDescribing {
        guard let url else {
            throw SearchResultDetailScraperError.invalidURL
        }
        guard let configuration = Paper.ApiConfiguration(library: library) else { throw SearchResultDetailScraperError.unsupportedLibrary }

        return try await Paper.SearchDetailScraper(configuration: configuration).detailsForUrl(url: url.absoluteString).asSearchResultDetail
    }

    public func status(availabilities: [LibraryCore.Availability], in library: LibraryModel) -> LibraryCore.AvailabilityStatus {
        guard let apiConfiguration = ApiConfiguration(library: library) else {
//            throw NSError.unknownLibraryError()
            return .noneAvailable // TODO: make this throw
        }

        return Paper.SearchDetailScraper(configuration: apiConfiguration).status(availabilities: availabilities.map { $0.paperAvailability }).availabilityStatus
    }
}

extension Paper.ItemAvailability {
    var asAvailability: LibraryCore.ItemAvailability {
        .init(availabilities: availabilities.map { $0.asAvailability })
    }
}

extension Paper.Loan {
    var internalLoan: InternalLoan {
        .init(
            title: title,
            author: author,
            canRenew: canRenew,
            renewalToken: renewalToken,
            renewalsCount: renewalsCount,
            dateDue: dateDue,
            borrowedAt: borrowedAt,
            itemNumber: itemNumber,
            lockedByPreorder: lockedByPreorder,
            details: details.asSearchResultDetails,
            searchResultDetailUrl: searchResultDetailUrl
        )
    }
}

extension Paper.SearchResultDetail {
    var asSearchResultDetails: LibraryCore.SearchResultDetail {
        LibraryCore.SearchResultDetail(
            mediumTitle: mediumTitle,
            mediumAuthor: mediumAuthor,
            fullTitle: fullTitle,
            smallImageUrl: smallImageUrl,
            signature: signature,
            dataEntries: dataEntries.map(\.asDataEntry),
            hint: hint,
            availability: availability.asAvailability
        )
    }
}

extension Paper.Balance {
    var internalBalance: LibraryCore.InternalBalance {
        LibraryCore.InternalBalance(total: total, charges: charges.map(\.asCharge))
    }
}

extension Paper.Charge {
    var asCharge: LibraryCore.InternalCharge {
        InternalCharge(
            timestamp: timestamp,
            amountOwed: amountOwed,
            amountPayed: amountPayed,
            reason: reason,
            item: item,
            source: source
        )
    }
}

extension Paper.Account {
    var internalAccount: InternalAccount {
        InternalAccount(
            accountId: accountId,
            name: name,
            address: address,
            phone: phone,
            email: email,
            chargeInfo: chargeInfo,
            loans: loans.asLoans,
            balance: balance?.internalBalance,
            notifications: notifications.map(\.internationalNotification)
        )
    }
}

extension Paper.Loans {
    var asLoans: InternalLoans {
        InternalLoans(loans: loans.map(\.internalLoan))
    }
}

extension Paper.Notification {
    var internationalNotification: LibraryCore.InternalNotification {
        .init(notificationType: notificationType.internalNotificationType, message: message)
    }
}

extension Paper.NotificationType {
    var internalNotificationType: InternalNotificationType {
        switch self {
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}

extension Paper.SearchResultList {
    var asSearchResultList: LibraryCore.SearchResultList {
        SearchResultList(text: text, nextPageUrl: nextPageUrl, resultCount: resultCount, items: items.map { $0.asSearchResultListItem })
    }
}

extension Paper.SearchResultListItem {
    var asSearchResultListItem: LibraryCore.SearchResultListItem {
        LibraryCore.SearchResultListItem(identifier: identifier, title: title, subtitle: subtitle, itemNumber: itemNumber, detailUrl: detailUrl, coverImageUrl: coverImageUrl)
    }
}

extension Paper.ValidationStatus {
    var asValidationStatus: LibraryCore.ValidationStatus {
        switch self {
        case .valid:
            return .valid
        case .invalid:
            return .invalid
        case .error(let description):
            return .error(description)
        }
    }
}

extension LibraryCore.Availability {
    var paperAvailability: Paper.Availability {
        switch self {
        case .available(let location):
            return .available(location.paperLocation)
        case .notAvailable(let location):
            return .notAvailable(location.paperLocation)
        case .unknown(let location):
            return .unknown(location.paperLocation)
        }
    }
}

extension Paper.Availability {
    var asAvailability: LibraryCore.Availability {
        switch self {
        case .available(let location):
            return .available(location.asLocation)
        case .notAvailable(let location):
            return .notAvailable(location.asLocation)
        case .unknown(let location):
            return .unknown(location.asLocation)
        }
    }
}

extension LibraryCore.Location {
    var paperLocation: Paper.Location {
        .init(name: name)
    }
}

extension Paper.Location {
    var asLocation: LibraryCore.Location {
        .init(name: name)
    }
}

extension Paper.AvailabilityStatus {
    var availabilityStatus: LibraryCore.AvailabilityStatus {
        switch self {
        case .allAvailable:
            return .allAvailable
        case .noneAvailable:
            return .noneAvailable
        case .someAvailable:
            return .someAvailable
        }
    }
}

public extension Paper.SearchResultDetail {
    var asSearchResultDetail: LibraryCore.SearchResultDetail {
        SearchResultDetail(
            mediumTitle: mediumTitle,
            mediumAuthor: mediumAuthor,
            fullTitle: fullTitle,
            smallImageUrl: smallImageUrl,
            signature: signature,
            dataEntries: dataEntries.map(\.asDataEntry),
            hint: hint,
            availability: availability.asAvailability
        )
    }
}

extension Paper.DataEntry {
    var asDataEntry: LibraryCore.DataEntry {
        LibraryCore.DataEntry(label: label, value: value)
    }
}
