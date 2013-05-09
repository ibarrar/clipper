/***
*
*  Assert.ch
*
*  Assertion header file for debugging programs
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Usage:   ASSERT( <condition> [, <msg>] )
*
*  If <condition> evaluates to true (.T.), ASSERT() does nothing.
*  Otherwise a message is written to STDOUT and the application
*  terminates. If <msg> is specified, it determines the message
*  produced if the assertion fails. Otherwise, the text of the
*  condition itself is output as the message.
*
*  Examples:
*           ASSERT( n > 0 .AND. n < Len(a), "bad array index" )
*           ASSERT( RECCOUNT() <> 0 )
*
*
*  NOTES:
*
*  ASSERT must occur as a statement by itself. The parentheses
*  surrounding the condition and message are required.
*
*  Defining the symbol NDEBUG at compile time (use /dNDEBUG on
*  the compile line) removes all assertions from your program.
*
*  This header file detects the fact that it has been #included
*  more than once in a compile, so it is safe to #include it
*  almost anywhere.
*
*  Refer to Asrtdemo.prg for an example of ASSERT.
*
*/


#ifndef _ASSERT_DEFINED

#ifndef NDEBUG

#command ASSERT( <exp> [, <msg>] )                                      ;
                                                                        ;
      => IF ( !(<exp>) )                                                ;
       ;   OUTSTD(                                                      ;
                   CHR(13) + CHR(10) + PROCNAME(0) +                    ;
                   "(" + LTRIM(STR(PROCLINE())) + ")" +                 ;
                   "  Assertion failed: " +                             ;
                   IF( <.msg.>, <msg>, <"exp"> )                        ;
                 )                                                      ;
       ;   QUIT                                                         ;
       ; ENDIF

#else  // If NDEBUG is definded, ignore all occurences of ASSERT()

#command ASSERT( <exp> [, <msg>] )      =>

#endif // NDEBUG

#define _ASSERT_DEFINED

#endif // _ASSERT_DEFINED
