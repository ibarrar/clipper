/*****
 *
 * TBR30.PRG
 *
 * Clipper tbr30 /N /W
 * RTLINK FILE tbr30
 *
 */

#include "inkey.ch"
#include "fileio.ch"
#include "setcurs.ch"

#include "samples.ch"
#include "tbrowse.ch"

#xtranslate       BOFile()      =>       (n == nFirstRec)
#xtranslate       EOFile()      =>       (n == nLastRec)

// Global stuff
STATIC cBuffer1
STATIC cBuffer2
STATIC n
STATIC nLastRec
STATIC nFirstRec

/*****
 *
 * Main Function
 *
 * WARNING: This program does not handle line overflow
 *          for the second text column
 *
 */

FUNCTION BroText( cFile )
   LOCAL nHandle, b, nKey, nMaxRow, nMaxCol
   LOCAL column, cClr, cSreen

   // Open file
   nHandle := FOPEN( cFile, FO_READ )
   IF ( nHandle < 0 )
      SCROLL()
      ?
      ? "Usage: Tbr30 <filename.ext>"
      ?
      QUIT

   ENDIF

   // Screen (not handled by TBrowse)
   cSreen := savescreen()
   SETCURSOR(SC_NONE)
   SETBLINK(.F.)       // This way you have more colors
   cClr := SETCOLOR("N/B")
   SCROLL()
   nMaxRow := MAXROW()
   nMaxCol := MAXCOLUMN
   SCROLL()
   // "Shadow"
   SETCOLOR("N/N")
   SCROLL( 3, 4, nMaxRow - 2, nMaxCol - 2)
   SETCOLOR("W+/B*,W+/R*")
   @ 0, 0 SAY PADC(;
   "Clipper 5.2 - Browsing a DBF File " +;
   "with TBrowse",;
   nMaxCol + 1) COLOR "N/W"
   @ nMaxRow, 0 SAY PADC(;
   "Browsing: " + cFile, nMaxCol + 1) COLOR "W+/BG"

   // Positioning
   nLastRec  := FindBottom(nHandle)
   nFirstRec := n := FindTop(nHandle)

   // Create objects
   // TBrowse
   b := TBrowseDB( 2, 2, nMaxRow - 3, nMaxCol - 4)
   b:colorSpec := "W+/B*,W+/R*,N/BG*"
   // TBrowse Skippers
   b:skipBlock     := {|x| SkipRec(x, nHandle)}
   b:goTopBlock    := {||  n := FindTop(nHandle)}
   b:goBottomBlock := {||  n := FindBottom(nHandle)}

   // Initialize buffers
   cBuffer1 := cBuffer2 := SPACE(RECSIZE)

   // TBColumn
   column  := TBColumnNew( , {|| cBuffer1} )
   column:width := RECSIZE
   column:colorBlock := {|| IF(!EMPTY(cBuffer2), {1,3}, {1,2})}
   b:addColumn( column )

   column  := TBColumnNew( , {|| cBuffer2} )
   column:width := RECSIZE
   column:colorBlock := {|| IF(!EMPTY(cBuffer2), {1,3}, {1,2})}
   b:addColumn( column )

   WHILE .T.
      DISPBEGIN()
      WHILE (!b:stabilize())
      END
      DISPEND()

      nKey := INKEY(0)
      IF !MoveIt( nKey, b )
         IF nKey == K_ESC
            EXIT

         ENDIF

      ENDIF

   END

   SETCOLOR(cClr)
   SCROLL()
   SETPOS( 0, 0 )
   restscreen(,,,,cSreen)
   RETURN (NIL)

/*****
 *
 * Main Skipper
 *
 */

FUNCTION SkipRec( nRequest, nHandle )
   LOCAL nActually := 0

   IF (nRequest == 0)
      ReadLine(nHandle, 0)

   ELSEIF (nRequest > 0)
      WHILE (nActually < nRequest) .AND. ;
            (!EOFile())
         ReadLine(nHandle, 1)
         nActually++

      END

   ELSEIF (nRequest < 0)
      WHILE (nActually > nRequest) .AND. ;
         (!BOFile())
         ReadLine(nHandle, -1)
         nActually--

      END

   ENDIF

   RETURN (nActually)

/*****
 *
 * Top of File
 *
 */

FUNCTION FindTop(nHandle)
   LOCAL cBuff
   LOCAL nAt := 0

   FSEEK(nHandle, 0, FS_SET)
   WHILE (nAt == 0)
      cBuff := SPACE(RECSIZE)
      FREAD(nHandle, @cBuff, RECSIZE)
      nAt := AT(CR, cBuff)

   END

   FSEEK(nHandle, -RECSIZE, FS_RELATIVE)

   RETURN (FSEEK(nHandle, nAt + 1, FS_RELATIVE))

/*****
 *
 * Bottom of File
 *
 */

FUNCTION FindBottom(nHandle)
   // Assume last byte is an LF
   RETURN (FSEEK(nHandle, 0, FS_END))

/*****
 *
 * Reads a line of text
 *
 */

FUNCTION ReadLine( nHandle, nRec )
   LOCAL cBuff
   LOCAL nAt

   cBuffer1 := cBuffer2 := cBuff := SPACE(RECSIZE)

   IF (nRec == 0)
      BackCRLF(nHandle, 1)

   ELSEIF (nRec < 0)
      BackCRLF(nHandle, 2)

   ENDIF

   FREAD(nHandle, @cBuff, RECSIZE)
   nAt := AT(CR, cBuff)
   IF (nAt == 0)
      // Line overflow
      cBuffer1 := cBuff
      cBuff := SPACE(RECSIZE)
      n := FSEEK(nHandle, 0, FS_RELATIVE)
      FREAD(nHandle, @cBuff, RECSIZE)
      //
      // WARNING:
      // Assuming CRLF is now in the buffer
      //
      nAt := AT(CR, cBuff)
      //
      // CR not in the buffer
      // ERROR!
      //
      // Program will go crazy!

   ENDIF

   FSEEK(nHandle, n, FS_SET)

   cBuff := SPACE(RECSIZE)
   FREAD(nHandle, @cBuff, nAt + 1)
   n := FSEEK(nHandle, 0, FS_RELATIVE)
   cBuff := TRIM(cBuff)
   cBuff := LEFT(cBuff, LEN(cBuff) - 2)

   IF (EMPTY(cBuffer1))
      cBuffer1 := cBuff

   ELSE
      cBuffer2 := cBuff

   ENDIF

   RETURN (NIL)

/*****
 *
 * Pointer at proper place
 *
 */

FUNCTION BackCRLF(nHandle, nTimes)
   LOCAL cBuff, nAt, nSize

   WHILE (nTimes > 0)
      IF (n == nFirstRec)
         n := FSEEK(nHandle, 0, FS_SET)
         EXIT

      ENDIF
      nSize := MIN(n, RECSIZE)
      cBuff := SPACE(nSize)
      FSEEK(nHandle, -nSize, FS_RELATIVE)
      FREAD(nHandle, @cBuff, nSize - 2)
      nAt := RAT(CR, cBuff)
      IF (nAt == 0)
         n := FSEEK(nHandle, -1, FS_RELATIVE)
         LOOP

      ELSE
         n := FSEEK(nHandle, (n - nSize) + (nAt + 1),;
                    FS_SET)

      ENDIF
      nTimes--

   END
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

FUNCTION MoveIt( nKey, oObj )
   LOCAL nFound
   STATIC aKeys := ;
       { K_DOWN      , {|b| b:down()},;
         K_UP        , {|b| b:up()},;
         K_PGDN      , {|b| b:pageDown()},;
         K_PGUP      , {|b| b:pageUp()},;
         K_CTRL_PGUP , {|b| b:goTop()},;
         K_CTRL_PGDN , {|b| b:goBottom()},;
         K_RIGHT     , {|b| b:right()},;
         K_LEFT      , {|b| b:left()},;
         K_HOME      , {|b| b:home()},;
         K_END       , {|b| b:end()},;
         K_CTRL_LEFT , {|b| b:panLeft()},;
         K_CTRL_RIGHT, {|b| b:panRight()},;
         K_CTRL_HOME , {|b| b:panHome()},;
         K_CTRL_END  , {|b| b:panEnd()} }

   // Search into array
   nFound := ASCAN( aKeys, nKey )
   IF nFound != 0
      EVAL( aKeys[++nFound], oObj )

   ENDIF
   RETURN (nFound != 0)

// EOF - TBR30.PRG //
