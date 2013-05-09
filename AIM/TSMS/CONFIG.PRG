#include "fileio.ch"
#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"
#include "Setcurs.ch"
#include "Janus.ch"

#define  MY_COLOR "GR+/B,W+/N+"
#define  C_BLOCK 140
#define  CL_ROW1   4
#define  CL_COL1  40
#define  CL_COL2  49

#define CHOICE_PROMPT "Press * to Mark Selection, - to UnMark, END to Save"
#define MARKER if( lReadPOS, "û", "²" )
#define TCODE(x) substr( aTCChoices[ x ], 2, 6 )

#define C_ROW1  9
#define C_COL1 17
#define C_ROW2 21
#define C_COL2 63

#define AC_ROW1 7
#define AC_COL1 65
#define AC_COL2 74

#define MODEL_LENGTH len( cModelName )

static rel_elem, rel_row, choice:=1, aCCode := {}
static aTCISC := {}, aTCChoices := {}, cTemp
static aScrollBar,aScroll2Bar

function Config( nMapTag )
local aISCStat := {}, i, cModel, lOK, aISCs
local cBuffer  := space ( C_BLOCK ), nHandle, cISCNo, windbuff
local bOldLeft := setkey ( K_LEFT, nil )
local bOldRight:= setkey ( K_RIGHT, nil )
local color

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)  // Look for cluster codes in master.
    Set Index to MASTER
 endif
 MASTER->(DbGoTop())

 // Resize aCCode
 asize( aCCode, 0 )

 do while (!eof()) // Repeat until all are found.
  // Check if already existing in the array.
  if ( aScan( aCCode, MASTER->CCODE ) == 0 )
    aadd( aCCode, MASTER->CCODE )  // Not yet, add it to the array.
  endif
  MASTER->(DbSkip())  // next record.
 enddo

 // Close the file.
 MASTER->(DbCloseArea())

 // No Cluster records ?
 if len( aCCode ) <= 0
  Message("No tenant's record. Please enter data first." )
  Tone(300,2)
  inkey(2)
  setkey( K_LEFT, bOldLeft )
  setkey( K_RIGHT, bOldRight )
  return nil
 endif

 // Save screen for the table.
 windbuff:= Savescreen( CL_ROW1, CL_COL1, CL_ROW1+7, CL_COL2 + 2 )
 color := setcolor(MY_COLOR)
 asort( aCCode,,, { |a,b| a < b } )  // sort..

 // Pad spaces in the cluster codes.
 for i:=  1 to len( aCCode )
  aCCode[i] := padc(aCCode[i]+" ",8)
 next i

 // Create box for choosing cluster codes.
 @ CL_ROW1, CL_COL1,CL_ROW1+ min( 1+len(aCCode),7 ), CL_COL2 Box B_DOUBLE+" "
 @ CL_ROW1, CL_COL1 + 1 SAY "CLUSTER"
 Shadow( CL_ROW1, CL_COL1,CL_ROW1+ min( 1+len(aCCode),7 ), CL_COL2 )

do while .t.
 aScrollBar:=ScrollBarNew(CL_ROW1,CL_COL2,CL_ROW1+min(1+len(aCCode),7),setcolor(),1)
 ScrollBarDisplay(aScrollBar)
 ScrollBarUpdate(aScrollBar,1,Len(aCCode),.T.)
 choice:= aChoice(CL_ROW1+1,CL_COL1+2,CL_ROW1+min( len(aCCode),6),CL_COL2-2,aCCode,,"Handle2Menu",choice)

 if choice == 0
   exit
 endif
    // Convert machine code to machine model name.
    do case
      case subs(ltri(aCCode[choice]),1,1) == "1"
        cModel := " RS 34-60 "
      case subs(ltri(aCCode[choice]),1,1) == "2"
        cModel := " RS 35-10 "
      case subs(ltri(aCCode[choice]),1,1) == "3"
        cModel := " RS 45-40 "
      case subs(ltri(aCCode[choice]),1,1) == "4"
       cModel := " RS 55-50 "
    endcase

   if nMapTag == 1
      Message( "Mark the ISC Nos. for Cluster : " + alltrim(aCCode[choice]) )
   endif

   aISCs := GetISC_Connected( alltrim( aCCode[choice] ))

   // Get ISC tagged status for this cluster
   aSize( aISCStat,0 )
   for i := 1 to 64
      aAdd(aISCStat, (ascan( aISCs, i - 1 ) > 0 ))
   next i

   // Call module for selecting isc numbers.
   if nMapTag == 1
      ArrayBrow( aISCStat, cModel, .f.,, alltrim( aCCode[choice] ) ,"" )
   else
      MapCluster(alltrim( aCCode[choice] ) )
   endif

   Message( "Configure POS Settings")
enddo
   // Restore parameters changed.
   setkey ( K_LEFT, bOldLeft )
   setkey ( K_RIGHT, bOldRight )
 restscreen ( CL_ROW1, CL_COL1,  CL_ROW1+7, CL_COL2 + 2, windbuff )
 setcolor(color)
return nil

function Handle2Menu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   ScrollBarUpdate(aScrollBar,nCurElem,len(aCCode),.F.)
   do case
      case nMode==AC_EXCEPT
           nKey:=Lastkey()
           do case
              case nKey==K_ESC
                   nRetVal:=AC_ABORT
              case nKey==K_ENTER
                   nRetVal:=AC_SELECT
              otherwise
                   nRetVal:=AC_CONT
           endcase
       otherwise
          nRetVal:=AC_CONT
   endcase
return nRetVal

/* This function will return an array of isc nos. which are connected to a
   particular cluster. */
function GetISC_Connected( cCluster )
local aISCs := {}
 // Open Database ISCMAP
 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
   Set index to ISCMAP,ISCODE
 endif
 ISCMAP->(DbGotop())

 Locate for (ISCMAP->CLUSTER==cCluster)
 do while found() .and. (!eof()) .and. (!Deleted())
  if ISCMAP->ISC_NO != "99"
    aadd( aISCs, val( ISCMAP->ISC_NO ) )
  endif
  ISCMAP->(DbSkip())
  locate rest for (ISCMAP->CLUSTER==cCluster)
 enddo

 ISCMAP->(DbCloseArea())
return aISCs

function ArrayBrow ( aISCStat, cModelName, lReadPOS, nRChoice, cClusChoice, XORZ )
local browse, key, n := 1, cWindBuff, nElement, i, j
local choice, cBuffer, cLineSave, NagRead := .F.
 // The array declared to represent the isc table.
local nOldCursor, aISC :={;
                  { " 00", " 01", " 02", " 03", " 04", " 05", " 06", " 07" },;
                  { " 08", " 09", " 10", " 11", " 12", " 13", " 14", " 15" },;
                  { " 16", " 17", " 18", " 19", " 20", " 21", " 22", " 23" },;
                  { " 24", " 25", " 26", " 27", " 28", " 29", " 30", " 31" },;
                  { " 32", " 33", " 34", " 35", " 36", " 37", " 38", " 39" },;
                  { " 40", " 41", " 42", " 43", " 44", " 45", " 46", " 47" },;
                  { " 48", " 49", " 50", " 51", " 52", " 53", " 54", " 55" },;
                  { " 56", " 57", " 58", " 59", " 60", " 61", " 62", " 63" }   }
local  cOldColor := if ( iscolor(), setcolor( "B+/W,W+/B+,,,B+/W+" ),;
                                    setcolor( "N/NW,NW/N,,,N/NW" ) )

  // Marked corresponding cell according to their status.
  for i := 1 to 8
   for j := 1 to 8
     if ( aISCStat [ n++ ] )
       aISC [i,j] := MARKER + substr ( aISC [i,j], 2, 2 )
     endif
   next j
  next i

  // save window coordinates.
  cWindBuff := savescreen (C_ROW1, C_COL1, C_ROW2 + 1, C_COL2 + 2 )
  // Hide cursor.
  nOldCursor := SetCursor(SC_NONE)
  nElement := 1 // This will be our "element pointer"

  // Create box for browsing.
  @ C_ROW1, C_COL1, C_ROW2, C_COL2 Box  B_DOUBLE_SINGLE+" "
  @ C_ROW1+2, C_COL1 say "Æ"
  @ C_ROW1+2, C_COL2 say "µ"
  @ C_ROW2-1, C_COL1 say "Æ"
  @ C_ROW2-1, C_COL2 say "µ"

  // Write the bottom message of the table.
  if lReadPOS
    @ C_ROW2, C_COL1+2 say "ESC - Exit"
  else
    @ C_ROW2, C_COL1+2 say "ESC - Save and exit"
    aTCISC := Get_Tcode_IscNos()
  endif
  Shadow ( C_ROW1, C_COL1, C_ROW2, C_COL2 )

  // Display machine model.
  if cModelName != nil
    @ C_ROW1, C_COL1 + int( ( C_COL2 - C_COL1 ) / 2 ) - int( MODEL_LENGTH/2 ) ;
      say cModelName
  endif

  // Create a TBrowse object that knows how to deal with databases.
  browse := TBrowseNew( C_ROW1 + 1, C_COL1 + 1, C_ROW2 - 1, C_COL2 - 1)

  // Separators.
  browse:headSep := "ÍÑÍ"
  browse:colSep :=  " ³ "
  browse:footSep := "ÍÏÍ"

  // Assign positioning blocks.
  browse:goTopBlock    := { | | nElement:= 1 }
  browse:goBottomBlock := { | | nElement:=len ( aISC ) }
  browse:skipBlock     := { |x| ArraySkip ( len ( aISC ), @nElement, x ) }

  // For each subarray in the ISC array....
  // Create a column object.
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 1] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 2] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 3] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 4] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 5] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 6] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 7] } ) )
  browse:addColumn(TBColumnNew("   ", { | | aISC[nElement, 8] } ) )

  // Keep looping as long as user wants to browse.
  do while .t.

  // Keep looping until all rows in window have been displayed.
   do while (!browse:stabilize())
    if NextKey() <> 0
     exit
    endif
   enddo

   // Wait for a keystroke.
   key := Inkey (0)
   // Move the pointer based on user's keystroke.
   do case
    case key == K_UP;   browse:up()    // Up one row
    case key == K_DOWN; browse:down()  // Down one row
    case key == K_LEFT; browse:left()  // Left one column
    case key == K_RIGHT;browse:right() // Right one column
    case key == K_PGUP; browse:pageUP()  // Up one page
    case key == K_PGDN; browse:pageDown()  // Down one page
    case key == K_HOME; browse:home()  // Go to left most column
    case key == K_END;  browse:end()   // Go to right most column
    case key == K_CTRL_HOME; browse:panHome()  // Go to 1st column
    case key == K_CTRL_END; browse:panEnd()   // Go to last column
    case key == K_ENTER     // Mark cell or Read a terminal
                            // This is the isc no.
     cTemp := substr ( aISC[browse:rowPos, browse:colPos], 2, 2 )

     if lReadPOS
       // Read the ECR individually.
       if  ( aISCStat[ val( cTemp ) + 1] ) // Check if configured.
         do case
           case nRChoice == 1   // Terminal
             Terminal_Read ( cTemp, cClusChoice, XORZ )
           case nRChoice == 2   // Department
             Department_Read ( cTemp, cClusChoice, XORZ )
           case nRChoice == 3   // PLU/SDP
             PLU_SDP_Read ( cTemp, cClusChoice, XORZ )
           case nRChoice == 4   // Hourly
             Hourly_Read ( cTemp, cClusChoice, XORZ )
           case nRChoice == 5   // Cashier
             Cashier_Read ( cTemp, cClusChoice, XORZ)
         endcase
         // Mark the cell to be unselected for it not to be read twice.
         aISC[browse:rowPos, browse:colPos] := " " + cTemp
         aISCStat [ val( cTemp ) + 1 ] := .F.
         NagRead := .T.
         Message("Choose ISC No. to Read")
       endif
     else
      rel_elem := rel_row := 1

      // Get Tenant's not yet assigned a complete isc's
      if len( aTCChoices := Get_Avail_Tcodes( aTCISC, cClusChoice,;
           substr( aISC[browse:rowPos, browse:colPos], 2, 2 ) ) ) > 0

         // Save first the screen to occupy for the menu.
         cBuffer := savescreen( AC_ROW1, AC_COL1, min( maxrow() -3, len(aTCChoices) + 1 + AC_ROW1 ) + 1, AC_COL2 + 2 )


         // Create box for choosing.
         @ AC_ROW1, AC_COL1, min( maxrow() -3, len(aTCChoices) + 1 + AC_ROW1 ), AC_COL2 Box B_SINGLE+" "
         Shadow( AC_ROW1, AC_COL1, min( maxrow() -3, len(aTCChoices) + 1 + AC_ROW1 ), AC_COL2 )
         aScroll2Bar:=ScrollBarNew(AC_ROW1,AC_COL2,min( maxrow() -3, len(aTCChoices) +1+ AC_ROW1 ),Setcolor(),1)
         ScrollBarDisplay(aScroll2Bar)
         ScrollBarUpdate(aScroll2Bar,1,Len(aTCChoices),.T.)
         // Prompt message.
         Message( CHOICE_PROMPT )
         // Get choice of tenant.
         do while .T.
           choice := achoice( AC_ROW1+1, AC_COL1 + 1, min( maxrow()-4, AC_ROW1 + len(aTCChoices) ),;
                              AC_COL2 - 1, aTCChoices,, 'KeyTest',  )
           if lastkey() == K_END
              exit
           endif
         enddo

         // Restore the box screen.
         restscreen( AC_ROW1, AC_COL1, min( maxrow() -3, len(aTCChoices) + 1 + AC_ROW1 ) + 1, AC_COL2 + 2, cBuffer )

         // Mark or Un-mark the cluster.
         aISC[browse:rowPos, browse:colPos] := " " + cTemp
         for i := 1 to len( aTCChoices )
           if substr( aTCChoices[i], 1, 1 ) == "*"
             aISC[browse:rowPos, browse:colPos] := MARKER + cTemp
             exit
           endif
         next i

      endif   // IF len( aTCChoices ....

     endif

     browse:refreshCurrent()  // Enable display of marked isc's.

    case key == K_ESC   // Done browsing
     exit
   endcase
 enddo // While browsing...

  if NagRead
     Message("Transferring Data files to Database")
     RepCon(nRChoice,alltrim(cClusChoice), XORZ )
  endif

  // Close files and restore screen, cursor and color.
  restscreen ( C_ROW1, C_COL1, C_ROW2 + 1, C_COL2 + 2, cWindBuff )
  setcursor ( nOldCursor )
  setcolor ( cOldColor )

return nil // end of brow.prg


function ArraySkip ( aLen, curPos, howMany )
/*
  General purpose array skipping function intended for with TBrowse
  b:skipBlocks. You must pass the curPos parameter by reference ( use the
  @ operator ) for this function to work correctly with TBrowse.
  ----> From "Clipper 5 A Developer's Guide".
*/

 local actual

 if howMany >= 0                 // Moving forward?
  if ( curPos + howMany ) > aLen // Can't go that far!
    actual := aLen - curPos      // Actual is whatever is left
    curPos := aLen               // Put pointer at end.
  else                           // Can move the whole distance...
    actual := howMany            // Actual is number requested.
    curPos += howMany            // Move pointer forward
  endif
 else                            // Moving backward ?
  if ( curPos + howMany ) < 1    // Can't go that far !
    actual := 1 - curPos         // Actual is whatever was left
    curPos := 1                  // Put pointer at the top
  else                           // Can move the whole distance...
    actual := howMany            // Actual is number requested
    curPos += howMany            // Move pointer backward
  endif
 endif
return actual


/* This function will delete the isc no. in the array of Tenants and ISC nos.
   for a particular tenant. Did you understand ? */
static function Delete_ISC( aTCISC, cTCode, cIscNo )
local i, nPos

 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set Index to ISCODE,ISCMAP
 endif
 ISCMAP->(DbGotop())
 ISCMAP->(DbSeek(cTCode))
 do while (ISCMAP->TCODE == cTCode) .and. (ISCMAP->(!Eof()))
   if (ISCMAP->ISC_NO == cISCNo)
      ISCMAP->(RecLock())
      replace ISCMAP->ISC_NO with "99"
      ISCMAP->(DbCommit())
      ISCMAP->(DbUnLock())
   endif
   ISCMAP->(DbSkip())
 enddo
 ISCMAP->(DbCloseArea())

 for i := 1 to len( aTCISC )
   // Look for the ISC no.  in the array.
   nPos := ascan( aTCISC[i][2], alltrim(cISCNo) )
   if  ( nPos > 0  ) .and. ( aTCISC[i][1] == cTcode )
     aTCISC[i][2] := adel( aTCISC[i][2], nPos )  // Delete.
     asize( aTCISC[i][2], len( aTCISC[i][2] ) - 1 )
     exit
   endif
 next i
return nil


/* This function will add an isc no. in the array of Tenants and ISC nos.
   for a particular tenant. Did you understand ? */
static function Add_ISC( aTCISC, cTcode, cIscNo )
local i, nPos

 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set Index to ISCODE,ISCMAP
 endif
 ISCMAP->(DbGotop())
 ISCMAP->(DbSeek(cTCode))
 do while (ISCMAP->TCODE == cTCode) .and. (ISCMAP->(!Eof()))
   if (ISCMAP->ISC_NO == "99" )
      ISCMAP->(RecLock())
      replace ISCMAP->ISC_NO with cISCNo
      ISCMAP->(DbCommit())
      ISCMAP->(DbUnLock())
      exit
   endif
   ISCMAP->(DbSkip())
 enddo
 ISCMAP->(DbCloseArea())

 for i := 1 to len( aTCISC )
   // Look for the tenant code in the array.
   if ( aTCISC[i][1] == cTcode )
    aadd( aTCISC[i][2], cISCNo ) // Then add the isc no. for that tenant code.
    exit
   endif
 next i
return nil

/* A user defined function for the achoice() in the selection of the Tenant
   Code for an ISC no. */
function KeyTest( nStatus, nCurrElem, nCurrRow )
local nKey := lastkey(), nRetVal := AC_CONT, i
 ScrollBarUpdate(aScroll2Bar,nCurrElem,len(aTCChoices),.F.)
 do case
     case nKey == asc("-")
       // Remove the isc in the array.
       // When it is only marked.
       if substr( aTCChoices[ nCurrElem  ], 1, 1 ) == "*"
          // Remove the isc in the corresponding tenant code.
          Delete_Isc( aTCISC, TCODE(nCurrElem), cTemp )
          // Remove the * marker.
          aTCChoices[ nCurrElem ] := " " + TCODE( nCurrElem )
       endif
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
     case nKey == asc("*")
       // Remove first the tenant marked.
       for i := 1 to len( aTCChoices  )
          if substr( aTCChoices[i], 1, 1 ) == "*"
            // Remove the marker.
            aTCChoices[ i ] := " " + TCODE( i )
            // Remove it in the array.
            Delete_Isc( aTCISC, TCODE(i), cTemp )
            exit
          endif
       next i
       // Add to the corresponding tenant code.
       Add_Isc( aTCISC, TCODE( nCurrElem ), cTemp )
       // Mark the chosen tenant.
       aTCChoices[ nCurrElem ] := "*" + alltrim( TCODE( nCurrElem ) )
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
     case nKey == K_ESC .OR. nKey == K_END
       nRetVal := AC_ABORT
  endcase
return nRetVal

/*-*-*-*-*-*-*-*-*-End of File-*-*-*-*-*-*-*-*/

