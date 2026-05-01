; hello.asm — Chapter 5 reference solution.

arch spc700
norom

org $0000
base $0200

start:
    mov   a, #$42       ; A = $42
    mov   $0500, a      ; M($0500) = A = $42

forever:
    bra   forever       ; loop here forever

base off
