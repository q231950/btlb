# Localization Guide

## General Guidelines

- Translations will be used in a library management app by end users
- Translations use appropriate library management terminology
- Translations do not use slang
- Do not remove any existing translations or keys
- Look into the localization comment if it makes sense to get further information about the semantics of the string that should be translated
- Only take the following files into account, only edit the following files:
  - AppIntents.xcstrings
  - InfoPlist.xcstrings
  - Packages/BTLBIntents/Sources/BTLBIntents/Resources/Localizable.xcstrings
  - Packages/Loans/Sources/Loans/Resources/Localizable.xcstrings
  - Packages/LibraryUI/Sources/LibraryUI/Resources/Localizable.xcstrings
  - Packages/BTLBSettings/Sources/BTLBSettings/Resources/Localizable.xcstrings
  - Packages/Charges/Sources/Charges/Resources/Localizable.xcstrings
  - Packages/Libraries/Sources/Libraries/Resources/Localizable.xcstrings
  - Packages/More/Sources/More/Resources/Localizable.xcstrings
  - Packages/Search/Sources/Search/Resources/Search.xcstrings
  - Packages/Bookmarks/Sources/Bookmarks/Localizable.xcstrings
  - Packages/Accounts/Sources/Accounts/Resources/Localizable.xcstrings
  - Packages/Localization/Sources/Localization/Resources/Localizable.xcstrings
  - StringTables/Loans.xcstrings
  - StringTables/ActivityAndMessages.xcstrings
  - StringTables/Recommend.xcstrings
  - StringTables/Accessibles.xcstrings
  - StringTables/Imprint.xcstrings
  - StringTables/Favourites.xcstrings
  - StringTables/Applicationwide.xcstrings
  - StringTables/Summary.xcstrings
  - StringTables/Catalogue.xcstrings
  - StringTables/Tabbar.xcstrings

## Decision Making

If 2 translations are equally matching the original string, describe the differences and ask which one to use. Do not decide yourself.

Once done localizing, check each localization file for correctness and completeness. Ensure that all strings are translated accurately and that the translations are consistent with the original text. Verify that all necessary strings are present and that there are no missing translations.
