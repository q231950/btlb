//
//  BTLBAppDelegate.h
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 10/04/2009.
//  Copyright © 2009 neoneon. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import OSLog
import BackgroundTasks

import LibraryCore
import Persistence
import Utilities
import UserNotifications
import Libraries
import Localization
import Bookmarks

class EDSyncAppDelegate: NSObject, UIApplicationDelegate {

    private let appViewModel = AppViewModel.shared

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        UNUserNotificationCenter.current().delegate = self

        registerDependencies()
        registerForBackgroundTasks()
        registerForPushNotifications()
        configureEventObservers()
        requestNotificationAuthorization()

        appViewModel.dataStackProvider.load { [weak self] in
            if let container = self?.appViewModel.dataStackProvider.persistentContainer {
                let librariesController = LibraryManager(persistentContainer: container)

                librariesController.loadOrUpdateLibraries(in: container.viewContext)
            }
        }

        return true

    }

    func applicationWillTerminate(_ application: UIApplication) {
        scheduleAppRefresh()
    }
}

extension EDSyncAppDelegate {

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        guard let info = userInfo as? [String: Any] else { return .failed }

        return await didReceive(info: info)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        didRegister(deviceToken: deviceToken)
    }

}

extension EDSyncAppDelegate: UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        switch response.actionIdentifier {
        case "TRY_RENEW":
            await renew(response: response)
        case "RENEW":
            await renew(response: response)
        case "REFRESH_ACCOUNTS":
            await refresh(response: response)
        default: break
        }
    }

    private func refresh(response: UNNotificationResponse) async {
        do {
            try await AccountUpdater(dataStackProvider: appViewModel.dataStackProvider).update(in: appViewModel.dataStackProvider.backgroundManagedObjectContext)
        } catch {

        }
    }

    private func renew(response: UNNotificationResponse) async {
        if let barcode = response.notification.request.content.userInfo["barcode"] as? String {
            let context = appViewModel.dataStackProvider.foregroundManagedObjectContext

            let backendService = DatabaseConnectionFactory().databaseConnection(
                for: context,
                accountService: AccountScraper(),
                dataStackProvider: appViewModel.dataStackProvider
            )
            let bookmarkService = BookmarkService(managedObjectContext: context)
            let loanService = BTLBLoanService(backendService: backendService,
                                              bookmarkService: bookmarkService)

            do {
                let activeAccounts = try await appViewModel.dataStackProvider.activeAccounts(in: context)

                if let loanManagedObjectId = await loan(for: barcode, in: context, accounts: activeAccounts),
                   let loanManagedObject = context.object(with: loanManagedObjectId) as? Persistence.Loan {

                    let result = try await loanService.renew(loan: loanManagedObject)
                    switch result {
                    case .success(let loan):
                        print("Renewed loan (\(loan.title)): \(loan.dueDate)")
                        loanManagedObject.loanNotificationScheduledDate = nil
                        let renewableItem = RenewableItem(now: .now,
                                                          title: loan.title,
                                                          barcode: loan.barcode,
                                                          canRenew: loan.canRenew,
                                                          expirationDate: loan.dueDate,
                                                          expirationNotificationDate: loan.notificationScheduledDate) { notificationTriggerDate in
                            await loanManagedObject.managedObjectContext?.perform {
                                loanManagedObject.notificationScheduledDate = notificationTriggerDate
                                do {
                                    try loanManagedObject.managedObjectContext?.save()
                                } catch {

                                }
                            }
                        }
                        try await AppEventPublisher.shared.sendUpdate(.renewalSuccess(renewableItem, context: context))

                    case .failure(let error):
                        print("Failed to renew loan with barcode (\(barcode)): \(error)")
                        try await AppEventPublisher.shared.sendUpdate(.renewalFailure(title: loanManagedObject.title, barcode: loanManagedObject.barcode))
                    }
                }
            } catch {

            }
        }
    }


    @nonobjc private func loan(for barcode: String, in context: NSManagedObjectContext, accounts: [NSManagedObjectID]) async -> NSManagedObjectID? {
        await context.perform {
            let managedAccountObjects = accounts.compactMap { accountObjectID in
                return context.object(with: accountObjectID) as? Account
            }
            let loan = managedAccountObjects.reduce([any LibraryCore.Loan](), { partialResult, updateResult in
                partialResult + updateResult.allLoans.filter { $0.barcode == barcode }
            }).first as? Persistence.Loan

            return loan?.objectID
        }
    }
}


@objc extension EDSyncAppDelegate {

    @objc func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .provisional]) { granted, error in

            // Provisional authorization granted.
        }
    }

    @objc
    func registerForPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()

        let renewAction = UNNotificationAction(identifier: "RENEW",
                                               title: "notification action renew".localized,
                                               options: [])

        let itemRenewableCategory =
        UNNotificationCategory(identifier: "ITEM_EXPIRATION_RENEWABLE",
                               actions: [renewAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)

        let refreshAccountsAction = UNNotificationAction(identifier: "REFRESH_ACCOUNTS",
                                                         title: "notification action refresh accounts".localized,
                                                         options: [])

        let tryRenewAction = UNNotificationAction(identifier: "TRY_RENEW",
                                                  title: "notification action try to renew".localized,
                                                  options: [])

        let itemExpiresTodayCategory = UNNotificationCategory(identifier: "ITEM_EXPIRES_TODAY",
                                                              actions: [refreshAccountsAction, tryRenewAction],
                                                              intentIdentifiers: [],
                                                              hiddenPreviewsBodyPlaceholder: "",
                                                              options: .customDismissAction)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([itemRenewableCategory, itemExpiresTodayCategory])
    }

    func didRegister(deviceToken: Data) {
        Task {
            let pushManager = PushNotificationManager()
            try await pushManager.register(token: deviceToken)
        }
    }

    func didReceive(info: Dictionary<String, Any>) async -> UIBackgroundFetchResult {
        guard let aps = info["aps"] as? Dictionary<String, Any>,
              let category = aps["category"] as? String,
              category == "refresh" else {

            return .failed
        }

        let currentValue = UserDefaults.suite.backgroundNotificationRefreshCount
        UserDefaults.suite.backgroundNotificationRefreshCount = currentValue + 1

        AppEventPublisher.shared.addObserver(appViewModel.widgetSynchronisation)
        AppEventPublisher.shared.addObserver(appViewModel.notificationSynchronisation)

        let context = appViewModel.dataStackProvider.foregroundManagedObjectContext

        return await withCheckedContinuation { continuation in
            let operation = RefreshAppContentsOperation(updater: AccountUpdater(dataStackProvider: appViewModel.dataStackProvider),
                                                        context: context) { updateResult in
                let currentValue = UserDefaults.suite.successfulBackgroundNotificationRefreshCount
                UserDefaults.suite.successfulBackgroundNotificationRefreshCount = currentValue + 1

                UserDefaults.suite.latestSuccessfulBackgroundNotificationRefreshDate = .now

                continuation.resume(returning: .newData)
            }

            BackgroundOperationProvider.shared.operationQueue.addOperation(operation)
        }
    }

    func configureEventObservers() {
        AppEventPublisher.shared.addObserver(appViewModel.widgetSynchronisation)
        AppEventPublisher.shared.addObserver(appViewModel.notificationSynchronisation)
        AppEventPublisher.shared.addObserver(appViewModel.coreSpotlightSynchronisation)
    }

    // MARK: - Background Tasks

    // https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        true
    }

    @objc
    func registerForBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "dev.neoneon.btlb.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func registerDependencies() {
        UtilitiesDependencies.renewingUseCase = { (dependency: (RenewingUseCase) async throws -> Void) in
            try await dependency(RenewUseCase())
        }

        UtilitiesDependencies.accountValidatingUseCase = { (depenency: (AccountValidatingUseCase) async throws -> ValidationStatus) in
            try await depenency(ValidateAccountUseCase())
        }
    }

    @objc
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "dev.neoneon.btlb.refresh")
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        incrementBackgroundfetchCount()

        scheduleAppRefresh()

        let context = appViewModel.dataStackProvider.backgroundManagedObjectContext
        let operation = RefreshAppContentsOperation(updater: AccountUpdater(dataStackProvider: appViewModel.dataStackProvider),
                                                    context: context) { updateResult in
            switch updateResult {
            case .finished:
                self.incrementSuccessfulBackgroundfetchCount()
                self.updateLastSuccessfulAccountUpdateDate()
                try? context.save()
            case .error: break
            }

        }

        task.expirationHandler = {
            operation.cancel()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        BackgroundOperationProvider.shared.operationQueue.addOperation(operation)
    }

    private func updateLastSuccessfulAccountUpdateDate() {
        UserDefaults.suite.latestSuccessfulAccountBackgroundUpdateDate = .now
    }

    private func incrementBackgroundfetchCount() {
        let currentValue = UserDefaults.suite.backgroundFetchCount
        UserDefaults.suite.backgroundFetchCount = currentValue + 1
    }

    private func incrementSuccessfulBackgroundfetchCount() {
        let currentValue = UserDefaults.suite.successfulBackgroundFetchCount
        UserDefaults.suite.successfulBackgroundFetchCount = currentValue + 1
    }

    // MARK: - Universal Links

    @objc func scene(_ scene: UIScene, willConnectTo
                     session: UISceneSession,
                     options connectionOptions: UIScene.ConnectionOptions) {
    }

    @objc func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    }

    @objc func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let urlToOpen = userActivity.webpageURL else {
            return
        }

        print(urlToOpen)
    }

    @objc public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Logger.app.info("\(#function)")
        Logger.app.debug("[Application Delegate] \(#function)\nurl: \(url.absoluteString)")
        Logger.app.debug("[Application Delegate] \(#function)\n options: \(options)")

        return true
    }
}
