all :
	./RGBDS/rgbasm -L -o main.o main.asm
	./RGBDS/rgblink -o unbricked.gb main.o
	./RGBDS/rgbfix -v -p 0xFF unbricked.gb
	./RGBDS/rgblink -n unbricked.sym main.o	
	clear
