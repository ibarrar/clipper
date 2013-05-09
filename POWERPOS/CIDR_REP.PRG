#include "spec_key.ch"
#include "message.ch"
#include "config.ch"
#include "cashier.ch"
#include "grfx_all.ch"
#include "terminal.ch"
#include "fileio.ch"

#define MAX_ROW   15
#define BLOCK 40

static n := 0

static aDenom := {.05,.10,.25,.50,1.00,2.00,5.00,10.00,20.00,50.00,100.00, ;
                    500.00,1000.00 }

static aMoney := {} 

#define TYPE_BANKCARD      "0"
#define TYPE_BANKCHEQUE    "3"
#define TYPE_INHOUSE       "1"
#define TYPE_PO            "2"
#define TYPE_GC            "4"

#define  DRAWER_OPEN       18
#define  DRAWER_CLOSED     19

#define CRLF  chr(13)+chr(10)
#define DEF_SCR_SWAP2      "image.img"

function cash_declare()
local i := 1,j := 1,k := 1
local cKey := 0, m := 0
local cData := ""
local ckeyBuff := ""
local out_text := ""
local money_val,nQuantity := 1
local total_money := 0
local pera,tot_amt := 0
local tot_value := 0
local lflag := .F.
local nPayt := 0
local misc_pay:=0, l:= 0
local aBankCards_ := {}
local aBankDescs_ := {}
local aBankCheck_ := {}
local aCheckDesc_ := {}
local arrMisc_ := {}
local arrDesc_ := {}
local aInCard_ := {}
local aInDesc_ := {}
local aGiftCard_ := {}
local aGiftDesc_ := {}
local nMisc := 0
local cdesc
local choice := 0
local lExit  := .F.
local ab := 0
local h := 0
local nRowCnt := 0
local nArrTop := 1
local lRefresh := .T.
local cWindow := OpenWindow(10, 15, 90, 82, "Cash Declaration Report")

   aMoney := ccd_reissue()

   gDrawText(9, 10, "Desc.", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(9, 25, "Qty", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(9, 35, "Denominations", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(9, 50, "Total Amount", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

   // open the drawer to be able the cashier to count the money
   open_drawr()
     
   out_text := "Cash Declaration Report " 
   A_RJS_PRNT(1, 1, 0, out_text, 1)
   out_text := "Cashier Code : " + space(11) + substr(nvr_cCashCode(), 1, 3) + ;
               replicate("*", 3) + chr(10)
   A_RJS_PRNT(1, 1, 0, out_text, 1)
   out_text := "Terminal No. " + space(15) + config(POS_TERM_NUM) + chr(10)           
   A_RJS_PRNT(1, 1, 0, out_text, 1)
   out_text := dtoc(date()) + space(16) + time()
   A_RJS_PRNT(1, 1, 0, out_text, 1)

   A_RJS_FEED(1, 1, 0, 2)

   do while .T.
     MsgAreaDisp("Enter Qty/Cash Denominations ...")
     
     #ifdef DEF_GRAPHICS
        Disp_Data(ckeyBuff + chr(95))
        
        if lRefresh
        gClearTo(13, 30, 86, 78, 7)

        h := max(1,len(aMoney)+1-MAX_ROW)
        l := 1
        while h <= len(aMoney)
          gDrawText(10 + l, 10, aMoney[h][6], SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
          gDrawText(10 + l, 25, trans(aMoney[h][2], "@B999"), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
          gDrawText(10 + l, 30, "X", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
          gDrawText(10 + l, 35, trans(aMoney[h][1], "99,999.99"), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
          gDrawText(10 + l, 50, trans(aMoney[h][3], "999,999.99"), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
          h++
          l++
        enddo
        endif
     #endif     

     cKey := input()

     lRefresh := .T.

     do case

        case cKey == QTY
               if cKeyBuff == ""
                  nQuantity := 1
               else
                  nQuantity := val(cKeyBuff)
               endif      
               ckeyBuff := ""
               #ifdef DEF_GRAPHICS
                 Disp_Data(ckeyBuff + chr(95))
               #endif         
               lRefresh := .F. 
        case cKey == CLR
               ckeyBuff := ""
               nQuantity := 1
               #ifdef DEF_GRAPHICS
                 Disp_Data(ckeyBuff + chr(95))
               #endif
               lRefresh := .F.
        case cKey == BACK_SPACE
               ckeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
               #ifdef DEF_GRAPHICS
                 Disp_Data(ckeyBuff + chr(95))
               #endif
               lRefresh := .F.
        case !empty(cData := is_number(@cKey))
               ckeyBuff += cData
               #ifdef DEF_GRAPHICS
                 Disp_Data(ckeyBuff + chr(95))
               #endif 
               lRefresh := .F.                       
        case ((nPayt := is_payment(@cKey)) != -1)
               if nPayt == 0
                   ckeyBuff := put_decimal(ckeyBuff)
                   if empty(ckeybuff)
                     loop
                   endif
                   money_val := val(ckeyBuff)

                   if (i := aScan(aDenom, {|x| x == money_val })) > 0
                     pera := aDenom[i]
                     tot_amt := pera * nQuantity
                     if (( i := aScan(aMoney, { |x| x[1] == pera .and. x[6] == "CASH" } ) ) > 0)
                       if nQuantity < 1
                          aDel(aMoney,i)
                          aSize(aMoney,len(aMoney)-1)
                       else 
                          aMoney[i][1] := pera
                          aMoney[i][2] := nQuantity
                          aMoney[i][3] := tot_amt
                          aMoney[i][4] := 0
                          aMoney[i][5] := "0000"
                          aMoney[i][6] := "CASH"
                          aMoney[i][7] := 0
                          aMoney[i][8] := .F.
                       endif   
                     elseif nQuantity >= 1
                       aAdd(aMoney, { pera, nQuantity, tot_amt, 0, "0000", "CASH", 0, .F.})
                     endif

                      ckeyBuff := ""
                      nQuantity := 1
                      Disp_Data(ckeyBuff + chr(95))
                   endif
               else
                  money_val := nPayt * -1
                  ckeyBuff := put_decimal(ckeyBuff)
                  if empty(ckeybuff)
                    loop
                  endif
                  misc_pay := val(ckeyBuff)

                  if nPayt == 100
                     for l := 1 to 50
                       if GetMType(l) == TYPE_BANKCARD .and. !empty(GetMDesc(l))
                          aAdd( aBankCards_ , {GetMDesc(l), GetMCode(l), l} )
                          aAdd( aBankDescs_, GetMDesc(l) )
                       endif
                     next l

                     while .T.
                       nMisc := aLookUp(25, 35, aBankDescs_ )
                       if nMisc == 0
                          ckeyBuff := ""
                          Disp_Data(ckeyBuff+chr(95))
                          exit
                       elseif nMisc > 0 .and. GetMtype(aBankCards_[nMisc][3]) == TYPE_BANKCARD
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
                          MsgAreaDisp(aBankCards_[nMisc][1])
                          BEEP_1()
                          tone(15,15)
                          exit
                       else
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
                          ErrorDisp("BANK CODE NOT FOUND!")
                       endif
                     enddo

                     if nMisc > 0
                        pera := misc_pay
                        tot_amt := pera * nQuantity

                        if ( ( i := aScan(aMoney,{ |x| x[6] = aBankCards_[nMisc][1] .and. x[1] == pera })) > 0)
                          if nQuantity < 1
                             aDel(aMoney,i)
                             aSize(aMoney,len(aMoney)-1)
                          else                           
                             aMoney[i][1] := pera
                             aMoney[i][2] := nQuantity
                             aMoney[i][3] := tot_amt
                             aMoney[i][4] := 0
                             aMoney[i][5] := aBankCards_[nMisc][2]
                             aMoney[i][6] := aBankCards_[nMisc][1]
                             aMoney[i][7] := pera
                             aMoney[i][8] := .F.
                           endif  
                         elseif nQuantity >= 1
                           aAdd(aMoney, { pera, nQuantity, tot_amt, 0, aBankCards_[nMisc][2], aBankCards_[nMisc][1], pera, .F.})
                        endif

                        ckeyBuff := ""
                        aBankCards := {}
                        aBankDescs := {}
                        Disp_Data(ckeyBuff + chr(95))
                   endif
                  elseif nPayt == 50
                     for l := 1 to 50
                      if GetMType(l) == TYPE_BANKCHEQUE .and. !empty(GetMDesc(l))
                        aAdd( aBankCheck_, {GetMDesc(l), GetMCode(l), l} )
                        aAdd( aCheckDesc_, GetMDesc(l))
                      endif
                     next l

                     while .T.
                      nMisc := aLookUp(25, 35, aCheckDesc_)
                      if nMisc == 0
                          ckeyBuff := ""
                          Disp_Data(ckeyBuff+chr(95))
                         exit
                      elseif nMisc > 0 .and. GetMtype(aBankCheck_[nMisc][3]) == TYPE_BANKCHEQUE
                        DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
                        MsgAreaDisp(aBankCheck_[nMisc][1])
                        BEEP_1()
                        tone(15,15)
                        exit
                      else
                        DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
                        ErrorDisp("BANK CODE NOT FOUND!")
                      endif
                     enddo

                     if nMisc > 0
                        pera := misc_pay
                        tot_amt := pera * nQuantity

                        if ( ( i := aScan(aMoney,{ |x| x[6] = aBankCheck_[nMisc][1] .and. x[1] == pera })) > 0)
                          if nQuantity < 1
                             aDel(aMoney,i)
                             aSize(aMoney,len(aMoney)-1)
                          else  
                             aMoney[i][1] := pera
                             aMoney[i][2] := nQuantity
                             aMoney[i][3] := tot_amt
                             aMoney[i][4] := 0
                             aMoney[i][5] := aBankCheck_[nMisc][2]
                             aMoney[i][6] := aBankCheck_[nMisc][1]
                             aMoney[i][7] := pera
                             aMoney[i][8] := .F.
                          endif   
                        elseif nQuantity >= 1
                          aAdd(aMoney, { pera, nQuantity, tot_amt, 0, aBankCheck_[nMisc][2], aBankCheck_[nMisc][1], pera, .F.})
                        endif

                     ckeyBuff := ""
                     Disp_Data(ckeyBuff + chr(95))
                     aBankCheck_ := {}
                     aCheckDesc_ := {}
                   endif
                 elseif nPayt == 250
                     for l := 1 to 50
                      if (GetMType(l) == TYPE_PO) .and. !empty(GetMDesc(l))
                        aAdd( arrMisc_ , {GetMDesc(l), GetMCode(l),l} )
                        aAdd( arrDesc_, GetMDesc(l) )
                      endif
                     next l

                     while .T.

                       nMisc := aLookUp(30, 35, arrDesc_, "  PURCHASE ORDER   ")

                       if nMisc == 0
                          ckeyBuff := ""
                          Disp_Data(ckeyBuff+chr(95))
                          exit
                       elseif nMisc > 0 .and. (GetMtype(arrMisc_[nMisc][3]) == TYPE_PO)
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
                          MsgAreaDisp(arrMisc_[nMisc][1])
                          BEEP_1()
                          tone(15,15)
                          exit
                       else
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
                          ErrorDisp("BANK CODE NOT FOUND!")
                       endif
                     enddo

                     if nMisc > 0
                        pera := misc_pay
                        tot_amt := pera * nQuantity

                        if ( ( i := aScan(aMoney,{ |x| x[6] = arrMisc_[nMisc][1] .and. x[1] == pera})) > 0)
                          if nQuantity < 1
                             aDel(aMoney,i)
                             aSize(aMoney,len(aMoney)-1)
                          else                           
                             aMoney[i][1] := pera
                             aMoney[i][2] := nQuantity
                             aMoney[i][3] := tot_amt
                             aMoney[i][4] := 0
                             aMoney[i][5] := arrMisc_[nMisc][2]
                             aMoney[i][6] := arrMisc_[nMisc][1]
                             aMoney[i][7] := pera
                             aMoney[i][8] := .F.
                          endif   
                        elseif nQuantity >= 1
                          aAdd(aMoney, { pera, nQuantity, tot_amt, 0, arrMisc_[nMisc][2], arrMisc_[nMisc][1], pera, .F.})
                        endif

                        ckeyBuff := ""
                        Disp_Data(ckeyBuff + chr(95))
                     endif
                     arrMisc_ := {}
                     arrDesc_ := {}
                  elseif nPayt == 200
                     for l := 1 to 50
                      if (GetMType(l) == TYPE_INHOUSE) .and. !empty(GetMDesc(l))
                        aAdd( aInCard_ , {GetMDesc(l), GetMCode(l), l} )
                        aAdd( aInDesc_, GetMDesc(l) )
                      endif
                     next l

                     while .T.

                       nMisc := aLookUp(30, 35, aInDesc_, "N.E. IN-HOUSE CARD")

                       if nMisc == 0
                          ckeyBuff := ""
                          Disp_Data(ckeyBuff+chr(95))
                          exit
                       elseif nMisc > 0 .and. (GetMtype(aInCard_[nMisc][3]) == TYPE_INHOUSE)
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
                          MsgAreaDisp(aInCard_[nMisc][1])
                          BEEP_1()
                          tone(15,15)
                          exit
                       else
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
                          ErrorDisp("BANK CODE NOT FOUND!")
                       endif
                     enddo

                     if nMisc > 0
                        pera := misc_pay
                        tot_amt := pera * nQuantity

                        if ( ( i := aScan(aMoney,{ |x| x[6] = aInCard_[nMisc][1] .and. x[1] == pera})) > 0)
                          if nQuantity < 1
                             aDel(aMoney,i)
                             aSize(aMoney,len(aMoney)-1)
                          else                          
                             aMoney[i][1] := pera
                             aMoney[i][2] := nQuantity
                             aMoney[i][3] := tot_amt
                             aMoney[i][4] := 0
                             aMoney[i][5] := aInCard_[nMisc][2]
                             aMoney[i][6] := aInCard_[nMisc][1]
                             aMoney[i][7] := pera
                             aMoney[i][8] := .F.
                          endif   
                        elseif nQuantity >= 1
                          aAdd(aMoney, { pera, nQuantity, tot_amt, 0, aInCard_[nMisc][2], aInCard_[nMisc][1], pera, .F.})
                        endif

                        ckeyBuff := ""
                        Disp_Data(ckeyBuff + chr(95))
                     endif
                     aInCard_ := {}
                     aInDesc_ := {}
                  elseif nPayt == 300
                     for l := 1 to 50
                      if (GetMType(l) == TYPE_GC) .and. !empty(GetMDesc(l))
                        aAdd( aGiftCard_ , {GetMDesc(l), GetMCode(l), l} )
                        aAdd( aGiftDesc_, GetMDesc(l) )
                      endif
                     next l

                     while .T.

                       nMisc := aLookUp(30, 35, aGiftDesc_, "  GIFT CHEQUES  ")

                       if nMisc == 0
                          ckeyBuff := ""
                          Disp_Data(ckeyBuff+chr(95))
                          exit
                       elseif nMisc > 0 .and. (GetMtype(aGiftCard_[nMisc][3]) == TYPE_GC)
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
                          MsgAreaDisp(aGiftCard_[nMisc][1])
                          BEEP_1()
                          tone(15,15)
                          exit
                       else
                          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
                          ErrorDisp("BANK CODE NOT FOUND!")
                       endif
                     enddo

                     if nMisc > 0
                        pera := misc_pay
                        tot_amt := pera * nQuantity

                        if ( ( i := aScan(aMoney,{ |x| x[6] = aGiftCard_[nMisc][1] .and. x[1] == pera})) > 0)
                          if nQuantity < 1
                             aDel(aMoney,i)
                             aSize(aMoney,len(aMoney)-1)
                          else
                             aMoney[i][1] := pera
                             aMoney[i][2] := nQuantity
                             aMoney[i][3] := tot_amt
                             aMoney[i][4] := 0
                             aMoney[i][5] := aGiftCard_[nMisc][2]
                             aMoney[i][6] := aGiftCard_[nMisc][1]
                             aMoney[i][7] := pera
                             aMoney[i][8] := .F.
                          endif   
                        elseif nQuantity >= 1
                          aAdd(aMoney, { pera, nQuantity, tot_amt, 0, aGiftCard_[nMisc][2], aGiftCard_[nMisc][1], pera, .F.})
                        endif

                        ckeyBuff := ""
                        Disp_Data(ckeyBuff + chr(95))
                     endif
                     aGiftCard_ := {}
                     aGiftDesc_ := {}
                  endif
               endif
        case cKey == CASHIER
                 MsgAreaDisp("[ENTER] key to confirm cancellation")
                 if input() == ENTER
                   CloseWindow(cWindow)
                   if config(POS_CASH_DRAWER) != "NO"
                     while  chk_drawr() != DRAWER_CLOSED
                          MsgAreaDisp(MSG_D014) // Close Drawer msg
                          tone(15,9)
                     enddo
                   endif
                   aMoney := {}
                   n := 0
                   return .T.
                 endif
                 ckeyBuff := ""
        case cKey == CASH_IN_DRAWER
               tot_value := 0
               for j := 1 to len(aMoney)
                  if aMoney[j][2] > 0 .and. aMoney[j][3] > 0
                    tot_value += aMoney[j][3]
                    k++
                  endif
               next
               k += m
               gDrawText(10 + 17, 10, "Cash Amount", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
               gDrawText(10 + 16, 50, "==========", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
               gDrawText(10 + 17, 50, trans(tot_value, "999,999.99"), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

               MsgAreaDisp("Are Data Correct? <ENTER> for YES and <CLR> for NO")

               while .T.
               
                 choice := input()

                 if choice == ENTER
                    // create the text file before printing
                    MsgAreaDisp(" Saving CCD report file ..." )     
                    Heythere()
                    if !save_ccd() 
                      ErrorDisp("Error Saving CCD report...")
                    endif  
                    MsgAreaDisp("Press Any Key to Continue ...")
                    input()               
                    for i := 1 to len(aMoney)
                     if aMoney[i][2] > 0 .and. aMoney[i][3] > 0
                       if val(aMoney[i][5]) == 0
                          A_RJS_PRNT(1, 1, 0, "CASH" + chr(10), 0)
                          out_text := padr(trans(aMoney[i][2], "@B999"),3) + "  " + "x" + ;
                                      space(3) + trans(aMoney[i][1], "999,999.99") + ;
                                      space(3) + trans(aMoney[i][3], "999,999.99") + chr(10)
                          A_RJS_PRNT(1, 1, 0, out_text, 1)
                       else
                          A_RJS_PRNT(1, 1, 0, alltrim(aMoney[i][6])+chr(10), 0) 
                          out_text := padr(trans(aMoney[i][2], "@B999"),3) + "  " + "x" + ;
                                      space(3) + trans(aMoney[i][7], "999,999.99") + ;
                                      space(3) + trans(aMoney[i][3], "999,999.99") + chr(10)
                           A_RJS_PRNT(1, 1, 0, out_text, 1)

                       endif   
                     endif   
                    next
                    
                    Cash_nData(CS_RONA_TOT,-Cash_nData(CS_RONA_TOT))
                    Cash_nData(CS_RONA_KNT,-Cash_nData(CS_RONA_KNT))
                    Cash_nData(CS_RONA_TOT, tot_value )
                    Cash_nData(CS_RONA_KNT, len(aMoney))
                    
/*
                    // put the amt. declared by cashier to terminal & cashier
                    Term_nData(TR_RONA_TOT, tot_value)
                    Term_nData(TR_RONA_KNT, 1)
*/               
                    out_text := space(22) + "__________" + chr(10)
                    A_RJS_PRNT(1, 1, 0, out_text, 1)
                    out_text := "Cash Amount " + space(10) + ;
                    trans(tot_value, "999,999.99") + chr(10)
                    A_RJS_PRNT(1, 1, 0, out_text, 1)
                    out_text := space(22) + "==========" + chr(10)
                    A_RJS_PRNT(1, 1, 0, out_text, 1)
                    prnt_end()

                    CloseWindow(cWindow)

                    if config(POS_CASH_DRAWER) != "NO" 
                       while chk_drawr() != DRAWER_CLOSED
                           MsgAreaDisp(MSG_D014) // Close Drawer msg
                           tone(15,9)                       
                       enddo               
                    endif               

                    //reinitialize the array and the row counter 
                    aMoney := {}
                    n := 0            
                    lExit := .T.
                    exit
                 elseif choice == CLR
                    Tone(300,16)   
                    ckeyBuff := ""
                    lExit := .F.
                    exit
                 endif  
              enddo  
              if lExit == .T.
                exit
              else
                gDrawText(10 + 17, 10, "Cash Amount", SMALL_FONT, 6, 7, MFIX, LEFT_TEXT)
                gDrawText(10 + 16, 50, "==========", SMALL_FONT, 6, 7, MFIX, LEFT_TEXT)
                gDrawText(10 + 17, 50, trans(tot_value, "999,999.99"), SMALL_FONT, 6, 7, MFIX, LEFT_TEXT)
                loop
              endif    
        otherwise
               MsgAreaDisp("Invalid Sequence ...")
               tone(300,3)
               MsgAreaDisp("Enter Qty/Cash Denominations ...")         
               ckeyBuff := ""
               lRefresh := .F.
     endcase   
   enddo
   
return nil

function save_ccd()
local fhandle := -1
local cBuffer 
local cFilename := GetLocal_Path()+nvr_cCashCode() +".ccd"
local text_2
local text
local text_1
local i

   // delete the previous file the current cashier if it
   // already exist
   fhandle := fcreate(cFilename, FC_NORMAL)
   
   if ferror() != 0
      ErrorDisp("Error creating CCD file:"+str(ferror()))
      error_log("Error creating CCD file:"+str(ferror()))
      return .f.
   endif      
   
   fseek(fhandle,0,FS_SET)
   // sort all array contents
   aSort(aMoney,,,{ |x,y| x[1]+(val(x[5])*10000) < y[1]+(val(y[5])*10000) })
   
   for i := 1 to len(aMoney)

       MsgAreaDisp("Saving CCD file <"+cFilename+">")
       text_2 := padl(aMoney[i][2],10,"0") 

       if aMoney[i][1] > 0 
         text := padl(alltrim(strtran(trans(aMoney[i][1],"999999.99"),".","")),12,"0")
       else   
         text := padl(alltrim(strtran(str(aMoney[i][7]),".","")),12,"0")
       endif   

       text_1 := padl(alltrim(strtran(str(aMoney[i][3]),".","")),12,"0") 

       cBuffer := padl(aMoney[i][5],4,"0")
       cBuffer += text_2
       cBuffer += text 
       cBuffer += text_1
       cBuffer += CRLF 

       fwrite( fhandle, cBuffer, len(cBuffer) )
        
   next i        
   fclose(fhandle)
   
return (ferror() == 0)



#define LOCAL_CASH_FILE  GetLocal_path()+"CASHIER.LOC"
#define  CS_FIELD_KNT   CS_ATRN_TIM // last field in the local cashier file 

function form_ccd(lReset)
local fhandle := -1
local sfhandle := -1
local cs_handle := -1
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local nCounter,nTotals,k
local cData
local cIndata,cOutData
local status := NORMAL
local cFilename := "CCDR.RPT"
local cSource_filename
local nTotAmount
local nTotCounter
local cHeader
local i := 0
local cBuffer 
local nReadlines
local aCash_ := {}

   if empty( lReset )
     lReset := .F.
   endif   

   nTotAmount  := Term_nData(TR_RONA_TOT)     
   nTotCounter := Term_nData(TR_RONA_KNT)    

   Term_nData(TR_RONA_TOT, -nTotAmount)     
   Term_nData(TR_RONA_KNT, -nTotCounter)       
   
   
   // Search for the key code entered
   if (( cs_handle := fopen ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
        error_log("Err Open "+LOCAL_CASH_FILE+": "+ltrim(str(ferror())))                 
   else  
      // Seek for the Cashier code to produce reports
      i := 0
      FSEEK( cs_handle, 0 , FS_SET )
      cBuffer := space(LOCAL_CASH_SIZE)
      while FREAD( cs_handle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         aadd( aCash_, subs(cBuffer,CASH_CODE_OFF,CASH_CODE_LEN) )
         i += LOCAL_CASH_SIZE
         FSEEK( cs_handle, i, FS_SET)
         cBuffer := space(LOCAL_CASH_SIZE)
      enddo         
   endif

   fclose(cs_handle)

   // now open output file append all reports
   // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 

   fhandle := fopen( ".\"+cFilename,FO_READWRITE )

   if ferror() == 2
      fhandle := fcreate( ".\"+cFilename, FC_NORMAL )
   endif
   if ferror() != 0
      MsgAreaDisp(" Error Opening CCD report file ")
      error_log(" Error Opening CCD report file ")
      tone(300,6)
      return .F.
   endif

   fseek( fhandle, 0, FS_END ) 

   for i := 1 to len(aCash_)
   
     cSource_filename := GetLocal_Path()+aCash_[i]+".CCD"
     sfhandle := fopen(cSource_filename,FO_READWRITE)

     MsgAreaDisp("Opening <"+cSource_filename+"> file...")

     if ferror()  != 0
        // opening error
        if ferror() != 2 //file not found
          MsgAreaDisp("Error Opening CCD file :"+str(ferror()))
          error_log("Error Opening CCD file :"+str(ferror()))
        endif  
        loop //proceed to next record
     endif
     cBuffer := "CASH DECLARATI REPORT"+space(16)+"<"+config(POS_TERM_NUM)+">"+CRLF 
     fwrite( fhandle,cBuffer,len(cBuffer))   
     cBuffer := cDate+ space(30) + subs(time(),1,5)+CRLF
     fwrite( fhandle,cBuffer,len(cBuffer))   
     cBuffer := ("[" +aCash_[i]+ "]"+ space(37)+CRLF)
     fwrite( fhandle,cBuffer,len(cBuffer))   

     nTotAmount := 0        
     nTotCounter := 0
     fseek(sfhandle,0,FS_SET)
     
     while .t.
       cBuffer := space(BLOCK)
       nReadLines := BLOCK
       nReadLines := fread(sfhandle,@cBuffer,nReadLines)
       if nReadLines != BLOCK
          exit
       endif   

       nTotAmount += val(subs(cBuffer,27,12)) * 0.01
       nTotCounter ++
       
       fwrite( fhandle, cBuffer, len(cBuffer) )

     enddo   
     fclose(sfhandle)   
     if lReset
       ferase(cSource_filename)
     endif  
     // now update the terminal and the cashier
     // put the amt. declared by cashier to terminal & cashier
     Term_nData(TR_RONA_TOT, nTotAmount)
     Term_nData(TR_RONA_KNT, nTotCounter)     
   next i        

   fclose( fhandle )

return .T.

function ccd_report(lReset)
local sfhandle := -1
local cs_handle := -1
local status := NORMAL
local cFilename := "CCDR.RPT"
local cSource_filename
local nTotAmount
local nTotCounter
local i:=0
local cBuffer 
local nReadlines
local aCash_ := {}

   nTotAmount  := Term_nData(TR_RONA_TOT)     
   nTotCounter := Term_nData(TR_RONA_KNT)    

   Term_nData(TR_RONA_TOT, -nTotAmount)     
   Term_nData(TR_RONA_KNT, -nTotCounter)       
    
   if empty( lReset )
     lReset := .F.
   endif   
   
   // Search for the key code entered
   if (( cs_handle := fopen ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
        error_log("Err Open "+LOCAL_CASH_FILE+": "+ltrim(str(ferror())))                 
   else  
      // Seek for the Cashier code to produce reports
      i := 0
      FSEEK( cs_handle, 0 , FS_SET )
      cBuffer := space(LOCAL_CASH_SIZE)
      while FREAD( cs_handle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         aadd( aCash_, subs(cBuffer,CASH_CODE_OFF,CASH_CODE_LEN) )
         i += LOCAL_CASH_SIZE
         FSEEK( cs_handle, i, FS_SET)
         cBuffer := space(LOCAL_CASH_SIZE)
      enddo         
   endif

   fclose(cs_handle)

   for i := 1 to len(aCash_)
   
     cSource_filename := GetLocal_Path()+aCash_[i]+".CCD"
     sfhandle := fopen(cSource_filename,FO_READWRITE)

     if ferror()  != 0
        // opening error
        if ferror() != 2 // if not file not found
          MsgAreaDisp("Error Opening CCD file :"+str(ferror()))
          error_log("Error Opening CCD file :"+str(ferror()))
        endif  
        loop //proceed to next record
     endif
     
     nTotAmount := 0        
     nTotCounter := 0
     fseek(sfhandle,0,FS_SET)

     while .t.
       cBuffer := space(BLOCK)
       nReadLines := BLOCK
       nReadLines := fread(sfhandle,@cBuffer,nReadLines)
       if nReadLines != BLOCK
          exit
       endif   

       nTotAmount += val(subs(cBuffer,27,12)) * 0.01
       nTotCounter ++
       
     enddo   
     fclose(sfhandle)   
     
     if lReset
       ferase(cSource_filename)
     endif  
     
     // now update the terminal and the cashier
     // put the amt. declared by cashier to terminal & cashier
     Term_nData(TR_RONA_TOT, nTotAmount)
     Term_nData(TR_RONA_KNT, nTotCounter)     
   next i        
   

return .T.

function ccd_reissue()
local cFilename := GetLocal_Path()+nvr_cCashCode()+".CCD"
local cBuffer := space(40)
local nCode,nQty,nDenom,nTotal
local out_text
local nGtotals := 0
local fhandle := fopen(cFilename,FO_READ)
local aArray_ := {}

  if ferror() == NORMAL
     out_text := "Cash Declaration Report " 
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     out_text := "Cashier Code : " + space(11) + substr(nvr_cCashCode(), 1, 3) + ;
                 replicate("*", 3) + chr(10)
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     out_text := "Terminal No. " + space(15) + config(POS_TERM_NUM) + chr(10)           
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     out_text := dtoc(date()) + space(16) + time()
     A_RJS_PRNT(1, 0, 0, out_text, 1)

     A_RJS_FEED(1, 0, 0, 2)
  
     while fread(fhandle,@cBuffer,40) == 40

       nCode := val(subs(cBuffer, 1, 4))
       nQty  := val(subs(cBuffer, 5,10))
       nDenom:= val(subs(cBuffer,15,12))* 0.01       
       nTotal:= val(subs(cBuffer,27,12))* 0.01

       if nCode == 0
          A_RJS_PRNT(1, 0, 0, "CASH" + chr(10), 0)
          aAdd(aArray_,{nDenom,nQty,nTotal,0,"0000","CASH",0,.F.})
       else          
          A_RJS_PRNT(1, 0, 0, GetMDesc(nCode) + chr(10), 0)
          aAdd(aArray_,{nDenom,nQty,nTotal,0,subs(cBuffer,1,4),GetMDesc(nCode),nDenom,.F.})          
       endif
       
       out_text := padr(trans(nQty, "@B999"),3) + "  " + "x" + ;
                   space(3) + trans(nDenom, "999,999.99") + ;
		   space(3) + trans(nTotal, "999,999.99") + chr(10)
                      
       A_RJS_PRNT(1, 0, 0, out_text, 1)
       nGtotals += nTotal
     enddo
     out_text := space(22) + "__________" + chr(10)
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     out_text := "Cash Amount " + space(10) + ;
     trans(nGTotals, "999,999.99") + chr(10)
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     out_text := space(22) + "==========" + chr(10)
     A_RJS_PRNT(1, 0, 0, out_text, 1)
     prnt_end()         
  endif

  fclose(fhandle)
    
return aArray_
