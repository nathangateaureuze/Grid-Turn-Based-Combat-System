INCLUDE "src/main/utils/hardware.inc"

SECTION "CharacterMovement", ROM0

; Move the player 8 pixel to the Down.
CharacterGoDown::
	ld a, [_OAMRAM]
	add a, $8
	ld [_OAMRAM], a
    ret

; Move the player 8 pixel to the Up.
CharacterGoUp::
	ld a, [_OAMRAM]
	sub a, $8
	ld [_OAMRAM], a
	ret

; Move the player 8 pixel to the left.
CharacterGoLeft::
	ld a, [_OAMRAM + 1]
	sub a, $8
	ld [_OAMRAM + 1], a
    ret

; Move the player 8 pixel to the right.
CharacterGoRight::
	ld a, [_OAMRAM + 1]
	add a, $8
	ld [_OAMRAM + 1], a
    ret 

SECTION "Character", WRAM0
wCharacterLastX: db
wCharacterLastY: db
wCharacterMovPo: db