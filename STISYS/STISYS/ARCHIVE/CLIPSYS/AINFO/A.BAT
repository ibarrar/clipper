@Echo off
clipper Ainfo /b/n/a/m
if errorlevel 1 goto error
rtlink fi Ainfo pll base50
if errorlevel 1 goto error
ainfo
goto exit
:error
BEEP
Echo Error...
:exit
