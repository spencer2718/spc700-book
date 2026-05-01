#!/bin/sh
# build.sh — assemble the Chapter 5 SPC payload.
set -e
asar -werror hello.asm hello.bin
echo "Built hello.bin ($(wc -c < hello.bin | tr -d ' ') bytes)."
