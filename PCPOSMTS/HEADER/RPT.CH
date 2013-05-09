

// TERMINAL.RPT

#DEFINE  SIGN  substr(cStr,1,3)

// type 1
#DEFINE  COUNT  val(substr(cStr,6,4)) 
#DEFINE  AMOUNT val(substr(cStr,10,12)) *.01

// type 2
#DEFINE  AMOUNT2 val(substr(cStr,10,12)) * .01

// type 3
#DEFINE  COUNT3 val(substr(cStr,6,6)) 




// PLUITEMS.RPT

#DEFINE   ICODE    substr(cStr,1,14)
#DEFINE   ITCODE   substr(cStr,15,12)
#DEFINE   IDESC    substr(cStr,27,20)
#DEFINE   ICNT     substr(cStr,47,10) 
#DEFINE   IAMT     substr(cStr,57,12)
#DEFINE   IUCOST   val(substr(cStr,69,12)) *.01

// not found

#DEFINE   NF_ICODE    substr(cStr,1,14)
#DEFINE   NF_ICNT     substr(cStr,15,10)
#DEFINE   NF_IAMT     substr(cStr,25,12)



// DEPARTMENT.RPT

#DEFINE   D_CODE     substr(cStr,1,4)
#DEFINE   D_DESC     substr(cStr,5,20)
#DEFINE   D_COUNT   val(substr(cStr,25,10)) * .001 // jlp...03.13.98
#DEFINE   D_AMOUNT  val(substr(cStr,35,12) ) * .01



// HOUR.RPT

#DEFINE   H_HOUR     val(substr(cStr,1,2)) 
#DEFINE   H_COUNT    val(substr(cStr,3,10)) *.001
#DEFINE   H_AMOUNT   val(substr(cStr,14,12)) *.01



// RETURN.RPT

#DEFINE   R_PLU      substr(cStr,1,14)
#DEFINE   R_ICODE    substr(cStr,15,12)
#DEFINE   R_DESC     substr(cStr,27,20)
#DEFINE   R_DEPT     substr(cStr,47,4)
#DEFINE   R_COUNT    val(substr(cStr,51,10) ) *.01
#DEFINE   R_AMOUNT   val(substr(cStr,61,12) ) * .01
#DEFINE   R_UCOST    val(substr(cStr,73,12) ) *.01



// CLERK.RPT

#DEFINE   CLK_CODE     substr(cStr,1,6)
#DEFINE   CLK_NAME     substr(cStr,7,20)
#DEFINE   CLK_COUNT    val(substr(cStr,27,10)) *.01
#DEFINE   CLK_AMOUNT   val(substr(cStr,37,12)) *.01


// CCD.RPT

#DEFINE   BNK_CODE     substr(cStr,1,4)
#DEFINE   BNK_COUNT    val(substr(cStr,5,10)) 
#DEFINE   BNK_DENOM    val(substr(cStr,15,12)) *.01
#DEFINE   BNK_AMOUNT   val(substr(cStr,27,12)) *.01
