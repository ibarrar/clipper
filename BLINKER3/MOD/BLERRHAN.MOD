(*****************************************************************
*
*  Program  : BLERRHAN.MOD
*           : Blinker / Stony Brook Modula 2 Error Handler
*  Date     : 92.07.17
*
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
*)

MODULE BLERRHAN;

FROM Blinker IMPORT
     BLIERRNUM, BLIERRPRM ;

FROM InOut IMPORT
     WriteString, WriteLn, WriteCard ;

FROM Strings IMPORT
     Append, AppendChar ;

FROM SYSTEM IMPORT
     ADDRESS ;

PROCEDURE BLERRPRG ['_BLERRPRG'] ( ) [LOADDS, ALTERS()];

  VAR tmperrmsg : ARRAY [0..128] OF CHAR ;
      errparam  : ARRAY [0..128] OF CHAR ;
      tmperrnum : CARDINAL ;
      msgptr    : ADDRESS ;

  BEGIN
     tmperrmsg[0] := CHR(0) ;
     errparam[0] := CHR(0) ;
     tmperrnum := BLIERRNUM() ;
     msgptr := BLIERRPRM() ;


     WHILE CHAR(msgptr^) <> CHR(0) DO
        AppendChar(errparam,CHAR(msgptr^));
        msgptr := msgptr + SIZE(CHAR);
     END;

     CASE tmperrnum OF

        1201 : Append(tmperrmsg, 'unable to find overlay ') ;
               Append(tmperrmsg, errparam) ;
               Append(tmperrmsg, ' in the current PATH') ;
      | 1202 : Append(tmperrmsg, 'DOS read error in file ') ;
               Append(tmperrmsg, errparam) ;
      | 1203 : Append(tmperrmsg, 'file ') ;
               Append(tmperrmsg, errparam) ;
               Append(tmperrmsg, ' is not a valid .EXE file') ;
      | 1204 : Append(tmperrmsg, 'overlay file ') ;
               Append(tmperrmsg, errparam) ;
               Append(tmperrmsg, ' does not match the .EXE file') ;
      | 1205 : Append(tmperrmsg, 'not enough memory to load procedure') ;
      | 1206 : Append(tmperrmsg, 'maximum procedure nesting depth exceeded') ;
      | 1207 : Append(tmperrmsg, 'demonstration calls limit exceeded') ;
      | 1208 : Append(tmperrmsg, 'demonstration date limit exceeded') ;
      | 1209 : Append(tmperrmsg, 'demonstration time limit exceeded') ;
      | 1210 : Append(tmperrmsg, 'overlay has been prematurely freed') ;
      | 1211 : Append(tmperrmsg, 'overlay manager stack overflow') ;
      | 1212 : Append(tmperrmsg, 'Overlay Opsize exceeded - increase Opsize') ;
      | 1213 : Append(tmperrmsg, 'Attempt to call DEFINED routine') ;
      | 1214 : Append(tmperrmsg, 'Error accessing EMS overlay cache') ;
      | 1215 : Append(tmperrmsg, 'Error accessing XMS overlay cache') ;
      | 1216 : Append(tmperrmsg, 'Overlay manager unable to resume') ;
      | 1217 : Append(tmperrmsg, 'overlay vector corrupted during execution') ;
      ELSE
         Append(tmperrmsg, 'undefined error');
      END ;

      WriteString('BLINKER : ');
      WriteCard(tmperrnum,4) ;
      WriteString(' ');
      WriteString(tmperrmsg) ;
      WriteLn ;
      HALT(tmperrnum)
END BLERRPRG;

END BLERRHAN.
