//
//  AppPageModel.swift
//  BTLBUITests
//
//  Created by Martin Kim Dung-Pham on 20.03.20.
//  Copyright © 2020 neoneon. All rights reserved.
//

import XCTest

protocol PageModel {
    init(app: XCUIApplication)

    var app: XCUIApplication { get }
}

struct LoansPage: PageModel {
    var app: XCUIApplication


    init(app: XCUIApplication) {
        self.app = app
    }

    /// Shows the a loan's actions, performs a handler while the actions are on display and dismisses them again.
    ///
    /// - Parameters:
    ///   - loanTitle: The title of the loan to show the actions for
    ///   - actionsOnDisplayHandler: An optional handler to be executed while the actions are shown
    func showAndHideCellActions(loanTitle: String, actionsOnDisplayHandler: (() -> Void)?) {
        showCellActions(loanTitle: loanTitle)

        actionsOnDisplayHandler?()

        hideCellActions(loanTitle: loanTitle)
    }

    func showCellActions(loanTitle: String) {
        app.tables.staticTexts[loanTitle].swipeLeft()
    }

    private func hideCellActions(loanTitle: String) {
        app.tables.staticTexts[loanTitle].tap()

        let exp = XCTestExpectation(description: "wait for 1 seconds")
        XCTWaiter().wait(for: [exp], timeout: 1)
    }

    /// Selects a loan and navigates to the Loan Detail View
    /// - Parameter title: The title of the loan to select
    func selectLoan(title: String) -> LoanPage {
        app.staticTexts[title].tap()

        return LoanPage(app: app)
    }
}

struct LoanAction {
    static func bookmark(action: (LoanAction) -> Void) {
        action(LoanAction("Lesezeichen setzen"))
    }

    static func renew(action: (LoanAction) -> Void) {
        action(LoanAction("Entleihung verlängern"))
    }

    static func cancel(action: (LoanAction) -> Void) {
        action(LoanAction("Abbrechen"))
    }

    func perform(on sheet: XCUIElement) {
        sheet.buttons[buttonTitle].tap()
    }

    private let buttonTitle: String

    private init(_ buttonTitle: String) {
        self.buttonTitle = buttonTitle
    }
}

struct LoanActions {
    let sheet: XCUIElement

    var bookmark: () -> Void
    {
        {
            LoanAction.bookmark() { (action) in
                action.perform(on: self.sheet)
            }
        }
    }

    var renew: () -> Void
    {
        {
            LoanAction.renew() { (action) in
                action.perform(on: self.sheet)
            }
        }
    }

}

struct LoanPage: PageModel {
    var app: XCUIApplication
    init(app: XCUIApplication) {
        self.app = app
    }

    func renew() {
        app.navigationBars.buttons["verlängern"].tap()
    }

    func bookmark() {
        app.navigationBars.buttons["Lesezeichen hinzufügen"].tap()
    }

    func removeBookmark() {
        app.navigationBars.buttons["Lesezeichen entfernen"].tap()
    }

    func tapDone() {
        app.navigationBars.buttons["Fertig"].tap()
    }

    func editLoan(editSheetActions: (LoanActions) -> Void) {
        let sheet = openEditSheet()

        editSheetActions(LoanActions(sheet: sheet))
    }

    private func openEditSheet() -> XCUIElement {
        app.navigationBars["Entleihung"].buttons["Bearbeiten"].tap()

        return app.sheets["Aktionen"]
    }
}

enum Section: String {
    case loans = "Entleihungen"
}

extension XCUIApplication {

    func navigateToLoansSection() -> LoansPage {
        tapTabBarItem(section: .loans)

        return LoansPage(app: self)
    }

    private func tapTabBarItem(section: Section) {
        tabBars.buttons[section.rawValue].tap()
    }

}
