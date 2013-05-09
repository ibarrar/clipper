/*
          Filename : JANUS.ch
           Remarks : JANUS System Dataworks Library Header File
            Author : Ronan J. Paredes
      Date-Written : 16 March, 1993

      ** Modifications **
      Date      Who       Remarks

*/

/*   Color Constants   */
#define DATA_COLORS if(iscolor(),"N/W,W+/B+,,,GR+/N","N/W,W+/N,,,W/N")
#define MENU_COLORS if(iscolor(),"N/BG,W+/BG,W+/R","N/W,N+/W,W/N")
#define STAT_COLORS if(iscolor(),"N/BG","N/W")

/*   Selection Prompts   */
#define SELECT_BAR  chr(24)+chr(25)+chr(26)+chr(27)+"- Select   "+;
                    chr(17)+chr(217)+"-Choose"

/*   Database Manipulation Constants   */
#define DB_SHARED    .F.
#define DB_EXCLUSIVE .T.
#define NUM_SECONDS  5

/*   Data Entry Constants  */
#define APPEND_MODE  1
#define VIEW_MODE    2
#define EDIT_MODE    3
#define DELETE_MODE  4

#define NUM_TO_SKIP  20
#define NUM_PIC      "999,999,999.99"
#define NUM_PIC2     "999999.99"

#xcommand DEFAULT <p> TO <v> [, <p2> TO <v2> ]                             ;
          => <p> := IF( <p> == NIL, <v>, <p> )                             ;
             [; <p2> := IF( <p2> == NIL, <v2>, <p2>) ]

#xtranslate PLAYTUNE( <a> )                                                ;
            => aeval( <a>, {|t| tone( t\[1],t\[2] ) })

#xtranslate {<mm>/<dd>/<yy>}                                               ;
            =>  ctod( #<mm> +"/"+ #<dd> +"/"+ #<yy> )                      ;

#xtranslate  WRITE( [<xList,...>] )                                        ;
             => QQOut( <xList> )

#xtranslate  WRITELN( [<xList,...>] )                                      ;
             => QQOut( <xList> ) ; QQOUT( chr(13) + chr(10) )

#xtranslate  CLRSCR( [<top>], [<left>], [<bottom>], [<right>] )            ;
             => Scroll( <top>, <left>, <bottom>, <right> )                 ;
              ; SetPos(  IF(<top> == NIL, 0, <top>) ,                      ;
                         IF(<left> == NIL, 0, <left>   )
/*
#xtranslate ZEROBLANK( <v>, <c> )                                          ;
            =>  if( <v>==0, space(len( <c> )),transform( <v>, <c> ))
*/
#xtranslate BUMMER()                                                       ;
            => PlayTune({ {392,1}, {98,1}, {49,5} })

#xtranslate HEYTHERE()                                                     ;
            => PlayTune({ {392,1}, {880,1} })

#xtranslate OKDONE()                                                       ;
            => PlayTune({ {784,1}, {784,1} })

#xtranslate  ??? [<xList,...>]                                             ;
             => QQOut( <xList> ) ; QQOUT( chr(13) + chr(10) )

/* Eof<JANUS.ch> */

