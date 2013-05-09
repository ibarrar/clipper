/**************************************************************
*
* BLX286.H      93.10.10
*
* Blinker 3.0 extender API header for C
*
* Copyright (C) ASM Inc, 1992, 1993
*
***************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

typedef short SHORT;
typedef long LONG;
typedef unsigned char BYTE;

typedef unsigned char UCHAR;
typedef unsigned int UINT;
typedef unsigned short USHORT;
typedef unsigned long ULONG;

typedef char _far *PCHAR;
typedef int _far *PINT;
typedef short _far *PSHORT;
typedef long _far *PLONG;

typedef unsigned char _far *PUCHAR;
typedef unsigned int _far *PUINT;
typedef unsigned short _far *PUSHORT;
typedef unsigned long _far *PULONG;

typedef unsigned short SEL;
typedef unsigned short _far *PSEL;

typedef unsigned long REALPTR;

#define BLXAPI pascal _far

/* macros */

#ifndef MK_FP
#define MK_FP(sel, off) ((void *)((((ULONG)(sel)) << 16) + ((ULONG)(off))))
#endif

#define SELECTOROF(fp) ((SEL)(((ULONG)(fp)) >> 16))
#define OFFSETOF(fp) ((UINT)(ULONG)(fp))

/* segment descriptor */

typedef struct
{
        ULONG   segbase;        /* Segment linear base address */
        ULONG   seglen;         /* Segment length in bytes */
        USHORT  segattrib;      /* Attribute bytes */
} DESC;                         /* This is not a real descriptor */

typedef DESC _far *PDESC;

/* interrupts */

typedef struct
{
        USHORT es;
        USHORT ds;
        USHORT di;
        USHORT si;
        USHORT bp;
        USHORT sp;
        USHORT bx;
        USHORT dx;
        USHORT cx;
        USHORT ax;
        USHORT ip;
        USHORT cs;
        USHORT flags;
} REGS16;

typedef REGS16 _far *PREGS;

/*
   On entry to an _interrupt function, Borland C pushes registers
   in a different order to Microsoft, so needs a different register
   structure for interrupt functions
*/

#ifdef __BORLANDC__

typedef struct
{
	USHORT bp;
	USHORT di;
	USHORT si;
	USHORT ds;
	USHORT es;
	USHORT dx;
	USHORT cx;
	USHORT bx;
	USHORT ax;
	USHORT ip;
	USHORT cs;
	USHORT flags;

} REGS_BINT;

typedef REGS_BINT _far *PREGS_BINT;

#endif

/* DosSetExceptionHandler Stack Frame */

#ifndef __BORLANDC__

typedef struct
{
	USHORT es;
	USHORT ds;
	USHORT di;
	USHORT si;
	USHORT bp;
	USHORT sp;
	USHORT bx;
	USHORT dx;
	USHORT cx;
	USHORT ax;

        USHORT rsv1;            /* reserved - glue ip */
        USHORT rsv2;            /* reserved - glue cs */

	USHORT error_code;
	USHORT ret_ip;
	USHORT ret_cs;
	USHORT ret_flags;
        USHORT ret_rsv3;        /* reserved - int sp */
        USHORT ret_rsv4;        /* reserved - int ss */
} EXCEP_FRAME;

#else

typedef struct
{
	USHORT bp;
	USHORT di;
	USHORT si;
	USHORT ds;
	USHORT es;
	USHORT dx;
	USHORT cx;
	USHORT bx;
	USHORT ax;

        USHORT rsv1;            /* reserved - glue ip */
	USHORT rsv2;		/* reserved - glue cs */

        USHORT error_code;
	USHORT ret_ip;
	USHORT ret_cs;
	USHORT ret_flags;
        USHORT ret_rsv3;        /* reserved - int sp */
        USHORT ret_rsv4;        /* reserved - int ss */
} EXCEP_FRAME;

#endif

typedef EXCEP_FRAME _far *PEXCEP_FRAME;


/* Interrupt and Exception handler typedefs */

typedef void (_interrupt _far *PEXCHAN)(EXCEP_FRAME regs);

#ifndef __BORLANDC__
typedef void (_interrupt _far *PINTHAN)(REGS16 regs);
#else
typedef void (_interrupt _far *PINTHAN)(REGS_BINT regs);
#endif

/* memory allocation */

USHORT BLXAPI DosAllocHuge(USHORT nseg, USHORT lcount, PSEL selp,
                             USHORT maxsel, USHORT flags);

USHORT BLXAPI DosAllocRealSeg(ULONG size, PUSHORT parap, PSEL selp);
USHORT BLXAPI DosAllocSeg(USHORT size, PSEL selp, USHORT flags) ;
USHORT BLXAPI DosCreateCSAlias(SEL dsel, PSEL cselp);
USHORT BLXAPI DosCreateDSAlias(SEL sel, PSEL aselp);
USHORT BLXAPI DosFreeRealSeg(SEL sel);
USHORT BLXAPI DosFreeSeg(SEL sel);
USHORT BLXAPI DosFreeSelector(SEL sel);
USHORT BLXAPI DosGetBIOSSeg(PSEL selp);
USHORT BLXAPI DosGetExceptionHandler(USHORT exc_no, PEXCHAN _far *handler);
USHORT BLXAPI DosGetHugeShift(PUSHORT countp);
USHORT BLXAPI DosGetProtVec(int intno, PINTHAN _far *handler);
USHORT BLXAPI DosGetRealVec(int intno, REALPTR _far *handler);
USHORT BLXAPI DosGetSegBase(SEL sel, PULONG basep);
USHORT BLXAPI DosGetSegDesc(SEL sel, PDESC descp);
USHORT BLXAPI DosGetSegLimit(SEL sel, PULONG limitp);
USHORT BLXAPI DosLockSeg(SEL sel);
USHORT BLXAPI DosMapRealSeg(USHORT rm_para, ULONG size, PSEL selp);
USHORT BLXAPI DosMemAvail(PULONG availp);
USHORT BLXAPI DosRealAvail(PULONG max_sizep);
USHORT _far _cdecl DosRealFarCall(REALPTR func, PREGS inregs, REALPTR reserved, USHORT words);
USHORT _far _cdecl DosRealIntr(USHORT intr, PREGS inregs, ULONG reserved, USHORT words);
USHORT BLXAPI DosReallocHuge(USHORT nseg, USHORT lcount, SEL sel);
USHORT BLXAPI DosReallocSeg(USHORT nsize, SEL sel);
USHORT BLXAPI DosSetExceptionHandler(USHORT exc_no, PEXCHAN newhandler, PEXCHAN _far *poldhanlder);
USHORT BLXAPI DosSetProtVec(USHORT int_no, PINTHAN newhandler, PINTHAN _far *poldhandler);
USHORT BLXAPI DosSetRealVec(USHORT int_no, PINTHAN newhandler, PINTHAN _far *poldhandler);
USHORT BLXAPI DosSetSegAttrib(SEL sel, USHORT attr);
USHORT BLXAPI DosUnLockSeg(SEL sel);
USHORT BLXAPI DosVerifyAccess(SEL sel, USHORT* attr);
USHORT BLXAPI DosVMAvail(PULONG max_sizep);

/* Machine modes for DosGetMachineMode */

#define MODE_REAL      0
#define MODE_PROTECTED 1

/* Host modes for DosGetHostMode and BLIMGRSTS */

#ifndef BliHostNone

#define BliHostNone     0
#define BliHostDPMI     1
#define BliHostVCPI     2
#define BliHostXMS      3

#endif

USHORT BLXAPI DosGetHostMode(BYTE* modep);

USHORT BLXAPI DosIsBlinkX(void);

USHORT BLXAPI DosGetMachineMode(BYTE* modep);

/* Masks for DosVerifyAccess */

#define SEL_VALID       1
#define SEL_READABLE    2
#define SEL_WRITABLE    4
#define SEL_CODE        8

/* Attributes for DosSetSegAttrib */

#define CODE16		1		/* Code segment */
#define DATA16		2		/* Data segment */
#define CODE16_NOREAD	3		/* Execute only code segment */
#define DATA16_NOWRITE  4               /* Read only data segment */


#ifdef __cplusplus
}
#endif

