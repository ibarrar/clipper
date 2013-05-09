'****************************************************************
'
'  Program  : BLERRPRG BAS
'           : MS BASIC Error Handler
'  Date     : 92.07.21
'
'  Compiler : Microsoft Basic PDS / QuickBasic / VBDOS
'  Linker   : Blinker 2.1
'  Compile  : BC blerrprg /O;
'
'  Note     : Overlaying of this file is NOT recommended, because
'           : if a severe error occurs, it may be impossible to
'           : load this error handler into memory, in which case
'           : the error will never be reported, making debugging
'           : difficult.
'
'
'
'$INCLUDE:'BLINKER.BI'

SUB BLERRPRG

tmperrnum% = blierrnum%
'
select case tmperrnum%
case 1201
   tmperrmsg$ = "unable to find overlay " + blierrprmbas$ + " in the current PATH"
case 1202
   tmperrmsg$ = "DOS read error in file " + blierrprmbas$
case 1203
   tmperrmsg$ = "file " + blierrprmbas$ + " is not a valid .EXE file"
case 1204
   tmperrmsg$ = "overlay file " + blierrprmbas$ + " does not match the .EXE file"
case 1205
   tmperrmsg$ = "not enough memory to load procedure"
case 1206
   tmperrmsg$ = "maximum procedure nesting depth exceeded"
case 1207
   tmperrmsg$ = "demonstration calls limit exceeded"
case 1208
   tmperrmsg$ = "demonstration date limit exceeded"
case 1209
   tmperrmsg$ = "demonstration time limit exceeded"
case 1210
   tmperrmsg$ = "overlay has been prematurely freed"
case 1211
   tmperrmsg$ = "overlay manager stack overflow"
case 1212
   tmperrmsg$ = "Overlay Opsize exceeded - increase Opsize"
case 1213
   tmperrmsg$ = "attempt to call DEFINED routine"
case 1214
   tmperrmsg$ = "error accessing EMS overlay cache"
case 1215
   tmperrmsg$ = "error accessing XMS overlay cache"
case 1216
   tmperrmsg$ = "overlay manager unable to resume"
case 1217
   tmperrmsg$ = "overlay vector corrupted during execution"
case else
   tmperrmsg$ = "undefined error"
end select
'
cls
print "BLINKER :"; str$(tmperrnum%); " : "; tmperrmsg$
end

END SUB
