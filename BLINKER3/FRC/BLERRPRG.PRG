*****************************************************************
*
*  Program  : BLERRPRG.PRG
*           : Blinker / FORCE error handler
*  Date     : 92.07.22
*
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
*

#include blinker.hdr
#include string.hdr

PROCEDURE BLERRPRG

VARDEF
  CHAR tmperrmsg
  CHAR errparam
  INT tmperrnum
ENDDEF


  tmperrnum = BLIERRNUM()
  errparam  = BLIERRPRMFOR()
  tmperrmsg = ''

     DO CASE

        CASE tmperrnum = 1201
               tmperrmsg = tmperrmsg + 'unable to find overlay '
               tmperrmsg = tmperrmsg + errparam
               tmperrmsg = tmperrmsg + ' in the current PATH'
        CASE tmperrnum = 1202
               tmperrmsg = tmperrmsg + 'DOS read error in file '
               tmperrmsg = tmperrmsg + errparam
        CASE tmperrnum = 1203
               tmperrmsg = tmperrmsg + 'file '
               tmperrmsg = tmperrmsg + errparam
               tmperrmsg = tmperrmsg + ' is not a valid .EXE file'
        CASE tmperrnum = 1204
               tmperrmsg = tmperrmsg + 'overlay file '
               tmperrmsg = tmperrmsg + errparam
               tmperrmsg = tmperrmsg + ' does not match the .EXE file'
        CASE tmperrnum = 1205
               tmperrmsg = tmperrmsg + 'not enough memory to load procedure'
        CASE tmperrnum = 1206
               tmperrmsg = tmperrmsg + 'maximum procedure nesting depth exceeded'
        CASE tmperrnum = 1207
               tmperrmsg = tmperrmsg + 'demonstration calls limit exceeded'
        CASE tmperrnum = 1208
               tmperrmsg = tmperrmsg + 'demonstration date limit exceeded'
        CASE tmperrnum = 1209
               tmperrmsg = tmperrmsg + 'demonstration time limit exceeded'
        CASE tmperrnum = 1210
               tmperrmsg = tmperrmsg + 'overlay has been prematurely freed'
        CASE tmperrnum = 1211
               tmperrmsg = tmperrmsg + 'overlay manager stack overflow'
        CASE tmperrnum = 1212
               tmperrmsg = tmperrmsg + 'Overlay Opsize exceeded - increase Opsize'
        CASE tmperrnum = 1213
               tmperrmsg = tmperrmsg + 'Attempt to call DEFINED routine'
        CASE tmperrnum = 1214
               tmperrmsg = tmperrmsg + 'Error accessing EMS overlay cache'
        CASE tmperrnum = 1215
               tmperrmsg = tmperrmsg + 'Error accessing XMS overlay cache'
        CASE tmperrnum = 1216
               tmperrmsg = tmperrmsg + 'Overlay manager unable to resume'
        CASE tmperrnum = 1217
               tmperrmsg = tmperrmsg + 'overlay vector corrupted during execution'
      OTHERWISE
         tmperrmsg = tmperrmsg + 'undefined error'
      ENDCASE

      CLEAR
      ?
      ? "BLINKER : " + STR(tmperrnum,4,0) + " " + tmperrmsg
      ?
      ?
      QUIT

ENDPRO

