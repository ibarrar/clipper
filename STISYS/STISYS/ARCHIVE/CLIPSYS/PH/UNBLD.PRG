// Filename:      UNBLD.PRG
// System-Name:   Passenger's History of Accounts System
// Module:        Printing of Unbilled Tickets
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Aug. 13, 1993
// Last-Update:   Aug. 13, 1993

#include "Mode.Ch"
#include "Inkey.Ch"
#include "SetCurs.Ch"
#include "FileIO.Ch"

static clname:="",cfname:= ""

function Unbill_paid(mL_NAME,mF_NAME)
local vPeso := vDollar := 0, lBill := .F.,  cTitle, cTicket := space(18)
local vTPesoBal := vTDollBal := vTBillPeso := vTBillDoll :=;
      vTpaidPeso := vTPaidDoll := 0
    lRead:=  .f.
*    lExist:= .f.
    Message("Printing Unbilled Reports....")
*        aUnpaid_:= {}
     for x:=1 to 5
        aDetails_:={}
*        aDetails2_:={}
        cDbf:=OpenBSP(x)
        do case
               case x==1 ; cTitle:="MCO's"
               case x==2 ; cTitle:="SERIES 2 Tickets"
               case x==3 ; cTitle:="Series 4 Tickets"
               case x==4 ; cTitle:="APOLLO Tickets"
               case x==5 ; cTitle:="ABACUS Tickets"
        endcase
        Message("Searching "+cTitle+"...")
     if (cDbf)->(DbSeek(mL_NAME))
        initName()
        do while mL_NAME $ clname .and. !Eof()
           if clname == mL_NAME .and. (empty(mF_NAME) .or. ;
              cfname = mF_NAME .or. mF_NAME $ cfname )

                if empty( (cDbf)->BILL_1NO + (cDbf)->BILL_2NO + ;
                          (cDbf)->OR_1NO   + (cDbf)->OR_2NO ) .and. ;
                     !("VOID" $ upper((cDbf)->PASSENGER))
                     Message("Printing "+Alias()+" - Rec# "+;
                            transform((cDbf)->(RecNo()),"9999")+"...")
                     if cTicket $ (cDbf)->TICKET_NO
                         aAdd(aDetails_,{(cDbf)->DATE,;
                            space(18),;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99"),;
                            rtrim((cDbf)->PASSENGER)})
                     else
                        aAdd(aDetails_,{(cDbf)->DATE,;
                            substr((cDbf)->TICKET_NO,1,18),;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99"),;
                            rtrim((cDbf)->PASSENGER)})
                     endif
                     vDollar += (cDbf)->REMIT_D+(cDbf)->TAX_D
                     vPeso += (cDbf)->REMIT_P+(cDbf)->TAX_P
                     cTicket := substr((cDbf)->TICKET_NO,1,18)
                     if !lRead
                         ?
                         ? " Unbilled Tickets Report"
                         lRead:=.t.
                     endif

                endif

/*                if ( (cdbf)->BILL_1AMTP + (cdbf)->BILL_2AMTP > ;
                     (cdbf)->OR_1AMTP   + (cdbf)->OR_1AMTP  ) .or. ;
                   ( (cdbf)->BILL_1AMTD + (cdbf)->BILL_2AMTD > ;
                     (cdbf)->OR_1AMTD   + (cdbf)->OR_1AMTD  ) .and.;
                     (at("VOID",upper((cDbf)->PASSENGER))==0)
                     vPesoBal :=( (cdbf)->BILL_1AMTP+(cdbf)->BILL_2AMTP;
                     -(cdbf)->OR_1AMTP+(cdbf)->OR_2AMTP)
                     vDollBal :=( (cdbf)->BILL_1AMTD+(cdbf)->BILL_2AMTD;
                     -(cdbf)->OR_1AMTD+(cdbf)->OR_2AMTD )

                      aAdd(aDetails2_,{(cDbf)->DATE,substr((cDbf)->TICKET_NO,1,18),;
                            (cDbf)->PASSENGER,;
                            (cDbf)->BILL_1AMTP+(cDbf)->BILL_2AMTP,;
                            (cDbf)->BILL_1AMTD+(cDbf)->BILL_2AMTD,;
                            (cDbf)->OR_1AMTP+(cDbf)->OR_2AMTP,;
                            (cDbf)->OR_1AMTD+(cDbf)->OR_2AMTD,;
                            vPesoBal,vDollBal})
                      lExist:= .t.
                  endif */
           endif
           (cDbf)->(DBSkip())
           initName()
        enddo
            (cDbf)->(DbCloseArea())
            if len(aDetails_)>0
            xDetail1_Header(ctitle)
            for v:=1 to len(aDetails_)
               ? space(1)
               ?? aDetails_[v][1]
               ?? space(2)
               ?? aDetails_[v][2] + space(2)
               ?? aDetails_[v][3] + space(2)
               ?? aDetails_[v][4]
               if loption
               ?? space(2) + aDetails_[v][5] ;endif
            next
            endif
     endif
*     aAdd(aUnpaid_,aDetails2_)
     next
         if lRead
         ? space(29)+repl('-',25)
         ? space(29)+transform(vPeso,"9,999,999.99")
         ?? space(0)+transform(vDollar,"9,999,999.99")
         endif

/*     if lExist
        ?
        ? " Unpaid Tickets Report"
        for x:=1 to 4
        do case
               case x==1 ; cTitle:="MCO's            "
               case x==2 ; cTitle:="Series 2 Tickets "
               case x==3 ; cTitle:="Series 4 Tickets "
               case x==4 ; cTitle:="Automated Tickets"
        endcase
        if len(aUnpaid_[x])>0
            ? space(1) + ctitle

            ?? space(19)+ " Billed Amount"+space(10)
            ?? "  Paid Amount " + space(11)
            ?? "   Balance "
            ? space(1) + " Date   " + space(2) + "Ticket/MCO#" + space(15)
            ?? repl("Peso      Dollar" + space(8),2)
            ?? "Peso      Dollar"
            if loption ; ?? "  Passenger" ; endif
        endif
            for v:= 1 to len(aUnpaid_[x])
                ? space(1)
                ?? aUnpaid_[x,v,1]
                ?? space(2) + aUnpaid_[x,v,2]
                ?? transform(aUnpaid_[x,v,4],"9,999,999.99")
                ?? transform(aUnpaid_[x,v,5],"9,999,999.99")
                ?? transform(aUnpaid_[x,v,6],"9,999,999.99")
                ?? transform(aUnpaid_[x,v,7],"9,999,999.99")
                ?? transform(aUnpaid_[x,v,8],"9,999,999.99")
                ?? transform(aUnpaid_[x,v,9],"9,999,999.99")
                if loption ; ?? space(2) + rTrim(aUnpaid_[x,v,3]);endif
                vTBillPeso+=aUnpaid_[x,v,4]
                vTBillDoll+=aUnpaid_[x,v,5]
                vTPaidPeso+=aUnpaid_[x,v,6]
                vTPaidDoll+=aUnpaid_[x,v,7]
                vTPesoBal +=aUnpaid_[x,v,8]
                vTDollBal +=aUnpaid_[x,v,9]
            next
        next
                ? +repl('-',103)
                ? space(29)
                ?? transform(vTBillPeso,"9,999,999.99")
                ?? transform(vTBillDoll,"9,999,999.99")
                ?? transform(vTPaidPeso,"9,999,999.99")
                ?? transform(vTPaidDoll,"9,999,999.99")
                ?? transform(vTPesoBal, "9,999,999.99")
                ?? transform(vTDollBal, "9,999,999.99")
     endif
*/
return nil

static function initName()
  if "," $ (cDBf)->PASSENGER
    clname:=substr((cDbf)->PASSENGER, 1, at(",",(cDbf)->PASSENGER) -1 )
    cfname:=rtrim(substr((cDbf)->PASSENGER,at(",",(cDbf)->PASSENGER) +2 ))
  else
    clname:=rTrim((cDbf)->PASSENGER)
    cfname:= ""
  endif
return nil


function OpenBSP(nFnum)
    set(_SET_PATH,"d:\BSPDATA")
    do case
       case nFnum==1
          if NetUse("MCO",DB_SHARED,NUM_SECONDS)
             set index to MCOPAX,MCO,MCOTKT
          endif
       case nFnum==2
          if NetUse("SERIES2",DB_SHARED,NUM_SECONDS)
             set index to SERIES2P,SERIES2,SERIES2T
          endif
       case nFnum==3
          if NetUse("SERIES4",DB_SHARED,NUM_SECONDS)
             set index to SERIES4P,SERIES4,SERIES4T
          endif
       case nFnum==4
          if NetUse("APOLLO",DB_SHARED,NUM_SECONDS)
             set index to APOLLOP,APOLLO,APOLLOT
          endif
       case nFnum==5
          if NetUse("ABACUS",DB_SHARED,NUM_SECONDS)
             set index to ABACUSP,ABACUS,ABACUST
          endif
    endcase
    set(_SET_PATH,"d:\MDATA")
return (Alias())

static function xDetail1_Header(cTitle)
   ? space(1)+ctitle
   ? space(02)+" Date    Ticket/MCO#           Peso Amt  Dollar Amt"
   if loption
   ?? "  Passenger";endif
return nil

// <Eof> - UNBLD.prg