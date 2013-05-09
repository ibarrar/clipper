/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  GRFXDRVR.CH                                         บ
บ  Description     :  Graphic Driver Mode Definition File for             บ
บ                     Graphics Interface Library                          บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  June 1994                                           บ
บ  Last Revision   :                                                      บ
บ  Dialect         :  Clipper plus Extend Libraries from Turbo C++        บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

/* Define graphics drivers */

#define DETECT          0
#define CGA             1
#define MCGA            2
#define EGA             3
#define EGA64           4
#define EGAMONO         5
#define IBM8514         6
#define HERCMONO        7
#define ATT400          8
#define VGA             9
#define PC3270         10


/* Define graphics modes */


#define CGAC0           0
#define CGAC1           1
#define CGAC2           2
#define CGAC3           3
#define CGAHI           4
#define MCGAC0          0
#define MCGAC1          1
#define MCGAC2          2
#define MCGAC3          3
#define MCGAMED         4
#define MCGAHI          5
#define EGALO           0
#define EGAHI           1
#define EGA64LO         0
#define EGA64HI         1
#define EGAMONOHI       3
#define HERCMONOHI      0
#define ATT400C0        0
#define ATT400C1        1
#define ATT400C2        2
#define ATT400C3        3
#define ATT400MED       4
#define ATT400HI        5
#define VGALO           0
#define VGAMED          1
#define VGAHI           2
#define PC3270HI        0
#define IBM8514HI       1
#define IBM8514LO       0


/*  Graphics Driver and Mode Table

 Graphicsณ
  driver ณgraphics_modesณValueณColumn x Rowณ Palette ณPages
อออออออออุออออออออออออออุอออออุออออออออออออุอออออออออุออออออออออ
 CGA     ณ CGAC0        ณ  0  ณ  320 x 200 ณ    C0   ณ  1
         ณ CGAC1        ณ  1  ณ  320 x 200 ณ    C1   ณ  1
         ณ CGAC2        ณ  2  ณ  320 x 200 ณ    C2   ณ  1
         ณ CGAC3        ณ  3  ณ  320 x 200 ณ    C3   ณ  1
         ณ CGAHI        ณ  4  ณ  640 x 200 ณ  2 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 MCGA    ณ MCGAC0       ณ  0  ณ  320 x 200 ณ    C0   ณ  1
         ณ MCGAC1       ณ  1  ณ  320 x 200 ณ    C1   ณ  1
         ณ MCGAC2       ณ  2  ณ  320 x 200 ณ    C2   ณ  1
         ณ MCGAC3       ณ  3  ณ  320 x 200 ณ    C3   ณ  1
         ณ MCGAMED      ณ  4  ณ  640 x 200 ณ  2 colorณ  1
         ณ MCGAHI       ณ  5  ณ  640 x 480 ณ  2 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 EGA     ณ EGALO        ณ  0  ณ  640 x 200 ณ 16 colorณ  4
         ณ EGAHI        ณ  1  ณ  640 x 350 ณ 16 colorณ  2
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 EGA64   ณ EGA64LO      ณ  0  ณ  640 x 200 ณ 16 colorณ  1
         ณ EGA64HI      ณ  1  ณ  640 x 350 ณ  4 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 EGA-MONOณ EGAMONOHI    ณ  3  ณ  640 x 350 ณ  2 colorณ  1*
         ณ EGAMONOHI    ณ  3  ณ  640 x 350 ณ  2 colorณ  2**
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 HERC    ณ HERCMONOHI   ณ  0  ณ  720 x 348 ณ  2 colorณ  2
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 ATT400  ณ ATT400C0     ณ  0  ณ  320 x 200 ณ    C0   ณ  1
         ณ ATT400C1     ณ  1  ณ  320 x 200 ณ    C1   ณ  1
         ณ ATT400C2     ณ  2  ณ  320 x 200 ณ    C2   ณ  1
         ณ ATT400C3     ณ  3  ณ  320 x 200 ณ    C3   ณ  1
         ณ ATT400MED    ณ  4  ณ  640 x 200 ณ  2 colorณ  1
         ณ ATT400HI     ณ  5  ณ  640 x 400 ณ  2 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 VGA     ณ VGALO        ณ  0  ณ  640 x 200 ณ 16 colorณ  2
         ณ VGAMED       ณ  1  ณ  640 x 350 ณ 16 colorณ  2
         ณ VGAHI        ณ  2  ณ  640 x 480 ณ 16 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 PC3270  ณ PC3270HI     ณ  0  ณ  720 x 350 ณ  2 colorณ  1
ฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤ
 IBM8514 ณ IBM8514HI    ณ  1  ณ 1024 x 760 ณ256 colorณ
         ณ IBM8514LO    ณ  0  ณ  640 x 480 ณ256 colorณ

*/

