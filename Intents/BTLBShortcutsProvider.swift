//
//  BTLBShortcutsProvider.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 14.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import AppIntents
import Foundation

import Localization

public struct BTLBShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: PerformSearchIntent(),
                    phrases: [
                        "Search in \(.applicationName) |bɪtlɪb|",
                        "Find in \(.applicationName) |bɪtlɪb|",
                        "Look for something in \(.applicationName) |bɪtlɪb|"
                    ],
                    shortTitle: "Search",
                    systemImageName: "text.magnifyingglass")

        AppShortcut(intent: RenewItemsIntent(),
                    phrases: [
                        "Renew with \(.applicationName) |bɪtlɪb|",
                        "Renew using \(.applicationName)",
                        "Renew Items with \(.applicationName)",
                        "Renew Books with \(.applicationName)",
                        "Renew Media with \(.applicationName)",
                        "Prolong with \(.applicationName)",
                        "Prolong using \(.applicationName)",
                        "Extend books with \(.applicationName)",
                        "Extend items with \(.applicationName)",
                        "Renew Items with the \(.applicationName) app",
                        "Renew Books with the \(.applicationName) app",
                        "Renew Media with the \(.applicationName) app",
                        "Renew with the \(.applicationName) app",
                        "Prolong with the \(.applicationName) app",
                        "Renew using the \(.applicationName) app",
                        "Prolong using the \(.applicationName) app",
                        "Extend books with the\(.applicationName) app",
                        "Extend items with the \(.applicationName) app",
                        "Renew with the \(.applicationName) app"
                    ],
                    shortTitle: "Renew items",
                    systemImageName: "clock.arrow.2.circlepath"
        )
    }
}
