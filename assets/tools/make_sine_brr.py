#!/usr/bin/env python3
"""make_sine_brr.py — generate a 9-byte single-block sine BRR sample.

This is the script that produces exercises/ch13_first_sound/assets/sine.brr.
It's checked in for reproducibility — if you ever need to regenerate the
asset (for instance, to vary the amplitude or frequency), edit and rerun.

Usage:
    python3 make_sine_brr.py [output_path]

If no output path is given, writes to stdout (raw bytes — pipe to a file).

The encoding is deliberately simple:
- Filter 0 (no prediction) for safety and ease of inspection.
- Shift 0 (no scaling) for the same reasons.
- Single block of 16 samples = one full sine cycle.
- LOOP and END flags both set, so the block plays continuously.
"""

import math
import sys


SAMPLES_PER_BLOCK = 16
PEAK_AMPLITUDE = 6  # signed 4-bit range is -8..+7; 6 leaves headroom


def main() -> None:
    samples = [
        int(round(PEAK_AMPLITUDE * math.sin(2 * math.pi * i / SAMPLES_PER_BLOCK)))
        for i in range(SAMPLES_PER_BLOCK)
    ]

    # Pack 16 nibbles into 8 bytes, high nibble first.
    data_bytes = []
    for i in range(0, SAMPLES_PER_BLOCK, 2):
        high = samples[i] & 0x0F
        low = samples[i + 1] & 0x0F
        data_bytes.append((high << 4) | low)

    # Header: shift=12, filter=0, loop=1, end=1  =>  0b11000011  =>  0xC3
    #
    # The shift field scales the decoded nibbles by 2^shift. Shift 0 (which
    # we used in an earlier draft) leaves the nibbles in their raw -8..+7
    # range, producing a waveform so quiet that the SNES output is
    # essentially silent. Shift 12 multiplies by 4096, which lifts the
    # waveform into the comfortably-audible range without saturating.
    # fullsnes notes that shifts 13-15 are special and encoders should
    # avoid them; 12 is the highest "safe" shift.
    header = 0xC3

    brr = bytes([header] + data_bytes)
    assert len(brr) == 9

    if len(sys.argv) > 1:
        with open(sys.argv[1], "wb") as f:
            f.write(brr)
        print(f"Wrote {len(brr)} bytes to {sys.argv[1]}", file=sys.stderr)
    else:
        sys.stdout.buffer.write(brr)


if __name__ == "__main__":
    main()
