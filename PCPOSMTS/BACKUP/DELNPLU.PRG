#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"



function delnfound()


USE PLU
Set Index to PLU,ITEMCNT

PLU->(DbGotop())
Do while PLU->(!eof())
   @ 23,5 say "Deleting not found plu ..."
   IF PLU->DESC == space(20) .or. PLU->ITEM_CODE == space(12)
      PLU->(DbDelete())
   ENDIF
   PLU->(DbSkip())
enddo
PLU->(__DBPack())
DbCloseAll()
@ 23,1 clear to 23,80
return nil
