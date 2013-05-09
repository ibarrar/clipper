/*
           STI.Prg : Super Travel, specific functions
            Author : Rollie Ibarra Jr.
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
    ? space(if(nMode=1,12,25)) + "SUPER TRAVEL, INC."
    ?? _PRN_EMPHOFF
    ?? _PRN_WNORM
    ?? _PRN_CONDON
    ?  space(if(nMode=1,44,89)) + "             Ground Floor, VIP Building"
    ?  space(if(nMode=1,44,89)) + " 1154 Roxas Boulevard, Ermita, Manila, Philippines"
    ?  space(if(nMode=1,44,89)) + "               Tel. No. 59-60-02 to 05 "
    ?? _PRN_CONDOFF
    ? repl('Э',136)
return nil

/***
*  STI_Logo()  --> NIL
*  Display on Screen the STI's logo
*/
FUNCTION STI_Logo()
   clr := setcolor("R/B")
   SetPos(02, 00 )
   SetPos(row()+1,0 )  ;  DispOut("   кФФФФФФФФФФФФФФФФФФФФФФФФФФФП                                           ")
   SetPos(row()+1,0 )  ;  DispOut("   Г            ммммм          УФП                                         ")
   SetPos(row()+1,0 )  ;  DispOut("   Г          млллллллм        Г Г   мммм  мм  мм ммммм  ммммм ммммм       ")
   SetPos(row()+1,0 )  ;  DispOut("   Г     ммм  плллллллп        Г Г  лл  пп лл  лл лл  лл лл    лл  лл      ")
   SetPos(row()+1,0 )  ;  DispOut("   Г    лллллм  ппппп          Г Г   пллм  лл  лл ллммлп ллмм  ллммлп      ")
   SetPos(row()+1,0 )  ;  DispOut("   Г     плллллм               Г Г  мм  лл лл  лл лл     лл    лл  лл      ")
   SetPos(row()+1,0 )  ;  DispOut("   Г       плллллм             Г Г   пппп   пппп  пп     ппппп пп  пп      ")
   SetPos(row()+1,0 )  ;  DispOut("   Г     ммм плллллм           Г Г  мммммм ммммм   мммм  мм  мм ммммм мм   ")
   SetPos(row()+1,0 )  ;  DispOut("   Г    лллллм плллллм         Г Г    лл   лл  лл лл  лл лл  лл лл    лл   ")
   SetPos(row()+1,0 )  ;  DispOut("   Г     плллллм плллллм       Г Г    лл   ллммлп ллммлл лл  лл ллмм  лл   ")
   SetPos(row()+1,0 )  ;  DispOut("   Г       плллллм плллллм     Г Г    лл   лл  лл лл  лл  лммл  лл    лл   ")
   SetPos(row()+1,0 )  ;  DispOut("   Г         плллллм пллллл    Г Г    пп   пп  пп пп  пп   пп   ппппп ппппп")
   SetPos(row()+1,0 )  ;  DispOut("   Г           плллллм ппп     Г Г   мммм мм  мм  мммм                     ")
   SetPos(row()+1,0 )  ;  DispOut("   Г             плллллм       Г Г    лл  ллл лл лл  лл                    ")
   SetPos(row()+1,0 )  ;  DispOut("   Г               плллллм     Г Г    лл  лл ллл лл                        ")
   SetPos(row()+1,0 )  ;  DispOut("   Г          ммммм  пллллл    Г Г    лл  лл  лл лл  лл                    ")
   SetPos(row()+1,0 )  ;  DispOut("   Г        млллллллм  ппп     Г Г   пппп пп  пп  пппп  п                  ")
   SetPos(row()+1,0 )  ;  DispOut("   Г        плллллллп          Г Г                                         ")
   SetPos(row()+1,0 )  ;  DispOut("   Г          ппппп            Г Г                                         ")
   SetPos(row()+1,0 )  ;  DispOut("   РФТФФФФФФФФФФФФФФФФФФФФФФФФФй Г                                         ")
   SetPos(row()+1,0 )  ;  DispOut("     РФФФФФФФФФФФФФФФФФФФФФФФФФФФй                                         ")
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