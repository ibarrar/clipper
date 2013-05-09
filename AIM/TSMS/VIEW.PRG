#include "box.ch"
#include "inkey.ch"
#include "janus.ch"

// Separator strings for the browse display.
#define HEADSEP      "мям"
#define COLSEP       " Ё "
#define FOOTSEP      "мом"

#define  V_ROW1  05 //11
#define  V_COL1  2
#define  V_ROW2  21 //21
#define  V_COL2  76

function View_Master()
local windbuff, aNotDisplayed := { }
local OldColor:= SetColor ("N/W")
local aCBP := { ;
              "Tenant Code",;
              "Tenant's Name",;
              "Owner's Name",;
              "Address",;
              "Tel. No.",;
              "No. of Term.",;
              "Machine Code",;
              "Cluster Code",;
              "Sales Area",;
              "Daily Sales",;
              "Monthly Sales",;
              "Billing Rate",;
              "Monthly Rate",;
              "Yearly Sale",;
              "Con. Rate  "}

 // The master file is the one to be displayed.
 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif

 windbuff:= OpenWindow(V_ROW1-1,V_COL1,V_ROW2,V_COL2,"Browse Master File")
 // Draw box.
 @ V_ROW1, V_COL1, V_ROW2, V_COL2 box B_SINGLE_DOUBLE + " "
 @ V_ROW1+2, V_COL1 say "л"
 @ V_ROW1+2, V_COL2 say "╧"
 @ V_ROW2-1, V_COL1 say "л"
 @ V_ROW2-1, V_COL2 say "╧"

 // Browse the database file.
 DBrowse( V_ROW1+1, V_COL1+1, V_ROW2-1, V_COL2-1, aCBP, aNotDisplayed )

 // Restore parameters.
 CloseWindow( windbuff )
 SetColor( OldColor )
 MASTER->(DbCloseArea())
return nil

/* A Tbrowse function for browsing through a database file. */

static function DBrowse ( nTop, nLeft, nBottom, nRight, cBrowsePrompts, aNotDisplayed  )

local browse, column, key, n
// Create a new browse object.

browse := TBrowseDB( nTop, nLeft, nBottom, nRight)

// Assign browse attributes.
browse:headSep := HEADSEP
browse:colSep  := COLSEP
browse:footSep := FOOTSEP
browse:colorSpec := "N/W, N/BG, B/W, B/BG, B/W, B/BG, R/W, B/R"

FOR n := 1 TO fcount()

// Check if this field is to be displayed.
 if AScan ( aNotDisplayed, n ) != 0
  loop
 endif

// Create new TBColumn objects.
 column := TBColumnNew( cBrowsePrompts[n], FieldWBlock( Field(n), Select() ) )

// Add the column to the browse
 browse:addColumn(column)
 NEXT

// Do not scroll off first column
 browse:freeze := 1

While .T.
 while ! browse:stabilize()
 if nextkey () != 0
  exit
 endif
enddo

 key := inkey(0)

Do case
   case key == K_UP
     browse:up()
   case key == K_DOWN
     browse:down()
   case key == K_LEFT
     browse:left()
   case key == K_RIGHT
     browse:right()
   case key == K_PGUP
     browse:pageUp()
   case key == K_PGDN
     browse:pageDown()
   case key == K_HOME
     browse:home()
   case key == K_END
     browse:end()
   case key == K_CTRL_LEFT
     browse:panHome()
   case key == K_CTRL_RIGHT
     browse:panEnd()
   case key == K_CTRL_PGUP
     browse:goTop()
   case key == K_CTRL_PGDN
     browse:goBottom()
   case key == K_ESC
     exit
endcase
enddo

return nil

