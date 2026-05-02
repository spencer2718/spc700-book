# Chapter 6: Pass Conditions

This is an observational exercise — there is no code to write —
so "pass" means: after the payload runs to its `bra forever`, the
SPC's visible state matches what the chapter promises. Use the
**SPC Debugger** for register state and **Memory Tools** (Memory
Type = **RAM**) for ARAM bytes. Both windows open from the main
Mesen2 window's Debug menu (Ctrl+F and Ctrl+M).

## PASS condition 1: PC is in the BRA loop

```
PASS:  PC == $0218 (or oscillating at the bra forever address).
FAIL:  PC anywhere else, or stuck in the IPL ROM ($FFCx).
```

If FAIL: the upload didn't complete, or an instruction earlier in
the payload jumped/branched somewhere unexpected. The payload has
no branches before the final BRA, so this should not happen.

## PASS condition 2: registers reflect the load + push/pop sequence

```
PASS:  A = $22, X = $BB, Y = $CC, SP = $FE.
       PSW.P = 0 (the P flag in PSW; clrp executed cleanly).
       PSW.N = 1 (last A loaded was $22; bit 7 clear, so N=0
                  actually — wait, $22 = %00100010, bit 7=0, so N=0.
                  See note below.)
```

Re-derive PSW.N for yourself: A holds `$22` after the final pop.
`$22` in binary is `0010 0010`, bit 7 is `0`, so the N flag is
`0`. (PSW flags reflect the *last* op that updated them; the pop
updates N and Z based on the loaded value.)

```
FAIL:  Any of A, X, Y, SP differ. Most common cause: a step was
       skipped or the breakpoint hit somewhere unexpected. Step
       through one more time using `solution/trace.txt` as a
       reference at each instruction.
```

## PASS condition 3: memory shows the direct-page and absolute writes

In Memory Tools (Memory Type = RAM):

```
PASS:  $0020 == $AA.
       $0500 == $DD.
FAIL:  Either byte still $00, or holds a different value.
```

If `$0020` is unchanged: the `mov $20, a` either didn't execute
(unlikely — there's nothing to skip it) or assembled to a
different address. Check the disassembly: opcode at `$020A`
should be `C4 20`.

If `$0500` is unchanged: similarly, check the disassembly at
`$020E` — opcode should be `C5 00 05` (note the little-endian
address bytes).

## PASS condition 4: the stack physically holds the pushed bytes

In Memory Tools (Memory Type = RAM):

```
PASS:  $01FF == $11 (the first push, still in place).
       $01FE == $22 (the second push; not erased by the pop).
FAIL:  Either byte still $00, or a different value.
```

This is the key lesson of the push/pop part of the exercise: POP
doesn't *erase* memory. It increments SP and loads from the
new top — but the byte at the previous top is still there. If
you observe `$01FE = $00` after the pop, then either:

- Something cleared the page (unlikely; nothing in the payload
  touches `$01FE` other than the push), or
- You're reading the wrong window — make sure Memory Type is
  **RAM**, not "SPC" or "DSP."

## Bonus check: instruction encoding lengths

Look at the disassembly view in the SPC Debugger. The two memory
writes have different byte counts:

```
$020A: C4 20         mov $20, a       (2 bytes — direct-page form)
$020E: C5 00 05      mov $0500, a     (3 bytes — absolute form)
```

If both opcodes are the same length, the assembler picked the
wrong form for one of them. For the released payload, this
shouldn't happen — `$20` fits in a byte and `$0500` doesn't, so
Asar selects each form correctly.
