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
                        "Suche mit bɪtlɪb",
                        "open search shortcut phrase 1 \(.applicationName)",
                        "open search shortcut phrase 2 \(.applicationName)",
                        "open search shortcut phrase 3 \(.applicationName)",
                        "open search shortcut phrase 4 \(.applicationName)",
                        "open search shortcut phrase 5 \(.applicationName)"
                    ],
                    shortTitle: LocalizedStringResource("open search shortcut title"),
                    systemImageName: "text.magnifyingglass")

        AppShortcut(intent: RenewItemsIntent(),
                    phrases: [
                        "Verlängere mit bɪtlɪb",
                        "renew shortcut phrase 0 \(.applicationName)",
                        "renew shortcut phrase 1 \(.applicationName)",
                        "renew shortcut phrase 2 \(.applicationName)",
                        "renew shortcut phrase 3 \(.applicationName)",
                        "renew shortcut phrase 4 \(.applicationName)",
                        "renew shortcut phrase 5 \(.applicationName)",
                        "renew shortcut phrase 6 \(.applicationName)",
                        "renew shortcut phrase 7 \(.applicationName)",
                        "renew shortcut phrase 8 \(.applicationName)",
                        "renew shortcut phrase 9 \(.applicationName)",
                        "renew shortcut phrase 11 \(.applicationName)",
                        "renew shortcut phrase 12 \(.applicationName)",
                        "renew shortcut phrase 13 \(.applicationName)",
                        "renew shortcut phrase 14 \(.applicationName)",
                        "renew shortcut phrase 15 \(.applicationName)",
                        "renew shortcut phrase 16 \(.applicationName)",
                        "renew shortcut phrase 17 \(.applicationName)",
                        "renew shortcut phrase 18 \(.applicationName)",
                        "renew shortcut phrase 19 \(.applicationName)",
                        "renew shortcut phrase 21 \(.applicationName)",
                        "renew shortcut phrase 22 \(.applicationName)",
                        "renew shortcut phrase 23 \(.applicationName)",
                        "renew shortcut phrase 24 \(.applicationName)",
                        "renew shortcut phrase 25 \(.applicationName)",
                        "renew shortcut phrase 26 \(.applicationName)",
                        "renew shortcut phrase 27 \(.applicationName)",
                        "renew shortcut phrase 28 \(.applicationName)",
                        "renew shortcut phrase 29 \(.applicationName)"
                    ],
                    shortTitle: LocalizedStringResource("renew shortcut title"),
                    systemImageName: "clock.arrow.2.circlepath")
    }
}

