# Installation

You need three things: an assembler, an emulator, and the contents of
this repository. None of them are large.

## Asar (the assembler)

Asar is a small command-line assembler with native SPC-700 support.
The book's exercises target Asar 1.81 or later.

### Windows

1. Visit the Asar releases page on GitHub: <https://github.com/RPGHacker/asar/releases>
2. Download the most recent `asar-vX.Y.Z-windows.zip`.
3. Extract to a folder of your choice, e.g. `C:\tools\asar\`.
4. Add that folder to your `PATH` so you can run `asar` from any
   directory.

To verify: open a terminal and run `asar --version`. You should see
something like `asar 1.81 (...)`.

### Linux

Most distributions don't package Asar, so you build from source. It's
small and fast to build.

```bash
git clone https://github.com/RPGHacker/asar.git
cd asar
make -C src
sudo cp src/asar /usr/local/bin/
asar --version
```

### macOS

Same as Linux — build from source. Asar's Makefile uses standard
POSIX tools and builds with the system `clang`.

```bash
git clone https://github.com/RPGHacker/asar.git
cd asar
make -C src
cp src/asar /usr/local/bin/   # or somewhere on your PATH
asar --version
```

If you don't have Xcode command line tools, install them first with
`xcode-select --install`.

## Mesen2 (the emulator)

Mesen2 is a multi-system emulator with an excellent SNES debugger.
The SPC-700 debugger features (memory view, register view, breakpoints
on SPC code, DSP register inspection) are what the book's exercises
depend on.

### Windows

1. Visit the Mesen2 releases page: <https://github.com/SourMesen/Mesen2/releases>
2. Download the most recent `Mesen.zip` (the standard build).
3. Extract anywhere. Run `Mesen.exe`.
4. On first launch, Mesen2 may ask you to install the .NET runtime if
   you don't have it. Follow the prompts.

### Linux

Mesen2 ships AppImage builds for Linux. Download the most recent
`Mesen.AppImage` from the releases page, mark it executable
(`chmod +x Mesen.AppImage`), and run it. No installation needed.

If the AppImage doesn't work on your distribution, build from source
following the project's BUILDING.md.

### macOS

Mesen2 has experimental macOS support but does not ship a notarized
binary. You have two options:

1. **Build from source.** Clone the repo, install the .NET 8 SDK,
   and run the build commands in the project README. This is the
   path that produces the most native-feeling experience.

2. **Run the Windows version under CrossOver / Wine.** This works
   well in practice and avoids the build complexity. CrossOver is
   commercial; Wine is free.

Both paths give you a working Mesen2 with the SPC debugger. Choose
based on your tolerance for build complexity vs. compatibility-layer
quirks.

## The companion repository

```bash
git clone https://github.com/<author>/spc700-book-assets.git
cd spc700-book-assets
```

The book targets a specific tagged release. Check the book's preface
for the version tag, and:

```bash
git checkout v0.1.0   # or whichever tag matches your edition
```

If you're following along with a draft edition that hasn't pinned a
release yet, work from `main`.

## Verifying everything works

The Chapter 5 exercise is designed to verify your full toolchain in
about five minutes. After installing the tools above, follow
`exercises/ch05_setup/README.md`. If you can build and run the
exercise and see ARAM change in Mesen2, your setup is good for the
rest of the book.

If something doesn't work, see `docs/TROUBLESHOOTING.md`.
