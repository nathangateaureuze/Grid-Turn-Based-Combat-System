set PATH=%~dp0;%PATH%
RGBDS\windows\rgbasm -L -o main.o main.asm
RGBDS\windows\rgblink -o GridCombat.gb main.o
RGBDS\windows\rgbfix -v -p 0xFF GridCombat.gb
RGBDS\windows\rgblink -n GridCombat.sym main.o	
"bgb\bgb" GridCombat.gb
Pause
