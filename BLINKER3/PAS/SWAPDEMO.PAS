{*
 *
 *  Blinker 2.1 swap function demo
 *
 *  MS PASCAL 4.0
 *
 *  Copyright (c) A.S.M. Inc, 1992, 1993
 *
 *  Compile:  PAS1 swapdemo;
 *            PAS2
 *
 *}

program swapdemo(input,output);

{$include : 'blinker.inc'}

const
  ON  = 1 ;
  OFF = 0 ;

var
  i      : integer ;
  keystr : string (100);
  retptr : ADS of string(100);

begin

   if (SWPGETPID(ADS('swapdemo.pas')) = 0) THEN { if we're not running already }
      begin
      writeln (output,'Pascal Swap example') ;
      writeln (output,'===================') ;
      writeln (output,' ') ;
      writeln (output,'Swap defaults      ') ;
      writeln (output,' ') ;
      writeln (output,'Use EMS memory                  : ',SWPUSEEMS(OFF)) ;
      writeln (output,'Use XMS memory                  : ',SWPUSEXMS(OFF)) ;
      writeln (output,'Use UMBs                        : ',SWPUSEUMB(OFF)) ;
      writeln (output,'Save/restore video mode         : ',SWPVIDMDE(OFF)) ;
      writeln (output,'Save/restore directory          : ',SWPCURDIR(OFF)) ;
      writeln (output,'Display message                 : ',SWPDISMSG(OFF)) ;
      writeln (output,'Wait for keypress               : ',SWPGETKEY(OFF)) ;
      writeln (output,'Suppress <Ctrl><Alt><Del>       : ',SWPNOBOOT(OFF)) ;
      writeln (output,' ') ;

      { need to pass a far pointer to an ASCIIZ string to bligetpid, and blisetpid }

      writeln (output,'Program already running?        : ',SWPGETPID(ads('swapdemo.pas'*chr(0)))) ;
      writeln (output,'Set program ID to swapdemo.pas  : ',SWPSETPID(ads('swapdemo.pas'*chr(0)))) ;
      writeln (output,' ') ;

      { enable ems / xms / umbs }

      i := SWPUSEEMS(ON) ;
      i := SWPUSEXMS(ON) ;
      i := SWPUSEUMB(ON) ;

      { save / restore current directory and video mode }
      { video buffer contents are not saved }

      i := SWPCURDIR(ON) ;
      i := SWPVIDMDE(ON) ;

      writeln (output,'Shelling to DOS...');
      writeln (output,'Run swapdemo again to see SWPGETPID.');
      writeln (output,'-------------------------------------------------------------------------');

      { Set a new prompt }

      i := SWPSETENV(ads ('PROMPT=Pascal SwapDemo - $p$g'*chr(0))) ;

      i := SWPKEYBRD(ads('hello'*chr(0))) ;


      i := SWPKEYBRD(ads (chr(34)*'dir /w'*chr(34)*chr(123)*'enter'*chr(125)*chr(34)*'swapdemo'*chr(34)*chr(0))) ;

      i := SWPRUNCMD(ads(chr(0)), 0, ads(chr(0)),ads(chr(0)) ) ;

      writeln (output,'-------------------------------------------------------------------------');
      writeln (output,'Back from shell, status is      : ',i);
      writeln (output,'Major error code is             : ',SWPERRMAJ) ;
      writeln (output,'Minor error code is             : ',SWPERRMIN) ;
      writeln (output,'Child process return code was   : ',SWPERRLEV) ;
      retptr := SWPGETSTR ;
      writeln (output,'Child process return string was : ',retptr^) ;
      writeln;
      end
   else { we're already running, terminate the program }
      begin
      writeln(output,'This is the second invocation of SWAPDEMO');
      writeln(output,'Please enter a message to return to the parent');
      readln (input,keystr);

      i := SWPSETSTR (ads('swapdemo.pas'*chr(0)),ads(keystr)) ;

      writeln(output,'Type EXIT to return to previous swapdemo.pas') ;
   end
end.
