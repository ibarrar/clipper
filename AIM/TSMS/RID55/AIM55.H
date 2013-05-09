/* AIM55.H - System configuration data and low-level function  *
 *           declarations for AIM modules                      *
 *                                                EAR 09/21/89 *
 *                                                CMP 09/22/89 */

#define SCF "AIM55.SCF"       /* System control file name */
#define movminus(p) (p[2] == '-' || p[2] == '?') ? \
   (p[0] = '-', *(short *) (p+1) = 0x3030) : (*(short *) p = 0x3030)

enum addr_names  {            /* RAM address labels */
  CTZ1, PPTIME1, TLTMSL, TLZDPS, TLTX1, TLDYSL, TLNGAJ,
  WCASCDKN, WCASCDKB, TIMEPLU, PSMTX, WOJMPSTS, TLCLK
};

typedef struct  {             /* FILE CONTROL BLOCK */
   enum  {
      CENTR, DCENTR
   }  ftype;                  /* File type */
   enum  {
      EMF, IMF
   }  devtype;                /* Device type */
   union  {
      int iscn;               /* ISC number for centralized file */
      unsigned char isc[8];   /* ISC bit map for decentralized file */
   }  u;
}  FCB;

typedef struct mset_data  {
   unsigned char t_rate;      /* Transmission speed 0 - 187.5K, 1 - 90K */
   unsigned char dev_no;      /* ISC device number of TD85 card */
   unsigned char poll_tab[8]; /* Mode set polling table */
   unsigned char etc[4];      /* Filler */
   unsigned char port_num;    /* Communication port used - COM 1 or COM 2 */
}  MSET_DATA;

extern int load_flag;         /* Flag indicating whether loaded from file */

/* Structure of AIM Modules System Configuration file (RS5550) */
extern struct sct  {
   MSET_DATA tdl_mode;        /* Mode set data */
   unsigned char term[8];     /* ISC bit map of ECR Terminals */
   FCB pl_file;               /* File control block for main PLU/SD file */
   FCB cs_file;               /* File control block for Floating Cashier file */
   FCB nc_file;               /* File control block for Negative Check file */
   FCB pc_file;               /* File control block for Positive Check file */
   FCB cp_file;               /* File control block for Capturing file */
   int pt_file;               /* ISC device number for Temporary PLU/SD file */
   int cl_file;               /* ISC device number for Class file */
   int tc_file;               /* ISC device number for Tendered Check file */
   struct  {
      int main;               /* Device number of main EMF */
      int bup;                /* Device number of backup EMF */
   }  emf;
   unsigned char plu_class;   /* 1 - with class, 0 -  without class */
   unsigned char plu_type;    /* PLU Type:
                                 0 :  8-descriptor length,   0-total length
                                 1 :  8-descriptor length,  10-total length
                                 2 :  16-descriptor length,  0-total length
                                 3 :  16-descriptor length, 10-total length */
   struct  {                  /* RAM addresses for terminal access */
     char bank;
     short addr;
   } ram[13];
}  SCT;

/* Support functions from TDLIO2?.LIB */
char *fservinit(char *, int (*)(unsigned char *), char far *, char huge *);
                                          /* File server setup function */
int xmit(int, int (*)(void));             /* Transmit function */
int recv(void);                           /* Low level receive function */
void bcdtoa(char *, char *, int);         /* BCD to ASCII */
void atobcd(char *, char *, int);         /* ASCII to BCD */
void ascadd(char *, char *, int);         /* ASCII string addition */
char ask1(int);                           /* Ask if (S)kip, (R)etry, (A)bort */
int xconsldt(int, FCB *, int (*) (int));  /* Support function for consolidation */
extern unsigned char outdata[268];        /* Transmit data buffer */
extern unsigned char indata[268];         /* Receiver data buffer */
extern short asc_iscn[64];                /* ISC numbers in ASCII */