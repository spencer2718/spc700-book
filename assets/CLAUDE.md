# CLAUDE.md — spc700-book-assets

## What this is

Companion repository for *The SPC-700 for Aspiring SNES Musicians*,
a textbook teaching the SNES audio CPU from first principles. This
repo contains the runnable exercise assets the book points at:
stub ROM, BRR samples, exercise starter/solution code, and build
scripts.

## Project goal

Make every hands-on exercise in the book a verifiable, runnable
unit. A reader following the book should be able to clone this
repo, follow `docs/INSTALL.md` to install Asar and Mesen2, and
then for each exercise: read the chapter, edit the starter code,
build, load in Mesen2, and observe the documented PASS conditions.

The book is the primary deliverable; this repo is its laboratory.

## Source of truth

The book itself is the spec for what each exercise should teach.
The reviewer-validated correction history in `CHANGES.md` is the
spec for what's been fixed since the original skeleton.

Source-of-truth priority:
- Book chapter > exercise README > PASS_CONDITIONS > solution code

## Status

Pre-alpha. Skeleton scaffolded for Chapters 5 (setup) and 13 (first
sound), corrected once via static review, but not yet
emulator-verified end-to-end. See `STATUS.md` for coverage and
`VERIFICATION.md` for the protocol that promotes the skeleton to
v0.1.0.

## Architecture

```
spc700-book-assets/
├── stub-rom/           65816 cradle that uploads SPC payloads via IPL
├── exercises/
│   ├── ch05_setup/     toolchain verification exercise
│   └── ch13_first_sound/  first audible note exercise
├── tools/              Python helpers (e.g., BRR generators)
├── docs/               install, conventions, memory map, troubleshooting
├── CHANGES.md          chronological correction log
└── VERIFICATION.md     end-to-end test protocol
```

Each exercise is self-contained:
- `start/` — what the reader edits (has TODO markers).
- `solution/` — reference implementation + expected debugger trace.
- `PASS_CONDITIONS.md` — observable acceptance tests.
- `assets/` — any binary data the exercise uses (BRR samples, etc.).

## Conventions

See `docs/CONVENTIONS.md` for the full set. Highlights:
- All SPC-700 sources use `arch spc700` + `norom` + `base` for raw
  payloads. Never `arch spc700-inline`.
- All SPC-700 sources use `$NNNN` for absolute addresses, never
  `!$NNNN` (which is Asar define syntax).
- Stub ROM is 256 KiB, padded with `padbyte $00` and `pad`,
  checksum filled by `checksum auto`.
- Build scripts are short shell scripts; one per exercise.
- Every exercise has explicit PASS conditions. Adding an exercise
  without PASS conditions is incomplete work.

## Build

Each exercise builds locally with its `build.sh`. The stub ROM
builds with its `build.sh`, optionally taking a payload path.

There's no top-level build script yet. If exercises proliferate, a
`make` target per exercise may be appropriate.

## Testing

Manual, in Mesen2, per `VERIFICATION.md`. Once the verified
skeleton lands, future changes should regression-test against the
recorded PASS conditions for affected chapters.

Automated build verification (assemble all exercises, check sizes
match expected) is feasible but not yet implemented. Suggested
location: `tools/check_builds.sh`.

## Pinned tool versions

- Asar 1.81+ (any later release should work; if a specific version
  becomes required, document it here).
- Mesen2 latest stable. Some debugger UI elements may move between
  versions; the book references the *capability* (e.g., "the SPC
  register view") rather than exact menu paths.

## Working with this repo

- Commit at the end of each correction or addition pass.
- One commit per logical change; not one mega-commit per session.
- Use `CHANGES.md` for human-readable history; let git log carry
  the mechanical record.
- Update `STATUS.md` when an exercise's status changes
  (scaffolded → verified, etc.).

## Related

The book itself lives in a separate location (currently a Markdown
file with a Pandoc/XeLaTeX build pipeline producing a PDF). This
repo and the book co-evolve; book editions pin to this repo's
tagged releases.
