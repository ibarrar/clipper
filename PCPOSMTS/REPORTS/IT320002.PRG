/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it320002.prg - Item Directory module
         for Inventory Tracking System (ITS)

   acr / 12.27.90

 Revisions :
     1. Set filtering of items for i_019 != 2. Only records mark for deletion
        are not printed.
                                                   atc / 07.21.93       
     2. Replaced prow() with nCtr                                                   
                                                   eso / 09.25.95
============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "I-DIR"
#define RPT_NAME "ITEM DIRECTORY"
#define THIS_WIDTH (118 + PLU_CODE_LEN + PLU_DESC_LEN + LEFT_MARGIN )

STATIC nPage := 0
static nCtr := 0

/*==========================================*/
FUNCTION it320002
/*==========================================*/

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0 ,i
   local aVendor_ := {}
   local vCtr,nGoPrint := 2
   local flag := .f., lFirst := .t.
   nPage := 0
   nCtr := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

 if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   


   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)   
    *  Set Index to I_001
    Index on ITEM->I_020 to code
   endif
      
   set filter to ITEM->I_019 != 2 // Revised ATC 07-21-93.
   ITEM->(dbGoTop())


#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off

   

   lFirst := .t.
   while V->(!Eof())
   
    if lFirst
      it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
      nPage++ 
      // Print the headers for this report.
      it32000201()   
      lFirst := .f.
    endif  

      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + V->V_001 + " " + V->V_002

      // Print on next row.
      ?
      ? MARGIN + V->V_001
      ?? space(4) + V->V_002 
      nCtr += 2

      flag := .f.
      ITEM->(DbSeek(V->V_001))
      while ITEM->(!Eof()) .and. V->V_001 == ITEM->I_020 

        if ITEM->(!Deleted()) 
          if lFirst
            it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
            nPage++ 
            // Print the headers for this report.
            it32000201()   
            lFirst := .f.
          endif  
          if flag
             ? MARGIN +space(37)
             nCtr += 1
          endif
          ?? space(2) + ITEM->I_001 + tran(getchkdgt(ITEM->I_001)," 9") // IV->IV_CODE     
          ?? space(2) + ITEM->I_037  
          ?? space(3) + tran(ITEM->I_003, "999,999.99" )
          ?? space(3) + tran(ITEM->I_010, "999,999,999" )           
          ?? space(2) + tran(ITEM->I_011, "999,999,999" )           
          ?? space(2) + tran(ITEM->I_012, "999,999,999" )           
          
          flag := .t.
          if nCtr > 50
            lFirst := .t.
            nCtr := 0
            ? chr(12)
          endif
        endif
        
        ITEM->(DbSkip()) 
      enddo
      
      
      V->(Dbskip())

   enddo
    ?
    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   dbCloseAll()

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

   Repgen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   Ferase("code.ntx")

RETURN NIL

/*==========================================*/
FUNCTION it320002p
/*==========================================*/

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0 ,i
   local aVendor_ := {}
   local vCtr,nGoPrint := 2, lFirst := .t.
   local flag := .f., getlist := {}, vBrowse, vRecord := space(3)
   nPage := 0

   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   setCursor("ON")
   read
   setCursor("OFF")
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0") 

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

 if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("IV",DB_SHARED,NUM_SECONDS)
      Set Index to IV_LINK
   endif   

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)   
    *  Set Index to I_001
    Index on ITEM->I_020 to code
   endif
      
   set filter to ITEM->I_019 != 2 // Revised ATC 07-21-93.
   ITEM->(dbGoTop())


#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off

   

   if lfirst
      // Standard page header routine.
      it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
      nPage++
      // Print the headers for this report.
      it32000201()   
      lFirst := .f.
   endif

   flag := .f.
   // Indicate record being processed.
   @ 2, 1 wsay " Item: " + vRecord
   if ITEM->(DbSeek(vRecord))
   
      // Print on next row.
      V->(DbSeek(vRecord))
      if vRecord == V->V_001
        ?
        ? MARGIN + ITEM->I_020  
       ?? space(4) + V->V_002
       nCtr += 2
      endif
      
      while ITEM->(!Eof()) .and. vRecord == ITEM->I_020 
      
        if ITEM->(!Deleted()) 
          if lFirst
            // Standard page header routine.
            it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
            nPage++
            // Print the headers for this report.
            it32000201()   
            lFirst := .f.
          endif  
          if flag
             ? MARGIN +space(37)
             nCtr += 1
          endif
          ?? space(2) + ITEM->I_001 + tran(getchkdgt(ITEM->I_001)," 9") // IV->IV_CODE     
          ?? space(2) + ITEM->I_037  
          ?? space(3) + tran(ITEM->I_003, "999,999.99" )
          ?? space(3) + tran(ITEM->I_010, "999,999,999" )           
          ?? space(2) + tran(ITEM->I_011, "999,999,999" )           
          ?? space(2) + tran(ITEM->I_012, "999,999,999" )           
          
          flag := .t.
          if nCtr > 50
            lFirst := .t.
            nCtr := 0
            ? chr(12)
          endif
          
        endif
        
        ITEM->(DbSkip()) 
      enddo
      
    else
       Message("Supplier Code :"+vRecord+" not found ...")
       BUMMER() 
    endif  
    
    ?
    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   dbCloseAll()

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

   Repgen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   Ferase("code.ntx")

RETURN NIL


/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it32000201

      ? MARGIN  + "Report Date: " + dtoc(date())     
      ?
      ?  MARGIN   + "SUPPLIER---------------------------------" 
      ??   "ITEM" + repl("-",PLU_CODE_LEN + PLU_DESC_LEN + 73)
      
      ?  MARGIN   + padr ( "Code",         4 ) 
      ?? space(4) + padr ( "Name",        30 ) 
      ?? space(2) + padr ( "Code", PLU_CODE_LEN )
      ?? space(2) + padr ( "Description", 40 )
      ?? space(4) + padr ( "Sell Price", 10 )
      ?? space(3) + padr ( "Max. Level", 10 )
      ?? space(4) + padr ( "Min. Level", 10 )
      ?? space(3) + padr ( "ReOrder Lvl.", 12 )
      

       ? MARGIN +  replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
       nCtr += 3
RETURN NIL
