; first_sound.asm — Chapter 13 starter
;
; Goal: configure DSP voice 0 to play a 2 kHz sine wave forever.
;
; Most of the setup is already written for you. There are three
; TODO blocks marked below. Your job is to figure out what each one
; should do by reading the comments and consulting Chapter 13.
;
; This file produces a raw SPC payload. The stub ROM uploads the
; payload byte-by-byte to ARAM starting at address $0200, so file
; offset 0 corresponds to ARAM $0200, and ARAM addresses elsewhere
; map to file offsets of (ARAM - $0200). The `org` and `base`
; directives below establish that mapping.

arch spc700
norom

; -----------------------------------------------------------------
; DSP register addresses (Asar defines, prefixed with !)
; -----------------------------------------------------------------

!MVOLL    = $0C
!MVOLR    = $1C
!FLG      = $6C
!DIR      = $5D
!KON      = $4C
!V0VOLL   = $00
!V0VOLR   = $01
!V0PITCHL = $02
!V0PITCHH = $03
!V0SRCN   = $04
!V0ADSR1  = $05
!V0ADSR2  = $06

; -----------------------------------------------------------------
; Code section — file offset $0000, ARAM $0200
; -----------------------------------------------------------------

org $0000
base $0200

start:
    ; ----- 1. CPU init -----
    mov   x, #$ff
    mov   sp, x
    clrp                    ; ensure direct page = $0000-$00FF

    ; ----- 2. Hide the IPL ROM and disable timers -----
    mov   $f1, #$00

    ; ----- 3. Silence the DSP during setup -----
    ; FLG with MUTE and ECHO WRITE DISABLE set, so nothing reaches
    ; the output until we're done configuring, and so any in-flight
    ; echo writes can't corrupt RAM during setup.
    mov   a, #!FLG
    mov   y, #%01100000     ; MUTE | ECHO WRITE DISABLE
    movw  $f2, ya

    ; ----- 4. Configure master volume -----
    mov   a, #!MVOLL
    mov   y, #$7f
    movw  $f2, ya
    mov   a, #!MVOLR
    mov   y, #$7f
    movw  $f2, ya

    ; ----- 5. Set sample directory page -----
    ; The sample directory lives at ARAM $2000, so DIR (the high
    ; byte of the directory's address) should be $20.
    ;
    ; TODO 1: write $20 to DSP register DIR.
    ;
    ; The pattern for any DSP write:
    ;   mov a, #<register>      ; A = DSP register address
    ;   mov y, #<value>         ; Y = value to write
    ;   movw $f2, ya            ; A -> $F2 then Y -> $F3, atomically
    ;
    ; (delete this TODO block and write the three instructions)

    ; ----- 6. Configure voice 0: source, volumes, ADSR -----
    mov   a, #!V0SRCN
    mov   y, #$00           ; sample 0
    movw  $f2, ya

    mov   a, #!V0VOLL
    mov   y, #$7f
    movw  $f2, ya
    mov   a, #!V0VOLR
    mov   y, #$7f
    movw  $f2, ya

    ; ADSR1: bit 7 = enable ADSR, decay = 0, attack = $F (instant).
    mov   a, #!V0ADSR1
    mov   y, #%10001111
    movw  $f2, ya

    ; ADSR2: sustain level = 7 (max), sustain rate = 0 (no decay).
    mov   a, #!V0ADSR2
    mov   y, #%11100000
    movw  $f2, ya

    ; ----- 7. Set voice 0 pitch -----
    ; The pitch register is 14 bits, spread across PITCHL (low 8 bits)
    ; and PITCHH (high 6 bits). For native rate, the value is $1000.
    ;
    ; TODO 2: write the pitch value $1000 to V0PITCHL ($00) and
    ;         V0PITCHH ($10).
    ;
    ; (write six instructions — two DSP writes — to set both halves
    ;  of the pitch register)

    ; ----- 8. Unmute the DSP, but keep echo writes disabled -----
    ; FLG = $20 clears MUTE but leaves ECHO WRITE DISABLE set,
    ; because we haven't configured an echo buffer and we don't
    ; want stray DSP echo writes corrupting RAM. (See SNESdev's
    ; errata about EDL=0 / ESA=0 hazards.)
    mov   a, #!FLG
    mov   y, #$20
    movw  $f2, ya

    ; ----- 9. Key on voice 0 -----
    ; KON is a bitmask: bit N = key voice N. We want bit 0 set.
    ;
    ; TODO 3: write %00000001 to DSP register KON.

    ; ----- 10. Idle forever -----
forever:
    bra   forever

base off

; -----------------------------------------------------------------
; Sample directory at ARAM $2000 (file offset $1E00)
; -----------------------------------------------------------------
; ARAM $2000 - ARAM $0200 = $1E00, so we org to file offset $1E00
; and rebase logical addressing to $2000 for label arithmetic.

org $1E00
base $2000
sample_directory:
    dw    sine_sample          ; SRCN 0 start = $2100
    dw    sine_sample          ; SRCN 0 loop  = $2100 (whole sample loops)
base off

; -----------------------------------------------------------------
; BRR sample data at ARAM $2100 (file offset $1F00)
; -----------------------------------------------------------------

org $1F00
base $2100
sine_sample:
    incbin "sine.brr"
base off
