/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it320005.prg - Department Directory
      Merchandize Tracking System (MTS)

   acr / 04.18.93
   eso / 09.25.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "D-DIR"
#define RPT_NAME "DEPARTMENT DIRECTORY"
#define THIS_WIDTH 56
static nCtr := 0

FUNCTION it320005

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   local nPage := 0
   local nGoPrint := 2

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      Set Index to DP_001
   endif
      
   dbGoTop()

#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off

   it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nPage++
   nCtr += 1

   ? MARGIN  + "Report Date: " + dtoc(date())
   ? MARGIN + REPL("-",THIS_WIDTH)
  
   ? MARGIN + " # "
  ?? space(2) + padr( "Descriptor", 25 )
  ?? space(2) + padr( "Grp",         3 )
  ?? space(2) + padc( "Limit",      13 )

   ? MARGIN + repl( "-", 3 )
  ?? space(2) + repl( "-", 25 )
  ?? space(2) + repl( "-",  3 )
  ?? space(2) + repl( "-", 13 )

   ? MARGIN
   nCtr += 4   

   while .T.

      if it390002 ( RPT_ID, PAGE_LEN, TOP_MARGIN, BOT_MARGIN, LEFT_MARGIN, RIGHT_MARGIN, nPage, THIS_WIDTH, nCtr )
         it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
         nCtr := 0
         nPage++

          ? MARGIN  + "Report Date: " + dtoc(date())
          ? MARGIN + REPL("-",THIS_WIDTH)
          
          ? MARGIN + " # "
         ?? space(2) + padr( "Descriptor", 25 )
         ?? space(2) + padr( "Grp",         3 )
         ?? space(2) + padc( "Limit",      13 )

          ? MARGIN + repl( "-", 3 )
         ?? space(2) + repl( "-", 25 )
         ?? space(2) + repl( "-",  3 )
         ?? space(2) + repl( "-", 13 )

          ? MARGIN
          nCtr += 4
      endif

      // Nothing to print.
      if DP->(Eof())
         exit
      endif

      // Indicate record being processed.
      @ 2, 1 wsay " Department: " + DP->DP_001 + " " + DP->DP_002

       ? MARGIN + DP->DP_001 
      ?? space(3) + DP->DP_002
      ?? space(2) + tran(DP->DP_003, "99" )
      ?? space(2) + tran(DP->DP_004, "99,999,999.99" )
      nCtr += 1
      skip
   enddo

   dbCloseAll()

    ?
    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to

   // Remove window.
   Killwindow()
   tone ( 2100, 3 )

   // Restore cursor shape.
   setcursor ( nOldCursor )

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 0, 214 )

RETURN NIL
