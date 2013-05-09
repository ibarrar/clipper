/* Cashier Header File :cashier.ch */

#define  CASH_CODE_LEN   6
#define  CASH_NAME_LEN   20
#define  CASH_TIME1_LEN  6 
#define  CASH_TIME2_LEN  6
#define  CASH_POSNO_LEN  4
#define  CASH_RSRVD_LEN  1

#define  CASH_CODE_OFF   1
#define  CASH_NAME_OFF   CASH_CODE_OFF + CASH_CODE_LEN
#define  CASH_TIME1_OFF  CASH_NAME_OFF + CASH_NAME_LEN
#define  CASH_TIME2_OFF  CASH_TIME1_OFF + CASH_TIME1_LEN
#define  CASH_POSNO_OFF  CASH_TIME2_OFF + CASH_TIME2_LEN
#define  CASH_RSRVD_OFF  CASH_POSNO_OFF + CASH_POSNO_LEN

#define  CASHIER_SIZE  (CASH_RSRVD_OFF + CASH_RSRVD_LEN - CASH_CODE_OFF) + 2

#define  CS_CODE_LEN    3
#define  CS_SECR_LEN    3
#define  CS_NAME_LEN   20 
#define  CS_TERM_LEN    4
#define  CS_TMIN_LEN    6
#define  CS_TOUT_LEN    6
#define  CS_DATA_LEN    (CS_FIELD_KNT * 8)

#define  CS_CODE_OFF   1
#define  CS_SECR_OFF   CS_CODE_OFF + CS_CODE_LEN 
#define  CS_NAME_OFF   CS_SECR_OFF + CS_SECR_LEN 
#define  CS_TERM_OFF   CS_NAME_OFF + CS_NAME_LEN 
#define  CS_TMIN_OFF   CS_TERM_OFF + CS_TERM_LEN 
#define  CS_TOUT_OFF   CS_TMIN_OFF + CS_TMIN_LEN 
#define  CS_DATA_OFF   CS_TOUT_OFF + CS_TOUT_LEN

#define  LOCAL_CASH_SIZE  CS_DATA_OFF + CS_DATA_LEN - CS_CODE_OFF

#define  CS_DSLS_TOT    1
#define  CS_DSLS_KNT    2
#define  CS_CASH_TOT    3
#define  CS_DEPT_TOT    4
#define  CS_FCUR_TOT    5
#define  CS_FCUR_KNT    6
#define  CS_MC01_TOT    7
#define  CS_MC01_KNT    8
#define  CS_MC02_TOT    9
#define  CS_MC02_KNT   10
#define  CS_MC03_TOT   11 
#define  CS_MC03_KNT   12 
#define  CS_MC04_TOT   13 
#define  CS_MC04_KNT   14 
#define  CS_MC05_TOT   15 
#define  CS_MC05_KNT   16 
#define  CS_MC06_TOT   17 
#define  CS_MC06_KNT   18 
#define  CS_MC07_TOT   19 
#define  CS_MC07_KNT   20 
#define  CS_MC08_TOT   21 
#define  CS_MC08_KNT   22 
#define  CS_MC09_TOT   23 
#define  CS_MC09_KNT   24 
#define  CS_MC10_TOT   25 
#define  CS_MC10_KNT   26 
#define  CS_MC11_TOT   27 
#define  CS_MC11_KNT   28 
#define  CS_MC12_TOT   29 
#define  CS_MC12_KNT   30 
#define  CS_MC13_TOT   31 
#define  CS_MC13_KNT   32 
#define  CS_MC14_TOT   33 
#define  CS_MC14_KNT   34 
#define  CS_MC15_TOT   35 

#define  CS_MC15_KNT   36 
#define  CS_MC16_TOT   37 
#define  CS_MC16_KNT   38 
#define  CS_MC17_TOT   39 
#define  CS_MC17_KNT   40 
#define  CS_MC18_TOT   41 
#define  CS_MC18_KNT   42 
#define  CS_MC19_TOT   43 
#define  CS_MC19_KNT   44 
#define  CS_MC20_TOT   45 
#define  CS_MC20_KNT   46 

#define  CS_MC21_TOT   47 
#define  CS_MC21_KNT   48 
#define  CS_MC22_TOT   49 
#define  CS_MC22_KNT   50 
#define  CS_MC23_TOT   51 
#define  CS_MC23_KNT   52 
#define  CS_MC24_TOT   53 
#define  CS_MC24_KNT   54 
#define  CS_MC25_TOT   55 
#define  CS_MC25_KNT   56 
#define  CS_MC26_TOT   57 
#define  CS_MC26_KNT   58 
#define  CS_MC27_TOT   59 
#define  CS_MC27_KNT   60 
#define  CS_MC28_TOT   61 
#define  CS_MC28_KNT   62 
#define  CS_MC29_TOT   63 
#define  CS_MC29_KNT   64 
#define  CS_MC30_TOT   65 
#define  CS_MC30_KNT   66 
#define  CS_MC31_TOT   67 
#define  CS_MC31_KNT   68 
#define  CS_MC32_TOT   69 
#define  CS_MC32_KNT   70 
#define  CS_MC33_TOT   71 
#define  CS_MC33_KNT   72 
#define  CS_MC34_TOT   73 
#define  CS_MC34_KNT   74 
#define  CS_MC35_TOT   75 
#define  CS_MC35_KNT   76 
#define  CS_MC36_TOT   77 
#define  CS_MC36_KNT   78 
#define  CS_MC37_TOT   79 
#define  CS_MC37_KNT   80 
#define  CS_MC38_TOT   81 
#define  CS_MC38_KNT   82 
#define  CS_MC39_TOT   83 
#define  CS_MC39_KNT   84 
#define  CS_MC40_TOT   85 
#define  CS_MC40_KNT   86 
#define  CS_MC41_TOT   87
#define  CS_MC41_KNT   88 
#define  CS_MC42_TOT   89 
#define  CS_MC42_KNT   90 
#define  CS_MC43_TOT   91 
#define  CS_MC43_KNT   92 
#define  CS_MC44_TOT   93 
#define  CS_MC44_KNT   94 
#define  CS_MC45_TOT   95 
#define  CS_MC45_KNT   96 
#define  CS_MC46_TOT   97 
#define  CS_MC46_KNT   98
#define  CS_MC47_TOT   99 
#define  CS_MC47_KNT  100 
#define  CS_MC48_TOT  101 
#define  CS_MC48_KNT  102 
#define  CS_MC49_TOT  103 
#define  CS_MC49_KNT  104 
#define  CS_MC50_TOT  105 
#define  CS_MC50_KNT  106 


#define  CS_VOID_TOT  107 
#define  CS_VOID_KNT  108 
#define  CS_MGRV_TOT  109 
#define  CS_MGRV_KNT  110 
#define  CS_IDSC_TOT  111 
#define  CS_IDSC_KNT  112 
#define  CS_SDSC_TOT  113 
#define  CS_SDSC_KNT  114 
#define  CS_ADON_TOT  115 
#define  CS_ADON_KNT  116 
#define  CS_SESD_TOT  117 
#define  CS_SESD_KNT  118 
#define  CS_SADO_TOT  119 
#define  CS_SADO_KNT  120 
#define  CS_REXC_TOT  121 
#define  CS_REXC_KNT  122 
#define  CS_RFND_TOT  123 
#define  CS_RFND_KNT  124 
#define  CS_OINC_TOT  125 
#define  CS_OINC_KNT  126 
#define  CS_TRCL_TOT  127 
#define  CS_TRCL_KNT  128 
#define  CS_TRVD_TOT  129 
#define  CS_TRVD_KNT  130 
#define  CS_TRSU_TOT  131 
#define  CS_TRSU_KNT  132 
#define  CS_LAYA_TOT  133 
#define  CS_LAYA_KNT  134 
#define  CS_PKUP_TOT  135 
#define  CS_PKUP_KNT  136 
#define  CS_PDOT_TOT  137 
#define  CS_PDOT_KNT  138 
#define  CS_LOAN_TOT  139 
#define  CS_LOAN_KNT  140 
#define  CS_RONA_TOT  141 
#define  CS_RONA_KNT  142 
#define  CS_BOTD_TOT  143 
#define  CS_BOTD_KNT  144 
#define  CS_OFFL_TOT  145        // Not used 
#define  CS_OFFL_KNT  146        // not used

#define  CS_CIDR_TOT  147        // Cash declaration
#define  CS_TRNG_TOT  148        // training total
#define  CS_REEN_TOT  149 
#define  CS_OLDG_TOT  150 
#define  CS_NEWG_TOT  151 
#define  CS_XCTR_TOT  152 
#define  CS_ZCTR_TOT  153 
#define  CS_SCAN_TOT  154        // Scan sales
#define  CS_SCAN_KNT  155        // count
#define  CS_DUTY_TIM  156        // Total duty time
#define  CS_ATRN_TIM  157        // Actual transaction time..

