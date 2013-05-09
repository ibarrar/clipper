#define POSNO       substr(cStr,1,4)
#define DATES       substr(cStr,5,8)
#define TIMES       substr(cStr,13,8)           
#define TRANSNO     substr(cStr,21,8)           
#define CASH_CDE    substr(cStr,29,6)
#define PLUCODE     substr(cStr,35,14)
#define DEPTCODE    substr(cStr,49,4)

//#define SLSAMOUNT   val(substr(cStr,53,12))  * 0.01
#define SLSAMOUNT   substr(cStr,53,12)

#define QTTY        substr(cStr,65,8)

//#define UNIT_PRC    val(substr(cStr,73,8))   * 0.01
#define UNIT_PRC    substr(cStr,73,8)

#define EXCHRATE    val(substr(cStr,81,5))   * 0.01
//#define EXCHRATE    substr(cStr,81,5)

//#define ITEMCOST    val(substr(cStr,86,8))   * 0.01
#define ITEMCOST    substr(cStr,86,8)
#define TRQTY       val(substr(cStr,94,8))

//#define TRAMT       val(substr(cStr,102,12)) * 0.01
#define TRAMT       substr(cStr,102,12)
#define TRANSFLAG   substr(cStr,114,1)

#define DISCRATE    val(subs(cStr,115,3))
/*
#define TRQTY       val(substr(cStr,86,8))
#define TRAMT       val(substr(cStr,94,12))
#define TRANSFLAG   substr(cStr,106,1)
*/
