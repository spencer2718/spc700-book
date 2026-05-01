; ipl_upload.asm — the SPC upload protocol from the main CPU side.
;
; Implements the IPL handshake described in Chapter 7 of the book.
; Shape:
;
;   1. Wait for SPC port 0 == $AA and port 1 == $BB. (The SPC's IPL
;      ROM writes those when it's ready to receive.)
;   2. Write the destination ARAM address to ports 2 and 3.
;   3. Write a nonzero "start" signal to port 1.
;   4. Write $CC to port 0; wait for the SPC to echo it.
;   5. For each payload byte: write the byte to port 1, write the
;      counter to port 0, wait for the SPC to echo the counter.
;   6. Write the entry-point address to ports 2 and 3.
;   7. Write 0 to port 1 (signaling "stop transferring; jump to entry").
;   8. Write (last counter + 2) to port 0; wait for echo. The SPC
;      then reads the entry address and jumps.
;
; The "+2" in step 8 is mandated by the IPL ROM: it distinguishes the
; "jump to entry" signal from a normal byte transfer's counter +1. If
; you write only +1 the SPC interprets the value as "send another
; byte" and your final transfer never completes.

; -----------------------------------------------------------------
; Constants
; -----------------------------------------------------------------

!APUIO0 = $2140
!APUIO1 = $2141
!APUIO2 = $2142
!APUIO3 = $2143

; -----------------------------------------------------------------
; Entry point — called by reset after basic init
; -----------------------------------------------------------------

spc_upload_entry:
    cld                         ; ensure binary mode for ADC
    sep #$20                    ; 8-bit A
    rep #$10                    ; 16-bit X/Y

    ; ----- Step 1: wait for SPC's $AA/$BB ready signal -----
.wait_aa:
    lda !APUIO0
    cmp #$AA
    bne .wait_aa
.wait_bb:
    lda !APUIO1
    cmp #$BB
    bne .wait_bb

    ; ----- Step 2: send destination address -----
    lda #<!SPC_ENTRY
    sta !APUIO2
    lda #>!SPC_ENTRY
    sta !APUIO3

    ; ----- Step 3: send "start transfer" signal on port 1 -----
    lda #$01
    sta !APUIO1

    ; ----- Step 4: write $CC to port 0; wait for echo -----
    lda #$CC
    sta !APUIO0
.wait_cc_echo:
    cmp !APUIO0
    bne .wait_cc_echo

    ; ----- Step 5: stream the payload bytes -----
    ; X holds both the payload index AND the IPL counter (low byte
    ; of X). They start coupled at 0, so we just transmit X's low
    ; byte as the counter; this avoids tracking two state variables.
    ldx #$0000

.byte_loop:
    cpx.w #!SPC_PAYLOAD_SIZE
    bcs .upload_done

    ; Send payload[X] on port 1.
    lda.l spc_payload_start, x
    sta !APUIO1

    ; Send counter (X's low byte) on port 0.
    txa
    sta !APUIO0

    ; Wait for the SPC to echo the counter back on port 0.
.wait_byte_ack:
    cmp !APUIO0
    bne .wait_byte_ack

    inx
    bra .byte_loop

.upload_done:
    ; ----- Step 6: send the entry-point address -----
    lda #<!SPC_ENTRY
    sta !APUIO2
    lda #>!SPC_ENTRY
    sta !APUIO3

    ; ----- Step 7: signal "jump to entry" by writing 0 to port 1 -----
    stz !APUIO1

    ; ----- Step 8: counter += 2; write; wait for echo -----
    ; The IPL ROM only treats this as "jump now" if the new counter
    ; is at least 2 more than the last byte-transfer counter. +1
    ; would look like another byte transfer; +2 (or more) is the
    ; jump signal.
    lda !APUIO0                 ; A = last acknowledged counter
    clc
    adc #$02
    sta !APUIO0
.wait_jump_ack:
    cmp !APUIO0
    bne .wait_jump_ack

    ; The SPC has now jumped to the entry point. Main CPU is done.
    jml idle_forever
