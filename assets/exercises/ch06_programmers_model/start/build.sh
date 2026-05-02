#!/bin/sh
# build.sh — assemble the Chapter 6 SPC payload.
set -e
asar -werror programmers_model.asm programmers_model.bin
echo "Built programmers_model.bin ($(wc -c < programmers_model.bin | tr -d ' ') bytes)."
