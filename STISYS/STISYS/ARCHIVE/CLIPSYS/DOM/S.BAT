@echo off
clipper sr /b/n/a/m
if NOT errorlevel == 0 goto error
rtlink fi sr pll base60
if NOT errorlevel == 0 goto error
echo Good
sr.exe
goto exit
:error
echo Not Good
:exit