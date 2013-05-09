// Filename:      PACK_CST.PRG
// System-Name:   Super Travel Costing Software
// Module:        Package Costing Module
// Author:        Rollie Ibarra Jr.
// Date-Started:  Sept 23, 1993
// Last-Update:   Sept 23, 1993

#include "Mode.Ch"
#include "inkey.Ch"
#include "SetCurs.Ch"
#include "MemoEdit.Ch"
#include "Printer.Ch"
#include "c501_mod.ch"

#define BAR_1 "F1-Help   F2-Add    F3-Edit    F4-Delete    F5-Search    F6-Local    ESC-Abort"
#define BAR_2 "F1-Help    F3-Edit    F4-Delete    F6-Global    F8-Land Tariff    ESC-Abort"
#define AMT_PIC    "99999.99"

static m_label, m_valid1, m_valid2, m_sti, m_misc, m_ac, cLabel, lPrint
static a_total1, a_total2, a_total3, a_entries

function do_room()
local wCost, nkey
public s_label := space(12), s_effdate:= space(7), s_dir := 'F', n_pane := 1
public n_editrow := n_toppage :=  n_index := 1
    setcolor(DATA_COLORS)
    use cost_rmg new
    use cost_rml index cost_rml new
    wcost :=openwindow(03,02,21,77,"Room Costing")
    if Lastkey()!=K_ESC
      do while (nkey!=K_ESC)
         rmg_screen(VIEW_MODE)
         message(BAR_1)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
                 cost_rmg->(dbskip())
                 if cost_rmg->(eof())
                    cost_rmg->(dbgobottom())
                    tone(200,1)
                    message("End of file reached....")
                    inkey(1)
                 endif
            case nkey==K_UP
                 cost_rmg->(dbskip(-1))
                 if cost_rmg->(bof())
                    cost_rmg->(dbgotop())
                    tone(200,1)
                    message("Beginning of file reached....")
                    inkey(1)
                 endif
            case nkey==K_CTRL_PGDN
                 cost_rmg->(dbskip(NUM_TO_SKIP))
                 if cost_rmg->(eof())
                    cost_rmg->(dbgobottom())
                    tone(200,1)
                    message("End of file reached....")
                    inkey(1)
                 endif
            case nkey==K_CTRL_PGUP
                 cost_rmg->(dbskip(-NUM_TO_SKIP))
                 if cost_rmg->(bof())
                    cost_rmg->(dbgotop())
                    tone(200,1)
                    message("Beginning of file reached....")
                    inkey(1)
                 endif
            case nkey==K_END
                 cost_rmg->(dbgobottom())
                    message("Moving to end of file....")
                    inkey(1)
            case nkey==K_HOME
                 cost_rmg->(dbgotop())
                 message("Moving to beginning of file....")
                 inkey(1)
            case nkey == K_F1
                 helpme1()
            case nkey==K_F2
                 message("Press ENTER to add new record.")
                 if inkey(0)==K_ENTER
                    rmg_screen(APPEND_MODE)
                 endif
            case nkey==K_F3
                 rmg_screen(EDIT_MODE)
            case nkey==K_F4
                 message("Press ENTER to delete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    message("Deleting current record....")
                    cost_rml->(dbseek(cost_rmg->link ))
                    do while cost_rmg->link == cost_rml->link
                       cost_rml->(dbdelete())
                       cost_rml->(dbskip())
                    enddo
                    cost_rmg->(DbDelete())
                 endif
            case nkey == K_F5
                 cost_rmg->(search())
            case nkey == K_CTRL_S
                 cost_rmg->(Find())
            case nkey == K_F6
                 cost_rml->(components())
            case nkey = K_CTRL_LEFT
                 n_pane := 1
            case nkey = K_CTRL_RIGHT
                 n_pane := 2
         endcase
      enddo
    endif
    closewindow(wcost)
    cost_rml->(dbclosearea())
    cost_rmg->(dbclosearea())
return nil

static function rmg_screen(nmode)
    tone(300,1)
    set color to n/bg
    if cost_rmg->(deleted())    ;   @ 03, 36 say "<deleted>"
    else   ;   @ 03, 36 say "         "   ;  endif
    if nmode==APPEND_MODE
       @ 03, 68 say "< New >   "
    else
       @ 03, 68 say "Rec #"+transform(cost_rmg->(RecNo()),"9999")
    endif
    setcolor(DATA_COLORS)
    rmg_init(nmode)
    show_page()
    @ 05,      04 say repl('-',72)
    @ 08,      04 say repl('-',72)
    @ 13,      04 say repl('-',72)
    @ row()+1, 04 say "Miscell. "
    @ row()+2, 04 say "Total    "
    @ row()+1, 04 say "STI      "
    @ row()+1, 04 say "Air. Com."
    @ row()+2, 04 say "Grand Ttl"
    @ 04, 04 say "LABEL:" get m_label pict "@!"
    @ row(), col()+10 say "Validity:" get m_valid1 pict "99!!!99"
    @ row(), col() say " to " get m_valid2 pict "99!!!99"
    for x:=1 to 5
        @ 14, ((x-1)*12) + 17 get m_misc[x] pict AMT_PIC
        @ 17, ((x-1)*12) + 17 get m_sti[x] pict AMT_PIC
        @ 18, ((x-1)*12) + 17 get m_ac[x] pict repl('x',8)
    next
    if nmode==VIEW_MODE
       clear gets
    else
       SetCursor(SC_NORMAL)
       read
       if Lastkey()!=K_ESC
           rmg_save(nmode)
       endif
       SetCursor(SC_NONE)
    endif
return nil

static function rmg_init(nmode)
  if nmode==APPEND_MODE
     m_label := space(20)
     m_valid1 := space(7)
     m_valid2 := space(7)
     m_misc := afill(array(5),0.0)
     m_sti := afill(array(5),0.0)
     m_ac := afill(array(5),space(8))
     a_entries := {}
  else
     select cost_rmg
     m_label := label
     m_valid1 := valid_from
     m_valid2 := valid_to
     m_misc := {}  ;  m_sti := {}  ;  m_ac := {}  ;  a_entries := {}
     for x:=  1 to 5
           aadd( m_misc,&(Field(x+1)) )
           aadd( m_sti,&(Field(x+6)) )
           aadd( m_ac,&(Field(x+11)) )
     next
     for x:=1 to len(m_ac)
        m_ac[x] := padl(alltrim(m_ac[x]),8)
     next
     select cost_rml
     dbseek(cost_rmg->link)
     do while !eof() .and. (link==cost_rmg->link )
        aadd(a_entries,{sgl_bed,twn_bed,trp_bed,;
                        quad_bed,xtra_bed,;
                        hotel,recno()})
        cost_rml->(dbskip())
     enddo
     aadd(a_entries,{0,0,0,0,0,"   ",0})
     compute_totals(0)
  endif
return nil

static function compute_totals(nmode)
    a_total1 := {} ; a_total2 := {} ; a_total3 := {}
    a_total1 := afill(array(5),0.00)
    a_total2 := afill(array(5),0.00)
    a_total3 := afill(array(5),0.00)
    for x := 1 to if(nmode==0,len(a_entries),nmode)
        for z:= 1 to 5
             a_total1[z] += a_entries[x][z]
        next
    next
    for x:=1 to 5
        a_total2[x]  := a_total1[x] + m_misc[x]
    next
    for x:=1 to 5
        if at('%',m_ac[x]) <> 0
           a_total3[x]:=(a_total2[x] + m_sti[x]) / ;
           ((100 - val(substr(m_ac[x],at('%',m_ac[x])-2,2))) / 100)
        else
           a_total3[x]:=a_total2[x]+m_sti[x]+val(m_ac[x])
        endif
    next
    @ 06, 10 say "        Single       Twin       Triple       Quad       Extra"
    @ 07, 10 say "Htl      Bed         Bed         Bed         Bed         Bed "
    for x:=1 to 5
        @ 16, ((x-1)*12) + 17 get a_total2[x] pict AMT_PIC
        @ 20, ((x-1)*12) + 17 get a_total3[x] pict AMT_PIC
    next
    clear gets
return nil

static function rmg_save(nmode)
      select cost_rmg
      if nmode==APPEND_MODE
         cost_rmg->(dbappend())
         cost_rmg->link := cost_rmg->(recno())
      endif
      cost_rmg->label := m_label
      cost_rmg->valid_from := m_valid1
      cost_rmg->valid_to   := m_valid2
      for x:=1 to 5
        replace &(cost_rmg->(Field(x+1)))  with m_misc[x]
        replace &(cost_rmg->(Field(x+6))) with m_sti[x]
        replace &(cost_rmg->(Field(x+11))) with m_ac[x]
      next
      cost_rmg->(dbcommit())
return nil

static function components()
local w_browse, ascrollbar, nkey
    ascrollbar:=scrollbarnew(04,77,22,"N/W",1)
    scrollbardisplay(ascrollbar)
    show_page()
    do while nKey != K_F6
       n_index := n_toppage + n_editrow -1
       scrollbarupdate(ascrollbar,n_toppage + n_editrow - 1,len(a_entries),.T.)
       set color to n/bg
       if n_toppage+n_editrow-1 = len(a_entries)
          @ 03,68 say "<New>    "
       else
          @ 03,68 say "Rec #"+transform(n_index,"9999")
       endif
       setcolor(DATA_COLORS)
       message(BAR_2)
       compute_totals(n_toppage + n_editrow -1)
       toggle(.T.)
       nkey = inkey(0)
       toggle(.F.)
       do case
          case nkey == K_DOWN
               if n_editrow = 4
                  if n_toppage+2 < len(a_entries) -1
                     n_toppage ++
                     show_page()
                  endif
               else
                  if n_toppage + (n_editrow-1) <= len(a_entries) -1
                     n_editrow ++
                  endif
               endif
          case nkey == K_UP
               if n_editrow = 1
                  if n_toppage > 1
                     n_toppage --
                     show_page()
                  endif
               else
                  n_editrow --
               endif
          case nkey == K_PGDN
               if n_toppage + 8 < len(a_entries) -1
                  n_toppage += 3
               else
                  if len(a_entries) -1 > 3
                     n_toppage := len(a_entries) -1 -3
                     n_editrow := 4
                  else
                     n_toppage := 1
                     n_editrow := len(a_entries) -1
                  endif
               endif
               show_page()
          case nkey == K_PGUP
               if n_toppage - 3 > 0
                  n_toppage -= 3
               else
                  n_toppage := 1
                  n_editrow := 1
               endif
               show_page()
          case nkey == K_HOME
               n_editrow := 1
          case nkey == K_END
              n_editrow := if(len(a_entries)>4,4,len(a_entries))
          case nkey == K_CTRL_PGUP
               n_toppage := 1
               n_editrow := 1
               show_page()
          case nkey == K_CTRL_PGDN
              if len(a_entries) -1 > 3
                 n_toppage := len(a_entries) -1 -2
                 n_editrow := 4
              else
                 n_toppage := 1
                 n_editrow := len(a_entries) -1 +1
              endif
              show_page()
          case nkey == K_F1
               helpme2()
          case nkey == K_F3
               edit_rec()
               show_page()
          case nkey == K_F4
               delrec()
               n_toppage := n_editrow := 1
               rmg_screen(VIEW_MODE)
          case nkey == K_F5
               toggle(.T.)
               cost_rmg->(search())
               n_toppage := n_editrow := 1
               rmg_screen(VIEW_MODE)
          case nkey == K_F8
               get_land()
               n_toppage := n_editrow := 1
               rmg_screen(VIEW_MODE)
       endcase
    enddo
    n_toppage := n_editrow := 1
return nil

static function show_page()
local x
    for x := n_toppage to n_toppage + 3
       @ x - n_toppage + 9, 10 say ""
       if x <= len(a_entries) -1
          n_index := x
          show_line(row())
       else
          @ row(), 03 say space(77-04)
       endif
    next
return nil

static function toggle(l_toggle)
    n_index := n_toppage + (n_editrow -1)
    if l_toggle
       set color to
    endif
    show_line(n_editrow -1 + 9)
    setcolor(DATA_COLORS)
return nil

static function show_line(n_row)
local  x, c_string
    if n_index < len(a_entries)
       c_string := substr(a_entries[n_index][6],1,3)
       for x := 1 to 5
           c_string += "    "+transform(a_entries[n_index][x],"99999.99")
       next
       @ n_row,10 say c_string
    else
       @ n_row,10 say space(63)
    endif
return nil

static function edit_rec()
     if n_index != len(a_entries)
        @ n_editrow -1 +9, 10 get a_entries[n_index][6] pict "!!!"
        for x := 1 to 5
            @ row(), col() say "   " get a_entries[n_index][x] pict "99999.99"
        next
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if Lastkey()!=K_ESC
           dbgoto(a_entries[n_index][7])
           replace hotel    with a_entries[n_index][6]
           replace sgl_bed  with a_entries[n_index][1]
           replace twn_bed  with a_entries[n_index][2]
           replace trp_bed  with a_entries[n_index][3]
           replace quad_bed with a_entries[n_index][4]
           replace xtra_bed with a_entries[n_index][5]
           dbcommit()
        endif
     endif
return nil

static function delrec()
     if n_index != len(a_entries)
        toggle(.T.)
        dbgoto(a_entries[n_index][7])
        message("Press any key to delete, ESC to abort...")
        inkey(0)
        if Lastkey()!=K_ESC
           message("Deleting Record#"+transform(cost_rml->(recno()),"9999"))
           dbdelete()
           pack
           tone(300,1)
           message("Deleted...")
           inkey(2)
        endif
     endif
return nil

static function get_land()
    use land new
    message("Searching recent land tariffs...")
    set filter to (empty(eff_till) .or. (etod(eff_till)>=etod(cost_rmg->valid_from)));
        .and.  ( city $ cost_rmg->label)
    x:=do_land(.T.)
    if Lastkey()!= K_ESC .and. ( (x>0) .and. (x<=lastrec()) )
            dbgoto(x)
            cost_rml->(dbappend())
            cost_rml->link      := cost_rmg->link
            cost_rml->effective := land->eff_to
            cost_rml->hotel     := land->hotel
            cost_rml->sgl_bed   := land->rm_sgl
            cost_rml->twn_bed   := land->rm_twn
            cost_rml->trp_bed   := land->rm_trp
            cost_rml->quad_bed  := land->rm_quad
            cost_rml->xtra_bed  := land->rm_xtrb
            if !empty(land->currency) .and. get_usd(land->currency)
               cost_rml->sgl_bed   := tousd(cost_rml->sgl_bed)
               cost_rml->twn_bed   := tousd(cost_rml->twn_bed)
               cost_rml->trp_bed   := tousd(cost_rml->trp_bed)
               cost_rml->quad_bed  := tousd(cost_rml->quad_bed)
               cost_rml->xtra_bed  := tousd(cost_rml->xtra_bed)
            endif
            cost_rml->(dbcommit())
    endif
    close land
    select cost_rml
return nil

static function helpme1()
    w_help := openwindow(05,20,21,60,"Help Window")
    @ 07,     22 say "ARROW UP/DN - Previous/Next Record."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Record."
    @ row()+1,22 say "HOME        - First Record on File."
    @ row()+1,22 say "END         - Last Record on File."
    @ row()+1,22 say "CTRL PGUP   - Skip Last 20 Records."
    @ row()+1,22 say "CTRL PGDN   - Skip Next 20 Records."
    @ row()+1,22 say "F1          - Help!."
    @ row()+1,22 say "F2          - Add Record."
    @ row()+1,22 say "F3          - Edit Record."
    @ row()+1,22 say "F4          - Delete Record."
    @ row()+1,22 say "F5          - Search Record."
    @ row()+1,22 say "            (CTRL+S to repeat search)"
    @ row()+1,22 say "F6          - Local Control."
    @ row()+1,22 say "ESC         - Exit Room Costing."
    message("Press any key...")
    inkey(0)
    closewindow(w_help)
return nil

static function helpme2()
    w_help := openwindow(05,20,18,60,"Help Window")
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
    @ row()+1,22 say "F6          - Global Control."
    @ row()+1,22 say "F8          - Land Tariff"
    message("Press any key...")
    inkey(0)
    closewindow(w_help)
return nil

static function search()
local w_search
    w_search := openwindow(08,20,14,60,"Search Window")
    @ 10, 25 say "       Validity" get s_effdate pict "99!!!99"
    @ 11, 25 say "          Label" get s_label pict "@!"
    @ 12, 25 say "Direction (F/B)" get s_dir pict "!" valid s_dir $ "FB"
    @ 13, 25 say " (CTRL+S to search next)"
    setcursor(SC_NORMAL)
    read
    setcursor(SC_NONE)
    closewindow(w_search)
    if (lastkey()!=K_ESC)  ; cost_rmg->(Find())  ;  endif
return nil

static function find()
local l_found := .F.
    Message("Searching records...")
    if (!empty(s_effdate) .or. !empty(s_label))
       if s_dir = "F"
          skip 1
          do while  !eof()
             if ( ( (etod(s_effdate) >= etod(valid_from)) .and. ;
                  ( (etod(s_effdate) <= etod(valid_to)) .or. empty(valid_to) ) ;
                  ) .or. empty(s_effdate))  .and. ;
                ((alltrim(s_label) $ label) .or. empty(s_label))
                l_found := .T.
                exit
             endif
             skip 1
          enddo
          if !l_found
             message("End of File reached...")
             tone(100,3)
             inkey(2)
             skip -1
          else
             message("Found...")
             tone(300,1)
          endif
       else
          skip -1
          do while !bof()
             if ( ( (etod(s_effdate) >= etod(valid_from)) .and. ;
                  ( (etod(s_effdate) <= etod(valid_to)) .or. empty(valid_to) ) ;
                  ) .or. empty(s_effdate))  .and. ;
                ((alltrim(s_label) $ label) .or. empty(s_label))
                l_found := .T.
                exit
             endif
             skip -1
          enddo
          if !l_found
             message("Beginning of File reached...")
             tone(100,3)
             inkey(2)
          else
             message("Found...")
             tone(300,1)
          endif
       endif
    endif
    return nil
// <eof> - room.prg //