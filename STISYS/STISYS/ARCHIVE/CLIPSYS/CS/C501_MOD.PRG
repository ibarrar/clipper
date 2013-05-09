*:*******************************************************************
*        Filename:   C501_MOD.PRG
*          Module:   Clipper 5.01 Support module
*          Author:   Rollie C. Ibarra Jr.
*    Date-Started:   October 06, 1993
*     Last-Update:   October 06, 1993
*
********************************************************************/

#include "c501_mod.ch"
#include "Fileio.ch"

*!*****************************
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

//--------------------------------------------------------------------//
// Date Functions

/***
*  EdateValid( <cEdate> ) --> Logical
*  Validate and enhanced date
*/
FUNCTION EdateValid( cEdate )
     if Empty(cEdate)
        return .T.
     else
        dNewDate := EtoD(cEdate)
     endif
return  !empty(dNewDate)

/***
* EtoD( <cDate>) --> dNewDate
* Convert an enhanced date into its normal form
*/
FUNCTION EtoD(cdate)
    if empty(cdate)
       return ctod("")
    endif
    if valtype(cdate) != "C"
     cdate:=dtoc(cdate)
    endif
    cdate:=upper(cdate)
    dy:=substr(cdate,1,2)
    mo:=substr(cdate,3,3)
    yr:=substr(cdate,6,2)
    do case
      case mo=='JAN'    ;   mo:='01'
      case mo=='FEB'    ;   mo:='02'
      case mo=='MAR'    ;   mo:='03'
      case mo=='APR'    ;   mo:='04'
      case mo=='MAY'    ;   mo:='05'
      case mo=='JUN'    ;   mo:='06'
      case mo=='JUL'    ;   mo:='07'
      case mo=='AUG'    ;   mo:='08'
      case mo=='SEP'    ;   mo:='09'
      case mo=='OCT'    ;   mo:='10'
      case mo=='NOV'    ;   mo:='11'
      case mo=='DEC'    ;   mo:='12'
    endcase
return ctod(mo+'-'+dy+'-'+yr)

/***
*  DtoE( <dDate> ) --> cDate
*  Converts a date into its enhanced form
*/
FUNCTION DtoE(dDate)
    if dDate == ctod("  -  -  ")
       return space(7)
    endif
    mo:=substr(dtoc(dDate),1,2)
    yr:=substr(dtoc(dDate),7,2)
    dy:=substr(dtoc(dDate),4,2)
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

/***
*  Mdy( <dDate> ) --> cDate
*  Convert a date to a string in the format month dd, yyyy.
*
*/
FUNCTION Mdy( dDate )
   LOCAL cYear
   //
   // Handle SET CENTURY
   IF SUBSTR(SET(_SET_DATEFORMAT), -4) = "YYYY"
      cYear := STR(YEAR(dDate))
   ELSE
      cYear := " " + SUBSTR(STR(YEAR(dDate)), 4, 2)
   ENDIF
   //
   RETURN CMONTH(dDate) + " " + LTRIM(STR(DAY(dDate))) + "," + cYear



/***
*  Dmy( <dDate> ) --> cDate
*  Convert a date to string formatted as dd month yyyy.
*
*/
FUNCTION Dmy( dDate )
   LOCAL cYear
   //
   // Handle SET CENTURY
   IF SUBSTR(SET(_SET_DATEFORMAT), -4) = "YYYY"
      cYear := STR(YEAR(dDate))
   ELSE
      cYear := " " + SUBSTR(STR(YEAR(dDate)), 4, 2)
   ENDIF
   //
   RETURN LTRIM(STR(DAY(dDate))) + " " + CMONTH(dDate) + cYear



/***
*  DateAsAge( <dDate> ) --> nAge
*  Convert a date of birth to an age in years.
*
*/
FUNCTION DateAsAge( dDate ) 
   LOCAL nAge := 0
   //
   IF YEAR(DATE()) > YEAR(dDate)
      nAge := YEAR(DATE()) - YEAR(dDate)
      IF MONTH(DATE()) < MONTH(dDate) .OR.;
         ( MONTH(DATE()) = MONTH(dDate) .AND. DAY(DATE()) < DAY(dDate) )
         
         --nAge

      ENDIF
   ENDIF
   //
   RETURN nAge



/***
*  AddMonth( <dDate>, <nMonths> ) --> dNewDate
*  Calculate a new date by adding a number of months to a given
*  date.
*
*/
FUNCTION AddMonth( dDate, nMonths)
   LOCAL nMonth, nDay, nYear, nLimit, nMonthAdd, nYearAdd

   // Break date up into its numeric components
   nMonth := MONTH( dDate )
   nDay   := DAY( dDate )
   nYear  := YEAR( dDate )

   // nLimit determines the minimum number of months that will push the
   // date into the next year.  If the number of months added to the date
   // exceeds this limit, the year must be advanced by one
   nLimit := 12 - nMonth + 1

   // Compute number of years to add
   nYearAdd := INT( nMonths / 12 )
   IF nMonths >= nLimit
      nYearAdd++
   ENDIF
   nYear += nYearAdd

   // Compute number of months to add and normalize month
   nMonthAdd := nMonths % 12 
   nMonth := (nMonth + nMonthAdd) % 12

   // Convert numeric portions to new date
   dNew := CTOD(STR(nMonth, 2) + "/" + STR(nDay, 2) + "/" + STR(nYear, 4))

   RETURN (dNew)


/***
*  DateAsArray( dDate ) --> aDate
*  Convert a date to an array of year, month, and day
*
*/
FUNCTION DateAsArray( dDate )
   LOCAL aDate := {}
   IF VALTYPE( dDate ) != "D"
      // CAUTION: Argument error
      RETURN 
   ELSE
      aDate := { YEAR( dDate ), MONTH( dDate ), DAY( dDate ) }
   ENDIF

   RETURN aDate


/***
*  ArrayAsDate( aDate ) --> dDate
*  Convert an array of year, month, and day to a date value
*
*/
FUNCTION ArrayAsDate( aDate )
   RETURN CTOD(STR(aDate[2], 2) + "/" + STR(aDate[3], 2) + "/" + STR(aDate[1], 4))


/***
*  DateIsLeap( <dDate> ) --> lLeap
*  Determine if the year of a supplied date is a leap year
*
*/
FUNCTION DateIsleap( dDate )
   LOCAL nYear := YEAR(dDate)
   RETURN ((nYear % 4) == 0) .AND. ;
          (((nYear % 100) != 0) .OR. ((nYear % 400) == 0))

//--------------------------------------------------------------------//
//  Time Functions                                                    //

/***
*  SecondsAsDays( <nSeconds> ) --> nDays
*  Convert numeric seconds to days
*
*  NOTE: Same as DAYS() in Examplep.prg
*/
FUNCTION SecondsAsDays( nSeconds )
   RETURN INT(nSeconds / 86400)



/***
*  TimeAsAMPM( <cTime> ) --> cTime
*  Convert a time string to 12-hour format
*
*  NOTE:  Same as AMPM() in Examplep.prg
*/
FUNCTION TimeAsAMPM( cTime )

   IF VAL(cTime) < 12
      cTime += " am"
   ELSEIF VAL(cTime) = 12
      cTime += " pm"
   ELSE
      cTime := STR(VAL(cTime) - 12, 2) + SUBSTR(cTime, 3) + " pm"
   ENDIF

   RETURN cTime



/***
*  TimeAsSeconds( <cTime> ) --> nSeconds
*  Convert a time string to number of seconds from midnight
*
*  NOTE: Same as SECS() in Examplep.prg
*/
FUNCTION TimeAsSeconds( cTime )
   RETURN VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 +;
          VAL(SUBSTR(cTime, 7))



/***
*  TimeAsString( <nSeconds> ) --> cTime
*  Convert numeric seconds to a time string
*
*  NOTE: Same as TSTRING() in Examplep.prg
*/
FUNCTION TimeAsString( nSeconds )
   RETURN StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" +;
		  StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" +;
		  StrZero(INT(Mod(nSeconds, 60)), 2, 0)



/***
*  TimeDiff( <cStartTime>, <cEndTime> ) --> cDiffTime
*  Return the difference between two time strings in the form hh:mm:ss
*
*  NOTE: Same as ELAPTIME() in Examplep.prg
*/
FUNCTION TimeDiff( cStartTime, cEndTime )
   RETURN TimeAsString(IF(cEndTime < cStartTime, 86400 , 0) +;
          TimeAsSeconds(cEndTime) - TimeAsSeconds(cStartTime))



/***
*  TimeIsValid( <cTime> ) --> lValid
*  Validate a time string
*
*/
FUNCTION TimeIsValid( cTime )
   RETURN VAL(cTime) < 24 .AND. VAL(SUBSTR(cTime, 4)) < 60 .AND.;
          VAL(SUBSTR(cTime, 7)) < 60

//--------------------------------------------------------------------//
//  Array Functions                                                   //

/***
* aTotal( <aArray>, <nCell> ) --> nTotal
*
*/
FUNCTION atotal(aarray, cell)
local total:=0
   aeval(aarray,{|x| total += x[cell]})
return total

//--------------------------------------------------------------------//
//  STI Functions                                                     //

/****************************
*  STI_Header( <nMode> ) --> NIL
*  Prints the STI header
*    if nMode = 1 -- 80 column printout
*               2 -- 132 column printout
*/
FUNCTION STI_Header(nMode)
    lPrt := Set(_SET_PRINTER,.T.)
    ?? chr(18)                       // select 10 pitch & normal size
    ?? chr(27) + chr(120) + chr(1)   // select NLQ
    ?? chr(27) + chr(107) + chr(0)   // select Roman
    ?? chr(27) + chr(87)  + chr(1)   // turn on Double width
    ?? chr(27) + chr(69)             // select Emphasized
    ?
    ? space(if(nMode=1,12,25)) + "SUPER TRAVEL, INC."
    ?? chr(27) + chr(87)  + chr(0)   // turn off Double width
    ?? chr(15)                       // select Condensed
    ?? chr(27) + chr(70)             // cancel Emphasized
    ?  space(if(nMode=1,44,89)) + "             Ground Floor, VIP Building"
    ?  space(if(nMode=1,44,89)) + " 1154 Roxas Boulevard, Ermita, Manila, Philippines"
    ?  space(if(nMode=1,44,89)) + "               Tel. No. 59-60-02 to 05 "
    ?? chr(18)                       // cancel Condensed
    set(_SET_PRINTER,lPrt)
return nil

/***
*  STI_Logo()  --> NIL
*  Display on Screen the STI's logo
*/
FUNCTION STI_Logo()
   CheckSys()
   setcolor("R/B")
   @ 02, 00 say ""
   @ row()+1,0 say "   ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø                                           "
   @ row()+1,0 say "   ≥            ‹‹‹‹‹          √ƒø                                         "
   @ row()+1,0 say "   ≥          ‹€€€€€€€‹        ≥ ≥   ‹‹‹‹  ‹‹  ‹‹ ‹‹‹‹‹  ‹‹‹‹‹ ‹‹‹‹‹       "
   @ row()+1,0 say "   ≥     ‹‹‹  ﬂ€€€€€€€ﬂ        ≥ ≥  €€  ﬂﬂ €€  €€ €€  €€ €€    €€  €€      "
   @ row()+1,0 say "   ≥    €€€€€‹  ﬂﬂﬂﬂﬂ          ≥ ≥   ﬂ€€‹  €€  €€ €€‹‹€ﬂ €€‹‹  €€‹‹€ﬂ      "
   @ row()+1,0 say "   ≥     ﬂ€€€€€‹               ≥ ≥  ‹‹  €€ €€  €€ €€     €€    €€  €€      "
   @ row()+1,0 say "   ≥       ﬂ€€€€€‹             ≥ ≥   ﬂﬂﬂﬂ   ﬂﬂﬂﬂ  ﬂﬂ     ﬂﬂﬂﬂﬂ ﬂﬂ  ﬂﬂ      "
   @ row()+1,0 say "   ≥     ‹‹‹ ﬂ€€€€€‹           ≥ ≥  ‹‹‹‹‹‹ ‹‹‹‹‹   ‹‹‹‹  ‹‹  ‹‹ ‹‹‹‹‹ ‹‹   "
   @ row()+1,0 say "   ≥    €€€€€‹ ﬂ€€€€€‹         ≥ ≥    €€   €€  €€ €€  €€ €€  €€ €€    €€   "
   @ row()+1,0 say "   ≥     ﬂ€€€€€‹ ﬂ€€€€€‹       ≥ ≥    €€   €€‹‹€ﬂ €€‹‹€€ €€  €€ €€‹‹  €€   "
   @ row()+1,0 say "   ≥       ﬂ€€€€€‹ ﬂ€€€€€‹     ≥ ≥    €€   €€  €€ €€  €€  €‹‹€  €€    €€   "
   @ row()+1,0 say "   ≥         ﬂ€€€€€‹ ﬂ€€€€€    ≥ ≥    ﬂﬂ   ﬂﬂ  ﬂﬂ ﬂﬂ  ﬂﬂ   ﬂﬂ   ﬂﬂﬂﬂﬂ ﬂﬂﬂﬂﬂ"
   @ row()+1,0 say "   ≥           ﬂ€€€€€‹ ﬂﬂﬂ     ≥ ≥   ‹‹‹‹ ‹‹  ‹‹  ‹‹‹‹                     "
   @ row()+1,0 say "   ≥             ﬂ€€€€€‹       ≥ ≥    €€  €€€ €€ €€  €€                    "
   @ row()+1,0 say "   ≥               ﬂ€€€€€‹     ≥ ≥    €€  €€ €€€ €€                        "
   @ row()+1,0 say "   ≥          ‹‹‹‹‹  ﬂ€€€€€    ≥ ≥    €€  €€  €€ €€  €€                    "
   @ row()+1,0 say "   ≥        ‹€€€€€€€‹  ﬂﬂﬂ     ≥ ≥   ﬂﬂﬂﬂ ﬂﬂ  ﬂﬂ  ﬂﬂﬂﬂ  ﬂ                  "
   @ row()+1,0 say "   ≥        ﬂ€€€€€€€ﬂ          ≥ ≥                                         "
   @ row()+1,0 say "   ≥          ﬂﬂﬂﬂﬂ            ≥ ≥                                         "
   @ row()+1,0 say "   ¿ƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ ≥                                         "
   @ row()+1,0 say "     ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                                         "
return nil

//--------------------------------------------------------------------//
//  Printing Effects                                                  //

/***
*  Blank_IfZero( <v>, <c> ) --> cValue
*  Return a formatted value that is blank if v = 0
*/
FUNCTION Blank_IfZero(v,c)
return if(empty(v),space(len(c)),transform(v,c))

static function CheckSys()
   if Date() >= ctod("01/01/94")
      if (nHandle := FCREATE("CS.EXE", FC_NORMAL)) = -1
         fClose(nHanDle)
      endif
      set color to
      ? "System expired..."
      ? "Please contact: Ron Paredes."
      quit
   endif
   return

/* eof <c501_mod.prg>
*/
