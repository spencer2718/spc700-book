# Chapter 13: Voices, Pitch, and Envelopes — First Sound

This is the chapter where the SPC makes a sound for the first time.
After 12 chapters of explanation about a chip you couldn't hear, you
finally hear it.

## What you'll do

Configure voice 0 of the S-DSP to play a 2 kHz sine wave at full
volume, with a fast attack and an indefinite sustain. You'll then
hear that sine wave when you load the ROM in Mesen2.

## The exercise

The starter file `start/first_sound.asm` does almost everything for
you. The reset, the master volume setup, and the voice's source
selection / volume / ADSR are all pre-written. There are **three
TODO blocks** in the configuration section that you need to
complete:

1. Set the sample directory page (DIR) to `$20`. Three instructions.
2. Set voice 0's pitch to native rate (`$1000`). Six instructions
   (two DSP writes, one for PITCHL and one for PITCHH).
3. Issue the key-on command for voice 0. Three instructions.

The chapter text walks you through each one. Refer to it as needed;
the comments in the starter file also point at the relevant
sections.

## Build

```sh
cd exercises/ch13_first_sound/start
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch13_first_sound/start/first_sound.bin
```

You now have `stub-rom/stub.sfc`. Load that file in Mesen2.

## Run

1. Open `stub.sfc` in Mesen2.
2. Make sure your audio is on at a comfortable volume — not too
   high. The 2 kHz sine is loud and steady.
3. The sound should start shortly after you load the ROM (the IPL
   upload takes some time, then the SPC runs the setup) and
   continue indefinitely.

If you hear a steady tone: success. If you hear silence, walk
through the debugger checks below.

## Debugger walkthrough

If something doesn't work, this is the systematic check. Open the
SPC debugger and the DSP register view. Mesen2 has a separate
window for DSP registers; exact menu placement may vary by version.

After the IPL upload completes and your payload runs the setup,
check these registers in order. If any one is wrong, that's where
the bug is.

| Register     | Should be | If different...        |
|--------------|-----------|------------------------|
| `$0C` MVOLL  | `$7F`     | Setup never happened   |
| `$1C` MVOLR  | `$7F`     | Setup partial          |
| `$6C` FLG    | `$20`     | Mute or echo-disable wrong |
| `$5D` DIR    | `$20`     | TODO 1 incomplete      |
| `$00` V0VOLL | `$7F`     | Voice volume zero      |
| `$01` V0VOLR | `$7F`     | Voice volume zero      |
| `$02` V0PITCHL | `$00`   | TODO 2 incomplete      |
| `$03` V0PITCHH | `$10`   | TODO 2 incomplete      |
| `$04` V0SRCN | `$00`     | Sample source wrong    |
| `$05` V0ADSR1| `$8F`     | ADSR not enabled       |
| `$06` V0ADSR2| `$E0`     | Sustain not set        |

After the key-on (DSP `$4C` KON):

| Register     | Should be              | If different...        |
|--------------|------------------------|------------------------|
| `$08` V0ENVX | rising from $00 to $7F | Voice didn't key on    |
| `$09` V0OUTX | non-zero, oscillating  | Keyed on but no sample |

If `ENVX` rises and `OUTX` oscillates but you still hear nothing,
the issue is in the emulator's audio settings, not your code.

## Why FLG = $20 and not $00

You'll notice the unmute write sets FLG to $20, not $00. $00 would
clear MUTE *and* re-enable echo writes. We don't have echo
configured, and SNESdev's errata note that with EDL=0, the DSP
will continuously overwrite a few bytes at ESA — and since we
never set ESA, ESA defaults to $00, which means the DSP would
overwrite ARAM `$0000-$0003` (zero page) on every echo cycle.
That's a real hazard.

$20 keeps bit 5 (echo write disable) set, so no echo writes happen.
Bit 6 (MUTE) and bit 7 (RESET) are clear, so output flows normally.

## Why each step matters

The exercise sets up the absolute minimum to make a single voice
play a single sample:

1. **Master volume** must be non-zero.
2. **MUTE** in FLG must be cleared (and ECHO WRITE DISABLE kept set
   while we have no echo configured).
3. **DIR** must point at the sample directory's actual location.
4. **V0SRCN** must select the sample.
5. **V0VOLL/VOLR** must be non-zero or the voice contributes nothing.
6. **V0PITCH** controls how fast the sample plays.
7. **V0ADSR1/ADSR2** define the envelope; without ADSR enabled and
   sensible attack/decay rates, the envelope stays at zero.
8. **KON** is what actually starts the voice playing.

Forgetting any single one means silence.

## After this exercise

You should be able to:

- Configure voice parameters using the DSP register window.
- Set up a sample directory and point a voice at a sample.
- Trigger a key-on and observe the envelope rise.
- Diagnose "no sound" by walking the DSP register checklist.

The next chapter (BRR Samples) goes deeper into how the sample
data itself is encoded. After that, you'll be encoding your own
samples.
