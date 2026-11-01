#!/bin/sh

# Allow Xcode Plugins on ci
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

# Prepare Build
mv ../Secrets.sample.xcconfig ../Secrets.xcconfig

# Install Dependencies
brew install rust

cargo install cargo-swift@^0.9.0 --force --locked

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

# Make the Paper Swift Package
cd ../Packages/shared/paper
make prepare-apple
cd paper
make apple-release
make_status=$?

# Diagnostics for the Paper Swift Package, e.g. when Paper.swift cannot find RustBuffer
echo "=== Paper diagnostics ==="
sw_vers
xcodebuild -version
rustc --version
cargo --version
cargo swift --version
echo "--- Paper commit"
git -C .. rev-parse HEAD
echo "--- cargo-swift output"
find generated Paper/RustFramework.xcframework -print
echo "--- RustFramework.xcframework"
find paper-package/RustFramework.xcframework -print
plutil -p paper-package/RustFramework.xcframework/Info.plist
find paper-package/RustFramework.xcframework -iname '*.modulemap' | while read -r modulemap; do
    echo "--- $modulemap"
    cat "$modulemap"
    echo
done
echo "--- Headers declaring RustBuffer"
grep -rl "typedef struct RustBuffer" paper-package/RustFramework.xcframework
echo "--- Paper.swift"
ls -l paper-package/Sources/Paper
grep -n "canImport\|^import" paper-package/Sources/Paper/Paper.swift
echo "=== End of Paper diagnostics ==="

# keep failing the build when making the package failed
exit $make_status
