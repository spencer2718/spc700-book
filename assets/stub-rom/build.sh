#!/bin/sh
# build.sh — assembles the stub ROM with an embedded SPC payload.
#
# Usage:
#   ./build.sh path/to/spc_payload.bin
#
# Produces:
#   stub.sfc — a 256 KiB SNES ROM ready to load in Mesen2.
#
# If no payload is given, builds with a 1-byte placeholder ($FF =
# STOP), useful for sanity-checking the stub ROM itself.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

PAYLOAD="${1:-}"

if [ -z "$PAYLOAD" ]; then
    printf '\xFF' > spc_payload.bin
    echo "No payload provided; using 1-byte placeholder (STOP)."
elif [ ! -f "$PAYLOAD" ]; then
    echo "Error: payload file '$PAYLOAD' does not exist." >&2
    exit 1
else
    cp "$PAYLOAD" spc_payload.bin
    echo "Embedding payload: $PAYLOAD ($(wc -c < spc_payload.bin | tr -d ' ') bytes)."
fi

PAYLOAD_SIZE=$(wc -c < spc_payload.bin | tr -d ' ')

if [ "$PAYLOAD_SIZE" -gt 60000 ]; then
    echo "Error: payload is $PAYLOAD_SIZE bytes; max is 60000." >&2
    rm -f spc_payload.bin
    exit 1
fi

asar -werror -DPAYLOAD_SIZE=$PAYLOAD_SIZE stub.asm stub.sfc

ROM_SIZE=$(wc -c < stub.sfc | tr -d ' ')
echo "Built stub.sfc ($ROM_SIZE bytes)."

if [ "$ROM_SIZE" -ne 262144 ]; then
    echo "Warning: ROM size is $ROM_SIZE bytes; expected 262144 (256 KiB)." >&2
    echo "  This usually means stub.asm's padding directive needs tuning." >&2
fi

# Clean up the intermediate copy.
rm -f spc_payload.bin
