/***
*  Omenu.prg
*  Pull-down menu system that hierachical submenus, grayed items, and
*  checked items.
*
*  Copyright (c) 1990 Nantucket Corp.  All rights reserved
*
*  Notes:  Compile with RMAKE OMENU.RMK
*          See Omenu.doc for usage information; Odemo1.prg and Odemo2.prg
*          for usage examples.
*
*/

// Public functions

//  BarActivate( <hBar>, [<nKey>] ) --> nMenuChoice
//  Activate bar menu as primary task (nothing else active)

//  BarDeInstall( <hBar> ) --> hBar
//  Uninstall menubar from SET KEY handler

//  BarDisplay( <hBar> ) --> hBar
//  Display a menubar to the screen

//  BarInstall( <hBar> ) --> hBar
//  Install a menubar into the SET KEY handler

//  BarMenuChoice( <hBar>, [<nChoice>] ) --> nChoice
//

//  BarNew( <cColor>, <nBorder> ) --> hBar
//  Create a new menubar and return a handle to it

//  MenuAdd( <hBar>, <hMenu> ) --> hBar
//  Add a menu to menubar

//  MenuDisplay( <hMenu> ) --> hMenu
//  Display a menu to the screen

//  MenuNew( <cTitle> ) --> hMenuHandle
//  Create a new menu and return a new handle to it

//  PostExitBlock( [<bBlock>] ) --> bOldBlock
//  Post a code block to execute when a function is terminated

//  PromptAction( <hMenu>, <nID>, <bBlock> ) --> hMenu
//  Change the menu action block

//  PromptAdd( <hMenu>, <nID>, <cText>, <bBlock> ) --> hMenu
//  Add a prompt to the menu

//  PromptAddLine( <hMenu> ) --> hMenu
//  Add a line separator between prompts

//  PromptAddSub( <hMenu>, <nID>, <hSubMenu> ) --> hMenu
//  Add a hierarchical submenu to an existing menu

//  PromptAddToggle( <hMenu>, <nID>, <cText>, <bBlock> ) --> hMenu
//
//  Has to be separate from PromptAdd() because of needing to add <bBlock> to
//  key event array

//  PromptCheck( <hMenu>, <nID> ) --> hMenu
//  Mark a menu prompt with a check mark

//  PromptEnable( <hMenu>, <nID> ) --> hMenu
//  Ungray a menu prompt

//  PromptGray( <hMenu>, <nID> ) --> hMenu
//  Gray a menu prompt

//  PromptIsChecked( <hMenu>, <nID> ) --> lChecked
//  Determine if a menu prompt is checked

//  PromptIsEnabled( <hMenu>, <nID> ) --> lEnabled
//  Determine if a menu prompt is active

//  PromptQuickKey( <hBar>, <hMenu>, <nID>, <nKey> ) --> hMenu
//  Assign nKey to nID

//  PromptUnCheck( <hMenu>, <nID> ) --> hMenu
//  Uncheck menu prompt

// Includes
#include "Omenu.ch"
#include "Inkey.ch"
#include "Array.ch"
#include "Error.ch"

// Default colors for menus
//#define OM_DEFBW   "N/W,W+/W,W+/N,N/W,W/N"    Original
//#define OM_DEFCLR  "N/BG,B/BG,W+/R,W/BG,W/R"


#define COLOR_DEF


// Default colors for menus
#ifdef COLOR_DEF
  #define OM_DEFBW  "N/W,W+/W,W+/N,N/W,W/N"
  #define OM_DEFCLR "GR+/B,W+/B,W+/N,W/B,W/B"
#else  
  #define OM_DEFCLR "N/BG,B/BG,W+/R,N+/BG,W/R"
  #define MY_COLOR  "W+/BR,N/W,N/N,N/N,N/W"
#endif    


// Color Positions/Prompt Status
#define OM_NORM    1             // Normal
#define OM_LETTER  2             // Letter
#define OM_NORMHI  3             // Highlighted normal
#define OM_GRAY    4             // Inactive
#define OM_GRAYHI  5             // Highlighted inactive

// Status (numbers have no meaning)
#define OM_EXIT    -1101
#define OM_BAROUT  -1102
#define OM_BARIN   -1103
#define OM_BARLT   -1104
#define OM_BARRT   -1105
#define OM_ESC     -1106

// Default border setting
#define OM_DEFBORD OM_SINGLE

// Amount of spaces to "pad" around menu Prompts
#define OM_PAD     2

// Hotkey indicator
#define OM_HKCHAR "~"

// Line for menus
#define OM_LINECHR    CHR(196)
#define OM_LTSGLLINE  CHR(195)
#define OM_RTSGLLINE  CHR(180)
#define OM_LTDBLLINE  CHR(199)
#define OM_RTDBLLINE  CHR(182)

#define OM_CHKCHAR    CHR(251)   // Checked indicator
#define OM_SUBCHAR    CHR(16)    // Submenu indicator

// Positions in Bar Array Header
#define BA_LEN     8             // Length of array

#define BA_OUTKEYS 1             // Global Keys (keys accessed from
                                 // outside menu)
#define BA_INKEYS  2             // Local Keys (keys accessed from inside menu)
#define BA_CHOICE  3
#define BA_MENUS   4
#define BA_COLOR   5
#define BA_BORDER  6
#define BA_LASTREQ 7
#define BA_MCHOICE 8             // Last Menu Choice

//.Positions in Menu Array Header
#define MA_LEN     17            // Length of array

#define MA_ROW     1
#define MA_COL     2
#define MA_LASTROW 3
#define MA_LASTCOL 4
#define MA_WIDTH   5
#define MA_KEYS    6
#define MA_CHOICE  7
#define MA_ITEMS   8
#define MA_TITLE   9
#define MA_TTLROW  10
#define MA_TTLCOL  11
#define MA_HOTKEY  12            // Key that is "underlined" in title
#define MA_KEYPOS  13            // Where that key is
#define MA_BLOCK   14            // Block to execute
#define MA_LASTREQ 15
#define MA_OWNER   16            // What bar owns me?
#define MA_SAVESCR 17            // Keep track of what I am covering

// Positions in Prompt Array
#define IA_LEN       11          // Length of this array

#define IA_ROW       1
#define IA_COL       2
#define IA_TEXT      3
#define IA_ID        4
#define IA_ACTIVE    5
#define IA_CHECKED   6
#define IA_SUBMENU   7           // Is the the title of a submenu
#define IA_HOTKEY    8           // Key that is "underlined"
#define IA_KEYPOS    9           // Where that key is
#define IA_BLOCK     10          // Block to execute
#define IA_2NDBLOCK  11          // Secondary Block to execute (from IA_BLOCK)

// Global holders
STATIC saBar := {}
STATIC saMenu := {}
STATIC sbExitBlock := NIL
STATIC shCurrBar := NIL

/***
*  NilScan()
*  Temporary fix for ASCAN()
*
*/
STATIC FUNCTION NilScan( aArray )
   LOCAL x := 1

   DO WHILE ( x <= LEN(aArray) ) .AND. ( aArray[x] != NIL )
      x++
   ENDDO

   RETURN( IIF( x > LEN(aArray), 0, x ) )


/***
*  ATrueDel()
*
*/
STATIC FUNCTION ATrueDel( aArray, nElement )

   ADEL( aArray, nElement )
   ASIZE( aArray, LEN( aArray ) - 1 )

   RETURN( aArray )


/***
*  PromptFind()
*
*/
STATIC FUNCTION PromptFind( hMenu, nID )
   RETURN( ASCAN( saMenu[hMenu][MA_ITEMS], {|aPrompt| aPrompt[IA_ID] == nID} ) )


/***
*  ForceExit() --> NIL
*  Execute ExitBlock to allow exit from reads, etc.
*
*/
STATIC FUNCTION ForceExit( hMenu )

   IF sbExitBlock != NIL
      EVAL( sbExitBlock )
   ENDIF

   RETURN( NIL )


/***
*  BarDispPrompt( <hBar>, <nItem> ) --> hBar
*  Display prompt in proper color string for status
*
*/
STATIC FUNCTION BarDispPrompt( hBar, nItem )
   LOCAL cSaveColor
   LOCAL nSaveRow, nSaveCol
   LOCAL aMenu
   LOCAL cText
   LOCAL nStatus, lLetter := .F.

   cSaveColor := SETCOLOR()
   nSaveRow   := ROW()
   nSaveCol   := COL()

   aMenu := saMenu[ saBar[hBar][BA_MENUS][nItem] ]
   cText := aMenu[MA_TITLE]

   IF BarChoice(hBar) == nItem
      nStatus := OM_NORMHI
   ELSE
      nStatus := OM_NORM
      lLetter := .T.
   ENDIF

   // Establish base text first and write letter over if necessary
   SETCOLOR( saBar[hBar][BA_COLOR][nStatus] )
   @ aMenu[MA_TTLROW], aMenu[MA_TTLCOL] SAY cText

   IF lLetter
      // Write over hotkey letter with letter in appropriate color
      SETCOLOR( saBar[hBar][BA_COLOR][OM_LETTER] )
      @ aMenu[MA_TTLROW], (aMenu[MA_TTLCOL] + aMenu[MA_KEYPOS] - 1) SAY aMenu[MA_HOTKEY]
   ENDIF

   SETCOLOR( cSaveColor )
   SETPOS( nSaveRow, nSaveCol )

   RETURN( hBar )


/***
*  MenuDispPrompt( <hMenu>, <nItem> ) --> hMenu
*  Display prompt in proper color string for status
*
*/
STATIC FUNCTION MenuDispPrompt( hMenu, nItem )
   LOCAL cSaveColor
   LOCAL nSaveRow, nSaveCol
   LOCAL nRow, nCol
   LOCAL hBar
   LOCAL aItem
   LOCAL cText
   LOCAL nStatus, lLetter := .F.

   cSaveColor := SETCOLOR()
   nSaveRow   := ROW()
   nSaveCol   := COL()

   hBar  := saMenu[hMenu][MA_OWNER]
   aItem := saMenu[hMenu][MA_ITEMS][nItem]

   // Temporary hold row and column so they can be adjusted
   nRow  := aItem[IA_ROW]
   nCol  := aItem[IA_COL]

   // Special handling for lines
   IF ItemIsLine( hMenu, nItem )
      cText := REPLICATE( OM_LINECHR, saMenu[hMenu][MA_WIDTH] )

      nCol--
      DO CASE
      CASE saBar[hBar][BA_BORDER] == OM_SINGLE
         cText := OM_LTSGLLINE + cText + OM_RTSGLLINE
      CASE saBar[hBar][BA_BORDER] == OM_DOUBLE
         cText := OM_LTDBLLINE + cText + OM_RTDBLLINE
      OTHERWISE
         cText := OM_LINECHR + cText + OM_LINECHR
      ENDCASE
      // Border is in letter color
      nStatus := OM_NORM
   ELSE
	  cText := PADR( aItem[IA_TEXT], saMenu[hMenu][MA_WIDTH] )

      IF aItem[IA_CHECKED]
         cText := STUFF(cText, 1, LEN(OM_CHKCHAR), OM_CHKCHAR)
      ENDIF

      IF aItem[IA_SUBMENU] != NIL
         cText := STUFF(cText, 1, LEN(OM_SUBCHAR), OM_SUBCHAR)
      ENDIF

      IF MenuChoice(hMenu) == nItem
         IF aItem[IA_ACTIVE]
            nStatus := OM_NORMHI
         ELSE
            nStatus := OM_GRAYHI
         ENDIF
      ELSE
         IF aItem[IA_ACTIVE]
            nStatus := OM_NORM
            lLetter := .T.
         ELSE
            nStatus := OM_GRAY
         ENDIF
      ENDIF
   ENDIF

   // establish base text first and write letter over if necessary
   SETCOLOR( saBar[hBar][BA_COLOR][nStatus] )
   @ nRow, nCol SAY cText

   IF lLetter
      // Write over hotkey letter with letter in appropriate color
      SETCOLOR( saBar[hBar][BA_COLOR][OM_LETTER] )
      @ aItem[IA_ROW], (aItem[IA_COL] + aItem[IA_KEYPOS] - 1) SAY aItem[IA_HOTKEY]
   ENDIF

   SETCOLOR( cSaveColor )
   SETPOS( nSaveRow, nSaveCol )

   RETURN( hMenu )


/***
*  BarOutKeys( <hBar> ) --> aArray
*
*/
STATIC FUNCTION BarOutKeys( hBar )
   LOCAL aArray := {}

   AADD( aArray, { K_F10, {|hBar| BarSetItem( hBar, 1 ), BarLastReq( hBar, OM_BARIN ) }, hBar } )

   RETURN( aArray )


/***
*  BarInKeys( <hBar> ) --> aArray
*
*/
STATIC FUNCTION BarInKeys( hBar )
   LOCAL aArray := {}

   AADD( aArray, { K_LEFT,  {|hBar| BarLeft(hBar) }, hBar } )
   AADD( aArray, { K_RIGHT, {|hBar| BarRight(hBar) }, hBar } )
   AADD( aArray, { K_ENTER, {|hBar| BarExecute(hBar) }, hBar } )
   AADD( aArray, { K_ESC,   {|hBar| BarSetItem(hBar, NIL), BarLastReq( hBar, OM_BAROUT ) }, hBar } )
   AADD( aArray, { NIL,     {|nKey| IF( SET(_SET_BELL), QQOUT(CHR(7)), NIL ) } } )

   RETURN( aArray )


/***
*  MenuKeys( <hMenu> ) --> aArray
*
*/
STATIC FUNCTION MenuKeys( hMenu )
   LOCAL aArray := {}

   AADD( aArray, { K_UP,    {|hMenu| MenuUp( hMenu ) }, hMenu } )
   AADD( aArray, { K_DOWN,  {|hMenu| MenuDown( hMenu ) }, hMenu } )
   AADD( aArray, { K_ENTER, {|hMenu| MenuExecute( hMenu ) }, hMenu } )
   AADD( aArray, { K_LEFT,  {|hMenu| BarLastReq( saMenu[hMenu][MA_OWNER], OM_BARLT ) }, hMenu } )
   AADD( aArray, { K_RIGHT, {|hMenu| BarLastReq( saMenu[hMenu][MA_OWNER], OM_BARRT ) }, hMenu } )
   AADD( aArray, { K_ESC,   {|hMenu| MenuSetItem(hMenu, NIL ), ;
                                     BarSetItem( saMenu[hMenu][MA_OWNER], NIL ), ;
                                     BarLastReq( saMenu[hMenu][MA_OWNER], OM_EXIT ) }, hMenu } )
   AADD( aArray, { NIL,     {|nKey| IF( SET(_SET_BELL), QQOUT(CHR(7)), NIL ) } } )

   RETURN( aArray )


/***
*  BarChoice( <hBar> ) --> nChoice
*
*/
STATIC FUNCTION BarChoice( hBar )
   RETURN( saBar[hBar][BA_CHOICE] )


/***
*  BarLeft( <hBar> ) --> hBar
*
*/
STATIC FUNCTION BarLeft( hBar )

   IF BarChoice( hBar ) == 1
      IF SET(_SET_WRAP)
         BarSetItem( hBar, LEN(saBar[hBar][BA_MENUS]) )
      ENDIF
   ELSE
      BarSetItem( hBar, BarChoice( hBar ) - 1 )
   ENDIF

   RETURN( hBar )


/***
*  BarRight( <hBar> ) --> hBar
*
*/
STATIC FUNCTION BarRight( hBar )

   IF BarChoice( hBar ) == LEN(saBar[hBar][BA_MENUS])
      IF SET(_SET_WRAP)
         BarSetItem( hBar, 1 )
      ENDIF
   ELSE
      BarSetItem( hBar, BarChoice( hBar ) + 1 )
   ENDIF

   RETURN( hBar )


/***
*  BarActOn( <nKey> ) --> NIL
*
*/
STATIC FUNCTION BarActon( nKey )

   // Requires that currbar be set correctly
   BarActivate( shCurrBar, nKey )

   RETURN( NIL )


/***
*  BarExecute( <hBar> ) --> hBar
*
*/
STATIC FUNCTION BarExecute( hBar )
   LOCAL hMenu

   hMenu := saBar[hBar][BA_MENUS][BarChoice( hBar )]
   EVAL( saMenu[hMenu][MA_BLOCK], hMenu )

   RETURN( hBar )


/***
*  BarAbort( <hBar> ) --> hBar
*
*/
STATIC FUNCTION BarAbort( hBar )

   BarLastReq( hBar, OM_EXIT )

   RETURN( BarSetItem( hBar, NIL ) )


/***
*  BarExit( <hBar> ) --> hBar
*
*/
STATIC FUNCTION BarExit( hBar )

   BarLastReq( hBar, OM_EXIT )

   RETURN( hBar )


/***
*  BarLastRequest( <hBar>, [<nReq>] ) --> nRequest
*
*/
STATIC FUNCTION BarLastRequest( hBar, nReq )

   IF nReq != NIL
      saBar[hBar][BA_LASTREQ] := nReq
   ENDIF

   RETURN( saBar[hBar][BA_LASTREQ] )


/***
*  BarSetItem( <hBar>, <nItem> ) --> hBar
*
*/
STATIC FUNCTION BarSetItem( hBar, nItem )
   LOCAL aMenu
   LOCAL nOldItem := saBar[hBar][BA_CHOICE]

   IF nItem != nOldItem
      saBar[hBar][BA_CHOICE] := nItem

      IF nOldItem != NIL
         // Redisplay old item unhighlighted
         BarDispPrompt( hBar, nOldItem )
      ENDIF

      IF nItem != NIL
         // Redisplay item highlighted
         BarDispPrompt( hBar, nItem )
      ENDIF
   ENDIF

   RETURN( hBar )


/***
*  MenuLastRequest( <hMenu>, [<nReq>] ) --> nRequest
*
*/
STATIC FUNCTION MenuLastRequest( hMenu, nReq )

   IF nReq != NIL
      saMenu[hMenu][MA_LASTREQ] := nReq
   ENDIF

   RETURN( saMenu[hMenu][MA_LASTREQ] )


/***
*  MenuSetItem( <hMenu>, <nItem> ) --> hMenu
*
*/
STATIC FUNCTION MenuSetItem( hMenu, nItem )
   LOCAL aItem
   LOCAL nOldItem := saMenu[hMenu][MA_CHOICE]

   IF nItem != nOldItem
      saMenu[hMenu][MA_CHOICE] := nItem

      IF nOldItem != NIL
         // Redisplay old item unhighlighted
         MenuDispPrompt( hMenu, nOldItem )
      ENDIF

      IF nItem != NIL
         // Redisplay item highlighted
         MenuDispPrompt( hMenu, nItem )
      ENDIF
   ENDIF

   RETURN( hMenu )


/***
*  MenuChoice( <hMenu> ) --> nChoice
*
*/
STATIC FUNCTION MenuChoice( hMenu )
   RETURN( saMenu[hMenu][MA_CHOICE] )


/***
*  MenuUp( <hMenu> ) --> hMenu
*
*/
STATIC FUNCTION MenuUp( hMenu )
   LOCAL nChoice

   nChoice := MenuChoice( hMenu )
   IF nChoice == 1
      IF SET(_SET_WRAP)
         MenuSetItem( hMenu, LEN(saMenu[hMenu][MA_ITEMS]) )
      ENDIF
   ELSE
      nChoice--
      DO WHILE ( ItemIsLine( hMenu, nChoice ) )
         nChoice--
      ENDDO
      MenuSetItem( hMenu, nChoice )
   ENDIF

   RETURN( hMenu )


/***
*  MenuDown( <hMenu> ) --> hMenu
*
*/
STATIC FUNCTION MenuDown( hMenu )
   LOCAL nChoice

   nChoice := MenuChoice( hMenu )
   IF nChoice == LEN(saMenu[hMenu][MA_ITEMS])
      IF SET(_SET_WRAP)
         MenuSetItem( hMenu, 1 )
      ENDIF
   ELSE
      nChoice++
      DO WHILE ( ItemIsLine( hMenu, nChoice ) )
         nChoice++
      ENDDO
      MenuSetItem( hMenu, nChoice )
   ENDIF

   RETURN( hMenu )


/***
*  MenuErase( <hMenu> ) --> hMenu
*
*/
STATIC FUNCTION MenuErase( hMenu )

   RESTSCREEN(saMenu[hMenu][MA_ROW], saMenu[hMenu][MA_COL], ;
              saMenu[hMenu][MA_LASTROW]+1, saMenu[hMenu][MA_LASTCOL]+1, ;
              saMenu[hMenu][MA_SAVESCR]);

   saMenu[hMenu][MA_SAVESCR] := ""  // Free up memory used
   RETURN hMenu


/***
*  MenuExecute( <hMenu> ) --> hMenu
*
*/
STATIC FUNCTION MenuExecute( hMenu )
   LOCAL hBar
   LOCAL aItem

   hBar  := saMenu[hMenu][MA_OWNER]
   aItem := saMenu[hMenu][MA_ITEMS][MenuChoice(hMenu)]

   IF aItem[IA_ACTIVE]
      IF aItem[IA_BLOCK] == NIL
         ForceExit(hMenu)
         BarMenuChoice( hBar, aItem[IA_ID] )
      ELSE
         EVAL( aItem[IA_BLOCK], hMenu, aItem[IA_ID], aItem[IA_2NDBLOCK] )
      ENDIF
      BarLastReq( hBar, OM_EXIT )
      BarSetItem( hBar, NIL )
   ENDIF

   RETURN( hMenu )


/***
*  MenuActivate( <hMenu> ) --> hMenu
*  Activate Menu menu as primary task (nothing else active)
*
*/
STATIC FUNCTION MenuActivate( hMenu )
   LOCAL aActiveKeys
   LOCAL nKey
   LOCAL uResult
   LOCAL nSaveCurs

   // Initialize
   saMenu[hMenu][MA_CHOICE] := 1
   BarLastReq( saMenu[hMenu][MA_OWNER], OM_BARIN )

   // Draw Menu
   MenuDisplay( hMenu )

   nSaveCurs := SET(_SET_CURSOR)

   // Check to see if cursor in menu area. If so, turn it off
   IF (ROW() >= saMenu[hMenu][MA_ROW]) .AND. ;
      (ROW() <= saMenu[hMenu][MA_LASTROW]) .AND. ;
      (COL() >= saMenu[hMenu][MA_COL]) .AND. ;
      (COL() <= saMenu[hMenu][MA_LASTCOL])

      SET(_SET_CURSOR, 0)
   ENDIF


   // Handle keystrokes
   DO WHILE BarLastReq( saMenu[hMenu][MA_OWNER] ) == OM_BARIN
      nKey := INKEY(0)

      uResult := DoKeyEvents( saMenu[hMenu][MA_KEYS], nKey )
   ENDDO

   // Restore Image that was under menu
   MenuErase( hMenu )
   SET(_SET_CURSOR, nSaveCurs)

   RETURN( hMenu )


/***
*  MenuSubActivate( <hMenu>, <nID> ) --> hMenu
*  Activate Submenu menu as primary task (nothing else active)
*
*/
STATIC FUNCTION MenuSubActivate( hMenu, nID )
   LOCAL nPrompt, aPrompt
   LOCAL hSub

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      aPrompt := saMenu[hMenu][MA_ITEMS][nPrompt]
      hSub := aPrompt[IA_SUBMENU]
      saMenu[hSub][MA_ROW] := aPrompt[IA_ROW]

      // Draw with small overlap
      saMenu[hSub][MA_COL] := saMenu[hMenu][MA_LASTCOL] - 1

      // Same bar "owns" both menus
      // Can't set this earlier because don't what bar owns it
      saMenu[hSub][MA_OWNER] := saMenu[hMenu][MA_OWNER]

      MenuActivate( hSub )
   ENDIF

   RETURN( hMenu )

/***
*  ItemIsLine()
*
*/
STATIC FUNCTION ItemIsLine( hMenu, nItem )
   RETURN( saMenu[hMenu][MA_ITEMS][nItem][IA_TEXT] == OM_LINECHR )

/***
*  CheckIt()
*  Used only by PromptAddToggle()
*
*/
STATIC FUNCTION CheckIt( hMenu, nID, bBlock )
   LOCAL lChecked

   IF (lChecked := PromptIsChecked(hMenu, nID))
      PromptUnCheck(hMenu, nID)
   ELSE
      PromptCheck(hMenu, nID)
   ENDIF

   IF bBlock != NIL
      EVAL( bBlock, !lChecked )
   ENDIF

   RETURN( hMenu )


/***
*  DoKeyEvents( <aKeys>, <nKey> ) ---> lKeyFound
*
*  Execute block associated with nKey if one exists and return .T.
*  otherwise return .F.
*
*  aKeys is an array of arrays: { nKey, bBlock, [uParam list] }
*
*/
STATIC FUNCTION DoKeyEvents( aKeys, nKey )
   LOCAL nCurrEvent
   LOCAL lExit   := .F.
   LOCAL lFound  := .F.

   // Force uppercase
   IF nKey >= ASC('a') .and. nKey <= ASC('z')
      nKey := ASC(UPPER(CHR(nKey)))
   ENDIF

   IF (nCurrEvent := ASCAN( aKeys, {|x| x[1] == nKey} )) == 0
      // Not any defined key so find NIL and execute it
      nCurrEvent := 0
      DO WHILE ( .NOT. lFound ) .AND. ( nCurrEvent < LEN( aKeys ) )
         nCurrEvent++
         IF aKeys[nCurrEvent, 1] == NIL
            lFound := .T.
         ENDIF
      ENDDO
      lExit :=  (!lFound)
   ENDIF
   IF .NOT. lExit

      // Handle up to five parameters
      DO CASE
      CASE LEN(aKeys[nCurrEvent]) == 2       /* 0 parameters */
         EVAL( aKeys[nCurrEvent, 2], nKey )

      CASE LEN(aKeys[nCurrEvent]) == 3       /* 1 parameter  */
         EVAL( aKeys[nCurrEvent, 2], aKeys[nCurrEvent, 3] )

      CASE LEN(aKeys[nCurrEvent]) == 4       /* 2 parameters */
         EVAL( aKeys[nCurrEvent, 2], aKeys[nCurrEvent, 3], ;
                                     aKeys[nCurrEvent, 4])

      CASE LEN(aKeys[nCurrEvent]) == 5       /* 3 parameters */
         EVAL( aKeys[nCurrEvent, 2], aKeys[nCurrEvent, 3], ;
                                     aKeys[nCurrEvent, 4], ;
                                     aKeys[nCurrEvent, 5])

      CASE LEN(aKeys[nCurrEvent]) == 6       /* 4 parameters */
         EVAL( aKeys[nCurrEvent, 2], aKeys[nCurrEvent, 3], ;
                                     aKeys[nCurrEvent, 4], ;
                                     aKeys[nCurrEvent, 5], ;
                                     aKeys[nCurrEvent, 6])

      OTHERWISE
         EVAL( aKeys[nCurrEvent, 2], aKeys[nCurrEvent, 3], ;
                                     aKeys[nCurrEvent, 4], ;
                                     aKeys[nCurrEvent, 5], ;
                                     aKeys[nCurrEvent, 6], ;
                                     aKeys[nCurrEvent, 7])

      ENDCASE

   ENDIF

   RETURN( !lExit )


/***
*  LetterAsAltKey( <nKey> ) ---> nAltKey
*
*/
STATIC FUNCTION LetterAsAltKey( nKey )
   LOCAL nAltKey
   // Conversion table
   STATIC saRegAltKeys := { { 65, K_ALT_A }, ;
                           { 66, K_ALT_B }, ;
                           { 67, K_ALT_C }, ;
                           { 68, K_ALT_D }, ;
                           { 69, K_ALT_E }, ;
                           { 70, K_ALT_F }, ;
                           { 71, K_ALT_G }, ;
                           { 72, K_ALT_H }, ;
                           { 73, K_ALT_I }, ;
                           { 74, K_ALT_J }, ;
                           { 75, K_ALT_K }, ;
                           { 76, K_ALT_L }, ;
                           { 77, K_ALT_M }, ;
                           { 78, K_ALT_N }, ;
                           { 79, K_ALT_O }, ;
                           { 80, K_ALT_P }, ;
                           { 81, K_ALT_Q }, ;
                           { 82, K_ALT_R }, ;
                           { 83, K_ALT_S }, ;
                           { 84, K_ALT_T }, ;
                           { 85, K_ALT_U }, ;
                           { 86, K_ALT_V }, ;
                           { 87, K_ALT_W }, ;
                           { 88, K_ALT_X }, ;
                           { 89, K_ALT_Y }, ;
                           { 90, K_ALT_Z } }


   nKey    := ASC( UPPER( CHR(nKey) ) )  // Make sure it is uppercase
   nAltKey := ASCAN( saRegAltKeys, {|x| x[1] == nKey} )

   RETURN( IIF( nAltKey > 0, saRegAltKeys[nAltKey, 2], 0 ) )


/***
*  PauseKey( <nSecs> ) --> nKey
*  Similar to inkey(), except services SET KEYs
*
*/
STATIC FUNCTION PauseKey( nSecs )
   LOCAL nKey
   LOCAL bKeyBlock

   nKey := INKEY( nSecs )

   DO WHILE ( (bKeyBlock := SETKEY(nKey)) != NIL )
      EVAL(bKeyBlock, PROCNAME(2), PROCLINE(2))
      nKey := INKEY( nSecs )
   ENDDO

   RETURN( nKey )

/***
*  BarActivate( <hBar>, [<nKey>] ) --> nMenuChoice
*  Activate bar menu as primary task (nothing else active)
*
*/
FUNCTION BarActivate( hBar, nKey )
   LOCAL aActiveKeys
   LOCAL nResult

   // Handle keystrokes
   IF nKey != NIL
      aActiveKeys := saBar[hBar][BA_OUTKEYS]
      IF !DoKeyEvents( aActiveKeys, nKey )
         BarLastReq( hBar, OM_EXIT )
      ENDIF
   ELSE
      // Draw bar
      BarDisplay( hBar )

      // Initialize
      BarSetItem( hBar, NIL )
      BarLastReq( hBar, OM_BAROUT )
   ENDIF
   DO WHILE BarLastReq( hBar ) != OM_EXIT
      DO CASE
      CASE BarLastReq( hBar ) == OM_BAROUT
         aActiveKeys := saBar[hBar][BA_OUTKEYS]
         nKey := INKEY(0)
         DoKeyEvents( aActiveKeys, nKey )

      CASE BarLastReq( hBar ) == OM_BARIN
         aActiveKeys := saBar[hBar][BA_INKEYS]
         nKey := INKEY(0)
         DoKeyEvents( aActiveKeys, nKey )

      CASE BarLastReq( hBar ) == OM_BARRT
         BarLastReq( hBar, OM_BARIN )
         BarRight( hBar )
         BarExecute( hBar )

      CASE BarLastReq( hBar ) == OM_BARLT
         BarLastReq( hBar, OM_BARIN )
         BarLeft( hBar )
         BarExecute( hBar )

      ENDCASE
   ENDDO

   RETURN( BarMenuChoice( hBar ) )

/***
*  BarDeInstall( <hBar> ) --> hBar
*  Uninstall menubar from SET KEY handler
*
*/
FUNCTION BarDeInstall( hBar )
   LOCAL i
   LOCAL aKeys := saBar[hBar][BA_OUTKEYS]

   FOR i := 1 TO LEN( aKeys )
      SETKEY( aKeys[i][1], NIL )
   NEXT

   shCurrBar := NIL

   RETURN hBar

/***
*  BarDisplay( <hBar> ) --> hBar
*  Display a menubar to the screen
*
*/
FUNCTION BarDisplay( hBar )
   LOCAL i
   LOCAL nLen
   LOCAL nCol := 1, nRow := 1
   LOCAL aMenu
   LOCAL cSaveColor, nSaveRow, nSaveCol

   nSaveRow   := ROW()
   nSaveCol   := COL()
   cSaveColor := SETCOLOR( saBar[hBar][BA_COLOR][OM_NORM] )

   @ nRow, 0 CLEAR TO nRow, MAXCOL()

   nLen := LEN(saBar[hBar][BA_MENUS])
   FOR i := 1 TO nLen
      // Put referential nature of arrays to good use
      aMenu := saMenu[ saBar[hBar][BA_MENUS][i] ]

      // Make sure column will fit
      IF ( nCol + LEN(aMenu[MA_TITLE]) ) > MAXCOL()
         // Establish new row for menus
         nRow++
         nCol := 1
         @ nRow, 0 CLEAR TO nRow, MAXCOL()
      ENDIF

      aMenu[MA_TTLROW] := nRow
      aMenu[MA_TTLCOL] := nCol
      aMenu[MA_ROW]    := nRow + 1
      aMenu[MA_COL]    := nCol - 1

      BarDispPrompt( hBar, i )

      nCol += LEN(aMenu[MA_TITLE])
   NEXT
   SETPOS(nSaveRow, nSaveCol)
   SETCOLOR( cSaveColor )

   RETURN( hBar )

/***
*  BarInstall( <hBar> ) --> hBar
*  Install a menubar into the SET KEY handler
*
*/
FUNCTION BarInstall( hBar )
   LOCAL i
   LOCAL aKeys := saBar[hBar][BA_OUTKEYS]

   FOR i := 1 TO LEN( aKeys )
      SETKEY( aKeys[i][1], {|| BarActOn(LASTKEY())} )
   NEXT

   // Set bar as current bar
   shCurrBar := hBar

   RETURN hBar

/***
*  BarMenuChoice( <hBar>, [<nChoice>] ) --> nChoice
*
*/
FUNCTION BarMenuChoice( hBar, nChoice )

   IF nChoice != NIL
      saBar[hBar][BA_MCHOICE] := nChoice
   ENDIF

   RETURN( saBar[hBar][BA_MCHOICE] )

/***
*  BarNew( <cColor>, <nBorder> ) --> hBar
*  Create a new menubar and return a handle to it
*
*/
FUNCTION BarNew( cColor, nBorder )
   LOCAL aBar[BA_LEN]
   LOCAL hBarHandle
   aSize(saBar,0)
   aSize(saMenu,0)

   // Add bar array to global holder
   IF ( LEN(saBar) == 0 ) .OR. ( hBarHandle := (NilScan(saBar) == 0) )
      AADD( saBar, aBar )
      hBarHandle := 1
   ELSE
      saBar[hBarHandle] := aBar
   ENDIF

   // Fill it in through equivalent array
   aBar[BA_OUTKEYS] := BarOutKeys( hBarHandle )
   aBar[BA_INKEYS]  := BarInKeys( hBarHandle )
   aBar[BA_CHOICE]  := NIL
   aBar[BA_MCHOICE] := OM_CONT
   aBar[BA_COLOR]   := ListAsArray( IIF( cColor == NIL, ;
                                    IIF( ISCOLOR(), OM_DEFCLR, OM_DEFBW ), ;
                                    cColor ) )
   aBar[BA_BORDER]  := OM_DEFBORD
   aBar[BA_MENUS]   := {}

   RETURN( hBarHandle )

/***
*  MenuAdd( <hMenu> ) --> hBar
*  Add a menu to menubar
*
*/
FUNCTION MenuAdd( hBar, hMenu )

   saMenu[hMenu][MA_OWNER] := hBar

   AADD( saBar[hBar][BA_MENUS], hMenu )

   // Add Alt Key sequence to "out" keys
   AADD( saBar[hBar][BA_OUTKEYS], ;
         { LetterAsAltKey(ASC(saMenu[hMenu][MA_HOTKEY])), ;
           {|hBar, nItem| BarSetItem(hBar, nItem), ;
                          BarLastReq(hBar, OM_BARIN), ;
                          BarExecute(hBar) }, ;
           hBar, ;
           LEN(saBar[hBar][BA_MENUS]);
         } )

   // Add key to "in" keys (after F10 is hit)
   AADD( saBar[hBar][BA_INKEYS], ;
         { ASC(saMenu[hMenu][MA_HOTKEY]), ;
           {|hBar, nItem| BarSetItem(hBar, nItem), ;
                          BarLastReq(hBar, OM_BARIN), ;
                          BarExecute(hBar) }, ;
           hBar, ;
           LEN(saBar[hBar][BA_MENUS]);
         } )
   RETURN( hBar )

/***
*  MenuDisplay( <hMenu> ) --> hMenu
*  Display a menu to the screen
*
*/
FUNCTION MenuDisplay( hMenu )
   LOCAL i
   LOCAL hBar
   LOCAL nLen
   LOCAL aItem, aLongItem
   LOCAL nRow, nCol, nLastRow, nLastCol
   LOCAL cSaveColor, nSaveRow, nSaveCol

   hBar      := saMenu[hMenu][MA_OWNER]
   aItem     := saMenu[hMenu][MA_ITEMS]
   aLongItem := ACOMP( aItem, {|x,y| LEN(x[IA_TEXT]) > LEN(y[IA_TEXT])} )

   saMenu[hMenu][MA_WIDTH] := MAX( LEN( aLongItem[IA_TEXT] ), LEN( saMenu[hMenu][MA_TITLE] ) )

   nSaveCol := COL()
   nCol     := saMenu[hMenu][MA_COL]
   nLastCol := nCol + saMenu[hMenu][MA_WIDTH] + 1

   // Check to see if I have tried to go off the screen horizontally
   IF nLastCol > MAXCOL()
      nCol     := saMenu[hMenu][MA_COL] ;
               := MAXCOL() - 1 - saMenu[hMenu][MA_WIDTH]
      nLastCol := MAXCOL()

      IF nCol < 0
         // Error, tried to display menu that is wider than the screen
         MenuError( ME_TOOWIDE )
      ENDIF
   ENDIF

   nSaveRow := ROW()
   nRow     := saMenu[hMenu][MA_ROW]
   nLastRow := nRow + LEN(aItem) + 1

   // Check to see if I have tried to go off the screen vertically
   IF nLastRow > MAXROW()
      nRow     := saMenu[hMenu][MA_ROW] ;
               := MAXROW() - 1 - LEN(aItem)
      nLastCol := MAXROW()

      IF nRow < 0
         // Error, tried to display menu that is longer than the screen
         MenuError( ME_TOOLONG )
      ENDIF
   ENDIF

   saMenu[hMenu][MA_SAVESCR] := SAVESCREEN(nRow, nCol, nLastRow+1, nLastCol+1)
   // add 1 for shadow
   saMenu[hMenu][MA_LASTROW] := nLastRow
   saMenu[hMenu][MA_LASTCOL] := nLastCol

   cSaveColor := SETCOLOR( saBar[hBar][BA_COLOR][OM_NORM] )

   @ nRow, nCol CLEAR TO nLastRow, nLastCol
   shadow(nRow, nCol, nLastRow, nLastCol)     //paint the shadow

/*   SETCOLOR( saBar[hBar][BA_COLOR][OM_LETTER] ) */
   SETCOLOR( saBar[hBar][BA_COLOR][OM_NORM] )
   DO CASE
   CASE saBar[hBar][BA_BORDER] == OM_SINGLE
       @ nRow, nCol TO nLastRow, nLastCol
   CASE saBar[hBar][BA_BORDER] == OM_DOUBLE
       @ nRow, nCol TO nLastRow, nLastCol DOUBLE
   ENDCASE

   SETCOLOR( cSaveColor )

   nLen := LEN(aItem)
   FOR i := 1 TO nLen
      aItem[i][IA_ROW] := nRow + i
      aItem[i][IA_COL] := nCol + 1

      MenuDispPrompt( hMenu, i )
   NEXT
   SETPOS( nSaveRow, nSaveCol )

   RETURN( hMenu )

/***
*  MenuNew( <cTitle> ) --> hMenuHandle
*  Create a new menu and return a new handle to it
*
*/
FUNCTION MenuNew( cTitle )
   LOCAL aMenu[MA_LEN]
   LOCAL hMenuHandle

   cTitle := " " + cTitle + " "  // Pad out correctly

   // Add menu array to global holder
   IF ( LEN(saMenu) == 0 ) .OR. ( hMenuHandle := (NilScan(saMenu) == 0) )
      AADD( saMenu, aMenu )
      hMenuHandle := LEN( saMenu )
   ELSE
      saMenu[hMenuHandle] := aMenu
   ENDIF

   // Setup header information
   aMenu[MA_ROW]    := 0
   aMenu[MA_COL]    := 0
   aMenu[MA_WIDTH]  := 0
   aMenu[MA_KEYS]   := MenuKeys( hMenuHandle )
   aMenu[MA_ITEMS]  := {}
   aMenu[MA_TITLE]  := STRTRAN( cTitle, OM_HKCHAR, "" )
   aMenu[MA_KEYPOS] := AT( OM_HKCHAR, cTitle )
   aMenu[MA_HOTKEY] := IIF( aMenu[MA_KEYPOS] == 0, "", ;
                            SUBSTR( cTitle, aMenu[MA_KEYPOS] + 1, 1 ) )
   aMenu[MA_BLOCK]  := {|hMenu| MenuActivate(hMenu) }
   aMenu[MA_CHOICE] := NIL

   RETURN( hMenuHandle )

/***
*  PostExitBlock( [<bBlock>] ) --> bOldBlock
*  Post a code block to execute when a function is terminated
*
*/
FUNCTION PostExitBlock( bBlock )
   LOCAL bOldBlock := sbExitBlock

   sbExitBlock := bBlock

   RETURN( bOldBlock )

/***
*  PromptAction( <hMenu>, <nID>, <bBlock> ) --> hMenu
*  Change the menu action block
*
*/
FUNCTION PromptAction( hMenu, nID, bBlock )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      saMenu[hMenu][MA_ITEMS][nPrompt][IA_BLOCK] := bBlock
   ENDIF

   RETURN( hMenu )

/***
*  PromptAdd( <hMenu>, <nID>, <cText>, <bBlock> ) --> hMenu
*  Add a prompt to the menu
*
*/
FUNCTION PromptAdd( hMenu, nID, cText, bBlock )
   LOCAL aPrompt[IA_LEN]

   cText := SPACE(OM_PAD) + cText

   aPrompt[IA_TEXT]    := STRTRAN( cText, OM_HKCHAR, "" )
   aPrompt[IA_ID]      := nID
   aPrompt[IA_ACTIVE]  := .T.
   aPrompt[IA_CHECKED] := .F.
   aPrompt[IA_SUBMENU] := NIL
   aPrompt[IA_KEYPOS]  := AT( OM_HKCHAR, cText )
   aPrompt[IA_HOTKEY]  := IIF( aPrompt[IA_KEYPOS] == 0, "", ;
                             SUBSTR( cText, aPrompt[IA_KEYPOS] + 1, 1 ) )

   // Assign Block
   aPrompt[IA_BLOCK]   := bBlock

   AADD( saMenu[hMenu][MA_ITEMS], aPrompt )

   // Add to key event array
   AADD( saMenu[hMenu][MA_KEYS], { ASC(UPPER(aPrompt[IA_HOTKEY])), ;
                    {|hMenu,nID| MenuSetItem(hMenu,PromptFind(hMenu,nID)),;
                                 MenuExecute(hMenu)}, ;
                    hMenu, nID} )

   RETURN( hMenu )

/***
*  PromptAddLine( <hMenu> ) --> hMenu
*  Add a line separator between prompts
*
*/
FUNCTION PromptAddLine( hMenu )
   LOCAL aPrompt[IA_LEN]

   aPrompt[IA_TEXT]    := OM_LINECHR
   aPrompt[IA_ACTIVE]  := .F.
   aPrompt[IA_CHECKED] := .F.
   aPrompt[IA_SUBMENU] := NIL

   // Add Prompt to Menu
   AADD( saMenu[hMenu][MA_ITEMS], aPrompt )

   RETURN( hMenu )

/***
*  PromptAddSub( <hMenu>, <nID>, <hSubMenu> ) --> hMenu
*  Add a hierarchical submenu to an existing menu
*
*/
FUNCTION PromptAddSub( hMenu, nID, hSubMenu )
   LOCAL aPrompt[IA_LEN]
   LOCAL cText

   // Minus 1 because of the space added by MenuNew()
   cText := STUFF(SPACE(OM_PAD-1) + saMenu[hSubMenu][MA_TITLE], 1, 1, OM_SUBCHAR)

   aPrompt[IA_TEXT]    := cText
   aPrompt[IA_ID]      := nID
   aPrompt[IA_SUBMENU] := hSubMenu
   aPrompt[IA_CHECKED] := .F.
   aPrompt[IA_ACTIVE]  := .T.
   aPrompt[IA_KEYPOS]  := saMenu[hSubMenu][MA_KEYPOS] + 1  // +1 due to extra " "
   aPrompt[IA_HOTKEY]  := saMenu[hSubMenu][MA_HOTKEY]

   aPrompt[IA_BLOCK]   := {|hMenu,nID| MenuSubActivate( hMenu, nID ) }

   AADD( saMenu[hMenu][MA_ITEMS], aPrompt )

   // Add key to key event array
   AADD( saMenu[hMenu][MA_KEYS], { ASC(UPPER(aPrompt[IA_HOTKEY])), ;
                    {|hMenu,nID| MenuSetItem(hMenu,PromptFind(hMenu,nID)),;
                                 MenuExecute(hMenu)}, ;
                    hMenu, nID} )

   RETURN( hMenu )

/***
*  PromptAddToggle( <hMenu>, <nID>, <cText>, <bBlock> ) --> hMenu
*
*  Has to be separate from PromptAdd because of needing to add bBlock to
*  key event array
*
*/
FUNCTION PromptAddToggle( hMenu, nID, cText, bBlock )
   LOCAL aPrompt[IA_LEN]

   cText := SPACE(OM_PAD) + cText

   aPrompt[IA_TEXT]    := STRTRAN( cText, OM_HKCHAR, "" )
   aPrompt[IA_ID]      := nID
   aPrompt[IA_ACTIVE]  := .T.
   aPrompt[IA_CHECKED] := .F.
   aPrompt[IA_SUBMENU] := NIL
   aPrompt[IA_KEYPOS]  := AT( OM_HKCHAR, cText )
   aPrompt[IA_HOTKEY]  := IIF( aPrompt[IA_KEYPOS] == 0, "", ;
                             SUBSTR( cText, aPrompt[IA_KEYPOS] + 1, 1 ) )

   // Assign Block
   aPrompt[IA_BLOCK]    := {|hMenu, nID, bBlock| CheckIt(hMenu, nID, bBlock)}
   aPrompt[IA_2NDBLOCK] := bBlock

   // Add Prompt to Menu
   AADD( saMenu[hMenu][MA_ITEMS], aPrompt )

   // Add to key event array
   AADD( saMenu[hMenu][MA_KEYS], { ASC(UPPER(aPrompt[IA_HOTKEY])), ;
                    {|hMenu,nID| MenuSetItem(hMenu,PromptFind(hMenu,nID)),;
                                 MenuExecute(hMenu)}, ;
                    hMenu, nID} )

   RETURN( hMenu )

/***
*  PromptCheck( <hMenu>, <nID> ) --> hMenu
*  Mark a menu prompt with a check mark
*
*/
FUNCTION PromptCheck( hMenu, nID )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      saMenu[hMenu][MA_ITEMS][nPrompt][IA_CHECKED] := .T.
   ENDIF

   RETURN( hMenu )

/***
*  PromptEnable( <hMenu>, <nID> ) --> hMenu
*  Ungray a menu prompt
*
*/
FUNCTION PromptEnable( hMenu, nID )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      saMenu[hMenu][MA_ITEMS][nPrompt][IA_ACTIVE] := .T.
   ENDIF

   RETURN( hMenu )

/***
*  PromptGray( <hMenu>, <nID> ) --> hMenu
*  Gray a menu prompt
*
*/
FUNCTION PromptGray( hMenu, nID )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      saMenu[hMenu][MA_ITEMS][nPrompt][IA_ACTIVE] := .F.
   ENDIF

   RETURN( hMenu )

/***
*  PromptIsChecked( <hMenu>, <nID> ) --> lChecked
*  Determine if a menu prompt is checked
*
*/
FUNCTION PromptIsChecked( hMenu, nID )
   LOCAL nPrompt

   nPrompt := PromptFind( hMenu, nID )

   RETURN( IIF( nPrompt == 0, .F., saMenu[hMenu][MA_ITEMS][nPrompt][IA_CHECKED] ) )

/***
*  PromptIsEnabled( <hMenu>, <nID> ) --> lEnabled
*  Determine if a menu prompt is active
*
*/
FUNCTION PromptIsEnabled( hMenu, nID )
   LOCAL nPrompt

   nPrompt := PromptFind( hMenu, nID )

   RETURN( IIF( nPrompt == 0, .F., saMenu[hMenu][MA_ITEMS][nPrompt][IA_ACTIVE] ) )

/***
*  PromptQuickKey( <hBar>, <hMenu>, <nID>, <nKey> ) --> hMenu
*  Assign nKey to nID
*
*/
FUNCTION PromptQuickKey( hBar, hMenu, nID, nKey )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      AADD( saBar[hBar][BA_OUTKEYS], { nKey, ;
                                       {|hMenu, nID| saMenu[hMenu][MA_CHOICE] := PromptFind( hMenu, nID ), ;
                                                MenuExecute(hMenu)}, ;
                                        hMenu, nID } )
   ENDIF

   RETURN (hMenu)

/***
*  PromptUnCheck( <hMenu>, <nID> ) --> hMenu
*  Uncheck menu prompt
*
*/
FUNCTION PromptUnCheck( hMenu, nID )
   LOCAL nPrompt

   IF ( (nPrompt := PromptFind( hMenu, nID )) > 0 )
      saMenu[hMenu][MA_ITEMS][nPrompt][IA_CHECKED] := .F.
   ENDIF

   RETURN( hMenu )

/***
*  MenuError( nErr ) --> NIL
*  Unrecoverable menu error, report it
*
*/
STATIC FUNCTION MenuError( nErr )
   LOCAL oErr

   oErr := ErrorNew()

   oErr:canDefault    := .F.
   oErr:canRetry      := .F.
   oErr:canSubstitute := .F.

   oErr:genCode       := EG_COMPLEXITY
   oErr:severity      := ES_ERROR
   oErr:description   := "Menu will not fit on screen"
   oErr:subCode       := nErr
   oErr:subSystem     := "OMENU"

   EVAL( ERRORBLOCK(), oErr )

   QUIT  // Should never reach this point
   RETURN NIL
