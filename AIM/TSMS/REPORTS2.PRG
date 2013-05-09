#include "Janus.ch"

#define OUTTERM if(cMode = "X");set alternate to "TERMX.RPT"; else; set alternate to "TERMZ.RPT"; endif
#define OUTDEPT if(cMode = "X");set alternate to "DEPTX.RPT"; else; set alternate to "DEPTZ.RPT"; endif
#define OUTHOUR if(cMode = "X");set alternate to "HOURX.RPT"; else; set alternate to "HOURZ.RPT"; endif
#define OUTZSTS "Z-STATS.RPT"
#define OUTMNTH "MONTHLY.RPT"

#ifdef MARGIN
#undef MARGIN
#define MARGIN
#endif

memvar DbfFile

/*  This function will create the database file for browsing/printing
    of daily sale report. The output file is T.DBF     */
FUNCTION CREATE_DSALE_REPORT(cMode)
LOCAL nGrandTotal:= 0, nTotalPerTenant, cTCode

 // Use Master database file.
 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif

 // Open the terminal file with index on Tcode+IscNo
 if cMode == "X"
   if NetUse ("TERMX.DBF",DB_SHARED, NUM_SECONDS )
      Set Index to TERMX
   endif
 else
   if NetUse ("TERMZ.DBF",DB_SHARED, NUM_SECONDS )
      Set Index to TERMZ
   endif
 endif

 DbfFile:= Alias()

 set filter to ((DbfFile)->DATE == date())

 (DbfFile)->(DbGotop())

 set console off
 OUTTERM
 set alternate on
 ? MARGIN +padc("Daily Sales "+cMode+"-Report",110)
 ? MARGIN +padc(Mdy(date()),110)
 ? MARGIN +space(110)
 ? MARGIN +"TENANT CODE       OUTLET NAME      CLUSTER CODE  ISC#    DAILY SALES   TOTAL DAILY SALES     GRAND TOTAL"
 ? MARGIN +"-----------  --------------------  ------------  ----  --------------  -----------------  -----------------"
 // Repeat for all tenant's terminals.
 DO WHILE (DbfFile)->(!eof())

    cTcode := (DbfFile)->TCODE  // Get tenant code in the terminal file.

    MASTER->(DbGotop())
    MASTER->(DbSeek(cTcode)) // Position the file pointer in master.

    ? MARGIN + space(110)
    ? MARGIN +padc(cTCode,11) + space(2)
    ?? padc(MASTER->OTNAME,20) + space(2)
    ?? padc(alltrim((DbfFile)->CCODE),12) + space(2)
    ?? " "+alltrim((DbfFile)->ISCNO)+" " + space(2)
    ?? transform ( (DbfFile)->DSALE, "9,999,999.9999" )
    nTotalPerTenant := (DbfFile)->DSALE

    (DbfFile)->(dbSkip())
    DO WHILE ( cTcode == (DbfFile)->TCODE ) .AND. (DbfFile)->(!eof())

       ? MARGIN +SPACE(49) + padc(" "+alltrim((DbfFile)->ISCNO)+" ",4)+space(2)
       ?? transform ( (DbfFile)->DSALE, "9,999,999.9999" )
       nTotalPerTenant += (DbfFile)->DSALE

       (DbfFile)->(dbSkip())
    ENDDO

    ?? space(3) + tran( nTotalPerTenant, "999,999,999.9999" )
    nGrandTotal += nTotalPerTenant
 ENDDO

 ?? space(2) + tran ( nGrandTotal, "999,999,999.9999" )
 close alternate
 set alternate to
 set alternate off
 set console on

 MASTER->(DbCloseArea())
 (DbfFile)->(DbCloseArea())

RETURN nil


FUNCTION CREATE_DEP_REPORT(cMode)
 LOCAL cTcode, nTotalDept, cIscNo

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif

 if cMode == "X"
   if NetUse("DEPTX",DB_SHARED,NUM_SECONDS)
     Set index to DEPTX
   endif
 else
   if NetUse("DEPTZ",DB_SHARED,NUM_SECONDS)
     Set index to DEPTZ
   endif
 endif

 DbfFile := Alias()

 (DbfFile)->(DbGotop())

 set console off
 OUTDEPT
 set alternate on
 ? MARGIN +padc("Department Sales "+cMode+"-Report",118)
 ? MARGIN +padc(Mdy(date()),118)
 ? MARGIN +SPACE(118)
 ? MARGIN +"TENANT CODE       OUTLET NAME      CLUSTER CODE  ISC#  DEPT. NAME  DEPT. TOTAL     DEPT. SUM    TOTAL DEPT SALES"
 ? MARGIN +"-----------  --------------------  ------------  ----  ----------  -----------  --------------  ----------------"

 DO WHILE (DbfFile)->(!eof())

    cTcode := (DbfFile)->TCODE
    MASTER->(DbGotop())
    MASTER->(DbSeek(cTcode)) // Position the file pointer in master.

    ?  MARGIN +SPACE(118)
    ?  MARGIN +padc(cTcode,11) + space(2)
    ?? padc(MASTER->OTNAME,20) + space(2)
    ?? padc(alltrim((DbfFile)->CCODE),12) +space(2)
    ?? " "+alltrim((DbfFile)->ISCNO)+" " +space(2)
    ?? padc(alltrim((DbfFile)->DPNAME),10) +space(4)
    ?? padc(tran((DbfFile)->DPCTR, "999,999" ),11)
    ?? tran((DbfFile)->DPSUM, "9,999,999.9999" ) + space(2)
        cIscNo := (DbfFile)->ISCNO
    nTotalDept := (DbfFile)->DPSUM

    (DbfFile)->(dbSkip())
    DO WHILE ( cTcode == (DbfFile)->TCODE ) .AND. (DbfFile)->(!eof())

      DO WHILE ( cIscNo == (DbfFile)->ISCNO ) .AND. ( cTcode == (DbfFile)->TCODE ) .AND. (DbfFile)->(!eof())
        ?  MARGIN +space(55) + padc(alltrim((DbfFile)->DPNAME),10) + space(4)
        ?? padc(Tran((DbfFile)->DPCTR, "999,999" ),11)
        ?? tran((DbfFile)->DPSUM, "9,999,999.9999" ) + space(2)
        nTotalDept += (DbfFile)->DPSUM
        (DbfFile)->(DbSkip())
      ENDDO

        if ( cTcode == (DbfFile)->TCODE )
           ?  MARGIN + space(50)
           ?? alltrim((DbfFile)->ISCNO)+space(3)
           ?? padc(alltrim((DbfFile)->DPNAME),10) + space(4)
           ?? padc(Tran((DbfFile)->DPCTR, "999,999" ),11)
           ?? tran((DbfFile)->DPSUM, "9,999,999.9999" ) + space(2)
           cIscNo := (DbfFile)->ISCNO
           nTotalDept += (DbfFile)->DPSUM
           (DbfFile)->(DbSkip())
        endif

    ENDDO

    ?? transform( nTotalDept, "999,999,999.9999" )

 ENDDO

 close alternate
 set alternate to
 set alternate off
 set console on

 MASTER->(DbCloseArea())
 (DbfFile)->(DbCloseArea())

RETURN nil


FUNCTION CREATE_HOUR_REPORT(cMode)
 LOCAL cTcode, cIscNo

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif

 if cMode == "X"
   if NetUse("HOURX",DB_SHARED,NUM_SECONDS)
      Set index to HOURX
   endif
 else
   if NetUse("HOURZ",DB_SHARED,NUM_SECONDS)
      Set index to HOURZ
   endif
 endif

 DbfFile := Alias()

 (DbfFile)->(DbGotop())

 set console off
 OUTHOUR
 set alternate on
 ? MARGIN +padc("Hourly Sales "+cMode+"-Report",88)
 ? MARGIN +padc(mdy(date()),88)
 ? MARGIN +SPACE(88)
 ? MARGIN +"TENANT CODE       OUTLET NAME      CLUSTER CODE  ISC#   TIME   COUNT       AMOUNT"
 ? MARGIN +"-----------  --------------------  ------------  ----  -----  -------  --------------"

 DO WHILE (DbfFile)->(!EOF())

    cTcode := (DbfFile)->TCODE
    MASTER->(DbGotop())
    MASTER->(DbSeek(cTcode)) // Position the file pointer in master.
    ?  MARGIN +SPACE(88)
    ?  MARGIN +padc(cTcode,11) + space(2)
    ?? padc(MASTER->OTNAME,20) + space(2)
    ?? padc(alltrim((DbfFile)->CCODE),12) + space(2)
    ?? " "+alltrim((DbfFile)->ISCNO)+" " + space(2)
    ?? padc(alltrim((DbfFile)->HTIME),5) +space(2)
    ?? transform ((DbfFile)->HCOUNT, "999,999" ) + space(2)
    ?? transform ((DbfFile)->HSALE, "9,999,999.9999" ) + space(2)
    cIscNo := (DbfFile)->ISCNO

    (DbfFile)->(DbSkip())
    DO WHILE ( cTcode == (DbfFile)->TCODE ) .AND. (DbfFile)->(!eof())

      DO WHILE ( cIscNo == (DbfFile)->ISCNO ) .AND. ( cTcode == (DbfFile)->TCODE ) .AND. (DbfFile)->(!eof())
       ?  MARGIN +space(55)+ padc(alltrim( (DbfFile)->HTIME ) ,5 ) + space(2)
       ?? transform ( (DbfFile)->HCOUNT, "999,999" ) + space(2)
       ?? transform ( (DbfFile)->HSALE, "9,999,999.9999" )
       (DbfFile)->(dbSkip())
      ENDDO

      IF cTcode == (DbfFile)->TCODE

         ?  MARGIN +space(49) + " "+alltrim((DbfFile)->ISCNO)+" " + space(2)
         ?? padc(alltrim ( (DbfFile)->HTIME ),5) + space(2)
         ?? transform ( (DbfFile)->HCOUNT, "999,999" ) + space(2)
         ?? transform ( (DbfFile)->HSALE, "9,999,999.9999" )
         cIscNo := (DbfFile)->ISCNO
         (DbfFile)->(dbSkip())
      ENDIF

    ENDDO

 ENDDO

 close alternate
 set alternate to
 set alternate off
 set console on

 MASTER->(DbCloseArea())
 (DbfFile)->(DbCloseArea())

RETURN nil


FUNCTION CREATE_ZSTATUS_REPORT()
LOCAL cTCode

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
   Set index to MASTER
 endif

  if NetUse("TERMZ.dbf",DB_SHARED,NUM_SECONDS)
    Set index to TERMZ
  endif

 SET FILTER TO ( TERMZ->DATE == date() )
 TERMZ->(DbGotop())

 set console off
 set alternate to OUTZSTS
 set alternate on
 ? MARGIN +padc("Z-Counter Status Report",107)
 ? MARGIN +padc(mdy(date()),107)
 ? MARGIN +SPACE(107)
 ? MARGIN +"TENANT CODE       OUTLET NAME      CLUSTER CODE  ISC#  PREVIOUS Z COUNTER  CURRENT Z COUNTER  DESCREPANCY"
 ? MARGIN +"-----------  --------------------  ------------  ----  ------------------  -----------------  -----------"

 DO WHILE TERMZ->(!eof())
   cTcode := TERMZ->TCODE
    MASTER->(DbGotop())
    MASTER->(DbSeek(cTcode)) // Position the file pointer in master.

   ?  MARGIN +SPACE(107)
   ?  MARGIN +padc(cTcode,11) + space(2)
   ?? padc(MASTER->OTNAME,20) + space(2)
   ?? padc(alltrim(TERMZ->CCODE),12) + space(2)
   ?? " "+alltrim(TERMZ->ISCNO)+" " + space(2)
   ?? padc(transform( TERMZ->PZCNT, "9,999,999" ),18) + space(2)
   ?? padc(transform( TERMZ->CZCNT, "9,999,999" ),17) + space(2)
   ?? padc(transform( TERMZ->CZCNT - TERMZ->PZCNT, "9,999,999" ),11)

   TERMZ->(dbSkip())
   DO WHILE ( cTcode == TERMZ->TCODE ) .AND. TERMZ->(!eof())

      ? MARGIN +space(50) +alltrim(TERMZ->ISCNO)+ space(3)
      ?? padc(transform( TERMZ->PZCNT, "9,999,999" ),18) + space(2)
      ?? padc(transform( TERMZ->CZCNT, "9,999,999" ),17) + space(2)
      ?? padc(transform( TERMZ->CZCNT - TERMZ->PZCNT, "9,999,999" ),11)
      TERMZ->(dbSkip())
   ENDDO

 ENDDO

 close alternate
 set alternate to
 set alternate off
 set console on

 MASTER->(DbCloseArea())
 TERMZ->(DbCloseArea())

RETURN nil


FUNCTION CREATE_MSALE_REPORT()
LOCAL nGrandTotal:= 0, nTotalPerTenant, cTCode

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif
 MASTER->(DbGotop())

 set console off
 set alternate to OUTMNTH
 set alternate on
 ? MARGIN +padc("Monthly Sales Report",96)
 ? MARGIN +padc(mdy(date()),96)
 ?
 ? MARGIN +"TENANT CODE       OUTLET NAME      CLUSTER CODE    DAILY SALES    MONTHLY SALES  MONTHLY RENTAL"
 ? MARGIN +"-----------  --------------------  ------------  --------------  --------------  --------------"

 DO WHILE MASTER->(!eof())

    ?
    ?  MARGIN +padc(MASTER->TCODE,11) + space(2)
    ?? padc(MASTER->OTNAME,20) + space(2)
    ?? padc(MASTER->CCODE,12) + space(2)
    ?? transform (MASTER->DSALE, "999,999,999.99" ) + space(2)
    ?? transform (MASTER->MSALE, "999,999,999.99" ) + space(2)
    ?? transform (MASTER->MRENT, "999,999,999.99" )
    MASTER->(dbSkip())

 ENDDO

 close alternate
 set alternate to
 set alternate off
 set console on

 MASTER->(DbCloseArea())

RETURN nil

