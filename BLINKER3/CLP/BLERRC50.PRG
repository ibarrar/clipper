/****************************************************************
*
*  Program  : BLERRC50.PRG
*           : Blinker/CA-Clipper 5.x Error Handler
*  Date     : 93.09.28
*
*  Compiler : CA-Clipper 5.x
*  Linker   : Blinker 2.x and above
*  Compile  : /n/m/w/l
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
*/

#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

function BlErrc50()
local bBliError, bOldErrBlk, nErrCode, oErr, lUseErrBlk, i
public lInErr

// First check we're not in a multiple error situation
// (likely cause of multiple error is an error loading
// an overlay while in an error situation)

if m->lInErr
*  ?  "Blinker error :   "
*  ?? BliErrNum()
*  ?  "(Multiple errors occurred while in error handler)"
   quit
endif

m->lInErr := .T.                                // In an error
lUseErrBlk = .t.                                // Use BLINKER error block

oErr := ErrorNew()                              // Create error object

nErrCode       := BliErrNum()                   // Blinker Error Number
oErr:subsystem := [BLINKER]                     // Failing Subsystem name
oErr:subCode   := nErrCode                      // Blinker error number
oErr:canRetry  := .F.                           // Not Retryable
oErr:severity  := 3                             // Maximum severity

do case
   case nErrCode = 1201
        oErr:description := [unable to find overlay file ]+BliErrPrm()+[ in current path]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1202
        oErr:description := [DOS read error in file ]+BliErrPrm()
        oErr:filename    := BliErrPrm()
   case nErrCode = 1203
        oErr:description := [file ]+BliErrPrm()+[ is not a valid .EXE file]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1204
        oErr:description := [overlay file ] + BliErrPrm() + [ does not match the .EXE file]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1205
        oErr:description := [not enough memory to load procedure]
   case nERRCode = 1206
        oErr:description := [maximum procedure nesting depth exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1207
        oErr:description := [demonstration calls limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1208
        oErr:description := [demonstration date limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1209
        oErr:description := [demonstration time limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1210
        oErr:description := [overlay has been prematurely freed]
   case nERRCode = 1211
        oErr:description := [overlay manager internal stack overflow]
   case nERRCode = 1212
        oErr:description := [Overlay Opsize exceeded - increase Opsize]
   case nERRCode = 1213
        oErr:description := [attempt to call DEFINED routine]
        lUseErrBlk = .f.
   case nERRCode = 1214
        oErr:description := [error accessing EMS overlay cache]
   case nERRCode = 1215
        oErr:description := [error accessing XMS overlay cache]
   case nERRCode = 1216
        oErr:description := [overlay manager unable to resume]
   case nERRCode = 1217
        oErr:description := [overlay vector corrupted during execution]
   otherwise
        oErr:description := [unknown BLINKER error]
end case


for i = 1 to 60                                 // Cheap substitute for CLS
   ? ""                                         // So that it does not
next                                            // Force in the screen drivers

if lUseErrBlk
   bOldErrBlk := ErrorBlock({|e|BliError(e)})   // Install new error handler
else
   ?? "Blinker error" + str (oErr:subCode,5)
   ?? " :", oErr:description                    // Just in case error handler
   ? ""                                         // fails
endif

if (ErrorBlock() <> NIL)
   eval(Errorblock(),oErr)                      // Evaluate the error block
else
   quit
end

if lUseErrBlk
   Errorblock(bOldErrBlk)                       // Restore the previous handler
endif

m->lInErr := .F.

return (nil)

// Blinker error handler

Static Function BliError(e)
local i

   ? "Error         : "

   if ( !Empty(e:subsystem()) )
      ?? e:subsystem() + "/" + Ltrim(Str(e:subCode()))
   end
   if ( !Empty(e:description()) )
      ? "Description   : " + e:description()
   end
   if ( !Empty(e:filename()) )
      ? "Filename      : " + e:filename()
   end
   ? ""
   ? "Call Trace"
   i := 3
   while ( !Empty(ProcName(i)) )
      ? "Called from   : ", Left(ProcName(i)+SPACE(20),20) + ;
         "(" + Substr(SPACE(7)+Str(ProcLine(i)),-7) + ")  "
      i++
   end
   ? ""
   ERRORLEVEL(1)
   QUIT                                         // terminate application
   return (nil)

