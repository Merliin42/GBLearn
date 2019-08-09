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