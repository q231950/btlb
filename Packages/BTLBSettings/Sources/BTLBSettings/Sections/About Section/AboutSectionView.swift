//
//  AboutSectionView.swift
//
//
//  Created by Martin Kim Dung-Pham on 15.04.23.
//

import AppIntents
import Foundation
import SwiftUI

import LibraryUI
import Localization

struct AboutSectionView: View {

    let libraries: AboutSectionLibraryList

    init(libraries: AboutSectionLibraryList) {
        self.libraries = libraries
    }

    var body: some View {
        List {
            aboutSection

            shortcutsSection

            contentSection

            privacySection

            librariesSection()
                .listSectionSeparator(.hidden)

            securitySection

            versionSection

            gitSection
            
            openSourceSection
        }
        .listStyle(.plain)
        .navigationTitle(Localization.Titles.about)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    AppReviewService(userDefaults: .suite).requestWrittenAppReview()
                }, label: {
                    Image(systemName: "star.bubble")
                })
            }
        }
    }

    // MARK: App Shortcuts

    private var shortcutsSection: some View = {
        Section {
            HStack {
                Spacer()
                ShortcutsLink {}
                    .shortcutsLinkStyle(.automatic)
                    .padding()
                Spacer()
            }
        }
    }()

    // MARK: About

    private var aboutSection: some View = {
        Section {
            Text("ABOUT_TITLE", bundle: .module)
                .listRowSeparator(.hidden)

            Text("ABOUT_TEXT", bundle: .module)
                .listRowSeparator(.hidden)
        }
    }()

    // MARK: Content

    private var contentSection: some View = {
        Section(content: {
            Text("INFO_VIEW_LIBRARIES_TEXT", bundle: .module)
                .listRowSeparator(.hidden)
        }, header: {
            ItemView(title: "INFO_VIEW_LIBRARIES_TITLE".localized(bundle: .module))
        })
    }()

    // MARK: Privacy

    private var privacySection: some View = {
        Section(content: {
            Text("PRIVACY_POLICY_TEXT", bundle: .module)
                .listRowSeparator(.hidden)
        }, header: {
            ItemView(title: "PRIVACY_POLICY_TITLE".localized(bundle: .module))
        })
    }()

    // MARK: Libraries

    private func librariesSection() -> some View {
        Section(content: {

            ForEach(libraries.libraries) { library in
                Text(library.name.localized(bundle: .module))
            }

            Text("LIBRARIES_TEXT", bundle: .module)
                .listRowSeparator(.hidden)
        }, header: {
            ItemView(title: "LIBRARIES_TITLE".localized(bundle: .module))
        })
    }

    // MARK: Security

    private var securitySection: some View = {
        Section(content: {
            Text("SECURITY_TEXT", bundle: .module)
                .listRowSeparator(.hidden)
        }, header: {
            ItemView(title: "SECURITY_TITLE".localized(bundle: .module))
        })
    }()

    // MARK: Versions

    private var versionSection: some View = {
        Section(content: {
            Text("**\(VersionNumberProvider.versionString)**")
                .listRowSeparator(.hidden)

        }, header: {
            ItemView(title: "VERSION_TITLE".localized(bundle: .module))
        })
    }()

    // MARK: Git Info

    private var gitSection: some View = {
        Section(content: {
            Text("**\(VersionNumberProvider.gitString)**")
                .listRowSeparator(.hidden)
        }, header: {
            ItemView(title: "GIT_INFO_TITLE".localized(bundle: .module))
        })
    }()
    
    // MARK: Open Source
    
    private var openSourceSection: some View = {
        Section {
            NavigationLink(destination: OpenSourceSectionCoordinator().contentView) {
                Text("Open Source")
            }
        }
    }()
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let libraries = AboutSectionLibraryList(libraries: [
            AboutSectionLibrary(name: "Bücherhallen Hamburg",
                                description: "Stiftung Hamburger Öffentliche Bücherhallen"),
            AboutSectionLibrary(name: "New York Public Library",
                                description: "The New York Public Library (NYPL)")
        ])

        return NavigationView {
            AboutSectionView(libraries: libraries)
        }
    }
}
