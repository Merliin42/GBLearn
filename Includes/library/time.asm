; Count from bc to 0
; Parameters :
; bc - Counter
delay:
	dec bc
	ld a, b
	or c
	jr nz, delay
	ret