import CoreData
import XCTest

import LibraryCore
@testable import Accounts
import Persistence

final class AccountsSectionViewModelTests: XCTestCase {

    private struct UnexpectedError: Error {}

    @MainActor func testRefreshWithoutErrorsShowsNoErrors() async {
        let viewModel = AccountsSectionViewModel {
            .finished(hasChanges: true, renewableItems: [], returnedItems: [], errors: [])
        } onLoanSelection: { _, _ in }

        await viewModel.refresh()

        XCTAssertEqual(viewModel.errors, [])
        XCTAssertFalse(viewModel.isShowingErrors)
    }

    @MainActor func testRefreshShowsTheErrorsOfTheUpdate() async {
        let viewModel = AccountsSectionViewModel {
            .finished(hasChanges: false, renewableItems: [], returnedItems: [], errors: [.accountUpdateFailed])
        } onLoanSelection: { _, _ in }

        await viewModel.refresh()

        XCTAssertEqual(viewModel.errors, [.accountUpdateFailed])
        XCTAssertTrue(viewModel.isShowingErrors)
    }

    @MainActor func testRefreshShowsALibraryErrorThatIsThrown() async {
        let viewModel = AccountsSectionViewModel {
            throw PaperErrorInternal.accountUpdateFailed
        } onLoanSelection: { _, _ in }

        await viewModel.refresh()

        XCTAssertEqual(viewModel.errors, [.accountUpdateFailed])
        XCTAssertTrue(viewModel.isShowingErrors)
    }

    @MainActor func testRefreshShowsAnUnexpectedErrorAsUnhandled() async {
        let viewModel = AccountsSectionViewModel {
            throw UnexpectedError()
        } onLoanSelection: { _, _ in }

        await viewModel.refresh()

        XCTAssertEqual(viewModel.errors, [.unhandledError(UnexpectedError().localizedDescription)])
        XCTAssertTrue(viewModel.isShowingErrors)
    }

    @MainActor func testRefreshClearsTheErrorsOfAnEarlierUpdate() async {
        let update = UpdateStub(error: PaperErrorInternal.accountUpdateFailed)
        let viewModel = AccountsSectionViewModel {
            try update.run()
        } onLoanSelection: { _, _ in }

        await viewModel.refresh()
        update.error = nil
        await viewModel.refresh()

        XCTAssertEqual(viewModel.errors, [])
        XCTAssertFalse(viewModel.isShowingErrors)
    }

    /// The editor stays open while the list behind it updates, because the navigation finds the edit view model it pushed by its value.
    @MainActor func testEditViewModelsOfTheSameAccountAreEqual() throws {
        let (dataStackProvider, accounts) = try Self.dataStackWithAccounts()
        let viewModel = AccountsSectionViewModel {
            .finished(hasChanges: false, renewableItems: [], returnedItems: [], errors: [])
        } onLoanSelection: { _, _ in }

        let first = editViewModel(of: accounts.first, from: viewModel, dataStackProvider: dataStackProvider)
        let firstAgain = editViewModel(of: accounts.first, from: viewModel, dataStackProvider: dataStackProvider)

        XCTAssertTrue(first == firstAgain)
        XCTAssertEqual(first.hashValue, firstAgain.hashValue)
    }

    @MainActor func testEditViewModelsOfDifferentAccountsDiffer() throws {
        let (dataStackProvider, accounts) = try Self.dataStackWithAccounts()
        let viewModel = AccountsSectionViewModel {
            .finished(hasChanges: false, renewableItems: [], returnedItems: [], errors: [])
        } onLoanSelection: { _, _ in }

        let first = editViewModel(of: accounts.first, from: viewModel, dataStackProvider: dataStackProvider)
        let second = editViewModel(of: accounts.second, from: viewModel, dataStackProvider: dataStackProvider)

        XCTAssertFalse(first == second)
    }

    // MARK: Helpers

    /// A single in-memory store for all tests, loading the managed object model more than once
    /// leaves Core Data unable to tell which entity a managed object subclass belongs to
    @MainActor private static let dataStackProvider: DataStackProvider = {
        let dataStackProvider = DataStackProvider()
        dataStackProvider.loadInMemory()
        return dataStackProvider
    }()

    /// Two saved accounts in the shared in-memory store.
    @MainActor private static func dataStackWithAccounts() throws -> (DataStackProvider, (first: NSManagedObjectID, second: NSManagedObjectID)) {
        let first = try dataStackProvider.createAccount()
        first.accountName = "first"
        let second = try dataStackProvider.createAccount()
        second.accountName = "second"
        try dataStackProvider.foregroundManagedObjectContext.save()

        return (dataStackProvider, (first.objectID, second.objectID))
    }

    @MainActor private func editViewModel(of account: NSManagedObjectID,
                                          from viewModel: AccountsSectionViewModel,
                                          dataStackProvider: DataStackProvider) -> AccountEditViewModel {
        viewModel.accountEditViewModel(for: account,
                                       dataStackProvider: dataStackProvider,
                                       accountService: LocalAccountRepository(context: dataStackProvider.foregroundManagedObjectContext),
                                       accountCredentialStore: CredentialStoreStub(),
                                       accountActivating: AccountActivatingStub())
    }
}

/// Holds no passwords.
private struct CredentialStoreStub: AccountCredentialStoring {
    func store(_ password: String, of accountIdentifier: String) throws {}
    func password(for accountIdentifier: String?) -> String? { nil }
    func removePassword(for accountIdentifier: String) {}
}

/// Leaves every account inactive.
private struct AccountActivatingStub: AccountActivating {
    @MainActor func activate(_ account: any Account) async -> ActivationState { .inactive }
}

/// An account update that fails with its error, or finishes without errors when it has none.
@MainActor private final class UpdateStub {
    var error: Error?

    init(error: Error?) {
        self.error = error
    }

    func run() throws -> UpdateResult {
        if let error {
            throw error
        }

        return .finished(hasChanges: true, renewableItems: [], returnedItems: [], errors: [])
    }
}
