INCLUDE "Includes/hardware.inc"

; Defining constant to work with Sprite
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
; Turn off the LCD screen
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
	ld hl, $8000
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
	ld [_SPR0_NUM], a ; number of tiles the table that we will use
	
	xor a ; ld a, 0
	ld [_SPR0_ATT], a ; special attributes

; Sprite 0 color palette
	ld a, %11100100
	ld [rOBP0], a

; Screen Y and X at 0
	xor a ; ld a, 0
	ld [rSCY], a
	ld [rSCX], a

; Turn off audio
	ld [rNR52], a

; Turn on the screen
	ld a, %10010011
	ld [rLCDC], a


move:
	call waitVBlank
	call readInputs

; Move Y
	ld a, b
	and $80
	jr z, .down
	ld a, b
	and $40
	jr z, .up
	xor a
	jr .endY
.down
	ld a, 1
	jr .endY
.up
	ld a, -1
.endY
	ld [_MOVY], a

; Move X
	ld a, b
	and $20
	jr z, .left
	ld a, b
	and $10
	jr z, .right
	xor a
	jr .endX
.left
	ld a, -1
	jr .endX
.right
	ld a, 1
.endX
	ld [_MOVX], a

	ld a, [_SPR0Y]
	ld hl, _MOVY
	add a, [hl]
	ld hl, _SPR0Y
	ld [hl], a

	ld a, [_SPR0X]
	ld hl, _MOVX
	add a, [hl]
	ld hl, _SPR0X
	ld [hl], a

	call delay
	jr move



SECTION "Graphics", ROM0

tiles:
INCLUDE "TileMaps/tcdp.z80"
tilesEnd:

SECTION "Functions", ROM0
; Turn of the screen
lcdOff:
	call waitVBlank
	xor a ; ld a, 0
	ld [rLCDC], a
	ret

; Wait VBlank
waitVBlank:
.loopVBlank
	ld a, [rLY]
	cp 144
	jr c, .loopVBlank
	ret

delay:
	ld bc, 1000
.loopDelay
	dec bc
	ld a, b
	or c
	jr nz, .loopDelay
	ret

; Read Inputs
; Return Inputs in b
; down | up | left | right | start | select | B | A
readInputs:
	ld a, %00100000 ; Read the directional pad
	ld a, [rP1]

; Read several times for avoiding bouncing
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	
	and a, $0F ; Masking a for keeping 4 lower bytes
	swap a ; Exchange lower/higher nibbles
	ld b, a ; Store the result in b

; Do the exact same thing with a, b, start and select
	ld a, %00010000
	ld a, [rP1]

	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]

	and a, $0F
	add b
	ld b, a
	ret