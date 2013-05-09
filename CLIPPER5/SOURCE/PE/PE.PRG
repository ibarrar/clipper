/***
*
*	Pe.prg
*
*  Simple program editor in Clipper.
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile:    CLIPPER pe /n/w/m
*  Link:       RTLINK FILE pe
*  Execute:    pe <file>
*
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"


/* key defs for pe */
#define EK_WRITE K_ALT_W
#define EK_QUIT  K_ESC
#define EK_WQUIT K_CTRL_W


/* structure used to contain information about edit in progress */
#define ES_TOP      1
#define ES_LEFT     2
#define ES_BOTTOM   3
#define ES_RIGHT    4

#define ES_FILE     5
#define ES_TEXT     6

#define ES_WIDTH    7
#define ES_TABSIZE  8
#define ES_SCROLL   9
#define ES_WRAP     10
#define ES_INS      11

#define ES_ROW      12
#define ES_COL      13
#define ES_RELROW   14
#define ES_RELCOL   15

#define ES_CHANGED  16
#define ES_LASTKEY  17

#define ES_PATTERN  18

#define ES_LENGTH   18


#define NextTab(y, z)   ( ( (y) + z ) - ( (y) % z ) )


/* static vars scope to entire module */
static aEdit
static nMaxRow
static nMaxCol
static nStatCol


****
*   pe()
*

func pe(cFile)
local nKey, lDone, cScreen

    Set(_SET_BELL, .f.)
    Set(_SET_SCOREBOARD, .f.)
    SetKey(K_F1, NIL)

    if ( IsColor() )
        SetColor("w+/b, b/w, b")
    else
        SetColor("w/n, n/w")
    end

    if ( Empty(cFile) )
        cFile := "untitled"
    elseif ( Rat(".", cFile) <= Rat("\", cFile) )
        cFile := cFile + ".prg"
    end

    nMaxRow := Maxrow()
    nMaxCol := Maxcol()
    nStatCol := nMaxCol - 19

    /* create the edit structure */
    aEdit               := Array(ES_LENGTH)
    aEdit[ES_FILE]      := Lower(cFile)
    aEdit[ES_TEXT]      := MemoRead(cFile)

    aEdit[ES_TOP]       := 0
    aEdit[ES_LEFT]      := 0
    aEdit[ES_BOTTOM]    := nMaxRow - 2
    aEdit[ES_RIGHT]     := nMaxCol

    aEdit[ES_WIDTH]     := 132
    aEdit[ES_TABSIZE]   := 4
    aEdit[ES_SCROLL]    := .f.
    aEdit[ES_WRAP]      := .t.
    aEdit[ES_INS]       := Set(_SET_INSERT)

    aEdit[ES_ROW]       := 1
    aEdit[ES_COL]       := 0
    aEdit[ES_RELROW]    := 0
    aEdit[ES_RELCOL]    := 0

    aEdit[ES_CHANGED]   := .f.
    aEdit[ES_LASTKEY]   := 0

    aEdit[ES_PATTERN]   := ""

    cScreen := SaveScreen(0, 0, nMaxRow, nMaxCol)
    cls

    @ nMaxRow - 1, 0 TO nMaxRow - 1, nMaxCol
    Msg( "File: " + aEdit[ES_FILE] )
    lDone := .f.


    while (!lDone)
        DoEditing()

        nKey := aEdit[ES_LASTKEY]

        do case
        case (nKey == K_ALT_S)
            Search()

        case (nKey == K_ALT_A)
            SearchAgain()

        case (nKey == EK_WRITE)
            EditWrite()

        case (nKey == EK_QUIT)
            lDone := PExit()

        case (nKey == EK_WQUIT)
            EditWrite()
            lDone := PExit()

        otherwise
        end

    end

    if ( IsColor() )
        SetColor(",,n")
    end

    RestScreen(0, 0, nMaxRow, nMaxCol, cScreen)
    @ nMaxRow, nMaxCol SAY ""

return (NIL)


****
*   DoEditing()
*

func DoEditing()

    aEdit[ES_WRAP] := .t.
    aEdit[ES_TEXT] := MemoEdit( aEdit[ES_TEXT],     ;
                                aEdit[ES_TOP],      ;
                                aEdit[ES_LEFT],     ;
                                aEdit[ES_BOTTOM],   ;
                                aEdit[ES_RIGHT],    ;
                                .t., "ufunc",       ;
                                aEdit[ES_WIDTH],    ;
                                aEdit[ES_TABSIZE],  ;
                                aEdit[ES_ROW],      ;
                                aEdit[ES_COL],      ;
                                aEdit[ES_RELROW],   ;
                                aEdit[ES_RELCOL]    ;
                              )

return (NIL)


****
*   Prompt()
*

func Prompt(cSay, cGet)
local getList := {}, bInsSave, bAltISave

    bInsSave := SetKey(K_INS, {|| SetCursor(if( Set(_SET_INSERT,            ;
                                                !Set(_SET_INSERT) ),        ;
                                                SC_NORMAL, SC_INSERT) ) }   ;
                      )

    bAltISave := SetKey(K_ALT_I, SetKey(K_INS))

    Msg(Space(nStatCol))
    @ nMaxRow,0 SAY cSay    ;
                GET cGet    ;
                Picture "@KS" + Ltrim(Str(nStatCol - (Len(cSay) + 2)))
    READ

    SetKey(K_INS, bInsSave)
    SetKey(K_ALT_I, bAltISave)
    aEdit[ES_INS] := Set(_SET_INSERT)

return (cGet)


****
*   NewName()
*

func NewName()
local name

    name := Prompt("Enter new output file name:", PadR(aEdit[ES_FILE], 64))
    name := Lower(Ltrim(Rtrim(name)))
    if ( !Empty(name) .and. name != aEdit[ES_FILE] )
        aEdit[ES_FILE] := name
        aEdit[ES_CHANGED] := .t.
    end

    Msg("File: " + aEdit[ES_FILE])

return (NIL)


****
*   xSearch()
*

func xSearch(x)
local nRow, pos, offset, newcol, a

    if ( !Empty(aEdit[ES_PATTERN]) )
        nRow := aEdit[ES_ROW]
        pos := x + MLCToPos(aEdit[ES_TEXT],     ;
                            aEdit[ES_WIDTH],    ;
                            aEdit[ES_ROW],      ;
                            aEdit[ES_COL],      ;
                            aEdit[ES_TABSIZE],  ;
                            aEdit[ES_WRAP]      ;
                           )

        offset := pos + At(aEdit[ES_PATTERN],Substr(aEdit[ES_TEXT], pos)) - 1
        if ( offset >= pos )
            a := MPosToLC(aEdit[ES_TEXT],   ;
                          aEdit[ES_WIDTH],  ;
                          offset,           ;
                          aEdit[ES_TABSIZE],;
                          aEdit[ES_WRAP]    ;
                         )

            aEdit[ES_ROW] := a[1]
            newcol := a[2]
            aEdit[ES_RELCOL] := aEdit[ES_RELCOL] + newcol - aEdit[ES_COL]
            aEdit[ES_COL] := newcol

            if ( aEdit[ES_ROW] - nRow <=                                ;
                 aEdit[ES_BOTTOM] - aEdit[ES_TOP] - aEdit[ES_RELROW]    ;
               )

                aEdit[ES_RELROW] := aEdit[ES_RELROW] + aEdit[ES_ROW] - nRow

            end

            Msg("Search completed.")

        else
            Msg("Pattern not found.")
        end
    else
        Msg("")
    end

return (NIL)


****
*   Search()
*

func Search()
local pattern

    pattern := Prompt("Search for:", PadR(aEdit[ES_PATTERN], 64))
    pattern := Ltrim(Rtrim(pattern))
    if ( !Empty(pattern) )
        aEdit[ES_PATTERN] := pattern
        xSearch(0)
    else
        Msg("")
    end

return (NIL)


****
*   SearchAgain()
*

func SearchAgain()
return (xSearch(1))


****
*   ufunc()
*

func ufunc(nMode, nLine, nCol)
local nKey

    aEdit[ES_LASTKEY]   := nKey := LastKey()
    aEdit[ES_ROW]       := nLine
    aEdit[ES_COL]       := nCol
    aEdit[ES_RELROW]    := Row() - aEdit[ES_TOP]
    aEdit[ES_RELCOL]    := Col() - aEdit[ES_LEFT]


    if (nMode == ME_INIT)
        if (aEdit[ES_WRAP])
            /* turn off word wrap */
            aEdit[ES_WRAP] := .f.
            return (ME_TOGGLEWRAP)  /* NOTE */
        end

        SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )

    elseif (nMode == ME_IDLE)
        StatMsg()

    else
        /* keystroke exception */
        if (nMode == ME_UNKEYX)
            aEdit[ES_CHANGED] := .t.
        end

        do case
        case (nKey == K_F1)
            DisplayHelp()

        case (nKey == K_ALT_H)
            DisplayHelp()

        case (nKey == K_ALT_F)
            Msg( "File: " + aEdit[ES_FILE] )

        case (nKey == K_ALT_O)
            NewName()

        case (nKey == K_INS)
            aEdit[ES_INS] := !Set(_SET_INSERT)
            SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )
            return (nKey)

        case (nKey == K_ALT_I)
            aEdit[ES_INS] := !Set(_SET_INSERT)
            SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )
            return (K_INS)

        case (nKey == K_ALT_S)
            /* search */
            return (K_CTRL_W)

        case (nKey == K_ALT_A)
            /* search again */
            return (K_CTRL_W)

        case (nKey == K_ALT_X)
            aEdit[ES_LASTKEY] := EK_QUIT
            return (K_CTRL_W)

        case (nKey == EK_QUIT)
            return (K_CTRL_W)

        case (nKey == EK_WRITE)
            return (K_CTRL_W)

        otherwise
        end
    end

return (0)



****
*   EditWrite()
*

func EditWrite()
local lRet

    lRet := .t.
    if ( aEdit[ES_CHANGED] )
        Msg( "Writing " + aEdit[ES_FILE] )

        if ( MemoWrit(aEdit[ES_FILE], aEdit[ES_TEXT]) )
            Msg("Write OK")
            aEdit[ES_CHANGED] := .f.

        else
            Msg("Write error")
            lRet := .f.

        end
    else
        Msg("File has not been modified -- not written.")

    end

return (lRet)


****
*   Msg()
*

func Msg(text)
static oldLength := 0

    if (oldLength != 0)
        @ nMaxRow, 0 SAY Replicate(" ", oldLength)
    end

    @ nMaxRow, 0 SAY text
    oldLength := Len(text)

return (NIL)


****
*   StatMsg()
*

func StatMsg()
local cLine, cCol, nCtype, nRow, nCol

    cLine := PadR( LTrim(Str(aEdit[ES_ROW])), 6 )
    cCol := LTrim( Str(aEdit[ES_COL]) )

    nCtype := SetCursor(0)
    nRow := Row()
    nCol := Col()
    @ nMaxRow, nStatCol SAY "Line: " + cLine + "Col: " + cCol + "  "
    DevPos(nRow, nCol)
    SetCursor(nCtype)

return (NIL)


****
*   PExit()
*

func PExit()
local c, lRet, nCtype

    lRet = .t.
    if ( aEdit[ES_CHANGED] )
        nCtype := SetCursor(SC_NORMAL)

        Msg("Abandon " + aEdit[ES_FILE] + " [ynw]?" )
        while ( !((c := Upper(Chr(InKey(0)))) $ ("YNW" + Chr(K_ESC))) )
        end

        if ( c == "W" )
            lRet := EditWrite()

        else

            if ( c != "Y" )
                lRet := .f.
            end

            Msg("")
        end

        SetCursor(nCtype)

    end

return (lRet)


****
* DisplayHelp()
*

func DisplayHelp()
local cScreen := SaveScreen(0, 0, MaxRow(), MaxCol()), nCtype

    cls
    @ 0, 1 say "PE Help"
    @ 1, 0 to nMaxRow - 1, nMaxCol
    @ 2, 2 say "Uparrow/Ctrl-E          Line up           ³ Alt-H, F1    Display Help screen "
    @ 3, 2 say "Dnarrow/Ctrl-X          Line down         ³ Ctrl-W       Save and exit       "
    @ 4, 2 say "Leftarrow/Ctrl-S        Char left         ³ Alt-W        Save and continue   "
    @ 5, 2 say "Rightarrow/Ctrl-D       Char right        ³ Alt-O        New Output filename "
    @ 6, 2 say "Ctrl-Leftarrow/Ctrl-A   Word left         ³ Alt-X, Esc   Exit                "
    @ 7, 2 say "Ctrl-Rightarrow/Ctrl-F  Word right        ³ Alt-F        Display Filename    "
    @ 8, 2 say "Home                    Beginning of line ³ Alt-S        Search              "
    @ 9, 2 say "End                     End of line       ³ Alt-A        Search Again        "
    @ 10,2 say "Ctrl-Home               Top of window     ³ Alt-I, Ins   Toggle Insert mode  "
    @ 11,2 say "Ctrl-End                End of window     ³ "
    @ 12,2 say "PgUp                    Previous window   ³ "
    @ 13,2 say "PgDn                    Next window       ³ "
    @ 14,2 say "Ctrl-PgUp               Top of file       ³ "
    @ 15,2 say "Ctrl-PgDn               End of file       ³ "
    @ 16,2 say "Return                  Begin next line   ³ "
    @ 17,2 say "Delete                  Delete char       ³ "
    @ 18,2 say "Backspace               Delete char left  ³ "
    @ 19,2 say "Tab                     Insert tab/spaces ³ "
    @ 20,2 say "Ctrl-Y                  Delete line       ³ "
    @ 21,2 say "Ctrl-T                  Delete word right ³ "
    @ 22,2 say "                                          ³ "

    @ nMaxRow, 1 say "Press any key to return to the edit screen..."

    nCtype := SetCursor(SC_NORMAL)
    Inkey(0)
    SetCursor(nCtype)

    RestScreen(0, 0, nMaxRow, nMaxCol, cScreen)
  
return (NIL)
