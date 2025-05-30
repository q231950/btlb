//
//  BTLBUITests.swift
//  BTLBUITests
//
//  Created by Martin Kim Dung-Pham on 04.10.17.
//  Copyright © 2017 neoneon. All rights reserved.
//

import os
import XCTest
import Rorschach

/// https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/
enum ScreenshotSize: String {

    case `iPhone67` = "iPhone-6.7" /// iPhone 15 Pro Max
    case `iPhone65` = "iPhone-6.5" /// iPhone 14 Plus (required)
    case `iPhone55` = "iPhone-5.5" /// iPhone 8 Plus (required)
    case `iPad129` = "iPad-12.9"
    case invalid

    init(width: Int, height: Int) {
        switch (width, height) {
        case (1290, 2796), (2796, 1290):
            self = .iPhone67
        case (1242, 2688), (2688, 1242), (1284, 2778), (2778, 1284):
            self = .iPhone65
        case (1242, 2208), (2208, 1242):
            self = .iPhone55
        case (2048, 2732), (2732, 2048):
            self = .iPad129
        case(let x, let y):
            Logger.tests.error("Invalid device for a snapshot. (\(x), \(y)) is not a valid AppStoreConnect Screenshot device.")
            self = .invalid
        }
    }
}

final class ScreenshotStorage: NSObject {

    private enum EnvironmentVariableKeys: String {
        case screenshotDirectoryPath = "SCREENSHOT_DIR"
    }

    let app: XCUIApplication
    let path: String

    var name: String

    init?(app: XCUIApplication, name: String) {
        self.app = app
        self.name = name

        guard let path = app.launchEnvironment[EnvironmentVariableKeys.screenshotDirectoryPath.rawValue] else { return nil }
        self.path = path
    }

    func snapshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()

        let heightInPoints = screenshot.image.size.height
        let heightInPixels = heightInPoints * screenshot.image.scale

        let widthInPoints = screenshot.image.size.width
        let widthInPixels = widthInPoints * screenshot.image.scale

        let size = ScreenshotSize(width: Int(widthInPixels), height: Int(heightInPixels))

        let fileManager = FileManager.default
        let directoryPath = path + "/\(size.rawValue)"
        if !fileManager.fileExists(atPath: directoryPath) {
            try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
        }
        let path = directoryPath + "/" + name + ".png"
        print("📸 Taking snapshot at path: \(path)")
        fileManager.createFile(atPath: path,
                               contents: screenshot.pngRepresentation,
                               attributes: [FileAttributeKey.type: "json"])

    }
}

class BTLBUITests: XCTestCase {

    var app: XCUIApplication!
    var screenshotRecorder: ScreenshotStorage?

    override func setUp() {
        super.setUp()

        if UIDevice.current.userInterfaceIdiom == .phone {
            XCUIDevice.shared.orientation = .portrait
        } else {
            XCUIDevice.shared.orientation = .landscapeRight
        }

        continueAfterFailure = false

        app = XCUIApplication()

        let processInfo = ProcessInfo()
        app.launchEnvironment["STUB_PATH"] = "\(processInfo.environment["PROJECT_DIR"] ?? "")/BTLBUITests/Stubs"
        app.launchEnvironment["THE_STUBBORN_NETWORK_UI_TESTING"] = "YES"
        app.launchEnvironment["STUB_NAME"] = self.name
        app.launchEnvironment["SCREENSHOT_DIR"] = "\(processInfo.environment["PROJECT_DIR"] ?? "")/Screenshots"
        screenshotRecorder = ScreenshotStorage(app: app, name: "ScreenshotStorage")

        app.launch()

        if UIDevice.current.userInterfaceIdiom == .phone {
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        } else {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        }
    }

//    func testAccountsSnapshot() {
//        expect {
//            Given("I create 2 accounts") {
//                self.login(name: "Laserman", login: "123456789", password: "***", library: "Bücherhallen Hamburg")
//                self.login(name: "Laserman", login: "123456789", password: "***", library: "Bücherhallen Hamburg")
//            }
//
//            When("I rename both accounts") {
//                let accounts = self.app.buttons.matching(identifier: "account item")
//                for index in 0..<accounts.count {
//                    let account = accounts.element(boundBy: index)
//                    account.tap()
//                    if index == 0 {
//
//                    }
//                }
//            }
//
//            Then("I take a snapshot and log out") {
//                self.screenshotRecorder?.snapshot(name: "accounts")
//
//                self.logout()
//            }
//        }
//    }

    func testChargesSnapshot() {
        expect {
            When("I login and navigate to the 'Charges' section") {
                self.login(name: "Laserman", login: "123456789", password: "***", library: "Bücherhallen Hamburg")

                self.app.tabBars.buttons["Gebühren"].tap()
            }

            Then("I take a snapshot and log out") {
                self.screenshotRecorder?.snapshot(name: "charges")

                self.logout()
            }
        }
    }

    func testSearchSnapshot() {
        app.tabBars.buttons["Suche"].tap()

        screenshotRecorder?.snapshot(name: "SearchHistoryPortrait")

        app.navigationBars["Suche"]/*@START_MENU_TOKEN@*/.buttons["Katalog für die Suche auswählen"]/*[[".buttons[\"Katalog für die Suche auswählen\"]",".buttons[\"switch library button\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()

        app.buttons["Bücherhallen Hamburg"].tap()

        let sucheImBestandHamburgSearchField = app.searchFields["Suche im Bestand Bücherhallen Hamburg"]

        sucheImBestandHamburgSearchField.doubleTap()
        sucheImBestandHamburgSearchField.typeText("Taniguchi")
        app.typeText("\r")

        app.swipeUp(velocity: XCUIGestureVelocity.fast)
        app.swipeUp(velocity: XCUIGestureVelocity.fast)
        app.swipeUp(velocity: XCUIGestureVelocity.fast)
        app.swipeUp(velocity: XCUIGestureVelocity.slow)

        if UIDevice.current.userInterfaceIdiom == .phone {
            screenshotRecorder?.snapshot(name: "SearchListPortrait")
        }

        app.staticTexts["Ihr Name war Tomoji"].tap()

        app.navigationBars.buttons["bookmark/unbookmark"].tap()

        app.navigationBars/*@START_MENU_TOKEN@*/.buttons["bookmark/unbookmark"]/*[[".buttons[\"not bookmarked\"]",".buttons[\"bookmark\/unbookmark\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }

    func testSearchDetailSnapshot() {
        app.tabBars.buttons["Suche"].tap()

        app.navigationBars["Suche"]/*@START_MENU_TOKEN@*/.buttons["Katalog für die Suche auswählen"]/*[[".buttons[\"Katalog für die Suche auswählen\"]",".buttons[\"switch library button\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()

        app.buttons["Bücherhallen Hamburg"].tap()

        let sucheImBestandHamburgSearchField = app.searchFields["Suche im Bestand Bücherhallen Hamburg"]

        sucheImBestandHamburgSearchField.doubleTap()
        sucheImBestandHamburgSearchField.typeText("gestatten Magritte")
        app.typeText("\r")

        app.staticTexts["Gestatten Magritte"].tap()

        screenshotRecorder?.snapshot(name: "search-result-detail")
    }

    func testLoans() {
        var context = Context(app: app, test: self)

        expect {
            Given("I login with an account with loans") {
                self.login(name: "Irma Vep", login: "123456789", password: "***", library: "Bücherhallen Hamburg")
            }

            When("I navigate to the loans section") {
                context.loansSection = context.app?.navigateToLoansSection()
                self.screenshotRecorder?.snapshot(name: "loans")
            }

            Then("I can select a loan and bookmark it") {
                context.loanPage = context.loansSection.selectLoan(title: "Dinosaurier und andere Wesen der Urzeit")

                context.loanPage.bookmark()

                self.screenshotRecorder?.snapshot(name: "loan detail")

                context.loanPage.removeBookmark()

                context.loanPage.tapDone()

                self.logout()
            }
        }
    }

    func test_renewal() {
        var context = Context(app: app, test: self)

        expect {
            Given("I select a loan") {
                self.login(name: "John Doe", login: "123456789", password: "***", library: "Bücherhallen Hamburg")

                let loansSection = context.app?.navigateToLoansSection()
                context.loanPage = loansSection?.selectLoan(title: "Dinosaurier")
            }

            When("I renew") {
                context.loanPage.renew()
            }

            Then("I can see a success message") {
                self.screenshotRecorder?.snapshot(name: "renewal")
                let renewedSuccessLabel = context.app?.navigationBars.buttons["verlängert"]
                let exists = NSPredicate(format: "exists == true")
                let exp = context.test.expectation(for: exists, evaluatedWith: renewedSuccessLabel)
                context.test.wait(for: [exp], timeout: 2)

                context.loanPage.tapDone()
                self.logout()
            }
        }
    }

    func login(name: String, login: String, password: String, library: String) {
        app.tabBars.buttons["Mehr"].tap()
        app.staticTexts["Konten"].tap()

        app.buttons["Konto hinzufügen"].tap()

        app.buttons["Bibliothek Auswählen"].tap()
        let libraryItem = app.buttons[library]
        if libraryItem.waitForExistence(timeout: 2) {
            libraryItem.tap()
        } else {
            app.swipeUp()
            libraryItem.tap()
        }
        app.textFields["Bücherhallen-Karten Nummer"].tap()
        app.typeText(login)
        app.secureTextFields["Passwort"].tap()
        app.typeText(password)
        app.typeText(XCUIKeyboardKey.return.rawValue)
        app.buttons["Anmelden"].tap()

        let continueButton = app.buttons["Loslesen"]
        _ = continueButton.waitForExistence(timeout: 10)
        continueButton.tap()
    }

    func logout(file: StaticString = #file, line: Int = #line) {
        app.tabBars.buttons["Mehr"].tap()
        app.staticTexts["Konten"].tap()

        let accounts = app.buttons.matching(identifier: "account item")
        var count = accounts.count
        while count > 0 {
            let account = accounts.element(boundBy: 0)
            account.tap()
            app.buttons["Konto Löschen"].tap()
            app.buttons["Löschen"].tap()

            count -= 1
        }
    }
}
