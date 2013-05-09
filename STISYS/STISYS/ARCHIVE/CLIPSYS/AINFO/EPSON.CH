/*
     EPSON.CH     : Header file for EPSON compatible print codes.
     Author       : Ron Paredes
     Date Written : March 31, 1993
*/

#define   _PRN_RESET           chr(27) + chr(64)
#define   _PRN_FFEED           chr(12)
#define   _PRN_LQON            chr(27) + chr(120) + chr(1)
#define   _PRN_LQOFF           chr(27) + chr(120) + chr(0)
#define   _PRN_ROMAN           chr(27) + chr(107) + chr(0)
#define   _PRN_SANS            chr(27) + chr(107) + chr(1)
#define   _PRN_10CPI           chr(27) + chr(80)
#define   _PRN_12CPI           chr(27) + chr(77)
#define   _PRN_CONDON          chr(15)
#define   _PRN_CONDOFF         chr(18)
#define   _PRN_WDBLE           chr(27) + chr(87) + chr(1)
#define   _PRN_WNORM           chr(27) + chr(87) + chr(0)
#define   _PRN_HDBLE           chr(27) + chr(119) + chr(1)
#define   _PRN_HNORM           chr(27) + chr(119) + chr(0)
#define   _PRN_EMPHON          chr(27) + chr(69)
#define   _PRN_EMPHOFF         chr(27) + chr(70)
#define   _PRN_DBSTON          chr(27) + chr(71)
#define   _PRN_DBSTOFF         chr(27) + chr(72)
#define   _PRN_SUPSON          chr(27) + chr(83) + chr(0)
#define   _PRN_SUPSOFF         chr(27) + chr(84)
#define   _PRN_SUBSON          chr(27) + chr(83) + chr(1)
#define   _PRN_SUBSOFF         chr(27) + chr(84)
#define   _PRN_ITALON          chr(27) + chr(52)
#define   _PRN_ITALOFF         chr(27) + chr(53)
#define   _PRN_UNDON           chr(27) + chr(45) + chr(1)
#define   _PRN_UNDOFF          chr(27) + chr(45) + chr(0)

/*
  end-of-file
*/

