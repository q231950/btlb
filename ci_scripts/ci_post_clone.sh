#!/bin/sh

mv ../Secrets.sample.xcconfig ../Secrets.xcconfig

brew install rust

cargo install cargo-swift@^0.9.0 --force --locked

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

cd ../Packages/shared/paper

make prepare-apple

cd paper

make apple-release
