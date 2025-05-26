#!/bin/sh

brew install rust

cargo install cargo-swift --force --locked

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

cd ../Packages/shared/paper

make prepare-apple

cd paper

# make apple
make apple-release
