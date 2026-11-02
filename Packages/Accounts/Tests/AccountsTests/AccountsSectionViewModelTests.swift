import XCTest

import LibraryCore
@testable import Accounts

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
