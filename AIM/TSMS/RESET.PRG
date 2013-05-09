#include "Janus.ch"
#include "setcurs.ch"

#define R_ROW1 9
#define R_COL1 19
#define R_ROW2 15
#define R_COL2 59

#define M_ROW 12
#define M_COL 25

FUNCTION RESET ()
//  LOCAL cWindPromt :=  savescreen ( R_ROW1, R_COL1, R_ROW2+1, R_COL2+2 )
  LOCAL cOldColor := setcolor ( "BG+/R" )
  LOCAL nOldCurs := setcursor ( SC_NONE )

    // Reset files as if performing a daily closing.
    Message ("End of day resetting of totals..." )

    if NetUse("MASTER",DB_EXCLUSIVE,30)
       Set index to MASTER
    endif
      REPLACE ALL MASTER->DSALE WITH 0
    MASTER->(DbCloseArea())

    if NetUse("TERMX",DB_EXCLUSIVE,30)
       Set Index to TERMX
       DELETE ALL FOR ( TERMX->DSALE == 0 )
       PACK
       TERMX->(DbCloseArea())
    endif

    if NetUse("TERMZ",DB_EXCLUSIVE,30)
       Set Index to TERMZ
       DELETE ALL FOR ( TERMZ->DSALE == 0 )
       PACK
       TERMZ->(DbCloseArea())
    endif


    if NetUse("DEPTX",DB_EXCLUSIVE,30)
       Set Index to DEPTX
       ZAP
       DEPTX->(DbCloseArea())
    endif

    if NetUse("DEPTZ",DB_EXCLUSIVE,30)
       Set Index to DEPTZ
       ZAP
       DEPTZ->(DbCloseArea())
    endif

    if NetUse("HOURX",DB_EXCLUSIVE,30)
       Set Index to HOURX
       ZAP
       HOURX->(DbCloseArea())
    endif

    if NetUse("HOURZ",DB_EXCLUSIVE,30)
       Set Index to HOURZ
       ZAP
       HOURZ->(DbCloseArea())
    endif

    Message( "Closing all files..." )

  // Restore.
  setcursor( nOldCurs )
  setcolor( cOldColor )
//  restscreen( R_ROW1, R_COL1, R_ROW2+1, R_COL2+2, cWindPromt )

RETURN nil


