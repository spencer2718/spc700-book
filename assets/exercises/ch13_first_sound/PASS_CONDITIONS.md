# Chapter 13: Pass Conditions

The exercise is complete when **all** of the following hold,
verifiable in Mesen2's SPC and DSP debuggers shortly after the
ROM is loaded.

## PASS condition 1 (audible): a steady 2 kHz tone is playing

This is the actual end goal. Listen for a sustained, slightly
buzzy sine wave. If you hear it, the exercise passes regardless
of the remaining checks.

```
PASS:  Audible, sustained 2 kHz tone.
FAIL:  Silence, or noise that doesn't sound like a sine.
```

## PASS condition 2 (DSP state): main mix is enabled

```
DSP $0C (MVOLL)  ==  $7F
DSP $1C (MVOLR)  ==  $7F
DSP $6C (FLG)    ==  $20    ; unmuted, echo writes still disabled
```

If FAIL: the master-volume / unmute setup didn't run, or the
unmute write used the wrong value.

## PASS condition 3 (DSP state): voice 0 is configured

```
DSP $00 (V0VOLL)   ==  $7F
DSP $01 (V0VOLR)   ==  $7F
DSP $02 (V0PITCHL) ==  $00
DSP $03 (V0PITCHH) ==  $10
DSP $04 (V0SRCN)   ==  $00
DSP $05 (V0ADSR1)  ==  $8F   (ADSR enabled, decay=0, attack=$F)
DSP $06 (V0ADSR2)  ==  $E0   (sustain level=7, sustain rate=0)
```

If FAIL: one of the per-voice setup writes is wrong, or one of
the TODO lines is unfilled.

## PASS condition 4 (DSP state): voice 0 is keyed on

After the KON write, the voice's envelope should ramp up:

```
Within ~1 ms of KON, DSP $08 (V0ENVX) > $00
Within ~10 ms of KON, DSP $08 (V0ENVX) approaches $7F
DSP $09 (V0OUTX) is non-zero and oscillates
```

If FAIL but conditions 2 and 3 hold: the KON write went to the
wrong register, set the wrong bit, or never ran at all.

## PASS condition 5 (sample directory): SRCN 0 points at the BRR

```
DSP $5D (DIR)              ==  $20
ARAM $2000-$2003 (entry 0) ==  $00 $21 $00 $21
                           ; (start = $2100, loop = $2100)
ARAM $2100 (BRR header)    ==  $C3
ARAM $2101-$2108 (data)    ==  $02 $46 $66 $42 $0E $CA $AA $CE
```

If FAIL: the sample didn't get embedded into the payload at the
right ARAM addresses, or DIR points somewhere else.

## What "PASS" means cumulatively

Conditions 2 through 5 together imply condition 1. If 2-5 all hold
and 1 doesn't, check Mesen2's audio output settings — the chip is
doing the right thing and you're not hearing it.
