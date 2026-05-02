# SNES Book Monorepo

Two co-evolving artifacts for *The SPC-700 for SNES Musicians*:

- **`book/`** — the textbook (Markdown source, XeLaTeX build pipeline,
  rendered PDF). 19 chapters, 6 appendices. Builds to PDF via
  Pandoc + XeLaTeX.
- **`assets/`** — the companion code repository. Stub ROM, exercise
  starters and solutions, BRR samples, build scripts, conventions,
  memory map, and verification protocol. Pre-alpha; scaffolded for
  Chapters 5 and 13.

## Why a monorepo

The book and its exercise assets co-evolve. The book references
specific files in `assets/`; the assets reference specific chapters
in the book. Keeping them in one repository means a single commit
can update both sides of an interface, and the git log is the
canonical record of how each side got to where it is.

A future split into separate repositories is possible if the assets
become a published library used outside this textbook. For now,
single-repo discipline is simpler.

## Building

### The book (PDF from Markdown)

```sh
cd book
./build.sh
```

After every push to `main` that touches `book/` contents, CI
rebuilds `book/spc700_textbook.pdf` and commits the updated PDF
back to `main` (under the `spc700-book-ci` bot identity, with
`[skip ci]` in the commit message to avoid re-triggering itself).
The in-repo PDF is therefore always the current rendering of the
source — no manual download needed.

You can build locally with `cd book && ./build.sh` if you want to
preview before pushing. See `book/SYSTEM_DEPENDENCIES.md` for the
Pandoc / XeLaTeX / fonts install. If a push breaks the build, the
failed `Build textbook PDF` workflow on GitHub Actions is the
diagnostic.

### The exercises

See `assets/README.md` and `assets/docs/INSTALL.md`.

Briefly: install Asar (1.81+) and Mesen2, then for each exercise:

```sh
cd assets/exercises/chXX_<name>/start
./build.sh
cd ../../../stub-rom
./build.sh ../exercises/chXX_<name>/start/<payload>.bin
# load assets/stub-rom/stub.sfc in Mesen2
```

## Status

The book is in a stable corrected state — fully audited against
SNESdev/fullsnes references, with all known technical errors
addressed in prior revision passes.

The assets repo is at v0.1.0-skeleton-corrected: scaffolded for
Chapters 5 and 13, statically reviewed and corrected once, awaiting
end-to-end verification on real Asar and Mesen2 tooling. See
`assets/VERIFICATION.md` for the protocol that promotes the
skeleton to v0.1.0, and `assets/STATUS.md` for chapter coverage.

## Roadmap

After v0.1.0 is verified, additional exercises are planned to
follow the structure proposed in the book's revision plan: one
hands-on exercise per chapter from Ch 6 onward, plus new chapters
on debugging (Ch 20) and embedding the SPC in a host application
(Ch 21).

## License

- **Book** (Markdown source, PDF, build scripts): authored content;
  license to be set by the book's author.
- **Assets code** (assembly, build scripts, Python tooling, BRR
  data): MIT. See `assets/LICENSE`.
- **Assets documentation** (READMEs, conventions, memory map,
  walkthroughs): CC-BY-4.0. See `assets/LICENSE-docs`.
