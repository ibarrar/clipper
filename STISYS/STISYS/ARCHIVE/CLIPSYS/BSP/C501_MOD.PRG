/********************************************************************
* Filename:      C501_MOD.PRG
* Module:        Clipper 5.01 Support module
* Author:        Rollie C. Ibarra Jr.
* Date-Started:  October 06, 1993
* Last-Update:   October 06, 1993
*
********************************************************************/

#include "c501_mod.ch"

/*****************************
* Status Bar functions
*/
function stat_msg(cmsg)
local ccolor:=setcolor()                    //save default color
     setcolor(if(iscolor(),"N/BG","N/W"))
     if cmsg==NIL                           //resolve parameter
        @ 24,0
     else
        if len(cmsg) > 79                   // check string length
           cmsg:=substr(cmsg,1,79)
        endif
        @ 24,0 say " "+cmsg
     endif
     setcolor(ccolor)                       // restore defaults
return nil

function stat_query(cquery)
local ccolor:=setcolor()                    //save default color
     setcolor(if(iscolor(),"N/BG","N/W"))
     if cquery==NIL                         //resolve parameter
        @ 24,0
        return false
     else
        if len(cquery) > 79                 // check string length
           cquery:=substr(cquery,1,79)
        endif
        @ 24,0 say " "+cquery
     endif
     setcolor(ccolor)                       // restore defaults
return (upper(chr(inkey(0)))='Y')

function stat_pause()
local ccolor:=setcolor()                    //save default color
     setcolor(if(iscolor(),"N/BG","N/W"))
     if cmsg==NIL                           //resolve parameter
        @ 24,0
     else
        if len(cmsg) > 79                   // check string length
           cmsg:=substr(cmsg,1,79)
        endif
        @ 24,0 say " "+cmsg
     endif
     setcolor(ccolor)                       // restore defaults
     inkey(2)                               // suspend for 2 secs
return nil

/*****************************
* Database insertion function
*/
function dbinsert()
local nRecno:=recno(),nOrder:=indexord()
local astruct1:={},astruct2
    dbsetorder(0)
    dbappend()
    dbgoto(nRecno)
    for xx:=1 to fcount()
        aadd(astruct1,&(field(xx)) )
        do case
            case valtype(&(field(xx)) )="C"
                replace &(field(xx)) with space(len( &(field(xx)) ))
            case valtype(&(field(xx)) )="N"
                replace &(field(xx)) with 0.00
            case valtype(&(field(xx)) )="D"
                replace &(field(xx)) with ctod("")
        endcase
    next
    astruct2:=aclone(astruct1)
    dbskip()
    do while !eof()
        stat_msg("Moving Rec#"+transform(recno(),"9999"))
        for xx:=1 to fcount()
            astruct2[xx]:=&(field(xx))
        next
        for xx:=1 to fcount()
            replace &(field(xx)) with astruct1[xx]
        next
        astruct1:={}
        astruct1:=aclone(astruct2)
        dbskip()
    enddo
    dbgoto(nRecno)
    astruct1:=astruct2:={}
    dbsetorder(nOrder)
return nil

/*****************************
* Enhanced date functions
*/
function compress(cdate)
    if empty(cdate)
       return ctod("")
    endif
    cdate:=upper(cdate)
    dy:=substr(dtoc(date),1,2)
    mo:=substr(dtoc(date),3,3)
    yr:=substr(dtoc(date),6,2)
    do case
      case mo:='JAN'    ;   mo:='01'
      case mo:='FEB'    ;   mo:='02'
      case mo:='MAR'    ;   mo:='03'
      case mo:='APR'    ;   mo:='04'
      case mo:='MAY'    ;   mo:='05'
      case mo:='JUN'    ;   mo:='06'
      case mo:='JUL'    ;   mo:='07'
      case mo:='AUG'    ;   mo:='08'
      case mo:='SEP'    ;   mo:='09'
      case mo:='OCT'    ;   mo:='10'
      case mo:='NOV'    ;   mo:='11'
      case mo:='DEC'    ;   mo:='12'
    endcase
return ctod(dy+'-'+mo+'-'+yr)

function expand(date)
    if date == ctod("  -  -  ")
       return space(7)
    endif
    mo:=substr(dtoc(date),1,2)
    yr:=substr(dtoc(date),7,2)
    dy:=substr(dtoc(date),4,2)
    do case
      case mo=='01'     ;   mo:='JAN'
      case mo=='02'     ;   mo:='FEB'
      case mo=='03'     ;   mo:='MAR'
      case mo=='04'     ;   mo:='APR'
      case mo=='05'     ;   mo:='MAY'
      case mo=='06'     ;   mo:='JUN'
      case mo=='07'     ;   mo:='JUL'
      case mo=='08'     ;   mo:='AUG'
      case mo=='09'     ;   mo:='SEP'
      case mo=='10'     ;   mo:='OCT'
      case mo=='11'     ;   mo:='NOV'
      case mo=='12'     ;   mo:='DEC'
    endcase
return (dy+mo+yr)

/*****************************
* Array total function
*/
function atotal(aarray, cell)
local total:=0
   aeval(aarray,{|x| total += x[cell]})
return total

/*****************************
* sti printout header function
*/
function sti_header(nMode)
    lPrt := Set(_SET_PRINTER,.T.)
    ?? chr(18) + chr(27) + chr(80)   // select 10 pitch & normal size
    ?? chr(27) + chr(120) + chr(1)   // select NLQ
    ?? chr(27) + chr(107) + chr(0)   // select Roman
    ?? chr(27) + chr(87)  + chr(1)   // turn on Double width
    ?? chr(27) + chr(69)             // select Emphasized
    ?? space(if(nMode=1,12,25)) + "SUPER TRAVEL, INC."
    ?? chr(27) + chr(70)             // cancel Emphasized
    ?? chr(27) + chr(87)  + chr(0)   // turn off Double width
    ?? chr(15)                       // select Condensed
    ?  space(if(nMode=1,46,90)) + "             Ground Floor, VIP Building"
    ?  space(if(nMode=1,46,90)) + " 1154 Roxas Boulevard, Ermita, Manila, Philippines"
    ?  space(if(nMode=1,46,90)) + "               Tel. No. 59-60-02 to 05 "
    ?? chr(18)                       // cancel Condensed
    ?
    set(_SET_PRINTER,lPrt)
return nil

/*****************************
* printing function
*/
function blank_ifzero(v,c)
return if(v==0.00,space(len(c)),transform(v,c))

function sti_logo()
   setcolor("R/B")
   @ 02, 00 say ""
   @ row()+1,0 say "   кФФФФФФФФФФФФФФФФФФФФФФФФФФФП                                           "
   @ row()+1,0 say "   Г            ммммм          УФП                                         "
   @ row()+1,0 say "   Г          млллллллм        Г Г   мммм  мм  мм ммммм  ммммм ммммм       "
   @ row()+1,0 say "   Г     ммм  плллллллп        Г Г  лл  пп лл  лл лл  лл лл    лл  лл      "
   @ row()+1,0 say "   Г    лллллм  ппппп          Г Г   пллм  лл  лл ллммлп ллмм  ллммлп      "
   @ row()+1,0 say "   Г     плллллм               Г Г  мм  лл лл  лл лл     лл    лл  лл      "
   @ row()+1,0 say "   Г       плллллм             Г Г   пппп   пппп  пп     ппппп пп  пп      "
   @ row()+1,0 say "   Г     ммм плллллм           Г Г  мммммм ммммм   мммм  мм  мм ммммм мм   "
   @ row()+1,0 say "   Г    лллллм плллллм         Г Г    лл   лл  лл лл  лл лл  лл лл    лл   "
   @ row()+1,0 say "   Г     плллллм плллллм       Г Г    лл   ллммлп ллммлл лл  лл ллмм  лл   "
   @ row()+1,0 say "   Г       плллллм плллллм     Г Г    лл   лл  лл лл  лл  лммл  лл    лл   "
   @ row()+1,0 say "   Г         плллллм пллллл    Г Г    пп   пп  пп пп  пп   пп   ппппп ппппп"
   @ row()+1,0 say "   Г           плллллм ппп     Г Г   мммм мм  мм  мммм                     "
   @ row()+1,0 say "   Г             плллллм       Г Г    лл  ллл лл лл  лл                    "
   @ row()+1,0 say "   Г               плллллм     Г Г    лл  лл ллл лл                        "
   @ row()+1,0 say "   Г          ммммм  пллллл    Г Г    лл  лл  лл лл  лл                    "
   @ row()+1,0 say "   Г        млллллллм  ппп     Г Г   пппп пп  пп  пппп  п                  "
   @ row()+1,0 say "   Г        плллллллп          Г Г                                         "
   @ row()+1,0 say "   Г          ппппп            Г Г                                         "
   @ row()+1,0 say "   РФТФФФФФФФФФФФФФФФФФФФФФФФФФй Г                                         "
   @ row()+1,0 say "     РФФФФФФФФФФФФФФФФФФФФФФФФФФФй                                         "
return nil
/* eof <c501_mod.prg>
*/
