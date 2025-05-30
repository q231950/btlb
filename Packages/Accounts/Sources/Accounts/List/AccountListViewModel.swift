//
//  AccountListViewModel.swift
//
//
//  Created by Martin Kim Dung-Pham on 01.08.23.
//

import CoreData
import Foundation
import SwiftUI

import LibraryCore
import Localization
import Persistence

public class AccountListViewModel: ObservableObject {

    let title = "ACCOUNTS".localizedKey(bundle: .module)
    @Published var showsAccountCreation = false
    var onDelete: () -> Void

    private let dataStackProvider: DataStackProviding

    public init(dataStackProvider: DataStackProviding, onDelete: @escaping () -> Void) {
        self.dataStackProvider = dataStackProvider
        self.onDelete = onDelete
    }

    func addAccount() {
        showsAccountCreation = true
    }

    func accountDetailViewModel(for identifier: NSManagedObjectID,
                                accountService: LocalAccountService,
                                accountCredentialStore: AccountCredentialStoring,
                                accountActivating: AccountActivating) -> AccountEditViewModel {
        AccountEditViewModel(accountService: accountService,
                             accountCredentialStore: accountCredentialStore,
                             accountActivating: accountActivating,
                             managedObjectContext: dataStackProvider.foregroundManagedObjectContext,
                             managedObjectId: identifier,
                             onDelete: onDelete)
    }
}
