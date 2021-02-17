INCLUDE "Includes/hardware.inc" ; Include hardware specs

SECTION "Header", ROM0[$100]

EntryPoint:
	di ; Disable interrupts
	jp Start ; tells to the processor to jump to start

REPT $150 - $104 ; Repeat $150 - $104 times
	db 0 ; Writes 0 in the ROM
ENDR

SECTION "Code", ROM0

Start:
	call lcdOff
	
	ld hl, $8000
	ld bc, $9FFF - $8000

	call clearMemory

	ld hl, $9000
	ld de, TilesStart
	ld bc, TilesEnd - TilesStart

	call copyMemory

	xor a ; ld a, 0

	ld hl, $9800
	inc a
	ld [hli], a

	inc a
	ld [hl], a

	ld hl, $9820
	inc a
	ld [hli], a

	inc a
	ld [hl], a

	ld a, %11100100
	ld [rBGP], a

	xor a ; ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	ld [rNR52], a

	ld a, %10000001
	ld [rLCDC], a

.lockup
	jr .lockup

SECTION "Library", ROM0 ; Section with all the includes

;INCLUDE "Includes/library/inputs.asm"
INCLUDE "Includes/library/memory.asm"
INCLUDE "Includes/library/screen.asm"

SECTION "Tiles", ROM0 ; Section where the tiles are written

TilesStart:
; Blank tile
db $00, $00, $00, $00, $00, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $00, $00

INCLUDE "TileMaps/gbButtons.z80"
TilesEnd: