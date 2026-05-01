# Conventions

These conventions apply to every assembly file in this repository.
They are not hardware requirements; they are *style* requirements.
Reading code is much easier when everyone agrees on a set of habits.

If you're working through the book and writing your own SPC code,
adopting these conventions will make your code easier for both
humans and assistants to review.

## Routine documentation block

Every routine starts with a comment block describing its contract:

```asm
; describe_one_line_purpose
;
; Inputs:
;   A          = (description)
;   X          = (description)
;   Y          = (description)
;   $30/$31    = 16-bit pointer to (description)
;
; Outputs:
;   A          = (description)
;   carry      = (set on success / clear on failure / etc.)
;
; Clobbers:
;   X, Y, $32, $33
;
; Preserved:
;   (anything not listed in Clobbers is preserved)
;
; DSP writes:
;   $4C (KON)  -- only if a key-on is staged
;
; Notes:
;   - any tricky preconditions
;   - any flag dependencies
my_routine:
    ; ... code ...
    ret
```

Not every field is mandatory on every routine. Tiny helpers can omit
sections that are obvious. But the larger or more subtle the routine,
the more important the contract block becomes.

The single most important field is **Clobbers**. If a routine writes
to A, X, Y, or any direct-page byte, the contract must say so.
Surprise clobbers are the most common cause of "code that worked
yesterday breaks today after a small change."

## Direct-page allocation

The repository uses a shared direct-page memory map declared in
`docs/MEMORY_MAP.md` and replicated as an `.inc` file inside each
exercise. Direct-page bytes have *names*, not numeric addresses, in
all source code:

```asm
; good
mov   a, last_cmd

; bad
mov   a, $10
```

If you need a direct-page byte that isn't in the map, add it to the
map (in a comment if not in the actual `.inc`) before using it.

## Register conventions for DSP writes

The DSP write idiom is consistent throughout the repo:

```asm
mov   a, #<reg>     ; A = DSP register address
mov   y, #<value>   ; Y = value to write
movw  $f2, ya       ; the actual write
```

Helper subroutines are named `dsp_write_<reg>` when the register is
fixed and just `dsp_write` (with A=reg, Y=value) when generic.

## Flag conventions

When a routine returns a status, it uses the carry flag:
- C=0 means success
- C=1 means failure or a recoverable error

This is opposite the SBC borrow convention. Document it clearly in
each routine's contract.

When a routine returns a "found" / "not found" result, it uses the
zero flag with the same convention as `CMP`:
- Z=1 means found / equal
- Z=0 means not found / not equal

Routines that don't return any status leave flags undefined. Don't
rely on flag state from arbitrary subroutines unless their contract
says so.

## Comments

- A comment after `;` explaining *why*, not *what*. The instruction
  itself says what; the comment says why this instruction is here.
- A blank line before each logical section within a routine.
- An end-of-routine `ret` is always on its own line, never sharing a
  line with another instruction.

## File organization

Each `.asm` source file:
1. Begins with a one-line file purpose comment.
2. Then `arch spc700-inline` (or `arch spc700`, depending on which
   variant of Asar's syntax we end up standardizing on).
3. Then `incsrc` for any shared definition files.
4. Then the actual code, organized as: data tables first, code routines
   after.
5. Ends with a final newline.

## Building

Every exercise has a `build.sh` script that runs Asar with the right
arguments. The script is identical across exercises except for the
input/output filenames. Don't reinvent it per exercise.

```bash
#!/bin/sh
# build.sh
set -e
asar -werror first_sound.asm first_sound.bin
echo "Built first_sound.bin ($(wc -c < first_sound.bin) bytes)."
```

The `set -e` ensures the script fails loudly on any error. The
`-werror` flag tells Asar to treat warnings as errors, which catches
addressing-mode mistakes that would otherwise produce mysterious
runtime behavior.
