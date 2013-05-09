/*****
 *
 * TBR31.PRG
 * A semaphored TBrowse
 *
 *
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "fileio.ch"
#include "tbr31.ch"

FUNCTION Main()
   LOCAL oBrowse, oColumn, nKey
   LOCAL nHandle
   LOCAL nCursor, bOldError, cScreen

   cScreen := savescreen()
   SCROLL()
   SET(_SET_SCOREBOARD, .F.)
   SET(_SET_CONFIRM, .T.)
   READEXIT(.T.)

   // Post error block
   bOldError := ERRORBLOCK( {|e| OpenDBF(e, bOldError)} )

   DBUSEAREA( NEW, "dbfNtx", "tbr31", , SHARED )

   // Back to default error block
   ERRORBLOCK( bOldError )

   if !File( "tbr31_2.ntx" ) .or. !File( "tbr31_1.ntx" )
      dbcreateindex("tbr31_1.ntx", "tbr31->fld3", {|| tbr31->fld3 } )
      dbcreateindex("tbr31_2.ntx", "dtos(tbr31->fld7)", {|| dtos(tbr31->fld7) } )
      use
      DBUSEAREA( NEW, "dbfNtx", "tbr31", , SHARED )

   endif

   DBSETINDEX( "tbr31_1" )
   DBSETINDEX( "tbr31_2" )

   // Open semaphore file
   IF ((nHandle := OpenSemaphore( "Semaph.Tbr" ,, ;
                    FO_READWRITE + FO_SHARED )) < 0)
      SCROLL()
      QOUT( MSG_SEM_NOT_FOUND )
      QUIT

   ENDIF

   DISPBEGIN()
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @ TOP,LEFT TO BOTTOM,RIGHT COLOR MYCOLORS
   @ MAXROW(), 0 SAY PADC(SCREEN_FOOTER,;
     MAXCOL() + 1) COLOR "W+/RB"
   DISPEND()

   oBrowse := TBROWSEDB(TOP + 1, LEFT + 1, BOTTOM - 1, RIGHT - 1)
   oBrowse:colorSpec := MYCOLORS
   oBrowse:colSep    := COLSEP
   oBrowse:headSep   := HEADSEP

   // The best way to attach things to cargo is
   // using a Data Dictionary (see DICT.PRG which
   // is supplied as one of the samples in the
   // CA-Clipper 5.2 package)
   //
   // Doing so, will prevent against someone
   // destroying your cargo by accident
   //
   // I know it "NEVER" happens (specially when we
   // have multiprogrammer environments...)
   //
   // Just for this example...
   //
   oBrowse:cargo := {0, 0, 0}

   // Columns
   oColumn := TBCOLUMNNEW( "Field 3", FIELDBLOCK("fld3") )
   oBrowse:addColumn( oColumn )
   oColumn := TBCOLUMNNEW( "Field 7", FIELDBLOCK("fld7") )
   oBrowse:addColumn( oColumn )
   oColumn := TBCOLUMNNEW( "Field 4", FIELDBLOCK("fld4") )
   oBrowse:addColumn( oColumn )
   oColumn := TBCOLUMNNEW( "Record#", {|| RECNO()} )
   oBrowse:addColumn( oColumn )

   WHILE .T.
      // Do not allow cursor to enter
      // the last column (RECNO())
      IF oBrowse:colPos == oBrowse:colCount
         oBrowse:colPos := oBrowse:colCount - 1

      ENDIF

      ForceStable( oBrowse )
      oBrowse:cargo[REC_NO] := RECNO()

      IF ( oBrowse:hitTop .OR. oBrowse:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF

      // Do something while waiting for a key...
      WHILE ((nKey := INKEY(WAIT_TIME)) == 0)
         CheckSemaphore( nHandle, oBrowse )

      END

      IF !TBMoveCursor( oBrowse, nKey )
         IF ( nKey == K_ESC )
            EXIT

         ELSEIF ( nKey == K_ENTER )
            IF RecLock(LOCK_RETRY)
               //
               // Time out was implemented
               // since the record is going to
               // be locked during editing
               //
               IF DoGet( oBrowse, GETCOLORS, {|oGet| EditIt(oGet)} )
                  UpdateSemaphore( nHandle, oBrowse )

               ENDIF
               DBCOMMIT()
               DBUNLOCK()

            ENDIF

         ENDIF

      ENDIF

   END
   SCROLL()
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Semaphore checking
 *
 * CheckSemaphore(<nHandle>, <oBrowse>) --> NIL
 *
 */

STATIC FUNCTION CheckSemaphore( nHandle, oBrowse )
   oBrowse:cargo[FILE_CNT] := VAL(FREADSTR(nHandle,;
                                MAX_CNT_DIGITS))
   GoBOF(nHandle)
   IF (oBrowse:cargo[FILE_CNT] != oBrowse:cargo[PRG_CNT])
      DBSKIP(0)
      oBrowse:refreshAll()
      ForceStable(oBrowse)
      //
      // You know that TBrowse behaviour...
      //
      DBSKIP(0)
      WHILE (oBrowse:cargo[REC_NO] != RECNO())
         oBrowse:up()
         ForceStable(oBrowse)

      END
      oBrowse:cargo[PRG_CNT] := oBrowse:cargo[FILE_CNT]

   ENDIF
   RETURN (NIL)

/*****
 *
 * Updates semaphore
 *
 * UpdateSemaphore(<nHandle>, <oBrowse>) --> NIL
 *
 */

STATIC FUNCTION UpdateSemaphore( nHandle, oBrowse )
   oBrowse:cargo[PRG_CNT] := ;
            IF(oBrowse:cargo[PRG_CNT] != MAX_CNT,;
               oBrowse:cargo[PRG_CNT] + 1, 0)
   FWRITE(nHandle, STR(oBrowse:cargo[PRG_CNT],;
                       MAX_CNT_DIGITS))
   GoBOF(nHandle)
   RETURN (NIL)

// EOF - TBR31.PRG //
