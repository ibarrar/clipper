/*    TDL55.H - Header file containing declarations and messages
 *         for RS5550 standard library
 *
 *    Copyright (c) 1989, OMRON Corporation. All rights reserved.  */

/* Return values correspond to the following situations:

   NORMAL    - TDL function performed normally;
   NO_SCT    - System control table not loaded;
   MODE_ERR  - Mode set error;
   SEND_ERR  - TDL transmit error;
   RECV_ERR  - TDL receive error;
   SAVE_ERR  - Disk write error;
   BUSY_STS  - TDL device is busy;
   INVP      - Invalid parameter;
   ERRSF     - Error reading source file;
   MEM_OUT   - BRC out of memory;
   NOT_FD    - Record not found;
   MINIT_ERR - Error initializing FDK disk;
   INDXC     - Index file not found or corrupted;
   ERR_WNDX  - Error writing index. */

enum retval  {
   NORMAL, NO_SCT, MODE_ERR, SEND_ERR, RECV_ERR, SAVE_ERR, BUSY_STS,
   INVP, ERRSF, MEM_OUT, NOT_FD, MINIT_ERR, INDXC, ERR_WNDX
};


/* PLU STRUCTURE DEFINITIONS */
typedef struct {
   char iscn [2];                /* ISC number */
   char code [12];               /* PLU Code */
   char sub_code [2];            /* Sub Code */
   char counter [10];            /* Counter */
   char total [12];              /* Total */
} PLDAT;

typedef struct {
    char  code [12];
    char  sub_code [2];
} PLKEY;

typedef struct {
   char  base_qty [2];      /* Base qty :
                                  - Bottle # for Bottle link PLU
                                  - "00" for other type of PLU */
   char  unit_price [8];    /* Unit price - No decimal point (implicit) */
} PLPRC;

typedef struct {
    char  code [12];
    char  sub_code [2];
    char  counter [8];
    char  desc [8];
    char  pbytes [32];
    char  dummy [2];
    char  ass_dept [4];
    char  base_qty [2];
    char  unit_price [8];
    char  mmcd [4];
    char  bdlk [2];
} PL0008;                    /* 0 byte total  8 bytes descriptor */

typedef struct {
    char  code [12];
    char  sub_code [2];
    char  total [10];
    char  counter [8];
    char  desc [8];
    char  pbytes [32];
    char  dummy [2];
    char  ass_dept [4];
    char  base_qty [2];
    char  unit_price [8];
    char  mmcd [4];
    char  bdlk [2];
} PL1008;                    /* 10 byte total  8 bytes descriptor */

typedef struct {
    char  code [12];
    char  sub_code [2];
    char  counter [8];
    char  desc [16];
    char  pbytes [32];
    char  dummy [2];
    char  ass_dept [4];
    char  base_qty [2];
    char  unit_price [8];
    char  mmcd [4];
    char  bdlk [2];
} PL0016;                    /* 0 byte total  16 bytes descriptor */

typedef struct {
    char  code [12];         /* PLU/SD code */
    char  sub_code [2];      /* Subcode :
                                  "DD" - Normal PLU/SDP 
                                  "nD" - Modified PLU (n = 1, 2, ..., 8)
                                  "Dm" - Time Price PLU (m = 0, 1, 2) */
    char  total [10];        /* Total - "0000000000" */
    char  counter [8];       /* Counter - "00000000" */
    char  desc [16];         /* Descriptor */
    char  pbytes [32];       /* Refer to PLU/SD STATUS REFERENCE below */
    char  dummy [2];         /* Dummy - "00" */
    char  ass_dept [4];      /* Associated dept code "0001" to "0099",
                                Class code "0001" to "9999",
                                Group number "0001" to "0099" */
    char  base_qty [2];      /* Base qty :
                                  - Bottle # for Bottle link PLU
                                  - "00" for other type of PLU */
    char  unit_price [8];    /* No decimal point (implicit) */
    char  mmcd [4];          /* Mix and match code */
    char  bdlk [2];          /* B.D. link */
} PL1016;                    /* 10 byte total  16 bytes descriptor */

/*  PLU/SD STATUS REFERENCE : (YES - '1' or NO - '0')
       pbytes [0]  = '0' : PLU or '1': SDP
       pbytes [2], pbytes [1]
       ----------------------
                   = "10" : Coupon PLU
                   = "11" : GRF PLU
       pbytes [3]  = '0'
       pbytes [6], pbytes [5], pbytes [4]
       ----------------------------------
                   = "000" : Normal PLU
                   = "001" : Modified PLU
                   = "010" : Time Price PLU
                   = "011" : Time Price PLU
                   = "100"
                   =   :   : Mix and Match PLU
                   = "111"
       pbytes [7]  = '0'
       pbytes [8]  = Rate 1 taxable
       pbytes [9]  = Rate 2 taxable
       pbytes [10] = Rate 3 taxable
       pbytes [11] = '0'
       pbytes [12] = '0'
       pbytes [13] = Non taxable
       pbytes [14] = Selective DSS applicable level 2
       pbytes [15] = '0'
       pbytes [16] = Selective DSS applicable level 1
       pbytes [17] = Food stamp applicable
       pbytes [18] = '0'
       pbytes [19] = '0'
       pbytes [20] = Net clerk total
       pbytes [21] = '0'
       pbytes [22] = Data Capture
       pbytes [23] = '0'
       pbytes [24] = Scale inhibit/compulsory
       pbytes [25] = Coupon key #1/#2
       pbytes [26] = Random weight PLU
       pbytes [27] = '0'
       pbytes [28] = Link to next PLU
       pbytes [29] = Inhibit registration in link
       pbytes [30] = '0'
       pbytes [31] = '0'
*/

/* CLASS FILE STRUCTURE DEFINITIONS */
typedef struct {
   char code [4];            /* Class code "0001" to "9999" */
   char total [12];          /* Total "000000000000" */
   char counter [4];         /* Counter "0000" */
   char desc [12];           /* Class descriptor */
   char ass_dept [4];        /* Associated department code */
} CLASSREC;

typedef struct {
   char iscn [2];            /* ISC number */
   char code [4];            /* Class code */
   char counter [6];         /* Counter */
   char total [14];          /* Totals */
   char dept[2];	     /* Associated department code : Modified */
} CLDAT;


/* RECORD TYPES : MIX AND MATCH TABLE PROGRAMMING */
typedef struct {
    char table[4];                /* Table Number - "0001" to "0999" */
    char base[2];                 /* Base Quantity - "01" to "99" */
    char pprice[6];               /* Package Price - "000001" to "999999" */
    char iprice[6];               /* Item Price - "000001" to "999999" */
    char  sp;                     /* Pricing Method */
} MIXTAB;


/* POSITIVE CHECK FILE STRUCTURE DEFINITIONS */
typedef struct {
   char accno [8];           /* Account number */
   char desc [12];           /* Description */
   char b_bop [8];           /* Bal Bop */
   char purch [8];           /* Purchase */
   char p_ctr [4];           /* Purchase counter */
   char pay [8];             /* Payment */
   char c_lim [6];           /* Credit limit */
   char stat [2];            /* Status */
} PCDATA;


/* DEPARTMENT FILE STRUCTURE DEFINITIONS */
typedef struct {
    char code [4];           /* Department Code from "0001" to "0099" */
    char desc [8];           /* Department Descriptor */
    char pbytes [24];        /* Refer to DEPARTMENT STATUS REFERENCE below */
    char grpno [2];          /* Group Number from "01" to "99" */
    char limit [2];          /* Amount Entry Limit (XY)
                                   X : First digit
                                   Y : Number of zeroes  Ex. 45 = $4000.00 */
}  DDATA;

typedef struct  {
    char iscn [2];           /* ISC Number */
    char code [4];           /* Department Code */
    char dtotal [12];        /* Daily Total */
    char dccount [6];        /* Daily Customer Count */
    char dicount [6];        /* Daily Item Count */
    struct  {
        char total [12];     /* Negative Tracking Total */
        char count [6];      /* Negative Tracking Count */
    }  negative [4];
} DEPTDAT;

/*  DEPARTMENT STATUS REFERENCE : (YES - '1' or NO - '0')
       pbytes [0]  = Rate1 taxable
       pbytes [1]  = Rate2 taxable
       pbytes [2]  = Rate3 taxable
       pbytes [3]  = '0'
       pbytes [4]  = Non taxable
       pbytes [5]  = pbytes [6] = pbytes [7] = '0'
       pbytes [8]  = Capture
       pbytes [9]  = Allow with scale
       pbytes [10] = Journal skip
       pbytes [11] = '0'
       pbytes [12] = Selective DSS applicable level 2
       pbytes [13] = Slip validation compulsory
       pbytes [14] = R/J validation compulsory
       pbytes [15] = '0'
       pbytes [16] = Selective DSS applicable level 1
       pbytes [17] = Food stamp applicable
       pbytes [18] = Net clerk total
       pbytes [19] = '0'
       pbytes [20] = Single item cash
       pbytes [21] = Art # compulsory
       pbytes [22] = '0'
       pbytes [23] = '0'   */

/* Time Price Data Structure */
typedef struct {
    char day[7];
    char start[4];
    char stop[4];
    int level;
} TIMEP;

/* ERROR LOGGING FILE STRUCTURE DEFINITION */
typedef struct {
  char iscn [2];        /* ISC number */
  char date [6];        /* Date - YYMMDD */
  char day [2];         /* Refer to R-A */
  char time [6];        /* Time - HHMMSS */
  char status [2];      /* Refer to R-B */
  char errcode [2];     /* Refer to R-C */
} ELDAT;

/*  ERROR LOGGING FILE REFERENCE :
    R-A :
        Week - "00" : Monday
             - "01" : Tuesday
                :
             - "06" : Sunday

    R-B :
        Status - "01" : Command processing error
               - "03" : File inhibit flag on
               - "43" : Error during CLOSE switch processing
    R-C :
        Error code -
             - "11" : File not found
             - "12" : File already exist
             - "13" : REC POS or file counter over
             - "14" : REC already exist
             - "15" : Write data error
             - "16" : File overflow ADR
             - "17" : KCNT (RCNT) over
             - "18" : REC ADR over
             - "19" : CMP code format error
             - "1A" : Command not found
             - "1B" : Record not found
             - "1C" : EMF load EOR
             - "1D" : Header format error
             - "21" : File-inhibited file access error
             - "22" : Memory error (header)
             - "23" : Memory error (data sect.)
             - "31" : File Type error
             - "32" : Procedure error
             - "41" : Memory over flow error
             - "81" : Send length over
             - "82" : IOCS error
             - "AX" : Header write data error
             - "B1" : Transmit error
             - "C1" : Time out error
             - "B4" : HBL down
             - "FD" : FD error
             - "B5" : Sleep
             - "D1" : DIP switch error
             - "B6" : HBL load/dump error   */

/* PRIMARY FUNCTIONS */
int tdlinit(void);
void tdloff(void);

/* TERMINAL ACCESS FUNCTIONS */
int termrep(int, char, FILE *);
int deptset(int, DDATA *);
int deptinf(int, void *);
int deptall(int, char, FILE *);
int deptgrp (int iscn, char mode, int grp_no, FILE *save_file);
int deptind(int, char, char *, DEPTDAT *);
int deptact(int, char *, int);
int mix55(int, MIXTAB *);
int time55(int, TIMEP *);
int hourly(int, char, FILE *);

/* PLU/SD FILE FUNCTIONS */
int plalloc(int, int);
int pladd(int, void *);
int plchange(int, void *);
int plprice(int, PLKEY *, PLPRC *);
int pldel(int, PLKEY *);
int plact(int, PLKEY *, int);
int plmerge(int);
int plrange(int, char, char *, char *, FILE *);
int plall(int, char, FILE *);
int plind(int, char *, PLDAT *);
int plnf(int, char, FILE *);
int pldmp(int, char *, char *, FILE *);

/* CLASS FILE FUNCTIONS */
int clalloc(int, int);
int cladd(int, CLASSREC *);
int cldel(int, char *);
int clchange(int, CLASSREC *);
int clind(int, char *, CLDAT *);
int clrange(int, char, char *, char *, FILE *);
int clall(int, char, FILE *);

int lcashrep (int iscn, char mde, char cash_no, FILE *save_file);

/* POSITIVE CHECK FUNCTIONS */
int pcalloc(int, int);
int pcadd(int, PCDATA *);
int pcdel(int, char *);
int pcchange(int, PCDATA *);
int pcind(int, char *, PCDATA *);
int pcall(int, char, FILE *);

/* NCF FUNCTIONS */
int ncfread(int, int, FILE *);
int ncfadd(int, int, char *, char *);
int ncfdel(int, int, char *);
int ncfalloc(int,int,int);

/* CASHIER FILE FUNCTIONS */
int cashadd(int, char *, int);
int cashsp(int, char *, char *, int);
int cashscd(int, char *, int);
int cashdel(int, char *, char *, int);
int cashid(int, char, char *, char *);
int cassign(int, char *, int);
int cdisass(int, char *);
int csiread(int, char *, FILE *);
int csaread(int, FILE *);
int csindrep(int, char, int, char *, FILE *);
int csallrep(int, char, int, FILE *);
int csiszrep(int, char *, FILE *);
int csaszrep(int, FILE *);

/* TENDERED CHECK FILE FUNCTIONS */
int tcalloc(int, int);
int tcindrep(int, char, char *, FILE *);
int tcallrep(int, char, FILE *);

/* CAPTURING FILE FUNCTIONS */
void capture(FILE *);
int cfclose(int);
int cfdread(int,FILE *);
int cfring(int, FILE *);
int minit(char, int, int, char *);

/* FILE SERVER FUNCTIONS */
void capture(FILE *);
int ncfsetup(int, int, FILE *, unsigned int);
int plusetup(FILE *, FILE *, unsigned long);
int csfsetup(int, int, FILE *);
int clsetup(FILE *, FILE *, int);
int pcfsetup(FILE *, unsigned int);
int tdlwait(void);
int cpalloc ( int iscn, int fsize );

/* UTILITIES */
int emfbup(int);
int emfrest(int);
int elset(int);
int elread(int, ELDAT *);
int devchk(int, char *);
int holdup(int);
int release(int);
int timeset(int iscn, char *timstr);
int dateset(int iscn, char *datstr);
int flushcp ( int iscn );
int getcash (int iscn, char *save_buffer );
