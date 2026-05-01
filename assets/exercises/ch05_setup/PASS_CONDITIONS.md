# Chapter 5: Pass Conditions

The exercise is complete when **all** of the following are
observable in Mesen2's SPC debugger after the SPC payload starts
executing.

## PASS condition 1: ARAM at $0500 holds $42

Open the ARAM memory view. Scroll to address `$0500`.

```
PASS:  M(0x0500) == 0x42 after the second SPC instruction.
FAIL:  M(0x0500) != 0x42, or it's still $00 after stepping past
       the second instruction.
```

If FAIL: your `mov $0500, a` didn't execute, the address is wrong,
or the value being stored is wrong.

## PASS condition 2: PC reaches the infinite loop

Set a breakpoint at the third instruction's address. Run.

```
PASS:  Breakpoint hits, then PC oscillates within the BRA range.
FAIL:  Breakpoint never hits — code didn't reach the loop.
```

If FAIL: an earlier instruction didn't execute, the BRA target is
wrong, or your payload didn't get past the first two instructions.

## PASS condition 3: A == $42 just before the store

Set a breakpoint at the second instruction (the `mov $0500, a` line).

```
PASS:  At the breakpoint, A == 0x42.
FAIL:  A is some other value.
```

If FAIL: your immediate-load instruction didn't execute or used
the wrong value.

## Bonus check: the upload happened cleanly

Before your code starts running:

```
PASS:  PC == 0x0200 when the SPC starts executing your payload.
FAIL:  PC stuck at $FFCx territory (still in the IPL ROM).
```

If FAIL: the stub ROM didn't complete the upload, or the SPC
entry address was set wrong. This usually indicates a problem
with the stub ROM build, not with your payload. See
`docs/TROUBLESHOOTING.md`.
