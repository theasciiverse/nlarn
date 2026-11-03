#!/bin/sh
# Packs NLarn into its archive for av: dist/nlarn-<target>.tar.gz, with
# the binary, lib/ beside it (NLarn looks there first), and the licence,
# README, changelog and PATCHES.md. On macOS, out/libs/ (bundled dylibs)
# goes in as well.
#
#   asciiverse/package.sh x86_64-unknown-linux-musl
set -eu
cd "$(dirname "$0")/.."
target="$1"
stage="stage/nlarn"
rm -rf "$stage" && mkdir -p "$stage" dist
cp out/nlarn LICENSE README.md Changelog.md PATCHES.md "$stage/"
cp -r out/lib "$stage/lib"
[ -d out/libs ] && cp -r out/libs "$stage/libs"
tar --owner=0 --group=0 --numeric-owner -czf "dist/nlarn-$target.tar.gz" -C "$stage" . 2>/dev/null \
  || tar -czf "dist/nlarn-$target.tar.gz" -C "$stage" .
ls -l dist
