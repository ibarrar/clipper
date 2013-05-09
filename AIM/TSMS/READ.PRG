#include "fileio.ch"
#include "inkey.ch"
#include "box.ch"
#include "achoice.ch"
#include "Janus.ch"

#define  C_BLOCK  140
#define  MY_COLOR "GR+/B,W+/N+"

#define SL_ROW  23
#define SL_COL1 1
#define SL_COL2 78

// For the type of reading coordinates.
#define  T_ROW1 4
#define  T_COL1 30
#define  T_ROW2 8
#define  T_COL2 45

#define X_ROW1  (T_ROW1+nRChoice)
#define X_COL1  (T_COL1+6)
#define X_ROW2  (T_ROW1+nRChoice+3)
#define X_COL2  (X_COL1+17) //(46-62)

// For the cluster menu.
#define CL_ROW1 7
#define CL_COL1 28
#define CL_COL2 37

static aClusterChoices:={}, aMain :=  {}, rel_elem, rel_row, nChoice
static aScrollBar

function read(nMode)
local aPos := { " Terminal   ",;
                " Department ",;
                " PLU        ",;
                " Hourly     ",;
                " Cashier    "}
local color
local cBuffer := savescreen ( T_ROW1-1, T_COL1-1, T_ROW2+2, T_COL2 + 2 )
local cBuff, wMode, xMode := {"X","Z"}
local aMode := {" X-Mode Reading ",;
                " Z-Mode Reading "}
static x := 1, nRChoice := 1

 color := setcolor(MY_COLOR)

 cBuff := savescreen( maxrow()-1, 0, maxrow()-1, maxcol() )
 Message( "Pick the Type of Reading" )

 @ T_ROW1-1, T_COL1-1, T_ROW2+1, T_COL2+1 Box B_DOUBLE+" "
 shadow(T_ROW1-1, T_COL1-1, T_ROW2+1, T_COL2+1)

 // Menu for choosing type of reading.
 do while  ( ( nRChoice := aChoice(T_ROW1, T_COL1, T_ROW2, T_COL2,aPos,,,nRChoice)) > 0)
  wMode := savescreen( X_ROW1, X_COL1, X_ROW2+1, X_COL2+1 )
  Message( "Pick the Type of Reading" )
  @ X_ROW1, X_COL1, X_ROW2, X_COL2 Box B_SINGLE+" "
  shadow(X_ROW1, X_COL1, X_ROW2, X_COL2)
  do while ( ( x := aChoice(X_ROW1+1, X_COL1+1, X_ROW2-1, X_COL2-1,aMode,,,x)) > 0)
    if (x == 2)
     tone(200,3)
     Message("Warning: Z-Reading will zero out all data on this report...")
     if (alert("Will Reset counters..., Are you sure ?",{"  Yes  ","  No  "} )  != 1 )
      exit
     endif
    endif
    if (!ReadPOS ( nMode, nRChoice, xMode[x] ))
     exit
    endif
    Message( "Pick the Type of Reading" )
  enddo
  restscreen(X_ROW1, X_COL1, X_ROW2+1, X_COL2+1,wMode)
 enddo
 restscreen( maxrow()-1, 0, maxrow()-1, maxcol(), cBuff )

 //  Restore parameters changed.
 restscreen( T_ROW1-1, T_COL1-1, T_ROW2 + 2, T_COL2 + 2, cBuffer )
 setcolor(color)
return nil


/* Individual or Configuration reading with a specified type of reports
   is done in this function */
function readPos ( nMode, nRChoice, XORZ )
local cLineSave
local nHandle, aCCode := {}, aISCnum := {}, i, cISCNo, aSungot := {}
local cBuffer := space (C_BLOCK), aISCStat:={}
local cClus,x

 //  Use the assignment file.
 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set index to ISCODE,ISCMAP
 endif

 // Check for an existence of the configuration file.
 if ( lastrec() < 1 )
   alert ("Configuration file does not exist. Configure first.")
   return .F.    // not my type rci. this is not "c"
 endif

 // Resize the main array and cluster choices.
 asize( aMain, 0 )
 asize( aClusterChoices, 0 )

 ISCMAP->(DbGotop())
 do while ISCMAP->(!EOF())
   if aScan( aCCode , ISCMAP->CLUSTER ) == 0
     aadd ( aCCode, ISCMAP->CLUSTER)     // For achoice() to process.
     aadd ( aClusterChoices, padr ( padl( ISCMAP->CLUSTER, 5, " " ), 8, " ") )
   endif
   ISCMAP->(DBSkip())
 enddo

 //now the isc's
 for x:=1 to len(aCCode)
   ISCMAP->(DbGotop())
   aSize(aSungot,0)
   do while ISCMAP->(!EOF())
    if( aCCode[x] == ISCMAP->CLUSTER ) .and. ISCMAP->ISC_NO!="99"
       aAdd(aSungot, ISCMAP->ISC_NO)
    endif
    ISCMAP->(DbSkip())
   enddo
   aAdd(aMain,{aCCode[x],aclone(aSungot)})
 next x

 // Close the assignment file and reselect work area.
 ISCMAP->(DbCloseArea())

 asort( aClusterChoices,,, { |a,b| a < b } ) // Sort.
 asort( aMain,,, { |a,b| a[1] < b[1] } )     // Sort.

 // Create box for choosing cluster codes.
 cBuffer := savescreen ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices),;
                         maxrow()-4 ) + 2, CL_COL2 + 2 )
 @ CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1,;
          CL_COL2 Box  B_SINGLE_DOUBLE+" "
 @ CL_ROW1, CL_COL1 + 1 SAY "CLUSTER"
 shadow ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1, CL_COL2 )
 aScrollBar:=ScrollBarNew(CL_ROW1,CL_COL2,min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1,;
             setcolor(),1)
 ScrollBArDisplay(aScrollBar)
 ScrollBarUpdate(aScrollBar,1,len(aClusterChoices),.T.)

 cLineSave := savescreen ( SL_ROW, SL_COL1, SL_ROW, SL_COL2 )  // Save Status line

 Message ( "Choose Cluster Code to Read, <ESC> to Convert")
 rel_elem := rel_row := 1
 do while .T.   // Loop for reading a cluster.
   do while .T. // Loop for achoice.
     achoice( CL_ROW1 + 1, CL_COL1 + 1, min( CL_ROW1 + len( aClusterChoices ), maxrow()-4 ),;
              CL_COL2 - 1, aClusterChoices,,'KeyHandler', rel_elem, rel_row )
     if lastkey() == K_ENTER .OR. lastkey() == K_ESC
       exit
     endif
   enddo

   // Check to see if Esc was pressed.
   if ( nChoice == 0 )
     exit
   endif

  if ( nMode == 1 )
    // If individual reading only.

    Message( "Choose ISC No. to Read")
    // Initialize arrays.
    asize( aISCStat, 64 )
    afill( aISCStat, .F. )

    // Set isc nos. configured in the cluster
    for i := 1 to len( aMain[nChoice, 2] )
     aISCStat[ val ( aMain[nChoice, 2][i] ) + 1 ] := .T.
    next i

    // Read individually.
    Message( "Choose ISC No. to Read")
    ArrayBrow ( aISCStat, GetModelName( aClusterChoices[nChoice] ), .T.,;
                nRChoice, aClusterChoices[nChoice], XORZ )
  else
    asort( aMain[nChoice,2],,,{ |a,b| a < b } )     // Sort.
    Message( "Configuration Reading Going on...")
    // Read in configuration mode.
    do case
       case nRChoice == 1 // Terminal
        for i := 1 to len( aMain [nChoice, 2] )
             Terminal_Read ( aMain[nChoice, 2][i], aClusterChoices[nChoice], XORZ )
        next i
        Message(" Transferring Terminal Reports to Database files...")
        RepCon(1,alltrim(aClusterChoices[nChoice]),XORZ)
      case nRChoice == 2 // Department
        for i := 1 to len( aMain [nChoice, 2] )
             Department_Read ( aMain[nChoice, 2][i], aClusterChoices[nChoice], XORZ)
        next  i
        Message(" Transferring Department Reports to Database files...")
        RepCon(2,alltrim(aClusterChoices[nChoice]),XORZ)
      case nRChoice == 3 //PLU
        for i := 1 to len( aMain [nChoice, 2] )
             PLU_SDP_Read ( aMain[nChoice, 2][i], aClusterChoices[nChoice], XORZ)
        next i
        Message(" Transferring PLU Reports to Database files...")
        RepCon(3,alltrim(aClusterChoices[nChoice]),XORZ)
      case nRChoice == 4 // Hourly
        for i := 1 to len( aMain [nChoice, 2] )
             Hourly_Read ( aMain[nChoice, 2][i], aClusterChoices[nChoice], XORZ)
        next i
        Message(" Transferring Hourly Reports to Database files...")
        RepCon(4,alltrim(aClusterChoices[nChoice]),XORZ)
      case nRChoice == 5 //CAshier
        for i := 1 to len( aMain [nChoice, 2] )
             Cashier_Read ( aMain[nChoice, 2][i], aClusterChoices[nChoice], XORZ)
        next i
        Message(" Transferring PLU Reports to Database files...")
        RepCon(5,alltrim(aClusterChoices[nChoice]),XORZ)
    endcase
    Message(" Done. ")
  endif
  Message ( "Choose Cluster Code to Read, <ESC> to Abort")
 enddo
 restscreen ( SL_ROW, SL_COL1, SL_ROW, SL_COL2, cLineSave ) // Restore Status line

 do case
    case nRChoice == 1
    Tr_Dat(XORZ)
    case nRChoice == 2
    Dp_Dat(XORZ)
    case nRchoice == 4
    Hr_Dat(XORZ)
 end case


 // Restore screen.
 restscreen ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 2, CL_COL2 + 2, cBuffer)

return .T.

/* Just to disable the abort process when left and right arrow keys
   were pressed. */
function KeyHandler( nStatus, nCurrElem, nCurrRow )
local nKey := lastkey(), nRetVal := AC_CONT, i
 ScrollBarUpdate(aScrollBar,nCurrElem,len(aClusterChoices),.F.)
 do case
    case nKey == K_LEFT
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_RIGHT
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_END
       rel_elem := len( aClusterChoices )
       nRetVal := AC_ABORT
    case nKey == K_HOME
       rel_elem := 1
       nRetVal := AC_ABORT
    case nKey == K_ENTER
       nChoice := nCurrElem
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_ESC
       nChoice := 0
       nRetVal := AC_ABORT
 endcase
return nRetVal

function GetModelName(cClustch)
local x,cModel
   x := val(substr(allTrim(cClustch),1,1))
   do case
      case x == 1
        cModel := " RS 34-60 "
      case x == 2
        cModel := " RS 35-10 "
      case x == 3
        cModel := " RS 45-40 "
      case x == 4
       cModel := " RS 55-50 "
    endcase
return cModel

/*-*-*-*-*-*-*-Eof (READ.prg)-*-*-*-*-*/
