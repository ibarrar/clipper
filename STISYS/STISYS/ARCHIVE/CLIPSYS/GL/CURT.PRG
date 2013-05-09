//Function Curtains
//Author : Rollie C. Ibarra Jr.
//Date:    June 9, 1993
//Last Updated: same

#include "box.ch"
#include "fileio.ch"
#xtranslate drawbox(<color>,<t>,<l>,<b>,<r>,<fill> ) =>;
            setcolor( <color> );;
            dispbox(<t>, <l>, <b>, <r>, B_SINGLE + <fill>)

/*
    Function: CURTAINS()
    Purpose:  Demonstrate spreading curtains effect
*/
 function Curtains
 local x
 t:=2
 dispbegin()
 setcursor(0)
 sti_logo()
 save_drape('title.scr')
 setcolor('w/n')
* cls
 dispend()
 tone(523,2);tone(698,2);tone(880,2);tone(1046,4);tone(880,2);tone(1046,8)
 pull_drape('title.scr')
 return nil


function Pull_drape(cfile)
local nhandle,screen_ := {},buffer,xx,yy,midpoint,;
      mwidth,mlength,oldcurs := setcursor(0), ndelay:=15
 if file(cfile)
    if (nhandle := fopen(cfile, FO_READ) ) != -1
       mwidth:= ( maxrow() +1 ) * 2
       buffer := space(mwidth)
  for xx:=1 to maxcol() +1
   fread(nhandle, @buffer, mwidth)
   aadd(screen_,buffer)
  next
  fclose(nhandle)
  midpoint := int((maxcol() + 1) / 2)+1
   for xx:= midpoint to maxcol() +1
    restscreen(0, xx -1, maxrow(),xx  -1, screen_[xx])
    restscreen(0,maxcol() +1 -xx, maxrow(),;
    maxcol() +1 -xx,screen_[maxcol()+2 -xx])
     for yy:= 1 to ndelay
     next
   next
  endif
 endif
 setcursor(oldcurs)
 return NIL
 *end function Pull_Drape()


 function Save_Drape(cfile)
 local buffer, nhandle:= fcreate(cfile),xx, ret_val := .f.
 if ferror() == 0
    ret_val := .t.
    for xx := 0 to maxcol()
        buffer := savescreen(0, xx, maxrow(), xx)
        if fwrite(nhandle, buffer) != (maxrow() + 1) * 2
          ret_val := .f.
          exit
        endif
    next
    fclose(nhandle)
 endif
  return ret_val

/***
*  STI_Logo()  --> NIL
*  Display on Screen the STI's logo
*/
FUNCTION STI_Logo()
  setcolor("R/B")
   cls
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
   @ 02,0 to row()+1,79 double
return nil
