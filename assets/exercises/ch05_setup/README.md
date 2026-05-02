# Chapter 5: Interlude — Setting Up

By the end of this exercise you will have:

- Built the stub ROM from source.
- Assembled an SPC payload of about 8 bytes.
- Loaded the resulting ROM into Mesen2.
- Stepped through the SPC code in the debugger.
- Watched a byte change in ARAM as your code runs.

This exercise has no musical payoff. The point is to verify your
toolchain works, end to end, with the smallest possible piece of
code in the middle. You will spend the rest of the book repeating
this edit-build-run-step loop. Make sure it's smooth before moving
on.

## The exercise

The starter file `start/hello.asm` writes a single recognizable byte
(`$42`, the answer) to ARAM address `$0500` and then loops forever.
Your job:

1. Read the starter file. Identify the line marked `TODO`.
2. Fill in the missing instruction so the program writes `$42` to
   address `$0500`.
3. Build the payload.
4. Build the stub ROM with your payload embedded.
5. Load the ROM in Mesen2.
6. Open the SPC debugger.
7. Step through your code one instruction at a time.
8. Confirm that ARAM at `$0500` becomes `$42` after the second
   instruction executes.

## Build

```sh
cd exercises/ch05_setup/start
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch05_setup/start/hello.bin
```

You now have `stub-rom/stub.sfc`. Load that file in Mesen2.

## Run

1. Open Mesen2.
2. **File → Open ROM → stub.sfc**.
3. The screen will be black. This is correct — the stub ROM does
   not render anything. The action is on the audio CPU.

## Mesen2 windows you'll need

Mesen2 has several debugger windows. Two are relevant for this
exercise:

- **SPC Debugger** (Debug → SPC Debugger, or **Ctrl+F**): shows
  the SPC's CPU state and disassembly. Use this to step
  instructions, set breakpoints, and watch PC, A, X, Y, SP, PSW
  change.

- **Memory Tools** (Debug → Memory Tools, or **Ctrl+M**): shows
  raw memory as bytes. Use this to inspect ARAM contents.

Both menu items are on the *main* Mesen2 window's menu bar, not on
the SPC Debugger window's own Debug menu (which only has execution
controls — continue, step, run cycle/frame/scanline). It's normal
to keep the two windows open side by side; they update
independently.

In **Memory Tools**, find the "Memory Type" dropdown near the top
of the window. The values you'll touch in this book are:

- **RAM** — the SPC's 64 KiB ARAM. This is what you want for
  reading/writing memory from your SPC code.
- **SPC** — the SPC CPU's full address space (includes the IPL
  ROM at the top end).
- **DSP** — the DSP register file.

For this exercise, set Memory Type to **RAM**.

## Step through your code

1. Open the **SPC Debugger** (Ctrl+F). Set a breakpoint at address
   `$0200` — the entry point of your payload. Right-click on the
   line in the disassembly pane and choose the breakpoint option,
   or use the breakpoint dialog.
2. Run the emulator (**F5** or the play button). It will hit the
   breakpoint after the IPL upload completes.
3. Open **Memory Tools** (Ctrl+M). Set Memory Type to **RAM**.
   Type `0500` into the address field at the top and press Enter
   to jump to that byte.
4. The current value at `$0500` should be `$00` (ARAM clears at
   boot).
5. Switch back to the SPC Debugger and step one instruction at a
   time with **F10** (or the step-over button).
6. After each step, glance at the Memory Tools window — `$0500`
   stays `$00` until the second instruction (`mov $0500, a`)
   executes, at which point it becomes `$42`.

## What you should see

- After the first instruction, register A (SPC Debugger pane)
  holds `$42`.
- After the second instruction, ARAM `$0500` (Memory Tools pane,
  with Memory Type = RAM) holds `$42`.
- After the third instruction, the SPC is in the infinite loop
  and PC oscillates between two adjacent addresses.

If you see all three, your toolchain is working and you can move
on. If any step doesn't behave as described, see
`PASS_CONDITIONS.md` for more detailed checks, or
`../../docs/TROUBLESHOOTING.md` for common problems.

## After this exercise

You should be comfortable with:

- The edit → assemble → build ROM → load in emulator → debug loop.
- Where in Mesen2 to find SPC registers and ARAM.
- Setting a breakpoint and stepping a single instruction.

You don't need to understand any actual SPC-700 instructions yet —
that's the next chapter's job. You only need to know that your
machinery works.
