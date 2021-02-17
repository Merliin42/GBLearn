INCLUDE "Includes/hardware.inc"

; Variables
_CONTROL_TIMER EQU _RAM ; Control milliseconds
_ACTIVATE EQU _RAM+1 ; Stopwatch activated or not
_SECONDS EQU _RAM+2
_MINUTES EQU _RAM+3
_HOURS EQU _RAM+4
_PAD EQU _RAM+5

; Constants
_POS_CRONO EQU _SCRN0+32*4+6 ; Screen position

; Vblank interruption
SECTION "Vblank", ROM0[$0040]
	call drawChrono
	reti ; Return and enable interrupts

SECTION "TimerOverflow", ROM0[$0050]
	; When there is an interruption of the timer, we call this subroutine
	call controlTimer
	reti

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game Code", ROM0
Start:
	; We start the timer
	xor a ; ld a, 0
	ld [rTAC], a ; Off timer, divider to 00

	ld a, 51
	ld [rTMA], a ; When TIMA overflows, this is
				 ; reset value, (1/4096)*(255-51) = 0,049s
	ld [rTIMA], a ; initial value of the timer

	; Begin the variables
	xor a ; ld a, 0
	ld [_CONTROL_TIMER], a
	ld [_ACTIVATE], a
	ld [_SECONDS], a
	ld [_MINUTES], a
	ld [_HOURS], a

	; Pallet
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a

	; Scroll
	xor a ; ld a, 0
	ld [rSCX], a
	ld [rSCY], a

	; video

	call lcdOff

	; the tiles loaded in memory

	ld hl, _VRAM
	ld de, Tiles
	ld bc, EndTiles-Tiles
	call copyMemory

	; We clean the map
	ld hl, _SCRN0
	ld d, 12
	ld bc, 32*32
	call cleanMemory

	; Clean sprite attributes
	ld hl, _OAMRAM
	ld d, 0
	ld bc, 40*4
	call cleanMemory

	; We draw the Stopwatch
	call drawChrono

	; Configure and activate the display
	ld a, %10010001
	ld [rLCDC], a

	; Main control loop
control:
	; We read the pad
	call readInputs

	; Now activate or desactivate the timer
	ld a, [_PAD]
	and %00000001 ; A
	call nz, activate

	; reset
	ld a, [_PAD]
	and %00000010 ; B
	call nz, reset

	ld bc, 1500
	call delay
	; we start
	jr control

activate:
	ld a, [_ACTIVATE]
	cp 1
	jp z, .desactivate
	ld a, 1
	ld [_ACTIVATE], a

	ld a, %00000100 ; timer activated
	ld [rTAC], a

	ld a, %00000101 ; Vblank timer interrupt
	ld [rIE], a
	ei ; activate interrupts
	ret
.desactivate
	ld a, 0
	ld [_ACTIVATE], a

	ld a, %00000000 ; Timer disabled
	ld [rTAC], a

	ld a, %00000101 ; Vblank timer interrupts
	ld [rIE], a
	di ; disable interrupts
	ret

	; reset the timer
reset:
	ld a, 0
	ld [_SECONDS], a
	ld [_MINUTES], a
	ld [_HOURS], a

	ld a, 51 ; initial value of the timer
	ld [rTIMA], a

	; look if activated
	ld a, [_ACTIVATE]
	ret z
	; if not, we redraw
	call waitVBlank
	call drawChrono
	ret

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
	xor a ; ld a, 0
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
	xor a ; ld a, 0
	ld [_SECONDS], a ; minute, seconds increase to 0

	ld a, [_MINUTES]
	inc a
	daa
	cp 96 ; 60 minutes have passed ?
	jr z, .hours
	ld [_MINUTES], a
	ret

.hours
	xor a ; ld a, 0
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

SECTION "Library", ROM0
INCLUDE "Includes/library/inputs.asm"
INCLUDE "Includes/library/memory.asm"
INCLUDE "Includes/library/screen.asm"
INCLUDE "Includes/library/time.asm"

SECTION "Tiles", ROM0

Tiles:
INCLUDE "TileMaps/Numbers.z80"
EndTiles: