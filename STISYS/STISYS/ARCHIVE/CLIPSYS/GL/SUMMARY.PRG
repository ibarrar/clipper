#include "Mode.Ch"
static aItems

function CDB_Summary(nMode)
   if GetDates()
         Set(_SET_SOFTSEEK,.T.)
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_CODE,CHART,CHT_ACCT
         endif
         if NetUse("CDBTRANS",DB_SHARED,NUM_SECONDS)
            set index to CDBTRANS
         endif
         if NetUse("CDB",DB_SHARED,NUM_SECONDS)
            set index to CDB_VNO,CDB_DATE,CDB_NAME
         endif
         CDB->(DbSeek(dStartDate))
         aItems:={}
         do while CDB->(!Eof()) .and. ;
            ((ctod(CDB->DATE)>=dStartDate) .and. (ctod(CDB->DATE)<=dEndDate))
            CDBTRANS->(DbSeek( CDB->(RecNo()) ))
            do while CDBTRANS->(!Eof()) .and. ;
               (CDBTRANS->REC_NO == CDB->(RecNo()))
               aAdd(aItems,{CDBTRANS->ACCT_CODE,CDBTRANS->DEBIT,CDBTRANS->CREDIT})
               CDBTRANS->(DbSkip())
            enddo
            ? CDB->DATE," ",CDB->PAYEE," ",CDB->VOUCHER_NO," ",CDB->CHECK_NO
            z:=if(len(aItems)>2,len(aItems),3)
            for x:=1 to len(aItems)
                if x==1  ;  ?? space(2)
                elseif x==2  ;  ? space(11),CDB->DETAILS_1," "
                elseif x==3  ;  ? space(11),CDB->DETAILS_2," "
                else  ;  ? space(51)  ; endif
                if x<=len(aItems)
                   CHART->(DbSeek(aItems[x][1]))
                   ?? CHART->ACCT_TITLE," ",aDetails[x][2]," ",aDetails[x][3]
                endif
            next
         enddo
         CDB->(DbCloseArea())
         CDBTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
   endif
return nil

