/*****
 *
 * TBROWSE.CH
 * Definitions for TBrowse
 *
 */

#define           HEADSEP             CHR(205) + CHR(209) + CHR(205)
#define           COLSEP              CHR(32)  + CHR(179) + CHR(32)
#define           FOOTSEP             CHR(205) + CHR(207) + CHR(205)

#xcommand         FORCE [STABLE] <x> =>           ;
                       DISPBEGIN()                ;;
                       WHILE !(<x>:stabilize())   ;;
                       END                        ;;
                       DISPEND()

#xcommand         ADD COLUMN <x> TO <c> [HEADING <*y*>]   =>  ;
                    <c>:addColumn( TBColumnNew( <"y"> , <{x}> ) )

#xtranslate       GetSetBlock(<xVar>)          => ;
                  {|xParm| IF(xParm == NIL, <xVar>, <xVar> := xParm)}

#xtranslate       BlockIt(<xCond>)             =>           <{xCond}>

// EOF - TBROWSE.CH //
