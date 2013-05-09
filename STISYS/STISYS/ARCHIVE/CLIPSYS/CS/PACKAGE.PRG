// Filename:      PACK_CST.PRG
// System-Name:   Super Travel Costing Software
// Module:        Package Costing Module
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Sept 23, 1993
// Last-Update:   Sept 23, 1993

#include "Mode.Ch"
#include "inkey.Ch"
#include "SetCurs.Ch"
#include "MemoEdit.Ch"
#include "Printer.Ch"
#include "c501_mod.ch"

#define BAR_1 "F1-Help   F2-Add    F3-Edit    F4-Delete    F5-Search    F6-Local    ESC-Abort"
#define BAR_2 "F1-Help  F3-Edit  F4-Delete  F6-Global  F7-Air Trff  F8-Land Trff  ESC-Abort"
#define AMT_PIC    "99999.99"

static _Label, _Valid1, _Valid2, _aSti, _aMisc, _aAc, lPrint
static aTotal1, aTotal2, aTotal3, aEntries

function Do_Pkg()
local wCost, nKey
private cLabel := space(12), cEffDate:= space(7), cDir := 'F', cHotel := space(3)
private nEditRow := nTopPage :=  nIndex := nPane := 1
    setcolor( DATA_COLORS )
    Message("Opening Databases...")
    use COST_PKG new
    use COST_PKL index COST_PKL new
    wCost :=OpenWindow( 03, 02, 21, 77, "Package Costing" )
    if lastkey()!=K_ESC
      do while ( nKey!=K_ESC )
         Pkg_Screen( VIEW_MODE )
         Message( BAR_1 )
         nKey := inkey(0)
         do case
            case nKey == K_DOWN
               COST_PKG->( dbskip() )
               if COST_PKG->( eof() )
                  COST_PKG->( dbgobottom() )
                  tone( 200,1 )
                  Message( "End of file reached...." )
                  inkey(1)
               endif
            case nKey == K_UP
               COST_PKG->( dbskip(-1) )
               if COST_PKG->( bof() )
                  COST_PKG->( dbgotop() )
                  tone( 200,1 )
                  Message( "Beginning of file reached...." )
                  inkey(1)
               endif
            case nKey == K_CTRL_PGDN
               COST_PKG->( dbskip(NUM_TO_SKIP) )
               if COST_PKG->( eof() )
                  COST_PKG->( dbgobottom() )
                  tone( 200,1 )
                  Message( "End of file reached...." )
                  inkey(1)
               endif
            case nKey == K_CTRL_PGUP
               COST_PKG->( dbskip(-NUM_TO_SKIP) )
               if COST_PKG->( bof() )
                  COST_PKG->( dbgotop() )
                  tone( 200,1 )
                  Message( "Beginning of file reached...." )
                  inkey(1)
               endif
            case nKey == K_END
               COST_PKG->( dbgobottom() )
               Message( "Moving to end of file...." )
               inkey(1)
            case nKey == K_HOME
               COST_PKG->( dbgotop() )
               Message( "Moving to beginning of file...." )
               inkey(1)
            case nKey == K_F1
               HelpMe1()
            case nKey == K_F2
               Message( "Press ENTER to add new record." )
               if inkey(0) == K_ENTER
                  Pkg_Screen( APPEND_MODE )
               endif
            case nKey == K_F3
               Pkg_Screen( EDIT_MODE )
            case nKey == K_F4
               Message( "Press ENTER to delete record, ESC to abort." )
               if inkey(0) == K_ENTER
                  Message( "Deleting current record...." )
                  COST_PKL->( dbseek( COST_PKG->Link ) )
                  do while COST_PKG->Link == COST_PKL->Link
                     COST_PKL->( dbdelete() )
                     COST_PKL->( dbskip() )
                  enddo
                  COST_PKG->( DbDelete() )
                  COST_PKG->(DbGoto( COST_PKG->( RecNo()) ))
               endif
             case nKey == K_F5
               COST_PKG->( Search() )
             case nKey == K_CTRL_S
               COST_PKG->( Find() )
             case nKey == K_F6
               COST_PKL->( Components() )
             case nKey = K_CTRL_LEFT
               nPane -= if( nPane > 1, 1, 0 )
             case nKey = K_CTRL_RIGHT
               nPane += if( nPane < 3, 1, 0 )
         endcase
      enddo
    endif
    CloseWindow( wCost )
    Message("Closing Databases...")
    select COST_PKL
    pack
    COST_PKL->( dbclosearea() )
    select COST_PKG
    pack
    COST_PKG->( dbclosearea() )
return nil

static function Pkg_Screen( nMode )
local clr, crs, i
    tone( 300,1 )
    clr := setcolor("n/bg")
    if COST_PKG->(deleted())    ;   @ 03, 36 say "<deleted>"
    else   ;   @ 03, 36 say "         "   ;  endif
    if nMode==APPEND_MODE
       @ 03, 68 say "< New >   "
    else
       @ 03, 68 say "Rec #"+transform(COST_PKG->(RecNo()),"9999")
    endif
    setcolor( clr )
    PkgInit( nMode )
    ShowTotals()
    ShowPage()
    @ 05,      04 say repl('-',72)
    @ 08,      04 say repl('-',72)
    @ 13,      04 say repl('-',72)
    @ row()+1, 04 say "Sub Total"
    @ row()+2, 04 say "Miscell. "
    @ row()+1, 04 say "STI      "
    @ row()+1, 04 say "AC       "
    @ row()+2, 04 say "Total    "
    @ 07,      04 say "Agent  Loc"
    @ 04,    04       say "LABEL:"    get _Label pict "@!"
    @ row(), col()+10 say "Validity:" get _Valid1 pict "99!!!99"
    @ row(), col()    say " to "      get _Valid2 pict "99!!!99"
    if nPane == 1
       for i := 1 to 7
           @ 16, ((i-1)*9) + 14 get _aMisc[i]  pict AMT_PIC
           @ 17, ((i-1)*9) + 14 get _aSti[i]   pict AMT_PIC
           @ 18, ((i-1)*9) + 14 get _aAc[i]    pict repl('x',8)
           @ 20, ((i-1)*9) + 14 get aTotal2[i] pict AMT_PIC
       next
    elseif nPane == 2
       for i := 8 to 14
           @ 16, ((i-8)*9) + 14 get _aMisc[i]  pict AMT_PIC
           @ 17, ((i-8)*9) + 14 get _aSti[i]   pict AMT_PIC
           @ 18, ((i-8)*9) + 14 get _aAc[i]    pict repl('x',8)
           @ 20, ((i-8)*9) + 14 get aTotal2[i] pict AMT_PIC
       next
    else
           @ 16, 14 clear to 18,75
           @ 20, 14 clear to 20,75
           @ 16, 14 get _aMisc[15]  pict AMT_PIC
           @ 17, 14 get _aSti[15]   pict AMT_PIC
           @ 18, 14 get _aAc[15]    pict repl('x',8)
           @ 20, 14 get aTotal2[15] pict AMT_PIC
    endif
    if nMode == VIEW_MODE
       clear gets
    else
       aTemp1 := aClone(_aSti)
       aTemp2 := aClone(aTotal2)
       crs := setcursor( SC_NORMAL )
       read
       for i := 1 to 15
          if aTemp1[i] != _aSti[i]    ;  StiToTotal(i)  ;  endif
       next
       for i := 1 to 15
          if aTemp2[i] != aTotal2[i]  ;  TotalToSti(i)  ;  endif
       next
       if LastKey()!=K_ESC
           Pkg_Save( nMode )
       endif
       SetCursor( crs )
    endif
return nil

static function PkgInit( nMode )
  /* ----------------------------------------- */
  /* Free memory allocations for static arrays */
  /* ----------------------------------------- */
  _aSti    := {}
  _aAc     := {}
  _aMisc   := {}
  aEntries := {}
  if nMode==APPEND_MODE
     _Label  := space(20)
     _Valid1 := space(7)
     _Valid2 := space(7)
     _aMisc  := afill( array(15), 0 )
     _aSti   := afill( array(15), 0 )
     _aAc    := afill( array(15), space(8))
  else
     _Label  := COST_PKG->Label
     _Valid1 := DtoE( COST_PKG->Valid_From )
     _Valid2 := DtoE( COST_PKG->Valid_To   )
     for x := 1 to 15
           aadd( _aMisc, COST_PKG->( fieldget(x+1)  ) )
           aadd( _aSti,  COST_PKG->( fieldget(x+16) ) )
           aadd( _aAc,   COST_PKG->( fieldget(x+31) ) )
     next
     for x:=1 to len(_aAc)
        _aAc[x] := padl( alltrim(_aAc[x]), 8 )
     next
     aEntries := LocalArray(aEntries)
  endif
  CompTotals(0)
return nil

static function Pkg_Save( nMode )
local i, cLink
      if nMode == APPEND_MODE
         cLink := chr( val( dtoc(date()) ) +64) + ;
                  chr( val( substr( dtoc(date()),4) ) +64) + ;
                  chr( val( substr( dtoc(date()),7) ) +64) + ;
                  chr( val( time() ) +64) + ;
                  chr( val( substr( time(),4) ) +64) + ;
                  chr( val( substr( time(),7) ) +64)
         COST_PKG->( dbappend() )
         COST_PKG->Link := cLink
      endif
      COST_PKG->Label := _Label
      COST_PKG->Valid_From := EtoD( _Valid1 )
      COST_PKG->Valid_To   := EtoD( _Valid2 )
      for i := 1 to 15
        COST_PKG->( fieldput( i+ 1, _aMisc[i] ))
        COST_PKG->( fieldput( i+16, _aSti[i]  ))
        COST_PKG->( fieldput( i+31, _aAC[i]   ))
      next
      COST_PKG->(dbcommit())
return nil

static function CompTotals( nMode )
local i, j
    aTotal1 := {} ; aTotal2 := {}
    aTotal1 := afill( array(15),0 )
    aTotal2 := afill( array(15),0 )
    for i := 1 to if( nMode==0,len(aEntries),nMode )
        for j := 1 to 15
            aTotal1[j] += aEntries[i][j]
        next
    next
    for i := 1 to 15
       StiToTotal(i)
    next
return nil

static function ShowTotals()
local i
    if nPane == 1
       @ 06, 15 say "ÚÄÄÄÄÄ Adult ÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄ Child ÄÄÄÄÄÄÄÄ¿  Sglb   XN+ABF "
       @ 07, 15 say "HTwnb      XBed     HTwnb    XBed     Nobed    Supp   HTwnb  "
       for i := 1 to 7
           @ 14, ((i-1)*9) + 14 get aTotal1[i] pict AMT_PIC
           @ 20, ((i-1)*9) + 14 get aTotal2[i] pict AMT_PIC
       next
    elseif nPane == 2
       @ 06, 15 say "ÚÄÄÄ Xn+ABF ÄÄÄÄ¿ ÚÄÄÄÄ 3d2n Deduction ÄÄÄÄ¿ Hotel           "
       @ 07, 15 say "Sglb     XBed     Htwnb    Sglb    Xbed      ABF     Land    "
       for i := 8 to 14
           @ 14, ((i-8)*9) + 14 get aTotal1[i] pict AMT_PIC
           @ 20, ((i-8)*9) + 14 get aTotal2[i] pict AMT_PIC
       next
    else
       @ 06, 15 say "  Room                                                       "
       @ 07, 15 say "  Twnb                                                       "
       @ 14, 14 clear to 14,75
       @ 20, 14 clear to 20,75
       @ 14, 14 get aTotal1[15] pict AMT_PIC
       @ 20, 14 get aTotal2[15] pict AMT_PIC
    endif
    clear gets
return nil

static function StiToTotal(n)
    if at('%',_aAc[n]) # 0
      u := val(_aAc[n])
      aTotal2[n]:=(aTotal1[n] + _aSti[n] + _aMisc[n]) / (1 - (u/100))
    else
      aTotal2[n]:= aTotal1[n] + _aSti[n] + _aMisc[n] + val(_aAc[n])
    endif
return nil

static function TotalToSti(n)
    if at('%',_aAc[n]) # 0
       u := val(_aAc[n])
       _aSti[n]:= (aTotal2[n] * (1 - (u/100))) - aTotal1[n] - _aMisc[n]
    else
       _aSti[n]:= aTotal2[n] - _aMisc[n] - val(_aAc[n]) - aTotal1[n]
    endif
return nil

static function LocalArray(aItems)
     asize(aItems,0)
     COST_PKL->( dbseek(COST_PKG->Link) )
     do while !eof() .and. (COST_PKL->Link == COST_PKG->Link )
        aadd( aItems,{ COST_PKL->adt_twnb,  COST_PKL->adt_xtrb,;
                         COST_PKL->chd_twnb,  COST_PKL->chd_xtrb,;
                         COST_PKL->chd_nob,   COST_PKL->sglb_supp,;
                         COST_PKL->xn_twnb,   COST_PKL->xn_sglb,;
                         COST_PKL->xn_xtrb,   COST_PKL->twnb_3d2n,;
                         COST_PKL->sglb_3d2n, COST_PKL->xbed_3d2n,;
                         COST_PKL->hotel_abf, COST_PKL->land,;
                         COST_PKL->rm_twnb,   COST_PKL->loc_type,;
                         COST_PKL->agent,     COST_PKL->( recno() ) })
        COST_PKL->( dbskip() )
     enddo
     aadd( aItems,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,' ',space(7),0} )
return aItems

static function Components()
local wBrowse, aScrollbar, nKey, clr
    aScrollbar := ScrollBarNew( 08,77,13,"N/W",1 )
    ScrollBarDisplay( aScrollBar )
    ShowPage()
    do while nKey != K_F6
       nIndex := nTopPage + nEditRow -1
       ScrollBarUpdate( aScrollBar,nTopPage + nEditRow - 1,len(aEntries),.T. )
       clr := setcolor( "n/bg" )
       if nTopPage + nEditRow-1 = len(aEntries)
          @ 03,68 say "<New>     "
       else
          @ 03,68 say "Rec #"+transform(nIndex,"9999")
       endif
       setcolor( clr )
       Message( BAR_2 )
       CompTotals( nTopPage + nEditRow -1 )
       ShowTotals()
       Toggle( .T. )
       nKey = inkey(0)
       Toggle( .F. )
       do case
          case nKey == K_DOWN
              if nEditRow = 4
                 if nTopPage+2 < len(aEntries) -1
                    nTopPage ++
                    ShowPage()
                 endif
              else
                 if nTopPage + (nEditRow-1) <= len(aEntries) -1
                    nEditRow ++
                 endif
              endif
          case nKey == K_UP
              if nEditRow = 1
                 if nTopPage > 1
                    nTopPage --
                    ShowPage()
                 endif
              else
                 nEditRow --
              endif
          case nKey == K_PGDN
              if nTopPage + 8 < len(aEntries) -1
                 nTopPage += 3
              else
                 if len(aEntries) -1 > 3
                    nTopPage := len(aEntries) -1 -3
                    nEditRow := 4
                 else
                    nTopPage := 1
                    nEditRow := len(aEntries) -1
                 endif
              endif
              ShowPage()
          case nKey == K_PGUP
              if nTopPage - 3 > 0
                 nTopPage -= 3
              else
                 nTopPage := 1
                 nEditRow := 1
              endif
              ShowPage()
          case nKey == K_HOME
              nEditRow := 1
          case nKey == K_END
              nEditRow := if(len(aEntries)>4,4,len(aEntries))
          case nKey == K_CTRL_PGUP
              nTopPage := 1
              nEditRow := 1
              ShowPage()
          case nKey == K_CTRL_PGDN
              if len(aEntries) -1 > 3
                 nTopPage := len(aEntries) -1 -2
                 nEditRow := 4
              else
                 nTopPage := 1
                 nEditRow := len(aEntries) -1 +1
              endif
              ShowPage()
          case nKey == K_CTRL_LEFT
               if ( nPane >1, nPane--, nPane := 3 )
               Pkg_Screen(VIEW_MODE)
          case nKey == K_CTRL_RIGHT
               if ( nPane <3, nPane++, nPane := 1 )
               Pkg_Screen(VIEW_MODE)
          case nKey == K_F1
               HelpMe2()
/*          case nKey == K_F3
               EditRec()
               ShowPage()
*/
          case nKey == K_F4
               DelRec()
               nTopPage := nEditRow := 1
               Pkg_Screen(VIEW_MODE)
          case nKey == K_F7
               GetAir()
               nTopPage := nEditRow := 1
               Pkg_Screen(VIEW_MODE)
          case nKey == K_F8
               GetLand()
               nTopPage := nEditRow := 1
               Pkg_Screen(VIEW_MODE)
       endcase
    enddo
    nTopPage := nEditRow := 1
return nil

static function ShowPage()
local i
    for i := nTopPage to nTopPage + 3
       @ i - nTopPage + 9, 10 say ""
       if i <= len(aEntries) -1
          nIndex := i
          ShowLine(row())
       else
          @ row(), 03 say space(77-04)
       endif
    next
return nil

static function Toggle( lToggle )
local clr := setcolor()
    nIndex := nTopPage + (nEditRow -1)
    if lToggle
       set color to
    endif
    ShowLine( nEditRow -1 + 9 )
    setcolor( clr )
return nil

static function ShowLine( r )
local  i, cString
    if nIndex < len(aEntries)
       cString := substr(aEntries[ nIndex ][ 17 ],1,7) + ;
                    " " + aEntries[ nIndex ][ 16 ]
       if nPane < 3
          for i := if(nPane==1,1,8) to if(nPane==1,7,14)
              cString += " "+transform(aEntries[ nIndex ][ i ],"99999.99")
          next
       else
          cString += " "+transform(aEntries[ nIndex ][ 15 ],"99999.99")
       endif
       @ r, 04 say padr(cString,72)
    else
       @ r, 04 say space(72)
    endif
return nil

static function EditRec()
local i, crs
    if nIndex != len(aEntries)
        @ nEditRow -1 +9, 04    get aEntries[ nIndex ][ 16 ] pict "!!!!!!!"
        @ row(),   col() say "" get aEntries[ nIndex ][ 15 ] pict "!"
        do case
           case nPane == 1
             for i := 1 to 7
             @ row(), col() say "" get aEntries[ nIndex ][ i ] ;
                 pict "99999.99"
             next
           case nPane == 2
             for i := 8 to 14
             @ row(), col() say "" get aEntries[ nIndex ][ i ] ;
                 pict "99999.99"
             next
           otherwise
             @ row(), col() say "" get aEntries[ nIndex ][ 15 ] ;
                 pict "99999.99"
        endcase
        crs := setcursor( SC_NORMAL )
        read
        setcursor( crs )
        if lastkey()!=K_ESC
           dbgoto( aEntries[ nIndex ][ 18 ] )
           replace agent    with aEntries[ nIndex ][ 17 ]
           replace loc_type with aEntries[ nIndex ][ 16 ]
           if nPane == 1
                 replace adt_twnb  with aEntries[ nIndex ][ 1 ]
                 replace adt_xtrb  with aEntries[ nIndex ][ 2 ]
                 replace chd_twnb  with aEntries[ nIndex ][ 3 ]
                 replace chd_xtrb  with aEntries[ nIndex ][ 4 ]
                 replace chd_nob   with aEntries[ nIndex ][ 5 ]
                 replace sglb_supp with aEntries[ nIndex ][ 6 ]
                 replace xn_twnb   with aEntries[ nIndex ][ 7 ]
           elseif nPane == 2
                 replace xn_sglb   with aEntries[ nIndex ][ 8 ]
                 replace xn_xtrb   with aEntries[ nIndex ][ 9 ]
                 replace twnb_3d2n with aEntries[ nIndex ][ 10 ]
                 replace sglb_3d2n with aEntries[ nIndex ][ 11 ]
                 replace xbed_3d2n with aEntries[ nIndex ][ 12 ]
                 replace hotel_abf with aEntries[ nIndex ][ 13 ]
                 replace land      with aEntries[ nIndex ][ 14 ]
           else
                 replace rm_twnb   with aEntries[ nIndex ][ 15 ]
           endif
           dbcommit()
        endif
    endif
return nil

static function DelRec()
    if nIndex != len(aEntries)
        Toggle( .T. )
        dbgoto( aEntries[ nIndex ][ 18 ] )
        Message("Press any key to delete, ESC to abort...")
        inkey(0)
        if lastkey()!=K_ESC
           Message("Deleting Record#"+transform(COST_PKL->(recno()),"9999"))
           dbdelete()
           pack
           tone(300,1)
           Message("Deleted...")
           inkey(2)
        endif
    endif
return nil

static function GetLand()
local n
    use LAND new
    Message("Searching recent land tariffs...")
    set filter to (;
       ( LAND->eff_from <= COST_PKG->valid_from)  .and. ;
       ( if(empty(LAND->eff_till),LAND->eff_to,LAND->eff_till)  >= COST_PKG->valid_to)  .and.;
       ( city $ COST_PKG->label) )
    n := Do_Land(.T.)
    if lastkey()!= K_ESC  .and. ( (n>0) .and. (n<=lastrec()) )
         dbgoto(n)
         aDummy := array(7)
         aDummy[ 1 ] := LAND->sglb_4d3na
         aDummy[ 2 ] := LAND->htwn_4d3na
         aDummy[ 3 ] := LAND->rm_twn
         aDummy[ 4 ] := LAND->htwn_3d2n
         aDummy[ 5 ] := LAND->sglb_3d2n
         aDummy[ 6 ] := LAND->xtrb_4d3na
         aDummy[ 7 ] := LAND->xtrb_3d2n
         COST_PKL->(dbappend())
         COST_PKL->Link      := COST_PKG->Link
         COST_PKL->effective := LAND->eff_from
         COST_PKL->loc_type  := 'L'
         COST_PKL->agent     := rtrim(LAND->hotel) + '-' + rtrim(LAND->AGENCY)
         COST_PKL->adt_twnb  := LAND->htwn_4d3na
         COST_PKL->adt_xtrb  := LAND->xtrb_4d3na
         COST_PKL->chd_twnb  := LAND->htwn_4d3nc
         COST_PKL->chd_xtrb  := LAND->xtrb_4d3nc
         COST_PKL->chd_nob   := LAND->nob_4d3nc
         COST_PKL->sglb_supp := aDummy[ 1 ] - aDummy[ 2 ]
         COST_PKL->xn_twnb   := LAND->xn_htwn
         COST_PKL->xn_sglb   := LAND->xn_sglb
         COST_PKL->xn_xtrb   := LAND->xn_xtrb
         COST_PKL->twnb_3d2n := aDummy[ 2 ] - aDummy[ 4 ]
         COST_PKL->sglb_3d2n := aDummy[ 1 ] - aDummy[ 5 ]
         COST_PKL->xbed_3d2n := aDummy[ 6 ] - aDummy[ 7 ]
         COST_PKL->hotel_abf := LAND->hotel_abf
         COST_PKL->land      := LAND->htwn_4d3na
         COST_PKL->rm_twnb   := LAND->rm_twn
         if !empty(LAND->currency) .and. get_usd(LAND->currency)
              COST_PKL->adt_twnb  := tousd(COST_PKL->adt_twnb )
              COST_PKL->adt_xtrb  := tousd(COST_PKL->adt_xtrb )
              COST_PKL->chd_twnb  := tousd(COST_PKL->chd_twnb )
              COST_PKL->chd_xtrb  := tousd(COST_PKL->chd_xtrb )
              COST_PKL->chd_nob   := tousd(COST_PKL->chd_nob  )
              COST_PKL->sglb_supp := tousd(COST_PKL->sglb_supp )
              COST_PKL->xn_twnb   := tousd(COST_PKL->xn_twnb  )
              COST_PKL->xn_sglb   := tousd(COST_PKL->xn_sglb  )
              COST_PKL->xn_xtrb   := tousd(COST_PKL->xn_xtrb  )
              COST_PKL->twnb_3d2n := tousd(COST_PKL->twnb_3d2n)
              COST_PKL->sglb_3d2n := tousd(COST_PKL->sglb_3d2n)
              COST_PKL->xbed_3d2n := tousd(COST_PKL->xbed_3d2n)
              COST_PKL->hotel_abf := tousd(COST_PKL->hotel_abf)
              COST_PKL->land      := tousd(COST_PKL->land     )
              COST_PKL->rm_twnb   := tousd(COST_PKL->rm_twnb  )
         endif
         COST_PKL->(dbcommit())
    endif
    select COST_PKL
return nil

static function GetAir()
local n
    use AIR new
    Message("Searching recent air tariffs...")
    set filter to (empty(eff_to) .or. ( eff_to >= COST_PKG->valid_from) );
        .and.  ( route $ COST_PKG->label)
    n := do_air(.T.)
    if lastkey()!= K_ESC  .and. ( (n>0) .and. (n<=lastrec()) )
         dbgoto(n)
         COST_PKL->(dbappend())
         COST_PKL->Link      := COST_PKG->Link
         COST_PKL->effective := AIR->eff_from
         COST_PKL->loc_type  := 'A'
         COST_PKL->agent     := AIR->airline
         COST_PKL->adt_twnb  := AIR->adult
         COST_PKL->adt_xtrb  := AIR->adult
         COST_PKL->chd_twnb  := AIR->child
         COST_PKL->chd_xtrb  := AIR->child
         COST_PKL->chd_nob   := AIR->child
         COST_PKL->(dbcommit())
    endif
    close air
    select COST_PKL
return nil

static function helpme1()
    wHelp := OpenWindow( 04,20,22,60,"Help Window" )
    @ 06,     22 say "ARROW UP/DN - Previous/Next Record."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Record."
    @ row()+1,22 say "HOME        - First Record on File."
    @ row()+1,22 say "END         - Last Record on File."
    @ row()+1,22 say "CTRL PGUP   - Skip Last 20 Records."
    @ row()+1,22 say "CTRL PGDN   - Skip Next 20 Records."
    @ row()+1,22 say "CTRL LEFT   - 1st Group of Columns."
    @ row()+1,22 say "CTRL RIGHT  - 2nd Group of Columns."
    @ row()+1,22 say "F1          - Help!."
    @ row()+1,22 say "F2          - Add Record."
    @ row()+1,22 say "F3          - Edit Record."
    @ row()+1,22 say "F4          - Delete Record."
    @ row()+1,22 say "F5          - Search Record."
    @ row()+1,22 say "F5          (CTRL-S to repeat search)"
    @ row()+1,22 say "F6          - Local Control."
    @ row()+1,22 say "ESC         - Exit Room Costing."
    Message("Press any key...")
    inkey(0)
    CloseWindow( wHelp )
return nil

static function helpme2()
    wHelp := OpenWindow( 04,20,20,60,"Help Window" )
    @ 06,     22 say "ARROW UP/DN - Previous/Next Page."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Page."
    @ row()+1,22 say "HOME        - First Record on Page."
    @ row()+1,22 say "END         - Last Record on Page."
    @ row()+1,22 say "CTRL PGUP   - First Record of File."
    @ row()+1,22 say "CTRL PGDN   - Last Record of File."
    @ row()+1,22 say "CTRL LEFT   - 1st Group of Columns."
    @ row()+1,22 say "CTRL RIGHT  - 2nd Group of Columns."
    @ row()+1,22 say "F1          - Help!"
    @ row()+1,22 say "F3          - Edit Record."
    @ row()+1,22 say "F4          - Zap/Delete Record."
    @ row()+1,22 say "F6          - Global Control."
    @ row()+1,22 say "F7          - Air Tariff."
    @ row()+1,22 say "F8          - Land Tariff."
    Message("Press any key...")
    inkey(0)
    CloseWindow( wHelp )
return nil

static function Search()
local wSearch, crs
    wSearch := OpenWindow(08,20,18,60,"Search Window" )
    @ 10, 28 say "  Validity" get cEffDate pict "99!!!99"
    @ 12, 28 say "     Label" get cLabel pict "@!"
    @ 14, 28 say "     Hotel" get cHotel pict "@!"
    @ 16, 28 say "Direction (F/B)" get cDir pict "!" valid cDir $ "FB"
    @ 17, 28 say "(CTRL+S to search next)"
    crs := setcursor( SC_NORMAL)
    read
    setcursor( crs )
    CloseWindow( wSearch )
    if (lastkey()!=K_ESC)  ; COST_PKG->(Find())  ;  endif
return nil

static function Find()
local lFound := .F., dDate := EtoD(cEffDate)
    Message("Searching records...")
    if (!empty(dDate) .or. !empty(cLabel))
       if cDir = "F"
          skip 1
          do while  !eof()
             if ( ( dDate >= Valid_From .and. ;
                  ( dDate <= Valid_To   .or. empty(Valid_To) ) ;
                  ) .or. empty(dDate))
                aEntries := LocalArray(aEntries)
                if (empty(cLabel) .or. (alltrim(cLabel) $ Label)) .and. ;
                   (empty(cHotel) .or. (ascan(aEntries,{|x| cHotel $ x[17]}) # 0))
                   lFound := .T.
                   exit
                endif
             endif
             skip 1
          enddo
          if !lFound
             Message("End of File reached...")
             tone(100,3)
             inkey(2)
             skip -1
          else
             Message("Found...")
             tone(300,1)
          endif
       else
          skip -1
          do while !bof()
             if ( ( dDate >= Valid_From .and. ;
                  ( dDate <= Valid_To   .or. empty(Valid_To) ) ;
                  ) .or. empty(dDate))
                aEntries := LocalArray(aEntries)
                if (empty(cLabel) .or. (alltrim(cLabel) $ Label)) .and. ;
                   (empty(cHotel) .or. (ascan(aEntries,{|x| cHotel $ x[17]}) # 0))
                   lFound := .T.
                   exit
                endif
             endif
             skip -1
          enddo
          if !lFound
             Message("Beginning of File reached...")
             tone(100,3)
             inkey(2)
          else
             Message("Found...")
             tone(300,1)
          endif
       endif
    endif
    return nil

// <eof> - pack_cst.prg //