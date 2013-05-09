/*
       Filename:  Update.Prg
         Author:  Rollie C. Ibarra
   Date-Started:  July 08, 1993
    Last-Update:  July 08, 1993
*/
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Janus.ch"

static TotPer

function PassUpdate()
local nDbf,out,wDate,wScr
public ni:=nH:=0
   dStartDate:=MASTER->(LUpdate())
   Message("Master File last update:"+dtoc(dStartDate)+" ; ESC to abort. ")
   wDate:=OpenWindow(09,15,12,63,"Date Information Box")
   @ 11,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   SetCursor(SC_NORMAL)
   SetKey(K_F1,{ || Help(7)})
   read
   SetKey(K_F1)
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   wScr:=OpenWindow(10,10,14,69,"Master File Update Window")
   @ 11,10 to 14,69
   @ 12,11 say "Updating from : Subsidiaries"
   @ 13,56 say "0% complete"
   out:= lastKey()==K_ESC
*******************************////subsidiaries\\\\\*****************************
   TotPer:=11.12
   TotRec:=1
   if !out .and. aChek_[1] .and. NetUse("d:\gldata\ARTI",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec:=LastRec()
     out:= Update(nDbf)
     ARTI->(DbCloseArea())
   endif

   TotPer:=22.23
   if !out .and. aChek_[2] .and. NetUse("d:\gldata\ARTA",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     ARTA->(DbCloseArea())
   endif

   TotPer:=33.34
   if !out .and. aChek_[3] .and. NetUse("d:\gldata\ARA",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     ARA->(DbCloseArea())
   endif

   TotPer:=44.45
   if !out .and. aChek_[4] .and. NetUse("d:\gldata\ARO",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     ARO->(DbCloseArea())
   endif

   TotPer:=55.56
   if !out .and. aChek_[5] .and. NetUse("d:\gldata\AFP",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     AFP->(DbCloseArea())
   endif

   TotPer:=66.67
   if !out .and. aChek_[6] .and. NetUse("d:\gldata\APO",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     APO->(DbCloseArea())
   endif

   TotPer:=77.78
   if !out .and. aChek_[7] .and. NetUse("d:\gldata\PRI",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     PRI->(DbCloseArea())
   endif

   TotPer:=88.89
   if !out .and. aChek_[8] .and. NetUse("d:\gldata\PRA",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     PRA->(DbCloseArea())
   endif

   TotPer:=100
   if !out .and. aChek_[9] .and. NetUse("d:\gldata\AEX",DB_SHARED,NUM_SECONDS)
     nDbf:=Select()
     TotRec+=LastRec()
     out:= Update(nDbf)
     AEX->(DbCloseArea())
   endif
   clear type
   Message(transform(nH,"9999")+" Record(s) Added ...")
   Inkey(1)
   CloseWindow(wScr)
return nil

static function Update(nDbfArea)
local lMatched
   @ 13,13 say transform(alias(),"!!!!")+" at Rec.# "
   do while !Eof() .and. nextKey() != K_ESC
   clea type
   lMatched:=.f.
   @ 13,27 say transform(RecNo(),"@B 9999")+space(23)+transform(ni/TotRec*TotPer,"999%")
   do while nextKey()!= K_ESC .and. ctod((nDbfArea)->DATE) < dStartDate .and.!EOF()
    clear type;(nDbfArea)->(DbSkip());ni++
*  Message("Updating form "+alias()+" at Rec.#"+transform(RecNo(),"@B 9999")+space(42)+transform(ni/TotRec*TotPer,"999%"))
   @ 13,27 say transform(RecNo(),"@B 9999")+space(23)+transform(ni/TotRec*TotPer,"999%")
   enddo
   /* test if particular lname is in master  */
   if MASTER->(DbSeek(substr((nDbfArea)->PARTICULAR,1,at(",",(nDbfArea)->PARTICULAR)-1)))
    /* do while particular lname is in Master */
    do while rtrim(MASTER->L_NAME) $ substr((nDbfArea)->PARTICULAR,1,at(",",(nDbfArea)->PARTICULAR)-1)
      /* test if particular fname is in master */
      if rtrim(MASTER->F_NAME) $ substr((nDbfArea)->PARTICULAR,at(",",(nDbfArea)->PARTICULAR)+2)
          lMatched:=.t.
      endif
      MASTER->(DbSkip())
    enddo
    endif
    if MASTER->(DbSeek(rtrim((nDbfArea)->PARTICULAR)))
        lMatched:=.t.
    endif

    if !lMatched .and. nextkey()!=K_ESC
      @ 13,27 say transform(RecNo(),"@B 9999")+space(23)+transform(ni/TotRec*TotPer,"999%")
      MASTER->(AddRec(0)); nH++
      MASTER->(FilLock(0))
      if "," $ (nDbfArea)->PARTICULAR
        MASTER->L_NAME:= substr((nDbfArea)->(PARTICULAR),1, at(",", (nDbfArea)->(PARTICULAR)) -1)
        MASTER->F_NAME:= substr((nDbfArea)->(PARTICULAR),at(",", (nDbfArea)->(PARTICULAR)) + 2)
      else
        MASTER->L_NAME:= (nDbfArea)->PARTICULAR
        MASTER->F_NAME:= ""
      endif
      MASTER->DATE:=(nDbfArea)->DATE
      MASTER->AIR_AGENCY:=(nDbfArea)->AIR_AGENCY
      MASTER->(DbUnLock())
      @ 12,48 say transform(nH,"9999")+" record(s) Added"
    endif
      (nDbfArea)->(DbSkip());ni++
   enddo
return nextkey()==K_ESC

function check()
local wList,aRec_:={},alist_:={} ,aCtr_:={},all_:={}
local wChk,ix,ixx,ixxx,xi,aray_:={}
 use MASTER.dbf
 set index to by_Lname,by_Fname
 Message("Press Enter to Check for Duplicate...,  F1-Help  ESC-Abort")
 inkey(0)
 do case
    case lastkey()==K_ESC
         keyboard(chr(K_ESC))
    case lastkey()==K_F1
         Help(8)
 endcase
 set exact on
 wList:=OpenWindow(6,7,20,72,"List of MASTER FILE Duplicate Entries")
 wChk:=OpenWindow(10,10,10,69,"Checking MASTER FILE for Duplicate Entries...")
 ixxx:= 0;xi:=7
 do while !Eof() .and. nextKey()!=K_ESC
 clea type
  aSize(aray_,0);aSize(aRec_,0)
  chr:=alltrim(L_NAME)
  aadd(aray_,alltrim(F_NAME));aadd(aRec_,recno())
  skip
  do while chr == alltrim(L_NAME)
    aadd(aray_,alltrim(F_NAME));aadd(aRec_,recno())
    skip
  enddo
  ctr:=len(aray_)
  if ctr > 1
  nrec:=recno()
  for ix:= 1 to ctr
   for ixx:=ix+1 to ctr
    if aray_[ix]==aray_[ixx]
    CloseWindow(wChk)
    ixxx++;if(xi<=19,xi++,scroll(7,7,20,71,1))
    cChr:=rTrim(MASTER->L_NAME)+", "+aray_[ix]
    goto aRec_[ix]
    cChr:=rTrim(L_name)+", "+aray_[ix]
    x:=aScan(aList_,cChr)
    if x == 0
       aAdd(aList_,cChr);aAdd(aCtr_,1)
       x:=len(aList_)
    else
       aCtr_[x]+= 1
    endif
    aAdd(all_,{cChr,aCtr_[x]})
    @ xi,8 say aList_[x]+" "+str(aCtr_[x])+" Duplicate Entrie(s)"
    delete
    aray_[ix]:= str(ixxx)
    @ row(),col() say "  Deleted...."
    OpenWindow(wChk)
*   wChk:=OpenWindow(10,10,10,69,"Checking MASTER FILE for Duplicate Entries...")
    endif
   next
  next
  goto(nrec)
  endif
 @ row(),58 say recNo() pict "99999"
 enddo
 CloseWindow(wChk)
 MASTER->(DbCloseArea())
 clea type
 if ixxx==0 .and. lastkey()!=K_ESC
 @ 10,25 say "No Duplictate Entries Found..."
 inkey(0)
 else
 do while lastkey()!= K_ESC
  inkey(0)
  do case
     case lastkey()==K_UP
             if (ixxx-13) > 1
             scroll(7,7,20,71,-1);ixxx--
             @ 7,8 say all_[ixxx-13,1]+" "+str(all_[ixxx-13,2])+" Duplicate Entrie(s)  Deleted...."
             else
             tone(100,.025)
             endif
     case lastkey()==K_DOWN
             if ixxx < len(all_)
             scroll(7,7,20,71,1);ixxx++
             @ 20,8 say all_[ixxx,1]+" "+str(all_[ixxx,2])+" Duplicate Entrie(s)  Deleted...."
             else
             tone(100,.025)
             endif
   endcase
 enddo
 endif
 set exact off
 CloseWindow(wList)
return nil

// eof // -->