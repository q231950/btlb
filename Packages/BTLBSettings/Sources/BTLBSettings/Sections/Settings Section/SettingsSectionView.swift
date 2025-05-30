//
//  SettingsSectionView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.05.23.
//

import Foundation
import SwiftUI

import LibraryCore
import LibraryUI
import Localization

struct SettingsSectionView: View {

    @ObservedObject private var viewModel: SettingsViewModel
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel

        defer {
            viewModel.updateAsyncProperties()
        }
    }

    var body: some View {

        List {
            Section {
                appIconToggle


                notificationSection

                debugToggle
            }
            .listSectionSeparator(.hidden)

            Section {
                versionSection
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
            viewModel.updateAsyncProperties()
        }
        .navigationTitle(Localization.Titles.settings)
        .navigationBarTitleDisplayMode(.large)

    }

    // MARK: App Icon Toggle

    @ViewBuilder private var appIconToggle: some View {
        DescriptiveToggle(
            title: "APPICON_TITLE",
            description: "APPICON_TEXT",
            bundle: .module,
            isOn: $viewModel.alternetAppIconEnabled
        )
    }

    // MARK: Notification Section

    @ViewBuilder private var notificationSection: some View {
        Group {
            DescriptiveToggle(
                title: "NOTIFICATIONS_TITLE",
                description: "NOTIFICATIONS_TEXT",
                bundle: .module,
                isOn: $viewModel.notificationsEnabled
            )
            .disabled(!viewModel.notificationsAuthorized)
            .tint(if: !viewModel.notificationsAuthorized) { v in
                v.tint(.primary.opacity(0.3))
            }
            .disabled(!viewModel.notificationsAuthorized)

            if !viewModel.notificationsAuthorized {
                Group {
                    VStack {
                        Text("NOTIFICATIONS_NOT_ALLOWED")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                            .frame(height: 10)

                        Button {
                            Task {
                                await self.viewModel.openSettings()
                            }
                        } label: {
                            HStack {
                                Text("NOTIFICATIONS_NOT_ALLOWED_DESCRIPTION")

                                Spacer()

                                Image(systemName: "arrow.up.forward.square")
                                    .imageScale(.large)
                            }
                        }
                        .disabled(false)
                    }
                }
                .listRowSeparator(.hidden, edges: .top)
            }

            if viewModel.notificationsEnabled && viewModel.notificationsAuthorized {
                VStack {
                    DescriptiveSlider(viewModel: viewModel.descriptiveSliderViewModel)
                        .padding(.bottom, 10)

                    DescriptiveToggle(
                        title: "NOTIFICATION_TITLE_ACCOUNT_UPDATE",
                        description: "NOTIFICATION_DESCRIPTION_ACCOUNT_UPDATE",
                        bundle: .module,
                        isOn: $viewModel.loanExpirationNotificationsEnabled
                    )

                    lastAutomaticAccountUpdateText

                    lastManualAccountUpdateText
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    @ViewBuilder private var lastAutomaticAccountUpdateText: some View {
        let dateText: LocalizedStringKey = lastAutomaticUpdateString(date: viewModel.lastAutomaticAccountUpdateDate) ?? "LATEST_ACCOUNT_UPDATE_AUTOMATIC_NEVER"

        Group {
            Spacer()
                .frame(height: 10)


            Text(dateText, bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder private var lastManualAccountUpdateText: some View {
        let dateText: LocalizedStringKey = lastManualUpdateString(date: viewModel.lastManualAccountUpdateDate) ?? "latest account update date never"

        VStack {
            Spacer()
                .frame(height: 10)
            
            
            Text(dateText, bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func lastAutomaticUpdateString(date: Date?) -> LocalizedStringKey? {
        guard let date else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium

        return "The last successful account background update happened on \(dateFormatter.string(from: date))"
    }

    private func lastManualUpdateString(date: Date?) -> LocalizedStringKey? {
        guard let date else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium

        return "The last manual update happened on \(dateFormatter.string(from: date))"
    }

    // MARK: Debug Toggle

    private var debugToggle: some View {
        DescriptiveToggle(
            title: "DEBUG_ENABLED_TITLE",
            description: "DEBUG_ENABLED_SUBTITLE",
            bundle: .module,
            isOn: $viewModel.debugEnabled
        )
    }

    // MARK: Versions

    private var versionSection: some View {
        VStack {
            HStack {
                Spacer()
                Text(String(localized: "VERSION_TITLE", bundle: .module, locale: locale))
                    .font(.caption)
                Spacer()
            }

            HStack {
                Spacer()
                Button {
                    openURL(URL(string: "https://github.com/q231950/btlb/commit/\(VersionNumberProvider.gitCommit)")!)
                } label: {
                    Text("**\(VersionNumberProvider.versionString)**")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.bottom)
    }
}

extension View {
    @ViewBuilder func tint<Content: View>(if condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#if DEBUG
import Combine
import LibraryCore

struct SettingsSectionView_Previews: PreviewProvider {

    struct Preview: View {
        @ObservedObject private var viewModel = SettingsViewModel(service: MockSettingsService(isAlternateAppIconEnabled: true))

        var body: some View {
            NavigationView {
                SettingsSectionView(viewModel: viewModel)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

class MockSettingsService: LibraryCore.SettingsService {
    var loanExpirationNotificationsThreshold: UInt = 2

    var lastAccountUpdateDate: Date?

    var lastManualAccountUpdateDate: Date? = .now

    func openSettings() async {

    }

    var lastAutomaticAccountUpdateDate: Date? {
        Date()
    }

    public var publisher = PassthroughSubject<LibraryCore.Setting, Never>()

    var notificationsEnabledFlag = true
    var notificationsAuthorizedFlag = true
    var loanExpirationNotificationsEnabledFlag = false

    func toggleNotificationsEnabled(on isOn: Bool) {

    }

    func notificationsEnabled() -> Bool {
        notificationsEnabledFlag
    }

    var isAlternateAppIconEnabled: Bool

    func toggleAlternateAppIcon() {
        isAlternateAppIconEnabled.toggle()

        // mock implementation below ☝️↓
        notificationsAuthorizedFlag.toggle()
        publisher.send(.notificationsAuthorized(notificationsAuthorizedFlag))
    }

    func notificationsAuthorized() async -> Bool {
        notificationsAuthorizedFlag
    }

    func loanExpirationNotificationsEnabled() -> Bool {
        loanExpirationNotificationsEnabledFlag
    }

    func toggleLoanExpirationNotificationsEnabled(on isOn: Bool) {
        loanExpirationNotificationsEnabledFlag.toggle()
    }


    internal init(isAlternateAppIconEnabled: Bool) {
        self.isAlternateAppIconEnabled = isAlternateAppIconEnabled
    }

    public var debugEnabled: Bool = false

    func toggleDebugEnabled(on isOn: Bool) {
        debugEnabled = isOn
    }
}

#endif
