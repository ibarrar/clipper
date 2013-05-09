@echo off

:disk
echo Please insert the back-up disk on drive a:, Ctrl-C to abort...
pause
if exist a:backdisk.id goto zipit
echo.
echo The disk in A is not the backup disk...
echo.
goto disk

:zipit
lha a a:\docs *.prg *.rmk
echo  backup process done
