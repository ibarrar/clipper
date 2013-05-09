/**************************************************************
*
* BLINKER.CH   93.11.27
*
* Blinker 3.0 function header for CA-Clipper 5.x
*
* Copyright (C) ASM Inc, 1992, 1993
*
***************************************************************/

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

#define BliHostNone     0                  /* No host */
#define BliHostDPMI     1                  /* DPMI host mode */
#define BliHostVCPI     2                  /* VCPI host mode */
#define BliHostXMS      3                  /* XMS host mode */

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
