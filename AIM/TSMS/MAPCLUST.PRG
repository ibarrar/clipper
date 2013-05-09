#include "box.ch"
#include "inkey.ch"
#include "Janus.ch"

#define M_ROW1 0
#define M_COL1 10
#define M_ROW2 24
#define M_COL2 68

function MapCluster( cCluster )
local aCLTC := Get_Cluster_Tcodes()
local aTCISC:= Get_Tcode_IscNos()
local i, j
local aISCTC := {}
local cISCNo, nPos, n, cWind := savescreen( M_ROW1, M_COL1, M_ROW2, M_COL2+2 )

 // Initialize the array of tenant w/ ISC + 1 as subscript
 // Example : ISC 02 assigned to tenant "A00001" is equivalent as
 //           aISCTC[3] := "A00001"
 asize( aISCTC, 64 )
 afill( aISCTC, nil)

 // Get postion of the cluster in the array of cluster and tenants.
 nPos := ascan( aCLTC, { |a| a[1] == cCluster } )

 // Repeat for all the tenants in the cluster.
 for i := 1 to len( aCLTC[nPos][2] )
  // Locate for the position of the current tenant in the array of
  // tenants and ISCs.
  n := ascan( aTCISC, { |a| a[1] == aCLTC[nPos][2][i] } )

  // Repeat for all the isc nos. in this particular tenant.
  for j := 1 to len( aTCISC[n][2] )
    // Save the tenant code in the isc array.
    aISCTC[val( aTCISC[n][2][j] ) +1 ] := aTCISC[n][1]
  next j

 next i

 // Draw the box with shadow large enough to fit all the 64 ISC nos.
 shadow( M_ROW1, M_COL1, M_ROW2, M_COL2 )
 @ M_ROW1, M_COL1, M_ROW2, M_COL2 Box B_SINGLE_DOUBLE+" " ;
                       COLOR if( iscolor(), "N+/G+", "N+/W+" )

 // Print the cluster at the top of the box.
 @ M_ROW1, M_COL1 + 2  SAY  " Cluster - " + cCluster + " " ;
                       COLOR if( iscolor(), "N+/G+", "N/W" )

 // This routine will print all the 64 isc nos. and those tenants attached
 // to them.
 n := 0
 for i := 1 to 22 STEP 3
  for j := 12 to 67 STEP 7
    cIscNo := padl( alltrim ( str( n, 2 ) ), 2, "0" )
    @ i, j + 2  say cISCNo
    @ i+1, j say if( aISCTC[n + 1] == nil, space(6), aISCTC[n + 1]);
             COLOR "W+/N"
    n++
  next j
 next i

 // Put message.
 @ M_ROW2, M_COL1 + 2  SAY  " ESC - to Exit " ;
                       COLOR if( iscolor(), "N+/G+", "N/W" )

 // Wait for an ESC key to be pressed.
 do while ( inkey(0) != K_ESC ) ; enddo

 restscreen( M_ROW1, M_COL1, M_ROW2, M_COL2+2, cWind )
return nil

/*******************************************************/

/* This function will return all the isc nos.(terminal) in an array for a
   particular tenant code */
static function Get_ISCNos ( cTCode )
local  aISC := {}
local nRecNo := ISCMAP->(recno())
 ISCMAP->(DbGotop())
 ISCMAP->(DbSeek(cTCode))
 do while ISCMAP->TCODE==cTCode .and. ISCMAP->(!Eof())
   if ISCMAP->ISC_NO != "99"
     aadd ( aISC, ISCMAP->ISC_NO )
   endif
   ISCMAP->(DbSkip())
 enddo
 ISCMAP->(DBGoto(nRecno))
return aISC


/* This function will return an array of tenant codes and  array of
   isc nos. */
function Get_TCode_ISCNos ()
local  aTcode_ISC := {}, aTcode := {}, aSungot := {}

 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set Index to ISCODE,ISCMAP
 endif
 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
   Set index to MASTER
 endif

 MASTER->(DbGotop())
 do while MASTER->(!eof())
   asize(aTCode,0)
   aAdd( aTCode, MASTER->TCODE)
   aadd( aTcode, ISCMAP->(Get_IscNos( MASTER->TCODE )) )
   aSungot:= aClone( aTcode)
   aAdd( aTCode_ISC, aSungot )
   MASTER->(DbSkip())
 enddo
 MASTER->(DbCloseArea())
 ISCMAP->(DbCloseArea())
return aTcode_ISC


/* This function will return an array of tenants for a particular cluster
    no. */
static  function Get_TCodes( cCluster )
local  aTCodes := {}
local nRecno:= MASTER->(Recno())
 MASTER->(DbGotop())
 // The search is done for all the tenants in cluster "cCluster"
 LOCATE FOR ( cCluster == MASTER->CCODE )
 do while found()
   if (aScan(aTCodes, MASTER->TCODE) == 0)
    aadd( aTCodes, MASTER->TCODE )
   endif
   MASTER->(DbSkip())
   LOCATE REST FOR ( cCluster == MASTER->CCODE )
 enddo
 MASTER->(DbGoto(nRecNo))
return ( aTCodes )


/* This function will create an array of tenants connected to a cluster.*/
function Get_Cluster_TCodes()
local aCluster_TCodes := {}, aSungot := {}
local aBuffer := {}, aCluster := {}

 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif
 MASTER->(DbGotop())
 do while MASTER->(!eof())
   // Check first if the cluster is already in the array.
   if ( ascan( aBuffer, MASTER->CCODE ) == 0 )
     // Temporary array to store clusters.
     aadd( aBuffer, MASTER->CCODE )

     // Resize the array of clusters and tenants.
     asize( aCluster, 0 )
     // Add the Cluster to the array.
     aadd( aCluster, MASTER->CCODE )
     // Add the Tenant's connected to this cluster.
     aadd( aCluster, MASTER->(Get_Tcodes( MASTER->CCODE )) )
     // Make another copy of these in memory. Para saan ? Ewan ko. !
     aSungot := aclone( aCluster )
     // Now the finish product.
     aadd( aCluster_TCodes, aSungot )
   endif

   MASTER->(DbSkip())
 enddo

 MASTER->(DbCloseArea())

return ( aCluster_TCodes )
function Get_Avail_TCodes( aTCISC, CCluster, cISCNo)
local i, aAvailable := {}, nTemp,lMine
 if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
    Set index to MASTER
 endif
 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set Index to ISCMAP,ISCODE
 endif
 for i:= 1 to len( aTCISC )
  lMine:=.f.
  nTemp:=0
  MASTER->(DbGoTop())
  MASTER->(DbSeek(aTCISC[i][1])) //tcode
  ISCMAP->(DbSeek(MASTER->(Recno())))
  do while ISCMAP->REC_NO == MASTER->(RecNo()) .and. ISCMAP->(!Eof())
    if ISCMAP->CLUSTER == cCluster .and. ISCMAP->ISC_NO == "99"
     nTemp++
    endif
    if (ISCMAP->ISC_NO == cISCNo).and.(ISCMAP->CLUSTER==cCluster)
        lMine:= .t.
    endif
    ISCMAP->(DbSkip())
  enddo

  if (nTemp > 0) .or. (lMine)
      if (lMine) // Mark it if already assigned.
        aadd( aAvailable,"*"+aTCISC[i][1]+" "+tran(nTemp,"@B 99") )
      else
        aadd( aAvailable," "+aTCISC[i][1]+" "+tran(nTemp,"@B 99") )
      endif
  endif
 next i

ISCMAP->(DbCloseArea())
MASTER->(DbCloseArea())
return  aAvailable

/*-*-*-*-*-*-Eof <mapclust>-*-*-*-*-*-*/