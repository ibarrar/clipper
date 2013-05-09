(*
 *  SWAPDEMO.MOD - Stony Brook Modula 2
 *  Demonstration program for Blinker swap function
 *
 *  Copyright (c) 1992,93 ASM inc.
 *
 *)

MODULE SWAPDEMO;

FROM Blinker IMPORT
    SWPEMS320, SWPFREEMS, SWPFREXMS, SWPUSEEMS, SWPUSEXMS,
    SWPUSEUMB, SWPDISMSG, SWPVIDMDE, SWPNOBOOT, SWPCURDIR,
    SWPRUNCMD, SWPSETENV, SWPADDENV, SWPSETPID, SWPGETPID,
    SWPGETKEY, SWPERRLEV, SWPERRMAJ, SWPERRMIN, SWPSETSTR,
    SWPGETSTR, SWPKEYBRD, CSTR;

FROM InOut IMPORT
     WriteLn ,
     WriteString ,
     WriteCard ,
     ReadString;

FROM SYSTEM IMPORT
     ADR,
     ADDRESS ;

PROCEDURE YesNo( Flag : BOOLEAN );
BEGIN
    IF Flag THEN
       WriteString('Yes');
    ELSE
       WriteString('No ');
    END ;
END YesNo ;

VAR
  success : BOOLEAN ;
  majerr, minerr, retcode : CARDINAL ;
  msgstr : ARRAY [1..63] OF CHAR;
  retstr : ADDRESS;

BEGIN

  IF NOT (SWPGETPID(ADR('swapdemo.mod'))) THEN
     (* if we're not running already *)

     WriteString ('Stony Brook Modula 2 Swap example') ; WriteLn ;
     WriteString ('=================================') ; WriteLn ;
     WriteLn ;
     WriteString ('Swap defaults      ') ; WriteLn ;
     WriteLn ;
     WriteString ('Use EMS memory                  : ') ;
     YesNo(SWPUSEEMS(FALSE)) ; WriteLn ;
     WriteString ('Use XMS memory                  : ') ;
     YesNo(SWPUSEXMS(FALSE)) ; WriteLn ;
     WriteString ('Use UMBs                        : ') ;
     YesNo(SWPUSEUMB(FALSE)) ; WriteLn ;
     WriteString ('Save/restore video mode         : ') ;
     YesNo(SWPVIDMDE(FALSE)) ; WriteLn ;
     WriteString ('Save/restore directory          : ') ;
     YesNo(SWPCURDIR(FALSE)) ; WriteLn ;
     WriteString ('Display message                 : ') ;
     YesNo(SWPDISMSG(FALSE)) ; WriteLn ;
     WriteString ('Wait for keypress               : ') ;
     YesNo(SWPGETKEY(FALSE)) ; WriteLn ;
     WriteString ('Suppress <Ctrl><Alt><Del>       : ') ;
     YesNo(SWPNOBOOT(FALSE)) ; WriteLn ;

     (* need to pass a far pointer to an ASCIIZ string to swpgetpid, and swpsetpid *)

     WriteString ('Program already running?        : ') ;
     YesNo(SWPGETPID(ADR('swapdemo.mod'))) ; WriteLn ;

     WriteString ('Set program ID to swapdemo.mod  : ') ;
     YesNo(SWPSETPID(ADR('swapdemo.mod'))) ; WriteLn ;
     WriteLn ;

     (* enable ems / xms / umbs *)

     SWPUSEEMS(TRUE) ;
     SWPUSEXMS(TRUE) ;
     SWPUSEUMB(TRUE) ;

     (* save / restore current directory and video mode *)
     (* video buffer contents are not saved *)

     SWPCURDIR(TRUE) ;
     SWPVIDMDE(TRUE) ;

     (* if we're not running already *)
     WriteString ('Shelling to DOS...'); WriteLn ;
     WriteString ('Run swapdemo again to see SWPGETPID.'); WriteLn;
     WriteString ('-------------------------------------------------------------------------'); WriteLn ;

     (* status = SWPRUNCMD(ChildProg, Memory, Shell Directory, Temporary directory) *)

     success := SWPKEYBRD(ADR('"dir /w"{enter}"swapdemo"')) ;
     SWPSETENV(ADR('PROMPT=Modula 2 SwapDemo - $p$g')) ;
     success := SWPRUNCMD(ADR(''), 0, ADR(''),ADR('') ) ;

     retcode := SWPERRLEV() ;
     majerr  := SWPERRMAJ() ;
     minerr  := SWPERRMIN() ;

     WriteString ('-------------------------------------------------------------------------'); WriteLn ;
     WriteString ('Did shell succeed               : ') ;
     YesNo(success); WriteLn ;
     WriteString ('Major error code is             : ') ;
     WriteCard(majerr,3) ; WriteLn ;
     WriteString ('Minor error code is             : ') ;
     WriteCard(minerr,3) ; WriteLn ;
     WriteString ('Child process return code was   : ') ;
     WriteCard(retcode,3) ; WriteLn ;
     WriteString ('Child return string was         : ') ;
     retstr := SWPGETSTR() ;
     WriteString (retstr^:CSTR) ; WriteLn ;

  ELSE (* we're already running, terminate the program *)

     WriteLn ;
     WriteString('SwapDemo.mod is already running') ; WriteLn ;
     WriteString("Please enter a message to return to the parent"); WriteLn;
     WriteString("Message : ");
     ReadString(msgstr);
     WriteLn;
     success := SWPSETSTR(ADR("swapdemo.mod"),ADR(msgstr)) ;
     WriteString('Type EXIT to return to previous swapdemo.mod') ; WriteLn ;
  END

END SWAPDEMO.
