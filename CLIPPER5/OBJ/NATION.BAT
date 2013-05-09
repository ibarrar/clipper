@ECHO OFF
IF MDX==%1 GOTO FINISH
IF NTX==%1 GOTO FINISH

:DRIVER
cls
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³                                                 ³
ECHO ³   Install NATION module for use with which      ³
ECHO ³   database driver?                              ³
ECHO ³                                                 ³
ECHO ³   A. DBFMDX                                     ³
ECHO ³   B. DBFNTX / DBFNDX                            ³
ECHO ³                                                 ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Type a letter, or press Esc to exit.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL   3 GOTO DRIVER
IF ERRORLEVEL   2 GOTO NTX
IF ERRORLEVEL   1 GOTO MDX

:MDX
CLS
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³               Nations Modules for DBFMDX                  ³
ECHO ³ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ³
ECHO ³                                                           ³
ECHO ³   A. British  MDXUK.OBJ        E. Italian  MDXITA.OBJ     ³
ECHO ³   B. Dutch    MDXDUT.OBJ       F. Spanish  MDXSPA.OBJ     ³
ECHO ³   C. French   MDXFRE.OBJ       G. Swedish  MDXSWE.OBJ     ³
ECHO ³   D. German   MDXGER.OBJ                                  ³
ECHO ³                                                           ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Type a letter, or press Esc to cancel.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL  8 GOTO MDX
IF ERRORLEVEL  7 NATION MDX SWE
IF ERRORLEVEL  6 NATION MDX SPA
IF ERRORLEVEL  5 NATION MDX ITA
IF ERRORLEVEL  4 NATION MDX GER
IF ERRORLEVEL  3 NATION MDX FRE
IF ERRORLEVEL  2 NATION MDX DUT
IF ERRORLEVEL  1 NATION MDX UK


:NTX
CLS
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³                 Nations Modules for DBFNTX/NDX                  ³
ECHO ³ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ³
ECHO ³                                                                 ³
ECHO ³   A. Danish      NTXDAN.OBJ       H. Icelandic  NTXIC850.OBJ*   ³
ECHO ³   B. Dutch       NTXDUT.OBJ       I. Icelandic  NTXIC861.OBJ*   ³
ECHO ³   C. French      NTXFRE.OBJ       J. Italian    NTXNOR.OBJ      ³
ECHO ³   D. Finnish     NTXFIN.OBJ       K. Norwegian  NTXNOR.OBJ      ³
ECHO ³   E. German      NTXGER.OBJ       L. Portuguese NTXPOR.OBJ      ³
ECHO ³   F. Greek       NTXGR437.OBJ*    M. Spanish    NTXSPA.OBJ      ³
ECHO ³   G. Greek       NTXGR851.OBJ*    N. Swedish    NTXSWE.OBJ      ³
ECHO ³                                                                 ³
ECHO ³   * Number indicates intended code page                         ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Type a letter, or press Esc to cancel.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL  15 GOTO NTX
IF ERRORLEVEL  14 NATION NTX SWE
IF ERRORLEVEL  13 NATION NTX SPA
IF ERRORLEVEL  12 NATION NTX POR
IF ERRORLEVEL  11 NATION NTX NOR
IF ERRORLEVEL  10 NATION NTX ITA
IF ERRORLEVEL   9 NATION NTX IC861
IF ERRORLEVEL   8 NATION NTX IC850
IF ERRORLEVEL   7 NATION NTX GR851
IF ERRORLEVEL   6 NATION NTX GR437
IF ERRORLEVEL   5 NATION NTX GER
IF ERRORLEVEL   4 NATION NTX FIN
IF ERRORLEVEL   3 NATION NTX FRE
IF ERRORLEVEL   2 NATION NTX DUT
IF ERRORLEVEL   1 NATION NTX DAN

:FINISH
NAT_OBJ -O MSG%2.OBJ %1%2.OBJ > nul
ECHO Copying %1%2 to %1SORT.OBJ
COPY %1%2.OBJ  %1SORT.OBJ

IF %1%2 == MDXUK GOTO END
ECHO Copying MSG%2 to MSG.OBJ
COPY MSG%2.OBJ MSG.OBJ

:END



