# Verification Protocol

> **Audience.** This is a maintainer-facing regression document, not
> a reader-facing exercise walkthrough. Readers should follow the
> per-exercise READMEs (`exercises/chXX_*/README.md`). Use this file
> when you change something in this repo and want to confirm you
> haven't regressed the v0.1.0 path.

## What "verified" means as of v0.1.0

`v0.1.0` was verified end-to-end on **Windows** with **Asar 1.91**
and **Mesen2** (latest stable at the time of tagging). Linux and
macOS *should* work — both tools are cross-platform — but the
build scripts and exact command paths have not yet been exercised
on those platforms. If you verify on another platform, file the
finding in `CHANGES.md`.

## Prerequisites

- Asar 1.81 or later on `PATH` (or invoke by full path).
- Mesen2 installed.
- Repo cloned; shell `cd`'d into the repo root.

Run `asar --version` to confirm Asar works. Open Mesen2 and
dismiss any first-launch dialogs.

## The protocol

Eight steps: 1–4 are static (build-time), 5–8 are dynamic (run in
Mesen2). The static steps are quick and catch most regressions.
The dynamic steps require an emulator session and a working audio
output.

### Step 1 — stub ROM builds

```sh
cd stub-rom
./build.sh
```

Expected:

- `No payload provided; using 1-byte placeholder (STOP).`
- `Built stub.sfc (262144 bytes).`
- No warnings printed.

The 262144-byte size (256 KiB exactly) is anchored by `padbyte $00`
plus the `db $00` sentinel at `org $07FFFF` near the bottom of
`stub.asm`. The SNES header checksum is filled by Asar, driven by
the `--fix-checksum=on` flag in `build.sh`.

### Step 2 — pre-Mesen2 sanity checks on stub.sfc

The stub is **LoROM**, so the SNES `$00:FFC0` header lives at file
offset `$7FC0–$7FDF` (not `$FFC0`). These four checks catch the
common header-malformation regressions before launching the
emulator.

```sh
cd stub-rom
```

**Check A — file size is exactly 262144 bytes:**

```sh
test "$(wc -c < stub.sfc | tr -d ' ')" -eq 262144 && echo "OK" || echo "FAIL"
```

**Check B — map mode byte at file offset `$7FD5` is `$20` (LoROM):**

```sh
xxd -s 0x7FD5 -l 1 stub.sfc
# Expected: 00007fd5: 20
```

**Check C — ROM-size byte at file offset `$7FD7` is `$08` (256 KiB):**

```sh
xxd -s 0x7FD7 -l 1 stub.sfc
# Expected: 00007fd7: 08
```

**Check D — title at `$7FC0–$7FD4` is 21 bytes of printable ASCII:**

```sh
xxd -s 0x7FC0 -l 21 stub.sfc
# Expected: 00007fc0: 5350 4337 3030 2042 4f4f 4b20 5354 5542 2020 2020 20  SPC700 BOOK STUB
```

### Step 3 — Chapter 5 payload assembles

```sh
cd ../exercises/ch05_setup/start
cp ../solution/hello.asm ./hello.asm
./build.sh
```

Expected: `Built hello.bin (8 bytes).` (`clrp` + `mov a,#$42` +
`mov $0500,a` + `bra forever` = 1 + 2 + 3 + 2 = 8 bytes. Asar does
not pad SPC-700 output.)

Restore the starter:

```sh
git checkout hello.asm
```

### Step 4 — Chapter 13 payload assembles, BRR is reproducible

```sh
cd ../../ch13_first_sound/start
cp ../solution/first_sound.asm ./first_sound.asm
./build.sh
```

Expected: `Built first_sound.bin (7945 bytes).` The size is
anchored by the trailing `org $1F00 / incbin sine.brr` block (file
ends at offset `$1F08`, byte 7945). Code growth in front of that
block shrinks the gap; it does not extend the file.

Restore the starter:

```sh
git checkout first_sound.asm
```

Confirm the BRR sample is byte-identical to what the generator
produces:

```sh
cd ../../..
python3 tools/make_sine_brr.py /tmp/regenerated_sine.brr
diff exercises/ch13_first_sound/assets/sine.brr /tmp/regenerated_sine.brr
```

Expected: no output (files identical).

### Step 5 — stub.sfc loads in Mesen2

Open `stub.sfc` in Mesen2 (File → Open ROM).

Expected:

- Mesen2 accepts the file with no error or warning.
- Screen is black (forced blank).
- No crash.

Open the SPC Debugger (Debug → SPC Debugger, Ctrl+F). PC should
either be inside the IPL ROM (around `$FFC0`–`$FFC9`) momentarily,
or at the SPC's `STOP` instruction at `$0200` once the placeholder
payload's single byte (`$FF` = STOP) has executed.

### Step 6 — Chapter 5 ROM exhibits PASS conditions

```sh
cd exercises/ch05_setup/start
cp ../solution/hello.asm ./hello.asm
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch05_setup/start/hello.bin
```

Load the resulting `stub.sfc` in Mesen2. Verify the four PASS
conditions from `exercises/ch05_setup/PASS_CONDITIONS.md`:

1. PC reaches `$0201` (or wherever the `clrp` lands; the IPL hands
   off at `$0200`, so PC inside `$0200`–`$0207` confirms upload).
2. After stepping the `mov $0500, a` instruction, Memory Tools
   (Memory Type = RAM) shows `$42` at address `$0500`.
3. A holds `$42` just before the store.
4. PC eventually oscillates inside the `bra forever` loop.

### Step 7 — Chapter 13 produces audible sound

```sh
cd exercises/ch13_first_sound/start
cp ../solution/first_sound.asm ./first_sound.asm
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/ch13_first_sound/start/first_sound.bin
```

Load the resulting `stub.sfc` in Mesen2. Within 1–2 seconds of
load you should hear a steady 2 kHz sine tone that sustains
indefinitely.

If silent or distorted, walk
`exercises/ch13_first_sound/PASS_CONDITIONS.md`. Check that
Mesen2's master volume isn't muted (it's an emulator setting,
unrelated to your DSP code).

### Step 8 — capture an SPC for archival

In Mesen2 while Chapter 13's ROM plays, save an SPC file (the menu
varies between Mesen2 versions; commonly Tools → Run Single Frame
or a dedicated "Save SPC" entry). Save as `verification_ch13.spc`.
Open in any external SPC player and confirm the same 2 kHz tone.
This proves the SPC has reached a self-contained playable state.

## If a step fails

If any step fails after a change, the change introduced a
regression against `v0.1.0`. The fastest recovery:

```sh
git bisect start
git bisect bad           # current HEAD is broken
git bisect good v0.1.0   # v0.1.0 was end-to-end clean
```

…and let bisect narrow down the offending commit.

If a step fails on `v0.1.0` itself (no recent change), the cause
is environmental: tool version, OS, or shell. Check Asar version
(`asar --version`) and Mesen2 version first.

## Reporting

When a regression survives bisect (e.g., it depends on the tool
version, not a repo commit), open an issue with:

1. Which step failed.
2. Exact error message or observed behavior.
3. `asar --version` output, Mesen2 version, OS, shell.
4. Git SHA of the working tree.
