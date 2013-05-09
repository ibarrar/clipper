/***
*
*  Tbdemo.prg
*
*  Illustration of TBROWSE and GET objects.
*
*  Copyright (c) 1990-1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Compile:  CLIPPER Tbdemo /m /n /w
*  Link:     RTLINK FILE Tbdemo
*  Execute:  Tbdemo <dbf> [<ntx>]
*
*/

#include "Common.ch"
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Error.ch"


/* 
*  These #defines use the browse's "cargo" slot to hold the
*  "append mode" flag for the browse. The #defines make it
*  easy to change this later (e.g. if you need to keep
*  several items in the cargo slot).
*/
#define APP_MODE_ON( b )      ( b:cargo := TRUE  )
#define APP_MODE_OFF( b )     ( b:cargo := FALSE )
#define APP_MODE_ACTIVE( b )  ( b:cargo )

// Separator strings for the browse display
#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "



/***
*
*  Tbdemo <dbf> [<index>]
*
*/
PROCEDURE Tbdemo( dbf, index )

   LOCAL bSaveHandler
   LOCAL oError
   LOCAL cScreen
   LOCAL cSavClr
   
   // Lazy man's error checking
   bSaveHandler := errorblock( { |x| break(x) } )

   BEGIN SEQUENCE
      use (dbf) index (index)

   RECOVER USING oError
      if ( oError:genCode == EG_OPEN )
         ?? "Error opening file(s)"

      else
         // Assume it was a problem with the params
         ?? "Usage: Tbdemo <dbf> [<index>]"

      endif

      QUIT     // NOTE
   END

   // Restore the default error handler
   errorblock( bSaveHandler )

   // Save screen, set color, etc.
   set scoreboard off
   cScreen := savescreen()
   cSavClr := setcolor("N/BG")
   cls

   MyBrowse( 3, 6, maxrow() - 2, maxcol() - 6 )

   // Put things back
   setcolor  ( cSavClr )
   setpos    ( maxrow(), 0 )
   restscreen( ,,,, cScreen )

   QUIT

   RETURN



/***
*   
*  MyBrowse()
*
*  Create a Tbrowse object and browse with it.
*
*/
STATIC PROCEDURE MyBrowse(nTop, nLeft, nBottom, nRight)

   LOCAL oBrowse                          // The TBrowse object
   LOCAL cColorSave, nCursSave            // State preservers
   LOCAL nKey                             // Keystroke
   LOCAL lMore := TRUE                    // Loop control
   LOCAL lSavReadExit := READEXIT( .T. )  // Enable Up/Down as READ exit keys

   // Make a "stock" Tbrowse object for the current workarea
   oBrowse := StockBrowseNew( nTop, nLeft, nBottom, nRight )

   /*
   *  This demo uses the browse's "cargo" slot to hold a logical
   *  value of true (.T.) when the browse is in "append mode",
   *  otherwise false (.F.) (see #defines at top).
   */
   APP_MODE_OFF( oBrowse )

   // Use a custom 'skipper' to handle append mode (see below)
   oBrowse:skipBlock := { |x| Skipper( x, oBrowse ) }

   // Change the heading and column separators
   oBrowse:headSep := MY_HEADSEP
   oBrowse:colSep  := MY_COLSEP

   // Play with the colors and picture
   FormatColumns( oBrowse )

   // Insert a column at the left for "Rec #" and freeze it
   AddRecno( oBrowse )

   // Draw a window shadow
   dispbegin()

   cColorSave := setcolor( "N/N" )
   scroll( nTop + 1, nLeft + 2, nBottom + 1, nRight + 2 )

   setcolor( "W/W" )
   scroll( nTop, nLeft, nBottom, nRight )

   dispend()

   setcolor( cColorSave )

   // Save cursor shape, turn the cursor off while browsing
   nCursSave := setcursor( SC_NONE )

   // Main loop
   while lMore
      
      // Don't let the cursor move into frozen columns
      if ( oBrowse:colPos <= oBrowse:freeze )
         oBrowse:colPos := ( oBrowse:freeze + 1 )
      
      endif

      // Stabilize the display until it's stable or a key is pressed
      oBrowse:forceStable()

      if ( oBrowse:hitBottom .and. !APP_MODE_ACTIVE( oBrowse ) )
         // Banged against EOF; go into append mode
         APP_MODE_ON( oBrowse )
         nKey := K_DOWN

      else
         if ( oBrowse:hitTop .or. oBrowse:hitBottom )
            tone( 125, 0 )

         endif

         /*
         *  Make sure that the current record is showing
         *  up-to-date data in case we are on a network.
         */
         oBrowse:refreshCurrent():forceStable()

         // Everything's done -- just wait for a key
         nKey := inkey( 0 )

      endif

      if ( nKey == K_ESC )
         // Esc means leave
         lMore := .F.

      else
         // Apply the key to the oBrowse
         applyKey( oBrowse, nKey )

      endif
   enddo

   setcursor( nCursSave )
   READEXIT( lSavReadExit )

   RETURN



/***
*   
*  Skipper()
*
*  Handle record movement requests from the Tbrowse object.
*
*  This is a special "skipper" that handles append mode. It
*  takes two parameters instead of the usual one. The second
*  parameter is a reference to the Tbrowse object itself. The
*  Tbrowse's "cargo" variable contains information on whether
*  append mode is turned on.
*
*  NOTE: uses the cargo #defines shown at the top of Tbdemo.prg
*
*/
STATIC FUNCTION Skipper( nSkip, oBrowse )

   LOCAL lAppend := APP_MODE_ACTIVE( oBrowse )
   LOCAL i       := 0

   do case
   case ( nSkip == 0 .or. lastrec() == 0 )
      // Skip 0 (significant on a network)
      dbSkip( 0 )

   case ( nSkip > 0 .and. !eof() )
      while ( i < nSkip )           // Skip Foward

         dbskip( 1 )

         if eof()
            iif( lAppend, i++, dbskip( -1 ) )
            exit

         endif

         i++

      enddo

   case ( nSkip < 0 )
      while ( i > nSkip )           // Skip backward

         dbskip( -1 )

         if bof()
            exit

         endif

         i--

      enddo

   endcase

   RETURN i



/***
*
*   ApplyKey()
*
*   Apply one keystroke to the oBrowse.
*
*   NOTE: uses the cargo #defines shown at the top of Tbdemo.prg
*
*/
STATIC PROCEDURE ApplyKey( oBrowse, nKey )

   do case
   case nKey == K_DOWN
      oBrowse:down()

   case nKey == K_PGDN
      oBrowse:pageDown()

   case nKey == K_CTRL_PGDN
      oBrowse:goBottom()
      APP_MODE_OFF( oBrowse )

   case nKey == K_UP
      oBrowse:up()

      if APP_MODE_ACTIVE( oBrowse )
         APP_MODE_OFF( oBrowse )
         oBrowse:refreshAll()

      endif

   case nKey == K_PGUP
      oBrowse:pageUp()

      if APP_MODE_ACTIVE( oBrowse )
         APP_MODE_OFF( oBrowse )
         oBrowse:refreshAll()

      endif

   case nKey == K_CTRL_PGUP
      oBrowse:goTop()
      APP_MODE_OFF( oBrowse )

   case nKey == K_RIGHT
      oBrowse:right()

   case nKey == K_LEFT
      oBrowse:left()

   case nKey == K_HOME
      oBrowse:home()

   case nKey == K_END
      oBrowse:end()

   case nKey == K_CTRL_LEFT
      oBrowse:panLeft()

   case nKey == K_CTRL_RIGHT
      oBrowse:panRight()

   case nKey == K_CTRL_HOME
      oBrowse:panHome()

   case nKey == K_CTRL_END
      oBrowse:panEnd()

   case nKey == K_RETURN
      DoGet( oBrowse )

   otherwise
      KEYBOARD chr( nKey )
      DoGet( oBrowse )

   endcase

   RETURN



/***
*
*   DoGet()
*
*   Do a GET for the current column in the browse.
*
*   NOTE: uses the cargo #defines shown at the top of Tbdemo.prg
*
*/
PROCEDURE doGet( oBrowse )

   LOCAL lFlag := TRUE
   LOCAL oCol
   LOCAL GetList
   LOCAL nKey
   LOCAL nLen
   LOCAL lAppend
   LOCAL bSavIns
   LOCAL nSavRecNo := recno()
   LOCAL xNewKey
   LOCAL xSavKey

   // If we're at EOF we're adding the first record, so turn on append mode
   if EOF()
      lAppend := APP_MODE_ON( oBrowse )
   else
      lAppend := APP_MODE_ACTIVE( oBrowse )
   endif

   // Make sure screen is fully updated, dbf position is correct, etc.
   oBrowse:forceStable()

   if ( lAppend .and. ( recno() == lastrec() + 1 ) )
      dbAppend()

   endif

   // Save the current record's key value (or NIL)
   xSavKey := iif( empty( indexkey() ), NIL, &( indexkey() ) )

   // Get the current column object from the browse
   oCol := oBrowse:getColumn( oBrowse:colPos )

   // Get picture len to force scrolling if var is larger than window
   nLen := oBrowse:colWidth( oBrowse:colPos )

   // Create a corresponding GET
   GetList := { getnew( row(), col(),     ;
                        oCol:block,       ;
                        oCol:heading,     ;
                        oCol:picture,     ;
                        oBrowse:colorSpec ) }

   // Set insert key to toggle insert mode and cursor shape
   bSavIns := setkey( K_INS, { || InsToggle() } )

   // Set initial cursor shape
   setcursor( iif( ReadInsert(), SC_INSERT, SC_NORMAL ) )
   READ
   setcursor( SC_NONE )
   setkey( K_INS, bSavIns )

   // For this demo, we turn append mode off after each new record
   APP_MODE_OFF( oBrowse )

   // Get the record's key value (or NIL) after the GET
   xNewKey := if( empty( indexkey() ), NIL, &( indexkey() ) )

   oBrowse:inValidate()
   oBrowse:refreshAll():forceStable()

   // if the key has changed (or if this is a new record)
   if !( xNewKey == xSavKey ) .or. ( lAppend .and. xNewKey != NIL )

      // do a complete refresh
      oBrowse:refreshAll():forceStable()

      // Make sure we're still on the right record after stabilizing
      while &( indexkey() ) > xNewKey .and. !oBrowse:hitTop()
         oBrowse:up():forceStable()

      enddo

   endif

   // Check exit key from get
   nKey := lastkey()
   if nKey == K_UP   .or. nKey == K_DOWN .or. ;
      nKey == K_PGUP .or. nKey == K_PGDN

      // Ugh
      keyboard( chr( nKey ) )

   endif

   RETURN



/***
*
*   InsToggle()
*
*   Toggle the global insert mode and the cursor shape.
*
*/
STATIC PROCEDURE InsToggle()

   if readinsert()
      readinsert( FALSE )
      setcursor( SC_NORMAL )

   else
      readinsert( TRUE )
      setcursor( SC_INSERT )

   endif

   RETURN



/***
*
*   StockBrowseNew()
*
*   Create a "stock" Tbrowse object for the current workarea.
*
*/
STATIC FUNCTION StockBrowseNew( nTop, nLeft, nBottom, nRight )

   LOCAL oBrowse
   LOCAL n
   LOCAL oColumn
   LOCAL cType

   // Start with a new browse object from TBrowseDB()
   oBrowse := TBrowseDB( nTop, nLeft, nBottom, nRight )

   // Add a column for each field in the current workarea
   for n := 1 to fcount()

      // Make a new column
      oColumn := TBColumnNew( field( n ),                         ;
                              FieldWBlock( field( n ), select() ) )

      // Add the column to the browse
      oBrowse:addColumn( oColumn )

   next

   RETURN oBrowse



/***
*
*   FormatColumn()
*
*   Set up some colors and pictures for the column.
*
*/
STATIC PROCEDURE FormatColumn( oBrowse )

   LOCAL n
   LOCAL oColumn
   LOCAL xValue

   // Set up a list of colors for the browse to use
   oBrowse:colorSpec := "N/W,N/BG,B/W,B/BG,B/W,B/BG,R/W,B/R"

   // Loop through the columns, choose some colors for each
   for n := 1 to oBrowse:colCount
      
      // Get (a reference to) the column
      oColumn := oBrowse:getColumn( n )

      // Get a sample of the underlying data by evaluating the codeblock
      xValue := eval( oColumn:block )

      do case
      case ISNUM( xValue )
          // For numbers, use a color block to highlight negative values
          oColumn:picture    := "999,999"
          oColumn:colorBlock := { |x| iif( x < 0, { 7, 8 }, { 5, 6 } ) }

          // Set default colors also (controls the heading color)
          oColumn:defColor := {7, 8}

      case ISCHAR( xValue )
         // For non-numeric, just use colors 3 and 4 ("B/W" and "B/BG")
         oColumn:picture  := repl( "!", len( xValue ) )
         oColumn:defColor := { 3, 4 }

      otherwise
         // For non-numeric, just use colors 3 and 4 ("B/W" and "B/BG")
         oColumn:defColor := { 3, 4 }

      endcase

   next

   RETURN



/***
*
*   AddRecno()
*
*   Insert a frozen column at the left that shows current record number
*
*/
STATIC PROCEDURE AddRecno( oBrowse )

   LOCAL oColumn

   // Create the column object
   oColumn := TBColumnNew( "  Rec #", { || recno() } )

   // Insert it as the leftmost column
   oBrowse:insColumn( 1, oColumn )

   // Freeze it at the left
   oBrowse:freeze := 1

   RETURN

