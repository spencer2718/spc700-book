# Troubleshooting

If an exercise doesn't work, check these in order. The most common
problems are tooling-related, not code-related.

## Mesen2 windows: which one shows what?

Most "I can't find ARAM" / "the debugger doesn't show what the
README says" reports come down to looking in the wrong Mesen2
window. The book's exercises use four Mesen2 windows; all of them
are opened from the **main** Mesen2 window's menu bar (not from
inside another debugger window).

| Window         | Menu path                  | Shortcut | Shows                                        |
|----------------|----------------------------|----------|----------------------------------------------|
| SPC Debugger   | Debug → SPC Debugger       | Ctrl+F   | SPC CPU state, disassembly, breakpoints      |
| Memory Tools   | Debug → Memory Tools       | Ctrl+M   | Raw bytes for any selected memory region     |
| Trace Logger   | Debug → Trace Logger       | Ctrl+J   | Per-instruction execution trace              |
| Event Viewer   | Debug → Event Viewer       | Ctrl+E   | Frame-level events (PPU/APU/DMA timing)      |

Memory Tools has a **Memory Type** dropdown near the top. The
values relevant to this book:

- **RAM** — the SPC's 64 KiB ARAM. This is what the chapters
  usually mean when they say "ARAM."
- **SPC** — the SPC CPU's mapped address space (includes the IPL
  ROM near the top end).
- **DSP** — the DSP register file. Use this when an exercise asks
  you to verify a DSP register's value.
- **ROM** — the SPC's IPL ROM (rarely needed).

The **SPC Debugger** window's own Debug menu has *only* execution
controls (continue, step, run cycle/frame/scanline). It does
**not** contain a memory view — that's what Memory Tools is for.
The two windows are independent and typically kept open side by
side.

## "asar: command not found"

Asar isn't on your `PATH`. Either fix your `PATH` to include the
directory where `asar` lives, or invoke it with the full path:

```bash
/full/path/to/asar first_sound.asm first_sound.bin
```

## Asar reports "unknown opcode" or "syntax error"

Two possibilities:

1. **Wrong architecture directive.** Check the top of your `.asm`
   file. Should be `arch spc700-inline` (or just `arch spc700`,
   depending on Asar version). If you accidentally wrote `arch
   65c816` or no `arch` directive, Asar will try to interpret SPC-700
   instructions as 65816 ones and many will be invalid.

2. **Outdated Asar.** Run `asar --version`. If it's older than 1.81,
   upgrade. Older versions may not support all SPC-700 syntax.

## Mesen2 won't load my `.sfc` ROM

The most likely cause: the file isn't actually a valid ROM. The stub
ROM produces a `.sfc` of either 256 KiB or 1 MiB. If your output is
much smaller (a few KiB), then `build.sh` only built the SPC payload
without wrapping it in a ROM. Check `build.sh` — it should run *two*
Asar invocations: one for the payload and one to embed it into the
stub.

## ROM loads but Mesen2 shows a black screen forever

Expected. The stub ROM doesn't render anything to the screen — it
hands off to the SPC and idles. Open the SPC Debugger (Debug →
SPC Debugger, or Ctrl+F, on the main Mesen2 window) and you should
see your code running there. The screen being black is correct.

## SPC debugger shows PC stuck at `$FFC0` or `$FFC9`

The SPC is still in the IPL ROM, waiting for the main CPU to start
the upload. This means the stub ROM either didn't run or didn't
reach the upload code. Check that the stub ROM built correctly and
that your SPC payload was embedded into it.

## SPC debugger shows PC at $0200 but nothing happens

The payload was uploaded but execution started somewhere
unexpected, or your code immediately falls into a sleep / stop / 
infinite loop without doing the thing you expected.

- Check the start of your `.asm` file. Is there a `org $0200`
  directive? Without it, your code may have been assembled at a
  different address.
- Are you sure your code reaches the place you expected? Set a
  breakpoint at the *beginning* of your routine and confirm it
  triggers.

## ARAM doesn't show what I wrote

Common causes:
- **You're looking at the wrong window.** ARAM bytes live in the
  *Memory Tools* window (Debug → Memory Tools, Ctrl+M, on the main
  Mesen2 window — not inside the SPC Debugger), with Memory Type
  set to **RAM**. The SPC Debugger's disassembly pane shows code,
  not data, and may render non-code bytes as "unidentified"
  garbage. See the "Mesen2 windows" section above.
- Mesen2's Memory Tools view updates live, but if you're paused
  in the SPC Debugger, advance one instruction (F10) so the byte
  you expect to be written has actually executed.
- You wrote to a register address (`$F0`-`$FF`) instead of a
  RAM address. Those have hardware side effects, not RAM writes.
- You wrote to an absolute address with the wrong `org` setting.

## I hear no sound

This is Chapter 13 territory. The full debugging path is in
`exercises/ch13_first_sound/PASS_CONDITIONS.md`. Quick checks:

- Master volume nonzero? (`MVOLL`/`MVOLR` at DSP `$0C`/`$1C`)
- FLG MUTE bit cleared? (DSP `$6C` should be `$00`, not `$60`)
- Voice volume nonzero? (`VOLL`/`VOLR` at DSP `$x0`/`$x1`)
- Pitch nonzero? (`PITCHL`/`PITCHH` at DSP `$x2`/`$x3`)
- ADSR enabled with sensible attack/decay? (`ADSR1` bit 7 set,
  attack rate not too slow)
- Sample directory pointing at real BRR data? (DSP `$5D` = page
  containing your directory; directory entries point at real
  samples)
- KON written *after* all the above? (DSP `$4C` with the right
  bit set)
- ENVX rising after KON? (DSP `$x8` should go non-zero within a
  few hundred samples of key-on)

If you've checked all of these and still no sound, capture an SPC
file from Mesen2 and inspect the DSP registers there. Compare to
`solution/expected_dsp.md`.

## Mesen2 emulator audio is very quiet or has clipping

Check Mesen2's audio settings. The default mixer levels and master
volume can be set quite low, which makes test sounds barely audible.
This is unrelated to your SPC code; it's an emulator-side setting.

## Something else

Open an issue on the repo with:
- Your OS and Mesen2/Asar versions
- The exercise you were working on
- A description of what you expected vs. what happened
- The `.asm` source you were trying to build, if you're comfortable
  sharing it
