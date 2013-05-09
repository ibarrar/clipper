// Filename:      REPORTS.PRG
// System-Name:   Super Travel Costing Software
// Module:        Report Module
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Sept 18, 1993
// Last-Update:   Sept 18, 1993

#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "Mode.ch"
#include "Printer.ch"

function Land_Report()
   if Get1Info()
      if isprinter()
         Message("Thinking...")
         use LAND new
         set filter to ( Eff_From <= dStartDate ) .and. ;
                       ( if(empty(Eff_Till),Eff_To,Eff_Till) >= dEndDate )
         go top
         Message("Insert 132 column paper and press any key...")
         inkey(0)
         set console off
         set printer on
*        set alternate to "Temp.TXT"
*        set alternate on
         ?? chr(27) + chr(64)
         ?? chr(27) + chr(119) + chr(1)              // Double Heigth
         ?? chr(27) + chr(107) + chr(0)              // Roman Type
         ?? chr(27) + chr(120) + chr(1)              // NLQ on
         ?? "Super Travel, Inc."
         ?
         ? "þLand Tariff Report"
         ?
         ? "Period :" + dtoe( dStartDate ) + " to " + dtoe( dEndDate )
         ?? if(!empty(cCity),"    ("+alltrim(cCity)+")","")
         ?
         ?? chr(27) + chr(119)+ chr(0)               // Double Heigth off
         ?? chr(15)                                  // Condense on
         ? space(37) + "ÚÄÄÄÄÄÄ 4D3N PKG ADT ÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄ 3D2N PKG ADT ÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄ 4D3N PKG CHD ÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄ X/N ÄÄÄÄÄÄÄÄÄÄÄ¿"
         ? space(37) + "1/2                           1/2                           1/2                           HTWNB     SGLB      XB        HOTEL     OW        CITY"
         ? space(3)  + "EFFECTIVITY     UNTIL   AGN  HTL  TWNB      SGLB      XBED      TWNB      SGLB      XBED      TWNB      XBED      NOBED     + ABF     + ABF     + ABF     ABF       TRSF      TOUR      REMARKS     CITY          CUR"
         ?? chr(27) + chr(120) + chr(0)              // NLQ off
         do while LAND->(!Eof())
            Message("Printing Land Tariff Rec# " + transform(RecNo(),"9999") )
            if  ( alltrim(cCity) $ City ) .or. empty( cCity )
                ? " " + DtoE( Eff_From ) + "-" + DtoE( Eff_To )
                ?? space(2) + DtoE( if(empty(Eff_Till),Eff_To,Eff_Till ))
                ?? space(2) + Agency
                ?? space(2) + Hotel
                ?? space(2) + transform( Htwn_4D3NA,"99999.99" )
                ?? space(2) + transform( Sglb_4D3NA,"99999.99" )
                ?? space(2) + transform( Xtrb_4D3NA,"99999.99" )
                ?? space(2) + transform( HTwn_3D2N, "99999.99" )
                ?? space(2) + transform( Sglb_3D2N, "99999.99" )
                ?? space(2) + transform( Xtrb_3D2N, "99999.99" )
                ?? space(2) + transform( HTwn_4D3NC,"99999.99" )
                ?? space(2) + transform( Xtrb_4D3NC,"99999.99" )
                ?? space(2) + transform( Nob_4D3NC, "99999.99" )
                ?? space(2) + transform( Xn_HTwn,   "99999.99" )
                ?? space(2) + transform( Xn_Sglb,   "99999.99" )
                ?? space(2) + transform( Xn_Xtrb,   "99999.99" )
                ?? space(2) + transform( Hotel_ABF, "99999.99" )
                ?? space(2) + transform( Ow_Trsf,   "99999.99" )
                ?? space(2) + transform( Tour,      "99999.99" )
                ?? space(2) + Remark
                ?? space(2) + City
                ?? space(2) + Currency
            endif
            DbSkip()
         enddo
         ? repl('=',219)
         ? chr(12)
         DbCloseArea()
         set printer off
*        set alternate off
         set console on
         Message("Printing Done...")
         tone(300,1)
         inkey(2)
      else
         Message("Printer not ready...")
         tone(100,3)
         inkey(2)
      endif
   endif
return nil

function Air_Report()
   if Get1Info()
      if isprinter()
         Message("Thinking...")
         set console off
         set printer on
*        set alternate to "Temp.TXT"
*        set alternate on
         ?? chr(27) + chr(64)
         ?? chr(27) + chr(119)+ chr(1)               // Double Heigth
         ?? chr(27) + chr(107)+chr(0)                // Roman Type
         ?? chr(27) + chr(120)+chr(1)                // NLQ on
         ?? "Super Travel, Inc."
         ?
         ? "þAir Tariff Report"
         ?
         ? "Period :" + dtoe( dStartDate ) + " to " + dtoe( dEndDate )
         ?? if(!empty(cCity),"    ("+alltrim(cCity)+")","")
         ?
         ?? chr(27) + chr(119)+ chr(0)               // Double Heigth off
         ?? "   EFFECTIVITY           AIRLINE        ADULT      CHILD"
         ?? "           ROUTE"
         ?? chr(27)+chr(120)+chr(0)                  // NLQ off
         use AIR new
         set filter to ( Eff_From <= dStartDate ) .and. ;
                       ( Eff_To   >= dEndDate )
         go top

         Message("Insert 80 column paper and press any key...")
         inkey(0)
         do while AIR->(!Eof())
            Message("Printing Air Tariff Rec# "+transform(AIR->(RecNo()),"9999"))
            if ( (alltrim(cCity) $ Route) .or. empty(cCity) )
                ? " " + dtoe( Eff_From ) + "-" + dtoe( Eff_To )
                ?? space(2) + Airline
                ?? space(2) + transform( Adult,"999999.99" )
                ?? space(2) + transform( Child,"999999.99" )
                ?? space(2) + Route
            endif
            DbSkip()
         enddo
         ? repl('=',99)
         ? chr(12)
         DbCloseArea()
         set printer off
*        set alternate off
         set console on
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer not ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

function Room_Report()
   if Get1Info()
      if isprinter()
         Message("Thinking...")
         set console off
         set printer on
*        set alternate to "Temp.TXT"
*        set alternate on
         ?? chr(27) + chr(64)
         ?? chr(27) + chr(119) + chr(1)              // Double Heigth
         ?? chr(27)+chr(107)+chr(0)                  // Roman Type
         ?? chr(27)+chr(120)+chr(1)                  // NLQ on
         ?? "Super Travel, Inc."
         ?
         ? "þRoom Tariff Report"
         ?
         ? "Period :" + dtoe( dStartDate ) + " to " + dtoe( dEndDate )
         ?? if(!empty(cCity),"    ("+alltrim(cCity)+")","")
         ?
         ?? chr(27) + chr(119)+ chr(0)               // Double Heigth off
         ?? chr(15)
         ?  space(3) + "EFFECTIVITY     UNTIL   CTY  HTL     SGLB       "
         ?? "TWNB       TRPB       QUAD       XTRB     CUR"
         ?? chr(27) + chr(120) + chr(0)              // NLQ off
         use LAND new
         set filter to ( Eff_From >= dStartDate ) .and. ;
                       ( if(empty(Eff_Till),Eff_To,Eff_Till) <= dEndDate )
         go top
         Message("Insert 132 column paper and press any key...")
         inkey(0)
         do while LAND->(!Eof())
            Message("Printing Land Tariff Rec# "+transform((RecNo()),"9999"))
            if ( (alltrim(cCity) $ City) .or. empty(cCity) )
                ? " " + DtoE( Eff_From ) + "-" + DtoE( Eff_To )
                ?? space(2) + DtoE( if(empty(Eff_Till),Eff_To,Eff_Till) )
                ?? space(2) + City
                ?? space(2) + Hotel
                ?? space(2) + transform(Rm_Sgl,"999999.99")
                ?? space(2) + transform(Rm_Twn,"999999.99")
                ?? space(2) + transform(Rm_Trp,"999999.99")
                ?? space(2) + transform(Rm_Quad,"999999.99")
                ?? space(2) + transform(Rm_Xtrb,"999999.99")
                ?? space(2) + Currency
            endif
            DbSkip()
         enddo
         ? repl('=',106)
         set margin to
         ? chr(12)
         DbCloseArea()
         set printer off
*        set alternate off
         set console on
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer not ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

static function Get1Info()
local wInfo, crs
   dStartDate:= dEndDate:= space(7)
   cCity := space(12)
   Message("Enter transaction dates and City code, press Esc to abort.")
   wInfo:=OpenWindow(08,15,15,64,"Date Information Box")
   @ 10,25 say "Starting date (ddmmmyy)" get dStartDate pict "99!!!99"
   @ 12,25 say "  Ending date (ddmmmyy)" get dEndDate pict "99!!!99"
   @ 14,25 say "              City Code" get cCity pict "@!"
   crs := SetCursor( SC_NORMAL )
   read
   SetCursor( crs )
   CloseWindow(wInfo)
   dStartDate := etod(dStartDate)
   dEndDate := etod(dEndDate)
return If(LastKey()==K_ESC,.F.,.T.)

function Print_Pack()
local wScreen, i, lFound
private _aSti, _aAc, _aMisc
private aTotal1, aTotal2, aEntries, cLabel, cHotel, nOpt
   if Get2Info()
       if isPrinter()
         use cost_pkl index cost_pkl new
         use cost_pkg new
         set filter to (Valid_From >= dStartDate) .and. ;
                       (Valid_To <= dEndDate)
         go top
         set console off
         set printer on
*        set alternate to "Temp.Txt"
*        set alternate on
         ?? chr(27) + chr(64)
         ?? chr(27) + chr(119) + chr(1)              // Double Heigth
         ?? chr(27) + chr(107) + chr(0)              // Roman Type
         ?? chr(27) + chr(120) + chr(1)              // NLQ on
         ?? "Super Travel, Inc."
         ?
         ? "þPackage Costing Report -",alltrim(cLabel),;
           "   (Validity-" + DtoE( dEndDate ) +")"
         ?
         ?? chr(27) + chr(119)+ chr(0)               // Double Heigth off
         if nOpt==1
            set margin to 10
         else
            ?? chr(15)                               // Condense on
         endif
         ? space(8),"  ADT      ADT      CHD      CHD     CHD       "
         if nOpt == 2
            ?? "SGL     XN TWNB  XN SLGB  XN XBED +---- 3D2N DEDUCTION ---+    HTL              ROOM"
         endif
         ? space(8),"  TWNB     XBED     TWNB     XBED    NO BED    "
         if nOpt == 2
            ?? "SUPP     + ABF    + ABF    + ABF   TWNB     SGLB     XBED      ABF     LAND     TWNB"
         endif
         ? repl('=',if(nOpt==1,55,143))
         ?
         ?? chr(27)+chr(120)+chr(0)                  // NLQ off
         do while cost_pkg->(!eof())
            Message("Reading Rec#"+transform(RecNo(),"9999"))
            InitArrays()
            if (empty(cLabel) .or. (alltrim(cLabel) $ Label) ) .and. ;
               (empty(cHotel) .or. (ascan(aEntries,{|x| cHotel $ x[17]}) # 0))
               Message("Printing Rec#"+transform(RecNo(),"9999"))
               ? "Record #", transform(recno(),"9999")
               for x:=1 to len(aEntries)
                  ? if(aEntries[x][16]=='A',;
                        "  Air -",;
                        substr(aEntries[x][17],1,7)) + space(2)
                  ?? transform(aEntries[x][1],"9999.99") + space(2)
                  ?? transform(aEntries[x][2],"9999.99") + space(2)
                  ?? transform(aEntries[x][3],"9999.99") + space(2)
                  ?? transform(aEntries[x][4],"9999.99") + space(2)
                  ?? transform(aEntries[x][5],"9999.99") + space(2)
                  if nOpt == 2
                     ?? transform(aEntries[x][6],"9999.99") + space(2)
                     ?? transform(aEntries[x][7],"9999.99") + space(2)
                     ?? transform(aEntries[x][8],"9999.99") + space(2)
                     ?? transform(aEntries[x][9],"9999.99") + space(2)
                     ?? transform(aEntries[x][10],"9999.99") + space(2)
                     ?? transform(aEntries[x][11],"9999.99") + space(2)
                     ?? transform(aEntries[x][12],"9999.99") + space(2)
                     ?? transform(aEntries[x][13],"9999.99") + space(2)
                     ?? transform(aEntries[x][14],"9999.99") + space(2)
                     ?? transform(aEntries[x][15],"9999.99")
                  endif
                  if aEntries[x][16]=='A'
                     ? padr(alltrim(aEntries[x][17],1,7)+' ',if(nOpt==1,55,143),'-')
                  endif
               next
               ? repl('-',if(nOpt==1,55,143))
               ? "  SubTtl "
               for x:=1 to if(nOpt==1,5,15)
                  ?? transform(aTotal1[x],"9999.99") + space(2)
               next
               ? "    Misc "
               for x:=1 to if(nOpt==1,5,15)
                  ?? transform(_aMisc[x],"9999.99") + space(2)
               next
               ? "     STI "
               for x:=1 to if(nOpt==1,5,15)
                  ?? transform(_aSti[x],"9999.99") + space(2)
               next
               ? "      AC "
               for x:=1 to if(nOpt==1,5,15)
                  ?? substr(_aAc[x],2,7) + space(2)
               next
               ? repl('-',if(nOpt==1,55,143))
               ? "   Total "
               for x:=1 to if(nOpt==1,5,15)
                  ?? transform(aTotal2[x],"9999.99") + space(2)
               next
               ? repl('=',if(nOpt==1,55,143))
               ?
            endif
            dbskip()
         enddo
         ? chr(12)
         set printer off
*        set alternate off
         set console on
         cost_pkl->(DbCloseArea())
         cost_pkg->(DbCloseArea())
         message("Printing Done...")
         tone(300,1)
         inkey(2)
      else
         message("Printer Not Ready...")
         tone(100,3)
         inkey(2)
       endif
   endif
return nil

static function initarrays()
     select cost_pkg
     _aMisc := {}  ;  _aSti := {}  ;  _aAc := {}  ;  aEntries := {}
     for x:=  1 to 15
           aadd( _aMisc,FieldGet(x+1) )
           aadd( _aSti, FieldGet(x+16) )
           aadd( _aAc,  FieldGet(x+31) )
     next
     for x:=1 to 15
        _aAc[x] := padl(alltrim(_aAc[x]),8)
     next
     select cost_pkl
     dbseek(cost_pkg->link)
     do while !eof() .and. (link==cost_pkg->link )
        aadd(aEntries,{adt_twnb,adt_xtrb,;
                        chd_twnb,chd_xtrb,chd_nob,sglb_supp,;
                        xn_twnb,xn_sglb,xn_xtrb,;
                        twnb_3d2n,sglb_3d2n,xbed_3d2n,;
                        hotel_abf,land,rm_twnb,loc_type,agent,;
                        recno()})
        cost_pkl->(dbskip())
     enddo
     aTotal1 := {} ; aTotal2 := {}
     aTotal1 := afill( array(15),0 )
     aTotal2 := afill( array(15),0 )
     for x := 1 to len(aEntries)
        for z:= 1 to 15
             aTotal1[z] += aEntries[x][z]
        next
     next
     for x:=1 to 15
        if at('%',_aAc[x]) # 0
           u := val(_aAc[x])
           aTotal2[x]:=(aTotal1[x] + _aSti[x] + _aMisc[x]) / (1 - (u/100))
        else
           aTotal2[x]:= aTotal1[x] + _aSti[x] + _aMisc[x] + val(_aAc[x])
        endif
     next
     select cost_pkg
return nil

function Print_Room()
private _Label, m_valid, _aSti, _aAc, _aMisc
private aTotal1, aTotal2, aTotal3, cLabel, cHotel
   if Get2Info()
      if IsPrinter()
         use COST_RML index COST_RML new
         use COST_RMG new
         set filter to
         set console off
*        set printer on
         set alternate to "Temp.Txt"
         set alternate on
         ? "Super Travel, Inc."
         ? "þRoom Costing Report -",alltrim(cLabel),"   (Validity-"+dEndDate+")"
         ?
         ? space(14), "Single    Twin     Triple     Quad      Extra"
         ? space(14), "Bed       Bed      Bed        Bed       Bed"
         ? repl('=',64)
         ?
         do while COST_RMG->(!Eof())
            if ((etod(COST_RMG->VALID)>=etod(dStartDate)) .and. ;
                (etod(COST_RMG->VALID)<=etod(dEndDate)) .and. ;
                ((alltrim(cLabel) $ COST_RMG->LABEL) .or. empty(cLabel)) )
            Message("Reading Room Cost Rec #"+;
                     transform(COST_RMG->(RecNo()),"9999") )
               init2arrays()
               COST_RML->(DbSeek(COST_RMG->LINK ))
               do while (COST_RMG->LINK==COST_RML->LINK)
                  ? COST_RML->HOTEL + space(8)
                  ?? transform(COST_RML->SGL_BED ,"99999.99") + space(2)
                  ?? transform(COST_RML->TWN_BED ,"99999.99") + space(2)
                  ?? transform(COST_RML->TRP_BED ,"99999.99") + space(2)
                  ?? transform(COST_RML->QUAD_BED,"99999.99") + space(2)
                  ?? transform(COST_RML->XTRA_BED,"99999.99") + space(2)
                  COST_RML->(DbSkip())
               enddo
               ? repl('-',64)
               ? "    MISC      "
               for x:=1 to 5
                  ?? transform(_aMisc[x],"99999.99") + space(2)
               next
               ? repl('-',64)
               ? "SUBTOTAL      "
               for x:=1 to 5
                  ?? transform(aTotal2[x],"99999.99") + space(2)
               next
               ? "     STI      "
               for x:=1 to 5
                  ?? transform(_aSti[x],"99999.99") + space(2)
               next
               ? "      AC      "
               for x:=1 to 5
                  ?? substr(_aAc[x],1,8) + space(2)
               next
               ? repl('-',64)
               ? "   TOTAL      "
               for x:=1 to 5
                  ?? transform(aTotal3[x],"99999.99") + space(2)
               next
               ?
               ?
            endif
            COST_RMG->(DbSkip())
         enddo
         Set(_SET_ALTERNATE,.F.)
         Set(_SET_ALTFILE,"")
         Set(_SET_CONSOLE,.T.)
         COST_RML->(DbCloseArea())
         COST_RMG->(DbCloseArea())
         Message("Insert 80 column paper and presss any key...")
         inkey(0)
         Message("Printing...")
         cReport:=MemoRead("CROOM.RPT")
         nLines:=MLCount(cReport,225)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         ?? chr(27) + chr(80) + chr(18)
         SetPrinter(_SET_HEIGHT,P_DOUBLE)
         SetPrinter(_SET_EMPH_aSIZED,.T.)
         SetPrinter(_SET_QUALITY,P_NLQ)
         ?? MemoLine(cReport,70,2)
         ?
         ?  MemoLine(cReport,70,3)
         SetPrinter(_SET_HEIGHT,P_NORMAL)
         SetPrinter(_SET_PITCH,P_12_PITCH)
         ?
         Set(_SET_MARGIN,15)
         ? "Page : 1"
         Head1 := MemoLine(cReport,70,5)
         Head2 := MemoLine(cReport,70,6)
         Head3 := MemoLine(cReport,70,7)
         ?  Head1  ;  ? Head2  ;  ? Head3
         SetPrinter(_SET_QUALITY,P_DRAFT)
         SetPrinter(_SET_EMPH_aSIZED,.F.)
         nLCount:=8  ; nPage := 1
         for x:=8 to nLines
             ? MemoLine(cReport,70,x)
             nLCount ++
             if nLCount > 57
                ? chr(12)
                nPage ++
                SetPrinter(_SET_EMPH_aSIZED,.T.)
                SetPrinter(_SET_QUALITY,P_NLQ)
                ? "Page :"+transform(nPage,"99")
                ?  Head1  ;  ? Head2  ;  ? Head3
                SetPrinter(_SET_QUALITY,P_DRAFT)
                SetPrinter(_SET_EMPH_aSIZED,.F.)
                nLcount := 5
             endif
         next
         ? chr(12)
         Set(_SET_MARGIN,0)
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         Message("Printing Done...")
         Tone(300,1)
         Inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         Inkey(2)
      endif
   endif
return nil

static function init2arrays()
     select cost_rmg
     m_label := label
     m_valid := valid
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
     a_total1 := {} ; a_total2 := {} ; a_total3 := {}
     a_total1 := afill(array(5),0.00)
     a_total2 := afill(array(5),0.00)
     a_total3 := afill(array(5),0.00)
     for x := 1 to len(a_entries)
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
return nil

static function Get2Info()
local wInfo, crs
   dStartDate:= dEndDate:= space(7)
   cLabel := space(12)
   cHotel := space(3)
   nOpt := 1
   message("Enter transaction dates and City code, press Esc to abort.")
   wInfo:=OpenWindow(07,15,18,64,"Date Information Box")
   @ 09,22 say " Label/Description Code" get cLabel     pict "@!"
   @ 11,22 say "             Hotel Code" get cHotel     pict "@!"
   @ 13,22 say "Starting date (ddmmmyy)" get dStartDate pict "99!!!99"
   @ 15,22 say "Validity date (ddmmmyy)" get dEndDate   pict "99!!!99"
   @ 17,22 say "     Print Option (1/2)" get nOpt       pict "9"
   crs := SetCursor( SC_NORMAL )
   read
   SetCursor( crs )
   CloseWindow(wInfo)
   dStartDate := etod(dStartDate)
   dEndDate := etod(dEndDate)
return If(LastKey()==K_ESC,.F.,.T.)

//<eof> - Reports.Prg //