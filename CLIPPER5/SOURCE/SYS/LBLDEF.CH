/***
*
*  Lbldef.ch
*
*  Clipper LABEL FORM system definitions
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

// Label array definitions
#define LB_REMARK   1       // Character, remark from label file
#define LB_HEIGHT   2       // Numeric, label height
#define LB_WIDTH    3       // Numeric, label width
#define LB_LMARGIN  4       // Numeric, left margin
#define LB_LINES    5       // Numeric, lines between labels
#define LB_SPACES   6       // Numeric, spaces between labels
#define LB_ACROSS   7       // Numeric, number of labels across
#define LB_FIELDS   8       // Array of Field arrays

#define LB_COUNT    8       // Numeric, number of label fields

// Field array definitions ( one array per field )
#define LF_EXP      1       // Block, field expression
#define LF_TEXT     2       // Character, text of field expression
#define LF_BLANK    3       // Logical, compress blank fields, .T.=Yes .F.=No

#define LF_COUNT    3       // Numeric, number of elements in field array

