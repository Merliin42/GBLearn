INCLUDE "Includes/hardware.inc"

; Defining constants to work with sprite
_SPR0Y EQU _OAMRAM
_SPR0X EQU _OAMRAM+1
_SPR0_NUM EQU _OAMRAM+2
_SPR0_ATT EQU _OAMRAM+3

; Defining variables to see where we need to move the sprite
_MOVX EQU _RAM
_MOVY EQU _RAM+1

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

Start:

; Turn off LCD screen
	call lcdOff

; Clean VRAM
	ld hl, $8000
	ld bc, $9FFF - $8000
.cleanVRAM
	xor a ; ld a, 0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .cleanVRAM

; Copy tiles to VRAM
	ld hl, $8000 ; VRAM
	ld de, tiles
	ld bc, tilesEnd - tiles
.copyTiles
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyTiles

	; Create the sprite
	ld a, 30
	ld [_SPR0Y], a ; Y pos of the sprite
	ld [_SPR0X], a ; X pos of the sprite
	ld a, 1
	ld [_SPR0_NUM], a ; number of tiles of the table that we will use
	xor a ; ld a, 0
	ld [_SPR0_ATT], a ; special attributes, so far nothing

	ld a, %11100100
	ld [rOBP0], a

	xor a ; ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	ld [rNR52], a

	ld a, %10010011
	ld [rLCDC], a

	; Preparing animation variables
	ld a, 1
	ld [_MOVY], a
	ld [_MOVX], a

animation:
	call waitVBlank

	ld a, [_SPR0Y]
	ld hl, _MOVY
	add a, [hl]
	ld hl, _SPR0Y
	ld [hl], a
	; compared to see if they change the direction
	cp 152
	jr z, .decY
	cp 16
	jr z, .incY
	;do not change
	jr .endY
.decY
	ld a, -1
	ld [_MOVY], a
	jr .endY
.incY
	ld a, 1
	ld [_MOVY], a
.endY
	; We go with the X, the same but changing the margin
	ld a, [_SPR0X]
	ld hl, _MOVX
	add a, [hl]
	ld hl, _SPR0X
	ld [hl], a
	; compared to see if they change the direction
	cp 160
	jr z, .decX
	cp 8
	jr z, .incX
	;do not change
	jr .endX
.decX
	ld a, -1
	ld [_MOVX], a
	jr .endX
.incX
	ld a, 1
	ld [_MOVX], a
.endX

	call delay
	jr animation


.lockup
	jr .lockup

SECTION "Tiles", ROM0

tiles:
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $E0, $EC, $40, $48, $00, $0C
	db $C0, $00, $AC, $0C, $CC, $0C, $08, $08
tilesEnd:

SECTION "Functions", ROM0

; Turn off the screen
lcdOff:
	call waitVBlank
	xor a ; ld a, 0
	ld [rLCDC], a
	ret

; Wait
delay:
	ld bc, 1000
.loopDelay
	dec bc
	ld a, b
	or c
	jr nz, .loopDelay
	ret

waitVBlank:
.loopVBlank
	ld a, [rLY]
	cp 144
	jr c, .loopVBlank
	ret