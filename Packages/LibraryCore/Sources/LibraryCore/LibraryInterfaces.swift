import Combine
import CoreData
import Foundation
import SwiftUI

public enum DataStackProviderError: Error, Equatable {
    case persistentStoreNotConfigured
    case loanNotFound
}

public enum AccountRepositoryError: Error, Equatable {
    case update(UpdateFailureReason)
    case accountDoesNotExist

    public enum UpdateFailureReason : Sendable, Equatable {
        case invalidCredentials
        case missingCredentials
        case missingPersistentContainer
        case unknown(String?)
    }
}

public enum RenewalError: Error, Equatable {
    case tooLate
    case badTypeOfLoan
    case unexpectedError
}

public enum AccountUpdaterError: Error, Equatable {
    case missingObjectContext
    case managedObjectNotFound
    case manualUpdateFailed(String)
}

public enum UpdateAccountUsecaseError: Error, Equatable {
    case oneOrMoreAccountUpdatesFailed
    case unableToSaveAfterAccountUpdate
}

public enum SerializationError: Error, Equatable {
    case accountDoesNotExist
}

public enum PaperErrorInternal: Error, Equatable, Identifiable {
    public var id: String { localizedDescription + UUID().uuidString }

    case accountUpdateFailed
    case unhandledError(String)
    case renewalError(RenewalError)
    case accountUpdaterError(AccountUpdaterError)
    case updateAccountUsecaseError(UpdateAccountUsecaseError)
    case dataStackProviderError(DataStackProviderError)
    case accountReposioryError(AccountRepositoryError)
    case loanSerializerError(SerializationError)
    case NotImplementedError(username: String? = nil)
    case GeneralError
    case LibraryNotSupportedError
    case SearchFailed
    case FailedToRenew
    case RenewalTokenParserFailedToParseToken
    case MissingRenewalToken
    case FailedToParseRenewedLoan
    case FailedToParseLoans
    case FailedToRenewLoanBecauseItIsNotLoaned
    case LoginCurrentlyNotPossible
    case IncorrectCredentials
    case CredentialsBadInput
    case FailedToReadSessionTokenResponseBody
    case FailedToGetSessionTokenResponse
    case FailedToGetRequestToken
    case FailedToGetResourceResponseContent
    case ErrorGettingResourceResponse
    case FailedToCreateAccountInfoFromXml
    case IsInvalidBrwrNum
    case ParseErrorAccountInfoName
    case ParseErrorAccountInfoAccountId
    case ParseErrorAccountInfoAddress
    case ParseErrorAccountInfoEmail
    case ParseErrorAccountInfoPhone
    case ParseErrorAccountInfoServiceStatus
    case ParseErrorSearchResultDetail
    case ParseErrorAccountInfoServiceChargeInfo
    case ParseErrorAccountInfoServiceChargeAmount
    case ParseErrorAccountInfoBalance
    case ErrorParsingUrl
    case ReqwestError
    case IoError(String)
    case ParserError(String)
    case ErrorWithMessage(String)
}

public protocol AuthenticationManaging {
    func authenticateAccount(_ accountIdentifier: String,
                             in library: LibraryModel,
                             context: NSManagedObjectContext,
                             libraryProvider: LibraryProvider,
                             completion:@escaping (_ authenticated: Bool, _ error: NSError?) -> Void)
}

public protocol AccountCredentialStoring {
    func store(_ password: String, of accountIdentifier: String) throws
    func password(for accountIdentifier: String?) -> String?
    func removePassword(for accountIdentifier: String)
}

public extension EnvironmentValues {
    var libraryProvider: (any LibraryProvider)? {
        get { self[LibraryProviderEnvironmentKey.self] }
        set { self[LibraryProviderEnvironmentKey.self] = newValue }
    }
}

struct LibraryProviderEnvironmentKey: EnvironmentKey {
    static var defaultValue: (any LibraryProvider)? // TODO: add nooop library provider
}

public extension EnvironmentValues {
    var accountCredentialStore: any AccountCredentialStoring {
        get { self[AccountCredentialStoreEnvironmentKey.self] }
        set { self[AccountCredentialStoreEnvironmentKey.self] = newValue }
    }
}

struct AccountCredentialStoreEnvironmentKey: EnvironmentKey {
    static var defaultValue: any AccountCredentialStoring = NoopAccountCredentialStore()
}

private struct NoopAccountCredentialStore: AccountCredentialStoring {
    func password(for accountIdentifier: String?) -> String? {
        nil
    }
    
    func removePassword(for accountIdentifier: String) {
    }
    
    func store(_ password: String, of accountIdentifier: String) throws {
    }
}

@objc
public protocol KeychainProvider {

    /// Stores a password of an account in the keychain
    /// - Parameters:
    ///     - parameter password: The password to store
    ///     - parameter accountIdentifier: The identifier of the belonging account
    func add(password: String, to account: String) throws

    /// Deletes the password of the given account
    /// - Parameters:
    ///     - parameter account: The account the password to delete belongs to.
    func deletePassword(of account: String)

    /**
     Retrieve a password belonging to an account
     - returns: The optional session identifier if one was found
     - parameter account: The account to retrieve the password for
     */
    func password(for account: String) -> String?
}

public protocol LoanService: AnyObject, BookmarkServicing, LoanBackendServicing, LoanInfoService {

}

public enum Setting {
    case notificationsEnabled(Bool)
    case notificationsAuthorized(Bool)
}

public protocol DatabaseConnectionProducing {
    func databaseConnection(for managedObjectContext: NSManagedObjectContext, accountService: AccountServiceProviding) -> LoanBackendServicing
}

public enum ProgressButtonState: Equatable {
    case idle(systemImageName: String)
    case animating(systemImageName: String)
    case success(systemImageName: String)
    case failure(systemImageName: String)
}

public protocol LoanViewModel: AnyObject, Identifiable, Hashable, ObservableObject {
    var loan: any Loan { get }
    var notificationDescription: String? { get }
    var isBookmarked: Bool { get }
    var progressButtonState: ProgressButtonState { get }
    var showsRenewalConfirmation: Bool { get set }
    var shouldRequestAppReview: Bool { get set }
    var lockedByPreorderDescription: String { get }

    func updateAsyncProperties()

    func toggleBookmarked() async

    func renew() async throws
}

public protocol LoanListViewModel: ObservableObject {

    var isShowingErrors: Bool { get set }
    var errors: [PaperErrorInternal] { get }

    func refresh() async throws

    func show(_ loan: some LoanViewModel)
}

public protocol AppReviewService {
    var shouldRequestAppReview: Bool { get }

    func resetAppReviewRequestIndicators()
    func increaseLatestSuccessfulRenewalCount(by count: Int)
    func increaseLatestAppLaunchCount(by count: Int)
}

public protocol SettingsService: AnyObject {

    var publisher: PassthroughSubject<Setting, Never> { get }
    var lastAutomaticAccountUpdateDate: Date? { get }
    var lastManualAccountUpdateDate: Date? { get }

    func openSettings() async

    var isAlternateAppIconEnabled: Bool { get }
    func toggleAlternateAppIcon()

    func notificationsAuthorized() async -> Bool

    func toggleNotificationsEnabled(on isOn: Bool)
    func notificationsEnabled() -> Bool

    func loanExpirationNotificationsEnabled() -> Bool
    func toggleLoanExpirationNotificationsEnabled(on isOn: Bool)

    var loanExpirationNotificationsThreshold: UInt { get set }

    var debugEnabled: Bool { get }
    func toggleDebugEnabled(on isOn: Bool)
}

public protocol Account: AnyObject {
    var allLoans: [any LibraryCore.Loan] { get }
    var allCharges: [any LibraryCore.Charge] { get }
    var name: String? { get set }
    var username: String? { get set }
    var avatar: String? { get set }
    var isActivated: Bool { get set }
    var library: (any Library)? { get set }
}

public protocol SearchResultInfoHolding {
    var maxResults: Int { get }
    var searchResultInfos: [SearchResultInfo] { get }
}

public protocol SearchProviding {
    func search(for text: String, page: UInt, library: any LibraryCore.Library) async throws -> SearchResultInfoHolding
}

public protocol AccountServiceProviding {
    func account(username: String?, password: String?, library: LibraryModel) async throws -> InternalAccount?
}

public protocol SearchResultDetailsProviding {
    func details(for url: URL?, in library: LibraryModel) async throws -> any LibraryCore.SearchResultDescribing
    func status(availabilities: [LibraryCore.Availability], in library: LibraryModel) -> LibraryCore.AvailabilityStatus
}

public protocol SearchResultDescribing {
    var content: [Pair] { get }
    var availability: ItemAvailability { get }
}

public struct ItemAvailability {
    public var availabilities: [Availability]

    public init(availabilities: [Availability]) {
        self.availabilities = availabilities
    }
}

public protocol SearchScraping {
    func search(text: String, in library: LibraryModel, nextPageUrl: String?) async throws  -> LibraryCore.SearchResultList
}

public enum AvailabilityStatus {
    case allAvailable
    case noneAvailable
    case someAvailable
}

public enum Availability {

    case available(Location)
    case notAvailable(Location)
    case unknown(Location)
}

public struct Location: Hashable {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

public struct DataEntry {
    public var label: String
    public var value: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

extension Array where Element == DataEntry {
    public var asPairs: [Pair] {
        map { Pair(key: $0.label, value: $0.value) }
    }
}


public struct SearchResultDetail: LibraryCore.SearchResultDescribing {
    public var content: [Pair] {
        dataEntries.asPairs
    }

    public var mediumTitle: String?
    public var mediumAuthor: String?
    public var fullTitle: String?
    public var smallImageUrl: String?
    public var signature: String?
    public var dataEntries: [DataEntry]
    public var hint: String?
    public var availability: LibraryCore.ItemAvailability

    public init(mediumTitle: String?, mediumAuthor: String?, fullTitle: String?, smallImageUrl: String?, signature: String?, dataEntries: [LibraryCore.DataEntry], hint: String?, availability: LibraryCore.ItemAvailability) {
        self.mediumTitle = mediumTitle
        self.mediumAuthor = mediumAuthor
        self.fullTitle = fullTitle
        self.smallImageUrl = smallImageUrl
        self.signature = signature
        self.dataEntries = dataEntries
        self.hint = hint
        self.availability = availability
    }
}

public struct SearchResultListItem {
    public var identifier: String
    public var title: String?
    public var subtitle: String?
    public var itemNumber: String?
    public var detailUrl: String?
    public var coverImageUrl: String?

    public init(identifier: String, title: String?, subtitle: String?, itemNumber: String?, detailUrl: String?, coverImageUrl: String?) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.itemNumber = itemNumber
        self.detailUrl = detailUrl
        self.coverImageUrl = coverImageUrl
    }
}



public struct SearchResultList {
    public var text: String
    public var nextPageUrl: String?
    public var resultCount: UInt32
    public var items: [SearchResultListItem]

    public init(text: String, nextPageUrl: String?, resultCount: UInt32, items: [SearchResultListItem]) {
        self.text = text
        self.nextPageUrl = nextPageUrl
        self.resultCount = resultCount
        self.items = items
    }
}



public struct InternalLoans {
    public var loans: [InternalLoan]

    public init(loans: [InternalLoan]) {
        self.loans = loans
    }
}

public struct InternalLoan {
    public var title: String
    public var author: String
    public var canRenew: Bool
    public var renewalToken: String?
    public var renewalsCount: UInt8
    public var dateDue: String
    public var borrowedAt: String
    public var itemNumber: String
    public var lockedByPreorder: Bool
    public var details: LibraryCore.SearchResultDetail
    public var searchResultDetailUrl: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(title: String, author: String, canRenew: Bool, renewalToken: String?, renewalsCount: UInt8, dateDue: String, borrowedAt: String, itemNumber: String, lockedByPreorder: Bool, details: SearchResultDetail, searchResultDetailUrl: String?) {
        self.title = title
        self.author = author
        self.canRenew = canRenew
        self.renewalToken = renewalToken
        self.renewalsCount = renewalsCount
        self.dateDue = dateDue
        self.borrowedAt = borrowedAt
        self.itemNumber = itemNumber
        self.lockedByPreorder = lockedByPreorder
        self.details = details
        self.searchResultDetailUrl = searchResultDetailUrl
    }
}


public struct InternalBalance {
    public var total: String
    public var charges: [InternalCharge]

    public init(total: String, charges: [InternalCharge]) {
        self.total = total
        self.charges = charges
    }
}

public struct InternalCharge {
    public var timestamp: Int64
    public var amountOwed: Double
    public var amountPayed: Double
    public var reason: String
    public var item: String
    public var source: String

    public init(timestamp: Int64, amountOwed: Double, amountPayed: Double, reason: String, item: String, source: String) {
        self.timestamp = timestamp
        self.amountOwed = amountOwed
        self.amountPayed = amountPayed
        self.reason = reason
        self.item = item
        self.source = source
    }
}

public enum InternalNotificationType {
    case info
    case warning
    case error
}


public struct InternalNotification {
    public var notificationType: InternalNotificationType
    public var message: String

    public init(notificationType: InternalNotificationType, message: String) {
        self.notificationType = notificationType
        self.message = message
    }
}

public struct InternalAccount {
    public var accountId: String
    public var name: String
    public var address: String
    public var phone: String
    public var email: String
    public var chargeInfo: [String: String]
    public var loans: InternalLoans
    public var balance: InternalBalance?
    public var notifications: [InternalNotification]

    public init(accountId: String, name: String, address: String, phone: String, email: String, chargeInfo: [String: String], loans: InternalLoans, balance: InternalBalance?, notifications: [InternalNotification]) {
        self.accountId = accountId
        self.name = name
        self.address = address
        self.phone = phone
        self.email = email
        self.chargeInfo = chargeInfo
        self.loans = loans
        self.balance = balance
        self.notifications = notifications
    }
}

extension SearchResultList: LibraryCore.SearchResultInfoHolding {
    public var maxResults: Int {
        Int(resultCount)
    }

    public var searchResultInfos: [LibraryCore.SearchResultInfo] {
        items.map {
            LibraryCore.SearchResultInfo(
                identifier: $0.identifier,
                title: $0.title ?? "",
                subtitle: $0.subtitle ?? "",
                number: $0.itemNumber ?? "",
                imageUrl: URL(string: $0.coverImageUrl ?? ""),
                detailUrl: URL(string: $0.detailUrl ?? "")
            )
        }
    }
}

@objc public protocol LibraryProvider {

    /// The default library which is selected when no user selection has happened yet
    var defaultLibrary: NSManagedObjectID? { get }

    var searchLibrary: NSManagedObjectID? { get }

    /// A library for the given identifier
    func library(forIdentifier: String, in context: NSManagedObjectContext?) -> NSManagedObjectID?

    func loadOrUpdateLibraries(in context: NSManagedObjectContext?)
}

public struct LibraryModel: Sendable, Library {
    public var id: String { identifier ?? UUID().uuidString }

    /// Whether or not the library is supported by BTLB
    public let name: String?
    public let subtitle: String?
    public let identifier: String?
    public let baseURL: String?
    public let catalogUrl: String?

    public init(name: String?, subtitle: String?, identifier: String?, baseUrl: String?, catalogUrl: String?) {
        self.name = name
        self.subtitle = subtitle
        self.identifier = identifier
        self.baseURL = baseUrl
        self.catalogUrl = catalogUrl
    }

    public var isPublicHamburg: Bool {
        identifier == "HAMBURGPUBLIC"
    }
}

public extension LibraryModel {
    init?(wrapping: (any Library)?) {
        guard let wrapping else { return nil }
        self.init(
            name: wrapping.name,
            subtitle: wrapping.subtitle,
            identifier: wrapping.baseURL,
            baseUrl: wrapping.catalogUrl,
            catalogUrl: wrapping.identifier
        )
    }
}

public protocol Library: Identifiable, Hashable {
    var name: String? { get }
    var subtitle: String? { get }
    var baseURL: String? { get }
    var catalogUrl: String? { get }
    var identifier: String? { get }
}

public extension Library {
    /// Whether or not the library is supported by BTLB
    var isAvailable: Bool {
        /// Allow all libraries to be selected as search and account synchronisation libraries except these:
        if identifier == "GREIFSWALD" ||
            identifier == "COMMERZ_HH" ||
            identifier == "LUH" {
            return false
        }

        return true
    }

    var isAvailableForLogin: Bool {
        /// Allow all libraries to be selected as search and account synchronisation libraries except these:
        if !(identifier ?? "").isEmpty {
            return true
        }

        return false
    }
}


var kDefaultSearchLibraryIdentifier: String { "HAMBURGPUBLIC" }

public protocol Bookmark: AnyObject, Identifiable, Hashable {
    var bookmarkIdentifier: String? { get }
    var bookmarkTitle: String? { get }
    var bookmarkAuthor: String? { get }
    var bookmarkImageUrl: String? { get }
    var bookmarkLibraryIdentifier: String? { get }
    var infos: [Info] { get }
}

public protocol Charge: AnyObject, Identifiable {
    var chargeAmount: Float { get }
    var reason: String? { get }
}

public protocol Renewable {
    var barcode: String { get }
}

public protocol Loan: AnyObject, Identifiable, Hashable, Renewable {
    var libraryIdentifier: String { get }
    var author: String? { get }
    var title: String { get }
    var subtitle: String { get }
    var dueDate: Date { get }
    var shelfmark: String { get }
    var iconUrl: String? { get }
    var renewalCount: Int { get }
    var canRenew: Bool { get }
    var renewalToken: String? { get }
    var lockedByPreorder: Bool { get }
    var volume: String? { get }
    var barcode: String { get }
    var infos: [Info] { get }
    var notificationScheduledDate: Date? { get set }
}

public struct Info: Identifiable, Hashable {

    public var id: String { title }
    public let title: String
    public let value: String

    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

public protocol LocalAccountService {
    func account(for identifier: NSManagedObjectID, in context: NSManagedObjectContext) async -> Account?
    func deleteAccount(with identifier: NSManagedObjectID) async throws
}

public extension EnvironmentValues {
    var localAccountService: any LocalAccountService {
        get { self[LocalAccountServiceEnvironmentKey.self] }
        set { self[LocalAccountServiceEnvironmentKey.self] = newValue }
    }
}

struct LocalAccountServiceEnvironmentKey: EnvironmentKey {
    static var defaultValue: any LocalAccountService = NoopLocalAccountService()
}

public struct NoopLocalAccountService: LocalAccountService {
    public func account(for identifier: NSManagedObjectID, in context: NSManagedObjectContext) async -> Account? {
        nil
    }

    public func deleteAccount(with identifier: NSManagedObjectID) async throws {

    }
}

public protocol LoanInfoService {
    func nextReturnDate() async -> Date
}

public protocol LoanBackendServicing {
    @MainActor func renew(loan: any Renewable) async throws -> Result<any LibraryCore.Loan, Error>

    func initiateUpdate(forAccount accountID: NSManagedObjectID,
                        accountIdentifier temporaryAccountIdentifier: String?,
                        password temporaryPassword: String?,
                        libraryProvider: Any) async throws
}

public protocol BookmarkServicing {
    @MainActor func isBookmarked(identifier: String?, title: String?) async throws -> Bool

    @MainActor func toggleBookmarked(_ loan: any LibraryCore.Loan) async throws -> Bool
}

// MARK: Account Activating Environment Object

public struct AccountActivatingEnvironmentKey: EnvironmentKey {
    public typealias Value = any AccountActivating

    public static var defaultValue: any AccountActivating = EnvironmentNoopAccountActivating()
}

final class EnvironmentNoopAccountActivating: AccountActivating {
    func activate(_ account: Account) async -> ActivationState {
        // no op
        .error
    }
}

public protocol AccountUpdating {
    /// instead of having manual and auto update functions, these should be a single function as follows ↓ wait for when @objc is gone
    /// `func update(_ trigger: UpdateTrigger) async throws`
    @discardableResult func update(in moc: NSManagedObjectContext?) async throws -> UpdateResult
    @discardableResult func manualUpdate(in moc: NSManagedObjectContext?, at: Date) async throws -> UpdateResult
    func update(completion:@escaping (NSError?) -> ())
}

public extension EnvironmentValues {
    var accountActivating: any AccountActivating {
        get { self[AccountActivatingEnvironmentKey.self] }
        set { self[AccountActivatingEnvironmentKey.self] = newValue }
    }
}

public struct AccountUpdatingEnvironmentKey: EnvironmentKey {
    public typealias Value = any AccountUpdating

    public static var defaultValue: any AccountUpdating = EnvironmentNoopAccountUpdating()
}

public protocol RenewingUseCase {
    func renew(item: String, renewalToken: String?, for account: String?, password: String?, in library: LibraryModel?) async throws -> (dueDateString: String, renewalCount: Int, canRenew: Bool)
}

public enum ValidationStatus: Equatable {
    case valid
    case invalid
    case error(String)
}

public protocol AccountValidatingUseCase {

    /// Validates a credentials against a given library for validity
    /// - Parameters:
    ///   - account: account
    ///   - password: password
    ///   - library: the library to validate against
    /// - Returns: the validation status
    func validate(account: String?, password: String?, library: LibraryModel) async throws -> ValidationStatus
}


final class EnvironmentNoopAccountUpdating: AccountUpdating {

    func update(completion:@escaping (NSError?) -> ()) {
        completion(nil)
    }

    func update(in moc: NSManagedObjectContext?) async throws -> UpdateResult {
        .error(.NotImplementedError())
    }
    
    func manualUpdate(in moc: NSManagedObjectContext?, at: Date) async throws(PaperErrorInternal) -> UpdateResult {
        .error(.NotImplementedError())
    }
}

public extension EnvironmentValues {
    var accountUpdating: any AccountUpdating {
        get { self[AccountUpdatingEnvironmentKey.self] }
        set { self[AccountUpdatingEnvironmentKey.self] = newValue }
    }
}

// MARK: Loan Service Environment Object

public struct LoanServiceEnvironmentKey: EnvironmentKey {
    public typealias Value = any LoanService

    public static var defaultValue: any LoanService = EnvironmentNoopLoanService()
}

///
/// Example:
/// 
/// ```swift
/// @Environment(\.loanService) private var loanService
/// ```
public extension EnvironmentValues {
    var loanService: any LoanService {
        get { self[LoanServiceEnvironmentKey.self] }
        set { self[LoanServiceEnvironmentKey.self] = newValue }
    }
}

import AppIntents
public struct IntentEnvironmentKey: EnvironmentKey {
    public typealias Value = (any AppIntent)?

    public static var defaultValue: (any AppIntent)? = nil
}

public extension EnvironmentValues {
    var intent: (any AppIntent)? {
        get { self[IntentEnvironmentKey.self] }
        set { self[IntentEnvironmentKey.self] = newValue }
    }
}

/// This is the default LoanService in the environment when nothing else has been setup.
/// It does not perform any operations, it's no op.
public final class EnvironmentNoopLoanService: LoanService {

    public static let shared = EnvironmentNoopLoanService()
}

extension EnvironmentNoopLoanService: LoanBackendServicing {
    enum EnvironmentNoopLoanServiceError: Error {
        case error
    }

    @MainActor public func renew(loan: any Renewable) async throws -> Result<any LibraryCore.Loan, Error> {
        .failure(EnvironmentNoopLoanServiceError.error)
    }

    public func initiateUpdate(forAccount accountID: NSManagedObjectID, accountIdentifier temporaryAccountIdentifier: String?, password temporaryPassword: String?, libraryProvider: Any) async throws(PaperErrorInternal) {
        throw .NotImplementedError()
    }
    
}

extension EnvironmentNoopLoanService: BookmarkServicing {
    @MainActor public func isBookmarked(identifier: String?, title: String?) async throws -> Bool {
        false
    }

    @MainActor public func toggleBookmarked(_ loan: any Loan) async throws -> Bool {
        false
    }
}

extension EnvironmentNoopLoanService: LoanInfoService {
    public func nextReturnDate() async -> Date {
        var components = DateComponents()
        components.day = 13
        components.month = 2
        components.year = 1983

        return Calendar.current.date(from: components) ?? .now
    }
}

// MARK: - Internals

struct NoOpBackEndService: LoanBackendServicing {

    static let noop = NoOpBackEndService()

    @MainActor func renew(loan: any Renewable) async throws -> Result<any LibraryCore.Loan, Error> {
        .failure(PaperErrorInternal.NotImplementedError())
    }

    func initiateUpdate(forAccount accountID: NSManagedObjectID, accountIdentifier temporaryAccountIdentifier: String?, password temporaryPassword: String?, libraryProvider: Any) async throws(PaperErrorInternal) {
        throw .NotImplementedError()
    }
}

struct NoOpBookmarkServicing: BookmarkServicing {

    static let noop = NoOpBookmarkServicing()

    @MainActor public func isBookmarked(identifier: String?, title: String?) async throws -> Bool {
        Bool.random()
    }

    @MainActor func toggleBookmarked(_ loan: any Loan) async throws -> Bool {
        Bool.random()
    }
}
