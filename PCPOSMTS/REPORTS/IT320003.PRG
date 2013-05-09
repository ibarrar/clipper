/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it320003.prg - Unit Directory
      Merchandize Tracking System (MTS)

   acr / 04.18.93
   eso / 09.25.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "U-DIR"
#define RPT_NAME "UNIT DIRECTORY"
#define THIS_WIDTH 93 +LEFT_MARGIN
static nCtr := 0

FUNCTION it320003

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   local nVariance := 0, nRatio := 0, nPage := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 55, CONFIRM_COLOR )
   @ 1, 1 wsay " Printing " + RPT_NAME + ".  Please wait . . ."

   if NetUse("U",DB_SHARED,NUM_SECONDS)
      Set Index to U_001
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
         
    ? MARGIN

    ? MARGIN + " # "
   ?? space(2) + padr ( "Unit Name",    20 )
   ?? space(2) + padr ( "Address",      20 )
   ?? space(2) + padl ( "Target Sales", 13 )
   ?? space(2) + padl ( "Actual Sales", 13 )
   ?? space(2) + padl ( "Variance",     13 )

    ? MARGIN   + repl ( "-", 3 )
   ?? space(2) + repl ( "-", 20 )
   ?? space(2) + repl ( "-", 20 )
   ?? space(2) + repl ( "-", 13 )
   ?? space(2) + repl ( "-", 13 )
   ?? space(2) + repl ( "-", 13 )

    ? MARGIN
  nCtr += 4   

   do while .T.

      if it390002 ( RPT_ID, PAGE_LEN, TOP_MARGIN, BOT_MARGIN, LEFT_MARGIN, RIGHT_MARGIN, nPage, THIS_WIDTH, nctr )
         it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
         nCtr := 0
         nPage++
         
          ? MARGIN

          ? MARGIN + " # "
         ?? space(2) + padr ( "Unit Name",    20 )
         ?? space(2) + padr ( "Address",      20 )
         ?? space(2) + padl ( "Target Sales", 13 )
         ?? space(2) + padl ( "Actual Sales", 13 )
         ?? space(2) + padl ( "Variance",     13 )

          ? MARGIN   + repl ( "-", 3 )
         ?? space(2) + repl ( "-", 20 )
         ?? space(2) + repl ( "-", 20 )
         ?? space(2) + repl ( "-", 13 )
         ?? space(2) + repl ( "-", 13 )
         ?? space(2) + repl ( "-", 13 )

          ? MARGIN
          nCtr += 4
      endif

      // Nothing to print.
      if u->(eof())
         exit
      endif

      // Indicate record being processed.
      @ 2, 1 wsay " Unit: " + u->u_001 + " " + u->u_002

       ? MARGIN + U->U_001 
      ?? space(2) + U->U_002
      ?? space(2) + U->U_003
      ?? space(2) + tran( U->U_004, "99,999,999.99" )
      ?? space(2) + tran( U->U_005, "99,999,999.99" )
      nVariance = U->U_005 - U->U_004
      ?? space(2) + tran( nVariance, "99,999,999.99" )
      nCtr += 1
      skip
   enddo

   dbCloseAll()

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

RETURN NIL
