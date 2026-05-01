# spc700-book-assets

Companion repository for *The SPC-700 for Aspiring SNES Musicians*.

This repo contains the runnable code, ROM templates, BRR samples,
build scripts, and reference solutions referenced by the book's
hands-on exercises. The book treats this repo as a stable resource:
each published edition pins to a tagged release.

> **Status: pre-alpha.** Currently scaffolded for Chapters 5 and 13.
> The complete asset set covering all hands-on chapters is in
> progress. See `STATUS.md` for the coverage map and `VERIFICATION.md`
> for the protocol that promotes the skeleton to v0.1.0.

## What is this for?

The book teaches how the SPC-700 (the SNES audio CPU) works. From
Chapter 5 onward, every chapter pairs explanation with a hands-on
exercise: assemble a tiny SPC program, load it into an emulator,
watch specific things happen. This repo holds the assemblable,
runnable, and listenable assets for those exercises.

You should not need to write any 65816 (main SNES CPU) code. A small
"stub ROM" in this repo handles the main CPU side: it boots, uploads
your SPC payload through the IPL handshake, hands off execution to
the SPC, and idles. From your point of view as the reader, the stub
ROM is a cradle. You write SPC code; the stub ROM gets it running.

## Required tools

- **Asar** (assembler), version 1.81 or later. Native SPC-700 support.
- **Mesen2** (emulator with debugger). Latest release recommended.
- **make** or any system that runs a short shell script.
- **A text editor.** Any editor.

Specific install instructions per platform live in `docs/INSTALL.md`.

## Repository layout

```
spc700-book-assets/
├── README.md                       <- this file
├── STATUS.md                       <- per-chapter completion tracker
├── VERIFICATION.md                 <- end-to-end test protocol
├── docs/
│   ├── INSTALL.md                  <- platform-by-platform tool setup
│   ├── MEMORY_MAP.md               <- the canonical ARAM memory map
│   ├── TROUBLESHOOTING.md          <- "my exercise doesn't work"
│   └── CONVENTIONS.md              <- register/clobber/flag conventions
├── tools/
│   └── make_sine_brr.py            <- generates ch13's sine.brr
├── stub-rom/
│   ├── README.md                   <- what the stub ROM does
│   ├── stub.asm                    <- main 65816 source
│   ├── ipl_upload.asm              <- the IPL upload protocol
│   └── build.sh                    <- assembles the stub ROM
└── exercises/
    ├── ch05_setup/
    │   ├── README.md
    │   ├── PASS_CONDITIONS.md
    │   ├── start/{hello.asm, build.sh}
    │   └── solution/{hello.asm, trace.txt}
    └── ch13_first_sound/
        ├── README.md
        ├── PASS_CONDITIONS.md
        ├── assets/{sine.brr, sine.brr.notes.md}
        ├── start/{first_sound.asm, build.sh}
        └── solution/{first_sound.asm, expected_dsp.md}
```

## How to use it

For each chapter exercise:

1. Read the chapter in the book.
2. `cd exercises/chXX_<name>` and read the `README.md` there.
3. Look at `start/` and `PASS_CONDITIONS.md`.
4. Edit the starter file (the TODOs are marked).
5. Build with `./build.sh` from the `start/` directory.
6. Build the stub ROM around your payload:
   ```sh
   cd ../../../stub-rom
   ./build.sh ../exercises/chXX_<name>/start/<payload>.bin
   ```
7. Load `stub-rom/stub.sfc` in Mesen2 and follow the chapter's
   debugger walkthrough.
8. If stuck, compare with `solution/`. The trace and expected-DSP
   files show what the SPC should be doing at key moments.

## Versioning

This repo uses semantic versioning: `vMAJOR.MINOR.PATCH`. The book
edition you are reading targets a specific tagged release. If you
fetch `main` and find that filenames or stub ROM behavior differ
from what the book describes, switch to the tagged release that
matches your book edition.

## License

Code (assembly sources, build scripts, the BRR generator): MIT.

Documentation (README files, conventions, memory map, exercise
walkthroughs, BRR notes): CC-BY 4.0.

The `LICENSE` file at repo root contains the MIT text. Documentation
files are CC-BY by inclusion in this repository, attributable to the
book author.

## Asset author's note

The skeleton was produced before any of it was tested end-to-end on
real tooling. The expected workflow is:

1. The author builds the stub ROM and verifies upload to SPC.
2. The author runs the Chapter 5 exercise and confirms ARAM state.
3. The author runs Chapter 13 and confirms the sine wave is audible.
4. Only after that path is proven does the rest of the asset set
   get built out.

This is a deliberately conservative production order. It costs more
total time but avoids shipping exercises that subtly don't work.
