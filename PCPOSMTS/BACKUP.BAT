@echo off
del source.zip
del source1.zip
del source2.zip
del source3.zip
call pkzip -rP source *.prg *.ch *.c *.h *.lnk *.rmk *.bat *.lib
call pkzip -rP source1 c:\faccess\new\*.c c:\faccess\new\*.h c:\faccess\new\*.rmk c:\faccess\new\*.bat
call pkzip -rP source2 c:\pentium\driver\spectrum\*.c  c:\pentium\driver\spectrum\*.asm c:\pentium\driver\spectrum\*.h c:\pentium\driver\spectrum\*.inc c:\pentium\driver\spectrum\*.ext
call pkzip -rP source3 c:\pcposmts\*.ch c:\pcposmts\*.lib c:\pcposmts\*.h 
dir source.*
PAUSE Press any key to copy source.zip to disk in drive a:...
copy source.zip a: /v
copy source1.zip a: /v
copy source2.zip a: /v
copy source3.zip a: /v
