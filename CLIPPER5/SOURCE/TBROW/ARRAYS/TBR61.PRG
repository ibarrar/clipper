/************************************************************************
 TBR61.PRG

 This demo will take an array and add the columns on the fly.  The user
 can edit a number and the total in the footer will be updated upon hitting
 enter.

 Clipper Tbr61 /n/w/b
 Rtlink Fi Tbr61 /pll:base52

***********************************************************************/

#include "inkey.ch"
#include "setcurs.ch"

#define COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define MYCOLORS   "W+/BG,W+/B"

#xcommand   STABILIZE <obj> INKEY [TO] <x> => ;
	    DISPBEGIN();;
	    WHILE (!<obj>:stabilize()) .AND.;
	         ((<x> := INKEY()) == 0);;
	    END;;
	    DISPEND()

#define MAXLEN    14

FUNCTION Main()

LOCAL b, nKey, column, bBlock, nGtotal
LOCAL nSubscript := 1
LOCAL k := 0
LOCAL cScreen
LOCAL aArray := { 100.34, 45.90, 123.00, -6.89, ;
		   12.98,  3.05, 945.00, -4.01, ;
		  145.89, 55.78, -34.00, 39.33, ;
		   16.00, 18.34;
		}

cScreen := savescreen()
set(_SET_SCOREBOARD, .f. )
setcursor(0)
setcolor("N/W")
scroll()
@ 2, 14 TO 21, 36 DOUBLE COLOR MYCOLORS
@ MAXROW(), 0 SAY PADR( "ESC - Quit" +;
			SPACE(20) +;
			"Enter - Edit", ;
			Maxcol() + 1) ;
			COLOR "W+/RB"

b := TbrowseNew( 3, 15, 20, 35 )
b:colorSpec := MYCOLORS
b:headSep   := HEADSEP
b:colSep    := COLSEP
b:footSep   := FOOTSEP
b:goTopBlock   := {|| nSubscript := 1}
b:goBottomBloc := {|| nSubscript := MAXLEN }
b:SkipBlock    := {|x| ;
 		  k := If(ABS(x) >= IF(x >= 0,;
 		  MAXLEN - nSubscript, nSubscript - 1),;
 		  IF(x >= 0, MAXLEN - nSubscript,;
 		  1 - nSubscript),;
 		  x), nSubscript += k,;
 		  k }

//Total

bBlock := {|| nGtotal := 0, ;
	      Aeval(aArray, {|x| nGtotal += x}),;
	      "Total: " + STR(nGtotal, 12, 2)}

column := TbcolumnNew( "Values", ;
			{|p| If( p == NIL, aArray[nSubscript],;
			       aArray[nSubscript] := p)})

column:width   := 20
column:footing := Eval(bBlock)
b:addcolumn( column )

WHILE .T.
  STABILIZE b INKEY TO nKey

  IF (b:stable)
     nKey := INKEY(0)
  ENDIF

  IF !TbMoveCursor( nKey, b )
     IF (nKey == K_ESC )
        EXIT
     ELSEIF (nKey == K_ENTER)
        DoGet( b )
/*
   This is not a generic solution since "column" assumes you are
   already in the proper place or you have only one column.

   A generic solution should use :
     browse:getColumn(browse:colpos)
   In order to get the reference to the current column.
*/
        column:footing := Eval(bBlock)
        b:configure()
        b:invalidate()
     ENDIF
  ENDIF

END
SCROLL()
restscreen(,,,,cScreen)
RETURN(NIL)


/*******
*
*
* Cursor Movement Methods
*
*/



STATIC FUNCTION TbMoveCursor( nKey, oObj )

  LOCAL nFound
  STATIC aKeys := ;
     { K_DOWN          , {|b| b:down()},;
       K_UP            , {|b| b:up()},;
       K_PGDN          , {|b| b:pagedown()},;
       K_PGUP          , {|b| b:pageup()},;
       K_CTRL_PGUP     , {|b| b:gotop()},;
       K_CTRL_PGDN     , {|b| b:goBottom()},;
       K_RIGHT         , {|b| b:right()},;
       K_LEFT          , {|b| b:left()},;
       K_HOME          , {|b| b:home()},;
       K_END           , {|b| b:end()},;
       K_CTRL_LEFT     , {|b| b:panleft()},;
       K_CTRL_RIGHT    , {|b| b:panright()},;
       K_CTRL_HOME     , {|b| b:panhome()},;
       K_CTRL_END      , {|b| b:panend()} }

  nFound := Ascan( aKeys, nKey )
  IF (nFound != 0 )
    EVAL( aKeys[++nFound], oObj )
  ENDIF

  RETURN( nFound != 0 )


/******
*
*
*  @. . . Get
*
*/



STATIC FUNCTION DoGet( obj )

  LOCAL nCursSave
  LOCAL column, get, nKey

  nCursSave := Setcursor(1)

  WHILE ( !obj:stabilize() )
  END

  column := obj:getColumn( obj:colpos )
  get := GetNew( ROW(), COL(), column:block,;
              column:heading,, obj:colorspec)
  READMODAL( {get} )
  obj:refreshCurrent()

  nKey := LastKey()

  IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
       nKey == K_PGUP .OR. nKey == K_PGDN )
       KEYBOARD CHR( nKey )
  ENDIF

  Setcursor(0)
  RETURN(NIL)

