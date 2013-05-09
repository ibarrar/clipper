/**************************************************************
*
* BLINKER.H     93.10.10
*
* Blinker 3.0 function header for C
*
* Copyright (C) ASM Inc, 1992, 1993
*
***************************************************************/

/* prototypes */

#ifdef __cplusplus
   // prevent name mangling for C++
   extern "C" {
#endif

unsigned      far BLICUROVL(void);
unsigned      far BLICURSIZ(void);
unsigned      far BLIDBGHAN(unsigned);
unsigned      far BLIDEMCAL(unsigned);
char far *    far BLIDEMDTE(void);
unsigned      far BLIDEMMIN(unsigned);
void          far BLIDISTRC(unsigned);
unsigned      far BLIERRNUM(void);
char far *    far BLIERRPRM(void);
unsigned long far BLIMGRSTS(unsigned);
unsigned long far BLIOVLOPS(void);
void          far BLIOVLRES(void);
unsigned long far BLIOVLSIZ(void);
void          far BLIOVLSUS(unsigned);
char far *    far BLISERNUM(void);
unsigned      far BLITOTACT(void);
unsigned      far BLITOTLOD(void);
unsigned      far BLITOTSIZ(void);
unsigned      far BLIVERNUM(void);

unsigned      far SWPADDENV(unsigned);
unsigned      far SWPADDSTR(char far *, char far *);
unsigned      far SWPCURDIR(unsigned);
unsigned      far SWPDISMSG(unsigned);
unsigned      far SWPEMS320(unsigned);
unsigned      far SWPERRLEV(void);
unsigned      far SWPERRMAJ(void);
unsigned      far SWPERRMIN(void);
unsigned      far SWPFREEMS(unsigned);
unsigned      far SWPFREXMS(unsigned);
unsigned      far SWPGETKEY(unsigned);
unsigned      far SWPGETPID(char far *);
char far *    far SWPGETSTR(void);
unsigned      far SWPKEYBRD(char far *);
unsigned      far SWPKEYCLR(unsigned);
unsigned      far SWPNOBOOT(unsigned);
unsigned      far SWPRUNCMD(char far *, unsigned, char far *, char far *);
unsigned      far SWPSETENV(char far *);
unsigned      far SWPSETPID(char far *);
unsigned      far SWPSETSTR(char far *, char far *);
unsigned      far SWPUSEEMS(unsigned);
unsigned      far SWPUSEUMB(unsigned);
unsigned      far SWPUSEXMS(unsigned);
unsigned      far SWPVIDMDE(unsigned);

#ifdef __cplusplus
   }
#endif

/* Function numbers for BLIMGRSTS */

#define BliCacheLoc     1                  /* Get overlay cache location */
#define BliCacheSize    2                  /* Get overlay cache size */
#define BliExtMemAvail  3                  /* Get extended memory available */
#define BliHostMode     4                  /* Get host mode */
#define BliMachineMode  5                  /* Get machine mode */
#define BliOverlayLoc   6                  /* Get overlay area location */
#define BliOverlaySize  7                  /* Get overlay area size */
#define BliRealMemAvail 8                  /* Get real memory available */
#define BliVirMemAvail  9                  /* Get virtual memory available */


/* Cache locations for BLIMGRSTS */

#define BliCacheNone    0                  /* No overlay cache */
#define BliCacheEMS     1                  /* Overlay cache is in EMS */
#define BliCacheXMS     2                  /* Overlay cache is in XMS */


/* Host modes for DosGetHostMode and BLIMGRSTS */

#ifndef BliHostNone

#define BliHostNone     0
#define BliHostDPMI     1
#define BliHostVCPI     2
#define BliHostXMS      3

#endif


/* Processor modes for DosGetMachineMode and BLIMGRSTS */

#ifndef BliModeReal

#define BliModeReal     0
#define BliModeProt     1

#endif


/* SWPMAJERR codes */

#define SWPNONERR 0    /* No error */
#define SWPDSKFUL 1    /* Disk full */
#define SWPDSKOPE 2    /* Disk file open error */
#define SWPDSKERR 3    /* Disk i/o error */
#define SWPDIRERR 4    /* Change directory error */
#define SWPCREERR 5    /* Temp file create error */
#define SWPDRVERR 6    /* Change drive error */
#define SWPEMSERR 7    /* EMS error */
#define SWPXMSERR 8    /* XMS error */
#define SWPCMDERR 9    /* SHELL error */
#define SWPHANERR 10   /* Handle table too large to save */
#define SWPMEMERR 11   /* Top of memory decreased error */
#define SWPMCBERR 12   /* MCB chain corrupt */
#define SWPMCBCNT 13   /* Too many MCBs (128 max) */
#define SWPBLKERR 14   /* DOS memory function call error */
#define SWPMEMRES 15   /* Error reallocating program segment */
#define SWPCSPERR 16   /* COMSPEC variable not found */
#define SWPINTERR 254  /* Internal error */

/* Non fatal SWPERRMIN() codes when SWPERRMAJ() = 0 */

#define SWPKILTSR 1    /* TSR was removed */
#define SWPMEMINC 2    /* Top of DOS memory increased */

