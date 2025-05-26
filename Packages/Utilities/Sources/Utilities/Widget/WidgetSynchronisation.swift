//
//  WidgetSynchronisation.swift
//  
//
//  Created by Martin Kim Dung-Pham on 01.12.22.
//

import Foundation
import WidgetKit
import LibraryCore
import Persistence
import Combine
import CoreData

public final class WidgetSynchronisation: AppEventObserver {

    public static private(set) var shared: WidgetSynchronisation = WidgetSynchronisation()

    public var widgetState: WidgetState {
        get throws {
            let storage = AppGroupStorage()
            return try storage.read(named: "BTLBWidgetInfo")
        }
    }

    private let storage = AppGroupStorage()

    public var id = UUID()
    public func handle(_ change: AppEventPublisher.AppEvent) async throws {
        switch change {
        case .accountActivation(count: let count, activated: 0, _):
            try updateWidgetActivatedAccount(count: count, activated: 0)
        case .accountActivation(_, _, let context):
            try await updateWidgetContent(didRefresh: true, in: context)
        case .accountsRefreshed(.finished , let context):
            try await updateWidgetContent(didRefresh: true, in: context)
        case .accountsRefreshed(.error , let context):
            // error could be more specific, identifying the exact number of accounts which failed to update
            try await updateWidgetContent(didRefresh: false, in: context)
        case .settingChange: break
        case .renewalSuccess(_, let context):
            try await updateWidgetContent(didRefresh: true, in: context)
        case .renewalFailure:
            break
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateWidgetActivatedAccount(count: Int, activated: Int) throws {

        let viewModel = WidgetState.AccountInfoViewModel(accountsCount: count,
                                                         activatedAccountsCount: activated)
        let state: WidgetState = .accountInfo(viewModel: viewModel)

        try store(state)
    }

    private func updateWidgetContent(didRefresh: Bool, in context: NSManagedObjectContext) async throws {
        let nextReturnDate = await DataStackProvider.shared.nextReturnDate(in: context)
        let lastUpdateDate: Date = didRefresh ? .now : UserDefaults.suite.latestSuccessfulAccountUpdateDate ?? .now
        let overallNumberOfLoans = await DataStackProvider.shared.overallNumberOfLoans(in: context)
        let numberOfAccounts = try await DataStackProvider.shared.activeAccounts(in: context).count
        // Limit elements displayed in a widget so that they all fit into the available vertical space
        // Limiting should probably happen within the view/view model of the widget since it knows better how much space is available
        let items = await DataStackProvider.shared.items(in: context, renewableOnly: false, fetchLimit: 8)
        let viewModel = WidgetState.ContentViewModel(lastUpdate: lastUpdateDate,
                                                     nextReturnDate: nextReturnDate,
                                                     overallNumberOfLoans: overallNumberOfLoans,
                                                     numberOfAccounts: numberOfAccounts,
                                                     items: items)
        let state: WidgetState = .content(viewModel: viewModel)

        try store(state)
    }

    private func store(_ widgetState: WidgetState) throws {
        try storage.store(widgetState, name: "BTLBWidgetInfo")
    }
}
