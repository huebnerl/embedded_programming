; Metronome with function tab for beet

; initialisierung
cseg at 0h
ajmp init
cseg at 100h

tickCounter EQU R0
maxTickCount EQU R1
tickState EQU R2
timerValue EQU R3

; -----------------
; Interrupt
;------------------
ORG 0bh
call rectimer
reti

; Timer1 Interrupt
ORG 01bh
call timer
reti

; -----------------
; Init
; -----------------
init:
mov tickState, #0f0h
mov timerValue, #0eah
mov tickCounter, #00h
mov maxTickCount, #03h 	; default init

mov IE, #10001010b
mov TMOD, #00100010b
mov P0, #0fh
mov th0, timerValue

mov P2, #00h
mov P3, #0ffh
mov DPTR, #table


loop:
mov P0, #0fh
mov r7, P0
cjne r7, #0Eh, notpressed

mov P0, #0f0h
mov r7, P0
cjne r7, #70h, notpressed
cjne r6, #00h, loop
call startrectimer
jmp loop

notpressed:
cjne r6, #01h, loop
jmp stoprectimer

startrectimer:
setb tr0; start timer0
mov tl0, th0
mov r6, #01h
ret

stoprectimer:
clr tr0 ; stop timer0
mov r6, #00h
cjne r4, #02h, incrementDivider
inc r4
mov A, r5
mov B, r4
div AB
mov maxTickCount, A
jmp displaySection

incrementDivider:
inc r4
jmp loop

rectimer:
inc r5
ret

; diplaysection starts here
displaySection:
call starttimer
displayLoop:
jmp displayLoop

starttimer:
mov tl1, timerValue
mov th1, timerValue ; Auto reloads from here.
setb tr1
ret

stoptimer:
ret

timer:
mov P2, tickState
inc tickCounter

clr c
mov A, maxTickCount
subb A, tickCounter
jnz keep
call resetTickCounter
keep:
ret

resetTickCounter:
mov tickCounter, #00h
mov A, tickState
cpl A
mov tickState, A
ret

; ------------------------------------
org 300h
table:
db 11110000b, 11111111b
db 00001111b, 11111111b

end