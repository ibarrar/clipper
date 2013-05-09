@echo off
echo copying system into hard disk...
copy dtr.exe c:\
echo.
echo copying data files into hard disk...
d:
if errorlevel 1 goto noddrive
echo creating d:\dtrdata subdirectory
md d:\dtrdata
echo copying data files into d:\dtrdata
copy a:\dtrdata\*.dbf d:\dtrdata
copy a:\dtrdata\*.ntx d:\dtrdata
c:
goto exit
:noddrive
echo creating c:\dtrdata subdirectory
md c:\dtrdata
echo copying data files into c:\dtrdata
copy a:dtrdata\*.dbf c:\dtrdata
copy a:dtrdata\*.dbf c:\dtrdata
:exit
c:
cd\
echo.
echo finished...
echo to execute program type 'dtr '
