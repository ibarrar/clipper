/*****************************************************/
/* Filename:      C501_MOD.CH                        */
/* Module:        Clipper 5.01 Support header        */
/* Author:        Ronan J. Paredes                   */
/* Date-Started:  October 06, 1992                   */
/* Last-Update:   October 06, 1992                   */
/*                                                   */
/*****************************************************/

/* Color Constants
*/

#define DATA_COLORS if(iscolor(),"N/W,W+/B,,,W/B","N/W,W+/N,,,W/N")
#define MENU_COLORS if(iscolor(),"N/BG,W+/BG,W+/R","N/W,N+/W,W/N")
#define STAT_COLORS if(iscolor(),"N/BG","N/W")

#define SELECT_BAR  chr(24)+chr(25)+chr(26)+chr(27)+"- Select   "+;
                    chr(17)+chr(217)+"-Choose"

/* eof <c501_mod.prg>
*/