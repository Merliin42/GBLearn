INCLUDE "Includes/hardware.inc"

; Variables
_CONTROL_TIMER EQU _RAM ; Control milliseconds
_ACTIVATE EQU _RAM+1 ; Stopwatch activated or not
_SECONDS EQU _RAM+2
_MINUTES EQU _RAM+3
_HOURS EQU _RAM+4
PAD EQU _RAM+5

; Constants
_POS_CRONO EQU _SCRN0+32*4+6 ; Screen position

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

; Vblank interruption
SECTION "Vblank", ROM0[$0040]
	call drawChrono
	reti ; Return and enable interrupts

SECTION "TimerOverflow", ROM0[$0050]
	; When there is an interruption of the timer, we call this subroutine
	call controlTimer
	reti

SECTION "Functions", ROM0

drawChrono:
	; Decade of hours
	ld a, [_HOURS]
	and $F0
	swap a
	ld [_POS_CRONO], a

	; Hours
	ld a, [_HOURS]
	and $0F
	ld [_POS_CRONO+1], a

	; :
	ld a, 10
	ld [_POS_CRONO+2], a

	; Decade of minutes
	ld a, [_MINUTES]
	and $F0
	swap a
	ld [_POS_CRONO+3], a

	; Minutes
	ld a, [_MINUTES]
	and $0F
	ld [_POS_CRONO+4], a

	; :
	ld a, 10
	ld [_POS_CRONO+5], a

	; Decade of seconds
	ld a, [_SECONDS]
	and $F0
	swap a
	ld [_POS_CRONO+6], a

	; Seconds
	ld a, [_SECONDS]
	and $0F
	ld [_POS_CRONO+7], a

	ret

; Control the time
controlTimer:
	ld a, [_CONTROL_TIMER]
	cp 20 ; Interruption every 20 passes 1 sec
	jr z, .increment
	inc a
	ld [_CONTROL_TIMER], a
	ret

.increment
	; We reset the counter
	ld a, 0
	ld [_CONTROL_TIMER], a

	; We increased the clock
	ld a, [_SECONDS]
	inc a
	daa ; Decimal ajustement on the accu
	cp 96 ; 60 have passed (96 because we use BCD)
	jr z, .minutes
	ld [_SECONDS], a
	ret

.minutes
	ld a, 0
	ld [_SECONDS], a ; minute, seconds increase to 0

	ld a, [_MINUTES]
	inc a
	daa
	cp 96 ; 60 minutes have passed ?
	jr z, .hours
	ld [_MINUTES], a
	ret

.hours
	ld a, 0
	ld [_MINUTES], a

	ld a, [_HOURS]
	inc a
	daa
	cp 36 ; 24 hours have passed ? (36 equals 24 BCD)
	jr z, .reset

	ld [_HOURS], a
	ret

.reset
	call reset

	ret