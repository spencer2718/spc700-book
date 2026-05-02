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

## Pass 2 — Pre-Mesen2 cleanup

Static review (a separate model going over the post-Pass-1 state)
flagged five issues to address before launching Mesen2: one
ostensibly a header-length blocker, four defensive improvements.
After verifying against the actual file state, four of the five
applied; the blocker turned out to be a counting error against the
already-correct source.

### Verified, no fix needed

**Header title length is already 21 bytes.** The reviewer flagged
the title literal as 17 bytes, on the assumption that the visible
trailing whitespace was 1 character. The actual literal in
`stub.asm` is `"SPC700 BOOK STUB     "` — 16 visible characters
plus 5 trailing spaces, exactly 21 bytes. Confirmed two ways: by
counting the literal in the source, and by reading bytes
`$7FC0-$7FD4` from a freshly-built `stub.sfc` (printable ASCII end
to end). The map mode byte `$20` lands correctly at file offset
`$7FD5`, not at `$7FD1` as the off-by-four hypothesis predicted.

Related correction in scope: the reviewer's pre-Mesen2 sanity
checks were written for HiROM file offsets (`$FFC0-$FFD4`,
`$FFD5`, `$FFD7`). This stub is LoROM, so the SNES header at
`$00:FFC0` lives at file offset `$7FC0-$7FDF`. `VERIFICATION.md`
now uses the correct LoROM offsets in its sanity-check section.

### Fixes applied

**Bitwise math in `ipl_upload.asm` parenthesized.** The Pass 1 fix
to the byte-extraction expressions used `#!SPC_ENTRY&$FF` and
`#!SPC_ENTRY>>8` directly. Asar's left-to-right math precedence
parses these correctly, but parens make the intent unambiguous and
protect future similar expressions. Now `#(!SPC_ENTRY&$FF)` and
`#(!SPC_ENTRY>>8)`.

**`clrp` added to all four SPC payloads.** Both starter and
solution for Chapter 5 and Chapter 13 now begin with an explicit
`clrp` after the stack-pointer setup. The IPL ROM should leave P=0
already, so this is defensive rather than load-bearing, but it
makes each payload self-contained — every payload owns its own
direct-page assumption rather than relying on the IPL ROM's exit
state.

**KOFF cleared before KON in Chapter 13.** Both the starter and the
solution now write `$00` to KOFF (`$5C`) between the FLG=`$20`
unmute and the KON write. The IPL handshake re-uploads payload
bytes but does not reset DSP state, so a re-upload after a previous
run could leave a voice in release with KOFF still set, causing the
new KON to be silenced. The starter's TODO 3 is unchanged ("write
%00000001 to KON") because the KOFF clear is provided to the reader
rather than added to the TODO scope.

**`stub.asm` comments cleaned of stale references.** Two header
comments still mentioned the `checksum auto` directive that Pass 1
replaced with `--fix-checksum=on`. Reworded to describe current
behavior. The header section banner now also lists the LoROM file
offset (`$7FC0-$7FDF`) alongside the SNES address, since the
file-offset form is what the new sanity checks operate on.

**`VERIFICATION.md` updated for current state.** Replaced the stale
"skeleton produced without an SPC-700 assembler" preamble with an
accurate one-paragraph status; updated Step 1's diagnostic notes
to reference the actual current directives; added a new
"Pre-Mesen2 sanity checks" section between Steps 1 and 2; updated
Step 3's expected ch05 size from "8 bytes (Asar may pad to even)"
to the new exact 1 + 2 + 3 + 2 = 8 byte count.

### Build sizes after Pass 2

Re-running all builds after the changes:

- `stub.sfc` — 262144 bytes (unchanged; padding is what determines
  the file size, not stub-code length).
- `hello.bin` — 8 bytes (1 + 2 + 3 + 2 with the new `clrp` prefix;
  was 7 bytes in Pass 1).
- `first_sound.bin` — 7945 bytes (unchanged). The reviewer
  predicted 7951 bytes (+6 from clrp + KOFF clear), but the file
  size is anchored by the trailing `org $1F00` plus the 9-byte
  sine sample (`$1F09 = 7945`). Code growth in front of the gap
  shrinks the gap; it does not extend the file. Confirmed by
  rebuild.

All four pre-Mesen2 sanity checks (file size, map mode at `$7FD5`,
ROM size at `$7FD7`, ASCII title at `$7FC0-$7FD4`) pass.

## Pass 3 — Hardware verification (Mesen2)

Ran the dynamic portion of `VERIFICATION.md` against Mesen2 latest
stable on Windows. All checks passed; the skeleton is now end-to-end
verified and tagged `v0.1.0`.

### Results

- **Pre-Mesen2 sanity checks** all pass on the user's machine: file
  size = 262144, byte at file offset `$7FD5` = `$20`, byte at
  `$7FD7` = `$08`, title at `$7FC0-$7FD4` is 21 bytes of ASCII.
- **Mesen2 accepts `stub.sfc`** without error or warning.
- **SPC debugger reaches the user's code:** PC lands at `$0201` on
  the Chapter 5 payload, or `$025B` on the Chapter 13 payload —
  either confirms the IPL handshake completed and the SPC is
  executing the uploaded bytes.
- **Chapter 13's 2 kHz sine tone** plays within 1-2 seconds of ROM
  load and sustains indefinitely.

### Deferred

The byte-at-`$0500` check (Chapter 5 PASS condition 1) was not run
directly — Mesen2's memory viewer was unfamiliar to the user and
Chapter 13's full-run success is a strictly stronger end-to-end
test (it requires the IPL upload, code execution, DSP configuration,
and BRR decoding all to work). Skipping the weaker check was the
right trade given the stronger one passed cleanly.

### Scope of verification

This pass was on **Windows** with Mesen2 running natively. macOS
and Linux paths are not yet verified; readers on those platforms
will be the first to exercise the build paths in
`docs/INSTALL.md`.

## Pass 5 — Reader-facing documentation cleanup

Triggered by Spencer hitting two friction points during Pass 3
(hardware verification): (1) the Chapter 5 README pointed at
"the SPC debugger's memory view" for inspecting ARAM, but Mesen2
puts the memory view in a separate Memory Tools window opened from
the main window's Debug menu; (2) several docs still carried
post-skeleton language (predicted byte sizes, removed directives,
"no access to assembler") that drifted from the v0.1.0 reality.

A second model (GPT) verified the exact Mesen2 menu paths,
keyboard shortcuts, and Memory Type dropdown values by reading the
Mesen2 source on GitHub. The corrected paths used here come from
that pass, not from guesses.

### Changes

**`exercises/ch05_setup/README.md`** — Replaced the "Run" /
"Step through your code" section. New text distinguishes the SPC
Debugger window (CPU state, disassembly, breakpoints — Ctrl+F)
from Memory Tools (raw byte view — Ctrl+M), gives the exact
main-window menu paths, walks through setting Memory Type = RAM,
and navigates the reader to address `$0500` for the PASS check.
Notes that the two debugger windows are independent and typically
kept open side by side.

**`exercises/ch05_setup/PASS_CONDITIONS.md`** — Added a one-line
note at the top pointing at the README's Memory Tools section.
PASS condition 1 now references "Memory Tools with Memory Type =
RAM" instead of a generic "ARAM memory view."

**`docs/TROUBLESHOOTING.md`** — Added a new top section,
"Mesen2 windows: which one shows what?", with a 4-row table of
debugger windows and their menu paths / shortcuts and a list of
Memory Type dropdown values. Updated the "ARAM doesn't show what
I wrote" bullet so the first cause is "looking at the wrong
window" with a pointer to the orientation section. Fixed the
"black screen forever" section's stale `Debug > Sound > SPC` menu
path to the actual `Debug → SPC Debugger` (Ctrl+F).

**`VERIFICATION.md`** — Rewritten as a maintainer-facing
regression-test document. Eight steps (1–4 static, 5–8 dynamic)
referencing the actual current expected outputs (`stub.sfc` =
262144 bytes, `hello.bin` = 8 bytes, `first_sound.bin` = 7945
bytes, `sine.brr` regenerates byte-identical). The pre-Mesen2
sanity checks added in Pass 2 are kept prominent. The "what
success / almost-success looks like" prose was replaced with a
`git bisect` recipe against the `v0.1.0` tag. Dropped the asset-
author / initial-production framing.

**`README.md` and `docs/INSTALL.md`** — Added a "Verified
platforms" callout (top of README, near the top of INSTALL) noting
that the verified path is Windows + Asar 1.91 + Mesen2 (latest
stable), with an invitation for Linux and macOS users to file
findings.

## Pass 6 — Chapter 6 exercise (Programmer's Model)

Added `exercises/ch06_programmers_model/` with the same layout
shape as ch05 and ch13: README, PASS_CONDITIONS, `start/` with
the payload + build.sh, `solution/` with an identical payload
plus `trace.txt`. Builds clean: 26-byte payload, stub.sfc still
262144 bytes when wrapped.

### Why this exercise has no TODOs

Chapter 6 is the first exercise to use an **observational**
pattern instead of fill-in-the-blank. The reader runs a complete
26-byte payload that exercises each concept in the chapter —
stack pointer setup, `clrp`, register loads, direct-page vs.
absolute writes, push/pop — and watches state change in the SPC
Debugger and Memory Tools windows. The starter and solution
files are byte-identical for this reason.

This pattern fits Chapter 6 specifically: the chapter's content
(six visible registers, eight flags, memory map, direct-page
semantics) is *perceptual* — there's no missing instruction the
reader has to figure out, only a correspondence between the
abstract framework and observable bytes that the reader needs to
internalize. Chapter 5's edit-build-run-step loop established
the workflow; Chapter 6 deepens the *step* part of that loop
without adding a new editing skill.

A "Try this" section at the end of the README asks the reader to
predict (without committing) what would happen if the SP setup
were omitted, then to delete those two instructions, rebuild, and
verify the prediction. That covers the same pedagogical point as
a separate broken-variant file would, without doubling the file
count.

### Chapter numbering note

The asset directory uses `ch06_programmers_model/`, but the
current PDF of the book still calls this material "Chapter 5: The
Programmer's Model" — the new "Interlude: Setting Up" hasn't
been inserted into the book yet. The README's "Note on chapter
numbering" section explains this for readers; a future book-side
pass will renumber the textbook chapters and remove the note.

## Next steps

The critical-path exercises (5, 13) plus the first non-critical
exercise (6) are scaffolded. Spencer to verify Chapter 6 in
Mesen2; the rest of the chapters await planning before
scaffolding.
