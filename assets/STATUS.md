# Repository Status

## Tagged release

This skeleton has not yet been tagged. The first stable tag will be
`v0.1.0` once the Chapter 5 and Chapter 13 paths are verified
end-to-end on real tooling.

## Coverage by chapter

| Ch | Title                                   | Asset status            | Verified? |
|---:|-----------------------------------------|-------------------------|-----------|
| 5  | Interlude: Setting Up                   | scaffolded, builds clean| no        |
| 6  | The Programmer's Model                  | not started             | no        |
| 7  | Boot and Code Loading                   | not started             | no        |
| 8  | Moving Data                             | not started             | no        |
| 9  | Arithmetic                              | not started             | no        |
| 10 | Logic, Shifts, and Bits                 | not started             | no        |
| 11 | Control Flow                            | not started             | no        |
| 12 | The DSP Register Window                 | not started             | no        |
| 13 | Voices, Pitch, and Envelopes            | scaffolded, builds clean| no        |
| 14 | BRR Samples                             | not started       | no        |
| 15 | Echo, Noise, and Pitch Modulation       | not started       | no        |
| 16 | Inter-CPU Communication                 | not started       | no        |
| 17 | Anatomy of a Sound Driver               | not started       | no        |
| 18 | A Composer's Workflow                   | not started       | no        |
| 19 | Tooling, Testing, and SPC Files         | not started       | no        |
| 20 | Debugging an SPC Driver                 | not started       | no        |
| 21 | Embedding the SPC in a Host Application | not started       | no        |

"Scaffolded" means the directory structure, README, starter source,
solution, and PASS_CONDITIONS exist as drafts.

"Builds clean" means the solution source has been assembled by
Asar 1.91 and the resulting binary is the expected size. This is
the static portion of `VERIFICATION.md` (Pass 1). The stub ROM, the
Chapter 5 solution, and the Chapter 13 solution all build clean.

"Verified" means the build passes, the ROM boots, and the
PASS_CONDITIONS have been observed in Mesen2 (Pass 2 — not yet run).

The two scaffolded chapters are the ones the book identifies as the
critical path: Chapter 5 establishes the development workflow, and
Chapter 13 is the first chapter where the reader hears anything. If
those two work, the production approach for the remaining chapters
is validated.
