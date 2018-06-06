; Metronome with function tab for beet

; initialisierung
cseg at 0h
ajmp init
cseg at 100h

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
mov TMOD, #02h
mov th0, #0EFh

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
setb tr0; start timer0
mov tl0, th0
mov r6, #01h
ret

stoptimer:
clr tr0 ; stop timer0
mov r6, #00h
cjne r4, #04h, incrementDivider
inc r4
mov A, r5
mov B, r4
div AB
ret

incrementDivider:
inc r4
ret

timer:
inc r5
ret