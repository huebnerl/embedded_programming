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
mov P0, #0fh				; set the first 4 bits to 1 (for the key matrix column checking) Port0
mov r7, P0
cjne r7, #0Eh, notpressed	; check if the corresponding column is unset (key matrix is invers!)

mov P0, #0f0h				; set the last 4 bits to 1 (for row checking)
mov r7, P0
cjne r7, #70h, notpressed	; check the row that is set
cjne r6, #00h, loop			; check if timer running is not set -> continie and start recording-timer
call startrectimer
jmp loop

notpressed:
cjne r6, #01h, loop			; check if timer running is set -> stop recording-timer
jmp stoprectimer

startrectimer:
mov tl0, th0
setb tr0 					; start timer0
mov r6, #01h				; set running flag
ret

stoprectimer:
clr tr0 					; stop timer0
mov r6, #00h				; unset running flag
cjne r4, #02h, incrementDivider		; count number of mesurements  (want 3 mesurements -> 3-1 = 2
inc r4						; 2+1 = 3
mov A, r5
mov B, r4
div AB						; divide mesurements-sum through number of mesurements
mov maxTickCount, A			; bring result to register
jmp displaySection			; start metronom display

incrementDivider:
inc r4
jmp loop

rectimer:					; handle Interrupt
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
