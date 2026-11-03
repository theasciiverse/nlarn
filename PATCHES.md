# Asciiverse changes

Upstream: Joachim de Groot's NLarn, github.com/nlarn/nlarn (GPL-3.0-or-later),
remote `upstream`, branch `master` at `743abac` (2026-10-03): the 0.8.0
release of 2026-09-05 and 17 commits since (faster path-finding, a better
field of view, saved games robust against item changes, fixes). Upstream
calls this 0.8.1 in development; the game shows `0.8.1-g<commit>`. Our
work is on the `asciiverse` branch. We build NLarn's terminal (ncurses)
edition; its SDL window edition is not built.

NLarn already finds its data in `lib/` beside its binary, then in
`/usr/share/nlarn`, and keeps settings and saves in `~/.nlarn`, which is
how av and the system packages lay it out, so no change was needed there.

## Changes

- **Warnings stay warnings** (`Makefile`): upstream builds with `-Werror`, so a
  new warning from a newer compiler stops the build. On ARM, where `wchar_t`
  is unsigned, GCC 14 warns about comparing a glyph with an `int` key
  (`display.c`) and the release build failed. Release builds drop `-Werror`,
  as distributions usually do; the warnings are still shown.
- **Builds against macOS's ncurses 5.7** (`inc/display.h`): it has no
  `BUTTON5_PRESSED` (the wheel turned down), which `display.c` uses; it is
  defined as 0 there, so the wheel scrolls only up on macOS.
- **Builds with musl** (`src/nlarn.c`): the crash handler and the
  assertion handler printed a backtrace with glibc's `execinfo.h`, which
  musl does not have; that part is now used only where the header exists.
  Elsewhere the handlers do everything as before, without the backtrace.
- **Upstream's `.github/workflows/build.yml` is replaced by our
  `release.yml`**: upstream's runs on every tag created and publishes its
  builds to that tag's release.

## Building

`asciiverse/build.sh` (`STATIC=1` in Alpine for the static musl binary)
builds `out/nlarn` with upstream's Makefile (`config=release`) and
`out/lib/` with the help, messages, fortunes, maze file and the compiled
translations (German, Spanish, French, Portuguese);
`asciiverse/package.sh <target>` makes the av archive;
`.github/workflows/release.yml` builds Linux x86_64 and aarch64 on a
`v<version>-av.<n>` tag, with .deb, .rpm, .apk and Arch packages
(`asciiverse/nfpm.yaml`), and tries macOS with Homebrew's glib bundled
beside the binary.
