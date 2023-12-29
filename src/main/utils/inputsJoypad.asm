SECTION "InputsJoypad", ROM0

UpdateKeys::
	; Poll half the controller
	ld a, P1F_GET_BTN
	call .onenibble
	ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

	; Poll the other half
	ld a, P1F_GET_DPAD
	call .onenibble
	swap a ; A3-0 = unpressed directions; A7-4 = 1
	xor a, b ; A = pressed buttons + directions
	ld b, a ; B = pressed buttons + directions

	; And release the controller
	ld a, P1F_GET_NONE
	ldh [rP1], a

	; Combine with previous wCurKeys to make wNewKeys
	ld a, [wCurKeys]
	xor a, b ; A = keys that changed state
	and a, b ; A = keys that changed to pressed
	ld [wNewKeys], a
	ld a, b
	ld [wCurKeys], a
	ret

.onenibble
	ldh [rP1], a ; switch the key matrix
	call .knownret ; burn 10 cycles calling a known ret
	ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
	ldh a, [rP1]
	ldh a, [rP1] ; this read counts
	or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
	ret

CheckKeysState::
	ld a, [wNoneKeyPressed]
	inc a
	ld [wNoneKeyPressed], a
; First, check if the down button is pressed.
CheckDown:
	ld a, [wCurKeys]
	and a, PADF_DOWN
	jp nz, CheckAlreadyDown
	ld a, [wPressedKeys]
	RES 7, a
	ld [wPressedKeys], a
	jp CheckUp
CheckAlreadyDown:
	ld a, [wPressedKeys]
	BIT 7, a
	jp nz, CheckUp
Down:
	ld a, [wPressedKeys]
	or a, %1000_0000
	ld [wPressedKeys], a
	; Move the player one pixel to the right.
	ld a, [_OAMRAM]
	add a, $8
	ld [_OAMRAM], a
	ret

; Then check the right button.
CheckUp:
	ld a, [wCurKeys]
	and a, PADF_UP
	jp nz, CheckAlreadyUp
	ld a, [wPressedKeys]
	RES 6, a
	ld [wPressedKeys], a
	jp CheckLeft
CheckAlreadyUp:
	ld a, [wPressedKeys]
	BIT 6, a
	jp nz, CheckLeft
Up:
	ld a, [wPressedKeys]
	or a, %0100_0000
	ld [wPressedKeys], a
	; Move the player one pixel to the right.
	ld a, [_OAMRAM]
	sub a, $8
	ld [_OAMRAM], a
	ret

; First, check if the left button is pressed.
CheckLeft:
	ld a, [wCurKeys]
	and a, PADF_LEFT
	jp nz, CheckAlreadyLeft
	ld a, [wPressedKeys]
	RES 5, a
	ld [wPressedKeys], a
	jp CheckRight
CheckAlreadyLeft:
	ld a, [wPressedKeys]
	BIT 5, a
	jp nz, CheckRight
Left:
	ld a, [wPressedKeys]
	or a, %0010_0000
	ld [wPressedKeys], a
	; Move the player one pixel to the left.
	ld a, [_OAMRAM + 1]
	sub a, $8
	ld [_OAMRAM + 1], a
	ret

; Then check the right button.
CheckRight:
	ld a, [wCurKeys]
	and a, PADF_RIGHT
	jp nz, CheckAlreadyRight
	ld a, [wPressedKeys]
	RES 4, a
	ld [wPressedKeys], a
	jp NoneKeys
CheckAlreadyRight:
	ld a, [wPressedKeys]
	BIT 4, a
	jp nz, NoneKeys
Right:
	ld a, [wPressedKeys]
	or a, %0001_0000
	ld [wPressedKeys], a
	; Move the player one pixel to the right.
	ld a, [_OAMRAM + 1]
	add a, $8
	ld [_OAMRAM + 1], a
    ret
NoneKeys:
	ld a, 0
	ld [wNoneKeyPressed], a
	ret

SECTION "Input Joypad Variables", WRAM0
wCurKeys:: db
wNewKeys:: db
wPressedKeys:: db
wNoneKeyPressed:: db