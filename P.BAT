
REM This assembles the player and link with the rest of the files.

rem Tasm amsplay/m/q
rem Tasm amsshell /m /q



Tasmx play /m /q
Tlink /3 pmode+io+amsplay+amsshell+play,play
@del play.obj >nul
smartdrv/c
del fatal.exe
ren play.exe fatal.exe
call pp fatal.exe
copy /b fatal.exe+k.ams
