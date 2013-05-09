#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Error.ch"

#define TURN_ON_APPEND_MODE(b)      (b:cargo:=.T.)
#define TURN_OFF_APPEND_MODE(b)     (b:cargo:=.F.)
#define IS_APPEND_MODE(b)           (b:cargo)

// Separator strings for the browse display
#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "

static aScrollBar

function DbBrowse(nTop,nLeft,nBottom,nRight,cTitle,lFreeze)
local wScreen
   Message("F1-Help   Esc-Abort")
   wScreen:=OpenWindow(nTop,nLeft,nBottom,nRight,cTitle)
   aScrollBar:=ScrollBarNew(nTop,nRight,nBottom,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,LastRec(),.T.)
   MyBrowse(nTop+2,nLeft+2,nBottom-1,nRight-2,lFreeze)
   CloseWindow(wScreen)
return nil

static function MyBrowse(nTop,nLeft,nBottom,nRight,lFreeze)
local browse                        // The TBrowse object
local cColorSave,nCursSave         // State preservers
local nKey                          // Keystroke
local lMore                         // Loop control
    // Make a "stock" Tbrowse object for the current workarea
    browse:=StockBrowseNew(nTop,nLeft,nBottom,nRight)
    // This demo uses the browse's "cargo" slot to hold a logical
    // value of true (.T.) when the browse is in "append mode",
    // otherwise false (.F.) (see #defines at top).
    TURN_OFF_APPEND_MODE(browse)
    // Use a custom 'skipper' to handle append mode (see below)
    browse:skipBlock:={ |x| Skipper(x,browse) }
    // Change the heading and column separators
    browse:headSep:=MY_HEADSEP
    browse:colSep:=MY_COLSEP
    if lFreeze ; browse:freeze:=1 ; endif
    // Play with the colors
*    FancyColors(browse)
    // Save cursor shape,turn the cursor off while browsing
    nCursSave:=SetCursor(SC_NONE)
    // Main loop
    lMore:=.T.
    do while lMore
        // Stabilize the display until it's stable or a key is pressed
        nKey:=0
        do while nKey==0 .AND. .NOT. browse:stable
            browse:stabilize()
            nKey:=InKey()
        enddo
        if browse:stable
            if browse:hitBottom .AND. .NOT. IS_APPEND_MODE(browse)
                // Banged against EOF; go into append mode
                TURN_ON_APPEND_MODE(browse)
                nKey:=K_DOWN
            else
                if browse:hitTop .OR. browse:hitBottom
                    Tone(125,0)
                endif
                // Make sure that the current record is showing
                // up-to-date data in case we are on a network.
                browse:refreshCurrent()
                ForceStable(browse)
                // Everything's done -- just wait for a key
                nKey:=InKey(0)
            endif
        endif
        if nKey==K_ESC
            // Esc means leave
            lMore:=.F.
        else
            // Apply the key to the browse
            ApplyKey(browse,nKey)
        endif
    enddo
    SetCursor(nCursSave)
    return

static function Skipper(n,browse)
local lAppend
local i
    lAppend:=IS_APPEND_MODE(browse)           // see #defines at top
    i:=0
    if n==0 .OR. LASTREC()==0
        // Skip 0 (significant on a network)
        skip 0
    elseif n > 0 .and. RecNo() != LASTREC() + 1
        // Skip forward
        do while i < n
            skip 1
            if ( EOF() )
                if ( lAppend )
                    i++
                else
                    skip -1
                endif
                EXIT
            endif
            i++
        enddo
    elseif n < 0
        // Skip backward
        do while i > n
            skip -1
            if ( BOF() )
                EXIT
            endif
            i--
        enddo
    endif
    return i

static function ApplyKey(browse,nKey)
    ScrollBarUpdate(aScrollBar,RecNo(),LastRec(),.F.)
    do case
       case nKey==K_DOWN
           browse:down()
       case nKey==K_PGDN
           browse:pageDown()
       case nKey==K_CTRL_PGDN
           browse:goBottom()
           TURN_OFF_APPEND_MODE(browse)
       case nKey==K_UP
           browse:up()
           if IS_APPEND_MODE(browse)
               TURN_OFF_APPEND_MODE(browse)
               browse:refreshAll()
           endif
       case nKey==K_PGUP
           browse:pageUp()
           if IS_APPEND_MODE(browse)
               TURN_OFF_APPEND_MODE(browse)
               browse:refreshAll()
           endif
       case nKey==K_CTRL_PGUP
           browse:goTop()
           TURN_OFF_APPEND_MODE(browse)
       case nKey==K_RIGHT
           browse:right()
       case nKey==K_LEFT
           browse:left()
       case nKey==K_HOME
           browse:home()
       case nKey==K_END
           browse:end()
       case nKey==K_CTRL_LEFT
           browse:panLeft()
       case nKey==K_CTRL_RIGHT
           browse:panRight()
       case nKey==K_CTRL_HOME
           browse:panHome()
       case nKey==K_CTRL_END
           browse:panEnd()
       case nKey==K_RETURN
           DoGet(browse)
       OTHERWISE
           keyboard Chr(nKey)
           DoGet(browse)
       endcase
    return

static function DoGet(browse)
local bIns,lScore,lExit
local col,get,nKey
local lAppend,xOldKey,xNewKey
    // Make sure screen is fully updated,dbf position is correct,etc.
    ForceStable(browse)
    // If confirming a new record,do the physical append
    lAppend:=IS_APPEND_MODE(browse)
    if lAppend .AND. RecNo()==LASTREC() + 1
        append blank
    endif
    // Save the current record's key value (or NIL)
    // (for an explanation,refer to the rambling note below)
    xOldKey:=if( EMPTY(INDEXKEY()),NIL,&(INDEXKEY()) )
    // Save global state
    lScore:=Set(_SET_SCOREBOARD,.F.)
    lExit:=Set(_SET_EXIT,.T.)
    bIns:=SetKey(K_INS)
    // Set insert key to toggle insert mode and cursor shape
    SetKey( K_INS,{|| InsToggle()} )
    // Set initial cursor shape
    SetCursor( if(ReadInsert(),SC_INSERT,SC_NORMAL) )
    // Get the current column object from the browse
    col:=browse:getColumn(browse:colPos)
    // Create a corresponding GET
    get:=GetNew(Row(),Col(),col:block,col:heading,,browse:colorSpec)
    // Read it using the standard reader
    // NOTE: for a shared database,an RLOCK() is required here
    ReadModal( {get} )
    // Restore state
    SetCursor(0)
    Set(_SET_SCOREBOARD,lScore)
    Set(_SET_EXIT,lExit)
    SetKey(K_INS,bIns)
    xNewKey:=if( EMPTY(INDEXKEY()),NIL,&(INDEXKEY()) )
    // If the key has changed (or if this is a new record)
    if .NOT. (xNewKey==xOldKey) .OR. (lAppend .AND. xNewKey != NIL)
        // Do a complete refresh
        browse:refreshAll()
        ForceStable(browse)
        // Make sure we're still on the right record after stabilizing
        do while &(INDEXKEY()) > xNewKey .AND. .NOT. browse:hitTop()
            browse:up()
            ForceStable(browse)
        enddo
    endif
    // For this demo,we turn append mode off after each new record
    TURN_OFF_APPEND_MODE(browse)
    // Check exit key from get
    nKey:=LASTKEY()
    if nKey==K_UP .OR. nKey==K_DOWN .OR. ;
        nKey==K_PGUP .OR. nKey==K_PGDN
        // Ugh
        keyboard( Chr(nKey) )
    endif
    return

static function ForceStable(browse)
    do while .NOT. browse:stabilize()
    enddo
    return

static function InsToggle()
    if ReadInsert()
        ReadInsert(.F.)
        SetCursor(SC_NORMAL)
    else
        ReadInsert(.T.)
        SetCursor(SC_INSERT)
    endif
    return

static function StockBrowseNew(nTop,nLeft,nBottom,nRight)
local browse
local n,column,cType
    // Start with a new browse object from TBrowseDB()
    browse:=TBrowseDB(nTop,nLeft,nBottom,nRight)
    // Add a column for each field in the current workarea
    for n:=1 to FCount()
        // Make a new column
        column:=TBColumnNew(                                          ;
                                Field(n),                              ;
                                FieldWBlock(Field(n),Select())         ;
                             )
        // Add the column to the browse
        browse:addColumn(column)
    next
    return browse

static function FancyColors(browse)
local n,column
local xValue
    // Set up a list of colors for the browse to use
    browse:colorSpec:="N/W,N/BG,B/W,B/BG,B/W,B/BG,R/W,B/R"
    // Loop through the columns,choose some colors for each
    for n:=1 to browse:colCount
        // Get (a reference to) the column
        column:=browse:getColumn(n)
        // Get a sample of the underlying data by evaluating the codeblock
        xValue:=Eval(column:block)
        if ValType(xValue) != "N"
            // For non-numeric,just use colors 3 and 4 ("B/W" and "B/BG")
            column:defColor:={3,4}
        else
            // For numbers,use a color block to highlight negative values
            column:colorBlock:={|x| if( x < 0,{7,8},{5,6} )}
            // Set default colors also (controls the heading color)
            column:defColor:={7,8}
        endif
    next
    return

static function AddRecno(browse)
local column
    // Create the column object
    column:=TBColumnNew( "  Rec #",{|| RecNo()} )
    // Insert it as the leftmost column
    browse:insColumn(1,column)
    // Freeze it at the left
    browse:freeze:=1
    return

// end-of-file