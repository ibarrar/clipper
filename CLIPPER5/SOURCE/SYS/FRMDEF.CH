/***
*
*  Frmdef.ch
*
*  Clipper REPORT FORM system definitions
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

// Report array definitions
#define RP_HEADER   1       // Array of header strings
#define RP_WIDTH    2       // Numeric, report page width
#define RP_LMARGIN  3       // Numeric, report page offset
#define RP_RMARGIN  4       // NIL, Not used
#define RP_LINES    5       // Numeric, number of lines per page
#define RP_SPACING  6       // Numeric, single=1, double=2
#define RP_BEJECT   7       // Logical, eject before 1st page, .T.=Yes .F.=No
#define RP_AEJECT   8       // Logical, eject after last page, .T.=Yes .F.=No
#define RP_PLAIN    9       // Logical, plain report, .T.=Yes .F.=No
#define RP_SUMMARY  10      // Logical, no detail lines, .T.=Yes .F.=No
#define RP_COLUMNS  11      // Array of Column arrays
#define RP_GROUPS   12      // Array of Group arrays
#define RP_HEADING  13      // Character, heading for the report

#define RP_COUNT    13      // Number of elements in the Report array


// Column array definitions ( one array per column definition )
#define RC_EXP      1       // Block, contains compiled column expression
#define RC_TEXT     2       // Character, contains text column expression
#define RC_TYPE     3       // Character, type of expression
#define RC_HEADER   4       // Array of column heading strings
#define RC_WIDTH    5       // Numeric, column width including decimals and
                            // decimal point
#define RC_DECIMALS 6       // Numeric, number of decimal places
#define RC_TOTAL    7       // Logical, total this column, .T.=Yes .F.=No
#define RC_PICT     8       // Character, picture string

#define RC_COUNT    8       // Number of elements in the Column array


// Group array definitions ( one array per group definition )
#define RG_EXP      1       // Block, contains compiled group expression
#define RG_TEXT     2       // Character, contains text group expression
#define RG_TYPE     3       // Character, type of expression
#define RG_HEADER   4       // Character, column heading string
#define RG_AEJECT   5       // Logical, eject after group, .T.=Yes .F.=No

#define RG_COUNT    5       // Number of elements in the Group array

