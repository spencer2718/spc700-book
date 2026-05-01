; stub.asm — minimal SNES ROM that uploads an SPC payload and idles.
;
; Audience: this file is part of the book's companion repository. The
; book itself does not require readers to understand 65816 assembly.
; This file exists so book exercises can run real SPC code on real
; emulators (and, eventually, real hardware) without each reader
; having to build their own ROM scaffolding.
;
; Architecture: 65816 in native mode for the boot sequence, with
; interrupts disabled throughout. The SPC payload is embedded into
; the ROM; this code uploads it via the standard IPL protocol.
;
; Build: this file is assembled by build.sh together with
; ipl_upload.asm. Do not assemble it standalone.

arch 65816
lorom

; -----------------------------------------------------------------
; Build-time configuration
; -----------------------------------------------------------------

!SPC_PAYLOAD_SIZE  = !PAYLOAD_SIZE  ; defined by build.sh's -D flag
!SPC_ENTRY         = $0200          ; ARAM address to start executing at
!ROM_SIZE_BYTES    = $40000         ; 256 KiB ROM

; -----------------------------------------------------------------
; ROM padding
; -----------------------------------------------------------------
; By default, Asar only writes regions that have actual data. We
; want a fully-padded 256 KiB ROM, so we set the fill byte to $00
; (any gap between written regions becomes $00) and anchor the file
; size with a sentinel byte at the very end of the LoROM space.

padbyte $00

; -----------------------------------------------------------------
; Reset vector — first code that runs on power-on
; -----------------------------------------------------------------

org $008000
reset:
    sei                         ; interrupts off
    cld                         ; binary mode for ADC
    clc                         ; clear carry to enter native mode
    xce                         ; switch to native 65816
    rep #$30                    ; 16-bit A and 16-bit X/Y

    ldx #$1FFF                  ; set up stack at $1FFF
    txs

    sep #$20                    ; 8-bit A
    rep #$10                    ; keep 16-bit X/Y

    ; Set the data bank register to $00.
    lda #$00
    pha
    plb

    ; Disable NMI/IRQ/joypad-auto-read; force blank with brightness 0.
    lda #$00
    sta $4200                   ; NMITIMEN
    lda #$8F
    sta $2100                   ; INIDISP

    ; Hand off to the SPC upload routine.
    jml spc_upload_entry

; -----------------------------------------------------------------
; SPC upload routine
; -----------------------------------------------------------------

incsrc "ipl_upload.asm"

; -----------------------------------------------------------------
; Idle loop
; -----------------------------------------------------------------

idle_forever:
    wai                         ; wait for interrupt (none come,
                                ; since we disabled them). Effectively
                                ; a low-power halt.
    bra idle_forever

; -----------------------------------------------------------------
; Embedded SPC payload
; -----------------------------------------------------------------
; The build script writes the SPC payload binary to spc_payload.bin
; in the same directory as this source. We `incbin` it at a known
; ROM offset so the upload code can read it via long indexed
; addressing.

org $018000
spc_payload_start:
    incbin "spc_payload.bin"
spc_payload_end:

; -----------------------------------------------------------------
; ROM header at $00FFC0-$00FFFF (LoROM file offset $7FC0-$7FDF)
; -----------------------------------------------------------------
; The SNES requires specific values at specific addresses for the
; console to recognize the cartridge. The checksum and its inverse
; are filled in by Asar at assembly time, driven by the
; --fix-checksum=on flag passed by build.sh.

org $00FFC0
db "SPC700 BOOK STUB     "      ; 21-byte title, padded with spaces
db $20                          ; LoROM, no FastROM
db $00                          ; ROM type: ROM only
db $08                          ; ROM size: 256 KiB indicator
db $00                          ; SRAM size: none
db $01                          ; country: USA
db $33                          ; license code
db $00                          ; ROM version

; Checksum and inverse fields. Placeholder zeros; build.sh runs
; Asar with --fix-checksum=on, which overwrites these with the
; computed values at the end of assembly.
dw $0000                        ; checksum complement
dw $0000                        ; checksum

; Native-mode vectors
org $00FFE0
dw $0000, $0000, reset, reset, reset, reset, $0000, reset

; Emulation-mode vectors
org $00FFF0
dw $0000, $0000, reset, $0000, reset, reset, reset, reset

; -----------------------------------------------------------------
; Force the file size to !ROM_SIZE_BYTES by writing one byte at the
; final ROM offset. In LoROM, ROM offset $3FFFF (the last byte of a
; 256 KiB ROM) maps to SNES address $07:FFFF. Asar fills any gap with
; `padbyte` (set to $00 above).
; -----------------------------------------------------------------

org $07FFFF
db $00

; -----------------------------------------------------------------
; The SNES header checksum is generated automatically by Asar when
; invoked with --fix-checksum=on (see build.sh).
; -----------------------------------------------------------------
