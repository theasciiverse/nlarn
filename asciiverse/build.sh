#!/bin/sh
# Builds NLarn's terminal (ncurses) edition and its translations: out/nlarn
# and out/lib/ (help, messages, fortunes, the maze file, and compiled
# message catalogs in lib/locale), the layout NLarn looks for beside its
# binary. Uses upstream's Makefile (config=release).
#
#   asciiverse/build.sh            # Debian, Ubuntu
#   STATIC=1 asciiverse/build.sh   # Alpine: static musl binary
#   asciiverse/build.sh            # macOS with Homebrew glib and ncurses
#                                    (then bundle the dylibs, see the workflow)
set -eu
cd "$(dirname "$0")/.."
jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)
# let git describe this checkout even when it belongs to another user (a
# container's mounted folder), for the version shown in the game; set for
# this build only, not in any git config file
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0="$PWD"
make clean >/dev/null 2>&1 || true
if [ -n "${STATIC:-}" ]; then
  # link glib (and what it needs), ncurses and zlib statically
  libs="$(pkg-config --static --libs glib-2.0 ncursesw panelw) -lintl -lz -lm"
  make config=release -j"$jobs" nlarn LDFLAGS="-static -s $libs"
else
  make config=release -j"$jobs" nlarn
fi
pos=$(ls po/*.po 2>/dev/null || true)
for po in $pos; do
  lang=$(basename "$po" .po)
  mkdir -p "lib/locale/$lang/LC_MESSAGES"
  msgfmt -o "lib/locale/$lang/LC_MESSAGES/nlarn.mo" "$po"
done
rm -rf out && mkdir -p out/lib
cp nlarn out/
cp lib/fortune* lib/maze lib/maze_doc.txt lib/nlarn.* out/lib/
[ -d lib/locale ] && cp -r lib/locale out/lib/
echo "built nlarn"
