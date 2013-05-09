/*****
 *
 * MANAGER.PRG
 * Main module
 *
 *
 * RMAKE manager
 *
 */

#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "manager.ch"

/*****
 *
 * To be honest, there are several things that
 * you can improve using CA-Clipper/C or CA-Clipper/Assembly.
 *
 * Things like change directory, current drive, etc.
 *
 * Also, this will make your program a bit faster since
 * you are not calling externals via RUN command.
 *
 * But for the sake of having a plain Clipper code, I am
 * using the RUN command.
 *
 * Since you are going to use RUN, and to avoid any problem,
 * please check your SET COMSPEC.
 *
 */

FUNCTION Manager()
   MEMVAR cWork
   LOCAL b, cVal
   LOCAL nTop, nLeft, nBottom, nRight
   LOCAL cColour, nCursor, lScore, cScr
   LOCAL nKey, column
   LOCAL nSubscript, aDir, nLen, k
   LOCAL lReconfigure, nMaxRow
   PRIVATE cWork   // for macros

   // Before anything else, be sure COMSPEC was set
   IF EMPTY(GETENV("COMSPEC"))
      ALERT( "CRITICAL ERROR: COMSPEC environmental "+;
             "variable not set",;
            { "Quit" } )
      QUIT

   ENDIF

   // Init
   lReconfigure := .F.
   nMaxRow      := MAXROW()

   // Be sure drive is ready
   // Just in case of someone using this from a
   // floppy drive (Gosh!)
   //
   IF !FILE("\NUL")
      // This will prevent against open doors
      // on diskette drives or even unformatted
      // disks
      ALERT("Drive not ready!", {"Quit"})
      RETURN (NIL)

   ENDIF

   // Save and Set
   SETBLINK(.F.)
   lScore  := SET(_SET_SCOREBOARD, .F.)
   nCursor := SETCURSOR(SC_NONE)
   cColour := SETCOLOR("BG+/B")
   cScr    := SAVESCREEN( 0, 0, nMaxRow, 79)

   // Main coordinates
   nTop    :=  2
   nLeft   := 41
   nBottom := nMaxRow - 5
   nRight  := 78

   // Screen
   PaintScr( nTop, nLeft, nRight )

   nSubscript := 1
   k          := 0
   nLen       := 1

   // Load Array with directory information
   aDir := MyDirec(@nLen)

   // Create Browse Object
   b := TBrowseNew( nTop, nLeft, nBottom, nRight )
   b:colSep    := CHR(179)
   b:colorSpec := "BG+/B,W+/BG,N,N,GR+/W"
   // Skippers
   b:skipBlock := {|x| ;
                  k := IF(ABS(x) >= IF(x >= 0,;
                  nLen - nSubscript, nSubscript - 1),;
                  IF(x >= 0, nLen - nSubscript,1 ;
                  - nSubscript),;
                  x), nSubscript += k,;
                  k }
   b:goTopBlock    := {|| nSubscript := 1}
   b:goBottomBlock := {|| nSubscript := nLen}

   // TBColumn objects
   column := TBColumnNew(,{|| aDir[nSubscript,1]})
   column:width := 12
   b:addColumn(column)
   column := TBColumnNew(,{|| aDir[nSubscript,2]})
   column:width :=  9
   b:addColumn(column)
   column := TBColumnNew(,{|| aDir[nSubscript,3]})
   column:width :=  8
   b:addColumn(column)
   column := TBColumnNew(,{|| aDir[nSubscript,4]})
   column:width :=  8
   b:addColumn(column)

   b:freeze := 3
   WHILE .T.
      // Paint current line in unselected colour
      b:colorRect({b:rowPos, 1,;
                   b:rowPos, b:colCount}, {1, 1})

      STABILIZE b

      IF b:stable()
         // Paint the entire line
         b:colorRect({b:rowPos, 1,;
                    b:rowPos, b:colCount}, {2, 2})
         // Status line
         DISPBEGIN()
         @ nMaxRow - 3,nLeft      SAY ;
                       EVAL((b:getColumn(1)):block)
         @ nMaxRow - 3,nLeft + 13 SAY ;
                       EVAL((b:getColumn(2)):block)
         @ nMaxRow - 3,nLeft + 23 SAY ;
                       EVAL((b:getColumn(3)):block)
         @ nMaxRow - 3,nLeft + 32 SAY ;
                       EVAL((b:getColumn(4)):block)
         DISPEND()

         nKey := WhatKey( , {|| DEVPOS( nTop - 2, ;
                                nRight - 7 ),;
                                DEVOUT( TIME(), "N/BG" ) } )

         IF !TBMoveCursor(nKey, b)
            // Keystroke was not handled by
            // TBMoveCursor(). So, lets try here!
            //
            IF nKey == K_ESC .OR. nKey == K_F10 .OR.;
               nKey == K_ALT_F4 .OR. nKey == K_ALT_X
               IF OkBox( 5, 25,;
                       { " The CA-Clipper File Manager ",;
                          "Do you REALLY want to quit the",;
                          "CA-Clipper File Manager?",;
                          " Yes ",;
                          " No " } ) == GO_AHEAD
                  SETCURSOR(nCursor)
                  SETCOLOR(cColour)
                  RESTSCREEN( 0, 0, nMaxRow, 79, cScr)
                  EXIT

               ENDIF

            ELSEIF nKey == K_ENTER
               // Get the column and evaluate
               // its data retrieval block
               cWork := EVAL( (b:getColumn(2)):block )
               IF (cWork == "UP--DIR")
                  RUN CD..>NUL
                  lReconfigure := .T.

               ELSEIF (cWork == "SUB-DIR")
                  cWork := UnPad( b )
                  RUN CD &cWork>NUL
                  lReconfigure := .T.

               ENDIF

            ELSEIF nKey == K_F1
               // Information about MANAGER
               // (aka useless part of the program)
               Info( nTop, nRight )

            ELSEIF nKey == K_F3 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(2)):block))
               // Regular file
               // Lets decide what kind of view
               // we are going to use
               cVal := UnPad( b )
               IF (".dbf" $ cVal)
                  // Launch .DBF viewer
                  // (Of course, it is another TBrowse)
                  BrowseDBF(SUBSTR(cVal, 1, AT(".dbf",;
                                   cVal) - 1))

               ELSE
                  // Use MEMOEDIT() as a text viewer
                  // I am not concerned if the file
                  // is bigger than 64 Kb or even if the file
                  // is not a text one
                  ShowIt(cVal, .F.)

               ENDIF

            ELSEIF nKey == K_F4 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(2)):block))
               // Edit file
               // I am not concerned if the file
               // is not a text one or even if it is
               // bigger than 64 Kb
               ShowIt( UnPad( b ), .T.)

            ELSEIF nKey == K_F5 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(2)):block))
               // Copy file
               // "Unpad" the filename and pass it to the
               // the function in charge of copy
               lReconfigure := CopyOK( UnPad( b ) )

            ELSEIF nKey == K_F6 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(2)):block))
               // Rename file
               // "Unpad" the filename and pass it to the
               // the function in charge of copy
               cVal := UnPad( b )
               //
               // DO NOT allow move or rename of
               // this file or you will get a runtime
               // error, since the dynamic overlay manager
               // lost the place where it was supposed
               // to locate its dynamic overlays
               //
               IF !("manager.exe" $ cVal)
                  lReconfigure := RenameOK( UnPad( b ) )

               ENDIF

            ELSEIF nKey == K_F8 .AND.;
               !(CHR(017) $ EVAL((b:getColumn(2)):block))
               // Delete file, if you are able to do because
               // it can be marked as read-only
               //
               // DO NOT DELETE manager.exe!
               //
               // "Unpad" the filename and pass it
               // to the function in charge of deletion
               lReconfigure := DeleteOK( UnPad( b ) )

            ENDIF

         ENDIF
         IF lReconfigure
            lReconfigure := .F.
            aDir := MyDirec(@nLen)
            b:goTop()
            b:configure()
            b:refreshAll()

         ENDIF

      ENDIF

   END
   RETURN (NIL)

/*****
 *
 * Pads array elements
 *
 */

STATIC FUNCTION PadIt(aArray, nArrlen)
   LOCAL nPos, i, nALen, nNewALen
   LOCAL cTemp

   // Transverse array and its subarrays
   i := 1
   WHILE i <= LEN(aArray)
      IF ("D" $ aArray[i].fileattrib)
         IF (aArray[i].filename == ".")
            // Exclude current directory from list
            ADEL(aArray, i)
            // Shrink it!
            aArray := ASIZE(aArray, LEN(aArray) - 1)
            LOOP

         ELSEIF (aArray[i].filename == "..")
            aArray[i].filename := PADR(aArray[i].filename, 12)
            aArray[i].filesize := CHR(16) + "UP--DIR" +;
                                  CHR(17)

         ELSE
            aArray[i].filesize := CHR(16) + "SUB-DIR" +;
                                  CHR(17)
            nPos := AT(".",aArray[i].filename)
            IF nPos != 0
               aArray[i].filename := ;
                       PADR(SUBSTR(aArray[i].filename,;
                             1, nPos - 1), 9) +;
                       PADR(SUBSTR(aArray[i].filename,;
                             nPos + 1, 3), 3)
            ELSE
               aArray[i].filename := PADR(aArray[i].filename, 12)

            ENDIF

         ENDIF

      ELSE
         // Pad name
         nPos := AT(".",aArray[i].filename)
         IF nPos != 0
            aArray[i].filename := ;
                    PADR(SUBSTR(aArray[i].filename,;
                          1, nPos - 1), 9) +;
                    PADR(SUBSTR(aArray[i].filename,;
                          nPos + 1, 3), 3)
         ELSE
            aArray[i].filename := PADR(aArray[i].filename, 12)

         ENDIF
         aArray[i].filename := LOWER(aArray[i].filename)
         // Pad size
         aArray[i].filesize := STR(aArray[i].filesize, 9)

      ENDIF
      // Pad time
      aArray[i].filetime := SUBSTR(aArray[i].filetime, 1, 5)
      // Add a for AM or p for PM
      cTemp := VAL(SUBSTR(aArray[i].filetime, 1, 2))
      aArray[i].filetime += IF(cTemp >= 12 .AND. cTemp <= 23,;
                             "p", "a")
      cTemp := IF(cTemp > 12, cTemp % 12, cTemp)
      cTemp := STR(cTemp, 2, 0)
      aArray[i].filetime := cTemp +;
                          SUBSTR(aArray[i].filetime, 3, 4)

      // Keep counter updated
      i++

   END
   nArrLen := LEN(aArray)
   RETURN (NIL)

/*****
 *
 * Loads array with directory
 * information and sorts it putting
 * directories at top of list
 *
 */

STATIC FUNCTION MyDirec(nLen)
   LOCAL nStartAt := 1
   LOCAL aDir

   // Current Directory
   aDir := DIRECTORY("*.*", "HSD")
   nLen := LEN(aDir)

   // First, put all sub-directories
   // at the beginning of the list
   ASORT(aDir,,, {|x,y| x.fileattrib == "D"})

   // Now, lets find out where the other
   // files are
   AEVAL(aDir, {|x,i| nStartAt := ;
               IF("D" $ x.fileattrib, i, nStartAt)})

   // Sort sub-directories only
   ASORT(aDir,1, nStartAt, {|x,y| x.filename < y.filename})
   nStartAt++

   // Sort only the non-directory files.
   // Sort Array based on the first subarray
   // element
   ASORT(aDir, nStartAt,, {|x,y| x.filename < y.filename})

   // Pad some subarray elements
   PadIt(aDir, @nLen)
   // Return the array with directory information
   RETURN (aDir)

/*****
 *
 * Screen (section not handled by TBrowse)
 *
 */

STATIC FUNCTION PaintScr( nTop, nLeft, nRight )
   LOCAL nMaxRow := MAXROW()

   DISPBEGIN()
   SCROLL( nTop - 2, nLeft - 1, nMaxRow - 2, nRight + 1)
   @ nTop - 2,nLeft - 1 TO nMaxRow - 2,nRight + 1 DOUBLE
   @ nTop - 1,nLeft +  4 SAY "Name"   COLOR "GR+/B"
   @ nTop - 2,nLeft + 12 SAY CHR(209)
   @ nTop - 1,nLeft + 12 SAY CHR(179)
   @ nTop - 1,nLeft + 16 SAY "Size"   COLOR "GR+/B"
   @ nTop - 2,nLeft + 22 SAY CHR(209)
   @ nTop - 1,nLeft + 22 SAY CHR(179)
   @ nTop - 1,nLeft + 25 SAY "Date"   COLOR "GR+/B"
   @ nTop - 2,nLeft + 31 SAY CHR(209)
   @ nTop - 1,nLeft + 31 SAY CHR(179)
   @ nTop - 1,nLeft + 33 SAY "Time"   COLOR "GR+/B"
   @ nMaxRow - 4,nLeft TO nMaxRow - 4,nRight DOUBLE
   @ nMaxRow - 4,nLeft - 1  SAY CHR(204)
   @ nMaxRow - 4,nRight + 1 SAY CHR(185)
   @ nMaxRow - 4,nLeft + 12 SAY CHR(207)
   @ nMaxRow - 4,nLeft + 22 SAY CHR(207)
   @ nMaxRow - 4,nLeft + 31 SAY CHR(207)
   BottLine()
   @ nMaxRow, 1 SAY "Info"    COLOR "N/BG"
   @ nMaxRow,17 SAY "View"    COLOR "N/BG"
   @ nMaxRow,25 SAY "Edit"    COLOR "N/BG"
   @ nMaxRow,33 SAY "Copy"    COLOR "N/BG"
   @ nMaxRow,41 SAY "RenMove" COLOR "N/BG"
   @ nMaxRow,57 SAY "Delete"  COLOR "N/BG"
   @ nMaxRow,74 SAY "Exit"    COLOR "N/BG"
   DISPEND()
   RETURN (NIL)

// EOF - MANAGER.PRG //
