import AppIntents
import Foundation
import os.log
import SwiftUI

import BTLBIntents
import BTLBSettings
import LibraryCore
import Persistence
import Utilities

public struct RenewItemsIntent: AppIntent {

    public init() {}

    init(items: [ItemEntity]) {
        self.items = items
    }

    public static var title: LocalizedStringResource = LocalizedStringResource("renew intent title")

    public static var description = IntentDescription("renew intent description",
                                                      categoryName: "renew intent category name",
                                                      searchKeywords: [
                                                        "renew intent search keyword renew",
                                                        "renew intent search keyword library",
                                                        "renew intent search keyword prolong",
                                                        "renew intent search keyword book",
                                                        "renew intent search keyword media"])

    public static var parameterSummary: some ParameterSummary {
        Summary("renew intent parameter summary")
    }

    @MainActor public func perform() async throws -> some IntentResult & ShowsSnippetView {
        Logger.intentLogging.debug("Performing renewal \(items.map { $0.title })")

        // there are no renewable items to choose from
        guard try await ItemEntity.defaultQuery.suggestedEntities().count > 0 else {
            return .result(view: AppIntentRenewalItemsEmptyView())
        }

        // User has not selected any item from the list of renewable items
        guard items.count > 0 else {
            return .result(view: AppIntentRenewalNoSelectionView())
        }

        let loanService = DatabaseConnectionFactory().databaseConnection(
            for: DataStackProvider.shared.foregroundManagedObjectContext,
            accountService: AccountScraper()
        )

        let renewedItemResults = try await withThrowingTaskGroup(of: Result<any LibraryCore.Loan, Error>.self) { group in
            items.forEach { item in
                group.addTask {
                    try await loanService.renew(loan: item)
                }
            }

            var results = [Result<any LibraryCore.Loan, Error>]()


            for try await result in group {
                results.append(result)
            }

            try await group.waitForAll()

            return results
        }

        AppReviewService(userDefaults: .suite).increaseLatestSuccessfulRenewalCount(by: renewedItemResults.successCount)

        return .result(view: AppIntentRenewalResultView(viewModel: .init(results: renewedItemResults)))
    }

    @Parameter(title: "items to renew", description: "items to renew description")
    public var items: [ItemEntity]

    public static var openAppWhenRun: Bool = false

    // Keep it this way so that kids cannot renew item using Siri when they play with a locked device
    public static var authenticationPolicy: IntentAuthenticationPolicy = .requiresLocalDeviceAuthentication
}
