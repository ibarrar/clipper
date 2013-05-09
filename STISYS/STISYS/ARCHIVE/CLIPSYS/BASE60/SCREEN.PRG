// Filename:      SCREEN.PRG
// Module:        Text Screen Functions Library
// Date-Written:  November 27, 1991
// Last-Update:   December 06, 1991

*#define FILL_CHAR chr(176)             // Screen background design.
*#define BKGND_SCREEN "   "+FILL_CHAR+"   "+FILL_CHAR+FILL_CHAR

/***************************************************************************/
/* CHAR function BkgndScreen(NIL)                                          */
/* --> paints the background screen blue with white foreground and creates */
/*   a heading and message bar.                                            */
/*                                                                         */
/* NIL  function RestoreScreen(cSavedScreen)                               */
/* -->  restores the original screen attribute.                            */
/* CHAR cSavedScreen - the screen buffer of a previously saved screen.     */
/*                                                                         */
/*                                                                         */
/* NIL  function Header(cHeading1,cHeading2)                               */
/* -->  displays a 2 headings at the top row of the screen.                */
/* CHAR  cHeading1, cHeading2 - strings to display.                        */
/*                                                                         */
/* NIL  function Message(cMessage)                                         */
/* -->  displays a message at the bottom row of the screen (message bar).  */
/* CHAR  cMessage - string to display (maximum length is 79).              */
/***************************************************************************/

function BkgndScreen()
local cSaveScreen
   // Save original screen to buffer.
   cSaveScreen:=SaveScreen(00,00,24,79)
   // Display screen with white dots on blue background.
   SetColor("W+/N")                  // Change color to White on Blue.
   @ 00,00 clear to 24,79            // Clear entire screen.
*   SetColor("N/W+")                  // Change color to Black on White.
*   @ 00,00 say " "+chr(240)+" "
*   @ 01,00 clear to 01,79            // Clear the top row.
*   SetColor("W+/B")                  // Change back to White on Blue.
return cSaveScreen                   // Value returned: CHAR cSaveScreen

function RestoreScreen(cSavedScreen)
   RestScreen(00,00,24,79,cSavedScreen)  // Restore previously saved screen.
return nil                               // Value returned: NIL

function Heading(cTitle)
local cSaveColor
   cSaveColor:=SetColor("W+/N")        // Change color to White on Blue.
   // Display title on center-top row.
   @ 00,40-(Len(cTitle) / 2) say cTitle
   SetColor(cSaveColor)                // Return original color.
return nil                             // Value returned: NIL

function Message(cMessage)
local cSaveColor
   if Len(cMessage)>79                 // Is string > 79 characters?
      cMessage:=SubStr(cMessage,1,79)  // Yes -- truncate to 79 chars only.
   endif
   cSaveColor:=SetColor(if(iscolor(),"N/BG","N/W")) // Change color to White on Cyan.
   @ 24,00 clear to 24,79              // Clear bottom row.
   @ 24,01 say cMessage                // Display message on bottom row.
   SetColor(cSaveColor)                // Return original color.
return nil                             // Value returned: NIL

/***
*  STI_Logo()  --> NIL
*  Clear Screen Display the STI's logo
*/

FUNCTION STI_Logo()
local col
 col:=setcolor(if(Iscolor(),"R/N","W/N"))
 @ 02, 00 say ""
 @ row()+1, 00 say "   к                                                                          "
 @ row()+1, 00 say "   Г                                                                          "
 @ row()+1, 00 say "   Г                               мммм  мм  мм ммммм  ммммм ммммм           "
 @ row()+1, 00 say "   Г      ммм                     лл  пп лл  лл лл  лл лл    лл  лл          "
 @ row()+1, 00 say "   Г     лллллм                    пллм  лл  лл ллммлп ллмм  ллммлп          "
 @ row()+1, 00 say "   Г      плллллм                 мм  лл лл  лл лл     лл    лл  лл          "
 @ row()+1, 00 say "   Г        плллллм                пппп   пппп  пп     ппппп пп  пп          "
 @ row()+1, 00 say "   Г          плллллм             мммммм ммммм   мммм  мм  мм ммммм мм       "
 @ row()+1, 00 say "   Г            плллллм             лл   лл  лл лл  лл лл  лл лл    лл       "
 @ row()+1, 00 say "   Г              плллллм           лл   ллммлп ллммлл лл  лл ллмм  лл       "
 @ row()+1, 00 say "   Г                пллллл          лл   лл  лл лл  лл  лммл  лл    лл       "
 @ row()+1, 00 say "   Г                  ппп           пп   пп  пп пп  пп   пп   ппппп ппппп    "
 @ row()+1, 00 say "   Г                               мммм м   мм  мммм                         "
 @ row()+1, 00 say "   Г                                лл  ллм лл лл  лл                        "
 @ row()+1, 00 say "   Г          мммм                  лл  лллллл лл                            "
 @ row()+1, 00 say "   Г        мллллллм                лл  лл плл лл  лл                        "
 @ row()+1, 00 say "   Г        пллллллп               пппп пп   п  пппп  п                      "
 @ row()+1, 00 say "   Г          пппп                                                           "
 @ row()+1, 00 say "   Г                                                                         "
 @ row()+1, 00 say "   РФФФФФФФФФФФФФФФФФФФФФФФФФФй                                              "
setcolor("W+/N")
 @ 03,04,21,31 Box "опнннмоо"
 @       4, 15 say "  мммм "
 @ row()+1, 15 say "мллллллм"
 @ row()+1, 15 say "пллллллп "
 @ row()+1, 15 say "  пппп "
 @ row()+3, 10 say "ммм"
 @ row()+1, 09 say "лллллм"
 @ row()+1, 10 say "плллллм"
 @ row()+1, 12 say "плллллм"
 @ row()+1, 14 say "плллллм"
 @ row()+1, 16 say "плллллм"
 @ row()+1, 18 say "плллллм"
 @ row()+1, 20 say "пллллл"
 @ row()+1, 22 say "ппп"
 @ 2,0 to 23,79 double
 setcolor(col)
return nil


// end-of-file