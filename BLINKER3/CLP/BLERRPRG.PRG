*****************************************************************
*
*  Program  : BLERRPRG.PRG
*           : Blinker/Clipper Summer '87 Error Handler
*  Date     : 92.03.14
*
*  Compiler : Clipper Summer '87
*  Linker   : Blinker 2.0+
*  Compile  : /l
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
* 
extern misc_error
*
private tmperrnum, tmperrmsg
*
tmperrnum = blierrnum ()
*
do case
case tmperrnum = 1201
   tmperrmsg = "unable to find overlay " + blierrprm () + ;
               " in the current PATH"
case tmperrnum = 1202
   tmperrmsg = "DOS read error in file " + blierrprm ()
case tmperrnum = 1203
   tmperrmsg = "file " + blierrprm () + " is not a valid .EXE file"
case tmperrnum = 1204
   tmperrmsg = "overlay file " + blierrprm () + " does not match the .EXE file"
case tmperrnum = 1205
   tmperrmsg = "not enough memory to load procedure"
case tmperrnum = 1206
   tmperrmsg = "maximum procedure nesting depth exceeded"
case tmperrnum = 1207
   tmperrmsg = "demonstration calls limit exceeded"
case tmperrnum = 1208
   tmperrmsg = "demonstration date limit exceeded"
case tmperrnum = 1209
   tmperrmsg = "demonstration time limit exceeded"
case tmperrnum = 1210
   tmperrmsg = "overlay has been prematurely freed"
case tmperrnum = 1211
   tmperrmsg = "overlay manager stack overflow"
case tmperrnum = 1212
   tmperrmsg = "Overlay Opsize exceeded - increase Opsize"
case tmperrnum = 1213
   tmperrmsg = "attempt to call DEFINED routine"
case tmperrnum = 1214
   tmperrmsg = "error accessing EMS overlay cache"
case tmperrnum = 1215
   tmperrmsg = "error accessing XMS overlay cache"
case tmperrnum = 1216
   tmperrmsg = "overlay manager unable to resume"
case tmperrnum = 1217
   tmperrmsg = "overlay vector corrupted during execution"
otherwise
   tmperrmsg = "undefined error"
endcase
*
set color to
@ 1,0
misc_error ("BLINKER", tmperrnum, tmperrmsg, "")
*
