# BTLB

> synchronise your library account on your iOS device

## Build the App

Initial setup:
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
