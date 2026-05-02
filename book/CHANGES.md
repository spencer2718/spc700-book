# CHANGES (textbook)

This file tracks changes to the textbook source itself
(`spc700_textbook.md`, `metadata.yaml`, and `preprocess.py`).
It is separate from `assets/CHANGES.md`, which tracks the
companion exercise repository.

## Pass B — write Chapter 5 prose; establish hands-on chapter template

This pass replaces the Pass A placeholder with the full Chapter 5
(Interlude: Setting Up) prose, and adds a "Try this" subsection at
the end of Chapter 6 that points readers at the companion
repository's `ch06_programmers_model/` exercise. The Chapter 6
"Try this" structure becomes the template for every hands-on
chapter from this point forward — future passes will mirror it
without re-inventing the layout.

### Chapter 5 (Interlude: Setting Up) full prose written

The 17-line italic placeholder is replaced with a ~1400-word
chapter that walks readers through installing Mesen2, Asar, and
the companion repository, then exercises the full edit/build/run/
step loop on a tiny SPC-700 program that writes a single byte to
ARAM. The chapter has no end-of-chapter exercises because the
chapter itself is the exercise.

### "Try this" subsection added to Chapter 6

A new `### Try this` subsection sits between Chapter 6's existing
`### Exercises` and the chapter break. It points readers at
`assets/exercises/ch06_programmers_model/` (a no-code exercise
where readers single-step a ~25-byte payload through the SPC
debugger to observe each piece of programmer-visible state change)
and gives a concrete time estimate. The existing Chapter 6 prose
and conceptual exercises are unchanged.

### What was *not* changed in Pass B

- The PDF was not regenerated. Pass C will rebuild it.
- "Try this" was added only to Chapter 6. Future hands-on chapters
  (7+) will get their own "Try this" subsections in later passes,
  once their corresponding `assets/exercises/chXX_*/` directories
  exist.
- No assets/ files were touched.
- No existing chapter prose was edited beyond the Chapter 5
  placeholder replacement and the Chapter 6 subsection insertion.

### Pass B-fix — Chapter 5 errata

Two drafting bugs in the Pass B Chapter 5 prose were corrected.
First, the `mov   <destination>, <source>` template line was
restored to a fenced code block; in Pass B it landed as bare body
text, where the angle brackets risked being eaten as HTML tags by
some renderers. Second, the single-step walkthrough paragraph
("Press F10 (step) once...") was rewritten to match the actual
`hello.asm` starter — the original prose narrated four steps
through `mov x, #$ff` and `mov sp, x`, which belong to the
Chapter 6 exercise rather than Chapter 5's. The corrected
walkthrough describes the actual three-step sequence (`clrp`,
`mov a, #$42`, the reader's TODO write).

## Pass A — broaden audience, restructure for hands-on companion

This pass reframes the book to admit readers without prior
programming experience and inserts an Interlude chapter (Chapter 5)
that will eventually walk through the tooling needed to run the
companion repository's exercises.

### Title shortened

`The SPC-700 for Aspiring SNES Musicians` → `The SPC-700 for SNES
Musicians`. Updated in `metadata.yaml`, the textbook's top-level
heading, and the preprocessor's title-stripping regex.

### Preface rewritten for math-literate, no-programming audience

The original assumption paragraph framed the reader as a "lapsed
programmer." Replaced with a paragraph that assumes only
mathematical comfort — the book builds CPU concepts from the
ground up regardless of prior programming background. The "Read
in order. The book builds." line is updated to acknowledge that
exercises also build, beginning at Chapter 5.

### Companion repo pointer added to preface

A new paragraph before "Read in order" tells readers that
hands-on exercises live at `https://github.com/spencer2718/spc700-book`,
beginning at Chapter 5, and that the first four chapters do not
need the repository.

### "How to Use This Book" updated

Part II is now described as seven chapters (was six) reflecting
the new Chapter 5. The generic "you will want a SNES emulator
before Part III" sentence is replaced with an explicit pointer
to Chapter 5 as the place where Mesen2, Asar, and the companion
repository are introduced.

### Chapter 5 (Interlude — Setting Up) inserted as placeholder

A short placeholder chapter is inserted between the old Chapter 4
and the old Chapter 5. It explains what the forthcoming Interlude
will cover (installing Asar/Mesen2, cloning the companion repo,
running a first end-to-end SPC program) and gives readers two
paths until the chapter is written: skip directly to the new
Chapter 6, or follow the companion repository's README and run
`exercises/ch05_setup/` directly.

### Chapters 5–18 renumbered to 6–19

The 14 subsequent chapter headings are incremented by one. All
inline cross-references throughout the book are updated to match
the new numbering. The Part II introduction is rewritten (not
mechanically renumbered) to introduce the new seven-chapter
structure.

### Five forward references gain chapter names

Per the cross-reference audit, five forward references now
include the destination chapter's name in addition to its number,
so readers reading linearly know where they are headed:

- mailbox / Chapter 16, Inter-CPU Communication (Chapter 4)
- timers / Chapter 17, Anatomy of a Sound Driver (Chapter 6)
- driver specifics / Chapter 17, Anatomy of a Sound Driver
  (Chapter 7)
- voice-mask lookup table / Chapter 10 (Chapter 17 driver
  pseudocode)
- first-voice example / Chapter 13, Voices, Pitch, and Envelopes
  (Chapter 19 exercise and Appendix E preamble)

Backward references and intra-Part references remain terse.

### Appendix F (Embedding the SPC in a Host Application) placeholder

A placeholder appendix is added after Appendix E. It describes
the planned content (SPC playback vs. live core operation vs.
full SNES stub emulation, real-time threading, sample-rate
conversion, integration with libraries like blargg's `snes_spc`)
and points interested readers at the C700 fork as prior art
until the appendix is written.

### What was *not* changed in Pass A

- The PDF was not regenerated. Pass C will rebuild it after the
  textbook has stabilized.
- The new Chapter 5's actual content (the Interlude prose) was
  not written. Pass B is responsible for that.
- No editorial improvements were made to existing chapter prose
  beyond cross-reference updates.
- Existing appendix lettering A–E was untouched.
- Part headings did not renumber; only chapters within parts.
- No assets/ files were touched.
