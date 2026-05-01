#!/bin/sh
# build.sh — assemble the Chapter 13 SPC payload.
#
# Asar's `incbin` resolves paths relative to the source file's
# directory. The BRR sample lives in ../assets/sine.brr; we copy
# it locally before assembly and clean it up afterward so the
# starter source can use a simple `incbin "sine.brr"`.

set -e

cp ../assets/sine.brr ./sine.brr

asar -werror first_sound.asm first_sound.bin

echo "Built first_sound.bin ($(wc -c < first_sound.bin | tr -d ' ') bytes)."

rm -f sine.brr
