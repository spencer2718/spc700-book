# Expected DSP register state — Chapter 13 first sound

After the SPC payload finishes its setup, the DSP registers should
look like this. Use Mesen2's DSP register view to verify.

## Global registers

| Address | Name  | Expected | Notes                                  |
|---------|-------|----------|----------------------------------------|
| `$0C`   | MVOLL | `$7F`    | Main volume left, max positive         |
| `$1C`   | MVOLR | `$7F`    | Main volume right, max positive        |
| `$2C`   | EVOLL | `$00`    | Echo unused                            |
| `$3C`   | EVOLR | `$00`    | Echo unused                            |
| `$4C`   | KON   | (varies) | Read-back is not directly meaningful   |
| `$5C`   | KOFF  | `$00`    | No voices in release                   |
| `$5D`   | DIR   | `$20`    | Directory at $2000                     |
| `$6C`   | FLG   | `$20`    | Unmuted; echo writes disabled          |
| `$6D`   | ESA   | (any)    | We don't configure this                |
| `$7D`   | EDL   | `$00`    | Default. ECHO WRITE DISABLE prevents   |
|         |       |          | the EDL=0 buffer-corruption hazard.    |
| `$2D`   | PMON  | `$00`    | No pitch modulation                    |
| `$3D`   | NON   | `$00`    | No noise                               |
| `$4D`   | EON   | `$00`    | No echo input                          |

## Voice 0 registers

| Address | Name      | Expected      | Notes                              |
|---------|-----------|---------------|------------------------------------|
| `$00`   | V0VOLL    | `$7F`         | Voice 0 left volume, max           |
| `$01`   | V0VOLR    | `$7F`         | Voice 0 right volume, max          |
| `$02`   | V0PITCHL  | `$00`         | Pitch low byte                     |
| `$03`   | V0PITCHH  | `$10`         | Pitch high byte (= $1000 = native) |
| `$04`   | V0SRCN    | `$00`         | Sample number 0                    |
| `$05`   | V0ADSR1   | `$8F`         | ADSR enabled, attack=$F, decay=0   |
| `$06`   | V0ADSR2   | `$E0`         | Sustain level=7, sustain rate=0    |
| `$07`   | V0GAIN    | (any)         | Unused when ADSR1 bit 7 is set     |
| `$08`   | V0ENVX    | rising → $7F  | Envelope output; status register   |
| `$09`   | V0OUTX    | oscillating   | Sample output; status register     |

## Voices 1-7

ENVX should be `$00` for all of voices 1 through 7 (they're silent).
Their other per-voice registers are unspecified — we only set up
voice 0.

## Timing notes

The ADSR settings (attack=$F, decay=0, sustain=7, sustain rate=0)
mean the envelope ramps to peak within roughly one DSP sample
period (~32 µs at 32 kHz) and holds at peak indefinitely. ENVX
will read `$7F` essentially as soon as you sample it after KON.

## What you should hear

A continuous 2 kHz tone in both channels. The 4-bit amplitude
resolution of the BRR sample produces a slight rasp on top of the
sine; this is normal at the encoding level.
