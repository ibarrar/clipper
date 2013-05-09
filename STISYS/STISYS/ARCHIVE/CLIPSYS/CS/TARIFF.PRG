#include "c501_mod.ch"
#include "SetCurs.ch"
#include "inkey.ch"

*------------------------- Land Tariff ------------------------------------*
function do_land(lGet)
local wBrowse, nKey
private nCurLine := nTopRec := nPane := 1, nHeight := 15, aRecIndex := {}
private sEffdate := space(7), sAgent := sCity := sHotel := space(3)
private sDir := 'F'
    Message("Searching Land Tariffs...")
    nRecCnt := CountRecs()
    SetColor(DATA_COLORS)
    SetCursor(SC_NONE)
    wBrowse:=OpenWindow(02, 02, 22, 77, "Land Tariff Window")
    aScrollBar:=ScrollBarNew(04,77,21,"N/W",1)
    ScrollBarDisplay(aScrollBar)
    lShowPage()
    do while nKey != K_ESC
       ScrollBarUpdate(aScrollBar,nTopRec + nCurLine - 1,nRecCnt,.T.)
       SetColor("N/BG")
       if nTopRec + nCurLine-1 == nRecCnt
          @ 02,67 say "  <New> "
       else
          @ 02,67 say "Rec#"+transform(nTopRec+nCurLine-1,"9999")
       endif
       SetColor(DATA_COLORS)
       if !lGet
           Message("F1-Help    F3-Edit    F4-Delete    F5-Search    F7-Add Up    ESC-Abort")
       else
           Message("Enter-Choose    F1-Help    F5-Search    ESC-Abort")
       endif
       lToggle(.T.)
       nkey = inkey(0)
       lToggle(.F.)
       lPageReq := .F.
       do case
          case nkey == K_DOWN
              if nCurLine = nHeight
                 if nTopRec+nHeight -1 < nRecCnt
                    nTopRec ++
                    lPageReq := .T.
                 endif
              else
                 nCurLine ++
              endif
          case nkey == K_UP
              if nCurLine = 1
                 if nTopRec > 1
                    nTopRec --
                    lPageReq := .T.
                 endif
              else
                 nCurLine --
              endif
            case nkey == K_PGDN
              if nTopRec + nHeight -1 < nRecCnt
                 nTopRec += nHeight -1
                 lPageReq := .T.
              else
                 nCurLine := nHeight
              endif
          case nkey == K_PGUP
              if nTopRec > nHeight
                 nTopRec -= nHeight -1
              else
                 nTopRec := 1
                 nCurLine := 1
              endif
              lPageReq := .T.
          case nkey == K_HOME
              nCurLine := 1
          case nkey == K_END
              nCurLine := nHeight
          case nkey == K_CTRL_PGUP
              nTopRec := 1
              nCurLine := 1
              lPageReq := .T.
          case nkey == K_CTRL_PGDN
              if nRecCnt > nHeight
                 if nTopRec < nRecCnt -nHeight -1
                    nTopRec := nRecCnt -nHeight +1
                    lPageReq := .T.
                 endif
              endif
              nCurLine := nHeight
          case nkey == K_ENTER
              if lGet
                 nkey := K_ESC
              endif
          case nkey == K_F3
              if !lGet
                 lEdit()
                 lPageReq := .T.
              endif
          case nkey == K_F4
              if !lGet
                 lDelete()
                 lPageReq := .T.
              endif
          case nkey == K_F5
              lSearch()
              lPageReq := .T.
          case nkey == K_F7
              lAddUp()
          case nkey == K_CTRL_S
              lFind()
              lPageReq := .T.
          case nkey == K_F1
              lHelpme()
          case nkey == K_CTRL_RIGHT
              if(nPane < 4, nPane ++, nPane := 1)
              lPageReq := .T.
          case nkey == K_CTRL_LEFT
              if(nPane > 1, nPane --, nPane := 4)
              lPageReq := .T.
          case nkey == K_ALT_A
               Agent_Look()
          case nkey == K_ALT_H
               Hotel_Look()
       endcase
       if (nTopRec + nCurLine-1 > nRecCnt)
          do while (nTopRec + nCurLine-1 > nRecCnt)
             if nCurLine > 1
                nCurLine --
             else
                nTopRec --
             endif
          enddo
       endif
       if lPageReq
          lShowPage()
          lPageReq := .F.
       endif
    enddo
    CloseWindow(wBrowse)
    return if(Lastkey()==K_ENTER,aRecIndex[ nTopRec + nCurLine -1 ],nil)


static function lShowPage()
*    dispbegin()
    @ 06, 03 say repl('Ä',74)
    do case
       case nPane == 1
           @ 04, 03 say "   Effectivity                             ÚÄÄÄÄÄÄ 4D3N PKG (ADT) ÄÄÄÄ¿   "
           @ 05, 03 say "  From     To       Until   Cty  Htl  Agt   HTwnb     Sglb       XBed     "
       case nPane == 2
           @ 04, 03 say "ÚÄÄÄÄ 3D2N PKG (ADT) ÄÄÄÄ¿ÚÄÄÄ 4D3N PKG (CHD) ÄÄÄ¿ÚÄÄÄÄÄÄÄ XN+ABF ÄÄÄÄÄÄÄ¿"
           @ 05, 03 say " HTwnb     Sglb     XBed   HTwnb    XBed   NoBed   HTwnb    Sglb    XBed  "
       case nPane == 3
           @ 04, 03 say "ÚÄÄÄÄÄÄÄÄÄÄÄ Room Entries ÄÄÄÄÄÄÄÄÄÄÄ¿   CHD    Htl                       "
           @ 05, 03 say "  Sglb   Twnb    Trpb    Quad   XBed     FOC    ABF   Tour      Remarks   "
       otherwise
           @ 04, 03 say "    OW    ÚÄÄÄÄÄÄÄÄÄÄ RT Transfer ÄÄÄÄÄÄÄÄÄÄÄ¿                            "
           @ 05, 03 say "   Trsf    1 pax    2-3 pax  4-9 pax 10-20 pax   Cur                      "
    endcase
    dbgoto( aRecIndex[nTopRec] )
    for n := nTopRec to nTopRec + nHeight-1
    @ n - nTopRec + 7, 10 say ""
       if n <= nRecCnt
          dbgoto( aRecIndex[n])
          lShowLine(row())
       else
          @ row(), 03 say space(73)
       endif
    next
    @ 22, 02 say chr(27) + repl('°',73) + chr(26)
    SetColor("W+/N")
    do case
       case nPane == 1   ;   @ 22, 03 say repl('°',18)
       case nPane == 2   ;   @ 22, 21 say repl('°',18)
       case nPane == 3   ;   @ 22, 39 say repl('°',18)
       otherwise         ;   @ 22, 57 say repl('°',19)
    endcase
    SetColor(DATA_COLORS)
*    dispend()
    return nil

static function lToggle(lToggle)
    DbGoto( aRecIndex[nTopRec + (nCurLine -1)] )
    if lToggle
       SetColor("W+/N")
    endif
    lShowLine(nCurLine -1 + 7)
    SetColor(DATA_COLORS)
    return nil

static function lShowLine(nRow)
    if !Eof()
       do case
          case nPane == 1
              @ nRow,03 say " "+dtoe(eff_from)+"  "+dtoe(eff_to)+;
                          "  "+dtoe(eff_till)+;
                          "  "+city+"  "+hotel+"  "+agency+;
                          "  "+transform(htwn_4d3na,"99999.99")+;
                          "  "+transform(sglb_4d3na,"99999.99")+;
                          "  "+transform(xtrb_4d3na,"99999.99")+"   "
          case nPane == 2
              @ nRow, 03 say transform(htwn_3d2n,"99999.99")+;
                       " "+transform(sglb_3d2n,"99999.99")+;
                       " "+transform(xtrb_3d2n,"99999.99")+;
                       " "+transform(htwn_4d3nc,"9999.99")+;
                       " "+transform(xtrb_4d3nc,"9999.99")+;
                       " "+transform(nob_4d3nc ,"9999.99")+;
                       " "+transform(xn_htwn   ,"9999.99")+;
                       " "+transform(xn_sglb   ,"9999.99")+;
                       " "+transform(xn_xtrb   ,"9999.99")
          case nPane == 3
              @ nRow, 03 say transform(rm_sgl   ,"9999.99")+;
                       " "+transform(rm_twn   ,"9999.99")+;
                       " "+transform(rm_trp   ,"9999.99")+;
                       " "+transform(rm_quad  ,"9999.99")+;
                       " "+transform(rm_xtrb  ,"999.99")+;
                       " "+transform(chd_free ,"999.99")+;
                       " "+transform(hotel_abf,"999.99")+;
                       " "+transform(tour     ,"999.99")+;
                       " "+remark+"  "
          otherwise
              @ nRow, 03 say " "+transform(ow_trsf ,"99999.99")+;
                       " "+transform(rt_trsf ,"99999.99")+;
                       " "+transform(rt_trsf2,"99999.99")+;
                       " "+transform(rt_trsf3,"99999.99")+;
                       " "+transform(rt_trsf4,"99999.99")+;
                       "    "+currency+space(22)
       endcase
    else
       @ nRow, 03 say space(73)
    endif
    return nil

static function lEdit()
    DbGoto( aRecIndex[nTopRec + nCurLine -1] )
    if !Eof()
           v_eff_from   := dtoe( eff_from )
           v_eff_to     := dtoe( eff_to   )
           v_eff_till   := dtoe( eff_till )
           v_city       := city
           v_hotel      := hotel
           v_agency     := agency
           v_htwn_4d3na := htwn_4d3na
           v_sglb_4d3na := sglb_4d3na
           v_xtrb_4d3na := xtrb_4d3na
           v_htwn_3d2n  := htwn_3d2n
           v_sglb_3d2n  := sglb_3d2n
           v_xtrb_3d2n  := xtrb_3d2n
           v_htwn_4d3nc := htwn_4d3nc
           v_xtrb_4d3nc := xtrb_4d3nc
           v_nob_4d3nc  := nob_4d3nc
           v_xn_htwn  := xn_htwn
           v_xn_sglb  := xn_sglb
           v_xn_xtrb  := xn_xtrb
           v_rm_sgl   := rm_sgl
           v_rm_twn   := rm_twn
           v_rm_trp   := rm_trp
           v_rm_quad  := rm_quad
           v_rm_xtrb  := rm_xtrb
           v_chd_free := chd_free
           v_hotel_abf:= hotel_abf
           v_tour     := tour
           v_ow_trsf  := ow_trsf
           v_rt_trsf  := rt_trsf
           v_rt_trsf2 := rt_trsf2
           v_rt_trsf3 := rt_trsf3
           v_rt_trsf4 := rt_trsf4
           v_remark   := remark
           v_currency := currency
    else
           v_eff_from := space(7)
           v_eff_to   := space(7)
           v_eff_till := space(7)
           v_city     := space(3)
           v_hotel    := space(3)
           v_agency   := space(3)
           v_htwn_4d3na := 0
           v_sglb_4d3na := 0
           v_xtrb_4d3na := 0
           v_htwn_3d2n  := 0
           v_sglb_3d2n  := 0
           v_xtrb_3d2n  := 0
           v_htwn_4d3nc := 0
           v_xtrb_4d3nc := 0
           v_nob_4d3nc  := 0
           v_xn_htwn  := 0
           v_xn_sglb  := 0
           v_xn_xtrb  := 0
           v_rm_sgl   := 0
           v_rm_twn   := 0
           v_rm_trp   := 0
           v_rm_quad  := 0
           v_rm_xtrb  := 0
           v_chd_free := 0
           v_hotel_abf:= 0
           v_tour     := 0
           v_ow_trsf  := 0
           v_rt_trsf  := 0
           v_rt_trsf2 := 0
           v_rt_trsf3 := 0
           v_rt_trsf4 := 0
           v_remark   := space(10)
           v_currency := space(3)
    endif
    do case
       case nPane == 1
            @ row(),         03 say "" get v_eff_from pict "99!!!99"
            @ row(), col()+1 say "" get v_eff_to   pict "99!!!99"
            @ row(), col()+1 say "" get v_eff_till pict "99!!!99"
            @ row(), col()+1 say "" get v_city        pict "@!"
            @ row(), col()+1 say "" get v_hotel       pict "@!"
            @ row(), col()+1 say "" get v_agency   pict "@!"
            @ row(), col()+1 say "" get v_htwn_4d3na pict "99999.99"
            @ row(), col()+1 say "" get v_sglb_4d3na pict "99999.99"
            @ row(), col()+1 say "" get v_xtrb_4d3na pict "99999.99"
       case nPane == 2
            @ row(),    03        get v_htwn_3d2n pict "99999.99"
            @ row(), col() say "" get v_sglb_3d2n pict "99999.99"
            @ row(), col() say "" get v_xtrb_3d2n pict "99999.99"
            @ row(), col() say "" get v_htwn_4d3nc pict "9999.99"
            @ row(), col() say "" get v_xtrb_4d3nc pict "9999.99"
            @ row(), col() say "" get v_nob_4d3nc  pict "9999.99"
            @ row(), col() say "" get v_xn_htwn    pict "9999.99"
            @ row(), col() say "" get v_xn_sglb    pict "9999.99"
            @ row(), col() say "" get v_xn_xtrb    pict "9999.99"
       case nPane == 3
            @ row(),    03        get v_rm_sgl   pict "9999.99"
            @ row(), col() say "" get v_rm_twn   pict "9999.99"
            @ row(), col() say "" get v_rm_trp   pict "9999.99"
            @ row(), col() say "" get v_rm_quad  pict "9999.99"
            @ row(), col() say "" get v_rm_xtrb  pict "999.99"
            @ row(), col() say "" get v_chd_free pict "999.99"
            @ row(), col() say "" get v_hotel_abf  pict "999.99"
            @ row(), col() say "" get v_tour       pict "999.99"
            @ row(), col() say "" get v_remark   pict "@!"
       otherwise
            @ row(),    03 say "" get v_ow_trsf  pict "99999.99"
            @ row(), col() say "" get v_rt_trsf  pict "99999.99"
            @ row(), col() say "" get v_rt_trsf2 pict "99999.99"
            @ row(), col() say "" get v_rt_trsf3 pict "99999.99"
            @ row(), col() say "" get v_rt_trsf4 pict "99999.99"
            @ row(), col()+3 say "" get v_currency pict "@!"
    endcase
    SetCursor(SC_NORMAL)
    set key K_ALT_H to Hotel_Look()
    set key K_ALT_A to Agent_Look()
    read
    set key K_ALT_H to
    set key K_ALT_A to
    SetCursor(SC_NONE)
    if (Lastkey()!=K_ESC)
        lReScan := .F.
        if Eof()
           DbAppend()
           lReScan := .T.
        endif
        do case
           case nPane == 1
                replace eff_from   with etod( v_eff_from )
                replace eff_to     with etod( v_eff_to   )
                replace eff_till   with etod( v_eff_till )
                replace city       with v_city
                replace hotel      with v_hotel
                replace agency     with v_agency
                replace htwn_4d3na with v_htwn_4d3na
                replace sglb_4d3na with v_sglb_4d3na
                replace xtrb_4d3na with v_xtrb_4d3na
           case nPane == 2
                replace htwn_3d2n  with v_htwn_3d2n
                replace sglb_3d2n  with v_sglb_3d2n
                replace xtrb_3d2n  with v_xtrb_3d2n
                replace htwn_4d3nc with v_htwn_4d3nc
                replace xtrb_4d3nc with v_xtrb_4d3nc
                replace nob_4d3nc  with v_nob_4d3nc
                replace xn_htwn  with v_xn_htwn
                replace xn_sglb  with v_xn_sglb
                replace xn_xtrb  with v_xn_xtrb
           case nPane == 3
                replace rm_sgl   with v_rm_sgl
                replace rm_twn   with v_rm_twn
                replace rm_trp   with v_rm_trp
                replace rm_quad  with v_rm_quad
                replace rm_xtrb  with v_rm_xtrb
                replace chd_free with v_chd_free
                replace hotel_abf with v_hotel_abf
                replace tour     with v_tour
                replace remark   with v_remark
                replace currency with v_currency
           otherwise
                replace ow_trsf with v_ow_trsf
                replace rt_trsf with v_rt_trsf
                replace rt_trsf2 with v_rt_trsf2
                replace rt_trsf3 with v_rt_trsf3
                replace rt_trsf4 with v_rt_trsf4
                replace currency with v_currency
        endcase
        if lReScan  ;  nRecCnt := CountRecs()  ;  endif
    endif
    return nil

static function lDelete()
    lToggle(.T.)
    Message("Press any key to delete, ESC to abort...")
    inkey(0)
    if Lastkey()!=K_ESC .and. !Eof()
       DbGoto( aRecIndex[nTopRec + nCurLine -1] )
       Message("Deleting Record#"+transform(recno(),"9999"))
       DbDelete()
       pack
       Tone(300,1)
       Message("Deleted...")
       inkey(1)
       nRecCnt := CountRecs()
    endif
    return nil

static function lSearch()
local wSearch, l_found := .F.
    lToggle(.T.)
    wSearch := OpenWindow(08,20,15,60,"Search Window")
    @ 10, 25 say "    Effectivity" get sEffdate pict "99!!!99"
    @ 11, 25 say "           City" get sCity pict "@!"
    @ 12, 25 say "          Hotel" get sHotel pict "@!"
    @ 13, 25 say "          Agent" get sAgent pict "@!"
    @ 14, 25 say "Direction (F/B)" get sDir pict "!" valid sDir $ "FB"
    Message("Enter details,    ALT+H-Hotel Lookup     ALT+A-Agent Lookup     ESC-Abort.")
    SetCursor(SC_NORMAL)
    set key K_ALT_H to Hotel_Look()
    set key K_ALT_A to Agent_Look()
    read
    set key K_ALT_H to
    set key K_ALT_A to
    SetCursor(SC_NONE)
    CloseWindow(wSearch)
    if Lastkey()!=K_ESC  ;  lFind()  ;  endif
return nil

static function lFind()
local n, lFound := .F.
     if !empty(sEffdate) .or. !empty(sHotel) .or. !empty(sCity) .or. !empty(sAgent)
       message("Searching Tariff....")
       if sDir = "F"
          for n:= nTopRec + nCurLine to nRecCnt -1
             DbGoto( aRecIndex[n] )
             if ( empty(sEffdate) .or. ( (etod(sEffdate) >= eff_from) .and. (etod(sEffdate) <= if(empty(eff_till),eff_to,eff_till) )) );
                .and.  ((alltrim(sHotel) $ hotel) .or. empty(sHotel)) ;
                .and.  ((alltrim(sCity) $ city) .or. empty(sCity)) ;
                .and.  ((alltrim(sAgent) $ agency) .or. empty(sAgent))
                lFound := .T.
                exit
             endif
          next
          if !lFound
             Message("End of File reached...")
             tone(100,3)
             inkey(2)
          else
             Message("Found...")
             tone(300,1)
          endif
       else
          for n:= nTopRec + nCurLine-2 to 1 step -1
             DbGoto( aRecIndex[n] )
             if ( empty(sEffdate) .or. ( (etod(sEffdate) >= eff_from) .and. (etod(sEffdate) <= if(empty(eff_till),eff_to,eff_till) )) );
                .and.  ((alltrim(sHotel) $ hotel) .or. empty(sHotel)) ;
                .and.  ((alltrim(sCity) $ city) .or. empty(sCity)) ;
                .and.  ((alltrim(sAgent) $ agency) .or. empty(sAgent))
                lFound := .T.
                exit
             endif
          next
          if !lFound
             Message("Beginning of File reached...")
             tone(100,3)
             inkey(2)
          else
             Message("Found...")
             tone(300,1)
          endif
       endif
       if n <= 7
           nTopRec  := 1
           nCurLine := if(n>0,n,1)
       else
           nTopRec := n - 7
           nCurLine := n - nTopRec +1
       endif
    endif
    return nil

static function lHelpme()
local wHelp
    lToggle(.T.)
    wHelp := OpenWindow(05,20,21,60,"Help Window")
    @ 07,     22 say "ARROW UP/DN - Previous/Next Page."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Page."
    @ row()+1,22 say "HOME        - First Record on Page."
    @ row()+1,22 say "END         - Last Record on Page."
    @ row()+1,22 say "CTRL PGUP   - First Record of File."
    @ row()+1,22 say "CTRL PGDN   - Last Record of File."
    @ row()+1,22 say "CTRL LEFT   - Previous Window."
    @ row()+1,22 say "CTRL RIGHT  - Next Window."
    @ row()+1,22 say "F1          - Help!"
    @ row()+1,22 say "F3          - Edit Record."
    @ row()+1,22 say "F4          - Zap/Delete Record."
    @ row()+1,22 say "F5          - Search Record."
    @ row()+1,22 say "F7          - Add from Room entries."
    @ row()+1,22 say "ESC         - Exit Land Tariff."
    Message("Press any key...")
    inkey(0)
    CloseWindow(wHelp)
    return nil

static function lAddUp()
    lToggle(.T.)
    Message("Press any key to add up, esc to abort...")
    inkey(0)
    if Lastkey()!=K_ESC
          //  4d3n adult package
       DbGoto( aRecIndex[ nTopRec + nCurLine-1] )
       replace htwn_4d3na with ((rm_twn / 2) + hotel_abf) * 3  + (ow_trsf*2) + tour
       replace sglb_4d3na with ( rm_sgl + hotel_abf)      * 3  + (ow_trsf*2) + tour
       replace xtrb_4d3na with ( rm_xtrb + hotel_abf)     * 3  + (ow_trsf*2) + tour
           //  3d2n adult package
       replace htwn_3d2n  with ((rm_twn / 2) + hotel_abf) * 2  + (ow_trsf*2) + tour
       replace sglb_3d2n  with ( rm_sgl + hotel_abf)      * 2  + (ow_trsf*2) + tour
       replace xtrb_3d2n  with ( rm_xtrb + hotel_abf)     * 2  + (ow_trsf*2) + tour
           // 4d3n child package
       replace htwn_4d3nc with ((rm_twn / 2) + hotel_abf) * 3  + (ow_trsf*2) + tour
       replace xtrb_4d3nc with ( rm_xtrb + hotel_abf)     * 3  + (ow_trsf*2) + tour
       replace nob_4d3nc  with hotel_abf                  * 3  + (ow_trsf*2) + tour
          // extra nights with abf
       replace xn_htwn  with (rm_twn /2) + hotel_abf
       replace xn_sglb  with rm_sgl      + hotel_abf
       replace xn_xtrb  with rm_xtrb     + hotel_abf
       Tone(100,3)
    endif
    return nil

*------------------------------- Air Tariff -------------------------------*
function do_air(lGet)
local wBrowse, nkey
private nCurLine := nTopRec := nRecCnt := 1, aRecIndex := {}
private sEffdate := space(7), sAir := space(18), sRoute := space(20), sDir := 'F'
private nHeight := 15
    Message("Searching Air Tariffs...")
    nRecCnt := CountRecs()
    SetColor(DATA_COLORS)
    SetCursor(SC_NONE)
    wBrowse:=OpenWindow(03, 02, 22, 77, "Air Tariff Window")
    aScrollBar:=ScrollBarNew(04,77,22,"N/W",1)
    ScrollBardisplay(aScrollBar)
    aShowPage()
    do while nKey != K_ESC
       ScrollBarUpdate(aScrollBar,nTopRec + nCurLine - 1,nRecCnt,.T.)
       SetColor("N/BG")
       if nTopRec + nCurLine-1 == nRecCnt
          @ 03,67 say "  <New> "
       else
          @ 03,67 say "Rec#"+transform(nTopRec+nCurLine-1,"9999")
       endif
       SetColor(DATA_COLORS)
       if !lGet
           Message("F1-Help    F3-Edit    F4-Delete    F5-Search    ESC-Abort.")
       else
           Message("Enter-Choose     F1-Help     F5-Search     ESC-Abort.")
       endif
       aToggle(.T.)
       nkey = inkey(0)
       aToggle(.F.)
       lPageReq := .F.
       do case
          case nkey == K_DOWN
              if nCurLine = nHeight
                 if nTopRec+nHeight -1 < nRecCnt
                    nTopRec ++
                    lPageReq := .T.
                 endif
              else
                 nCurLine ++
              endif
          case nkey == K_UP
              if nCurLine = 1
                 if nTopRec > 1
                    nTopRec --
                    lPageReq := .T.
                 endif
              else
                 nCurLine --
              endif
            case nkey == K_PGDN
              if nTopRec + nHeight -1 < nRecCnt
                 nTopRec += nHeight -1
                 lPageReq := .T.
              else
                 nCurLine := nHeight
              endif
          case nkey == K_PGUP
              if nTopRec > nHeight
                 nTopRec -= nHeight -1
              else
                 nTopRec := 1
                 nCurLine := 1
              endif
              lPageReq := .T.
          case nkey == K_HOME
              nCurLine := 1
          case nkey == K_END
              nCurLine := nHeight
          case nkey == K_CTRL_PGUP
              nTopRec := 1
              nCurLine := 1
              lPageReq := .T.
          case nkey == K_CTRL_PGDN
              if nRecCnt > nHeight
                 if nTopRec < nRecCnt -nHeight -1
                    nTopRec := nRecCnt -nHeight +1
                    lPageReq := .T.
                 endif
              endif
              nCurLine := nHeight
          case nkey == K_ENTER
              if lGet
                 nkey := K_ESC
              endif
          case nkey == K_F3
              if !lGet
                 aEdit()
                 lPageReq := .T.
              endif
          case nkey == K_F4
              if !lGet
                 aDelete()
                 lPageReq := .T.
              endif
          case nkey == K_F5
              aSearch()
              lPageReq := .T.
          case nkey == K_CTRL_S
              aFind()
              lPageReq := .T.
          case nkey == K_F1
              ahelpme()
          case nkey == K_ALT_A
               Agent_Look()
          case nkey == K_ALT_H
               Hotel_Look()
       endcase
       if (nTopRec + nCurLine-1 > nRecCnt)
          do while (nTopRec + nCurLine-1 > nRecCnt)
             if nCurLine > 1
                nCurLine --
             else
                nTopRec --
             endif
          enddo
       endif
       if lPageReq
          aShowPage()
          lPageReq := .F.
       endif
    enddo
    CloseWindow(wBrowse)
    return if(Lastkey()==K_ENTER,aRecIndex[ nTopRec + nCurLine -1 ],nil)

static function aShowPage()
local n
*    dispbegin()
    @ 05, 03 say "  Effectivity        Airline               Route          Adult    Child"
    @ 06, 03 say repl('Ä',74)
    dbgoto( aRecIndex[nTopRec] )
    for n := nTopRec to nTopRec + 14
       @ n - nTopRec + 7, 10 say ""
       if n <= nRecCnt
          dbgoto( aRecIndex[n] )
          aShowLine(row())
       else
          @ row(), 03 say space(73)
       endif
    next
*    dispend()
    return nil

static function aToggle(lToggle)
    DbGoto( aRecIndex[nTopRec + (nCurLine -1)] )
    if lToggle
       SetColor("w+/n")
    endif
    aShowLine(nCurLine -1 + 7)
    SetColor(DATA_COLORS)
    return nil

static function aShowLine(nRow)
    if !eof()
       @ nRow,03 say dtoe(eff_from) + " " + dtoe(eff_to) +;
                   " " + airline  + " " + route  +;
                   " " + transform(adult,"9,999.99") + ;
                   " " + transform(child,"9,999.99")
    else
       @ nRow, 03 say space(73)
    endif
    return nil

static function aEdit()
    dbgoto( aRecIndex[ nTopRec + nCurLine -1] )
    if !eof()
        v_eff_from := dtoe(eff_from)
        v_eff_to   := dtoe(eff_to)
        v_airline  := airline
        v_adult    := adult
        v_child    := child
        v_route    := route
    else
        v_eff_from := space(7)
        v_eff_to   := space(7)
        v_airline  := space(18)
        v_adult    := 0
        v_child    := 0
        v_route    := space(20)
    endif
    @ row(), 03    get v_eff_from pict "99!!!99"
    @ row(), col() say "" get v_eff_to   pict "99!!!99"
    @ row(), col() say "" get v_airline  pict "@!"
    @ row(), col() say "" get v_route    pict "@!"
    @ row(), col() say "" get v_adult    pict "9,999.99"
    @ row(), col() say "" get v_child    pict "9,999.99"
    SetCursor(SC_NORMAL)
    read
    SetCursor(SC_NONE)
    if (Lastkey()!=K_ESC)
        lReScan := .F.
        if Eof()
           DbAppend()
           lReScan := .T.
        endif
        replace eff_from with etod(v_eff_from)
        replace eff_to   with etod(v_eff_to)
        replace airline  with v_airline
        replace adult    with v_adult
        replace child    with v_child
        replace route    with v_route
        if lReScan  ;  nRecCnt := CountRecs()  ;  endif
    endif
    return nil

static function aDelete()
    aToggle(.T.)
    Message("Press any key to delete, ESC to abort...")
    inkey(0)
    if Lastkey()!=K_ESC .and. !Eof()
       DbGoto( aRecIndex[ nTopRec + nCurLine -1] )
       Message("Deleting Record#"+transform(nTopRec + nCurLine -1,"9999"))
       DbDelete()
*      Pack
       Tone(300,1)
       Message("Deleted...")
       inkey(1)
       nRecCnt := CountRecs()
    endif
    return nil

static function aSearch()
local wSearch
    aToggle(.T.)
    wSearch := openwindow(08,20,15,60,"Search Window")
    @ 10, 23 say "    Effectivity" get sEffdate pict "99!!!99"
    @ 11, 23 say "        Airline" get sAir pict "@!"
    @ 12, 23 say "          Route" get sRoute pict "@!"
    @ 13, 23 say "Direction (F/B)" get sDir pict "!" valid sDir $ "FB"
    @ 14, 23 say "  (Press Ctrl+S to search again...)"
    SetCursor(SC_NORMAL)
    read
    SetCursor(SC_NONE)
    CloseWindow(wSearch)
    if Lastkey()!=K_ESC  ; aFind()   ;  endif
    return nil

static function aFind()
local n, lFound := .F.
    if !empty(sEffdate) .or. !empty(sRoute) .or. !empty(sAir)
       message("Searching Tariff....")
       if sDir = "F"
          for n := nTopRec + nCurLine to nRecCnt-1
             dbgoto( aRecIndex[n] )
             if ( empty(sEffdate) .or. ( (etod(sEffdate) >= eff_from) .and. (etod(sEffdate) <= if(empty(eff_to),ctod("12/31/99"),eff_to) )) );
                .and.  ((alltrim(sRoute) $ route) .or. empty(sRoute)) ;
                .and.  ((alltrim(sAir) $ airline) .or. empty(sAir))
                lFound := .T.
                exit
             endif
          next
          if !lFound
             Message("End of File reached...")
             tone(100,3)
             inkey(2)
          else
             Message("Found...")
             tone(300,1)
          endif
       else
          for n := nTopRec + nCurLine-2 to 1 step -1
             dbgoto( aRecindex[n] )
             if ( empty(sEffdate) .or. ( (etod(sEffdate) >= eff_from) .and. (etod(sEffdate) <= if(empty(eff_to),ctod("12/31/99"),eff_to) )) );
                .and.  ((alltrim(sRoute) $ route) .or. empty(sRoute)) ;
                .and.  ((alltrim(sAir) $ airline) .or. empty(sAir))
                lFound := .T.
                exit
             endif
          next
          if !lFound
             Message("Beginning of File reached...")
             tone(100,3)
             inkey(2)
          else
             Message("Found...")
             tone(300,1)
          endif
       endif
       if n <= 7
          nTopRec :=1
          nCurLine := if(n>0,n,1)
       else
          nTopRec := n - 7
          nCurLine := n - nTopRec +1
       endif
    endif
    return nil

static function ahelpme()
local w_help
    atoggle(.T.)
    w_help := openwindow(05,20,19,60,"Help Window")
    @ 07,     22 say "ARROW UP/DN - Previous/Next Page."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Page."
    @ row()+1,22 say "HOME        - First Record on Page."
    @ row()+1,22 say "END         - Last Record on Page."
    @ row()+1,22 say "CTRL PGUP   - First Record of File."
    @ row()+1,22 say "CTRL PGDN   - Last Record of File."
    @ row()+1,22 say "F1          - Help!"
    @ row()+1,22 say "F3          - Edit Record."
    @ row()+1,22 say "F4          - Zap/Delete Record."
    @ row()+1,22 say "F5          - Search Record."
    @ row()+1,22 say "              (Ctrl-S to repeat)"
    @ row()+1,22 say "ESC         - Exit Air Tariff."
    Message("Press any key...")
    inkey(0)
    closewindow(w_help)
    return nil

*---------------------------------------------------------------------*
static function CountRecs()
local n := 0
   aRecIndex := {}
   dbgotop()
   do while !eof()
      aAdd(aRecIndex,RecNo())
      n ++
      Dbskip()
   enddo
   aAdd(aRecIndex,LastRec()+1)
   return n+1

//end of file //