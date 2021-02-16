INCLUDE "Includes/hardware.inc"

; Constants
_FONT_TILES EQU $9200

; Variables
_BANK EQU _RAM
_PAD EQU _RAM+1

SECTION "Vblank", ROM0[$40]
	reti ; we do nothing, we return

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game Code", ROM0

Start:
	ld a, 1
	ld [_BANK], a

	; Palets
	ld a, %11100100

	ld [rBGP], a
	ld [rOBP0], a

	; Scroll
	xor a ; ld a, 0
	ld [rSCX], a
	ld [rSCY], a

	; Video
	call lcdOff

	; We load the tiles in the second table memory tiles
	ld hl, _FONT_TILES
	ld de, Font1
	ld bc, EndFont1 - Font1
	call copyMemory

	; We clean the map
	ld hl, _SCRN0
	ld d, 0
	ld bc, 40*4
	call cleanMemory

	


SECTION "Library", ROM0
INCLUDE "Includes/library/inputs.asm"
INCLUDE "Includes/library/memory.asm"
INCLUDE "Includes/library/screen.asm"
INCLUDE "Includes/library/time.asm"