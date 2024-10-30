INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/states/gameplay/backgrounds/background1.asm"
INCLUDE "src/main/utils/inputsJoypad.asm"
INCLUDE "src/main/states/gameplay/objects/character.asm"

DEF BRICK_LEFT EQU $05
DEF BRICK_RIGHT EQU $06
DEF BLANK_TILE EQU $08

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @ , 0

EntryPoint:
	ld a, AUDENA_OFF
	ld [rNR52], a
WaitVBlank:
	ld a , [rLY]
	cp 144
	jp c , WaitVBlank

	ld a , LCDCF_OFF
	ld [rLCDC] , a

	; Copy the tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
	call Memcopy

	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
	call Memcopy

	; Copy the tile data
	ld de, PlayerTile
	ld hl, $8000
	ld bc, PlayerTileEnd - PlayerTile
	call Memcopy

	ld a , 0 
	ld b , 160
	ld hl , _OAMRAM
ClearOam:
	ld [hli] , a
	dec b
	jp nz , ClearOam
	ld hl , _OAMRAM

	; Initialize the player sprite in OAM
	ld hl, _OAMRAM
	ld a, 128 + 16
	ld [hli], a
	ld a, 16 + 8
	ld [hli], a
	ld a, 0
	ld [hli], a
	ld [hli], a



	ld a , LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8
	ld [rLCDC] , a 
	ld a , %11100100
	ld [rBGP] , a
	ld [rOBP0] , a

	ld a, 3
	ld [wCharacterMovPo], a

	ld a , 0
	ld [wFrameCounter] , a
Main:
	ld a, [rLY]
	cp 144
	jp nc, Main
	ld a , 0
	ld [wFrameCounter] , a
WaitVBlank2:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank2

	;Save previous Positions
	ld hl, _OAMRAM + 1
	ld a, [hl]
	ld [wCharacterLastX], a
	ld hl, _OAMRAM
	ld a, [hl]
	ld [wCharacterLastY], a

	; Check the current keys
	call UpdateKeys
	call CheckKeysState

	ld a, [wNoneKeyPressed]
	cp a, 1
	jp nz, Main

	ld hl, _OAMRAM + 1
	ld a, [hl]
	sub a, 8
	ld b, a
	ld hl, _OAMRAM
	ld a, [hl]
	sub a, 16
	ld c, a
	call GetTileByPixel
	ld [hl], 4

	ld hl, wCharacterLastX
	ld a, [hl]
	sub a, 8
	ld b, a
	ld hl, wCharacterLastY
	ld a, [hl]
	sub a, 16
	ld c, a
	call GetTileByPixel
	ld [hl], 0
	
	jp Main





; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, Memcopy
	ret


; Checks if a brick was collided with and breaks it if possible.
; @param hl: address of tile.
CheckAndHandleBrick:
	ld a, [hl]
	cp a, BRICK_LEFT
	jr nz, CheckAndHandleBrickRight
	; Break a brick from the left side.
	ld [hl], BLANK_TILE
	inc hl
	ld [hl], BLANK_TILE
CheckAndHandleBrickRight:
	cp a, BRICK_RIGHT
	ret nz
	; Break a brick from the right side.
	ld [hl], BLANK_TILE
	dec hl
	ld [hl], BLANK_TILE
	ret

; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
GetTileByPixel:
	; First, we need to divide by 8 to convert a pixel position to a tile position.
	; After this we want to multiply the Y position by 32.
	; These operations effectively cancel out so we only need to mask the Y value.
	ld a, c
	and a, %11111000
	ld l, a
	ld h, 0
	; Now we have the position * 8 in hl
	add hl, hl ; position * 16
	add hl, hl ; position * 32
	; Convert the X position to an offset.
	ld a, b
	srl a ; a / 2
	srl a ; a / 2	} /8
	srl a ; a / 2	
	; Add the two offsets together.
	add a, l
	ld l, a
	adc a, h
	sub a, l
	ld h, a
	; Add the offset to the tilemap's base address, and we are done!
	ld bc, $9800
	add hl, bc
	ret

; @param a: tile ID
; @return z: set if a is a wall.
IsWallTile:
	cp a, $00
	ret z
	cp a, $01
	ret z
	cp a, $02
	ret z
	cp a, $04
	ret z
	cp a, $05
	ret z
	cp a, $06
	ret z
	cp a, $07
	ret

PlayerTile:
	dw `00010100
	dw `00101010
	dw `00222101
	dw `03232210
	dw `32222211
	dw `00222220
	dw `00222221
	dw `03232230
PlayerTileEnd:

SECTION "Counter", WRAM0
wFrameCounter: db