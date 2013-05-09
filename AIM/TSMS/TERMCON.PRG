#include "Janus.Ch"

/* These variables should be visible for all the different models in conver-
   ting */
STATIC cTcode, nTrev:=0, nSale:=0, nTotalTax:=0, nTMisc := 0, nTax4:=0
STATIC nTax8:=0, cIscNo, nZcnt, nCashAmt, cCmpDsc, nMRent, nSales, nCamt:=0
STATIC nTotTax := 0, cZCount := ""
static Z_READ

memvar DbfFile

function Tr_Dat(cMode)
 local aClusters := {}, i, j, aExisting := {}
 // Filenames start with these prefix.
 static aFiles := { "RS34", "RS35", "RS45", "RS55" }

 // Create the temporary file for reading.  Lets Just assume its there...
 NetUse( "DAT.DBF" , DB_EXCLUSIVE, NUM_SECONDS)

 // Use the assignment file.
 if NetUse( "ISCMAP",DB_SHARED, NUM_SECONDS )
    Set index to ISCODE,ISCMAP
 endif

 ISCMAP->(dbGoTop())

 // Store into an array all the clusters.
 DO WHILE ISCMAP->(!eof())
  IF ( ascan ( aClusters, ISCMAP->CLUSTER ) == 0 )
    aadd ( aClusters, ISCMAP->CLUSTER )
  ENDIF
  ISCMAP->(dbSkip())
 ENDDO

 // Open the terminal daily sale file.
 if cMode == "X"
   if NetUse( "TERMX.DBF",DB_SHARED,NUM_SECONDS )
    Set index to TERMX
   endif
   Z_READ := .F.
 else
   if NetUse( "TERMZ.DBF",DB_SHARED,NUM_SECONDS )
    Set index to TERMZ
   endif
   Z_READ := .T.
 endif

 DbfFile := Alias()

 // Open the master file.
 if NetUSe("MASTER.DBF",DB_SHARED,NUM_SECONDS )
   Set Index to MASTER
 endif

 // Set the temporary file for reading in work area 1.

 /* Loop until all possible combinations of prefix and cluster codes are
    converted */
 FOR i := 1 TO len(aClusters)

  FOR j := 1 TO len(aFiles)

   IF file ( aFiles[j] + aClusters[i] + cMode )  // Check if this file is existing.
     // Add it to the array of existin files.
     aadd ( aExisting, aFiles[j] + aClusters[i] + cMode )

     SELECT "DAT"
     ZAP /* Excuse me No other way */
     // Store the content to the temporary file for reading.
     APPEND FROM ( aFiles[j] + aClusters[i] + cMode +"." ) SDF
     DAT->(dbGoTop())

     // Go to the corresponding model conversion.
     DO CASE
       CASE j == 1
         con_34( aClusters[i] )
       CASE j == 2
         con_35( aClusters[i] )
       CASE j == 3
         con_45( aClusters[i] )
       CASE j == 4
         con_55( aClusters[i] )
     ENDCASE

   ENDIF

  NEXT j

 NEXT i

 MASTER->(DbCloseArea())
 ISCMAP->(DbCloseArea())
 (DbfFile)->(DbCloseArea())
 DAT->(DbCloseArea())

 // Erase the temporary file and those read for conversion.
 FOR i := 1 to len ( aExisting )
   ferase( aExisting[i] )
 NEXT i

RETURN nil



STATIC FUNCTION CON_34 ( cCluster )
*************** RS 3460
// Initialize these variables to zero so as that their previous values
// are not used.
nTrev := nSale:= nTotalTax:= nTMisc := nTax4 := nTax8:=nTotTax := 0
nCamt:=0

DO WHILE DAT->(!eof())

  cIscNo := substr ( DAT->F_DATA, 15, 2)  // Get Isc no.

  // Prompt the user of what is going on.
  Message("RS-3460 : " + cCluster + "-" + cIscNo;
                    + " conversion in progress...")

  // Go to the date immediately.
  DAT->(dbSkip(2))

  // Position all the record pointers of corresponding files in correct
  // position.
  Initialize_Positions( cCluster )

  // Reports are processed one by one.
  DO WHILE ( substr(DAT->F_DATA, 1, 4) != "TERM") .AND. DAT->(!eof())

    // Get number descriptor.
    cCmpDsc := substr( DAT->F_DATA, 1, 3 )

    // Store the corresponding values in specific variables.
    DO CASE
      CASE val ( cCmpDsc) >= 1 .AND. val ( cCmpDsc ) <= 6 
        nTrev += val( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "010"  // CASH SALES
        nCamt := val( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "012"  // MISC SALES1
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "014"  // MISC SALES2
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE val( cCmpDsc) > 25 .AND. val( cCmpDsc) < 31
        nTotTax += val( substr( DAT->F_DATA, 10, 8 ) )
      CASE cCmpDsc == "016"  // MISC SALES3
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "018"  // MISC SALES4
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "020"  // MISC SALES5
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "022"  // MISC SALES6
        nTMisc += val ( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "008"  // DYSLE
        nSales := val( substr( DAT->F_DATA, 10, 8 ) ) * 0.01
      CASE cCmpDsc == "048"  // ZCTR(DAILY)
   cZCount :=  substr( DAT->F_DATA, 4, 4 )
        // Append now the terminal file for the values gathered.
   Replace_Update ( cCluster )
    ENDCASE
  
    DAT->(dbSkip()) // Go to the next line.
  ENDDO // Until all the values in the report are processed.

ENDDO  // Main loop

// All is well that ends  well.
RETURN .T.


STATIC FUNCTION CON_35 ( cCluster )
*************** RS 3510
// Initialize these variables to zero so that their previous values
// are not used.
nTrev := nSale:= nTotalTax:= nTMisc := nTax4 := nTax8:=nTotTax := 0
nCamt:=0

// Scan through all the reports in the tempory file.
DO WHILE DAT->(!eof()) .AND. ( substr( DAT->F_DATA, 20, 2 ) != "88")

  cIscNo := substr( DAT->F_DATA, 20, 2 )  // Get isc number.

  // Display what is happening.
  Message("RS-3510 : " + cCluster + "-" + cIscNo + ;
                   " conversion in progress...")

  // Go to the data at once.
  DAT->(dbSkip(2))

  // Position all the record pointers of corresponding files in correct 
  // position.
  Initialize_Positions( cCluster )

  // Loop through all the reports one by one.
  DO WHILE ( substr( DAT->F_DATA, 1, 8) != "TERMINAL" ) .AND. DAT->(!eof())
   // Get number descriptor.
    cCmpDsc := substr( DAT->F_DATA, 1, 2 )

    // Save the corresponding values in variables.
    DO CASE
      // GENERAL REFUND, REFUND, DISCOUNT, VOID ...
      CASE val( cCmpDsc) >= 19 .AND. val ( cCmpDsc ) <= 23
        nTrev += val( substr( DAT->F_DATA, 13, 10 ) ) * 0.01
      CASE cCmpDsc == "45"  // VOID/EC
        nTrev += val( substr( DAT->F_DATA, 13, 10 ) ) * 0.01
      CASE cCmpDsc == "09"  // CASH SALES
        nCamt := val(substr( DAT->F_DATA, 13, 10 ) ) * 0.01
      // TAXES
      CASE val( cCmpDsc) > 25 .AND. val( cCmpDsc) < 31
        nTotTax += val( substr( DAT->F_DATA, 10, 8 ) )
      // MISCELLANEOUS
      CASE val( cCmpDsc) >= 10 .AND. val ( cCmpDsc) <= 15
        nTMisc += val( substr( DAT->F_DATA, 13, 10 ) ) * 0.01
      CASE cCmpDsc == "08"  // DAILY SALES
        nSales := val( substr( DAT->F_DATA, 13, 10 ) ) * 0.01
      CASE cCmpDsc == "50"  // ZCTR(DAILY)
        cZCount := substr( DAT->F_DATA, 3, 6 )
        // Now save the variables in the terminal with corresponding field.
   Replace_Update ( cCluster )
    ENDCASE

   DAT->(dbSkip()) // Go to the next line.
  ENDDO // Until all the data in this report are done.

ENDDO  // Main loop.

// All's well that ends well.
RETURN .T. // End of Con_35



STATIC FUNCTION  CON_45 ( cCluster )
*************** RS 4540
// Initialize these variables to zero so that their previous values
// are not used.
nTrev := nSale:= nTotalTax:= nTMisc := nTax4 := nTax8:=nTotTax := 0
nCamt:=0

DO WHILE ISCMAP->(!eof()) .AND. ( substr( DAT->F_DATA, 19,2) != "88")
      
  cIscNo := substr( DAT->F_DATA, 19, 2 )  // Get Isc no.

  // Prompt the user of the conversion going on.
  Message("RS-4540 : " + cCluster + "-" + cIscNo;
                   + " conversion in progress...")

  DAT->(dbSkip(2))   // Go to the data at once.

  // Position all the record pointers of corresponding files in correct
  // position.
  Initialize_Positions( cCluster )

  // Loop through all the values in this particular report.
  DO WHILE ( substr( DAT->F_DATA, 1, 8 ) != "TERMINAL" ) .AND. DAT->(!eof())
    // Get number descriptor.
    cCmpDsc := substr( DAT->F_DATA, 1, 3 )

    // Store the values gathered in corresponding variables.
    DO CASE
      CASE  val( cCmpDsc) > 25 .AND. val( cCmpDsc) < 31
        nTotTax += val( substr( DAT->F_DATA, 10, 8 ) )
      CASE cCmpDsc = "025"  // GENERAL REFUND
        nTrev += val( substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      CASE cCmpDsc == "024"  // REFUND
        nTrev += val( substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      CASE cCmpDsc == "021"  // VOID/EC
   nTrev += val( substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      CASE cCmpDsc == "026"  // SUBTOTAL DISCOUNT
   nTrev += val( substr( DAT->F_DATA, 10,  12 ) ) * 0.01
      CASE cCmpDsc == "037"  // CASH SALES
        nCamt += val( substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      //  MISC SALES
      CASE val ( cCmpDsc ) >= 7 .AND. val ( cCmpDsc ) <= 16
        nTMisc += val(substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      CASE cCmpDsc == "006"  // DYSALES
        nSales := val( substr( DAT->F_DATA, 10, 12 ) ) * 0.01
      CASE cCmpDsc == "055"  // ZCTR(DAILY)
        cZCount := substr( DAT->F_DATA, 4, 6 )
        // Append the terminal file for the values gathered.
   Replace_Update ( cCluster )
    ENDCASE

    DAT->(dbSkip())  // Next line.
  ENDDO  // Until all of the values in this report are read.

ENDDO  // Main loop

RETURN .T.  // End of procedure con_45


STATIC FUNCTION CON_55 ( cCluster )
*************** RS 5550
// Initialize these variables to zero so as that their previous values
// are not used.
nTrev := nSale:= nTotalTax:= nTMisc := nTax4 := nTax8:=nTotTax := 0
nCamt:=0

DO WHILE DAT->(!eof())  // Main loop...

  cIscNo := substr( DAT->F_DATA, 19, 2 )  // Get cIscNo no.

  // Prompt user.
  Message ("RS-5550 : " + cCluster + "-" + cIscNo +;
                    " conversion in progress..." )

  DAT->(dbSkip ( 2 ))  // Go to the record at once and exit loop.

  // Position all the record pointers of corresponding files in correct
  // position.
  Initialize_Positions( cCluster )

  // Get all the values in this particular report.
  DO WHILE ( substr( DAT->F_DATA, 1, 8 ) != "TERMINAL" ) .AND. DAT->(!eof())

    if (substr(DAT->F_DATA, 1, 9) == "Z-COUNTER")
        DAT->(DbSkip(2))
        cZCount := ( substr(DAT->F_DATA, 18,4) )
        DAT->(DbSkip())
    endif

    cCmpDsc := substr( DAT->F_DATA, 1, 3 )  // Get number descriptor.

    // Store the values in corresponding variables.
    DO CASE

       CASE  VAL( cCmpDsc ) > 25 .AND. VAL( cCmpDsc) < 31
          nTotTax += VAL( substr( DAT->F_DATA, 10, 8 ) )
       // GENERAL REFUN, etc.
       
       CASE val ( cCmpDsc ) >= 55 .AND.  val ( cCmpDsc ) <= 57
     nTrev += VAL( substr( DAT->F_DATA, 10, 12 ) ) * 0.01

       CASE cCmpDsc == "010"        && CASH SALES
          nCamt := VAL(substr( DAT->F_DATA, 10, 12 ) ) * 0.01
       // MISC SALES1

       CASE val ( cCmpDsc ) >= 11 .AND. val ( cCmpDsc ) <= 20
          nTMisc += VAL(substr( DAT->F_DATA, 10, 12 ) ) * 0.01

       CASE cCmpDsc == "009" // DYSALE
          nSales := VAL( substr( DAT->F_DATA, 10, 12 ) ) * 0.01

       CASE cCmpDsc == "095"  // TRANS CANCEL
          nTrev += VAL( substr( DAT->F_DATA, 10, 12 ) ) * 0.01

    ENDCASE

    DAT->(dbSkip ()) // Next line.

    if (substr( DAT->F_DATA, 1, 8 ) == "TERMINAL" ) .or. DAT->(eof())
       // Save the gathered data in the terminal file.
       Replace_Update ( cCluster )
    endif

  ENDDO  // Until all the values in the report are read.

ENDDO  // Main loop...

RETURN .T. // End of CON_55


STATIC FUNCTION INITIALIZE_POSITIONS( cCluster )
// This will positions the record pointers in TNTISC.DBF and TIM.DBF
// with a corresponding read cluster-iscno.

  // Position the record pointer in the assignment file.
  ISCMAP->(DbGotop())
  do while ISCMAP->(!eof())
    if ((alltrim(ISCMAP->ISC_NO) == alltrim(cIscNo)) .and. (alltrim(ISCMAP->CLUSTER) == alltrim(cCluster)))
       cTcode := ISCMAP->TCODE
       exit
    endif
    ISCMAP->(DbSkip())
  enddo

/*  if ISCMAP->(Eof())
   if alert("Error Seeking Proper Tenants Code & Isc No.",{"QUIT","CONTINUE"})==1
     quit
   endif
  endif */

  // Position record pointer in the master file.
  MASTER->(DbGotop())
  MASTER->(dbSeek( cTcode ))

RETURN nil


STATIC FUNCTION REPLACE_UPDATE ( cCluster )
/* After a Z-report is finished. There is a call in this function
   to update the terminal file and the master file. */
LOCAL nPrevZ := 0
local dTemp := ctod("")

   // Add the read data in TERM.DBF
   (DbfFile)->(DbGotop())
   do while ( (DbfFile)->(!eof() ) )
    if ( (DbfFile)->ISCNO == cIscNo ) .and. ((DbfFile)->CCODE == cCluster )
      if (DbfFile)->DATE >= dTemp
         nPrevZ := (DbfFile)->CZCNT
         dTemp := (DbfFile)->DATE
      endif
    endif
    (DbfFile)->(DbSKip())
   ENDDO

   (DbfFile)->(DbGotop())
   do While (!Z_READ)  .and. ((DbfFile)->(!eof()))
     if ((DbfFile)->ISCNO == cIscNo) .and. ((DbfFile)->CCODE == cCluster) ;
                                   .and. ((DbfFile)->DATE == date())
         exit
     endif
     (DbfFile)->(DbSkip())
   enddo
   
   if MASTER->CRATE != 0 
      nSales *= MASTER->CRATE 
   endif
   
   // Add the values in the terminal file.
   (DbfFile)->(FilLock(0))
   if (Z_READ) .or. ((DbfFile)->CCODE != cCluster) .or. ((DbfFile)->ISCNO != cIscNo) ;
             .or. ((DbfFile)->DATE != date())
     (DbfFile)->(AddRec(0))
     (DbfFile)->DATE  := date()
     (DbfFile)->ISCNO := cIscNo
     (DbfFile)->CCODE := cCluster
   endif
   (DbfFile)->PZCNT := nPrevZ
   (DbfFile)->CZCNT := val( cZcount )
   (DbfFile)->CSALE := nCamt
   (DbfFile)->NTRAN := nTrev
   (DbfFile)->DSALE := nSales
   (DbfFile)->MISCS := nTMisc
   (DbfFile)->TCODE := MASTER->TCODE
   (DbfFile)->(DbCommit())
   (DbfFile)->(DbUnlock())
   // Use the master file
   // Save the tenant code to the terminal file.

   
   if Z_READ
     MASTER->(RecLock(0))
     // Update corresponding data in DBF ( master )
     MASTER->DSALE := MASTER->DSALE+nSales
     MASTER->MSALE := MASTER->MSALE+nSales
     MASTER->YSALE := MASTER->YSALE+nSales
     nMRent := MASTER->BRATE * MASTER->MSALE * 0.01
     MASTER->MRENT := nMRent
     // Save at once.
     MASTER->(DbCommit())
     MASTER->(DbUnlock())
  endif

RETURN nil
