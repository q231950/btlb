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
