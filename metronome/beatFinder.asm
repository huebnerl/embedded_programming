; Metronome with function tab for beet

; initialisierung
cseg at 0h
ajmp init
cseg at 100h
EIN1 EQU 20H

; -----------------
; Interrupt
;------------------
ORG 0bh
call timer
reti

; -----------------
; Init
; -----------------
init:
mov IE, #10000010b
mov P0, #0fh

loop:
mov P0, #0fh
mov r7, P0
cjne r7, #0Eh, notpressed

mov P0, #0f0h
mov r7, P0
cjne r7, #70h, notpressed
cjne r6, #00h, loop
call starttimer
jmp loop

notpressed:
cjne r6, #01h, loop
call stoptimer
jmp loop

starttimer:
mov th0, #0fch
setb tr0; start timer0
mov r6, #01h
ret

stoptimer:
clr tr0 ; strop timer0
mov r6, #00h
ret

timer:
inc r5
mov th0, #0fch
ret