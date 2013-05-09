/*    TDL35.H - Header file containing declarations and messages
 *         for R3550 standard library
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
   MINIT_ERR - Error initializing FDK disk. */

enum retval  {
   NORMAL, NO_SCT, MODE_ERR, SEND_ERR, RECV_ERR, SAVE_ERR,
   BUSY_STS, INVP, ERRSF, MEM_OUT, NOT_FD, MINIT_ERR
};

/* PLU STRUCTURE DEFINITIONS */
typedef struct {
   char code [12];               /* PLU Code */
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

/* PLU in IMF - data structure */
typedef struct {
    char  code [12];
    char  desc [12];
    char  pbytes [16];       /* Refer to PLU/SD STATUS REFERENCE below */
    char  ass_dept [2];
    char  base_qty [2];
    char  unit_price [6];
    char  total [10];
    char  counter [8];
} PL0000;

/*  PLU/SD STATUS REFERENCE : (YES - '1' or NO - '0')
       pbytes [0]  = Rate 1 taxable
       pbytes [1]  = Rate 2 taxable
       pbytes [2]  = Rate 3 taxable
       pbytes [3]  = '0'
       pbytes [5], pbytes [4]
       ----------------------
                   = "00" : Normal PLU
                   = "01" : SDP
                   = "10" : Ass. GRF PLU
                   = "11" : Ass. GRF PLU
       pbytes [6]  = '0'
       pbytes [7]  = '0'
       pbytes [8]  = Data Capture
       pbytes [9]  = '0'
       pbytes [10] = Split PLU
       pbytes [11] = '0'
       pbytes [12] = Food stamp applicable
       pbytes [13] = Scale inhibit/compulsory
       pbytes [14] = '0'
       pbytes [15] = '0'
*/

/* PLU in EMF/BRC - data structure */
typedef struct {
    char  code [12];
    char  sub_code [2];
    char  counter [8];
    char  desc [16];
    char  pbytes [32];
    char  dummy1 [4];
    char  ass_dept [2];
    char  base_qty [2];
    char  unit_price [8];
    char  dummy2 [6];
} PL0016;                    /* 0 byte total  16 bytes descriptor */

typedef struct {
    char  code [12];
    char  sub_code [2];
    char  total [10];
    char  counter [8];
    char  desc [16];
    char  pbytes [32];
    char  dummy1 [4];
    char  ass_dept [2];
    char  base_qty [2];
    char  unit_price [8];
    char  dummy2 [6];
} PL1016;                    /* 10 byte total  16 bytes descriptor */

typedef struct {
    char  code [12];
    char  sub_code [2];
    char  counter [8];
    char  desc [24];
    char  pbytes [32];
    char  dummy1 [4];
    char  ass_dept [2];
    char  base_qty [2];
    char  unit_price [8];
    char  dummy2 [6];
} PL0024;                    /* 0 byte total  24 bytes descriptor */

typedef struct {
    char  code [12];         /* PLU/SD code */
    char  sub_code [2];      /* Subcode : "DD" - Normal PLU/SDP */
    char  total [10];        /* Total - "0000000000" */
    char  counter [8];       /* Counter - "00000000" */
    char  desc [24];         /* Descriptor */
    char  pbytes [32];       /* Refer to PLU/SD STATUS REFERENCE below */
    char  dummy1 [4];         /* Dummy - "0000" */
    char  ass_dept [2];      /* Associated dept code "01" to "48" */
    char  base_qty [2];      /* Base qty :
                                  - Bottle # for Bottle link PLU
                                  - "00" for other type of PLU */
    char  unit_price [8];    /* No decimal point (implicit) */
    char  dummy2 [6];        /* Dummy - "000000" */
} PL1024;                    /* 10 byte total  24 bytes descriptor */

/*  PLU/SD STATUS REFERENCE : (YES - '1' or NO - '0')
       pbytes [0]  = '0' : PLU or '1': SDP
       pbytes [2], pbytes [1]
       ----------------------
                   = "01" : Split PLU
                   = "11" : Associated GRF PLU
       pbytes [3]  = '0'
       pbytes [6], pbytes [5], pbytes [4]
       ----------------------------------
                   = "000" : Normal PLU
       pbytes [7]  = '0'
       pbytes [8]  = Rate 1 taxable
       pbytes [9]  = Rate 2 taxable
       pbytes [10] = Rate 3 taxable
       pbytes [11] = '0'
       pbytes [12] = '0'
       pbytes [13] = '0'
       pbytes [14] = '0'
       pbytes [15] = '0'
       pbytes [16] = '0'
       pbytes [17] = Food stamp applicable
       pbytes [18] = '0'
       pbytes [19] = '0'
       pbytes [20] = '0'
       pbytes [21] = '0'
       pbytes [22] = Data Capture
       pbytes [23] = '0'
       pbytes [24] = Scale inhibit/compulsory
       pbytes [25] = '0'
       pbytes [26] = '0'
       pbytes [27] = '0'
       pbytes [28] = '0'
       pbytes [29] = '0'
       pbytes [30] = '0'
       pbytes [31] = '0'
*/

/* Record Type : Cashier Report */
typedef struct {
    char knowncd[4];                 /* Cashier's Known Code */
    char secretcd[4];                /* Cashier's Secret Code */
    char cashmc[2];                  /* Cashier On Machine Status */
    char status[2];                  /* Cashier Status */
    char cashid;                     /* Cashier ID */
    char cashname[8];                /* Cashier Name */
    char tdaily[8];                  /* Department Daily Sales Total */
    char dcounter[4];                /* Department Daily Sales Counter */
    char cidtot[8];                  /* Cashier Cash In Drawer Total */
    char ccdtot[8];                  /* Cashier Cash Declaration Total */
    char ccdcount[4];                /* Cashier Cash Declaration Counter */
    char ttlcnt[15][12];             /* 8 bytes Total and 4 Bytes Count 
                                            - Media in Drawer 1
                                            - Media in Drawer 2
                                            - Media in Drawer 3
                                            - Media in Drawer 4
                                            - Media in Drawer 5
                                            - Media in Drawer 6
                                            - Paid Out
                                            - Received on Account
                                            - Void/EC
                                            - Refund
                                            - General Refund
                                            - DSI
                                            - MII
                                            - DSS
                                            - PSS                      */
    char dummy1[24];                 /* Dummy Data */
    char nscnt[4];                   /* No Sale Counter */
    char tvoid_ttl[8];               /* Transaction Void Total */
    char tvoid_cnt[4];               /* Transaction Void Counter */
    char dummy2[20];                 /* Dummy Data */
} FCASHREC;

/* PRIMARY FUNCTIONS */
int tdlinit(void);
void tdloff(void);

/* TERMINAL ACCESS FUNCTIONS */
int termrep(int, char, FILE *);
int ddaily(int, char, FILE *);
int ptdept(int, char, FILE *);
int deptgrp(int, char, int, FILE *);
int hourly(int, char, FILE *);
int vat(int, char, FILE *);
int dateset(int, char *);
int timeset(int,char *);
void mapterm(char *);
int termcpy(int, int, char *, char *);

/* PLU/SD FILE FUNCTIONS */
int plalc_e(int, int, char *);
int plmrg_e(int);
int pladd_e(int, void *);
int pldel_e(int, char *);
int plcng_e(int, void *);
int pldsc_e(int, char *, char *);
int plprc_e(int, char *, PLPRC *);
int plact_e(int, char *, int);
int plind_e(int, char *, PLDAT *);
int plrng_e(int, char, char *, char *, FILE *);
int plall_e(int, char, FILE *);
int pldmp_e(int, char *, char *, FILE *);
int pladd_i(int, void *);
int pldel_i(int, char *);
int plcng_i(int, void *);
int pldsc_i(int, char *, char *);
int plprc_i(int, char *, char *);
int plact_i(int, char *, int);
int plind_i(int, char *, PLDAT *);
int plrng_i(int, char, char *, char *, FILE *);
int plall_i(int, char, FILE *);
int pldmp_i(int, char *, char *, FILE *);

/* CASHIER FILE FUNCTIONS */
int floatc(int, char, int, FILE *);
int clerk(int, char, FILE *);

/* Floppy Disk Functions */
int cfclose(int);
int cfdread(int, FILE *);
int cfring(int, FILE *);
int minit(char,int,int,char *);

/* FILE in BRC FUNCTIONS */
void capture(FILE *);
int plusetup(FILE *, FILE *, unsigned long);
int csfsetup(unsigned int, FILE *);
int fcash(int, FCASHREC *, FILE *);
int tdlwait(void);

/* UTILITIES */
int holdup(int);
void release(int);