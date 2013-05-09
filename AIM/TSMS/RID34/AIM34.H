/* AIM34.H - System configuration data and low-level function  *
 *           declarations for AIM modules                      *
 *                                              MEZ  12/21/89  *
 *                                              ETC  07/29/92  */

#ifndef SCF
#define SCF "AIM34.SCF"       /* System control file name */
#define movminus(p) (p[2] == '-' || p[2] == '?') ? \
   (p[0] = '-', *(short *) (p+1) = 0x3030) : (*(short *) p = 0x3030)
#define HIBYTE(a) (char) ((unsigned)(a) >> 8)
#define LOBYTE(a) (char) ((a) & 0xff)

#define WCASNO   0x1B79
enum addr_names  {            /* RAM address labels */
  TLGR, TLMDSL5, TLTXSL7, TLNETGT, PBPRTTX1, TLTXSL1, PSBSTAT, PPBSTAT,
  PBPSET, PSTMSTAT, PSDVSTAT, PSNSSTAT, PALDSTOP, PPHTOP, PPTSTAT, PPVLSTAT
};

/* Enumeration constants for Device and File types */
enum dvce_types { EMF, IMF };
enum file_types { CENTR, DCENTR };

typedef struct  {             /* FILE CONTROL BLOCK */
   enum file_types ftype;     /* File type */
   enum dvce_types devtype;   /* Device type */
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

/* Structure of AIM System Configuration Table (RS3460) */
struct sct {
   MSET_DATA tdl_mode;        /* Mode set data */
   unsigned char term[8];     /* ISC bit map of ECR Terminals */
   FCB pl_file;               /* File control block for main PLU/SD file */
   FCB cs_file;               /* File control block for Cashier File */
   int bcs_file;              /* ISC device number for Back Up Cashier File */
   int cp_file;               /* ISC device number of Capturing File device */
   unsigned char plu_link;    /* 1 : link PLU system, 0 : not link PLU system */
   unsigned char plu_type;    /* PLU Type:
                                 0 :  16-descriptor length,   0-total length
                                 1 :  16-descriptor length,  10-total length
                                 2 :  24-descriptor length,   0-total length
                                 3 :  24-descriptor length,  10-total length */
   struct  {                  /* RAM addresses for terminal access */
     char bank;
     short addr;
   } ram[16];
};
extern struct sct SCT;
extern int load_flag;         /* Flag indicating whether loaded from file */

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
extern short asc_iscn[64];                /* ISC numbers in ASCII */
void delay(unsigned int);
int gettms(int, char *);
#endif
