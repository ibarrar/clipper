/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it320004.prg - Class Directory
      Merchandize Tracking System (MTS)

   acr / 04.18.93
   eso / 09.25.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "C-DIR"
#define RPT_NAME "CLASS DIRECTORY"
#define THIS_WIDTH 76 + LEFT_MARGIN
static nCtr := 0

FUNCTION it320004()

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   local nPage := 0
   local nGoPrint := 2

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      Set Index to CL_001
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
    ? MARGIN  + repl( "-", 75 )
    ? MARGIN  + "Class  "
   ?? space(1) + padr ( "Descriptor", 30 )
   ?? space(2) + padr ( "Dpt",         3 )
   ?? space(2) + padl ( "OTB Budget", 13 )
   ?? space(2) + padl ( "OTB Avail",  13 )

    ? MARGIN   + repl( "-", 6 )
   ?? space(2) + repl( "-", 30 )
   ?? space(2) + repl( "-",  3 )
   ?? space(2) + repl( "-", 13 )
   ?? space(2) + repl( "-", 13 )

    nCtr += 4

   do while .T.
      if it390002 ( RPT_ID, PAGE_LEN, TOP_MARGIN, BOT_MARGIN, LEFT_MARGIN, RIGHT_MARGIN, nPage, THIS_WIDTH, nCtr )
         it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
         nCtr := 0
         nPage++
          ? MARGIN  + "Report Date: " + dtoc(date())
          ? MARGIN   + repl( "-", 75)      
          ? MARGIN + "Class  "
         ?? space(1) + padr ( "Descriptor", 30 )
         ?? space(2) + padr ( "Dpt",         3 )
         ?? space(2) + padl ( "OTB Budget", 13 )
         ?? space(2) + padl ( "OTB Avail",  13 )

          ? MARGIN   + repl( "-", 6 )
         ?? space(2) + repl( "-", 30 )
         ?? space(2) + repl( "-",  3 )
         ?? space(2) + repl( "-", 13 )
         ?? space(2) + repl( "-", 13 )

         nCtr += 4
      endif

      // Nothing to print.
      if cl->(eof())
         exit
      endif

      // Indicate record being processed.
      @ 2, 1 wsay " Class: " + CL->CL_001 + " " + CL->CL_002

       ? MARGIN   + CL->CL_001 
      ?? space(4) + CL->CL_002
      ?? space(2) + CL->CL_003
      ?? space(2) + tran( CL->CL_004, "99,999,999.99" )
      ?? space(2) + tran( CL->CL_004, "99,999,999.99" )
      nCtr += 1
      skip
   enddo

   dbCloseAll()

    ? MARGIN
    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to

   // Remove window.
   killwindow()
   tone ( 2100, 3 )

   // Restore cursor shape.
   setcursor ( nOldCursor )

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 0, 214 )

RETURN NIL
