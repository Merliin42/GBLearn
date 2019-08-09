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
	jr nz, cleanMemory
	ret