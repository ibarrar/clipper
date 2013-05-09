/***
*
*  Common.ch
*
*  Commonly used definitions
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#define TRUE  .T.
#define FALSE .F.
#define YES   .T.
#define NO    .F.

#translate ISNIL( <v1> )         => ( <v1> == NIL )
#translate ISARRAY( <v1> )       => ( valtype( <v1> ) == "A" )
#translate ISBLOCK( <v1> )       => ( valtype( <v1> ) == "B" )
#translate ISCHARACTER( <v1> )   => ( valtype( <v1> ) == "C" )
#translate ISDATE( <v1> )        => ( valtype( <v1> ) == "D" )
#translate ISLOGICAL( <v1> )     => ( valtype( <v1> ) == "L" )
#translate ISMEMO( <v1> )        => ( valtype( <v1> ) == "M" )
#translate ISNUMBER( <v1> )      => ( valtype( <v1> ) == "N" )
#translate ISOBJECT( <v1> )      => ( valtype( <v1> ) == "O" )

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                        ;
          =>                                                            ;
          IF <v1> == NIL ; <v1> := <x1> ; END                           ;
          [; IF <vn> == NIL ; <vn> := <xn> ; END ]

#command UPDATE <v1> IF <exp> TO <v2> ;
         =>                           ;
         IF <exp> ; <v1> := <v2> ; END
