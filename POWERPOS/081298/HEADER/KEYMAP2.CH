#define CONFIG_KEY_LEN      140

#define KEY_ZERO        1
#define KEY_ONE         2
#define KEY_TWO         3
#define KEY_THREE       4
#define KEY_FOUR        5
#define KEY_FIVE        6
#define KEY_SIX         7
#define KEY_SEVEN       8
#define KEY_EIGHT       9
#define KEY_NINE        10
#define KEY_TWOZ        11
#define KEY_PERIOD      12
#define KEY_CASHIER     13
#define KEY_CLK         14
#define KEY_PLU         15
#define KEY_QTY         16
#define KEY_CLEAR       17
#define KEY_ENTER       18
#define KEY_SUBTOTAL    19
#define KEY_CASH        20
#define KEY_CVOID       21
#define KEY_MVOID       22
#define KEY_REC         23
#define KEY_JOUR        24
#define KEY_SLIP        25
#define KEY_DISC        26
#define KEY_SSDISC      27
#define KEY_VALID       28
#define KEY_SUSPEND     29
#define KEY_RESUME      30
#define KEY_CUSTDEP     31
#define KEY_RET_EXC     32
#define KEY_UP          33
#define KEY_DOWN        34
#define KEY_IPCT_DISC   35
#define KEY_SPCT_DISC   36
#define KEY_IAMT_DISC   37
#define KEY_SAMT_DISC   38
#define KEY_SPCT_ADDN   39
#define KEY_IAMT_ADDN   40
#define KEY_SAMT_ADDN   41
#define KEY_ITMREFUND   42
#define KEY_ERRCORR     43
#define KEY_TRANSCAN    44
#define KEY_SUB_DEPT    45
#define KEY_MISC_1      46
#define KEY_MISC_2      47
#define KEY_MISC_3      48
#define KEY_MISC_4      49
#define KEY_MISC_5      50
#define KEY_MISC_6      51
#define KEY_MISC_7      52
#define KEY_MISC_8      53
#define KEY_MISC_9      54
#define KEY_MISC_10     55
#define KEY_MISC_11     56
#define KEY_MISC_12     57
#define KEY_MISC_13     58
#define KEY_MISC_14     59
#define KEY_MISC_15     60
#define KEY_MISC_16     61
#define KEY_MISC_17     62
#define KEY_MISC_18     63
#define KEY_MISC_19     64
#define KEY_MISC_20     65
#define KEY_MISC        66
#define KEY_DEPT_1      67
#define KEY_DEPT_2      68
#define KEY_DEPT_3      69      
#define KEY_DEPT_4      70
#define KEY_DEPT_5      71
#define KEY_DEPT_6      72
#define KEY_DEPT_7      73
#define KEY_DEPT_8      74      
#define KEY_DEPT_9      75
#define KEY_DEPT_10     76
#define KEY_DEPT_11     77
#define KEY_DEPT_12     78
#define KEY_DEPT_13     79
#define KEY_DEPT_14     80
#define KEY_DEPT_15     81
#define KEY_DEPT_16     82
#define KEY_DEPT_17     83
#define KEY_DEPT_18     84
#define KEY_DEPT_19     85
#define KEY_DEPT_20     86
#define KEY_DEPT_21     87 
#define KEY_DEPT_22     88
#define KEY_DEPT_23     89
#define KEY_DEPT_24     90
#define KEY_DEPT_25     91
#define KEY_DEPT_26     92
#define KEY_DEPT_27     93 
#define KEY_DEPT_28     94 
#define KEY_DEPT_29     95 
#define KEY_DEPT_30     96 
#define KEY_A           97                    
#define KEY_B           98 
#define KEY_C           99  
#define KEY_D           100
#define KEY_E           101
#define KEY_F           102
#define KEY_G           103
#define KEY_H           104
#define KEY_I           105
#define KEY_J           106
#define KEY_K           107
#define KEY_L           108
#define KEY_M           109
#define KEY_N           110
#define KEY_O           111
#define KEY_P           112
#define KEY_Q           113
#define KEY_R           114
#define KEY_S           115
#define KEY_T           116
#define KEY_U           117
#define KEY_V           118
#define KEY_W           119
#define KEY_X           120
#define KEY_Y           121
#define KEY_Z           122
#define KEY_ESC_DOS     123
#define KEY_NO_SALE     124 
#define KEY_BACK_SP     125
#define KEY_NON_ADD     126
#define KEY_OTH_INC     127
#define KEY_TRAN_VOID   128
#define KEY_PICK_UP     129
#define KEY_PAID_OUT    130
#define KEY_LOAN        131
#define KEY_RE_PRINT    132
#define KEY_GENREFUND   133 
#define KEY_PRICE_ADJ   134
#define KEY_SPACE       135   
#define KEY_CASH_ID     136
#define KEY_PRC_LEVEL   137
#define KEY_PO	         138
#define KEY_PESO        139
#define KEY_USD         140
      
#define CONFIG_KEY_LINES   { ;
/*           001  */         "ZERO",;
/*           002  */         "ONE",;
/*           003  */         "TWO",;
/*           004  */         "THREE",;
/*           005  */         "FOUR",;
/*           006  */         "FIVE",;
/*           007  */         "SIX",;
/*           008  */         "SEVEN",;
/*           009  */         "EIGHT",;
/*           010  */         "NINE",;
/*           011  */         "TWO_ZEROES",;
/*           012  */         "PERIOD",;
/*           013  */         "CASHIER",;
/*           014  */         "CLERK",;
/*           015  */         "PLU KEY",;
/*           016  */         "QUANTITY",;
/*           017  */         "CLEAR",;
/*           018  */         "ENTER",;
/*           019  */         "SUBTOTAL",;
/*           020  */         "CASH",;
/*           021  */         "CASHIER'S VOID",;
/*           022  */         "MANAGER'S VOID",;
/*           023  */         "TO RECEIPT PRINTER",;
/*           024  */         "TO JOURNAL PRINTER",;
/*           025  */         "TO INTERNAL SLIP PRINTER",;
/*           026  */         "DISCOUNT",;
/*           027  */         "SELECTIVE SUBTOTAL DISCOUNT",;
/*           028  */         "VALIDATE",;
/*           029  */         "SUSPEND",;
/*           030  */         "RESUME",;
/*           031  */         "CUSTOMER DEPOSIT",;
/*           032  */         "RETURN EXCHANGE",;
/*           033  */         "UP",;
/*           034  */         "DOWN",;
/*           035  */         "IPCT_DISC",;
/*           036  */         "SPCT_DISC",;
/*           037  */         "IAMT_DISC",;
/*           038  */         "SAMT_DISC",;
/*           039  */         "SPCT_ADDN",;
/*           040  */         "IAMT_ADDN",;
/*           041  */         "SAMT_ADDN",;
/*           042  */         "REFUND",;
/*           043  */         "ERRCORR",;
/*           044  */         "TRANSCAN",;
/*           045  */         "SUB_DEPT",;
/*           046  */         "MISC_1",;
/*           047  */         "MISC_2",;
/*           048  */         "MISC_3",;
/*           049  */         "MISC_4",;
/*           050  */         "MISC_5",;
/*           051  */         "MISC_6",;
/*           052  */         "MISC_7",;
/*           053  */         "MISC_8",;
/*           054  */         "MISC_9",;
/*           055  */         "MISC_10",;
/*           056  */         "MISC_11",;
/*           057  */         "MISC_12",;
/*           058  */         "MISC_13",;
/*           059  */         "MISC_14",;
/*           060  */         "MISC_15",;
/*           061  */         "MISC_16",;
/*           062  */         "MISC_17",;
/*           063  */         "MISC_18",;
/*           064  */         "MISC_19",;
/*           065  */         "MISC_20",;
/*           066  */         "MISC_KEY",;
/*           067  */         "DEPT_1",;
/*           068  */         "DEPT_2",;
/*           069  */         "DEPT_3",;
/*           070  */         "DEPT_4",;
/*           071  */         "DEPT_5",;
/*           072  */         "DEPT_6",;
/*           073  */         "DEPT_7",;
/*           074  */         "DEPT_8",;
/*           075  */         "DEPT_9",;
/*           076  */         "DEPT_10",;
/*           077  */         "DEPT_11",;
/*           078  */         "DEPT_12",;
/*           079  */         "DEPT_13",;
/*           080  */         "DEPT_14",;
/*           081  */         "DEPT_15",;
/*           082  */         "DEPT_16",;
/*           083  */         "DEPT_17",;
/*           084  */         "DEPT_18",;
/*           085  */         "DEPT_19",;
/*           086  */         "DEPT_20",;
/*           087  */         "DEPT_21",;
/*           088  */         "DEPT_22",;
/*           089  */         "DEPT_23",;
/*           090  */         "DEPT_24",;
/*           091  */         "DEPT_25",;
/*           092  */         "DEPT_26",;
/*           093  */         "DEPT_27",;
/*           094  */         "DEPT_28",;
/*           095  */         "DEPT_29",;
/*           096  */         "DEPT_30",;
/*           097  */         "LETTER_A",;
/*           098  */         "LETTER_B",;
/*           099  */         "LETTER_C",;
/*           100  */         "LETTER_D",;
/*           101  */         "LETTER_E",;
/*           102  */         "LETTER_F",;
/*           103  */         "LETTER_G",;
/*           104  */         "LETTER_H",;
/*           105  */         "LETTER_I",;
/*           106  */         "LETTER_J",;
/*           107  */         "LETTER_K",;
/*           108  */         "LETTER_L",;
/*           109  */         "LETTER_M",;
/*           110  */         "LETTER_N",;
/*           111  */         "LETTER_O",;
/*           112  */         "LETTER_P",;
/*           113  */         "LETTER_Q",;
/*           114  */         "LETTER_R",;
/*           115  */         "LETTER_S",;
/*           116  */         "LETTER_T",;
/*           117  */         "LETTER_U",;
/*           118  */         "LETTER_V",;
/*           119  */         "LETTER_W",;
/*           120  */         "LETTER_X",;
/*           121  */         "LETTER_Y",;
/*           122  */         "LETTER_Z",;
/*           123  */         "ESC_DOS",;
/*           124  */         "NO_SALE",;
/*           125  */         "BACK_SPACE",;
/*           126  */         "NON_ADD" ,;
/*           127  */         "OTH_INC" , ;
/*           128  */         "TRAN_VOID",;
/*           129  */         "PICK_UP"   ,;
/*           130  */         "PAID_OUT"  ,;
/*           131  */         "LOAN"      ,;
/*           132  */         "REPRINT_BILL",;
/*           133  */         "GENREFUND"   ,; 
/*           134  */         "PRICE_ADJUST",;
/*           135  */         "LETTER_SPACE",;
/*           136  */         "CASH_IN_DRAWER",;    
/*           137  */         "PLEVEL",;
/*           138  */         "PO_KEY",;
/*           139  */         "PESO_KEY",;
/*           140  */         "USD_KEY"  } 
