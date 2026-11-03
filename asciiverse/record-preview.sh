#!/bin/sh
# Records the catalog preview, asciiverse/nlarn.cast, to hub/RECORDING.md
# (100x30) with hub's scripted recorder: the story, a new game (name,
# gender and a strong build preset in nlarn.ini), the walk across town to the caverns by auto-travel (v O), down
# the entrance (>), and a first look round the dark caverns at a person's
# pace. Plays the packaged build (dist/nlarn-<target>.tar.gz) with a
# throwaway HOME.
#
#   asciiverse/package.sh x86_64-unknown-linux-musl && asciiverse/record-preview.sh [castrec.py]
set -eu
cd "$(dirname "$0")/.."
rec=${1:-../../hub/tools/castrec.py}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/game" "$tmp/home"
tar -xzf dist/nlarn-x86_64-unknown-linux-musl.tar.gz -C "$tmp/game"
# name, gender and build preset, so the new game asks nothing
mkdir -p "$tmp/home/.nlarn"
printf '[nlarn]\nname=Player\ngender=m\nstats=a\n' > "$tmp/home/.nlarn/nlarn.ini"
python3 "$rec" asciiverse/nlarn.cast "$tmp/game" \
  "w4;kenter;w1.5;sa;w2.5;sv;w0.8;sO;w1.2;kenter;w4;s>;w2.5;r4:j:0.45;r4:l:0.45;r3:k:0.45;r5:h:0.45;r3:j:0.45;r4:l:0.45;r3:u:0.45;r4:l:0.45;r3:n:0.45;r4:h:0.45;w3" \
  -- env HOME="$tmp/home" LANG=C.UTF-8 ./nlarn
# the recorder stops the game at the end, and NLarn answers with
# "Terminated. Your progress has been saved."; cut that from the cast so
# it ends on the cavern
python3 - asciiverse/nlarn.cast <<'PY'
import json, sys
path = sys.argv[1]
lines = open(path).read().splitlines()
head, events = lines[0], [json.loads(l) for l in lines[1:] if l.strip()]
while events and (events[-1][1] != "o" or "Terminated" in events[-1][2] or not events[-1][2].strip("\r\n")):
    events.pop()
# whatever reset the screen on the way out goes too
while events and events[-1][1] == "o" and "\x1b[?1049l" in events[-1][2]:
    events.pop()
events.append([2.0, "o", ""])
with open(path, "w") as f:
    f.write(head + "\n")
    for e in events:
        f.write(json.dumps(e) + "\n")
PY
