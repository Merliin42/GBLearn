INCLUDE "Includes/hardware.inc" ; Include hardware specs

SECTION "Header", ROM0[$100] ; create a new section of code, for storage and define used bank as RMS0

EntryPoint:
	di ; Disable interrupts
	jp Start ; tells to the processor to jump to start

REPT $150 - $104 ; Repeat an operation $150 - $104 times
	db 0 ; Writes 0 in the ROM
ENDR ; End of the REPT loop

SECTION "Game code", ROM0 ; Create a new section of code, who is store whenever the assembler wants

Start:
	call lcdOff

	ld hl, $9000 ; Set hl to $9000, witch is the pointer to the first VRAM adress
	ld de, FontTiles ; Set de to the pointer to FontTiles label
	ld bc, FontTilesEnd - FontTiles ; Set bc to the difference between the start and the end of FontTiles, for making a counter

; Next loop is for copying font to VRAM
.copyFont ; Label
	ld a, [de] ; Load in a a byte of FontTiles
	ld [hli], a ; Load in VRAM ($9000) a byte of FontTiles and increment hl
	inc de ; Increment the pointer to FontTiles for check the next byte
	dec bc ; Decrement the counter
	ld a, b ; load the higher bits of bc to a
	or c ; set the Z flag if and only if bc == 0
	jr nz, .copyFont ; if the counter is not 0, loop to copyFont label

	ld hl, $9800 ; Set hl to $9800 witch is the pointer to the first background map
	ld de, HelloWorldStr ; Set de at a pointer to HelloWorldStr label
.copyString
	ld a, [de] ; Load a byte from Hello World string
	ld [hli], a ; Load the byte from Hello World in a to the first background map
	inc de ; Increment the pointer to Hello World string
	and a ; check if the value of a isn't 0 and set the Z flag if it is
	jr nz, .copyString ; if the string isn't finished, loop on copyString label

	ld a, %11100100 ; Load the color palette in a
	ld [rBGP], a ; Store it in the BD palette data

	xor a ; ld a, 0
	ld [rSCY], a ; Reset the position of the screen to Y = 0
	ld [rSCX], a ; Reset the position of the screen to X = 0

	ld [rNR52], a ; Turn off the volume

	ld a, %10000001 ; Turn on the screen and activate the BG display
	ld [rLCDC], a ; Load the value in a into LCD Controller

.lockup ; Loop for lockup the processor
	jr .lockup ; Jump to lockup label

SECTION "Font", ROM0 ; Create a section where we store code

FontTiles:
INCBIN "TileMaps/font.chr" ; Include binary file
FontTilesEnd:

SECTION "Hello World string", ROM0 ; Create another section

HelloWorldStr:
	db "Hello World!", 0 ; Writes in the ROM the phrase in ASCII

SECTION "Functions", ROM0

; Turn off the LCD Screen
lcdOff:
; Next loop is for waiting VBlank for turning LCD off
.waitVBlank ; Label
	ld a, [rLY] ; Load LCD Controler Y-Coordinate
	cp 144 ; Compare to 144 for knowing if it is in VBlank period
	jr c, .waitVBlank ; If it isn't, carry flag is set, so we have to do another loop

	xor a ; ld a, 0
	ld [rLCDC], a ; Set the LCDC bytes to 0 for turn off the LCD screen
	ret ; End of the function