/* AIM35.H - System configuration data and low-level function  *
 *           declarations for AIM modules                      *
 *                                              MEZ  12/21/89  */

#define SCF "AIM35.SCF"       /* System control file name */
#define movminus(p) (p[2] == '-' || p[2] == '?') ? \
   (p[0] = '-', *(short *) (p+1) = 0x3030) : (*(short *) p = 0x3030)

enum addr_names  {            /* RAM address labels */
  TLTX1, TLDYSL, TLNGAJ, TAXRATE, TAXTL, SMBHOST, PMDATA, PMVAT,
  TLDNET, CONDEV, NUMREC, PMDESC, HCOM, FCTEMP, TLCLK, TAXTAB
};

typedef struct  {             /* FILE CONTROL BLOCK */
   enum  {
      CENTR, DCENTR
   }  ftype;                  /* File type */
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

/* Structure of AIM System Configuration Table (RS3510) */
extern struct sct  {
   MSET_DATA tdl_mode;        /* Mode set data */
   unsigned char term[8];     /* ISC bit map of ECR Terminals */
   int ple_file;              /* ISC device number for external PLU/SD file */
   FCB pli_file;              /* File control block for internal PLU/SD file */
   FCB cs_file;               /* File control block for Cashier File */
   int bcs_file;              /* ISC device number for Back Up Cashier File */
   int cp_file;               /* ISC device number of Capturing File device */
   unsigned char plu_type;    /* PLU Type:
                                 0 :  16-descriptor length,   0-total length
                                 1 :  16-descriptor length,  10-total length
                                 2 :  24-descriptor length,   0-total length
                                 3 :  24-descriptor length,  10-total length */
   struct  {                  /* RAM addresses for terminal access */
     char bank;
     short addr;
   } ram[16];
}  SCT;

/* Support functions from TDLIO2?.LIB */
int xmit(int, int (*)(void));             /* Transmit function */
char *fservinit(char *, int (*)(unsigned char *), char far *, char huge *);
                                          /* File server setup function */
int recv(void);                           /* Low level receive function */
void bcdtoa(char *, char *, int);         /* BCD to ASCII */
void atobcd(char *, char *, int);         /* ASCII to BCD */
void ascadd(char *, char *, int);         /* ASCII string addition */
int xconsldt(int, FCB *, int (*) (int));  /* Support function for consolidation */
extern unsigned char outdata[268];        /* Transmit data buffer */
extern unsigned char indata[268];         /* Receiver data buffer */
extern short asc_iscn[64];                /* ISC numbers in ASCII */