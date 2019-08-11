; Turn of the screen
lcdOff:
	ld a, [rLCDC]
	rlca ; It sets the high bit of LCDC in the carry flag
	ret nc

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