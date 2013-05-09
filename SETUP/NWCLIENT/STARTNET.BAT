@ECHO OFF
SET NWLANGUAGE=ENGLISH
LH /L:1,18512 LSL
LH /L:1,21088 DE220ODI.COM
LH /L:1,30576 IPXODI /D /A
LH /L:0;1,33744;2,17520 /S VLM /V4
if errorlevel 1 goto error
f:
login rollie
goto end
:error
Echo Error locating Network... check Hubs.
:end 

