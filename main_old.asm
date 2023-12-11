INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @ , 0

EntryPoint:
	
WaitVBlank:
	ld a , [rLY]
	cp 144
	jp c , WaitVBlank

	ld a , 0
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
    ld de, Paddle
    ld hl, $8000
    ld bc, PaddleEnd - Paddle
    call Memcopy

	ld de , Ball
	ld hl , $8010
	ld bc , BallEnd - Ball
    call Memcopy

	ld a , 0 
	ld b , 160
	ld hl , _OAMRAM
ClearOam:
	ld [hli] , a
	dec b
	jp nz , ClearOam
	ld hl , _OAMRAM

	ld a , 128 + 16
	ld [hli] , a 
	ld a , 16 + 8
	ld [hli] , a 
	ld a , 0
	ld [hli] , a 
	ld [hli] , a

	ld a , 80
	ld [hli] , a 
	ld a , 62
	ld [hli] , a 
	ld a , $1
	ld [hli] , a
	ld a , 0
	ld [hl] , a

	ld a , LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC] , a 
	ld a , %11100100
	ld [rBGP] , a
	ld [rOBP0] , a

	ld a , %0011
	ld [$FF80] , a

	ld a , 0
	ld [wFrameCounter] , a
Main:
	ld a , [rLY]
	cp 144
	jr nc , Main
WaitVBlank2:
	ld a , [rLY]
	cp 144
	jp c , Main

	ld a , [$FF00]
	cp a , $CE
	jp z , ButtonRight
	cp a , $CD
	jp z , ButtonLeft
ButtonsDone:
	ld a , [wFrameCounter]
	inc a 
	ld [wFrameCounter] , a
	cp a , 2
	jp z , BallMovement
BallMovementDone:
	ld a , [_OAMRAM + 5]
	cp a , $F
	jp z , BallChangeRight
	ld a , [_OAMRAM + 5]
	cp a , $6A
	jp z , BallChangeLeft
XaxisChanged:
	ld a , [_OAMRAM + 4]
	cp a , $18
	jp z , BallChangeDown
	ld a , [_OAMRAM + 4]
	cp a , $A6
	jp z , Out
	cp a , $8B
	jp z , IsOnPaddle
BallChangeDone:
	jp Main

ButtonRight:
	ld a , [$fe01]
	cp a , $68
	jp nz , PaddleGoRight

ButtonLeft:
	ld a , [$fe01]
	cp a , $10
	jp nz , PaddleGoLeft

PaddleGoRight:
	ld a , [_OAMRAM + 1]
	inc a
	ld [_OAMRAM + 1] , a
	jp ButtonsDone

PaddleGoLeft:
	ld a , [_OAMRAM + 1]
	dec a
	ld [_OAMRAM + 1] , a
	jp ButtonsDone

BallMovement:
	ld a , 0
	ld [wFrameCounter] , a

	ld a , [$FF80]
	bit %0010 , a
	jp z , BalleDown
	jp nz , BallUp
Xaxis:
	ld a , [$FF80]
	bit %0001 , a
	jp z , BallRight
	jp nz , BalleLeft

BalleDown:
	ld a , [_OAMRAM + 4]
	inc a 
	ld [_OAMRAM + 4] , a
	jp Xaxis
BallUp:
	ld a , [_OAMRAM + 4]
	dec a 
	ld [_OAMRAM + 4] , a
	jp Xaxis
BallRight:
	ld a , [_OAMRAM + 5]
	inc a 
	ld [_OAMRAM + 5] , a
	jp BallMovementDone
BalleLeft:
	ld a , [_OAMRAM + 5]
	dec a 
	ld [_OAMRAM + 5] , a
	jp BallMovementDone

BallChangeRight:
	ld a , [$FF80]
	res %0001 , a
	ld [$FF80] , a
	jp XaxisChanged
BallChangeLeft:
	ld a , [$FF80]
	set %0001 , a
	ld [$FF80] , a
	jp XaxisChanged
BallChangeUp:
	ld a , [$FF80]
	set %0010, a
	ld [$FF80] , a
	jp BallChangeDone
BallChangeDown:
	ld a , [$FF80]
	res %0010 , a
	ld [$FF80] , a
	jp BallChangeDone

Out:
	ld a , 80
	ld [_OAMRAM + 4] , a 
	ld a , 62
	ld [_OAMRAM + 5] , a 
	jp Main
IsOnPaddle:
	ld hl , $FF81
	ld a , [_OAMRAM + 1]
	add a , 8
	ld [hl] , a
	ld a , [_OAMRAM + 5]
	cp a , [hl]
	jp c , IsAligned
	jp BallChangeDone
IsAligned:
	ld a , [_OAMRAM + 5]
	add a , 6
	ld [hl] , a
	ld a , [_OAMRAM + 1]
	cp a , [hl]
	jp c , BallChangeUp
	jp BallChangeDone

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

Tiles:
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33322222
	dw `33322222
	dw `33322222
	dw `33322211
	dw `33322211
	dw `33333333
	dw `33333333
	dw `33333333
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11111111
	dw `11111111
	dw `33333333
	dw `33333333
	dw `33333333
	dw `22222333
	dw `22222333
	dw `22222333
	dw `11222333
	dw `11222333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33333333
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `33322211
	dw `22222222
	dw `20000000
	dw `20111111
	dw `20111111
	dw `20111111
	dw `20111111
	dw `22222222
	dw `33333333
	dw `22222223
	dw `00000023
	dw `11111123
	dw `11111123
	dw `11111123
	dw `11111123
	dw `22222223
	dw `33333333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `11222333
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `11001100
	dw `11111111
	dw `11111111
	dw `21212121
	dw `22222222
	dw `22322232
	dw `23232323
	dw `33333333
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222211
	dw `22222211
	dw `22222211
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11111111
	dw `11111111
	dw `11221111
	dw `11221111
	dw `11000011
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11222222
	dw `11222222
	dw `11222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222211
	dw `22222200
	dw `22222200
	dw `22000000
	dw `22000000
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11000011
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11000022
	dw `11222222
	dw `11222222
	dw `11222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222200
	dw `22222200
	dw `22222211
	dw `22222211
	dw `22221111
	dw `22221111
	dw `22221111
	dw `11000022
	dw `00112222
	dw `00112222
	dw `11112200
	dw `11112200
	dw `11220000
	dw `11220000
	dw `11220000
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22000000
	dw `22000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `22222222
	dw `11110022
	dw `11110022
	dw `11110022
	dw `22221111
	dw `22221111
	dw `22221111
	dw `22221111
	dw `22221111
	dw `22222211
	dw `22222211
	dw `22222222
	dw `11220000
	dw `11110000
	dw `11110000
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `22222222
	dw `00000000
	dw `00111111
	dw `00111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `11111111
	dw `22222222
	dw `11110022
	dw `11000022
	dw `11000022
	dw `00002222
	dw `00002222
	dw `00222222
	dw `00222222
	dw `22222222
TilesEnd:

Tilemap:
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $05, $06, $05, $06, $05, $06, $05, $06, $05, $06, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0A, $0B, $0C, $0D, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $0E, $0F, $10, $11, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $12, $13, $14, $15, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $07, $03, $16, $17, $18, $19, $03, 0,0,0,0,0,0,0,0,0,0,0,0
	db $04, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $07, $03, $03, $03, $03, $03, $03, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd:

Paddle:
    dw `13333331
    dw `30000003
    dw `13333331
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
PaddleEnd:

Ball:
    dw `13333100
    dw `32222300
    dw `32222300
    dw `32222300
    dw `13333100
    dw `00000000
    dw `00000000
    dw `00000000
BallEnd:

SECTION "Counter", WRAM0
wFrameCounter: db