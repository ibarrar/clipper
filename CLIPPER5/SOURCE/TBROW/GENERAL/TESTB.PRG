
#include "inkey.ch"

function main ()
local oBrowse
local oCol
local nkey
local Column

set scoreboard off
cls
use test new

setcolor("W/N")
scroll()
setcolor ("W/RB,GR+/B")
scroll(2, 6, 22, 72)
@2, 6 to 22, 72 double
oBrowse := TBrowseDB(3, 7, 21, 71)
oBrowse:headsep := CHR(205) + CHR(209) + CHR(205)
oBrowse:colsep := CHR(32) + CHR(179) + CHR(32)

oCol := TBColumnNew("Field #1" , {| x | IF( x == NIL, test->FLD1, test->FLD1 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #2" , {| x | IF( x == NIL, test->FLD2, test->FLD2 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #3" , {| x | IF( x == NIL, test->FLD3, test->FLD3 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #4" , {| x | IF( x == NIL, test->FLD4, test->FLD4 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #5" , {| x | IF( x == NIL, test->FLD5, test->FLD5 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #6" , {| x | IF( x == NIL, test->FLD6, test->FLD6 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #7" , {| x | IF( x == NIL, test->FLD7, test->FLD7 := x ) } )
oBrowse:AddColumn(oCol)

oCol := TBColumnNew("Field #8" , {| x | IF( x == NIL, test->FLD8, test->FLD8 := x ) } )
oBrowse:AddColumn(oCol)

// oBrowse:freeze := 1
while .T.
while (!oBrowse:stabilize())
end

nkey := inkey(0)
if (nkey == K_DOWN)
        oBrowse:down()
elseif (nkey == K_UP)
        oBrowse:up()
elseif (nkey == K_RIGHT)
        oBrowse:right()
elseif (nkey == K_LEFT)
        oBrowse:left()
elseif (nkey == K_ENTER)
        aFLDS := { "Test->FLD1",;
                        "Test->FLD2",;
                        "Test->FLD3",;
                        "Test->FLD4",;
                        "Test->FLD5",;
                        "Test->FLD6",;
                        "Test->FLD7",;
                        "Test->FLD8" }
        Column := oBrowse:getcolumn( oBrowse:colpos )
        get := GetNew( ROW(), COL(), column:block,;
                aFLDS[oBrowse:ColPos], , "N/W" )

        ReadModal( { Get } )
        oBrowse:ReFreshCurrent()
elseif (nkey == K_ESC)
        scroll()
exit
endif
setcolor ( "W/N" )
end
return (nil)
