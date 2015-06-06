#!/bin/bash

set -e
set -x

export AR_mips_unknown_linux_gnu=mips-openwrt-linux-ar
export CC_mips_unknown_linux_gnu=mips-openwrt-linux-gcc

cd rust/src
cargo new --bin hello
cd hello
mkdir .cargo
cat >.cargo/config <<EOF
[target.mips-unknown-linux-gnu]
ar = "mips-openwrt-linux-ar"
linker = "mips-openwrt-linux-gcc"
EOF
cat >>Cargo.toml <<EOF
[dependencies.std]
path = "../libstd"
EOF

if [[ $BACKTRACE = yes && $JEMALLOC = yes ]]; then
    echo 'features = ["backtrace", "jemalloc"]' >> Cargo.toml
elif [[ $BACKTRACE = yes && $JEMALLOC = no ]]; then
    echo 'features = ["backtrace"]' >> Cargo.toml
elif [[ $BACKTRACE = no && $JEMALLOC = yes ]]; then
    echo 'features = ["jemalloc"]' >> Cargo.toml
fi

cat >>Cargo.toml <<EOF
[profile.release]
lto = true
EOF
cat Cargo.toml
cargo rustc --target=mips-unknown-linux-gnu --release -- -C link-args=-s
ls -hl target/mips-unknown-linux-gnu/release/hello
