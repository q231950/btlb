# BTLB 2.30.0 – Release and App Review information

Everything needed to submit BTLB 2.30.0 to App Store Connect and App Review, in one place.
Facts are taken from the code on `release-2.30.0-prep` (`13e24c5`). Anything that couldn't be
checked in the repository is marked **Assumption** or **Check**.

---

## 1. Version, build and what's in the release

### Version and build

| | Value | Where |
|---|---|---|
| App | BTLB, bundle ID `com.elbedev.sync`, App Store ID `383008918` | `BTLB.xcodeproj`, `BTLBSettings` |
| Version (`CFBundleShortVersionString`) | **2.30.0** | `Release.xcconfig` → `MARKETING_VERSION` |
| Build (`CFBundleVersion`) | **1** in the repository | `Release.xcconfig` → `CURRENT_PROJECT_VERSION` |
| Previous App Store release | 2.29.0, build 14 (`f629e4a`, "Build 2.29.0 (#15)", 10 Sep 2025) | `git show f629e4a:Release.xcconfig` |
| Minimum iOS | **26.0** (app, widget, notification service). Was **17.2** in 2.29.0 | `IPHONEOS_DEPLOYMENT_TARGET`, raised in #23 |
| Devices | iPhone and iPad (`TARGETED_DEVICE_FAMILY = 1,2`) | project |
| `paper` (Rust) submodule | `a187a771` | `git submodule status` |

`Release.xcconfig` is the base configuration of the project-level Release configuration (and of the
widget and notification service Release configurations), so the app and both extensions all get
2.30.0 (1).

**How builds are made:** Xcode Cloud (`BTLB.xcodeproj/xcshareddata/xcodecloud/manifest.json`).
`ci_scripts/ci_post_clone.sh` installs Rust and `cargo-swift` and builds the `Paper` Swift package
with `make apple-release`; `ci_scripts/ci_post_xcodebuild.sh` only prints diagnostics when the
build fails. fastlane is only used for screenshots (`fastlane snapshot`), not for building or
uploading. The workflow itself (branch, archive, TestFlight/App Store distribution) lives in App
Store Connect and isn't in the repository.

- **Assumption:** Xcode Cloud sets the build number of archives it distributes, so the uploaded
  build won't be "1". Check the build number in App Store Connect / TestFlight before choosing the
  build for the submission.
- Tags: `v2.30.0rc1` points at `153dfa9` (#38). The branch has three more commits since then:
  #39 (compiler warning fixes, touches app code), #41 (`about.md`) and the changelog update. If an
  rc1 build was uploaded from the tag, it doesn't contain #39. Build the release from `main` after
  this branch is merged.
- The remote branch `origin/release-2-30-0` (Sep 2025) only bumps the version and is stale.
- A commit `2caef8e` "Bump the version to 2.31.0" exists only on
  `origin/claude/pensive-franklin-9hqgc4`; it isn't on this branch or `main`.

### What's in the release (since 2.29.0)

User-facing, as listed in `Changelog.md` 2.30.0:

| Change | PR |
|---|---|
| Loans and charges of every account in a single Accounts tab | #30 |
| Add, edit and delete accounts right in the Accounts tab | #31 |
| Search lives in the standard iOS search tab (`Tab(role: .search)`) | #28 |
| The search history stays clear of the search field above the keyboard | #29 |
| The library button stays visible while searching | #32 |
| Refreshed buttons with a loading state, in light and dark mode | #18 |
| Loan details open as a sheet you can swipe away, at half or full height | #18 |
| Deleting a bookmark asks for confirmation first | #18 |
| The library picker is titled "Libraries" in English | #26 |
| Staatsbibliothek Berlin searches its catalog via K10plus (StabiKat merged into Berlin) | #23, #24 |
| Search library selection text highlights the Staatsbibliothek Berlin | #33 |
| Demo account: sign in at any library with demo/demo | #36 |
| AI book recommendations come from neoneon.dev, only selected bookmark titles are sent, no API key in the app | #37 |
| Select up to 10 bookmarks for recommendations, localized error messages | #37 |
| Spanish, French, Turkish and Ukrainian translations | #21 |
| **Minimum iOS raised from 17.2 to 26.0** (not in the changelog) | #23 |

Internal / not user-facing: Swift 6 for Accounts and Bookmarks packages (#16, #17), CI recommender
fix (#19), libraries from Paper's `LibraryList` (#22), recommender model rename (#25, superseded by
#37), unused libxml2 removed (#27), Secrets.xcconfig / BuildConfig / ObfuscateMacro removed (#38),
compiler warnings (#39), `about.md` (#41). App Store description rewritten for Stabi students (#34,
`Documentation/AppStoreDescription/`).

---

## 2. App Store "What's New" texts

Copied verbatim from `Changelog.md` → 2.30.0. All are well under the 4000-character limit.

> **The Spanish, French, Turkish and Ukrainian texts still need a check by a native speaker.**

### English (en)

```text
Hello Staatsbibliothek zu Berlin! You can now search the Stabi catalogue right in BTLB.

All your accounts, one tab: the new Accounts tab shows the loans and charges of every account in one place. You can add, edit and delete accounts right there, too.

Search fits perfectly into iOS: it now sits in the standard search tab. Your search history no longer hides behind the keyboard, and the library button stays in view while you search.

New here? Sign in at any library with the username "demo" and the password "demo" to try BTLB with sample loans and charges.

AI book recommendations have a more secure setup: only the titles of the bookmarks you select are sent, and if something goes wrong, a clear message tells you why.

Plus lots of polish: refreshed buttons that show when something is loading, loan details you can open at half or full height and simply swipe away, and a quick confirmation before you delete a bookmark.

Thanks for using BTLB, and good luck with your studies!
```

### German (de)

```text
Hallo Staatsbibliothek zu Berlin! Den Katalog der Stabi kannst du jetzt direkt in BTLB durchsuchen.

Alle Konten in einem Tab: Im neuen Konten-Tab siehst du die Ausleihen und Gebühren all deiner Konten an einem Ort. Dort kannst du Konten auch direkt hinzufügen, bearbeiten und löschen.

Die Suche fügt sich perfekt in iOS ein: Sie sitzt jetzt im Standard-Such-Tab. Dein Suchverlauf verschwindet nicht mehr hinter der Tastatur, und der Bibliotheks-Button bleibt beim Suchen sichtbar.

Neu hier? Melde dich bei einer beliebigen Bibliothek mit dem Benutzernamen „demo“ und dem Passwort „demo“ an und probiere BTLB mit Beispiel-Ausleihen und -Gebühren aus.

Die KI-Buchempfehlungen sind jetzt sicherer aufgestellt: Es werden nur die Titel der Lesezeichen übertragen, die du auswählst, und wenn etwas schiefgeht, sagt dir eine klare Meldung, woran es liegt.

Dazu jede Menge Feinschliff: neu gestaltete Buttons, die anzeigen, wenn etwas lädt, Ausleihdetails, die du halb oder ganz aufziehen und einfach wegwischen kannst, und eine kurze Rückfrage, bevor du ein Lesezeichen löschst.

Danke, dass du BTLB nutzt, und viel Erfolg im Studium!
```

### Spanish (es) – needs native-speaker check

```text
¡Hola, Staatsbibliothek zu Berlin! Ahora puedes buscar en el catálogo de la Stabi directamente en BTLB.

Todas tus cuentas en una pestaña: la nueva pestaña Cuentas muestra los préstamos y los cargos de todas tus cuentas en un solo lugar. Ahí mismo también puedes añadir, editar y eliminar cuentas.

La búsqueda se integra a la perfección en iOS: ahora está en la pestaña de búsqueda estándar. Tu historial de búsqueda ya no se esconde detrás del teclado y el botón de la biblioteca sigue a la vista mientras buscas.

¿Eres nuevo? Inicia sesión en cualquier biblioteca con el usuario «demo» y la contraseña «demo» para probar BTLB con préstamos y cargos de ejemplo.

Las recomendaciones de libros con IA ahora son más seguras: solo se envían los títulos de los marcadores que seleccionas y, si algo falla, un mensaje claro te explica por qué.

Y muchos detalles pulidos: botones renovados que muestran cuándo algo se está cargando, detalles del préstamo que puedes abrir a media altura o a pantalla completa y cerrar con un simple gesto, y una confirmación rápida antes de eliminar un marcador.

¡Gracias por usar BTLB y mucha suerte con tus estudios!
```

### French (fr) – needs native-speaker check

```text
Bonjour la Staatsbibliothek zu Berlin ! Vous pouvez désormais rechercher dans le catalogue de la Stabi directement depuis BTLB.

Tous vos comptes dans un seul onglet : le nouvel onglet Comptes affiche les emprunts et les frais de tous vos comptes au même endroit. Vous pouvez aussi y ajouter, modifier et supprimer des comptes.

La recherche s'intègre parfaitement à iOS : elle se trouve désormais dans l'onglet de recherche standard. Votre historique de recherche ne se cache plus derrière le clavier, et le bouton de la bibliothèque reste visible pendant que vous cherchez.

Nouveau ici ? Connectez-vous à n'importe quelle bibliothèque avec l'identifiant « demo » et le mot de passe « demo » pour essayer BTLB avec des emprunts et des frais fictifs.

Les recommandations de livres par IA sont désormais plus sûres : seuls les titres des signets que vous sélectionnez sont envoyés, et en cas de problème, un message clair vous en explique la raison.

Et de nombreuses finitions : des boutons repensés qui indiquent quand un chargement est en cours, des détails d'emprunt que vous pouvez ouvrir à mi-hauteur ou en plein écran et fermer d'un simple geste, et une petite confirmation avant de supprimer un signet.

Merci d'utiliser BTLB, et bonne réussite dans vos études !
```

### Turkish (tr) – needs native-speaker check

```text
Merhaba Staatsbibliothek zu Berlin! Artık Stabi kataloğunda doğrudan BTLB içinden arama yapabilirsiniz.

Tüm hesaplarınız tek bir sekmede: Yeni Hesaplar sekmesi, tüm hesaplarınızdaki ödünç alınanları ve ücretleri tek bir yerde gösterir. Hesapları da doğrudan burada ekleyebilir, düzenleyebilir ve silebilirsiniz.

Arama iOS'a kusursuz şekilde uyum sağlıyor: Artık standart arama sekmesinde yer alıyor. Arama geçmişiniz artık klavyenin arkasında kalmıyor ve kütüphane düğmesi arama yaparken görünür kalıyor.

Yeni misiniz? Herhangi bir kütüphanede kullanıcı adı "demo" ve şifre "demo" ile giriş yaparak BTLB'yi örnek ödünç alınanlar ve ücretlerle deneyin.

Yapay zekâ kitap önerileri artık daha güvenli: Yalnızca seçtiğiniz yer işaretlerinin başlıkları gönderilir ve bir sorun olursa, açık bir mesaj nedenini size söyler.

Ayrıca pek çok iyileştirme: Bir şey yüklenirken bunu gösteren yenilenmiş düğmeler, yarım ya da tam yükseklikte açıp kolayca kaydırarak kapatabileceğiniz ödünç ayrıntıları ve bir yer işaretini silmeden önce kısa bir onay.

BTLB'yi kullandığınız için teşekkürler, derslerinizde başarılar!
```

### Ukrainian (uk) – needs native-speaker check

```text
Привіт, Staatsbibliothek zu Berlin! Тепер ви можете шукати в каталозі Stabi прямо в BTLB.

Усі облікові записи в одній вкладці: нова вкладка «Облікові записи» показує позики та збори всіх ваших облікових записів в одному місці. Там же можна додавати, редагувати й видаляти облікові записи.

Пошук ідеально вписується в iOS: тепер він у стандартній вкладці пошуку. Історія пошуку більше не ховається за клавіатурою, а кнопка бібліотеки залишається на виду, поки ви шукаєте.

Ви тут уперше? Увійдіть у будь-якій бібліотеці з іменем користувача «demo» і паролем «demo», щоб спробувати BTLB із прикладами позик і зборів.

ШІ-рекомендації книг тепер надійніше захищені: надсилаються лише назви вибраних вами закладок, а якщо щось піде не так, зрозуміле повідомлення пояснить чому.

А ще багато дрібних покращень: оновлені кнопки, які показують, коли щось завантажується, деталі позики, які можна відкрити на пів екрана або на весь екран і просто змахнути, та коротке підтвердження перед видаленням закладки.

Дякуємо, що користуєтеся BTLB, і успіхів у навчанні!
```

None of the texts mention that 2.30.0 needs iOS 26. That's optional, since the App Store only offers
the update to devices that can run it.

---

## 3. App Review information

### Sign-in information (App Store Connect → App Review Information)

| Field | Value |
|---|---|
| Sign-in required | Yes (to see loans and charges; search and bookmarks work without an account) |
| User name | `demo` |
| Password | `demo` |

### How the demo account works (verified in code, #36)

- `Packages/LibraryCore/Sources/LibraryCore/DemoAccount.swift`: username `demo` **and** password
  `demo`, both exact and case-sensitive (`Demo` / `DEMO` don't match).
- It works at **every library that can be selected for sign-in**. Signing in never contacts the
  library: `Classes/ValidateAccountUseCase.swift` returns `.valid` straight away and
  `PaperMapper.swift` (`AccountScraper`) returns the made-up account instead of scraping. No
  network is needed to sign in.
- Libraries for sign-in come from Paper's `LibraryList`
  (`Packages/shared/paper/paper/src/model/library_list.rs`). Libraries with
  `enabled_for_login: false` are shown greyed out and can't be selected. That's only
  "Hamburg – Stiftung Hamburger Öffentliche Bücherhallen". All others, including
  "Berlin – Staatsbibliothek Preußischer Kulturbesitz", can be selected.
- Data shown (due dates relative to the moment of signing in):

  | Title | Author | Due | Renewals | Renewable |
  |---|---|---|---|---|
  | Der Process | Franz Kafka | in 2 days | 0 | yes |
  | Effi Briest | Theodor Fontane | in 9 days | 1 | yes |
  | Faust. Der Tragödie erster Teil | Goethe | today | 2 | no |
  | Der Schimmelreiter | Theodor Storm | in 21 days | 0 | no, reserved by someone else |
  | Kinder- und Hausmärchen | Grimm | 3 days overdue | 0 | no |

  Plus one charge: "Säumnisgebühr" (late fee) 1,50 € for "Kinder- und Hausmärchen".
  Barcodes are `DEMO-0001` … `DEMO-0005`; the account name is "Demo".
- Renewing a demo loan reports success but keeps the due date
  (`Packages/Utilities/Sources/Utilities/DatabaseConnection.swift`). Pull to refresh changes
  nothing while the demo account is the only active account (`Classes/AccountUpdater.swift`).
- The demo data is German whatever the device language: item details ("Verfasser", "Medienart",
  "Standort", "Signatur"), "Säumnisgebühr" and "1,50 €". The note below tells the reviewer.

### Review notes (ready to paste into "Notes")

```text
BTLB shows the loans and charges of library accounts at German libraries (Staatsbibliothek zu Berlin and libraries of the GBV network), lets you renew loans and search the library catalogue.

DEMO ACCOUNT
You don't need a real library card. A built-in demo account works at every library that can be selected for sign-in. It never contacts a library and shows made-up data.

1. Open the "Accounts" tab and tap "Add Account".
2. Tap "Select Library" and choose any library that isn't greyed out, e.g. "Berlin – Staatsbibliothek Preußischer Kulturbesitz".
3. Library Card Number: demo
   Password: demo
4. Tap "Sign In", then "Let's read".

The demo account shows five sample loans (German classics: one due today, one overdue, one reserved by someone else, two renewable) and one late fee of 1,50 €. The item details are in German, as real library data would be. Renewing a demo loan shows the success message but doesn't change its due date; pulling to refresh doesn't change the demo data.

WHAT TO TRY
- Accounts tab: the loans and charges of all accounts in one place. Tap a loan to open its details as a sheet (half or full height, swipe down to close). Renew "Der Process" or "Effi Briest". Tap the bookmark icon to bookmark a loan. Accounts can be added, edited and deleted here.
- Search tab (magnifying glass): searches a real library catalogue and needs an internet connection. Tap the library button and select "Berlin – Staatsbibliothek Preußischer Kulturbesitz", then search e.g. "Kafka". Open a result to see its details and availability, and bookmark it.
- Bookmarks tab: your bookmarked loans and search results. Deleting a bookmark asks for confirmation.
- AI book recommendations: in the Bookmarks tab tap the sparkles button, select up to 10 bookmarks and tap "Generate Recommendations". Only the titles of the selected bookmarks are sent to neoneon.dev (our own server), which passes them to the LLM provider OpenRouter and returns up to three suggestions. Nothing else is sent. The (i) button explains this. The feature needs an internet connection and Apple's App Attest, so it is hidden in the Simulator. It can be turned off in More > Settings.
- More tab: settings, alternative app icon, about and open source information.
- Widgets (Home Screen and Lock Screen) show upcoming due dates. Siri / Shortcuts: "Search in BTLB", "Renew with BTLB".

Thank you for reviewing BTLB!
```

### Features that need the network or a third-party service

| Feature | Talks to | Notes |
|---|---|---|
| Sign in, loans, renewals of real accounts | the selected library's catalogue/OPAC servers (e.g. `*.gbv.de`) | Not needed for the demo account |
| Search, search result details | library catalogue; Berlin searches K10plus SRU (`sru.k10plus.de`, record links to `stabikat.de`) | Needs network |
| AI book recommendations | `https://neoneon.dev/btlb/recommender/…` → OpenRouter | Real device only (App Attest). The server must accept production App Attest keys, which App Store / TestFlight builds use |
| Push token for background refresh | `https://neoneon.dev/btlb/pushtoken` (`Release.xcconfig`) | APNs token sent as hex, POST, on every registration |
| Search history sync | user's own iCloud key-value store (`NSUbiquitousKeyValueStore`) | |
| Recommender feedback | Mail composer to `support@btlb.app` | Only when the user taps "Feedback" |
| App version check | `itunes.apple.com/lookup?id=383008918` | Referenced in `BTLBSettings` |

**Check before submitting:** neoneon.dev must be up and must accept **production** App Attest keys.
`APP_ATTEST_ALLOW_DEVELOPMENT` only matters for Xcode-signed builds (README). If the recommender
fails during review, the reviewer sees a localized error message, but it's better if the feature
works. Do one end-to-end run with a TestFlight build on a real device.

---

## 4. Privacy and the App Privacy questionnaire

### What leaves the device, and to whom

| Data | Recipient | Stored? | In the code |
|---|---|---|---|
| Titles of the **selected** bookmarks (max 10, max 200 chars each, cleaned) | neoneon.dev, then OpenRouter (LLM provider) | neoneon.dev: not stored, per the in-app text. OpenRouter / model provider: **unknown, check** | `Packages/Bookmarks/Sources/Bookmarks/AI/Neoneon/RecommenderAPI.swift` |
| App Attest key ID, attestation and per-request assertions, timestamp | neoneon.dev | key ID registered on the server | `DeviceAppAttest.swift`, `RecommenderClient.swift` |
| APNs device token | neoneon.dev (`/btlb/pushtoken`) | presumably, to send refresh pushes | `Packages/Utilities/Sources/Utilities/Notifications/PushNotificationManager.swift` |
| Library card number and password | only the user's library | in the device Keychain | `ValidateAccountUseCase.swift`, `PaperMapper.swift` |
| Search queries | the selected library catalogue / K10plus | not by the developer | Search package, Paper |
| Search history | user's own iCloud (KVS) | in the user's iCloud | `Packages/Search/Sources/Search/SearchHistoryController.swift` |

Things I didn't find: analytics, crash reporting, advertising or tracking SDKs (no Firebase,
Sentry, TelemetryDeck etc.), and no IDFA use.

What changed in 2.30.0: before #37 the app called OpenRouter **directly** with a key built into the
app. Now it calls neoneon.dev, which calls OpenRouter. The data sent (bookmark titles) is the same
kind as before, but the first recipient is now the developer's own server.

### App Store Connect → App Privacy (suggestions, the owner decides)

- **Tracking:** No.
- **Bookmark titles for AI recommendations:** Apple counts data as "collected" when it leaves the
  device and the developer or a partner can access it for longer than it takes to serve the
  request. neoneon.dev doesn't store titles, according to the in-app text. **Check** OpenRouter's
  logging/retention settings for the key neoneon uses, and those of the model provider. If titles
  are retained, declare *User Content → Other User Content*, purpose *App Functionality*, **not
  linked** to the user, **not** used for tracking. If they aren't retained, this may stay "not
  collected". Compare with what the current App Store privacy label says and update it if it was
  answered for the old direct-to-OpenRouter flow.
- **APNs token on neoneon.dev:** Decide whether you treat this as *Identifiers → Device ID* (App
  Functionality, not linked, no tracking). Many apps don't declare push tokens. Make sure the
  answer matches the privacy policy.
- **Library credentials / search queries:** they go to the library the user picked, not to the
  developer. That's normally not "collection".
- **App Store guideline 5.1.2(i) (sharing personal data with third-party AI):** Apple's guidelines
  ask apps to say clearly when personal data goes to third-party AI and to get permission first.
  The app explains this in the recommender's (i) sheet and has an off switch in Settings. The
  feature is **on by default** (`UserDefaults+Suite.swift`, `enableAiRecommender: true`), and the
  user isn't asked to agree before the first titles are sent. Bookmark titles are arguably not
  personal data, and the review notes explain the flow. Decide whether that's enough or whether a
  one-time consent prompt is wanted (future release).
- **Privacy policy:** I found no privacy policy URL in the app's code. Make sure the privacy policy
  URL in App Store Connect describes neoneon.dev and OpenRouter for recommendations and
  neoneon.dev for push tokens.

### `PrivacyInfo.xcprivacy`

- Contains only `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`. It ships in the
  app, the widget and the notification service extension (three `PBXBuildFile` entries).
- `CA92.1` fits: the shared defaults use the suite `dev.neoneon.btlb.userdefaults` (not an App
  Group), and the recommender stores its App Attest key ID in `UserDefaults.standard`.
- I didn't find other required-reason APIs (file timestamps, system boot time, disk space, active
  keyboards) in the app's Swift code. The Rust `paper` library and third-party Swift packages
  weren't audited for this.
- It has no `NSPrivacyTracking` / `NSPrivacyCollectedDataTypes` keys. That's not an error.
  Optionally add `NSPrivacyTracking = false` and the collected data types to match the App Privacy
  answers above. Not required for this release.

---

## 5. Other submission checks

### Export compliance

- `BTLB-Info.plist`: `ITSAppUsesNonExemptEncryption = false`, so App Store Connect won't ask.
- In the Swift code: HTTPS via `URLSession`, CryptoKit SHA-256 (hashing for App Attest payloads)
  and App Attest / DeviceCheck. All of these count as exempt.
- **Check:** the Rust `paper` crate uses `reqwest 0.11` (default `native-tls`, which uses Apple's
  Security framework on iOS). `paper` still depends on `async-openai 0.43` for its old OpenRouter
  `Recommender` (`paper/src/api/recommender.rs`, exported via UniFFI). That pulls in
  `reqwest 0.13` with `rustls` / `aws-lc-rs` / `ring` (`Cargo.lock`). The app no longer calls that
  recommender since #37. I couldn't build here to see whether that code ends up in the binary.
  These are standard algorithms used only for TLS, so `false` is most likely still right. Removing
  `async-openai` and the old recommender from `paper` would remove the dead code and the extra TLS
  stack (follow-up in q231950/paper).

### Minimum iOS

- **iOS 26.0** for app and extensions (was 17.2 for 2.29.0). People on iOS 17/18 keep 2.29.0
  and won't get 2.30.0. Make sure that's intended. The code uses iOS 26 APIs
  (`tabViewSearchActivation`, search tab role), so lowering it isn't a quick change.

### Screenshots

- `AppStore Screenshots/` dates from Feb/Mar 2023 (iPhone 8 Plus 5.5", iPhone 14 Plus 6.5",
  iPad Pro 12.9" 2nd/6th gen). They predate the Accounts tab, the iOS 26 search tab and the
  iOS 26 look, so **they're outdated**. Apple currently needs 6.9" iPhone and 13" iPad
  screenshots (or accepts scaled-down ones). Check App Store Connect's current requirements.
- fastlane snapshot setup is outdated too. `fastlane/Snapfile` lists "iPhone 8 Plus",
  "iPhone 13 Pro Max" and "iPad Pro (12.9-inch) (5th generation)", which can't run iOS 26. A
  second `Snapfile` in the repository root uses another device list and scheme. Both use the
  `BTLBSnapshots` scheme or `BTLBUITests`. The demo account (#36) is a good way to make new
  screenshots with realistic data.

### What ships in the binary

- App `com.elbedev.sync` (iPhone + iPad, portrait on iPhone, all orientations on iPad).
- Widget extension `com.elbedev.sync.widget`: Lock Screen (circular, rectangular), small, medium,
  large widgets (`BTLBWidget/BTLBWidgetBundle.swift`).
- Notification service extension `com.elbedev.sync.BTLBNotificationService`.
- App Intents / App Shortcuts: `PerformSearchIntent` ("Search in BTLB") and `RenewItemsIntent`
  ("Renew with BTLB" and variants), `Intents/BTLBShortcutsProvider.swift`.
- Core Spotlight indexing of loans, background refresh (`dev.neoneon.btlb.refresh`, background
  modes fetch / processing / remote-notification), alternative app icon, associated domain
  `applinks:neoneon.dev`, URL scheme `btlb://`.
- Entitlements (`Entitlements/BTLB.entitlements`): push (`aps-environment` development, which
  Xcode switches to production on export), App Attest (`appattest-environment` development, which
  App Store / TestFlight builds ignore and use production), App Group `group.com.elbedev.sync`,
  iCloud KVS, Keychain group, data protection.
- **Check:** #37 asked for the **App Attest capability to be enabled on the App ID** in the
  developer portal. Without it, signing or attestation fails. Not verifiable from the repository.
- `NSAllowsArbitraryLoads = true` (some library endpoints are plain HTTP, e.g. a `bibliomondo.com`
  URL). App Review rarely asks about it, but have a one-line reason ready ("library servers that
  don't support HTTPS").

### Localizations

- String catalogs have **en, de, es, fr, tr, uk** (#21 added es/fr/tr/uk since 2.29.0).
  `InfoPlist.xcstrings` has them too. No Russian.
- The project's `knownRegions` lists only `en`, `de`, `Base`. **Check** in the built `.ipa` or in
  TestFlight / App Store Connect that es, fr, tr and uk are listed as app languages.
- App Store metadata exists in the repository for **en and de only**
  (`Documentation/AppStoreDescription/`). To add es/fr/tr/uk product pages you need descriptions,
  keywords and screenshots for them. Otherwise those storefronts show the primary language. The
  What's New texts above are ready for all six.
- `AppShortcuts.strings` exists for en and de only (`en.lproj`, `de.lproj`). Siri phrases in
  es/fr/tr/uk fall back to the primary language.

---

## 6. Pre-submission checklist

- [ ] Merge `release-2.30.0-prep` into `main`. Archive 2.30.0 with Xcode Cloud from `main` (contains #39)
- [ ] Note the build number Xcode Cloud assigned; tag the release (e.g. `v2.30.0`)
- [ ] Xcode Cloud workflow: delete the old `OPEN_ROUTER_API_KEY` environment variable (#37)
- [ ] Developer portal: App Attest capability enabled on `com.elbedev.sync` (#37)
- [ ] neoneon.dev: recommender up, accepting production App Attest keys; push token endpoint up
- [ ] TestFlight on a real iOS 26 device: demo sign-in, renew, refresh, search (Berlin), bookmark, AI recommendations, widget
- [ ] Revoke / rotate the **old OpenRouter API key** that shipped inside 2.28.0 / 2.29.0 (it was in the app bundle, see #37). Anyone can extract it from those binaries
- [ ] Native-speaker check of es / fr / tr / uk What's New texts
- [ ] Paste What's New for every language in App Store Connect
- [ ] App Review Information: sign-in `demo` / `demo`, paste the review notes, contact details
- [ ] App Privacy answers and privacy policy URL match section 4
- [ ] New screenshots (6.9" iPhone, 13" iPad) showing the Accounts tab and the search tab
- [ ] App Store description: `Documentation/AppStoreDescription/` (#34) pasted for en / de; decide on es / fr / tr / uk
- [ ] Export compliance: `ITSAppUsesNonExemptEncryption = false` (no question in App Store Connect)
- [ ] Confirm the minimum iOS 26.0 is intended

---

## 7. Open questions and risks

1. **Default search library is "Hamburg – Bücherhallen", which is disabled for search.**
   `LibraryManager` uses `HAMBURGPUBLIC` as `defaultSearchLibraryIdentifier` until the user picks
   another library. Paper marks it `enabled_for_search: false` (and `enabled_for_login: false`).
   Searching it still goes to the Bücherhallen scraper. So on a fresh install, a reviewer who
   searches without choosing a library may get errors or no results. The review notes tell them
   to choose Berlin first. Consider changing the default to `BERLIN` (it's the library the release
   and description highlight).
2. **Login library selection text mentions the Bücherhallen,** although Bücherhallen sign-in is
   disabled ("Currently you can login to libraries of _Stiftung Hamburger Öffentliche
   Bücherhallen_ …", `LibrarySelectionView.swift`). The German version of this login text also
   starts with "Derzeit unterstützt die Suche …", which talks about search, not login. A reviewer
   may be confused.
3. **UI test `test_demoAccount` probably can't pass.** It signs in at "Bücherhallen Hamburg",
   which is disabled for login. The row's label is also "Hamburg" / "Stiftung Hamburger
   Öffentliche Bücherhallen", not "Bücherhallen Hamburg". Not run here (needs Xcode and a
   simulator).
4. **Old OpenRouter key** in 2.28.0 / 2.29.0 binaries. Rotate it if that hasn't happened
   (checklist).
5. **Dead OpenRouter code in `paper`** (`async-openai`, `Recommender` with `api_key`). It's unused
   by the app, but it ships if it's linked, and it brings an extra TLS stack (section 5).
6. **AI recommender is on by default and sends titles without asking first** (section 4,
   guideline 5.1.2(i)).
7. **Minimum iOS jump 17.2 → 26.0** isn't in the changelog. Intended?
8. **Stale values in `BTLB-Info.plist`:** `GitBranch = main`, `GitCommit = e1203fb` are hard-coded
   (from 2.29.0), and `NSHumanReadableCopyright` says 2024. Cosmetic.
9. **Screenshots and Snapfiles outdated** (section 5).
10. **`v2.30.0rc1` tag doesn't include #39.** Don't submit a build made from that tag.

Things I could not verify here: building or running the app or tests (no Xcode or simulator on this
machine), the Xcode Cloud workflow settings, App Store Connect and developer portal state, the
neoneon.dev server and OpenRouter retention settings.
