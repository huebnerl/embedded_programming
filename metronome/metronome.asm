; Metronome with function to tap for beat

cseg at 0h
ajmp init
cseg at 100h

tickCounter EQU R0
maxTickCount EQU R1
tickState EQU R2
timerValue EQU R3

; -----------------
; Interrupts
;------------------
; Timer0 Interrupt
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
mov IE, #10001010b
mov TMOD, #00100010b

mov tickState, #0f0h
mov timerValue, #0eah
mov tickCounter, #00h
mov maxTickCount, #03h 	; default

; init ports we use
mov P0, #0fh
mov P2, #00h
mov P3, #0ffh

; init auto reload values
mov th0, timerValue
mov th1, timerValue

; -----------------
; Recording section
; -----------------
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
mov tl0, th0
setb tr0 ; start timer0
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

; -----------------
; Display section
; -----------------
displaySection:
call starttimer
displayLoop:
jmp displayLoop

starttimer:
mov tl1, th1
setb tr1
ret

stoptimer:
ret

timer:
mov P2, tickState	; tickState is used as a bitmap indicating the columns to light up
inc tickCounter		; increment tickCounter

clr c
mov A, maxTickCount
subb A, tickCounter	; subtract current tickCounter from maxTickCount to check whether it needs to be reset
jnz keep
call resetTickCounter	; reset the tick counter when the difference is 0
keep:
ret

resetTickCounter:
mov tickCounter, #00h	; set tickCounter to 0
mov A, tickState	; swap tickState by inverting the bits
cpl A
mov tickState, A
ret
