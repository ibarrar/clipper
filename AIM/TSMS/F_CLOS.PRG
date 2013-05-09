#include "Janus.ch"
#include "inkey.ch"
#include "Box.ch"

#define C_ROW1  9
#define C_COL1  20
#define C_ROW2  10
#define C_COL2  36

#define M_ROW  14
#define M_COL  18

#define MY_COLOR "GR+/B,W+/N+"

FUNCTION CLOSING()
 // Save Screen
 LOCAL cSaveWin := savescreen( C_ROW1-1, C_COL1-1, C_ROW2 + 2, C_COL2 + 3 )
 LOCAL nChoice
 // Update key assignments
 LOCAL color := setcolor(MY_COLOR)

/* IF !pass( substr( blisernum(), 38, 8 ) )
   setkey( K_LEFT, bOldLeft )
   setkey( K_RIGHT, bOldRight )
   Display_Error( 10, 25, "Invalid Password !!!")
   RETURN nil
 ENDIF */

   @ C_ROW1-1, C_COL1-1, C_ROW2 + 1, C_COL2 + 1 BOX B_DOUBLE + " "
   shadow(C_ROW1-1, C_COL1-1, C_ROW2 + 1, C_COL2 + 1)

   // A menu for a choice of periodic closing.
   DO WHILE ( (nChoice := aChoice (C_ROW1, C_COL1, C_ROW2, C_COL2,;
                      { " Monthly Closing ", " Yearly Closing " },;
                                 ) ) != 0 )
     DO CASE
        CASE nChoice == 1
         if Alert("Warning: Monthly Readings will be lost",{"Continue"," Cancel "}) == 1
          Monthly_Closing()
         endif
        CASE nChoice == 2
         if Alert("Warning: Yearly Readings will be lost",{"Continue"," Cancel "}) == 1
          Yearly_Closing()
         endif
     ENDCASE
   ENDDO

   // Restore screen.
   restscreen ( C_ROW1-1, C_COL1-1, C_ROW2 + 2, C_COL2 + 3, cSaveWin )
   // Restore key assignments.
   setcolor(MY_COLOR)
RETURN nil

STATIC FUNCTION MONTHLY_CLOSING()
 Message (  "PERFORMING MONTHLY CLOSING, MONTHLY SALES WILL BE RESET..." )

 // Reset daily and monthly sale and rent.
 if NetUse("MASTER",DB_EXCLUSIVE,30)
    MASTER->(dbSetIndex( "MASTER" ))
    DBEval( {|| MASTER->DSALE := 0},,,,, .F. )
    DBEval( {|| MASTER->MSALE := 0},,,,, .F. )
    DBEval( {|| MASTER->MRENT := 0},,,,, .F. )
    MASTER->(DbCloseArea())
 endif

 // Remove all dept reports.
 if NetUse("DEPTX",DB_EXCLUSIVE,30)
    DEPTX->(dbSetIndex( "DEPTX" ))
    ZAP
    DEPTX->(DbCloseArea())
 endif

 if NetUse("DEPTZ",DB_EXCLUSIVE,30)
    DEPTZ->(dbSetIndex( "DEPTZ" ))
    ZAP
    DEPTZ->(DbCloseArea())
 endif

 // Remove all hourly reports.
 if NeTUse( "HOURX",DB_EXCLUSIVE,30)
    HOURX->(dbSetIndex( "HOURX" ))
    ZAP
    HOURX->(DbCloseArea())
 endif

 if NeTUse( "HOURZ",DB_EXCLUSIVE,30)
    HOURZ->(dbSetIndex( "HOURZ" ))
    ZAP
    HOURZ->(DbCloseArea())
 endif

 // Remove all terminal records.
 if NetUse("TERMX",DB_EXCLUSIVE,30)
    TERMX->(DbSetIndex("TERMX"))
    ZAP
    TERMX->(DbCloseArea())
 endif

 if NetUse("TERMZ",DB_EXCLUSIVE,30)
    TERMZ->(dbSetIndex( "TERMZ" ))
    ZAP
    TERMZ->(DbCloseArea())
 endif

 if NetUse("REPORTX",DB_EXCLUSIVE,30)
    REPORTX->(dbSetIndex( "REPORTX" ))
    ZAP
    REPORTX->(DbCloseArea())
 endif

 if NetUse("REPORTZ",DB_EXCLUSIVE,30)
    REPORTZ->(dbSetIndex( "REPORTZ" ) )
    ZAP
    REPORTZ->(DbCloseArea())
 endif

 Message ( "Done." )
RETURN nil


STATIC FUNCTION YEARLY_CLOSING ()
 Message ( "PERFORMING YEARLY CLOSING, YEARLY SALES WILL BE RESET...")

 // Reset daily, monthly, rent and yearly sales in the master file.
 if NetUse("MASTER",DB_EXCLUSIVE,30)
    MASTER->(dbSetIndex( "MASTER" ))
    DBEval( {|| MASTER->DSALE := 0},,,,, .F. )
    DBEval( {|| MASTER->MSALE := 0},,,,, .F. )
    DBEval( {|| MASTER->YSALE := 0},,,,, .F. )
    DBEval( {|| MASTER->MRENT := 0},,,,, .F. )
    MASTER->(DbCloseArea())
 endif

 // Remove all dept. records.
 if NetUse("DEPTX",DB_EXCLUSIVE,30)
    DEPTX->(dbSetIndex( "DEPTX" ))
    ZAP
    DEPTX->(DbCloseArea())
 endif

 if NetUse("DEPTZ",DB_EXCLUSIVE,30)
    DEPTZ->(dbSetIndex( "DEPTZ" ))
    ZAP
    DEPTZ->(DbCloseArea())
 endif

 // Remove all hourly records.
 if NetUse("HOURZ",DB_EXCLUSIVE,30)
    HOURZ->(DbSetIndex( "HOURZ" ))
    ZAP
    HOURZ->(DbCloseArea())
 endif

 if NetUse("HOURX",DB_EXCLUSIVE,30)
    HOURX->(DbSetIndex( "HOURX" ))
    ZAP
    HOURX->(DbCloseArea())
 endif

 // Remove all terminal records.
 if NetUse( "TERMX",DB_EXCLUSIVE,30)
    TERMX->(dbSetIndex( "TERMX" ))
    ZAP
    TERMX->(DbCloseArea())
 endif

 if NetUse( "TERMZ",DB_EXCLUSIVE,30)
    TERMZ->(dbSetIndex( "TERMZ" ))
    ZAP
    TERMZ->(DbCloseArea())
 endif

 Message ( "Done." )

RETURN nil
