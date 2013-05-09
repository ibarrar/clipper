#include "Inkey.ch"
#include "setcurs.ch"
#include "fileio.ch"
#include "aChoice.ch"
#include "Box.ch"
#include "Janus.ch"


function service()

cls

if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
   index on PO_ITEMS->POI_ITEM to itm
endif

if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
   set index to I_001
endif

Do while PO_ITEMS->(!eof())
   @ 23,5 say "Updating Item Descriptor .. Pls Wait  " + PO_ITEMS->POI_DESC
   If ITEM->(DbSeek(PO_ITEMS->POI_ITEM))
      PO_ITEMS->(Reclock(0)) 
      PO_ITEMS->POI_DESC := ITEM->I_037
      PO_ITEMS->(DbUnLock())
   endif
   PO_ITEMS->(DbSkip())
enddo


   
return nil
