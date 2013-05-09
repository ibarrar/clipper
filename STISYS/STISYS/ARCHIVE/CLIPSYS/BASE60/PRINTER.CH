// Filename:      PRINTER.CH
// Module:        Printer Control Functions Library Header File
// Date-Written:  February 21, 1992
// Last-Update:   February 21, 1992

#define _SET_FORMFEED     0        // Form Feed.
#define _SET_QUALITY      1        // Select NLQ or Draft.
#define _SET_TYPESTYLE    2        // Select Typestyle (Roman/Sans Serif)
#define _SET_PITCH        3        // Select character pitch (10/12 cpi)
#define _SET_SIZE         4        // Select char size (Normal/Condensed)
#define _SET_WIDTH        5        // Select char width (Normal/Double)
#define _SET_HEIGHT       6        // Select char height (Normal/Double)
#define _SET_EMPHASIZED   7        // Turn Double-Height Mode (ON/OFF)
#define _SET_DBSTRIKE     8        // Turn Double-Strike Mode (ON/OFF)
#define _SET_SUPERSCRIPT  9        // Select Supercript Mode (ON/OFF)
#define _SET_SUBSCRIPT   10        // Select Subscript Mode (ON/OFF)
#define _SET_ITALIC      11        // Select Italic Mode (ON/OFF)
#define _SET_UNDERLINE   12        // Turn Underlining Mode (ON/OFF)

#define P_DRAFT          0        // Draft Mode.
#define P_NLQ            1        // Near Letter Quality Mode
#define P_ROMAN          3        // Roman Font.
#define P_SANS           4        // Sans Serif Font.
#define P_10_PITCH       5        // 10 characters per inch.
#define P_12_PITCH       6        // 12 characters per inch.
#define P_NORMAL         7        // Normal Mode.
#define P_CONDENSED      8        // Condensed Mode.
#define P_DOUBLE         9        // Double Mode.

// end-of-file

