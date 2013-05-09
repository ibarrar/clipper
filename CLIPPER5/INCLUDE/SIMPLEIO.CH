/***
*
*	Simpleio.ch
*
*	Definitions for performing simple I/O via standard input and output.
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


#command ?  [ <xList,...> ]                                             ;
      => ( OutStd(Chr(13)+Chr(10)) [, OutStd(<xList>)] )


#command ?? [ <xList,...> ]                                             ;
      => OutStd( <xList> )


#command ACCEPT TO <idVar>                                              ;
      => <idVar> := StrTran( FReadStr(0, 256), Chr(13)+Chr(10) )


#command ACCEPT <cPrompt> TO <idVar>                                    ;
      => ? <cPrompt>                                                    ;
       ; ACCEPT TO <idVar>

#define _SIMPLEIO_CH

