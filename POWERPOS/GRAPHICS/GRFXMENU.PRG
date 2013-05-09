/*
* System......... Graphics Pop-up Menu Routine 
* Program I.D.... GrfxMenu.prg
* Description.... User Defined Achoice/Menu Routine
*                   
* Author......... jay ocampo
* Date Started... July 1994
* Dialect........ Clipper plus Graphics lib from Turbo C++
* Remarks........
*
*/


#include "INKEY.CH"
#include "SET.CH"
#include "GRFX_ALL.CH"



FUNCTION GrfxAChoice( aMenuItems, nLeft, nTop, nRight, nBottom, cMenuTitle, nChoice, ; 
                      nFont, nSize, nFontHilite, nSizeHilite, ;
                      nNormColor, nHiliteColor, nFillColor, nBarColor, ;
                      cScrFile, nUlineFlag)
                   

  /*
     USAGE  : Simulate CLIPPER's ACHOICE() function
     PARAM  :  
               aMenuItems          -> Array of character strings to display as menu items
               nLeft, nTop         -> Upper left box coordinates
               [nBottom], [nRight] -> Lower right box coordinates
               [cMenuTitle]        -> Character string as Menu Title
               [nChoice]           -> Initial Highlighted Item
               [nFont]             -> FONT for Menu Item Display
               [nSize]             -> FONT Size for Menu Item Display
               [nFontHilite]       -> FONT for Menu Item Hotkey Display
               [nSizeHilite]       -> FONT Size for Menu Item Hotkey Display
               [nNormColor]        -> Color of Unselected Menu Item and Box Border
               [nHiliteColor]      -> Color of Hot Keys and Selected Menu Item
               [nFillColor]        -> Fill Color of the Box 
               [nBarColor]         -> Color of the Highlight Bar
               [cScrFile]          -> Save Screen Filename
               [nUlineFlag]        -> Underline HotKey flag
              
     Returns: the numeric position in the <aMenuItems> array of the menu
              item selected.
  */

  * Declared variables
   LOCAL lArrNotChar   := .F.               // Check if any element is not of character type
   LOCAL nLength       := 1                 // Numeric that holds Longest Menu Item Width (in terms of pixels)
   LOCAL nMenuRow      := 0                 // Row coordinate for the first menu item prompt (in pixels)
   LOCAL nMenuCol      := 0                 // Column coordinate for menu item prompt (in pixels)
   LOCAL nCurrCol      := 0                 // Temporary Column position (in pixels)
   LOCAL nFontHite     := 0                 // Maximum Character Height of the two Fonts Height
   LOCAL nFontDif      := 0                 // Difference in Character Height of the two Fonts 
   LOCAL nFontWide     := 0                 // FontHilite Character Width 
   LOCAL iBlockLen     := 0                 // Number of Replicates of the Bar Character (219) to superimpose every menu item
   LOCAL cStrHotKeys   := ""                // String of HotKeys
   LOCAL lExitLoop     := .F.               // Logical variable to exit Menu
   LOCAL nItemSelected := 0                 // Shadow variable of nChoice
   LOCAL nInkyCode     := 0                 // Variable that holds Ascii Code of keys pressed
   LOCAL iCtr          := 0                 // Temporary Counter Variable
   LOCAL cStrBuffer    := ""                // Temporary String Buffer
   LOCAL iBoxADJ       := 0                 // Box Adjustment (in pixels)
   LOCAL nMenuCnt      := LEN(aMenuItems)   // Number of Elements of aMenuItems array
   LOCAL aHotKeys      := ARRAY(nMenuCnt)   // Array composed of location of Hotkey Characters in Menu Items

   // If no array passed return NIL
   IF aMenuItems == NIL 
      RETURN NIL
   ENDIF


   // Check if any element is not of character type.
   ASCAN( aMenuItems, { |str| lArrNotChar := ( VALTYPE( str ) <> "C" ) } )

   // If any element is not of character type then return NIL
   IF lArrNotChar
      RETURN NIL
   ENDIF
    
   // Store each aMenuItems Element's Hot Key
   cStrHotKeys := FormatMenu(aMenuItems, aHotKeys)


    // Handle Omitted Parameters
   nTop         := IIF( nTop         == NIL, 0, nTop )
   nLeft        := IIF( nLeft        == NIL, 0, nLeft )
   nChoice      := IIF( nChoice      == NIL, 1, nChoice )
   nFont        := IIF( nFont        != NIL, nFont       , gGrfxConfg(CFONT_CFG)) 
   nSize        := IIF( nSize        != NIL, nSize       , gGrfxConfg(CFSIZE_CFG)) 
   nFontHilite  := IIF( nFontHilite  != NIL, nFontHilite , nFont) 
   nSizeHilite  := IIF( nSizeHilite  != NIL, nSizeHilite , nSize) 
   nNormColor   := IIF( nNormColor   != NIL, nNormColor  , gGrfxConfg(FCOLOR_CFG)) 
   nHiliteColor := IIF( nHiliteColor != NIL, nHiliteColor, nNormColor)
   nFillColor   := IIF( nFillColor   != NIL, nFillColor  , gGrfxConfg(BCOLOR_CFG)) 
   nBarColor    := IIF( nBarColor    != NIL, nBarColor   , MOD(nHiliteColor + 1, 15)) 
   nUlineFlag   := IIF( nUlineFlag   != NIL, nUlineFlag  , ULINE_ON)
   nChoice      := MIN(nChoice, nMenuCnt)
   nItemSelected := nChoice

   // Calculate for Box border adjustments
   iBoxADJ := INT( SCALE_Y * ( SCR_SCALE / 6) / SCALE_X)


   // Set nFontHilite and nSizeHilite Setting
   gDrawText(0, 0, "", nFontHilite, nSizeHilite, nNormColor, ;
             MBOTHREL, LEFT_TEXT, WRAPTEXT_OFF, ULINE_OFF)

   // Save Font Height & Width
   nFontHite := gGrfxConfg(CHAR_HEIGHT_CFG)
   nFontWide := gGrfxConfg(CHAR_WIDTH_CFG)

   // Set Font and Size Setting
   gDrawText(0, 0, "", nFont, nSize, nNormColor, ;
             MBOTHREL, LEFT_TEXT, WRAPTEXT_OFF, ULINE_OFF)
   
   // Get Maximum Font Height
   nFontDif  := nFontHite - gGrfxConfg(CHAR_HEIGHT_CFG)
   nFontDif  := IIF( nFontDif < 0, 0, nFontDif)
   nFontHite := MAX(nFontHite, gGrfxConfg(CHAR_HEIGHT_CFG))


   // Determine the starting row and column of the first menu prompt
   nTop     := INT(nTop  * SCALE_Y / SCR_SCALE)
   nLeft    := INT(nLeft * SCALE_X / SCR_SCALE)
   nMenuRow := nTop  
   nMenuCol := nLeft 
   nMenuRow := INT( nMenuRow + 0.5) + iBoxADJ      // Add box adjustment
   nMenuCol := INT( nMenuCol + 0.5) + iBoxADJ      // Add box adjustment
   

   // In case, normal font and font hilite size are different
   IF (cMenuTitle == NIL)
       nMenuRow := nMenuRow + nFontDif
   ENDIF
   
   // Find the array element with widest character Font Size
   ASCAN( aMenuItems, { |str| nLength:= MAX( nLength, gGrfxConfg(CHAR_WIDTH_CFG, str)) } )
   nLength += nFontWide
   nLength := IIF(cMenuTitle == NIL, nLength, ;
                  MAX(nLength, gGrfxConfg(CHAR_WIDTH_CFG, cMenuTitle)))
                     

   // Determine the length of Highlight Character "Û"
   iBlockLen := nLength / gGrfxConfg(CHAR_WIDTH_CFG, CHR(219))
   iBlockLen := INT( iBlockLen  + 0.5)     
   
   // Check nBottom and nRight Box parameters
   IF (nBottom == NIL)
      nBottom := (nMenuCnt + 1) * nFontHite           // Calculate how many pixels for all menu items 
      nBottom := nBottom + nMenuRow - nFontDif        // Add Top Row coordinate
      nBottom += iBoxADJ                              // Add Box border Adjustment
      nBottom := IIF(cMenuTitle != NIL, nBottom + (nFontHite * 2) , nBottom) 
   ELSE
      nBottom := INT(nBottom  * SCALE_Y / SCR_SCALE)
   ENDIF

   IF (nRight == NIL)
      nRight := nMenuCol + nLength   
      nRight += gGrfxConfg(CHAR_WIDTH_CFG) * 2
      nRight += iBoxADJ                               // Add Box border Adjustment
   ELSE
      nRight := INT(nRight * SCALE_X / SCR_SCALE)
   ENDIF


   IF !EMPTY(cScrFile)
       gScrnSave( nLeft, nTop, nRight, nBottom, cScrFile, MPIXEL )
   ENDIF       

   // Paint the box
   gDrawBox(nLeft, nTop, nRight, nBottom, BUTTON_UP_LINE, NORM_WIDTH, ;
            nNormColor, SOLID_FILL, nFillColor, MPIXEL)


   // Display Menu Title
   IF cMenuTitle != NIL
      nCurrCol := nRight - nMenuCol 
      nCurrCol := nMenuCol + ( nCurrCol / 2)
      gDrawText(nMenuRow, nCurrCol, cMenuTitle, ;
                nFont, nSize, nHiliteColor, MPIXEL, CENTER_TEXT)
                
      nMenuRow += nFontHite * 1.5

      // Draw Menu Title Line
      gDrawLine(nLeft + iboxADJ, nMenuRow, nRight - iboxADJ, nMenuRow, ;
                BUTTON_UP_LINE, NORM_WIDTH, nFillColor, MPIXEL)
                
      nMenuRow += nFontHite / 2
      
   ENDIF

   // Adjust nMenuCol
   nMenuCol += gGrfxConfg(CHAR_WIDTH_CFG)    
      
   
   // Display all Menu Items
   FOR iCtr := 1 TO nMenuCnt
       MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                    iBlockLen, iCtr, nFontHite, nFont, nSize, ;
                    nFontHilite, nSizeHilite, ;
                    nNormColor, nHiliteColor, nFillColor, nUlineFlag)
   NEXT iCtr

   // Display Highlighted Item
   MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                iBlockLen, nItemSelected, nFontHite, nFont, nSize, ;
                nFontHilite, nSizeHilite, ;
                nHiliteColor, nHiliteColor, nBarColor, nUlineFlag)


   DO WHILE !lExitLoop

      nInkyCode := INKEY(0)

      DO CASE
         CASE ( nInkyCode == K_ENTER .OR. nInkyCode == K_ESC )
              
              nChoice := IIF(nInkyCode == K_ENTER, nItemSelected, 0)

               // Clear Previous Highlight
              MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                           iBlockLen, nItemSelected, nFontHite, nFont, nSize, ;
                           nFontHilite, nSizeHilite, ;
                           nNormColor, nHiliteColor, nFillColor, nUlineFlag)

              lExitLoop := .T.

         CASE ( AT( UPPER(CHR(nInkyCode)), cStrHotKeys) > 0 )
              // One of the aMenuItem Element Hotkey is pressed

              // Scan Array element with particular HotKey is selected
              nChoice := 0
              ASCAN( aMenuItems, { |str| nChoice++ , ;
                                   UPPER(SUBSTR(str, aHotKeys[nChoice], 1)) == UPPER(CHR(nInkyCode)) } )
         
              // Clear Previous Highlight
              MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                           iBlockLen, nItemSelected, nFontHite, nFont, nSize, ;
                           nFontHilite, nSizeHilite, ;
                           nNormColor, nHiliteColor, nFillColor, nUlineFlag)

              lExitLoop := .T.
         
          CASE (nInkyCode == K_UP .OR. nInkyCode == K_DOWN .OR.;
                nInkyCode == K_HOME .OR. nInkyCode == K_END .OR. ;
                nInkyCode == K_CTRL_HOME .OR. nInkyCode == K_CTRL_END .OR. ;
                nInkyCode == K_PGUP .OR. nInkyCode == K_PGDN .OR. ;
                nInkyCode == K_CTRL_PGUP .OR. nInkyCode == K_CTRL_PGDN)

               // Clear Previous Highlight
               MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                            iBlockLen, nItemSelected, nFontHite, nFont, nSize, ;
                            nFontHilite, nSizeHilite, ;
                            nNormColor, nHiliteColor, nFillColor, nUlineFlag)
               
               DO CASE
                  CASE (nInkyCode == K_HOME .OR. nInkyCode == K_CTRL_HOME .OR. ;
                        nInkyCode == K_PGUP .OR. nInkyCode == K_CTRL_PGUP )
                       nItemSelected := 1

                  CASE (nInkyCode == K_END  .OR. nInkyCode == K_CTRL_END  .OR. ;
                        nInkyCode == K_PGDN .OR. nInkyCode == K_CTRL_PGDN )
                       nItemSelected := nMenuCnt

                  CASE (nInkyCode == K_UP)
                       // Scroll Up
                       nItemSelected := IIF(nItemSelected > 1, nItemSelected - 1, nMenuCnt)

                  CASE (nInkyCode == K_DOWN)
                       // Scroll Down
                       nItemSelected := IIF(nItemSelected < nMenuCnt, nItemSelected + 1, 1)

                  OTHERWISE
               ENDCASE

               // Display Highlight
               MenuItemPrnt(aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
                            iBlockLen, nItemSelected, nFontHite, nFont, nSize, ;
                            nFontHilite, nSizeHilite, ;
                            nHiliteColor, nHiliteColor, nBarColor, nUlineFlag)

         OTHERWISE
              * Do nothing
      ENDCASE

       
   ENDDO                          

   // Return aMenuItems array to original format
   UnFormatMenu(aMenuItems, aHotKeys)
   
   IF !EMPTY(cScrFile)
       gScrnRest( nLeft, nTop, cScrFile, COPY_PUT, 1, MPIXEL )
   ENDIF       

RETURN (nChoice)


/*--------------------------------------------------------------------------*/


STATIC FUNCTION MenuItemPrnt (aMenuItems, aHotKeys, nMenuRow, nMenuCol, ; 
               iBlockLen, nItemSelected, nFontHite, ;
               nFont, nSize, nFontHilite, nSizeHilite, ;
               nTextColor, nHiliteColor, nBlockColor, nUlineFlag)

  /* USAGE : Display and/or Clear Highlighted Menu Item 
             depending on the passed <nTextColor> and <nBlockColor>
             parameters.
     PARMS : Local Variables from GrfxMenu
  */

  LOCAL nCurrRow, cStrBuffer, nPosHotKey

  nPosHotKey :=  aHotKeys[nItemSelected]

  // Display/Clear Highlight Bar
  nCurrRow := nFontHite * (nItemSelected - 1)  + nMenuRow
  gDrawText(nCurrRow, nMenuCol, REPLICATE(CHR(219), iBlockLen), ;
            nFont, nSize, nBlockColor, MPIXEL)


  // Display/Clear Left Half of Menu Item
  cStrBuffer := LEFT(aMenuItems[nItemSelected], nPosHotKey - 1)
  gDrawText(nCurrRow, nMenuCol, cStrBuffer, nFont, nSize,; 
            nTextColor, MPIXEL, LEFT_TEXT, WRAPTEXT_OFF, ULINE_OFF)

  // Display Menu Item Hot Key
  IF ( nPosHotKey > 0 )
     cStrBuffer := SUBSTR(aMenuItems[nItemSelected], nPosHotKey, 1)
     gDrawText(0, 0, cStrBuffer, nFontHilite, nSizeHilite,; 
               nHiliteColor, MBOTHREL, LEFT_TEXT, WRAPTEXT_OFF, nUlineFlag)
  ENDIF

  // Display/Clear Right Half of Menu Item
  cStrBuffer := RIGHT(aMenuItems[nItemSelected], LEN(aMenuItems[nItemSelected]) - nPosHotKey)
  gDrawText(0, 0, cStrBuffer, nFont, nSize,; 
            nTextColor, MBOTHREL, LEFT_TEXT, WRAPTEXT_OFF, ULINE_OFF)

RETURN (NIL)

