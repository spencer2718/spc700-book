# ARAM Memory Map

This is the canonical layout used across all exercises in this
repository. As you progress through the book, more regions become
populated; the layout itself stays consistent.

```
$0000-$00EF   Direct page (driver variables)
$00F0-$00FF   Hardware I/O (TEST, CONTROL, DSPADDR, DSPDATA, mailboxes, timers)
$0100-$01FF   Stack
$0200-$1FFF   SPC payload code (~7.5 KiB)
$2000-$20FF   Sample directory (256 bytes; up to 64 entries)
$2100-$BFFF   BRR sample data and sequence data (~40 KiB)
$C000-$FFFF   Echo buffer (when EDL = 8; smaller buffers free space)
                Note: $FFC0-$FFFF is IPL ROM until you hide it via $F1
```

## Direct-page allocations

The exercises use the following direct-page byte names. Each exercise
file will `incsrc` a `dp_map.inc` that defines them so you can write
`mov a, last_cmd` instead of `mov a, $00`.

| Address  | Name              | Purpose                                |
|----------|-------------------|----------------------------------------|
| `$00`    | `last_cmd`        | Last command counter from main CPU     |
| `$01`    | `tick_counter`    | Ticks elapsed since last music advance |
| `$02-$03`| `pitch_temp`      | Scratch 16-bit pitch value             |
| `$04`    | `kon_shadow`      | Voices to key on this tick             |
| `$05`    | `koff_shadow`     | Voices to key off this tick            |
| `$06`    | `dirty_flags`     | Per-voice "needs DSP write" bits       |
| `$10-$11`| `seq_ptr`         | Pointer into current sequence row      |
| `$12-$13`| `aux_ptr`         | General-purpose pointer                |
| `$20-$2F`| `voice_state[]`   | 2 bytes × 8 voices: cached pitch       |
| `$30-$3F`| (reserved)        | Per-voice envelope phase tracking      |
| `$40-$4F`| (reserved)        | Per-voice volume                       |
| `$50-$5F`| (reserved)        | Per-voice instrument number            |
| `$60-$6F`| (reserved)        | Sequence advance state                 |
| `$70-$EF`| (free)            | Available for additional state         |

The book introduces these names a few at a time, only as needed.
You will not need most of them for the early exercises.

## ARAM allocation strategy

The exercises avoid using addresses above `$8000` until the chapter
on echo (Chapter 15) introduces the echo buffer. This keeps the
memory map simple while you're learning. From Chapter 15 onward, the
echo buffer reserves `$C000-$FFFF` (8 KiB at EDL=4, with the IPL
ROM hidden).

The sample directory is conventionally placed at `$2000` so that
DIR = `$20`. You can put it elsewhere; we standardize on `$2000` so
all exercises agree.

The first BRR sample lives at `$2100` (one page after the directory).
This is purely convention.

## Hidden vs. visible IPL ROM

By default at boot, `$FFC0-$FFFF` reads as the IPL ROM. Once your
SPC payload is running, you usually clear bit 7 of CONTROL (`$F1`)
to expose the underlying RAM, freeing those 64 bytes.

The exercises hide the IPL ROM as part of the standard payload boot
sequence. If you want to keep it visible (rare — the only reason
would be debugging the IPL itself), don't write that bit in `$F1`.
