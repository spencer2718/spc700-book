# CHANGES

## v0.1.0-skeleton-corrected (this pass)

This pass applies fixes from a static audit of the initial skeleton.
None of the original skeleton was emulator-tested, and several
issues were caught by code review before the author attempted to
verify in Mesen2. The corrections below should be in place before
the verification protocol in `VERIFICATION.md` is run.

### Blockers fixed

**`arch spc700-inline` replaced with `arch spc700` + `norom` + `base`.**
The original skeleton's payloads used `arch spc700-inline`, which
in Asar emits SPC upload-block control data rather than raw SPC
machine code. The stub uploader in `ipl_upload.asm` expects raw
bytes, so `inline` and the uploader were incompatible. The fix is
to use `arch spc700` for raw output, with `norom` to disable SNES
LoROM/HiROM address translation, and `base` to set the logical
address Asar uses for label arithmetic. File offsets are then
explicitly chosen so that ARAM addresses map cleanly:
- ARAM `$0200` → file offset `$0000`
- ARAM `$2000` → file offset `$1E00` (Chapter 13 directory)
- ARAM `$2100` → file offset `$1F00` (Chapter 13 BRR sample)

**`!$0500`-style addressing replaced with `$0500`.** In Asar, `!`
is the define prefix (e.g. `!MVOLL = $0C`). The textbook notation
`!abs` for absolute addressing doesn't translate to Asar source
directly. SPC-700 sources now use plain `$0500` for absolute
addresses. The textbook's `!abs` notation is preserved as
*pedagogical* notation in the book itself; only repo source files
were affected.

**IPL final-counter signal corrected.** The original code wrote 0
to APUIO1 and incremented A from 0 to 1 — but the IPL ROM
distinguishes "another byte" from "jump to entry" by requiring the
final APUIO0 value to be at least 2 greater than the last
acknowledged counter. The fix reads back the last counter,
adds 2, writes it, and waits for the SPC to echo it back.

**`cld` added to reset.** `adc` requires binary mode; the original
`reset:` didn't clear decimal mode before the upload routine used
`adc`. Added `cld` between `sei` and `clc`.

**FLG = $20 instead of $00 at the end of Chapter 13 setup.** Writing
$00 to FLG re-enables echo writes. Since the exercise doesn't
configure echo (no ESA, no EDL > 0), the DSP would continuously
overwrite a small region at ARAM `$0000-$0003` (zero page), which
overlaps with direct-page variables and the start of code. Keeping
FLG bit 5 (ECHO WRITE DISABLE) set with $20 avoids this.

**BRR header changed from $03 to $C3.** The original $03 set shift=0,
which leaves decoded nibbles in their raw -8..+7 range — far too
quiet to be audibly meaningful through the SNES output stage. $C3
sets shift=12, which scales nibbles to roughly -24576..+24576 —
comfortably within audible range and clear of the Gaussian
interpolation overflow zone (-32768).

**Stub ROM size enforced to 256 KiB.** The original `stub.asm`
declared a 256 KiB ROM in its header but didn't actually pad the
output. Added `padbyte $00` and `pad $0000` directives at the top,
plus a sentinel `db $00` at offset `!ROM_SIZE_BYTES-1` to anchor
the file size. Replaced the placeholder checksum bytes with
`checksum auto` (Asar 1.81+).

### Documentation fixes

**README.md no longer references `tools/build_chapter.sh`.** That
script was advertised in the layout but never written. Removed
from the layout listing.

**README.md says sine.brr is 9 bytes, not 64.** Original said
"64-byte" which was wrong.

**VERIFICATION.md adjusted Chapter 13 expected file size.** Was
"around 280 bytes" (which would have applied to a tightly-packed
binary). Actual size is ~7945 bytes because the file offsets for
the directory ($1E00) and BRR ($1F00) leave gaps that Asar
zero-fills.

**stub.asm comment about checksum reflects reality.** Was "build.sh
fills"; now correctly says `checksum auto` is responsible.

**TODO 2 in Chapter 13 starter says "six instructions" not "four".**
A DSP write takes three instructions (load A, load Y, MOVW), and
TODO 2 needs two such writes — six instructions total.

**Chapter 13 README clarifies that DIR and the directory data are
different things.** The directory's *data* (the 4-byte entry at
ARAM $2000) is pre-written; the *DSP register* DIR (which tells
the chip where the directory lives) is TODO 1.

**Time-to-sound made vague.** Previously said "about a second";
now "shortly after load" since actual timing depends on payload
size and emulator performance.

### Files modified

```
README.md                                        rewritten
VERIFICATION.md                                  rewritten
exercises/ch05_setup/README.md                   rewritten
exercises/ch05_setup/PASS_CONDITIONS.md          rewritten
exercises/ch05_setup/start/hello.asm             rewritten (raw payload)
exercises/ch05_setup/start/build.sh              minor fix (wc output)
exercises/ch05_setup/solution/hello.asm          rewritten (raw payload)
exercises/ch05_setup/solution/trace.txt          rewritten (correct opcode lengths)
exercises/ch13_first_sound/README.md             rewritten
exercises/ch13_first_sound/PASS_CONDITIONS.md    rewritten (FLG=$20)
exercises/ch13_first_sound/assets/sine.brr       regenerated (header $C3)
exercises/ch13_first_sound/assets/sine.brr.notes.md rewritten
exercises/ch13_first_sound/start/first_sound.asm rewritten (raw payload, FLG fix)
exercises/ch13_first_sound/start/build.sh        unchanged behavior, output cleaned
exercises/ch13_first_sound/solution/first_sound.asm rewritten
exercises/ch13_first_sound/solution/expected_dsp.md updated (FLG=$20)
stub-rom/stub.asm                                rewritten (padding, checksum)
stub-rom/ipl_upload.asm                          rewritten (counter +2, cld)
stub-rom/build.sh                                added size-warning check
tools/make_sine_brr.py                           updated (header $C3)
```

Files unchanged: `STATUS.md`, `docs/INSTALL.md`, `docs/MEMORY_MAP.md`,
`docs/TROUBLESHOOTING.md`, `docs/CONVENTIONS.md`, `stub-rom/README.md`.

## Pass 1 — Static build verification

Ran the four static checks from `VERIFICATION.md` (steps 1, 3, 5,
and 6) under Asar 1.91 on Windows. Three Asar-syntax issues in the
stub ROM had to be corrected before it would assemble; the two
SPC-700 payloads and the BRR sample passed first try.

### Fixes applied

**`pad $0000` removed from top of `stub.asm`.** Asar 1.91 rejects
this with `Epad_in_freespace`: `pad` requires a current pc set by a
prior `org`, and there is none at the top of the file. The
combination of `padbyte $00` and the end-of-file sentinel byte is
sufficient to produce a fully-padded 256 KiB ROM, so `pad $0000` was
redundant as well as invalid.

**`checksum auto` directive replaced with `--fix-checksum=on` build
flag.** `checksum auto` is not a recognized Asar directive (1.91
emits `Eunknown_command`). The equivalent behavior is the
command-line flag `--fix-checksum=on`, which forces Asar to
generate the SNES header checksum on every build. Updated
`stub-rom/build.sh` to pass the flag and removed the directive from
`stub.asm`.

**Sentinel-byte address fixed to `$07FFFF`.** The end-of-file
anchor was written as `org !ROM_SIZE_BYTES-1` where
`!ROM_SIZE_BYTES = $40000`. Asar's `org` takes a SNES address, not
a ROM offset, and SNES `$003FFF` under LoROM is RAM space, not the
final byte of a 256 KiB ROM. Replaced with `org $07FFFF`, which is
the LoROM SNES address mapping to ROM offset `$3FFFF`.

**xkas low/high byte syntax replaced in `ipl_upload.asm`.** The
original code used `lda #<!SPC_ENTRY` and `lda #>!SPC_ENTRY` to
take the low and high bytes of the 16-bit ARAM entry address. Asar
explicitly does not implement xkas's `<`/`>` byte-extraction
operators (the manual notes the ambiguity with macros and math
expressions); the errors were `Einvalid_number`. Replaced with
explicit bitwise math: `lda.b #!SPC_ENTRY&$FF` for the low byte and
`lda.b #!SPC_ENTRY>>8` for the high byte. The `.b` suffix is
defensive — accumulator is already 8-bit at this point — and makes
the intent explicit.

### Verified targets

After the fixes, all four static checks pass under Asar 1.91:

- `stub-rom/build.sh` → `stub.sfc` (262144 bytes, exactly 256 KiB).
- `exercises/ch05_setup/start/build.sh` (with solution copied in) →
  `hello.bin` (7 bytes; 2 + 3 + 2 = 7 for `mov a,#$42` + `mov $0500,a` + `bra forever`).
- `exercises/ch13_first_sound/start/build.sh` (with solution copied
  in) → `first_sound.bin` (7945 bytes, matching the predicted size
  from the `org $1F00` BRR offset plus the 9-byte sample).
- `tools/make_sine_brr.py` regenerates byte-identical output to the
  checked-in `exercises/ch13_first_sound/assets/sine.brr`.

Note: the previous prediction "Asar may pad to an even number; 8 is
fine" in `VERIFICATION.md` does not hold for Asar 1.91 — the
Chapter 5 binary is a clean 7 bytes. `VERIFICATION.md` should be
updated when the next pass touches it; left untouched here to
preserve the editorial scope of Pass 1.

## Next steps

The skeleton is statically clean. Mesen2 verification (steps 2, 4,
7, and 8 of `VERIFICATION.md`) is the next pass.
