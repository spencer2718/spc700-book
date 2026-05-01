; first_sound.asm — Chapter 13 reference solution.

arch spc700
norom

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

org $0000
base $0200

start:
    mov   x, #$ff
    mov   sp, x

    mov   $f1, #$00

    ; Mute and disable echo writes during setup.
    mov   a, #!FLG
    mov   y, #%01100000
    movw  $f2, ya

    ; Master volume both channels max.
    mov   a, #!MVOLL
    mov   y, #$7f
    movw  $f2, ya
    mov   a, #!MVOLR
    mov   y, #$7f
    movw  $f2, ya

    ; Sample directory at page $20.
    mov   a, #!DIR
    mov   y, #$20
    movw  $f2, ya

    ; Voice 0 source = sample 0.
    mov   a, #!V0SRCN
    mov   y, #$00
    movw  $f2, ya

    ; Voice 0 volumes both max.
    mov   a, #!V0VOLL
    mov   y, #$7f
    movw  $f2, ya
    mov   a, #!V0VOLR
    mov   y, #$7f
    movw  $f2, ya

    ; ADSR: enable, attack=$F, decay=0, sustain=7, sustain rate=0.
    mov   a, #!V0ADSR1
    mov   y, #%10001111
    movw  $f2, ya
    mov   a, #!V0ADSR2
    mov   y, #%11100000
    movw  $f2, ya

    ; Voice 0 pitch = $1000 (native rate).
    mov   a, #!V0PITCHL
    mov   y, #$00
    movw  $f2, ya
    mov   a, #!V0PITCHH
    mov   y, #$10
    movw  $f2, ya

    ; Unmute output, keep echo writes disabled.
    mov   a, #!FLG
    mov   y, #$20
    movw  $f2, ya

    ; Key on voice 0.
    mov   a, #!KON
    mov   y, #%00000001
    movw  $f2, ya

forever:
    bra   forever

base off

org $1E00
base $2000
sample_directory:
    dw    sine_sample
    dw    sine_sample
base off

org $1F00
base $2100
sine_sample:
    incbin "sine.brr"
base off
