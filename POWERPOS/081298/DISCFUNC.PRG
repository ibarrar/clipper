#include "nvr_file.ch"
#include "message.ch"
#include "terminal.ch"
#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
#endif

function discount(cKeyBuff)
local nDiscQty := 0 // percentage of discount...
local nDiscAmt := 0
local cDiscCode:= ""
local nRate   := 0
local nAmount := 0
local nRecSale := 0
local curr_item := nvr_nITMitem()
local cCode, out_text
local cClerk,cCargo
local nQty := 0
local cDesc := "",pPLUCode
local pFlag := "",cFlag := ""
local nPrice := 0
local nRow := 0
local nCol := 0
local a_Item

  nRate := val(cKeyBuff)

  if nvr_nSUBtotal() != 0 .and. curr_item > 0

     // check if this transaction record can be discounted ?
     if tran_cFlag() == "N" .or. tran_cFlag() == "M" .or. ;
        tran_cFlag() == "P" 

        // now get the amount of this transaction
        nRecSale := tran_nSale()
        cClerk   := tran_cClrk()
        cCargo   := tran_cCrgo()
        if tran_cFlag() == "N"
           pFlag := tran_cFlag()
           pPLUCode := tran_cPLU()
        endif   
        if nRecSale <= 0
           MsgAreaDisp("CAN'T DISC. ZERO AMT")
           return .F.
        endif   
        
        if cDiscCode == Tran_cPLU()
           // get the discounted amt of that item
           nRecSale := nRecSale - nDiscAmt
        endif
               
        do case
           case tran_cFlag() == "N" .or. tran_cFlag() == "P" 
                cCode := pad(tran_cPLU(),TRAN_PLU_LEN,"0")
           otherwise
                cCode := pad("DEPT: "+tran_cDept(),TRAN_PLU_LEN)
                tran_cPLU(  space(TRAN_PLU_LEN )) 
                tran_cItem( space(TRAN_ITEM_LEN)) 
                tran_cRegM( "0" ) // set as keyboard method of entry                
        endcase                             

        #ifdef DEF_GRAPHICS
          if tran_cFlag() != OP_NOTF_FLAG
             cDesc := tran_cDesc()
             cFlag := "D"
          else
             cDesc := cCode   
             cFlag := "D"
          endif            
          if tran_cPFlg() == "1"
             cFlag := "A"
          endif   
        #endif 
        
        // Prepare the transaction record file for update
        tran_cFlag( OP_IDSC_FLAG ) // Found the plu set as normal        
        tran_cPFlg( "0" ) // Found the plu set as normal                
        tran_cPrcM( "0" ) // Temporarily set as normal pricing method
        tran_cClrk(cClerk)
        tran_cCrgo(cCargo)

        nAmount  := nRecSale * (0.01 * nRate)
        nAmount  := round(nAmount,2)

        #ifdef DEF_GRAPHICS
          nQty     := tran_nQty()
          nPrice   := tran_nPric()
        
          nRow := getRcptRow()
          nCol := getRcptCol()
          a_Item := aclone(getRcptItem())
          
          nRow -= Rcpt_CntRows( a_Item[nCol][2],; // quantity element
                                a_Item[nCol][4],; // transaction type
                                a_Item[nCol][5],; // discounted quantity
                                a_Item[nCol][8],; // add-on/surcharge amount
                                a_Item[nCol][9] ) // Clerk ID

          nCol--             // Use last element of Receipt Array

          getRcptRow(nRow)
          getRcptCol(nCol)
          Rcpt_Scroll(1, cDesc, nQty, nPrice, cFlag, nQty, nRate, nAmount, 0, tran_cClrk())
        #endif
        
        Term_nData( TR_IDSC_TOT, nAmount)
        Term_nData( TR_IDSC_KNT, 1 )

        tran_nSale( nAmount ) 
        tran_nCntr( nRate )   

        tran_cDesc( cCode )
        tran_nPric( nAmount )
        tran_nQty ( nRate  )

        // normalize the transaction subtotal and no of items  
        nvr_nSUBtotal(nvr_nSUBtotal() - nAmount)

        Update_Trans()        

        

        disp_Disc(nRate, nAmount, cCode)        

        out_text := trans(nRate,"999%")+pad("ITEM DISC",17) + trans(-nAmount, "9999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)            
        
        // try to print to optional slip printer...
        out_text := space(6) + TRANS(nRate,"999% DISCOUNT           ") + ;
                     transform(nAmount, "9999,999.99") + chr(10)
        slip_print(out_text, 0)
             
        // Put all the lastest data on the mem variable
        tran_init()
        #ifdef DEF_GRAPHICS
         Disp_BoldChar(nvr_nSUBtotal())
        #endif
     else           
        ErrorDisp("CAN'T DISC LAST ITEM")                 
     endif
  else
     ErrorDisp(MSG_D009)
  endif    

return nil                 

function disp_disc(nRate, nAmount, cCode)
local out_text

  disp_clr()
  DISPTEXTXY(1, 1, 0, 0, 1, 1, cCode )
  out_text := trans( nRate , "999%") + " DISC." + trans(-nAmount,"999,999.99")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, "ITEM DISCOUNT")

return nil  

function reprint_IDisc(nRate, nAmount)
local out_text

   out_text := trans(nRate,"999.99%")+pad("ITEM DISC",14) + trans(-nAmount, "9999,999.99") + chr(10) 
   rpt_prnt(1, 0, 0, out_text, 0)            
   
return nil

function SubttlDisc(cKeyBuff)
local nRate := val(cKeyBuff)
local nAmount 
local nAmtTotal 
local nSubtotal := nvr_nSUBtotal()
local out_text
local descriptor


  nAmount := nvr_nSUBtotal() * (0.01 * nRate)
  nAmount := round(nAmount,2)
  
  disp_Sdisc(nRate, nAmount )  

  out_text := "SUBTOTAL:          "+ trans(nvr_nSUBtotal(), "99,999,999.99")      
  A_RJS_FEED(1, 1, 0, 1)
  rpt_prnt(1, 1, 0, out_text , 0)                    
  
  out_text := trans(nRate,"999 %")+"STTL. DISCOUNT " + trans(-nAmount, "9999,999.99") + chr(10) 
  rpt_prnt(1, 1, 0, out_text, 0)            
  
  // try to print to optional slip printer...
  out_text := space(6) + TRANS(nRate,"999% SUBTOTAL % DISCOUNT") + ;
              transform(nAmount,"9999,999.99") + chr(10)
  slip_print(out_text, 0)

  nAmtTotal := nvr_nSUBtotal() - nAmount  
 
  Term_nData( TR_SDSC_TOT, nAmount )
  Term_nData( TR_SDSC_KNT, 1 )  
  
  nvr_nSUBtotal(nAmtTotal)  
             
  tran_cPLU  ( repl("0",14) )
  tran_cITEM ( repl("0",12) )
  tran_cDept ( repl("0",4)  )
  tran_cFlag ( OP_SDSC_FLAG )
  tran_cPFlg ( "0" )
  tran_cRegM ( "0" )
  tran_cPrcM ( "0" )
  tran_cConc ( repl("0",4) )
  tran_cColo ( "CL" )
  tran_cSize ( "SZ" )
  tran_nSale( nAmount )
  tran_nCntr( nRate )
  // skip cargo 
  tran_cDesc ( space(20) ) 
  tran_nPric ( 0 )
  tran_nQty  ( 0 )           

  // Add this record to the nvcntrl trans file...            
  Update_Trans()  

  #ifdef DEF_GRAPHICS
    descriptor := transform(nRate, "@Z 99% ") + "DISCOUNT"
    Disp_PayAmt(descriptor, nSubtotal, nAmount, nAmtTotal)
    Disp_BoldChar(nvr_nSUBtotal())
  #endif
return nil

function disp_Sdisc(nRate, nAmount)
local out_text

  disp_clr()
*  DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR )
  out_text := trans( nRate , "999%") + " DISC." + trans(-nAmount,"999,999.99")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, "*SUBTOTAL DISCOUNT*")

return nil  

function  reprint_SDisc(nRate,nAmount)
local out_text

  out_text := trans(nRate,"999.99 %")+"STTL. DISC.  " + trans(-nAmount, "9999,999.99") + chr(10) 
  rpt_prnt(1, 0, 0, out_text, 0)            
  
return nil

function iamtdisc(cKeyBuff)
local nDiscAmt := val(cKeyBuff)
local curr_item := nvr_nITMitem()
local nRecSale := 0
local cClerk := 0
local cCargo := 0
local cCode
local nRate := 0
local out_text
local nQty := 0
local cDesc := ""
local cFlag := ""
local nPrice := 0
local nRow := 0
local nCol := 0
local a_Item

  if nvr_nSUBtotal() > 0 .and. curr_item > 0

     // check if last transaction record can be discounted ?
     if tran_cFlag() == "N" .or. tran_cFlag() == "M" .or.;
        tran_cFlag() == "P"

        // now get the amount of this transaction
        nRecSale := tran_nSale()
        cClerk   := tran_cClrk()
        cCargo   := tran_cCrgo()
        
        if nRecSale <= 0
           MsgAreaDisp("CAN'T DISC. ZERO AMT")
           return .F.
        endif   

        if nRecSale <= nDiscAmt
           MsgAreaDisp("CAN'T DISC. SAME AMT")
           return .F.
        endif

        #ifdef DEF_GRAPHICS
          if tran_cFlag() != OP_NOTF_FLAG
             cDesc := tran_cDesc()
          else
             cDesc := cCode
          endif    
        #endif  
               
        do case
           case tran_cFlag() == "N" .or. tran_cFlag() == "P" 
                cCode := pad(tran_cPLU(),TRAN_PLU_LEN,"0")
           otherwise
                cCode := pad("DEPT: "+tran_cDept(),TRAN_PLU_LEN)
                tran_cPLU(  space(TRAN_PLU_LEN )) 
                tran_cItem( space(TRAN_ITEM_LEN)) 
                tran_cRegM( "0" ) // set as keyboard method of entry                
        endcase                             

        // Prapare the transaction record file for update
        tran_cFlag( OP_IDSC_FLAG ) // Found the plu set as normal        
        tran_cPFlg( "0" ) // Found the plu set as normal                
        tran_cPrcM( "0" ) // Temporarily set as normal pricing method
        tran_cClrkc(cClerk)
        tran_cCrgo(cCargo)
        
        nRate := nDiscAmt/(nRecSale * 0.01)
        nRate := round(nRate,2)

        #ifdef DEF_GRAPHICS
          nQty     := tran_nQty()
          nPrice   := tran_nPric()
          nRow := getRcptRow()
          nCol := getRcptCol()
          a_Item := aclone(getRcptItem())
           
          nRow -= Rcpt_CntRows( a_Item[nCol][2],; // quantity element
                                a_Item[nCol][4],; // transaction type
                                a_Item[nCol][5],; // discounted quantity
                                a_Item[nCol][8],; // add-on/surcharge amount
                                a_Item[nCol][9] ) // Clerk ID

          nCol--             // Use last element of Receipt Array

          getRcptRow(nRow)
          getRcptCol(nCol)
          cFlag := tran_cFlag()
          Rcpt_Scroll(1, cDesc, nQty, nPrice, cFlag, 0, 0, nDiscAmt, 0, cClerk)
        #endif

        Term_nData( TR_IDSC_TOT, nDiscAmt)
        Term_nData( TR_IDSC_KNT, 1 )

        tran_nSale( nDiscAmt ) 
        tran_nCntr( nRate )   

        tran_cDesc( cCode )
        tran_nPric( nDiscAmt )
        tran_nQty ( nRate  )

        // normalize the transaction subtotal and no of items  
        nvr_nSUBtotal(nvr_nSUBtotal() - nDiscAmt)

        Update_Trans()        

        disp_Disc(nRate, nDiscAmt, cCode)        
        #ifdef DEF_GRAPHICS
          Disp_BoldChar(nvr_nSUBtotal())
        #endif

        out_text := "*ITEM AMOUNT DISCOUNT" + trans(-nDiscAmt, "9999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)            
        
        // try to print to optional slip printer...
        out_text := space(6) + TRANS(nRate,"ITEM AMOUNT DISCOUNT    ") + ;
                     transform(nDiscAmt, "9999,999.99") + chr(10)
        slip_print(out_text, 0)
             
        // Put all the lastest data on the mem variable
        tran_init()
     else           
        ErrorDisp("CAN'T DISC LAST ITEM")                 
     endif
  else
     ErrorDisp(MSG_D009)
  endif    

return nil                 

function print_iamtDisc(nDiscAmt)                
local out_text

  out_text := "*ITEM AMOUNT DISCOUNT" + trans(-nDiscAmt, "9999,999.99") + chr(10) 
  rpt_prnt(1, 0, 0, out_text, 0)            
  
return nil  


function SamtDisc(cKeyBuff)
local nDiscAmt := val(cKeyBuff)
local nRate 
local nAmtTotal 
local nSubtotal := nvr_nSUBtotal()
local out_text

  if nSubtotal <= nDiscAmt
     MsgAreaDisp("INVALID DISC. AMOUNT")
     return .F.
  endif  
                  
  nRate := nDiscAmt/(nvr_nSUBtotal() * 0.01)
  nRate := round(nRate,2)
  
  disp_Sdisc(nRate, nDiscAmt )  
 
  out_text := "SUBTOTAL:          "+ trans(nvr_nSUBtotal(), "99,999,999.99")      
  A_RJS_FEED(1, 1, 0, 1)
  rpt_prnt(1, 1, 0, out_text , 0)       

  out_text := "*STTL AMOUNT DISCOUNT" + trans(-nDiscAmt, "9999,999.99") + chr(10) 
  rpt_prnt(1, 1, 0, out_text, 0)                

  nAmtTotal := nSubtotal - nDiscAmt  
 
  Term_nData( TR_SDSC_TOT, nDiscAmt )
  Term_nData( TR_SDSC_KNT, 1 )  
  
  nvr_nSUBtotal(nAmtTotal)    
        
  // try to print to optional slip printer...
  out_text := space(6) + "SUBTOTAL AMOUNT DISCOUNT" + ;
              trans(nDiscAmt,"9999,999.99") + chr(10)
  slip_print(out_text, 0)
             
  tran_cPLU  ( repl("0",14) )
  tran_cITEM ( repl("0",12) )
  tran_cDept ( repl("0",4)  )
  tran_cFlag ( OP_SDSC_FLAG )
  tran_cPFlg ( "0" )
  tran_cRegM ( "0" )
  tran_cPrcM ( "0" )
  tran_cConc ( repl("0",4) )
  tran_cColo ( "CL" )
  tran_cSize ( "SZ" )
  tran_nSale( nDiscAmt )
  tran_nCntr( nRate )
  // skip cargo 
  tran_cDesc ( space(20) ) 
  tran_nPric ( 0 )
  tran_nQty  ( 0 )           

  // Add this record to the nvcntrl trans file...            
  Update_Trans()  

  #ifdef DEF_GRAPHICS
    Disp_PayAmt("DISCOUNT", nSubtotal, nDiscAmt, nSubtotal - nDiscAmt)  
    Disp_BoldChar(nvr_nSUBtotal())
  #endif
return nil


function print_SamtDisc(nDiscAmt)
local out_text
  
  out_text := "*STTL AMOUNT DISCOUNT" + trans(-nDiscAmt, "9999,999.99") + chr(10) 
  rpt_prnt(1, 0, 0, out_text, 0)            
  
return nil  
