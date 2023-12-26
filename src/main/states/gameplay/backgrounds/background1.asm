SECTION "Background1", ROM0

Tiles::
	dw `13333331
	dw `30000003
	dw `30000003
	dw `30000003
	dw `30000003
	dw `30000003
	dw `30000003
	dw `13333331
TilesEnd::


Tilemap::
REPT 1023
    db 0
ENDR
TilemapEnd::