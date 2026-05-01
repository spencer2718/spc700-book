# Stub ROM

This is a minimal SNES ROM whose only job is to upload an SPC payload
to the audio CPU and then idle forever. Readers of the book do not
need to understand the 65816 (main SNES CPU) or write any 65816 code
themselves — the stub ROM handles all of that.

## What it does

1. Performs the standard SNES boot setup (sets up the stack, clears
   registers, configures basic video to a known state).
2. Waits for the SPC's IPL ROM to write the magic bytes `$AA $BB` to
   ports `$2140`/`$2141`, indicating the audio subsystem is ready.
3. Initiates the IPL upload protocol (writes `$CC` to port `$2140`).
4. Streams the embedded SPC payload to the SPC, byte by byte, with
   the synchronization counter through port `$2140`.
5. Sends the entry-point address and tells the SPC to start
   executing.
6. Disables interrupts and enters an infinite loop on the main CPU.

The SPC, from this point on, is running your code with no further
involvement from the main CPU.

## What it does NOT do

- It does not render anything to the screen. The screen stays
  whatever color the SNES leaves it on reset (typically black).
- It does not respond to controller input.
- It does not communicate with the SPC after the initial upload.
  (Chapter 16's exercise extends the stub ROM to send commands.)
- It does not handle interrupts.

The intent is for the stub to be as small and unobtrusive as
possible. Every byte of complexity in the stub is one more byte that
could go wrong without you knowing it.

## Building

```bash
./build.sh path/to/spc_payload.bin
```

This produces `stub.sfc`, a 256 KiB SNES ROM with the specified SPC
payload embedded at a known offset. Load `stub.sfc` in Mesen2 to run
your SPC code.

If you don't pass an SPC payload, the stub builds with a 1-byte
"do-nothing" payload (`STOP` at `$0200`). The SPC will hang on that
instruction, which is fine for verifying the stub itself works.

## Embedded payload constraints

- **Maximum size:** about 60 KiB. The full ARAM is 64 KiB but the
  IPL ROM, stack, and direct page take some of that. In practice
  any payload under 50 KiB is safe; the stub's upload code has no
  fixed upper bound.
- **Entry point:** `$0200` by convention. The book's exercises all
  use `$0200`. If you need a different entry point, edit the
  `SPC_ENTRY` define in `stub.asm`.
- **Format:** raw binary. The first byte of the payload becomes the
  byte at ARAM address `$0200`, the second at `$0201`, and so on.
  No header, no checksums, no relocation.

## Memory layout of the ROM itself

The 256 KiB ROM consists of:

```
$00:8000-$00:80FF   (256 bytes) Reset vector and minimal init
$00:8100-$00:81FF   (256 bytes) IPL upload routine
$00:8200-$00:82FF   (256 bytes) Idle loop
$00:8300-$00:8FFF   unused, padded with $FF
$01:0000-...        Embedded SPC payload (filled in by build.sh)
$1F:8000-$1F:FFFF   ROM header and required vectors
```

The build script handles padding and header generation; you should
not need to modify these layout details.
