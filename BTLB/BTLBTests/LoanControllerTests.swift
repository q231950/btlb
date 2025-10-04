//
//  ManagedObjectContextStub.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 02.09.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import XCTest
import CoreData

import Mocks
import Persistence
import TestUtilities

@testable import BTLB
import LibraryCore

class LoanControllerTests: XCTestCase {

    var mocStub: NSManagedObjectContext!

    var account1: EDAccount?
    var loan1: Persistence.Loan!
    var loan2: Persistence.Loan!

    var account2: EDAccount?
    var loan3: Persistence.Loan!

    override func setUp() async throws {
        try await super.setUp()
        mocStub = await SomeHelper().managedObjectContextStub(for: self)
    }

    func setupSingleAccount() {
        account1 = Persistence.EDAccount(context: mocStub)
        account1?.activated = NSNumber(booleanLiteral: true)

        loan1 = Persistence.Loan(context: mocStub)
        loan1.loanTitle = "Loan 1"
        loan1.loanAccount = account1
        account1?.addToLoans(loan1)

        loan2 = Persistence.Loan(context: mocStub)
        loan2.loanTitle = "Loan 2"
        loan2.loanAccount = account1
        account1?.addToLoans(loan2)
    }

    func setupMultipleAccounts() {
        setupSingleAccount()

        account2 = EDAccount(context: mocStub)
        account2?.activated = NSNumber(booleanLiteral: true)

        loan3 = Persistence.Loan(context: mocStub)
        loan3.loanTitle = "Loan 3"
        loan3.loanAccount = account2
        account2?.addToLoans(loan3)
    }

}
