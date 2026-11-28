# BTLB 2.31.0 – Release and App Review information

Everything needed to submit BTLB 2.31.0 to App Store Connect and App Review, in one place.
Facts come from `origin/main` (`d8a1083`) and from the branch of the still-open PR #40
(`origin/claude/pensive-franklin-9hqgc4`, `2caef8e`). Anything that couldn't be checked in the
repository is marked **Assumption** or **Check**.

> **Assumption:** 2.30.0 has already shipped, built from tag `v2.30.0rc1` (`153dfa9`, #38).
> So #36 (demo account) and #37 (neoneon recommendations) are already in 2.30.0, and 2.31.0 is
> everything on `main` after `v2.30.0rc1` plus PR #40. If 2.30.0 was built from a later commit,
> only section 1 changes.

> **Prerequisite: merge PR #40 first**, then archive 2.31.0 from `main`. Without #40 there is no
> user-facing change in 2.31.0, and `MARKETING_VERSION` is still 2.30.0 (#40 bumps it).

---

## 1. Version, build and what's in the release

### Version and build

| | Value | Where |
|---|---|---|
| App | BTLB, bundle ID `com.elbedev.sync`, App Store ID `383008918` | `BTLB.xcodeproj`, `BTLBSettings` |
| Version (`CFBundleShortVersionString`) | **2.31.0** once #40 is merged (`main` has 2.30.0) | `Release.xcconfig` → `MARKETING_VERSION`, bumped in #40 (`2caef8e`) |
| Build (`CFBundleVersion`) | **1** in the repository | `Release.xcconfig` → `CURRENT_PROJECT_VERSION` |
| Previous App Store release | 2.30.0, from tag `v2.30.0rc1` (`153dfa9`, 6 Nov 2026) – **Assumption** | `git tag` |
| Minimum iOS | **26.0** (app, widget, notification service), unchanged since 2.30.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| Devices | iPhone and iPad (`TARGETED_DEVICE_FAMILY = 1,2`) | project |
| `paper` (Rust) submodule | `a187a771`, unchanged since 2.30.0 | `git submodule status` |

`Release.xcconfig` is the base configuration of the project-level Release configuration (and of the
widget and notification service Release configurations), so the app and both extensions all get
2.31.0 (1).

**How builds are made:** Xcode Cloud (`BTLB.xcodeproj/xcshareddata/xcodecloud/manifest.json`).
`ci_scripts/ci_post_clone.sh` installs Rust and `cargo-swift` and builds the `Paper` Swift package
with `make apple-release`; `ci_scripts/ci_post_xcodebuild.sh` only prints diagnostics when the
build fails. fastlane is only used for screenshots, not for building or uploading. The workflow
itself lives in App Store Connect and isn't in the repository.

- **Assumption:** Xcode Cloud sets the build number of archives it distributes, so the uploaded
  build won't be "1". Check it in App Store Connect / TestFlight before choosing the build.
- #40 branches off `153dfa9` (#38), not the tip of `main`. `git merge-tree` shows it merges with
  `main` and this branch without conflicts today (both touch `BookmarkListView.swift`, but in
  different places). Once this branch adds the 2.31.0 section to `Changelog.md`, #40's identical
  section will conflict there; keep one copy (section 2).
- Tag the release after archiving (e.g. `v2.31.0`). There is no `v2.30.0` tag, only `v2.30.0rc1`.

### What's in the release (since `v2.30.0rc1`)

User-facing, as listed in `Changelog.md` 2.31.0:

| Change | PR |
|---|---|
| Export a bookmark, all bookmarks or a search result as text, Markdown or Zotero RDF, via the share sheet | #40 (open) |

Not user-facing:

| Change | PR | Note |
|---|---|---|
| Fix five categories of compiler warnings | #39 | Touches app code: widget large view, avatar grid, sign-in view, renewal intent view, bookmark list, mocks. Worth a quick look at those screens in TestFlight |
| `about.md` with the history of the app, linked from the README | #41 | Docs only |
| Changelog, What's New and this document | this PR | Docs only |

### What #40 adds (code)

- `LibraryCore/ZoteroRDF/`: `BibliographicRecord`, `BibliographicRecordMapper` (maps the
  label/value details of bookmarks and search results to a record: title, creators, ISBN, DOI,
  publisher, year, call number, library, URL …), `ZoteroRDFWriter`, `ZoteroRDFDocument`
  (`Transferable`, writes a `.rdf` file).
- `LibraryCore/Export/`: `BibliographyFormatter` (plain text and Markdown), `BibliographyText`
  (`Transferable`: RTF with bold titles and links, plain text fallback).
- `LibraryUI/BibliographyExportMenu.swift`: the menu (icon `square.and.arrow.up`, accessibility
  label "Export") with three `ShareLink`s: **Text**, **Markdown**, **Zotero**. Disabled when there
  is nothing to export.
- Placed in `BookmarkListView.swift`, `BookmarkDetailView.swift` and `SearchResultDetailView.swift`.
- Tests: `BibliographicRecordMapperTests`, `BibliographyFormatterTests`, `ZoteroRDFWriterTests`
  (LibraryCore). Not run here (see section 7).

---

## 2. App Store "What's New" texts

Copied verbatim from `Changelog.md` → 2.31.0. They are only about the export, the only
user-facing change. All are far below the 4000-character limit.

PR #40 also adds a `### 2.31.0` section to `Changelog.md` with the same bullet, word for word.
Whichever of the two PRs is merged second gets a trivial conflict in `Changelog.md`: keep this
PR's section (bullet plus What's New texts) and drop the duplicate.

> **The Spanish, French, Turkish and Ukrainian texts need a check by a native speaker.**

### English (en)

```text
New in BTLB: export your bookmarks and search results.

Tap the share button on a bookmark, in your list of bookmarks or on a search result and choose a format: text, Markdown or Zotero. Then share it with another app, in a message or via AirDrop to your Mac.

The Zotero file imports straight into Zotero on your Mac, so your sources are ready for your next paper.

Thanks for using BTLB, and good luck with your studies!
```

### German (de)

```text
Neu in BTLB: Exportiere deine Lesezeichen und Suchergebnisse.

Tippe bei einem Lesezeichen, in deiner Lesezeichenliste oder bei einem Suchergebnis auf den Teilen-Button und wähle ein Format: Text, Markdown oder Zotero. Dann teilst du es mit einer anderen App, in einer Nachricht oder per AirDrop mit deinem Mac.

Die Zotero-Datei importierst du direkt in Zotero auf deinem Mac, so sind deine Quellen bereit für die nächste Hausarbeit.

Danke, dass du BTLB nutzt, und viel Erfolg im Studium!
```

### Spanish (es) – needs native-speaker check

```text
Novedad en BTLB: exporta tus marcadores y resultados de búsqueda.

Toca el botón de compartir en un marcador, en tu lista de marcadores o en un resultado de búsqueda y elige un formato: texto, Markdown o Zotero. Después compártelo con otra app, en un mensaje o por AirDrop con tu Mac.

El archivo de Zotero se importa directamente en Zotero en tu Mac, así tus fuentes están listas para tu próximo trabajo.

¡Gracias por usar BTLB y mucha suerte con tus estudios!
```

### French (fr) – needs native-speaker check

```text
Nouveau dans BTLB : exportez vos signets et vos résultats de recherche.

Touchez le bouton de partage sur un signet, dans votre liste de signets ou sur un résultat de recherche, puis choisissez un format : texte, Markdown ou Zotero. Partagez-le ensuite avec une autre app, dans un message ou par AirDrop vers votre Mac.

Le fichier Zotero s'importe directement dans Zotero sur votre Mac : vos sources sont prêtes pour votre prochain travail.

Merci d'utiliser BTLB, et bonne réussite dans vos études !
```

### Turkish (tr) – needs native-speaker check

```text
BTLB'de yeni: Yer işaretlerinizi ve arama sonuçlarınızı dışa aktarın.

Bir yer işaretinde, yer işaretleri listenizde veya bir arama sonucunda paylaş düğmesine dokunun ve bir biçim seçin: metin, Markdown veya Zotero. Ardından başka bir uygulamayla, bir mesajla ya da AirDrop ile Mac'inizle paylaşın.

Zotero dosyası doğrudan Mac'inizdeki Zotero'ya aktarılabilir; böylece kaynaklarınız bir sonraki ödeviniz için hazır olur.

BTLB'yi kullandığınız için teşekkürler, derslerinizde başarılar!
```

### Ukrainian (uk) – needs native-speaker check

```text
Нове в BTLB: експортуйте закладки та результати пошуку.

Торкніться кнопки «Поділитися» в закладці, у списку закладок або в результаті пошуку та виберіть формат: текст, Markdown або Zotero. Потім поділіться ним з іншою програмою, у повідомленні або через AirDrop зі своїм Mac.

Файл Zotero можна одразу імпортувати в Zotero на вашому Mac, тож ваші джерела будуть готові до наступної роботи.

Дякуємо, що користуєтеся BTLB, і успіхів у навчанні!
```

The texts call the export button the "share button" because it shows the share icon
(`square.and.arrow.up`). Its VoiceOver label is "Export" (localized).

---

## 3. App Review information

### Sign-in information (App Store Connect → App Review Information)

| Field | Value |
|---|---|
| Sign-in required | Yes (to see loans and charges; search, bookmarks and export work without an account) |
| User name | `demo` |
| Password | `demo` |

### How the demo account works (verified in code, #36, unchanged since 2.30.0)

- `Packages/LibraryCore/Sources/LibraryCore/DemoAccount.swift`: username `demo` **and** password
  `demo`, both exact and case-sensitive.
- It works at **every library that can be selected for sign-in**. Signing in never contacts the
  library: `Classes/ValidateAccountUseCase.swift` returns `.valid` straight away and
  `PaperMapper.swift` (`AccountScraper`) returns the made-up account instead of scraping.
- Libraries with `enabled_for_login: false` are greyed out. That's only "Hamburg – Stiftung
  Hamburger Öffentliche Bücherhallen". "Berlin – Staatsbibliothek Preußischer Kulturbesitz" can
  be selected.
- Data shown (due dates relative to the moment of signing in):

  | Title | Author | Due | Renewals | Renewable |
  |---|---|---|---|---|
  | Der Process | Franz Kafka | in 2 days | 0 | yes |
  | Effi Briest | Theodor Fontane | in 9 days | 1 | yes |
  | Faust. Der Tragödie erster Teil | Goethe | today | 2 | no |
  | Der Schimmelreiter | Theodor Storm | in 21 days | 0 | no, reserved by someone else |
  | Kinder- und Hausmärchen | Grimm | 3 days overdue | 0 | no |

  Plus one charge: "Säumnisgebühr" (late fee) 1,50 € for "Kinder- und Hausmärchen".
- Renewing a demo loan reports success but keeps the due date. Pull to refresh changes nothing
  while the demo account is the only active account.
- The demo data is German whatever the device language.

### How the export works (verified in the #40 branch)

| Where | Button | What's exported |
|---|---|---|
| Bookmarks tab, list | share icon in the navigation bar, top right, next to the sparkles (AI) button. Only shown when there is at least one bookmark | all bookmarks **in the list**, i.e. only those matching the search field if there is a search. Name "Bookmarks" (localized), Zotero file e.g. `Bookmarks.rdf` |
| Bookmark detail | share icon in the toolbar, next to the trash button | that bookmark. Name and file name from its title |
| Search result detail | share icon in the toolbar, top left, after the bookmark and availability buttons | that result. **Disabled (greyed out) until the result's details have loaded** |

Tapping the icon opens a menu with three formats. Each opens the iOS share sheet:

- **Text**: a short reference per record (title, authors, publisher/year, ISBN, library and call
  number, URL). Apps that take rich text (Notes, Mail) get bold titles and links (RTF); others
  get plain text.
- **Markdown**: the same as a Markdown string.
- **Zotero**: a Zotero RDF file (`<title>.rdf`, `application/rdf+xml`), to save to Files, AirDrop
  to a Mac and import there via Zotero's File → Import. Zotero isn't needed on the iPhone/iPad.

### Review notes (ready to paste into "Notes")

```text
BTLB shows the loans and charges of library accounts at German libraries (Staatsbibliothek zu Berlin and libraries of the GBV network), lets you renew loans and search the library catalogue.

NEW IN 2.31.0: EXPORT
Bookmarks and search results can be exported as text, Markdown or a Zotero file (Zotero is a free reference manager for researchers). Export happens entirely on the device: the app sends nothing anywhere. The iOS share sheet opens and you choose where the export goes.

How to try it:
1. Search tab (magnifying glass): tap the library button and select "Berlin – Staatsbibliothek Preußischer Kulturbesitz", then search e.g. "Kafka" and open a result.
2. Wait until the details have loaded, then tap the share icon at the top (next to the bookmark and availability buttons). Choose "Text", "Markdown" or "Zotero". The share sheet opens; e.g. tap "Copy", "Notes" or "Save to Files".
3. Tap the bookmark button to bookmark the result. You can also bookmark a loan of the demo account (see below).
4. Bookmarks tab: the share icon at the top right exports all bookmarks shown in the list. Open a bookmark: the share icon next to the trash button exports that bookmark.
The Zotero option creates an .rdf file which can be imported into the Zotero desktop app (File > Import). Zotero is not needed to test the export; saving the file to Files shows that it works.

DEMO ACCOUNT
You don't need a real library card. A built-in demo account works at every library that can be selected for sign-in. It never contacts a library and shows made-up data.

1. Open the "Accounts" tab and tap "Add Account".
2. Tap "Select Library" and choose any library that isn't greyed out, e.g. "Berlin – Staatsbibliothek Preußischer Kulturbesitz".
3. Library Card Number: demo
   Password: demo
4. Tap "Sign In", then "Let's read".

The demo account shows five sample loans (German classics: one due today, one overdue, one reserved by someone else, two renewable) and one late fee of 1,50 €. The item details are in German, as real library data would be. Renewing a demo loan shows the success message but doesn't change its due date; pulling to refresh doesn't change the demo data.

WHAT ELSE TO TRY
- Accounts tab: the loans and charges of all accounts in one place. Tap a loan to open its details. Renew "Der Process" or "Effi Briest". Tap the bookmark icon to bookmark a loan.
- Search tab: searches a real library catalogue and needs an internet connection.
- AI book recommendations: in the Bookmarks tab tap the sparkles button, select up to 10 bookmarks and tap "Generate Recommendations". Only the titles of the selected bookmarks are sent to neoneon.dev (our own server), which passes them to the LLM provider OpenRouter and returns up to three suggestions. The (i) button explains this. The feature needs an internet connection and Apple's App Attest, so it is hidden in the Simulator. It can be turned off in More > Settings.
- More tab: settings, alternative app icon, about and open source information.
- Widgets show upcoming due dates. Siri / Shortcuts: "Search in BTLB", "Renew with BTLB".

Thank you for reviewing BTLB!
```

### Features that need the network or a third-party service

Unchanged since 2.30.0. **The export adds none**: the #40 code has no `URLSession` or other
network calls. It only builds text / files on the device and hands them to the share sheet.

| Feature | Talks to | Notes |
|---|---|---|
| Sign in, loans, renewals of real accounts | the selected library's catalogue/OPAC servers (e.g. `*.gbv.de`) | Not needed for the demo account |
| Search, search result details | library catalogue; Berlin searches K10plus SRU (`sru.k10plus.de`, record links to `stabikat.de`) | Needs network |
| AI book recommendations | `https://neoneon.dev/btlb/recommender/…` → OpenRouter | Real device only (App Attest). Server must accept production App Attest keys |
| Push token for background refresh | `https://neoneon.dev/btlb/pushtoken` (`Release.xcconfig`) | APNs token sent as hex |
| Search history sync | user's own iCloud key-value store | |
| Recommender feedback | Mail composer to `support@btlb.app` | Only when the user taps "Feedback" |
| App version check | `itunes.apple.com/lookup?id=383008918` | |

**Check before submitting:** neoneon.dev is up and accepts **production** App Attest keys. Do one
end-to-end run with a TestFlight build on a real device.

---

## 4. Privacy and the App Privacy questionnaire

### What the export changes

- **Nothing leaves the device through the app.** The export data (title, authors, publisher,
  year, ISBN/DOI, library name, call number, catalogue URL, other catalogue fields as "extra") is
  only handed to the iOS share sheet, and the user picks the recipient. Apple doesn't count
  user-initiated sharing via the share sheet as collection by the developer. **No change to the
  App Privacy answers** is needed for 2.31.0.
- The Zotero file is written to `FileManager.default.temporaryDirectory/ZoteroRDF/<UUID>/` and not
  deleted afterwards (iOS purges `tmp`). Not a privacy issue (app sandbox), just leftover files.
- No new permissions or usage-description strings (no photo library, contacts, files access).
- **`PrivacyInfo.xcprivacy`:** no new required-reason APIs. Writing a file to the temporary
  directory isn't one; the code reads no file timestamps, disk space or boot time.

### What leaves the device, and to whom (unchanged since 2.30.0)

| Data | Recipient | Stored? | In the code |
|---|---|---|---|
| Titles of the **selected** bookmarks (max 10) | neoneon.dev, then OpenRouter | neoneon.dev: not stored, per the in-app text. OpenRouter / model provider: **unknown, check** | `Packages/Bookmarks/Sources/Bookmarks/AI/Neoneon/RecommenderAPI.swift` |
| App Attest key ID, attestation, assertions | neoneon.dev | key ID registered on the server | `DeviceAppAttest.swift`, `RecommenderClient.swift` |
| APNs device token | neoneon.dev (`/btlb/pushtoken`) | presumably | `PushNotificationManager.swift` |
| Library card number and password | only the user's library | device Keychain | `ValidateAccountUseCase.swift`, `PaperMapper.swift` |
| Search queries | the selected library catalogue / K10plus | not by the developer | Search package, Paper |
| Search history | user's own iCloud (KVS) | user's iCloud | `SearchHistoryController.swift` |

No analytics, crash reporting, advertising or tracking SDKs, no IDFA.

### Open privacy points carried over from 2.30.0 (the owner decides)

- **Tracking:** No.
- **Bookmark titles for AI recommendations:** **check** OpenRouter's and the model provider's
  retention for neoneon's key. If titles are retained, declare *User Content → Other User
  Content*, App Functionality, not linked, no tracking.
- **APNs token on neoneon.dev:** decide whether to declare it as *Identifiers → Device ID*.
- **Guideline 5.1.2(i):** the AI recommender is **on by default** and sends titles without asking
  first; it's explained in the (i) sheet and can be turned off. Decide whether a one-time consent
  prompt is wanted.
- **Privacy policy URL** in App Store Connect should describe neoneon.dev / OpenRouter and the
  push token. The export needs no mention.

---

## 5. Other submission checks

### `BTLB-Info.plist` change in #40

#40 adds a `UTImportedTypeDeclarations` entry:

| Key | Value |
|---|---|
| `UTTypeIdentifier` | `org.w3.rdf-xml` |
| `UTTypeDescription` | RDF/XML |
| `UTTypeConformsTo` | `public.xml` |
| extension / MIME | `rdf` / `application/rdf+xml` |

It matches `UTType(importedAs: "org.w3.rdf-xml", conformingTo: .xml)` in `ZoteroRDFDocument.swift`,
so shared files get the `.rdf` extension. **Imported**, not exported, is right: BTLB doesn't own
the RDF format. There's no `CFBundleDocumentTypes` / `LSSupportsOpeningDocumentsInPlace`, so BTLB
does **not** claim to open `.rdf` files and won't show up in "Open in…". Nothing for App Review to
ask about. No other plist keys change.

### Localized strings for the export (#40)

`Packages/LibraryUI/Sources/LibraryUI/Resources/Localizable.xcstrings` gets two keys, both
`translated` in all six languages:

| Key | en | de | es | fr | tr | uk |
|---|---|---|---|---|---|---|
| `export format text` | Text | Text | Texto | Texte | Metin | Текст |
| `export menu` (VoiceOver label) | Export | Exportieren | Exportar | Exporter | Dışa aktar | Експортувати |

"Markdown" and "Zotero" are shown verbatim (`Text(verbatim:)`, names). The list export's name uses
the existing `Localization.Titles.bookmarks`. No missing translations.

### Export compliance

- `BTLB-Info.plist`: `ITSAppUsesNonExemptEncryption = false`, so App Store Connect won't ask.
  **#40 doesn't change this:** it adds no encryption and no networking.
- Swift code: HTTPS via `URLSession`, CryptoKit SHA-256 (App Attest payloads), App Attest /
  DeviceCheck – all exempt.
- **Check (carried over):** the Rust `paper` crate still depends on `async-openai` for its old,
  unused OpenRouter `Recommender`, which pulls in `reqwest 0.13` with `rustls` / `aws-lc-rs` /
  `ring`. Standard TLS only, so `false` is most likely still right. Removing it from `paper` would
  drop the dead code and the extra TLS stack (follow-up in q231950/paper).

### Minimum iOS

- **iOS 26.0**, same as 2.30.0. No change for users.

### Screenshots

- `AppStore Screenshots/` dates from 2023 and predates the Accounts tab, the iOS 26 search tab and
  now the export, so **it's outdated**. Apple needs 6.9" iPhone and 13" iPad screenshots (or
  accepts scaled ones); check App Store Connect's current requirements. Screenshots aren't
  required to change for 2.31.0, but a shot of the export menu would show the new feature.
- `fastlane/Snapfile` and the root `Snapfile` list devices that can't run iOS 26. The demo account
  (#36) is a good way to make new screenshots with realistic data.

### What ships in the binary

- App `com.elbedev.sync` (iPhone + iPad), widget extension `com.elbedev.sync.widget`, notification
  service extension `com.elbedev.sync.BTLBNotificationService`.
- App Intents: `PerformSearchIntent`, `RenewItemsIntent` (`Intents/BTLBShortcutsProvider.swift`).
- Core Spotlight, background refresh, alternative app icon, associated domain `applinks:neoneon.dev`,
  URL scheme `btlb://`.
- Entitlements: push, App Attest, App Group `group.com.elbedev.sync`, iCloud KVS, Keychain group,
  data protection. **Check:** App Attest capability enabled on the App ID (#37).
- `NSAllowsArbitraryLoads = true` (some library servers are plain HTTP). Have a one-line reason
  ready ("library servers that don't support HTTPS").
- New in 2.31.0: the `org.w3.rdf-xml` imported type (above).

### Localizations

- String catalogs have **en, de, es, fr, tr, uk**; `InfoPlist.xcstrings` too.
- The project's `knownRegions` lists only `en`, `de`, `Base`. **Check** in TestFlight / App Store
  Connect that es, fr, tr and uk are listed as app languages.
- App Store metadata exists for **en and de only** (`Documentation/AppStoreDescription/`). The
  What's New texts above are ready for all six.
- `AppShortcuts.strings` exists for en and de only.

---

## 6. Pre-submission checklist

- [ ] Merge PR #40 (resolve the trivial `Changelog.md` conflict, section 2) and this PR into `main`
- [ ] Archive 2.31.0 with Xcode Cloud from `main`; check the version is 2.31.0 and note the build number
- [ ] Tag the release (e.g. `v2.31.0`)
- [ ] Run #40's LibraryCore tests (`BibliographicRecordMapperTests`, `BibliographyFormatterTests`, `ZoteroRDFWriterTests`) in Xcode
- [ ] TestFlight on a real iOS 26 device: export from bookmark list, bookmark detail and a search result in all three formats; Copy, Notes, Mail, Save to Files, AirDrop to a Mac; import the `.rdf` in Zotero on a Mac
- [ ] TestFlight: demo sign-in, renew, refresh, search (Berlin), bookmark, AI recommendations, widget, Siri renewal (#39 touched the renewal intent view and widget)
- [ ] Revoke / rotate the **old OpenRouter API key** that shipped inside 2.28.0 / 2.29.0 (#37), if not done yet
- [ ] Xcode Cloud workflow: delete the old `OPEN_ROUTER_API_KEY` environment variable (#37), if not done yet
- [ ] Developer portal: App Attest capability enabled on `com.elbedev.sync` (#37)
- [ ] neoneon.dev: recommender up, accepting production App Attest keys; push token endpoint up
- [ ] Native-speaker check of es / fr / tr / uk What's New texts
- [ ] Paste What's New for every language in App Store Connect
- [ ] App Review Information: sign-in `demo` / `demo`, paste the review notes (section 3), contact details
- [ ] App Privacy answers and privacy policy URL still match section 4 (no change from the export)
- [ ] Export compliance: `ITSAppUsesNonExemptEncryption = false` (no question in App Store Connect)
- [ ] Optional: new screenshots (6.9" iPhone, 13" iPad), e.g. with the export menu

---

## 7. Open questions and risks

### From #40 (export)

1. **Search result export is greyed out until the details load.** On a slow connection a reviewer
   may tap a disabled icon. The review notes say to wait. Not a blocker.
2. **The list export exports only what the list shows.** With text in the bookmark search field,
   only matching bookmarks are exported. That's deliberate (doc comment in #40), but the changelog
   says "all bookmarks".
3. **Records are built on every redraw.** `BookmarkListView` maps all bookmarks to records, and
   `BibliographyExportMenu` builds the Markdown string, each time the view's body is evaluated,
   not only when the menu is used. Fine for a few dozen bookmarks; could be slow with hundreds.
   Not a review issue.
4. **Temporary `.rdf` files are never deleted** (`tmp/ZoteroRDF/<UUID>/`). iOS cleans `tmp` up
   eventually. Cosmetic.
5. **Zotero name in the What's New text.** Naming a third-party product to describe compatibility
   is normally fine; the texts don't suggest an affiliation. Low risk.
6. **Not tested here:** #40's tests and the UI weren't run (no Xcode or simulator on this
   machine; `LibraryCore` now imports `UIKit` and `CoreTransferable`, so it doesn't build on
   Linux). No UI test covers the export menu, though it has accessibility identifiers
   (`export`, `export as text`, `export as markdown`, `export for zotero`).
7. `Packages/Search` imports `LibraryUI` (already on `main`, now also for the export menu) without
   listing it in `Search/Package.swift`. It builds in the app because Xcode resolves the package
   anyway; `swift build` of the Search package alone would fail. Pre-existing, not new in #40.

### Carried over from 2.30.0

8. **Default search library is "Hamburg – Bücherhallen", which is disabled for search.**
   `LibraryManager` uses `HAMBURGPUBLIC` as `defaultSearchLibraryIdentifier` until the user picks
   another library. On a fresh install a reviewer who searches without choosing a library may get
   errors or no results, and then can't try the search result export. The review notes say to
   choose Berlin first. Consider changing the default to `BERLIN`.
9. **Login library selection text mentions the Bücherhallen,** although Bücherhallen sign-in is
   disabled (`LibrarySelectionView.swift`). The German version starts with "Derzeit unterstützt
   die Suche …", which talks about search, not login.
10. **UI test `test_demoAccount` probably can't pass.** It signs in at "Bücherhallen Hamburg",
    which is disabled for login and labelled differently. Not run here.
11. **Old OpenRouter key** in 2.28.0 / 2.29.0 binaries: rotate it if that hasn't happened.
12. **Dead OpenRouter code in `paper`** (`async-openai`), extra TLS stack (section 5).
13. **AI recommender is on by default and sends titles without asking first** (section 4).
14. **`knownRegions`** lists only `en`, `de`, `Base` (section 5).
15. **Stale values in `BTLB-Info.plist`:** `GitBranch = main`, `GitCommit = e1203fb`,
    `NSHumanReadableCopyright` 2024. Cosmetic.
16. **Screenshots and Snapfiles outdated** (section 5).

Things I could not verify here: building or running the app or tests, the Xcode Cloud workflow,
App Store Connect and developer portal state, what 2.30.0 was actually built from, the
neoneon.dev server and OpenRouter retention settings, and an import of the generated `.rdf` file
into Zotero.
