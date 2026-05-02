; programmers_model.asm — Chapter 6 observational payload.
;
; This payload exercises every part of the SPC-700's programmer
; model: stack pointer, direct page, A/X/Y, direct vs. absolute
; memory addressing, and stack push/pop. There is nothing to
; edit. Step through it in the SPC Debugger and watch the state
; change. The comments on each line tell you what to look for.
;
; The starter and solution are identical for this exercise — see
; the README for why.

arch spc700
norom

; The output binary is uploaded raw to ARAM starting at address $0200.
; File offset $0000 corresponds to ARAM $0200.
org $0000
base $0200

start:
    ; ----- 1. Stack pointer setup -----
    ; The IPL ROM hands off with SP near $EF (its own scratch end).
    ; Convention is to put SP at the top of page 1 ($01FF) so pushes
    ; live in the canonical stack region.
    mov   x, #$ff       ; X = $FF
    mov   sp, x         ; SP = $FF (was ~$EF; now $FF)

    ; ----- 2. Direct page -----
    ; clrp sets PSW.P = 0. Direct-page accesses now resolve to
    ; $0000-$00FF. (setp would point them at $0100-$01FF instead.)
    clrp                ; PSW.P -> 0

    ; ----- 3. Load A, X, Y to memorable sentinels -----
    ; Watch each register change in turn in the SPC Debugger pane.
    mov   a, #$aa       ; A = $AA
    mov   x, #$bb       ; X = $BB
    mov   y, #$cc       ; Y = $CC

    ; ----- 4. Direct-page write -----
    ; This stores A at direct address $20. With P=0, that resolves
    ; to ARAM $0020. The opcode is C4 (mov dp, a) — only 2 bytes.
    ; In Memory Tools (RAM), $0020 changes from $00 to $AA.
    mov   $20, a        ; ($0020) = $AA

    ; ----- 5. Absolute write -----
    ; Same mnemonic, different opcode: C5 (mov abs, a) — 3 bytes,
    ; because the address $0500 doesn't fit in a single byte.
    ; In Memory Tools (RAM), $0500 changes from $00 to $DD.
    mov   a, #$dd       ; A = $DD
    mov   $0500, a      ; ($0500) = $DD

    ; ----- 6. Stack push (twice) -----
    ; Each push writes A to ARAM[$0100 + SP], then decrements SP.
    ; So pushes grow the stack downward through page 1.
    mov   a, #$11       ; A = $11
    push  a             ; ($01FF) = $11; SP -> $FE
    mov   a, #$22       ; A = $22
    push  a             ; ($01FE) = $22; SP -> $FD

    ; ----- 7. Stack pop -----
    ; pop a increments SP first, then loads A from ARAM[$0100+SP].
    ; The most recent push ($22) comes back. Note that the byte at
    ; $01FE is *not* cleared by the pop — popping just moves SP.
    pop   a             ; SP -> $FE; A = $22

    ; ----- 8. Halt -----
    ; PC oscillates here forever. From this point, every "step"
    ; just bounces PC back to this same address.
forever:
    bra   forever

base off
