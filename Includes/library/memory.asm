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
; d - Number to fill
; bc - Counter
cleanMemory:
	ld a, d ; ld a, 0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, cleanMemory
	ret

; Clear a memory location
; Parameters :
; hl - Destination address
; bc - Counter
clearMemory:
	xor a ; ld a, 0
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, clearMemory
	ret