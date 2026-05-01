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
4. **Debug → Sound → SPC** (or similar; menu may vary by Mesen2
   version) to open the SPC-700 debugger window.

You should see the SPC's CPU registers, a code listing at the
current PC, and a memory view of ARAM.

## Step through your code

In the SPC debugger:

1. Set a breakpoint at address `$0200` (the entry point of your
   payload). In Mesen2, right-click on the line in the code view
   or use the breakpoint dialog.
2. Run the emulator (F5 or the play button); it will hit the
   breakpoint after the IPL upload completes.
3. Open ARAM in the memory view. Navigate to address `$0500`.
4. The current value should be `$00` (ARAM clears at boot).
5. Step the SPC one instruction at a time using F10 or the
   step-over button.
6. Watch what changes after each step.

## What you should see

- After the first instruction, register A holds `$42`.
- After the second instruction, ARAM `$0500` holds `$42`.
- After the third instruction, the SPC is in the infinite loop and
  PC oscillates between two adjacent addresses.

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
