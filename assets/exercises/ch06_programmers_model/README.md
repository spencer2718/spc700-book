# Chapter 6: The Programmer's Model

By the end of this exercise you will have:

- Watched the SPC's six visible registers (A, X, Y, SP, PSW, PC)
  change as instructions execute.
- Watched a byte appear at a direct-page address (`$0020`) and at
  an absolute address (`$0500`).
- Seen the stack physically grow downward through page 1 as PUSH
  decrements SP.
- Confirmed POP returns the most recent push and only updates SP
  (the stack byte itself is not erased).

This exercise is **observational**. There is no code to write —
the whole point is to step through a small payload and watch the
state change in front of you. Chapter 5 verified your toolchain
works; this one verifies that the abstract framework from the
chapter ("the SPC's state is registers + memory") corresponds to
real bytes you can see.

## Note on chapter numbering

This exercise lives in `ch06_programmers_model/` in the asset
repo, but in the current PDF of the book it's still
**Chapter 5: The Programmer's Model**. The repo is one chapter
ahead because a new "Interlude: Setting Up" chapter has been
inserted at slot 5 here but not yet in the textbook itself. A
future book-side pass will renumber the textbook chapters and
bring the two in line; until then, "Chapter 6 here" maps to
"Chapter 5 in the PDF."

## The exercise

The payload `start/programmers_model.asm` runs through, in
sequence:

1. Setting SP to `$FF`.
2. Clearing the direct-page flag (`clrp`).
3. Loading A, X, Y to memorable sentinel bytes (`$AA`, `$BB`, `$CC`).
4. A direct-page write (`mov $20, a`).
5. An absolute write (`mov $0500, a`).
6. Two pushes (`$11`, then `$22`).
7. One pop.
8. An infinite-loop terminator.

Your job is to step through it one instruction at a time and watch
each promised change happen.

## Build

```sh
cd exercises/ch06_programmers_model/start
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch06_programmers_model/start/programmers_model.bin
```

You now have `stub-rom/stub.sfc`. Load it in Mesen2.

## Set this up before stepping

Open both windows from the **main** Mesen2 window's menu bar
(see `docs/TROUBLESHOOTING.md`'s "Mesen2 windows" table for
shortcuts and details):

- **SPC Debugger** (Ctrl+F) — for register state and the
  disassembly view.
- **Memory Tools** (Ctrl+M) — for ARAM bytes.

In Memory Tools, set **Memory Type = RAM** and arrange the
window so you can see all four interesting locations without
re-navigating during the exercise:

- `$0020` — where the direct-page write lands.
- `$0500` — where the absolute write lands.
- `$01FE`–`$01FF` — where the two pushes land.

In the SPC Debugger, set a breakpoint at `$0200` (the entry
point) and run; the breakpoint will hit once the IPL upload
completes. From there, step with **F10**.

## Step-by-step walkthrough

Each numbered step corresponds to one instruction (or, for tightly
coupled pairs, two). After each step, the listed changes should
have happened.

1. **`mov x, #$ff`** — X transitions to `$FF`. SP is unchanged
   (still whatever the IPL left it as, often `$EF`).
2. **`mov sp, x`** — SP transitions to `$FF`. The stack now
   "lives at the top of page 1," ready for the canonical
   convention.
3. **`clrp`** — PSW's P bit goes to `0` (or stays at `0` if it
   was already there). Direct-page references will now resolve
   to `$0000–$00FF`.
4. **`mov a, #$aa`** — A transitions to `$AA`. PSW's N flag goes
   to `1` (because `$AA` has bit 7 set).
5. **`mov x, #$bb`** — X transitions to `$BB`. Note: the load
   only modifies X; A is untouched at `$AA`.
6. **`mov y, #$cc`** — Y transitions to `$CC`. A and X
   unchanged.
7. **`mov $20, a`** — Memory Tools (RAM) at `$0020` transitions
   from `$00` to `$AA`. The disassembly shows opcode `C4 20` —
   the *direct-page* form of the store, just 2 bytes. A and the
   other registers are unchanged.
8. **`mov a, #$dd`** — A transitions from `$AA` to `$DD`.
9. **`mov $0500, a`** — Memory Tools at `$0500` transitions from
   `$00` to `$DD`. The disassembly shows opcode `C5 00 05` — the
   *absolute* form of the store, 3 bytes. Same mnemonic as step
   7, different opcode and length, because `$0500` doesn't fit
   in a single byte.
10. **`mov a, #$11`** — A transitions to `$11`.
11. **`push a`** — SP decrements from `$FF` to `$FE`. Memory
    Tools at `$01FF` transitions from `$00` to `$11`. (PUSH
    writes first, then decrements; so the byte landed *before*
    SP moved.)
12. **`mov a, #$22`** — A transitions to `$22`.
13. **`push a`** — SP decrements from `$FE` to `$FD`. Memory
    Tools at `$01FE` transitions from `$00` to `$22`.
14. **`pop a`** — SP increments from `$FD` to `$FE`. A is
    restored to `$22` (the byte at `$01FE`). **Crucially, the
    byte at `$01FE` is not cleared by the pop — it still reads
    `$22`.** Popping is just an SP move plus a load; nothing
    erases the popped byte.
15. **`bra forever`** — PC bounces back to the BRA instruction
    itself. Every subsequent step keeps PC at the same address.
    The SPC is now idle.

## What you should see (final state)

After step 15, the SPC is in the BRA loop. Read the state:

- **Registers:** A = `$22`, X = `$BB`, Y = `$CC`, SP = `$FE`,
  PSW.P = `0`.
- **Memory (Memory Tools, Memory Type = RAM):**
  - `$0020` = `$AA`
  - `$0500` = `$DD`
  - `$01FE` = `$22`
  - `$01FF` = `$11`
- **PC** oscillates inside the `bra forever` instruction
  (address `$0218`).

The detailed pass conditions are in `PASS_CONDITIONS.md`. The
expected register/memory trace at every step is in
`solution/trace.txt`.

## What you should remember

- The SPC has six visible registers: A, X, Y, SP, PSW, PC. You
  just watched five of them change (PC changes on every
  instruction by definition).
- Direct-page addresses are 8-bit operands and resolve to either
  `$0000–$00FF` (when PSW.P = 0) or `$0100–$01FF` (when P = 1).
  The reader saw P = 0 throughout, so `$20` resolved to `$0020`.
- The same mnemonic (`mov mem, a`) can pick either of two
  opcodes depending on whether the address fits in a byte. The
  assembler chooses; the difference is observable in the
  disassembly's instruction length.
- The stack lives at `$0100 + SP`. PUSH writes then decrements;
  POP increments then reads. The "stack" is just a region of
  ARAM with a register that tracks the next free slot.
- POP does not erase the byte it reads. Old stack contents
  linger as garbage past the current SP. (Production code that
  cares about secrets clears them explicitly.)

## Try this

The exercise's SP setup is `mov x, #$ff; mov sp, x`. Predict
what happens if you delete those two instructions:

1. Where does the first `push a` actually write its byte? (Hint:
   the IPL ROM leaves SP near `$EF`. PUSH writes to `$0100 + SP`,
   then decrements SP.)
2. Does the program crash, or does it silently corrupt
   something?
3. Could a future direct-page write at, say, `$EE` collide with
   any leftover stack data? Why or why not?

After you've predicted, edit `start/programmers_model.asm`,
delete the two SP-setup lines, rebuild, reload, and check your
predictions in Memory Tools. Then restore the file with
`git checkout programmers_model.asm`.

The lesson: SPC-700 won't fault on "wrong" SP. The convention of
putting SP at `$FF` is enforced by you, not the chip.
