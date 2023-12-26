set PATH=%~dp0;%PATH%
RGBDS\windows\rgbasm -L -o src\generated\main.o main.asm
@if errorLevel 1 goto ERROR
RGBDS\windows\rgblink -o src\generated\GridCombat.gb src\generated\main.o
@if errorLevel 1 goto ERROR
RGBDS\windows\rgbfix -v -p 0xFF src\generated\GridCombat.gb
@if errorLevel 1 goto ERROR
RGBDS\windows\rgblink -n src\generated\GridCombat.sym src\generated\main.o	
@if errorLevel 1 goto ERROR
"bgb\bgb" src\generated\GridCombat.gb
exit

:ERROR
@Pause