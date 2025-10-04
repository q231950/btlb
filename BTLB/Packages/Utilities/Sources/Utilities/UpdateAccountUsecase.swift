//
//  UpdateAccountUsecase.swift
//
//
//  Created by Martin Kim Dung-Pham on 09.07.24.
//

import Foundation

import LibraryCore
import Persistence

public class UpdateAccountDependencies {

    let accountCredentialStore: AccountCredentialStoring
    let accountService: AccountServiceProviding

    public init(accountCredentialStore: AccountCredentialStoring, accountService: AccountServiceProviding) {
        self.accountCredentialStore = accountCredentialStore
        self.accountService = accountService
    }
}

public class UpdateAccountUsecase {

    private let dependencies: UpdateAccountDependencies

    private lazy var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        return dateFormatter
    }()

    public init(dependencies: UpdateAccountDependencies) {
        self.dependencies = dependencies
    }

    public func execute(on account: EDAccount) async throws {

        guard let context = account.managedObjectContext else { return }

        var currentNotificationDates = [String : Date]()
        var username: String?
        var library: LibraryModel?

        await context.perform {
            username = account.username
            let l = account.accountLibrary
            library = LibraryModel(wrapping: l)
        }

        guard let library = library else {
            throw PaperErrorInternal.LibraryNotSupportedError
        }

        guard let password = self.dependencies.accountCredentialStore.password(for: username) else { return }

        do {
            let paperAccount = try await self.dependencies.accountService.account(username: username, password: password, library: library)

           try await context.perform {
               // MARK: delete existing loans and charges
               if let currentLoans = account.loans {
                   for loan in currentLoans {
                       if let loan = loan as? Persistence.Loan {
                           if let barcode = loan.loanBarcode, let date = loan.notificationScheduledDate {
                               currentNotificationDates[barcode] = date
                           }
                           loan.isLoaned = NSNumber(value: false as Bool)
                           account.removeFromLoans(loan)
                       }
                   }
               }

               if let charges = account.charges {
                   for charge in charges {
                       if let charge = charge as? Persistence.Charge {
                           account.removeFromCharges(charge)
                       }
                   }
               }

               // MARK: add the new ones
                account.accountLastUpdate = Date()

                paperAccount?.balance?.charges.forEach({ paperCharge in
                    let coreDataCharge = Persistence.Charge(context: context)
                    coreDataCharge.chargeDescription = paperCharge.reason
                    coreDataCharge.date = Date(timeIntervalSince1970: Double(paperCharge.timestamp))
                    coreDataCharge.amount = NSNumber(value: paperCharge.amountOwed)
                    
                    account.addToCharges(coreDataCharge)
                })

                for loan in paperAccount?.loans.loans ?? [] {
                    let coreDataLoan = Persistence.Loan(context: context)
                    coreDataLoan.loanBarcode = loan.itemNumber
                    coreDataLoan.loanTimesProlonged = NSNumber(value: loan.renewalsCount)
                    coreDataLoan.loanTitle = loan.title
                    coreDataLoan.loanSignature = loan.details.signature
                    coreDataLoan.loanIconUrl = loan.details.smallImageUrl
                    coreDataLoan.loanExpiryDate = self.dateFormatter.date(from: loan.dateDue)
                    coreDataLoan.loanCanRenew = loan.canRenew
                    coreDataLoan.loanRenewalToken = loan.renewalToken
                    coreDataLoan.loanLockedByPreorder = loan.lockedByPreorder
                    coreDataLoan.isLoaned = NSNumber(value: true as Bool)
                    loan.details.dataEntries.forEach {
                        coreDataLoan.createOrUpdateInfoPair(title: $0.label, value: $0.value)
                    }
                    coreDataLoan.loanLibrary = account.accountLibrary
                    account.accountLibrary?.addToLibraryLoans(coreDataLoan)
                    account.addToLoans(coreDataLoan)
                    coreDataLoan.loanAccount = account

                    account.addToLoans(coreDataLoan)
                }

                let bookmarkService = BookmarkService(managedObjectContext: context)
                do {
                    let bookmarks = try bookmarkService.bookmarks()
                    if let currentLoans = account.loans {
                        for loan in currentLoans {
                            if let loan = loan as? Persistence.Loan {

                                if let date = currentNotificationDates[loan.barcode] {
                                    loan.notificationScheduledDate = date
                                }

                                for item: EDItem in bookmarks {
                                    if loan.loanBarcode == item.barcode {
                                        loan.favourite = item
                                        item.loan = loan
                                        loan.loanIsFavourite = NSNumber(value: true as Bool)
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    throw PaperErrorInternal.unhandledError(error.localizedDescription)
                }
            }

            do {
                try await context.perform {
                    try context.save()
                }
            } catch {
                throw PaperErrorInternal.updateAccountUsecaseError(.unableToSaveAfterAccountUpdate)
            }
        } catch(let error as PaperErrorInternal) {
            throw error
        } catch {
            throw PaperErrorInternal.unhandledError(error.localizedDescription)
        }
    }
}
