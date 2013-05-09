#include "Janus.cH"

STATIC cTcode, cIscNo, nHamt, nHctr, cHour
static Z_READ, mCRATE

memvar DbfFile

FUNCTION HR_DAT (cMode)
 LOCAL aClusters := {}, i, j, aExisting := {}
 STATIC aFiles := { "HR34", "HR35", "HR45", "HR55" }

 NetUse( "DAT", DB_EXCLUSIVE, NUM_SECONDS )

 if NetUse( "ISCMAP", DB_SHARED, NUM_SECONDS )
     Set Index to ISCODE,ISCMAP
 endif

 ISCMAP->(dbGoTop())
 DO WHILE ISCMAP->(!eof())
  IF ( ascan ( aClusters, ISCMAP->CLUSTER ) == 0 )
    aadd ( aClusters, ISCMAP->CLUSTER )
  ENDIF
  ISCMAP->(dbSkip())
 ENDDO

 if cMode == "X"
    if NetUse( "HOURX", DB_SHARED, NUM_SECONDS )
     Set index to HOURX
    endif
    Z_READ := .F.
 else
    if NetUse( "HOURZ", DB_SHARED, NUM_SECONDS )
     Set index to HOURZ
    endif
    Z_READ := .T.
 endif

 DbfFile := Alias()

 FOR i := 1 TO len(aClusters)

  FOR j := 1 to len(aFiles)

   IF file ( aFiles[j] + aClusters[i] + cMode)

     aadd ( aExisting, aFiles[j] + aClusters[i] + cMode)
     SELECT "DAT"
     ZAP /*---- TO Do the undoable ----*/
     APPEND FROM ( aFiles[j] + aClusters[i] + cMode + "." ) SDF
     DAT->(dbGoTop())

     DO CASE
       CASE j == 1
         hr_34( aClusters[i] )
       CASE j == 2
         hr_35( aClusters[i] )
       CASE j == 3
         hr_45( aClusters[i] )
       CASE j == 4
         hr_55( aClusters[i] )
     ENDCASE

   ENDIF

  NEXT j

 NEXT i

 ISCMAP->(DbCloseArea())
 (DbfFile)->(DbCloseArea())
 DAT->(DbCloseArea())

 FOR i := 1 to len ( aExisting )
   ferase ( aExisting[i] )
 NEXT i
RETURN nil


STATIC FUNCTION HR_34 ( cCluster )

LOCAL aTimeFrame := { "09:00", "10:00", "11:00", "12:00", "13:00", "14:00",;
                      "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",;
                      "21:00", "22:00", "23:00", " 0:00", " 1:00", " 2:00",;
                      " 3:00", " 4:00", " 5:00", " 6:00", " 7:00", " 8:00" }

DO WHILE !eof()

  cIscNo := substr( DAT->F_DATA, 16, 2 ) // Get Isc number.

  Message("RS-3460 (Hourly): " + cCluster + "-" + cIscNo +;
                  " conversion in progress...", .F. )

  DAT->(dbSkip(2))

  Initial_Positions( cCluster )

  DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 1, 6 ) != "HOURLY" )

   // Process an hourly report of an isc.
   cHour := aTimeFrame [ val( substr( DAT->F_DATA, 1, 2 ) )]
   nHamt := val( substr( DAT->F_DATA, 3, 10 ) ) * 0.01
   nHCtr := val( substr( DAT->F_DATA, 13, 6) )

   IF nHamt > 0
     Replace_All ( cCluster )
   ENDIF

   DAT->(dbSkip())

  ENDDO // End of processing by isc no.

ENDDO  //  End of main loop.

RETURN .T. // End of hr_34


STATIC FUNCTION HR_35 ( cCluster )

LOCAL aTimeFrame := { "09:00", "10:00", "11:00", "12:00", "13:00", "14:00",;
                      "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",;
                      "21:00", "22:00", "23:00", " 0:00", " 1:00", " 2:00",;
                      " 3:00", " 4:00", " 5:00", " 6:00", " 7:00", " 8:00" }

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 22, 2 ) != "88"  ) // Main loop.

   cIscNo := substr( DAT->F_DATA, 22, 2 )  // Get isc number.

   Message("RS-3510 (Hourly): " + cCluster + "-" + cIscNo +;
                   " conversion in progress..." )
   DAT->(dbSkip(2))

   Initial_Positions( cCluster )

   DO WHILE ( substr(DAT->F_DATA, 1, 6) != "HOURLY" ) .AND. DAT->(!eof())

      cHour := aTimeFrame [ val( substr( DAT->F_DATA, 1, 2 ) )]
      nHamt := val( substr( DAT->F_DATA, 3, 10 ) ) * 0.01
      nHctr := val( substr( DAT->F_DATA, 13, 6) )

      IF ( nHctr > 0 )
         Replace_All ( cCluster )
      ENDIF

      DAT->(dbSkip())
   ENDDO  // loop for processing isc#


ENDDO // Main loop.

RETURN .T. // End of hr_35


STATIC FUNCTION HR_45 ( cCluster )
LOCAL aTimeFrame := { "10:00", "11:00", "12:00", "13:00", "14:00",;
                      "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",;
                      "21:00", "22:00", "23:00", " 0:00", " 1:00", " 2:00",;
                      " 3:00", " 4:00", " 5:00", " 6:00", " 7:00", " 8:00",;
                      " 9:00" }
LOCAL nTime

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 25, 2) != "88" )

  cIscNo := substr( DAT->F_DATA, 25, 2 )   // Get isc number.

  Message("RS-4540 (Hourly): " + cCluster + "-" + cIscNo +;
                  " conversion in progress..." )
  DAT->(dbSkip( 2 ))  // Go to the data at once.

  Initial_Positions( cCluster )

  DO WHILE DAT->(!eof()) .AND. ( substr ( DAT->F_DATA, 1, 6 ) != "HOURLY" )

      IF ( substr( DAT->F_DATA, 1, 2 )  == "FF" ) 
        DAT->(DbSkip())
        LOOP
      ENDIF

      IF ( ( nTime := val ( substr (DAT->F_DATA, 1, 2 ) ) ) == 0 )
         nTime++
      ENDIF

      cHour := aTimeFrame [ nTime ]
      nHamt := val( substr( DAT->F_DATA, 16, 12 ) ) * 0.01
      nHctr := val( substr( DAT->F_DATA, 8, 6 ) )

      IF ( nHctr > 0 )
         Replace_All ( cCluster )
      ENDIF

      DAT->(dbSkip())
  ENDDO  // Loop for conversion.

ENDDO  // Main loop.

RETURN .T. // End of hr_45.


STATIC FUNCTION HR_55 ( cCluster )

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 26, 2 ) != "88" )

  cIscNo := substr( DAT->F_DATA, 26, 2 )  // Get isc no.

  Message("RS-5550 (Hourly) : " + cCluster + "-" + cIscNo +;
                  " conversion in progress..." )

  DAT->(dbSkip( 2 )) // Go to the data at once and exit loop.

  Initial_Positions( cCluster )

  DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 1, 6) != "HOURLY"  )

      // Get time.
      cHour := substr(DAT->F_DATA, 1, 4)

      IF ( cHour == "9999")
        DAT->(dbSkip())
        LOOP
      ENDIF

      cHour := substr (cHour, 1, 2 ) + ":" + substr( cHour, 3, 2 ) // Convert time.
      // Get hourly count.
      nHctr := val( substr(DAT->F_DATA, 11, 6) )
      // Get hourly sale.
      nHamt := val( substr(DAT->F_DATA, 17, 12 ) ) * 0.01

      IF ( nHctr > 0 ) /*  Don't process 0 amounts. */

         Replace_All ( cCluster )

      ENDIF

      DAT->(dbSkip())
   ENDDO  // Loop of conversion.

ENDDO  // Main loop.

RETURN .T. // End of hr_55


STATIC FUNCTION INITIAL_POSITIONS ( cCluster )

  ISCMAP->(dbGotop())
   do While ISCMAP->(!eof())
    if ISCMAP->CLUSTER == cCluster .and. ISCMAP->ISC_NO == cIscNo
       cTcode := ISCMAP->TCODE
       exit
    endif
    ISCMAP->(DbSkip())
   enddo
   
   if NetUse( "MASTER", DB_SHARED, NUM_SECONDS )
      Set Index to MASTER
   endif

   MASTER->(DbSeek(cTcode))

   if MASTER->(!Eof())
      mCrate :=MASTER-> CRATE
   else
      mCRATE := 0
  endif

  MASTER-> (DbCloseArea())
  
RETURN nil


STATIC FUNCTION REPLACE_ALL ( cCluster )

  (DbfFile)->(Dbgotop())
  do while (!Z_READ)  .and. ((DbfFile)->(!Eof()))
   if (((DbfFile)->ISCNO == cIscNo) .and. ((DbfFile)->DATE == date()) .and. ((DbfFile)->CCODE == cCluster) ;
      .and. (alltrim((DbfFile)->HTIME) == alltrim(cHour)))
    exit
   endif
   (DbfFile)->(DbSkip())
  enddo

  if mCRATE !=0
     nHAmt *= mCRATE
  endif
  
      (DbfFile)->(FilLock(0))  // Add to HOUR.DBF .
      if ((Z_READ) .or. (DbfFile)->(Eof()))
        (DbfFile)->(Addrec(0))
        (DbfFile)->ISCNO  := cIscNo
        (DbfFile)->CCODE  := cCluster
        (DbfFile)->DATE   := date()
        (DbfFile)->HTIME  := cHour
      endif
      (DbfFile)->TCODE  := cTcode
      (DbfFile)->HSALE   := nHAmt
      (DbfFile)->HCOUNT  := nHctr
      (DbfFile)->(dbCommit())
      (DbfFile)->(DbUNLOCK(0))

RETURN nil
