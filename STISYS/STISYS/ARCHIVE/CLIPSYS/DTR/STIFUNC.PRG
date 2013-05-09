/*
           STI.Prg : Super Travel, specific functions
            Author : Ron Paredes
      Date Written : March 31, 1993
*/

#include "Epson.Ch"

function STI_Header(nMode)
    ?? _PRN_RESET
    ?? _PRN_10CPI
    ?? _PRN_CONDOFF
    ?? _PRN_LQON
    ?? _PRN_ROMAN
    ?? _PRN_WDBLE
    ?? _PRN_EMPHON
    ?
    ? space(if(nMode=1,09,19)) + "RURAL BANK OF SAN MIGUEL"
    ?? _PRN_EMPHOFF
    ?? _PRN_WNORM
    ?? _PRN_CONDON
    ?? _PRN_CONDOFF
    ? repl('Э',136)
return nil

/***
*  STI_Logo()  --> NIL
*  Display on Screen the STI's logo
*/
FUNCTION RBSM_Logo()
   clr := setcolor("R/B")
   SetPos(06, 00 )
   SetPos(row()+1,0 )  ;  DispOut("          кФлллллллллл кФлллллллллм кФмллллллллл кФлллм  кФмллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г лллФФП ллл Г лллФФП плл Г лллФФФФФй  Г лллллФйллллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г ллл  Г ллл Г ллл  Г млл Г ллл        Г лллллллллллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г лллллллллл Г ллллллллл  Г пллллллллм Г лллПпллп ллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г лллП лллй  Г лллФФП плл РФФФФФФП ллл Г лллРФФФГ ллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г лллРП ллл  Г ллл  Г млл кФФФФФФй ллл Г ллл    Г ллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          Г ллл РП ллл Г лллллллллп Г лллллллллп Г ллл    Г ллл           ")
   SetPos(row()+1,0 )  ;  DispOut("          РФФй   РФФй  РФФФФФФФФФй  РФФФФФФФФй   РФФй     РФФй            ")
   setcolor( clr )
return nil


function DtoE( dDate )
local aMonth := {"JAN","FEB","MAR","APR","MAY","JUN",;
                 "JUL","AUG","SEP","OCT","NOV","DEC"}
   if empty(dDate)  ;  return  space(7)  ;  endif
   return  substr( dtos( dDate ),7,2 ) +;
           aMonth[ val( substr( dtos( dDate ),5,2 )) ] +;
           substr( dtos( dDate ),3,2 )

function EtoD( cDate )
local aMonth := {"JAN","FEB","MAR","APR","MAY","JUN",;
                 "JUL","AUG","SEP","OCT","NOV","DEC"}
   if aScan( aMonth,substr( upper(cDate),3,3 ) ) # 0
      return ctod( str( aScan( aMonth,substr( cDate,3,3 ) ), 2) + "/" +;
                   substr( cDate,1,2 ) + "/" +;
                   substr( cDate,6,2 )  )
   endif
   return  ctod("")

function Evalid( cDate )
   if empty(cDate)
      return .T.
   endif
   return !empty( etod( cDate ) )

/* End of file */