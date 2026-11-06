# BTLB

> synchronise your library account on your iOS device

## Build the App

**AI recommender**

The recommender runs on neoneon.dev (`q231950/neoneon`, `docs/btlb-recommender-api.md`): the app
sends the titles of the selected bookmarks and gets back up to three recommendations. Requests are
signed with **App Attest**, so the server only serves genuine BTLB installs.

- App Attest doesn't work in the Simulator; the recommender is hidden there. Test on a device.
- Xcode-signed builds attest in Apple's sandbox (the `appattest-environment` entitlement is
  `development`). neoneon accepts those keys only while `APP_ATTEST_ALLOW_DEVELOPMENT=true` is set
  on the server. TestFlight and App Store builds always use production.
- The client lives in `Packages/Bookmarks/Sources/Bookmarks/AI/Neoneon/`. `RecommenderAPI` must
  match the server's contract byte for byte; `NeoneonRecommenderTests` asserts the shared fixture.

**Build the `paper` library**

```shell
# Navigate to the paper directory and install the Rust toolchain
cd Packages/shared/paper
make prepare-apple
```

Whenever the Rust `paper` library is updated:

```shell
cd Packages/shared/paper/paper

# then either build the `Paper` Swift Package to use the Rust `paper` library from iOS during development
make apple

# or include release version of `paper` in the `Paper` Swift Package
make apple-release
```

## App Icon

### Generate new icon set

`bundle exec icongen generate app-icon/appicon-v3-alt-black.pdf Assets.xcassets --type=iphone,ipad`

## App Store Snapshots

`brew install fastlane`

`fastlane snapshot`
