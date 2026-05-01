# Verification Protocol

This document is for the asset author / repo maintainer, not for
readers of the book. It describes the end-to-end test that needs to
pass before the v0.1.0 release of this asset repo.

The skeleton was produced without access to a SNES emulator or an
SPC-700 assembler. Some details — the stub ROM's 65816 code, the
IPL upload protocol, the exact register values — may need
adjustment when first run. The point of this protocol is to find
problems early.

## Prerequisites

- Asar 1.81 or later installed and on PATH.
- Mesen2 installed.
- This repo cloned and your shell `cd`'d into its root.

Run `asar --version` to confirm Asar works. Open Mesen2 and dismiss
any first-launch dialogs.

## Step 1: Stub ROM builds with a placeholder payload

```sh
cd stub-rom
./build.sh
```

**Expected:**
- "No payload provided; using 1-byte placeholder (STOP)."
- "Built stub.sfc (262144 bytes)." (256 KiB exactly)
- No warnings printed.

**If it fails to build:**
- Asar errors usually point at a file and line. Look at `stub.asm`
  and `ipl_upload.asm`.
- Common issues: Asar version mismatch on directives like
  `padbyte`, `pad`, `checksum auto`. Asar 1.81+ supports all of
  these; older versions may not.
- The `!PAYLOAD_SIZE` define is passed by the build script via
  `-D`. If Asar complains about an undefined symbol, the `-D`
  flag syntax may differ between Asar versions.

**If size is wrong:** the `pad` and `padbyte` directives at the
top of `stub.asm` should produce a 256 KiB output regardless of
how much is actually written. If the result is smaller, Asar may
not be honoring the directives; if larger, the org positions are
wrong somewhere.

## Step 2: Stub ROM loads in Mesen2 with placeholder payload

Open `stub.sfc` in Mesen2.

**Expected:**
- Mesen2 accepts the file as a valid ROM (no rejection).
- Screen is black or in forced-blank state.
- No crash.
- Open the SPC debugger. PC should eventually settle at the SPC's
  STOP instruction at $0200, or be stuck in the IPL ROM if the
  upload didn't run.

**If Mesen2 rejects the ROM:** the header at `$00FFC0-$00FFFF`
isn't producing what Mesen2 expects. The `checksum auto` directive
in `stub.asm` should fill the checksum and complement; if Asar
version doesn't support it, you may need to compute manually.

**If PC is stuck in IPL ROM forever:** the upload protocol in
`ipl_upload.asm` isn't completing. Likely causes:
- Wrong I/O register addresses (verify `$2140-$2143`).
- Counter mismatch in the byte-loop section.
- The "+2" final-counter signal is wrong.

## Step 3: Chapter 5 starter assembles

```sh
cd ../exercises/ch05_setup/start
./build.sh
```

**Expected:** the build will *fail* with a syntax error on the
TODO line, since the starter has a TODO placeholder. To verify
the build path: copy the solution and re-run.

```sh
cp ../solution/hello.asm ./hello.asm
./build.sh
```

**Expected:** "Built hello.bin (8 bytes)." (a 3-instruction
program: `mov a, #$42` is 2 bytes, `mov $0500, a` is 3 bytes,
`bra forever` is 2 bytes — 7 total — but Asar may pad to an even
number; 8 is fine.)

After verification, restore the starter:
```sh
git checkout hello.asm
```

## Step 4: Chapter 5 ROM loads and exhibits PASS conditions

```sh
cp ../solution/hello.asm ./hello.asm
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch05_setup/start/hello.bin
```

Load `stub.sfc` in Mesen2.

**Verify the four PASS conditions** from
`exercises/ch05_setup/PASS_CONDITIONS.md`:

1. `M(0x0500) == 0x42` after the second SPC instruction.
2. PC reaches and oscillates within the BRA loop.
3. A == $42 just before the store.
4. PC starts at $0200 after the upload.

**If any fails:** the bug is either in the SPC payload or the
upload protocol. Use the SPC debugger to step through and find
where execution actually goes.

## Step 5: Chapter 13 BRR encoding is correct

Inspect `exercises/ch13_first_sound/assets/sine.brr`:

```sh
od -An -tx1 exercises/ch13_first_sound/assets/sine.brr
```

**Expected output:** `c3 02 46 66 42 0e ca aa ce`

That's 9 bytes: header `$C3` (filter 0, shift 12, loop+end set),
then 8 data bytes encoding the 16-sample sine.

If different: re-run `tools/make_sine_brr.py` to regenerate.

## Step 6: Chapter 13 builds

```sh
cd ../exercises/ch13_first_sound/start
cp ../solution/first_sound.asm ./first_sound.asm   # for verification
./build.sh
```

**Expected:** "Built first_sound.bin (about 8 KiB)." More
precisely: file offset $0000-$xx (code) is filled, then $0100-$1DFF
is gap (Asar fills with $00), then $1E00-$1E03 is the directory,
then $1E04-$1EFF is gap, then $1F00-$1F08 is the BRR. Total file
size is $1F09 = 7945 bytes.

If you see a much smaller binary: Asar may be compacting the gaps
instead of zero-filling. The actual file *must* be at least 7945
bytes for the upload to land the BRR at ARAM $2100.

If you see an error about `incbin` not finding `sine.brr`: the
build script copies the file from `../assets/`. Verify the copy
worked.

## Step 7: Chapter 13 ROM produces audible sound

```sh
cd ../../../stub-rom
./build.sh ../exercises/ch13_first_sound/start/first_sound.bin
```

Load `stub.sfc` in Mesen2.

**Listen.**

You should hear a steady 2 kHz tone shortly after loading.

**If silence:** walk the DSP register checklist in
`exercises/ch13_first_sound/PASS_CONDITIONS.md`.

**If noise instead of a sine:**
- BRR header byte at $2100 is wrong. Should be $C3.
- BRR data isn't at $2100; check ARAM in the debugger.

**If only one channel:**
- One of V0VOLL/V0VOLR is wrong.

## Step 8: Capture an SPC for archival

In Mesen2, while Chapter 13's ROM plays:

- Save SPC via the appropriate menu (varies by Mesen2 version).
- Save as `verification_ch13.spc`.
- Open in any SPC player.
- Verify the same 2 kHz tone plays.

This proves the SPC reaches a self-contained playable state, which
is the actual end goal for any SPC-related work.

## What success looks like

Steps 1 through 8 all pass. v0.1.0 can then be tagged.

## What "almost success" looks like

If steps 1-5 pass but step 7 doesn't, the gap is in DSP
configuration. The debugger walkthrough will localize it.

If steps 1-2 pass but step 4 doesn't, the gap is in the upload
protocol. Cross-check against SNESdev's IPL documentation.

If step 1 fails, fix the Asar invocation first.

## Reporting back

If verification fails, please send back:
1. Which step failed.
2. Exact error message or observed behavior.
3. Asar version (`asar --version`) and Mesen2 version.
4. Your OS.

That's enough to diagnose nearly any problem in the skeleton.
