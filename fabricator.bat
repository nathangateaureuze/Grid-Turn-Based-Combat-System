set PATH=%~dp0;%PATH%
D:\unbricked\RGBDS\windows\rgbasm -L -o main.o main.asm
D:\unbricked\RGBDS\windows\rgblink -o unbricked.gb main.o
D:\unbricked\RGBDS\windows\rgbfix -v -p 0xFF unbricked.gb
D:\unbricked\RGBDS\windows\rgblink -n unbricked.sym main.o	
unbricked.gb	
Pause
