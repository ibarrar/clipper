/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  D_SCROLL.PRG                                        บ
บ  Description     :  Scroll Item Transaction on Receipt Image            บ
บ                                                                         บ
บ  Author          :  gladz dino                                          บ
บ  Date Started    :  august 1995                                         บ
บ  Last Revision   :                                                      บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "grfx_all.ch"
#include "powerpos.ch"
#include "spec_key.ch"
#include "nvr_file.ch"
#include "message.ch"
#include "terminal.ch"
#include "plu_file.ch"
#include "deptfile.ch"
#include "file_acc.ch"
#include "pfl_clip.ch"

static iRcpt_Row := 0
static iRcpt_Elem := 0
static aRcpt_Item[MAX_ITEM_DISP][9]

function getRcptRow(nVal)
  if valtype(nVal) == "N"
     iRcpt_Row := nVal
  endif   
return iRcpt_Row 

function getRcptCol(nVal)
  if valtype(nVal) == "N"
     iRcpt_Elem := nVal
  endif   
return iRcpt_Elem

function getRcptItem(nVal)
  if valtype(nVal) == "A"
     aRcpt_Item := aclone(nVal)
  endif   
return aRcpt_Item

/*---------------------------------------------------------------------------*/

FUNCTION Rcpt_Scroll(nScroll, cdescrip, quantity, namount, ctran_type, ;
                     disc_qty, disc_pct, disc_amt, addn_amt, clerk_code)

/*  Usage : Display Item Transaction on Receipt Image
    Descr :
    Parm  :
            nScroll     -> numeric argument specifying scroll movement
                              1 - scroll down
                             -1 - scroll up
            item_2      -> 20-char item description
            qty         -> quantity of items purchased
            amount      -> computed item unit price if qty > 1, else amt. alone
            nitem_amt   -> total amount of items
            ctran_type  -> transaction type "NDVE"
            disc_qty    -> quantity of discounted items
            disc_pct    -> discount percentage
            disc_amt    -> discount amount
            clerk_code  -> Clerk ID

    Return: no. of elements deleted/inserted
*/

  LOCAL iRowCtr  := 1                     // Row Counter/Adjustment variable
  LOCAL iStart   := 1                     // Loop counter initial value
  LOCAL iElemDif := 0                     // Function return value

  // If scroll up or scroll down
  IF (ABS(nScroll) == 1)

     iRowCtr   := Rcpt_CntRows( quantity, ctran_type, disc_qty, addn_amt, clerk_code )
     iRowCtr   += iRcpt_Row
     iRcpt_Row := IIF(iRowCtr > MAX_ITEM_DISP, 0, iRcpt_Row) 

     IF (nScroll == -1)

         // Insert an array row at the top
        Dim2_AINS( aRcpt_Item, 1 ) 

        // Delete array rows at the bottom
        DO WHILE iRowCtr > MAX_ITEM_DISP
           
           iRowCtr -= Rcpt_CntRows( aRcpt_Item[iRcpt_Elem][2] ,;    // quantity element
                                    aRcpt_Item[iRcpt_Elem][4] ,;    // transaction type
                                    aRcpt_Item[iRcpt_Elem][5] ,;    // discounted quantity
                                    aRcpt_Item[iRcpt_Elem][8] ,;    // add-on amount
                                    aRcpt_Item[iRcpt_Elem][9] )     // Clerk ID
           iRcpt_Elem--
        ENDDO

        iRcpt_Elem := MIN(iRcpt_Elem + 1, MAX_ITEM_DISP)

        // Set unused array elements to NIL
        Dim2_AFILL( aRcpt_Item, 0, iRcpt_Elem + 1)

        // subscript of array to assign parameters
        iStart := 1

        // Force display of entire aRcpt_Item array
        iRcpt_Row := 0
     ELSE   

       // Delete array rows at the bottom
       DO WHILE iRowCtr > MAX_ITEM_DISP
         iRowCtr -= Rcpt_CntRows( aRcpt_Item[1][2],;  // quantity element
                                  aRcpt_Item[1][4],;  // transaction type
                                  aRcpt_Item[1][5],;  // discounted quantity
                                  aRcpt_Item[1][8],;  // add-on amount
                                  aRcpt_Item[1][9] )  // Clerk ID

         Dim2_ADEL( aRcpt_Item, 1 )
         iElemDif++
       ENDDO

       iRcpt_Elem := iRcpt_Elem - iElemDif + 1
       iRcpt_Elem := MIN(iRcpt_Elem, MAX_ITEM_DISP)

       // subscript of array to assign parameters
       iStart := iRcpt_Elem
     ENDIF
     
       // Assign passed parameters to Item Display array
         aRcpt_Item[iStart][1] := cdescrip
         aRcpt_Item[iStart][2] := quantity
         aRcpt_Item[iStart][3] := namount
         aRcpt_Item[iStart][4] := ctran_type
         aRcpt_Item[iStart][5] := disc_qty
         aRcpt_Item[iStart][6] := disc_pct
         aRcpt_Item[iStart][7] := disc_amt
         aRcpt_Item[iStart][8] := addn_amt
         aRcpt_Item[iStart][9] := clerk_code 

  ELSE
     // Re-display entire array
     iRcpt_Row := 0
  ENDIF 

  IF (iRcpt_Row == 0)
     gClearTo(4, 28, 96, 74, 7)
     iStart := 1
  ELSE
     iStart := iRcpt_Elem
  ENDIF 

  FOR iRowCtr := iStart TO iRcpt_Elem
       Rcpt_ItemDisp( @iRcpt_Row, ;
          aRcpt_Item[iRowCtr][1] ,;
          aRcpt_Item[iRowCtr][2] ,;
          aRcpt_Item[iRowCtr][3] ,;
          aRcpt_Item[iRowCtr][4] ,;
          aRcpt_Item[iRowCtr][5] ,;
          aRcpt_Item[iRowCtr][6] ,;
          aRcpt_Item[iRowCtr][7] ,;
          aRcpt_Item[iRowCtr][8] ,;
          aRcpt_Item[iRowCtr][9] ,;
          BLACK)
  NEXT iRowCtr 

RETURN iElemDif 

/*--------------------------------------------------------------------------*/

FUNCTION Rcpt_ItemDisp( nRowCtr, cdescrip, qty, amount, ;
                        ctran_type, disc_qty, disc_pct, disc_amt, ;
                        addn_amt, clerk_code, nTextColor )
/*  Usage : Display Item Transaction on Receipt Image
    Descr :
    Parm  :
            nRowCtr     -> position of item in receipt image;
                           this must be passed by reference
            cdescrip    -> 20-char item description
            nquantity   -> quantity of items purchased
            nitem_price -> item unit price
            ctran_type  -> transaction type "NDVE"
            ndisc_qty   -> quantity of discounted items
            ndisc_pct   -> discount percentage
            ndisc_amt   -> discount amount
            naddn_amt   -> add-on/surcharge amount
            cclrk_code  -> Clerk ID
            Optional parameters :
            nTextColor  -> text color
    Return: nRowCtr
*/

 LOCAL nitem_amt := 0                       // item amount
 LOCAL cOutText  := ""                      // Output buffer
 

 // Handle omitted parameters
 nTextColor := IIF( nTextColor == NIL, CFG_DNORM, nTextColor)

 // calculate item amount
 nitem_amt := qty * amount
 
 // Negate item and discount amounts for VOID transaction
 IF ( ctran_type == "V" ) .or. (ctran_type == "G")
    nitem_amt := nitem_amt * -1
    addn_amt := addn_amt * -1
 ELSE
    disc_amt := disc_amt * -1
 ENDIF

 // display Clerk ID
 IF val(clerk_code) >= 1
     cOutText := "Clerk ID " + clerk_code
     gDrawText(nRowCtr + 8, 10, cOutText, ;
               SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)
     ++nRowCtr
     cOutText := ""
 ENDIF

 if ( ctran_type == "V" ) .or. (ctran_type == "G")
    gDrawText(nRowCtr + 8, 10, "VOID", ;
              SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)
    ++nRowCtr    
 endif   

    // Display Item descriptor
    gDrawText(nRowCtr + 8, 3, substr(cdescrip, 1, 15), ;
              SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)

    // display item qunatity sold  
    gDrawText(nRowCtr + 8, 22, transform(qty, "999.99"), ;
              SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)

    // display the unit price per item
    gDrawText(nRowCtr + 8, 29, transform(amount, "999,999.99"), ;
              SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)            
  
    // display the total cost per item
    gDrawText(nRowCtr + 8, 38, transform(nitem_amt, "9,999,999.99"), ;
              SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)                        

    // i have to add another space to show exchanged or adjusted flag, ;
    // if exchanged or adjusted display the trans flag otherwise space              

    //cOutText += IIF( ctran_type == "E", "E", " ")
    if ctran_type == "E"
       cOutText += "E"
    elseif ctran_type == "A"
       cOutText += "A"
    else
       cOutText += " "
    endif      

    gDrawText(nRowCtr + 8, 2, cOutText, ;
           SMALL_FONT, 8, nTextColor, MFIX, RIGHT_TEXT)

    ++nRowCtr

 // display discount amount and/or discount percent
 IF disc_amt != 0

    // Additional line for Void Item
      IF ( ctran_type == "V" ) .or. (ctran_type == "G")
           cOutText := "VOID"
           gDrawText(nRowCtr + 8, 10, cOutText, ;
                     SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)
          ++nRowCtr
      ENDIF

     cOutText := IIF(EMPTY(disc_pct), SPACE(5), ;
                      TRANSFORM(disc_pct, "@Z 99 % "))  + "DISCOUNT"
     gDrawText(nRowCtr + 8, 10, cOutText, ;
               SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)

     // display the total cost per item
        gDrawText(nRowCtr + 8, 40, transform(disc_amt, "999,999.99"), ;
                  SMALL_FONT, 8, nTextColor, MFIX, LEFT_TEXT)                        
     ++nRowCtr

 ENDIF

RETURN NIL

/*---------------------------------------------------------------------------*/

FUNCTION Rcpt_CntRows( qty, ctran_type, disc_qty, addn_amt, clerk_code)

/*  Usage : Get number of rows needed to display an
            item transactions
    Descr :
    Parm  :
            nquantity   -> no. of items purchased
            ctran_type  -> transaction type
            ndisc_qty   -> discount quantity
            naddn_amt   -> add-on amount/surcharge
            cclrk_code  -> Clerk ID

    Return: number of rows
*/

  LOCAL nRow := 1              // number of rows


  DO CASE
     CASE ( ctran_type == "D" )                  // Discount transaction type
          nRow += 1

     CASE ( ctran_type == "S" )                  // Item on Sale ( Time Price, Mix and Match)
           nRow += 1

     CASE ( ctran_type == "A" )                  // Add-on/Surcharge transaction type
           nRow := 1 

     CASE ( ctran_type == "V" )                  // Last Item Void trans. type
           nRow += 1
           // CHECK if Void item is discounted
           if disc_qty != 0
             nRow += 2
           endif  
           
     CASE ( ctran_type == "G" )                  // Mgrs Void transaction type
           nRow += 1
           // CHECK if Void item is discounted
           if disc_qty != 0
             nRow += 2
           endif  
             
  ENDCASE

  // Additional Line for Clerk ID
  /* nRow += IIF(val(clerk_code) != 0, 1, 0)  */


RETURN nRow

/*---------------------------------------------------------------------------*/

FUNCTION Disp_PayRcpt(nRow)

/*  Usage : Re-Display Item Transaction
            to accomodate payment messages
    Descr : there must be at least one item transaction
    Parm  :
    Return: NIL
*/

   // Move last item display up if needed
   IF iRcpt_Row > MAX_PAYROW

         // Display only 12 rows of items
         DO WHILE iRcpt_Row > MAX_PAYROW
               iRcpt_Row -= Rcpt_CntRows( aRcpt_Item[1][2],;  // quantity element
                                          aRcpt_Item[1][4],;  // transaction type
                                          aRcpt_Item[1][5],;  // discounted quantity
                                          aRcpt_Item[1][8],;  // add-on/surcharge amount
                                          aRcpt_Item[1][9] )  // Clerk ID

             Dim2_ADEL( aRcpt_Item, 1 )
            iRcpt_Elem--
         ENDDO
         Rcpt_Scroll( 0 )

   ENDIF

RETURN NIL

/*--------------------------------------------------------------------------*/

FUNCTION Dim2_AINS( aTarget, nPosition )

/*  Usage : Two-dimensional AINS() function
    Descr : Insert an entire Array Row
    Parm  :
         aTarget      -> array of any dimension provided
                         the data type and subarray are uniform
            nPosition    -> position of target array to insert
    Return: reference to the target array <aTarget>
*/

  LOCAL nRow, nCol                  // loop counter
  LOCAL nRowCnt, nColCnt            // Element counter

  nRowCnt := LEN(aTarget)
  nColCnt := LEN(aTarget[1])

  // Suppress array out of bound
  nPosition := MAX(nPosition, 1)

  FOR nRow = nRowCnt TO nPosition + 1 STEP -1

      FOR nCol = 1 TO nColCnt
          aTarget[nRow][nCol] := aTarget[nRow-1][nCol]
      NEXT nCol
  NEXT nRow

  FOR nCol = 1 TO nColCnt
      aTarget[nPosition][nCol] := NIL
  NEXT nCol

RETURN NIL

/*---------------------------------------------------------------------------*/

FUNCTION Dim2_AFILL( aTarget, expValue, nStart, nCount )

/*  Usage : Two-dimensional AFILL() function
    Descr : Insert an entire Array Row
    Parm  :
         aTarget      -> array of any dimension provided
                         the data type and subarray are uniform
            expValue     -> value to place in each array element
            nStart       -> position of first element to fill
         nCount       -> no. of elements to fill starting with
                         element no. <nStart>
    Return: reference to the target array <aTarget>
*/

  LOCAL nRow, nCol                  // loop counter
  LOCAL nColCnt                     // Array Column length

  // Handle omitted parameters
  nStart := IIF(nStart == NIL, 1, nStart)
  nCount := IIF(nCount == NIL, LEN(aTarget), nCount)

  // Suppress array out of bounds
  nCount  := MIN(LEN(aTarget) - nStart, nCount)
  nColCnt := LEN(aTarget[1])

  FOR nRow = nStart TO (nStart + nCount)
      FOR nCol = 1 TO nColCnt
       aTarget[nRow][nCol] := expValue
      NEXT nCol
  NEXT nRow

RETURN NIL

/*--------------------------------------------------------------------------*/

FUNCTION Dim2_ADEL( aTarget, nPosition )

/*  Usage : Two-dimensional ADEL() function
    Descr : Delete an entire Array Row
    Parm  :
            aTarget      -> array of any dimension provided
                            the data type and subarray are uniform
            nPosition    -> position of target array to delete
    Return: reference to the target array <aTarget>
*/
  LOCAL nRow, nCol                  // loop counter
  LOCAL nRowCnt, nColCnt            // Element counter

  nRowCnt := LEN(aTarget)
  nColCnt := LEN(aTarget[1])

  // Suppress array out of bound
  nPosition := MIN(nPosition, nRowCnt)

  FOR nRow = nPosition TO nRowCnt - 1
      FOR nCol = 1 TO nColCnt
          aTarget[nRow][nCol] := aTarget[nRow+1][nCol]
      NEXT nCol
  NEXT nRow

  FOR nCol = 1 TO nColCnt
      aTarget[nRowCnt][nCol] := NIL
  NEXT nCol

RETURN NIL

/* ------------------------------------------------------------------------ */
#ifdef NOTHING
FUNCTION Item_Select( nEOFrec)

/*  Usage : Select an item from Item Transaction Database
    Descr : calls Scroll function
    Parm  :
            nEOFrec     -> recound counter
    Return: record number of item selected
*/

  LOCAL iElement    := getRcptCol()                   // Highlighted item
  LOCAL nTopRec     := 1                              // Top record of item displayed
  LOCAL nBOFrec     := 1                              // FIRST record number
  LOCAL nItemRec    := 0                              // Function return value
  LOCAL nRecEnd     := getRcptCol()

  // NVRAM Transaction fields
  LOCAL cdescrip    := ""                             // item descriptor
  LOCAL nitem_price := 0                              // item unit price
  LOCAL nitem_qty   := 0                              // item quantity
  LOCAL clerk_code  := ""                              // clerk code
  LOCAL ctrans_type := ""                             // item transaction type
  LOCAL ndisc_qty   := 0                              // item discount quantity
  LOCAL ndisc_pct   := 0                              // item percent discount
  LOCAL ndisc_amt   := 0                              // item discount amount
  LOCAL naddn_amt   := 0                              // item add-on/surcharge amount
  LOCAL source_dev := 0
  LOCAL key_pressed := CLR
  LOCAL i := 1
  local x := 0,noofdisc := 0

  // If no records... EXIT
  IF (nEOFrec <= 0)
     RETURN nItemRec
  ENDIF


  IF ( iElement == 0 )
      nTopRec   := nEOFrec
      Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR )
  ELSE
      nTopRec := nEOFrec - iElement + 1
      key_pressed := 0
      Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR )
  ENDIF

  noofdisc := 0
  for x := 1 to iRcpt_Elem
     if (aRcpt_Item[x][6] + aRcpt_Item[x][7] != 0)
       noofdisc += 1
     endif  
  next x   

   DO WHILE .T. 
     key_pressed := input()   
     do case
        case (key_pressed == CLR .OR. key_pressed == ENTER)
             // Assign return value
             nItemRec := IIF( key_pressed == CLR, 0, nTopRec + iElement - 1)
             // Display last Rcpt array
             IF (nEOFrec >= nTopRec + nRecEnd)
                iRcpt_Row := 0
                nTopRec := nEOFrec
                RcptSearchTop(@nTopRec, nBOFrec)
                RcptAssign(nTopRec, nEOFrec) 
                Rcpt_Scroll(0)
             ELSE
                // Remove highlight
                Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL )
             ENDIF
             EXIT
        case (key_pressed == UP)
             Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL)
             // Scroll up
             IF ( iElement == 1 ) .AND. (nBOFrec <= nTopRec - 1) 
                   nTopRec-- 
                   tran_init(nTopRec)
                   if tran_cFlag() == OP_IDSC_FLAG .or. tran_cPflg() == OP_IDSC_FLAG
                      nTopRec--
                      noofdisc++
                      tran_init(nTopRec)
                   endif
                   cdescrip    := if(tran_cFlag() == "P", tran_cPLU(), tran_cDesc())
                   nitem_qty   := tran_nQty() 
                   nitem_price := tran_nPric()
                   ctrans_type := tran_cFlag()
                   clerk_code  := tran_cClrk()
                   tran_init(nTopRec+1)
                   ndisc_qty   := 0                   
                   ndisc_amt   := 0
                   ndisc_pct   := 0
                   if tran_cFlag() == "D" .or. tran_cPFlg() == "D"
                      ndisc_qty := tran_nCntr()
                      ndisc_pct := tran_nCntr()
                      ndisc_amt := tran_nSale()
                      if tran_cFlag() == "D"  
                         ctrans_type := "D"
                      endif   
                   endif   
                   Rcpt_Scroll( -1, cdescrip, ;
                                    nitem_qty, nitem_price ,;
                                    ctrans_type, ndisc_qty ,;
                                    ndisc_pct, ndisc_amt   ,;
                                    naddn_amt, clerk_code)
                  Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
             ELSE
                  // Move highlight bar upwards by one element
                  iElement := MAX(iElement - 1, 1)
                  Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
             ENDIF
        case (key_pressed == DOWN)
             Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL)
             // Scroll Down
             IF ( iElement == iRcpt_Elem ) .AND. (nEOFrec >= nTopRec + iRcpt_Elem + noofdisc ) 
                 tran_init(nTopRec + iRcpt_Elem + noofdisc )
                 if tran_cFlag() == OP_IDSC_FLAG .or. tran_cPFlg() == OP_IDSC_FLAG
                    nTopRec++
                    noofdisc++
                    tran_init(nTopRec + iRcpt_Elem + noofdisc )                    
                 endif
                 cdescrip    := if(tran_cFlag() == "P", tran_cPLU(), tran_cDesc())
                 nitem_qty   := tran_nQty()
                 nitem_price := tran_nPric()
                 ctrans_type := tran_cFlag()
                 clerk_code  := tran_cClrk()
                 tran_init(nTopRec + iRcpt_Elem + noofdisc +1)
                 ndisc_qty := 0
                 ndisc_pct := 0
                 ndisc_amt := 0                 
                 if tran_cFlag() == "D" .or. tran_cPFlg() == "D"
                     ndisc_qty := tran_nCntr()
                     ndisc_pct := tran_nCntr()
                     ndisc_amt := tran_nSale()
                     if tran_cFlag() == "D"
                        ctrans_type := "D"
                     endif                      
                 endif   
                 Rcpt_Scroll( 1, cdescrip, ;
                              nitem_qty, nitem_price ,;
                              ctrans_type, ndisc_qty ,;
                              ndisc_pct, ndisc_amt   ,;
                              naddn_amt, clerk_code )
                 iElement := iRcpt_Elem               

                 Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)

                 nTopRec++

              ELSE
                 // Move highlight bar downwards by one element
                 iElement := MIN(iElement + 1, iRcpt_Elem)
                 Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
              ENDIF
        otherwise
             * DO NOTHING
        endcase     

        noofdisc := 0
        for x := 1 to iRcpt_Elem
          if (aRcpt_Item[x][6] + aRcpt_Item[x][7] != 0)
            noofdisc += 1
          endif  
        next x   
  ENDDO

RETURN nItemRec
#endif

/*-------------------------------------------------------------------------*/

FUNCTION RcptSearchTop( nTopRec, nBOFrec)

/*  Usage : Search Top Record for Receipt Image Display Array
    Descr :
    Parm  :
            nTopRec     -> Record number of Top Array Element;
                           this must be passed by reference
            nBOFrec     -> First record number of Transaction Database
    Return: updated value of <nTopRec> parameter
*/

  // NVRAM Transaction fields
  LOCAL qty   := 0               //  item quantity
  LOCAL clerk_code := ""              //  clerk code
  LOCAL trans_type := ""              //  item transaction type
  LOCAL disc_qty   := 0               //  item discount amount
  LOCAL addn_amt   := 0               //  item add-on/surcharge amount

  // Search for Top Record
  DO WHILE (nBOFrec <= nTopRec ) .AND. (iRcpt_Row < MAX_ITEM_DISP - 1)

     tran_init(nTopRec)
     qty         := tran_nQty() 
     trans_type := tran_cFlag()
     clerk_code := tran_cClrk()
     iRcpt_Row += Rcpt_CntRows( qty, trans_type, disc_qty, ;
                                addn_amt, clerk_code)
     nTopRec--
  ENDDO

  nTopRec++

RETURN NIL

/*---------------------------------------------------------------------------*/

FUNCTION RcptAssign( nTopRec, nEOFrec )

/*  Usage : Assign Transaction Database records to
            Receipt Image Display Array
    Descr :
    Parm  :
            nTopRec     -> Record number of Top Array Element
            nEOFrec     -> Last record number of Transaction Database
    Return: NIL
*/

  LOCAL iRecCtr  := 0                  // Record counter
  LOCAL cdescrip    := ""              //  item descriptor
  LOCAL nitem_price := 0               //  item unit price
  LOCAL nitem_qty   := 0               //  item quantity
  LOCAL clerk_code  := ""              //  clerk code
  LOCAL ctrans_type := ""              //  item transaction type
  LOCAL ndisc_qty   := 0               //  item discount quantity
  LOCAL ndisc_pct   := 0               //  item percent discount
  LOCAL ndisc_amt   := 0               //  item discount amount
  LOCAL naddn_amt   := 0               //  item add-on/surcharge amount

  iRcpt_Row  := 0                      // Reset Receipt Row Counter
  iRcpt_Elem := 0                      // Reset Receipt Image aRcpt_Item elements counter

  iRecCtr    := nTopRec

  DO WHILE (iRecCtr <= nEOFRec) .AND. (iRcpt_Row < MAX_ITEM_DISP - 1)

     tran_init(iRecCtr)      
     if tran_cFlag() != "D"
       nitem_qty   := tran_nQty() 
       ctrans_type := tran_cFlag()
       if tran_cFlag() == "P"
         cdescrip := tran_cPLU()
       else
         cdescrip := tran_cDesc()
       endif   
       nitem_price := tran_nPric()
       clerk_code  := tran_cClrk()
       if (tran_cFlag() == "N" .and. tran_cPFlg() == "1") .or. ;
          (tran_cFlag() == "P" .and. tran_cPFlg() == "1")
          ctrans_type := "A"
       endif  
     endif  
     tran_init(iRecCtr + 1)
     if tran_cFlag() == "D" .or. tran_cPFlg() == "D"
        ndisc_pct := tran_nCntr()
        ndisc_amt := tran_nSale()
        if tran_cFlag() == "D"
           ctrans_type := "D"
        elseif tran_cPFlg() == "D"
           ndisc_qty := 2
        endif   
        iRecCtr++
     endif      
     tran_init(iRecCtr)
     iRecCtr++
     iRcpt_Elem++
            
     iRcpt_Row += Rcpt_CntRows( nitem_qty, ctrans_type, ndisc_qty, ;
                                naddn_amt, clerk_code)
                                
     aRcpt_Item[iRcpt_Elem][1] := cdescrip
     aRcpt_Item[iRcpt_Elem][2] := nitem_qty
     aRcpt_Item[iRcpt_Elem][3] := nitem_price
     aRcpt_Item[iRcpt_Elem][4] := ctrans_type
     aRcpt_Item[iRcpt_Elem][5] := 0
     aRcpt_Item[iRcpt_Elem][6] := ndisc_pct
     aRcpt_Item[iRcpt_Elem][7] := ndisc_amt
     aRcpt_Item[iRcpt_Elem][8] := 0
     aRcpt_Item[iRcpt_Elem][9] := clerk_code

     ndisc_pct := 0
     ndisc_amt := 0
     
  ENDDO

RETURN NIL

/*---------------------------------------------------------------------------*/

FUNCTION Rcpt_Hilite( iElement, nTextColor, nBarColor)

/*  Usage : Display Highlighted Item Transaction on Receipt Image
    Descr :
    Parm  :
            iElement    -> array subscript of aRcpt_Item
            nTextColor  -> Color of Text
            nBarColor   -> Color of Highlight bar
    Return: Row position of highlighted item
*/

  LOCAL nRow := 0              // Row position
  LOCAL iCtr := 0              // loop counter

  // Compute for Row position
  FOR iCtr = 1 TO (iElement - 1)

      // Check if quantity element is > 1
     nRow += Rcpt_CntRows( aRcpt_Item[iCtr][2],;  // quantity element
                           aRcpt_Item[iCtr][4],;  // transaction type
                           aRcpt_Item[iCtr][5],;  // discounted quantity
                           aRcpt_Item[iCtr][8],;  // add-on amount
                           aRcpt_Item[iCtr][9] )  // Clerk ID
  NEXT iCtr

  // Draw Highlight bar
  FOR iCtr = 1 TO Rcpt_CntRows( aRcpt_Item[iElement][2],;  // quantity element
                                aRcpt_Item[iElement][4],;  // transaction type
                                aRcpt_Item[iElement][5],;  // discounted quantity
                                aRcpt_Item[iElement][8],;  // add-on amount
                                aRcpt_Item[iElement][9] )  // Clerk ID

     gDrawText(nRow + iCtr + 7, 3, REPLICATE(CHR(177), 36), ;
               SMALL_FONT, 8, nBarColor, MFIX, LEFT_TEXT)
  NEXT iCtr

  Rcpt_ItemDisp( nRow ,;
                 aRcpt_Item[iElement][1], ;
                 aRcpt_Item[iElement][2] ,;
                 aRcpt_Item[iElement][3] ,;
                 aRcpt_Item[iElement][4], ;
                 aRcpt_Item[iElement][5] ,;
                 aRcpt_Item[iElement][6] ,;
                 aRcpt_Item[iElement][7] ,;
                 aRcpt_Item[iElement][8] ,;
                 aRcpt_Item[iElement][9] ,;
                 nTextColor )
RETURN nRow

/*---------------------------------------------------------------------------*/

FUNCTION Disp_LastPage( curr_item )

/*  Usage : Display Last Page of Item Transactions at Receipt Image
    Descr : Calls Rcpt_Scroll() function
    Parm  :
            ncurr_item  -> last transaction record number
    Return: NIL
*/

  LOCAL nTopRec   := 1        // Record number of item at the top of receipt image

  iRcpt_Row  := 0
  iRcpt_Elem := 0
  nTopRec    := curr_item

  IF curr_item > 0
     RcptSearchTop(@nTopRec, 1)
     // Make sure last item transaction is at the end of Receipt Image
     IF curr_item > 8
        nTopRec := MIN( nTopRec + 1, curr_item)
     ENDIF
     RcptAssign(nTopRec, curr_item)
     Rcpt_Scroll(0)
  ENDIF

RETURN NIL

static function load()
local nRecCtr := 1
local nEOFRec := nvr_nITMitem()
local aArray_ := {}
local nIndex  := 0
local cDesc   := ""
local nPrice  := 0
local nQty    := 0
local cClerk  := 0
local cFlag   := ""
local nDiscQty:= 0
local nDiscPct:= 0
local nDiscAmt:= 0
local nAddnAmt:= 0
local nRcpt_Row  := 0           // Reset Receipt Row Counter
local nRcpt_Elem := 0           // Reset Receipt Image aRcpt_Item elements counter

  while (nRecCtr <= nEOFRec) 
  
     tran_init(nRecCtr)      
     nIndex :=  nRecCtr
     if tran_cFlag() != "D"
       nQty  := tran_nQty() 
       cFlag := tran_cFlag()
       if cFlag == OP_NOTF_FLAG
         cDesc := tran_cPLU()
       else
         cDesc := tran_cDesc()
       endif          
       nPrice := tran_nPric()
       cClerk := tran_cClrk()
       if (tran_cFlag() == "N" .and. tran_cPFlg() == "1") .or. ;
          (tran_cFlag() == "P" .and. tran_cPFlg() == "1")
          cFlag := "A"
       endif  
     endif  
     nDiscPct := 0
     nDiscAmt := 0
     nDiscQty := 0
     tran_init(nRecCtr + 1)
     if tran_cFlag() == "D" .or. tran_cPFlg() == "D"
        nDiscQty := tran_nCntr()
        nDiscPct := tran_nCntr()
        nDiscAmt := tran_nSale()
        if tran_cFlag() == "D"
           cFlag := "D"
        elseif tran_cPFlg() == "D"
           nDiscQty := 2
        endif   
        nRecCtr++
     endif    
       
     nRecCtr++
     aAdd( aArray_ , { cDesc   , ;
                       nQty    , ;
                       nPrice  , ;
                       cFlag   , ; 
                       nDiscQty, ;
                       nDiscPct, ;
                       nDiscAmt, ;
                       nAddnAmt, ;
                       cClerk  , ;
                       nIndex  } )
     
   enddo
   
return aArray_


FUNCTION Item_Select( )

  LOCAL iElement    := getRcptCol()                   // Highlighted item
  LOCAL nTopRec     := 1                              // Top record of item displayed
  LOCAL nBOFrec     := 1                              // FIRST record number
  LOCAL nItemRec    := 0                              // Function return value
  LOCAL nRecEnd     := getRcptCol()

  // NVRAM Transaction fields
  LOCAL cdescrip    := ""                             // item descriptor
  LOCAL nitem_price := 0                              // item unit price
  LOCAL nitem_qty   := 0                              // item quantity
  LOCAL clerk_code  := ""                              // clerk code
  LOCAL ctrans_type := ""                             // item transaction type
  LOCAL ndisc_qty   := 0                              // item discount quantity
  LOCAL ndisc_pct   := 0                              // item percent discount
  LOCAL ndisc_amt   := 0                              // item discount amount
  LOCAL naddn_amt   := 0                              // item add-on/surcharge amount
  LOCAL source_dev := 0
  LOCAL key_pressed := CLR
  LOCAL i := 1
  local x := 0
  local aRecords    := load()
  local nEOFrec     := len(aRecords)

  // If no records... EXIT
  if nEOFrec == 0
     return nEOFrec
  endif

  if ( iElement == 0 )
       nTopRec   := nEOFRec
       Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR )
  else
      nTopRec := nEOFrec - iElement + 1
      key_pressed := 0
      Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR )
  endif

  while .t. 
     key_pressed := input()   
     do case
        case (key_pressed == CLR .OR. key_pressed == ENTER)
             // Assign return value
             nItemRec := if( key_pressed == CLR, 0, aRecords[nTopRec + iElement - 1][10])
             // Display last Rcpt array
             IF (nEOFrec >= nTopRec + nRecEnd)
                iRcpt_Row := 0
                nTopRec := nEOFrec
                RcptSearchTop(@nTopRec, nBOFrec)
                RcptAssign(nTopRec, nEOFrec) 
                Rcpt_Scroll(0)
             ELSE
                // Remove highlight
                Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL )
             ENDIF
             EXIT
        case (key_pressed == UP)
             Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL)
             // Scroll up
             IF ( iElement == 1 ) .AND. ( nTopRec > 1) 
                   nTopRec -= Max(Rcpt_Scroll( -1, aRecords[nTopRec-1][1], ;
                                    aRecords[nTopRec-1][2], ;
                                    aRecords[nTopRec-1][3], ;
                                    aRecords[nTopRec-1][4], ;
                                    aRecords[nTopRec-1][5], ;
                                    aRecords[nTopRec-1][6], ;
                                    aRecords[nTopRec-1][7], ;
                                    aRecords[nTopRec-1][8], ;
                                    aRecords[nTopRec-1][9] ), 1)
                  Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
             ELSE
                  // Move highlight bar upwards by one element
                  iElement := MAX(iElement - 1, 1)
                  Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
             ENDIF
        case (key_pressed == DOWN)
             Rcpt_Hilite( iElement, CFG_DNORM, CFG_DFILL)
             // Scroll Down
             IF ( iElement == iRcpt_Elem ) .AND. ((nTopRec + iRcpt_Elem) <= nEOFRec) 
                                            
                  nTopRec += Rcpt_Scroll( 1, aRecords[nTopRec+iRcpt_Elem][1], ;
                                  aRecords[nTopRec+iRcpt_Elem][2], ;
                                  aRecords[nTopRec+iRcpt_Elem][3], ;
                                  aRecords[nTopRec+iRcpt_Elem][4], ;
                                  aRecords[nTopRec+iRcpt_Elem][5], ;
                                  aRecords[nTopRec+iRcpt_Elem][6], ;
                                  aRecords[nTopRec+iRcpt_Elem][7], ;
                                  aRecords[nTopRec+iRcpt_Elem][8], ;
                                  aRecords[nTopRec+iRcpt_Elem][9] )                                
                 iElement := iRcpt_Elem               
                 Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
              ELSE
                 // Move highlight bar downwards by one element
                 iElement := MIN(iElement + 1, iRcpt_Elem)
                 Rcpt_Hilite( iElement, CFG_DHLITE, CFG_DBAR)
              ENDIF
        otherwise
             * DO NOTHING
        endcase     
  ENDDO

RETURN nItemRec
