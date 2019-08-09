; Read Inputs
; Return Inputs in _PAD
; down | up | left | right | start | select | B | A
readInputs:
	ld a, %00100000 ; Read the directional pad
	ld [rP1], a

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
	ld [rP1], a

	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]

	and a, $0F
	add b
	cpl
	ld [_PAD], a
	ret