@echo off
if "%1" == "" goto error1
del %1.exe
clipper %1.prg /n/a/m/w/es2/ic:\powerpos\header >err
if errorlevel 1 goto error
blinker fi %1 @FACCESS >> err 
type err
goto end
:error1
BEEP
echo " syntax error pass the filename to link to faccess...dummy!!!"
goto end
:error
BEEP
type err
ne %1.prg
:end