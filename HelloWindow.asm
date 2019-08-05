INCLUDE "Includes/hardware.inc"

; Defines constant for our sprites
_SPR0Y EQU _OAMRAM
_SPR0X EQU _OAMRAM + 1
_SPR0_NUM EQU _OAMRAM + 2
_SPR0_ATT EQU _OAMRAM + 3

_SPR1Y EQU _OAMRAM + 4
_SPR1X EQU _OAMRAM + 5
_SPR1_NUM EQU _OAMRAM + 6
_SPR1_ATT EQU _OAMRAM + 7

_SPR2Y EQU _OAMRAM + 8
_SPR2X EQU _OAMRAM + 9
_SPR2_NUM EQU _OAMRAM + 10
_SPR2_ATT EQU _OAMRAM + 11

_SPR3Y EQU _OAMRAM + 12
_SPR3X EQU _OAMRAM + 13
_SPR3_NUM EQU _OAMRAM + 14
_SPR3_ATT EQU _OAMRAM + 15

; VARIABLES
; Variable to save the state of the PAD
_PAD EQU _RAM ; At the beginning of internal RAM
; Control variables sprites
_POS_MAR_2 EQU _RAM + 1 ; placing the second position where sprites
_SPR_MAR_SUM EQU _RAM + 2 ; Counter for animation

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

Start:

	ld hl, _POS_MAR_2 ; Sprites looking to the right
	ld [hl], -8

	ld hl, _SPR_MAR_SUM ; We start with 0
	ld [hl], 0

	; Palettes
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a

	; Another palette
	ld a, %11010000
	ld [rOBP1], a

	; Scroll
	xor a ; ld a, 0
	ld [rSCX], a
	ld [rSCY], a

	; Turn off LCD screen
	call lcdOff

	; Load the tiles in VRAM
	ld hl, Tiles
	ld de, $8000
	ld bc, EndTiles - Tiles
	call copyMemory

	; Load the map
	ld hl, Map
	ld de, $9800
	ld bc, EndMap - Map
	call copyMemory

	; Load the map to the window
	ld hl, Window
	ld de, $9C00
	ld bc, EndWindow - Window
	call copyMemory

	; Clean _OAMRAM
	ld hl, _OAMRAM
	ld bc, 40*4
	call cleanMemory

	; Creating sprites
	ld a, 136 ; Y pos of the sprite
	ld [_SPR0Y], a
	ld a, 80 ; X pos of the sprite
	ld [_SPR0X], a
	xor a ; ld a, 0 ; Number of tiles on the table we will have to use
	ld [_SPR0_NUM], a
	ld a, %00010000 ; Special attributes
	ld [_SPR0_ATT], a

	ld a, 136 + 8
	ld [_SPR1Y], a
	ld a, 80
	ld [_SPR1X], a
	ld a, 1
	ld [_SPR1_NUM], a
	ld a, %00010000
	ld [_SPR1_ATT], a

	ld a, 136
	ld [_SPR2Y], a
	ld a, [_POS_MAR_2]
	add 80
	ld [_SPR2X], a
	ld a, 2
	ld [_SPR2_NUM], a
	ld a, %00010000
	ld [_SPR2_ATT], a

	ld a, 136 + 8
	ld [_SPR3Y], a
	ld a, [_POS_MAR_2]
	add 80
	ld [_SPR3X], a
	ld a, 3
	ld [_SPR3_NUM], a
	ld a, %00010000
	ld [_SPR3_ATT], a

	; Configure and acivate the display
	ld a, %11010011
	ld [rLCDC], a

; Main loop
.movement
	call readInputs
	call waitVBlank

	ld a, [_PAD] ; Charge the status pad
	and %00010000 ; right
	call nz, moveRight ; If the button is set, move to the left

	ld a, [_PAD]
	and %00100000
	call nz, moveLeft

	ld a, [_PAD]
	and %01000000
	call nz, moveUp

	ld a, [_PAD]
	and %10000000
	call nz, moveDown

	ld a, [_PAD]
	and %00001000
	call nz, showWindow

	ld a, [_PAD]
	and %11111111
	call z, noInput

	; Wait a few
	ld bc, 2000
	call delay

	; Do this loop again
	jr .movement

SECTION "Movement routines", ROM0

moveRight:
	ld a, [_SPR0X]
	cp 120
	jr nz, .ar

	ld a, [rSCX]
	inc a
	ld [rSCX], a

	; Apply translate to the sprites
	call numSprMario
	call animateMario
	ret
.ar
	; The second sprite must be behind the first
	push af
	ld a, -8
	ld [_POS_MAR_2], a
	pop af
	; motion
	inc a
	ld [_SPR0X], a
	ld [_SPR1X], a

	ld hl, _POS_MAR_2
	add a, [hl]
	ld [_SPR2X], a
	ld [_SPR3X], a

; Reflect sprites horizontally
	ld a, [_SPR0_ATT]
	set 5, a
	ld [_SPR0_ATT], a
	ld [_SPR1_ATT], a
	ld [_SPR2_ATT], a
	ld [_SPR3_ATT], a

	call numSprMario
	call walkMario
	ret

moveLeft:
	ld a, [_SPR0X]
	cp 16
	jp nz, .al

	ld a, [rSCX]
	dec a
	ld [rSCX], a
	

SECTION "Functions", ROM0

; Turn of the screen
lcdOff:
	call waitVBlank
	xor a ; ld a, 0
	ld [rLCDC], a
	ret

; Wait VBlank
waitVBlank:
	ld a, [rLY]
	cp 144
	jr c, waitVBlank
	ret

; Count from bc to 0
; Parameters :
; bc - Counter
delay:
	dec bc
	ld a, b
	or c
	jr nz, delay
	ret

; Read Inputs
; Return Inputs in _PAD
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
	cpl
	ld [_PAD], a
	ret

; Copy a number of bytes from one place to another
; Parameters :
; hl - Destination address
; de - Origin address
; bc - Counter
copyMemory:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, copyMemory
	ret

; Clean a memory location
; Parameters :
; hl - Destination address
; bc - Counter
cleanMemory:
	xor a ; ld a, 0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, copyMemory
	ret

SECTION "Graphics", ROM0

Tiles:
INCLUDE "TileMaps/marioTiles.z80"
EndTiles:

Map:
INCLUDE "TileMaps/marioMap.z80"
EndMap:

Window:
INCLUDE "TileMaps/window.z80"
EndWindow: