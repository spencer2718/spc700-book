# CHANGES (textbook)

This file tracks changes to the textbook source itself
(`spc700_textbook.md`, `metadata.yaml`, and `preprocess.py`).
It is separate from `assets/CHANGES.md`, which tracks the
companion exercise repository.

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
