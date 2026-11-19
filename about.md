# About BTLB

BTLB keeps track of your library accounts: loans, renewals, charges and bookmarks. It has been on the
App Store since 2010, first as EDSync and later as BTLB, and has been developed by Martin Kim Dung-Pham
throughout. About 1,300 commits over 14 years of git history across two repositories, and 16 years
since the App Store launch.

## History

### 2010: EDSync

- **30 July 2010**: first released on the App Store as **EDSync** (App Store id 383008918). The bundle
  id is still `com.elbedev.sync`, and older classes still use the `ED` prefix.
- The earliest code lived in Subversion, so the git history doesn't reach back this far.

### 2012–2014

- **11 November 2012**: the code moves from Subversion to git; the archived repository's history
  starts here.
- **2014**: EDSync is updated for iOS 8, Google Analytics is removed, and the first Swift code arrives.

### 2015: bitlib, then BTLB

- The busiest early year, with 209 commits: a new library selection and the migration to Swift.
- **13 October 2015**: the app is renamed, first to "bitlib", then to **BTLB**. Version 1.5.1 follows
  that month. The code is hosted on Bitbucket.

### 2016–2017

- Public library support: loans, charges, bookmarks and search.
- Dark mode, plus updates for Swift 4 and iOS 11.
- **December 2017**: the remaining "bitlib" text is changed to BTLB.

### 2018

- **January**: version 2.0.0, with the library list revised to "add glory to the institutions".
- 2.3 fixes syncing and renewals for Bücherhallen Hamburg.
- **December**: iPad layout.

### 2020

- The code moves to GitHub.
- 2.7.0 brings UI tests with stubbed networking.

### 2022

- The SwiftUI migration begins.
- 2.8–2.12 bring Home Screen and Lock Screen widgets, account update notifications and a
  notification service extension.

### 2023

- 2.13: renew loans right from a notification.
- 2.14 and 2.15: bookmarks and charges move to SwiftUI.
- **November 2023**: the whole app becomes a SwiftUI app.

### 2024

- 2.17 and 2.18: widget improvements.
- 2.19: a Renew Shortcut and App Intents.
- 2.20–2.22 follow.

### 2025

- **May**: the current repository starts fresh, and the app gets an Open Source section.
- 2.26–2.29 are released.

### 2026

- **11 November 2026**: 2.30.0, with AI book recommendations through the neoneon server and a demo
  account.
- The App Store lists BTLB for iOS, iPadOS, macOS and visionOS 26, in 6 languages, with a rating
  of 4.6.

## Sources

- [BTLB on the App Store](https://apps.apple.com/de/app/btlb/id383008918)
- [iTunes lookup API for id 383008918](https://itunes.apple.com/lookup?id=383008918&country=de)
- The git history of the archived repository and of this one.

App Store version notes only go back to 2.9.0 (November 2022); earlier history comes from the
commit log.
