; hello.asm — Chapter 5 starter
;
; Goal: write the byte $42 to ARAM address $0500, then loop forever.
;
; This file has one line for you to complete. The line is marked
; with TODO. Read the surrounding code, figure out what instruction
; should go there, and replace the TODO line with that instruction.
;
; You can refer to the book's Chapter 8 (Moving Data) for MOV syntax.
; The instruction you need has the form
;
;     mov   <destination>, <source>
;
; where <destination> is an absolute memory address and <source> is
; the A register.

arch spc700
norom

; The output binary is uploaded raw to ARAM starting at address $0200.
; File offset $0000 corresponds to ARAM address $0200, so we use
; `org $0000` for the file output and `base $0200` for SPC-side
; addressing. Asar's `base` directive offsets labels for the
; assembler's address arithmetic without changing where bytes land
; in the file.
org $0000
base $0200

start:
    mov   a, #$42       ; A = $42
    ; TODO: write A to ARAM address $0500
    ;       hint: the form is `mov <abs>, a` with a 16-bit address.

forever:
    bra   forever       ; loop here forever

base off
