# sine.brr — a minimal looping sine wave BRR sample

This is a **9-byte BRR file** containing one block (16 samples) of a
sine wave with the LOOP and END flags set, so the sample loops on
itself indefinitely.

## Specifications

- **Length:** 9 bytes (the smallest possible BRR sample — exactly
  one block).
- **Header byte:** `$C3`
  - Shift: 12 (decoded nibbles shifted left 12 bits → samples in
    the range −24576..+24576, comfortably audible)
  - Filter: 0 (no prediction; safest)
  - Loop: 1 (loop when END is reached)
  - End: 1 (this is the last block; with Loop=1, the decoder
    jumps back to the loop point)
- **Data bytes:** `$02 $46 $66 $42 $0E $CA $AA $CE`
- **Decoded nibbles (signed 4-bit, before shift):**
  `0, 2, 4, 6, 6, 6, 4, 2, 0, -2, -4, -6, -6, -6, -4, -2`
- **Decoded samples (after shift 12):**
  `0, 8192, 16384, 24576, 24576, 24576, 16384, 8192,
  0, -8192, -16384, -24576, -24576, -24576, -16384, -8192`
- **Cycle:** one full sine cycle per block of 16 samples.

## Why shift 12 and not shift 0

An earlier draft of this file used shift 0, which leaves decoded
nibbles in their raw −8..+7 range. That's audible only as faint hiss
through speakers; it's far below the SNES's normal output level. The
BRR shift field exists precisely to scale samples up into the audible
range, and skipping it is a common mistake when hand-encoding BRR.

Shift 12 multiplies nibbles by 2^12 = 4096, lifting peak amplitude
to ±24576, which is well within the 16-bit decoder's ±32767 range
and produces a clean, loud sine. fullsnes notes that shifts 13–15
are special-cased in the hardware and encoders normally avoid them;
12 is the highest "safe" shift.

## Frequency at the SPC's native rate

When played with pitch register = `$1000` (native rate, ~32000 Hz),
the audible frequency is:

```
freq = sample_rate / cycle_length = 32000 Hz / 16 samples = 2000 Hz
```

A 2 kHz tone is well within the audible range, easy to hear on any
speaker, and not so high or low that EQ or headphone differences
will mask it.

## Avoiding the Gaussian interpolation pop

The S-DSP's Gaussian interpolation has a known overflow bug when
three consecutive maximum-negative samples (each −32768) appear in
the interpolation window. Our peak amplitude after shift is −24576,
not −32768, which steers clear of this case. Don't push peak
amplitude higher without checking.

## Limitations

This sample is deliberately the simplest thing that will produce a
recognizable tone:

- **Quantized to 4-bit precision** (before shift). Resolution is
  coarse — 16 levels with fixed spacing of 4096 in the 16-bit
  decoded space.
- **No envelope shape.** The sample is a pure sustained tone; the
  ADSR envelope is what gives the note its attack and release.
- **Single block only.** Real instrument samples have a multi-block
  attack followed by a looped sustain portion.
- **Filter 0 only.** Prediction filters give better fidelity for
  similar block counts but introduce cross-block dependencies that
  complicate hand-encoding.

For Chapter 13's exercise, none of these limitations matter — the
sample is meant to prove the audio path works, not to sound good.

## How it was generated

`tools/make_sine_brr.py` produces this file deterministically.
Re-running the script will produce byte-identical output.

## Memory layout when loaded

When loaded into ARAM at address `$2100` (the convention used by
the Chapter 13 exercise), the byte layout is:

```
$2100:        $C3                    ; header (shift 12, filter 0, loop, end)
$2101-$2108:  $02 $46 $66 $42 $0E $CA $AA $CE
```

The corresponding sample directory entry (at `$2000`, with
SRCN = 0) is:

```
$2000-$2001:  $00 $21                ; start = $2100
$2002-$2003:  $00 $21                ; loop  = $2100
```
