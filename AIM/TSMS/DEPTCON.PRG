#include "Janus.CH"

// Variables used in all the type of conversion.
STATIC cDptName, nDptCtr, nDptAmt, cIscNo, cTcode
static Z_READ,mCRATE

memvar DbfFile

FUNCTION DP_DAT (cMode)
 LOCAL aClusters := {}, i, j, aExisting := {}
 // The file prefix for the department data read.
 STATIC aFiles := { "DP34", "DP35", "DP45", "DP55" }


 
 // Create the temporary file for reading.
 NetUse( "DAT", DB_EXCLUSIVE, NUM_SECONDS )

 // Use the assignment file.
 if NetUse( "ISCMAP", DB_SHARED, NUM_SECONDS )
    Set Index to ISCODE,ISCMAP
 endif

 // Get all the existing cluster codes.
 DO WHILE ISCMAP->(!eof())
  IF ( ascan ( aClusters, ISCMAP->CLUSTER ) == 0 )
    aadd ( aClusters, ISCMAP->CLUSTER )
  ENDIF
  ISCMAP->(dbSkip())
 ENDDO

 // Use the department file.
 if cMode == "X"
   if NetUSe( "DEPTX",DB_SHARED, NUM_SECONDS )
      Set Index to DEPTX
   endif
  Z_READ := .F.
 else
   if NetUSe( "DEPTZ",DB_SHARED, NUM_SECONDS )
      Set Index to DEPTZ
   endif
  Z_READ := .T.
 endif

 DbfFile := Alias()

 /* Loop through all the possible combinations of prefix and cluster codes
    for the departments read */
 FOR i := 1 TO len(aClusters)

  FOR j := 1 to len(aFiles)

   IF file ( aFiles[j] + aClusters[i] + cMode) // Check for the existence of this file.
     // Add it to the array of file existence.
     aadd ( aExisting, aFiles[j] + aClusters[i] + cMode)
     // Use the temporary file.
     SELECT "DAT"
     ZAP
     // Get the ascii file of the existing department read.
     APPEND FROM ( aFiles[j] + aClusters[i] + cMode + "." ) SDF
     DAT->(dbGoTop())

     // Go to the corresponding model conversion.
     DO CASE
       CASE j == 1
         dep_34( aClusters[i] )
       CASE j == 2
         dep_35( aClusters[i] )
       CASE j == 3
         dep_45( aClusters[i] )
       CASE j == 4
         dep_55( aClusters[i] )
     ENDCASE

   ENDIF

  NEXT j

 NEXT i

 ISCMAP->(DbCloseArea())
 (DbfFile)->(DbCloseArea())
 DAT->(DbCloseArea())

 // Erase the temporary file and all the files read.
 FOR i := 1 to len ( aExisting )
   ferase ( aExisting[i] )
 NEXT i
RETURN nil // End of FUNCTION DP_DAT


STATIC FUNCTION DEP_34 ( cCluster )

DO WHILE DAT->(!eof())
        
  cIscNo := substr( DAT->F_DATA, 68, 2 )  // Get isc number.

  Message("RS-3460 (Department) : " + cCluster + "-" + cIscNo +;
                    " conversion in progress..." )

  DAT->(dbSkip(2))
 
  Initial_Positions (cCluster)

  // It will loop until another department report is encountered
  DO WHILE ( substr( DAT->F_DATA, 1, 10 ) != "DEPARTMENT" ) .AND. DAT->(!eof())
  
    IF ( val( substr( DAT->F_DATA, 23, 8 ) ) ) != 0

       cDptName :=  substr( DAT->F_DATA, 3, 8 )         // Get data.
       nDptCtr  :=  val ( substr( DAT->F_DATA, 31, 4 ) )
       nDptAmt  :=  val ( substr( DAT->F_DATA, 23, 8 ) ) * 0.01

       Replace_All ( cCluster )

    ENDIF

   DAT->(DbSkip())
 ENDDO

ENDDO  // main loop do while .not. eof()

RETURN .T.// end of dep_34


STATIC FUNCTION DEP_35 ( cCluster )

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 34, 2 ) != "88" )

   cIscNo := substr( DAT->F_DATA, 34, 2 )

   Message ("RS-3510 (Department): " + cCluster + "-" + cIscNo +;
                    " conversion in progress..." )

   DAT->(dbSkip( 2 ))

   Initial_Positions (cCluster)

   DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 1, 10 ) != "DEPARTMENT" )

    IF ( val( substr( DAT->F_DATA, 3, 10) ) != 0 )

       nDptCtr  :=  val ( substr( DAT->F_DATA, 13, 6 ) )
       nDptAmt  :=  val ( substr( DAT->F_DATA, 3, 10 ) ) * 0.01
       cDptName :=  substr( DAT->F_DATA, 1, 2 )

       Replace_All ( cCluster )

    ENDIF

    DAT->(dbSkip())
   ENDDO  // loop for getting dept values.

ENDDO  // Main loop

RETURN .T. // End of DEP_35


STATIC FUNCTION DEP_45 ( cCluster )

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 40, 2 ) != "88" )

  cIscNo := substr( DAT->F_DATA, 40, 2 )

  Message("RS-4540 (Department): " + cCluster + "-" + cIscNo +;
                   " conversion in progress...")

  DAT->(dbSkip( 2 ))  // Go to the data at once.

  Initial_Positions (cCluster)

  DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 1, 3 ) != "ALL" )

    IF ( val( substr( DAT->F_DATA, 3, 12 ) ) != 0 )

      nDptCtr := val ( substr( DAT->F_DATA, 15, 6 ) )
      nDptAmt := val ( substr( DAT->F_DATA, 3, 12 ) )  * 0.01
      cDptName := substr( DAT->F_DATA, 1, 2 )

      Replace_All ( cCluster )
    ENDIF

    DAT->(dbSkip())

  ENDDO  // Loop for getting depts sum.

ENDDO   // Main loop.

RETURN .T. // End of dep_45.


STATIC FUNCTION DEP_55 ( cCluster )

DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 28, 2 ) != "88")

  cIscNo := substr( DAT->F_DATA, 28, 2 )  // Get isc number.

  Message( "RS-5550 (Department): " + cCluster + "-" + cIscNo +;
                   " conversion in progress..." )
  DAT->(dbSkip( 2 ))

  Initial_Positions (cCluster)

  DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 5, 10 ) != "Department")

    // Get corresponding data.
    cDptName := substr ( DAT->F_DATA, 1, 6 )
    nDptCtr  := val( substr( DAT->F_DATA, 19, 6 ) )
    nDptAmt  := val( substr( DAT->F_DATA, 7, 12 ) ) * 0.01

    IF ( nDptCtr != 0 )
      Replace_All ( cCluster )
    ENDIF
    DAT->(dbSkip())

  ENDDO // Conversion loop.

ENDDO  // End of main loop.

RETURN .T.// End of dep_55


STATIC FUNCTION INITIAL_POSITIONS ( cCluster )
// This will position the record pointers of iscmap.DBF .

  ISCMAP->(Dbgotop())
   do while ISCMAP->(!eof())
    if ((ISCMAP->CLUSTER == cCluster) ;
       .and. (ISCMAP->ISC_NO == cIscNo))
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
  mCRATE := MASTER->CRATE
 else
  mCRATE := 0 
 endif 

 MASTER->(DbCloseArea()) 
 
RETURN nil


STATIC FUNCTION REPLACE_ALL ( cCluster )
/* This function will just replace the corresponding fields in the
   department file. */

 (DbfFile)->(DbGotop())
 Do While (DbfFile)->(!Eof())
   if (((DbfFile)->ISCNO == cIscNo) .and. ((DbfFile)->DATE == date()) ;
      .and. ((DbfFile)->CCODE == cCluster) .and. (alltrim((DbfFile)->DPNAME) == alltrim(cDptName)) )
     exit
   endif
 (DbfFile)->(DbSkip())
 enddo
 
 if mCRATE != 0
   nDptAmt *= mCRATE
 endif

   (DbfFile)->(FILLOCK(0))
   if Z_READ .or. (DbfFile)->(Eof())
      (DbfFile)->(ADDREC(0))
      (DbfFile)->ISCNO  := cIscNo
      (DbfFile)->CCODE  := cCluster
      (DbfFile)->DATE   := date()
      (DbfFile)->DPNAME := cDptName
   endif
   (DbfFile)->TCODE  := cTcode
   (DbfFile)->DPCTR  := nDptCtr
   (DbfFile)->DPSUM  := nDptAmt
   (DbfFile)->(dbCommit(0))
   (DbfFile)->(dbUNLOCK())

RETURN nil

