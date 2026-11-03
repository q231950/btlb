## Changelog

### Unreleased

• Loans and charges of every account in a single Accounts tab
• Add, edit and delete accounts right in the Accounts tab
• Search library selection highlights the Staatsbibliothek Berlin

### 2.30.0

• Staatsbibliothek Berlin searches its catalog via K10plus

### 2.29.0

• security enhancement

### 2.28.0

• ✨Recommender

### 2.27.0

• Open Source section

### 2.26.0

• Rust account syncronisation

### 2.25.0

• error handling
• login with OPAC accounts 🔐 (no synchronization yet)
• converts Constants.h to Swift enum LibraryConstants
• removes all remaining 🦖 Objective-C code from the project

### 2.24.0
• adds a search shortcut
• re-adds many libraries to search
• copyable content in search result details
• opens search result links in internal webview

### 2.23.0

• fixes an issue where search would continue to search when there is only a single page of results
• removed dependency to https://github.com/tadija/AEXML
• removed dependency to https://github.com/topfunky/hpple
• removed dependency to https://github.com/TouchCode/TouchXML
• cleanup linked frameworks and libraries
• reduces app size by improving internal dependency graph
• reduced Objective-C files to 2 remaining ones
• further modularization
• get rid of Ruby gems

### 2.22.0

• search in Rust 🦀🔎

### 2.21.0

• sort balance items
• improved renewal/preorder count on loaned items

### 2.20.0

• app review requests in loans section
• app review button in info section
• fixes an issue where the keyboard would go haywire in search under certain conditions
• updated voiceover pronounciation to `bit lib`

### 2.19.0

• Renew Intents
• Core Spotlight integration: it's now possible to search for loaned items
• app name synonyms
• fixes issue where one would need to tap renew button twice to show the renewal confirmation

### 2.18.0

• cleanup legacy code

### 2.17.0

• moved to SwiftUI App
• rewritten Accounts section
• Widget UI fixes for iOS 17
• Further modularisation
• deleted a lot of legacy code
• rewritten Library Selection view

### 2.16.0

• many more Swift Packages
• notifications excel (borrowed/expiring today/expired)

### 2.13.0

• show whether one can renew or not (Public Hamburg only, rest always shows the renew button)
• trigger a notification 2 days before expiration
• renew renewable loans directly from a notification without opening the app

### 2.12.0

• account updates triggered by background push notifications twice a day
• keep push notifications and background fetch enabled for BTLB to get the most out of it!

### 2.11.0

• widgets for the Always On display

### 2.10.0

• a brand new **Widget** that shows the number of days left until the next expiry date
• bug in information section where text would not be fully displayed
• setting in the information section to enable/disable the notifications for account updates
• keep background fetch enabled for BTLB to get the most out of it!

### 2.9.0

• Swift Package Manager modulization continues
• Background Tasks to update accounts

### 2.8.0

• SwiftUI rewrite of the loans section
• Swift Package Manager modulization starts

### 2.7.0

• SwiftUI rewrite of the search section

### 2.6.0

• updated support link
• updated library url for Christian-Albrechts-Universität zu Kiel
• updated darkmode colours
• new icons
• option to select an app icon
• fixed potential crashes
• improved layouts


### 2.5.0

Improvements:
• Proper storage of account passwords
• Modernised the data layer
• Update Project Layout
• Removed Cocoapods
• Haptic feedback for certain interactions

Squashed bugs:
• the last selected tab will be remembered
• duplicate loan entries when the app updates in background
• account activation does not fail any more when there are no loans
• a crash on iPad
• allows placing bookmarks in all available libraries
• cover images will not show up under the status bar any more

### 2.4.0

• Proper support for iPad. Finally!
• Many lines of code in the App from the year 2009 have been rewritten - it feels much more like 2019 now.

### 2.3.4

• Support for Charges in public library accounts
• Improved icon readability
• Fix layout issue for cover images

### 2.3.3

• Updated design for loans view

### 2.3.2

• Fix renewal for Bücherhallen Hamburg
• Fix layout in loans view

### 2.3.1

• Improved performance for Bücherhallen Hamburg

### 2.3.0

• Renew support for Bücherhallen Hamburg

### 2.1.0

• Better support for dynamic text - use the font sizes you are most comfortable with

### 2.0.0

• Fix crash when showing a dialogue iPad
• Improve Search History sync
• Fix Wismar Search
• Fix Lüneburg Search and Login
• Fix Rostock Search
• Fix Magdeburg Search and Login
• Fix Greifswald Search
• Update Goettingen to use safer connection type
• Adds Commerzbibliothek Hamburg
• Additional information in search results list

### 1.8.0

• stability improvements for search results list
• covers for public library type (Hamburg Public) in search results list
• stability improvement legal notice view

### 1.7.0

• initial support for public libraries, starting with Hamburg
• support for iOS 11
• support iPhone X

### 1.6.0

• improved dark mode. It's dark like Irma Vep at night now.
• revamped search with sync'ed and editable search history
• lots of minor improvements


### 1.5.5

• Bug fixes - keeps last update date for accounts in sync
• Revamp search
• killall cocoapods

### 1.5.4

• Adds bookmark detail view
• Improves layout of book cover in search detail view
• Reenables recommend and rate functionality in the info screen

### 1.5.3

• Bookmarks search items + loans
• Improved search result
• Cover images for many search results
• Splash screen
• Light and dark theme

### 1.5.2

• Uses new icons in search
• Improved search detail view layout
• Updates Crashlytics
• Removes necessity to add sublibraries to a library

### 1.5.1

• Replaces activity indicator
• Removes unused files and classes
• Fixes bug with whitespaces in user login
• Replaces loan cells
• Replaces search result cells
