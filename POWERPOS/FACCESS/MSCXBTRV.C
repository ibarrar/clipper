/*									*/
/*	     MicroSoft C Version 3.0, 5.1 interface to the		*/
/*		Btrieve Record Manager, version 4, 5.0, 5.1		*/
/*									*/

/*	   make sure this constant is not commented if
		 compiling for MS windows
#define WINDOWS 1
*/

#include <dos.h>			     /* For int86x, int86 calls */
#define BTR_ERR     20			  /* record manager not started */
#define BTR_INT     0x7B		    /* Btrieve interrupt vector */
#define BTR2_INT    0x2F		 /* multi-user interrupt vector */
#define BTR_VECTOR  BTR_INT * 4 		/* offset for interrupt */
#define BTR_OFFSET  0x33	       /* Btrieve offset within segment */
#define VARIABLE_ID 0x6176     /* id for variable length records - 'va' */
#define _2FCODE     0xAB00	 /* function code for int 2F to btrieve */


/*  For Compact, Large, and Huge memory models				*/
/*  LMODEL means 32-bit pointers in use 				*/

#if (defined(M_I86CM) || defined(M_I86LM) || defined(M_I86HM))
#define LMODEL 1
#endif

/* ProcId is used for communicating with the Multi Tasking Version of  */
/* Btrieve. It contains the process id returned from BMulti and should */
/* not be changed once it has been set. 			       */
/*								       */

static unsigned ProcId = 0;		/* initialize to no process id */
static char MULTI = 0;		      /* flag set to true if MultiUser */
static char VSet = 0;		/* flag set to true if checked version */

BTRV (int OP, char POS_BLK[], char DATA_BUF[], int *DATA_LEN, char KEY_BUF[], int KEY_NUM)
/*  int  OP;
  char POS_BLK[];
  char DATA_BUF[];
  int  *DATA_LEN;
  char KEY_BUF[];
  int  KEY_NUM; */

{

union REGS b_regs;			    /* define general registers */

struct SREGS b_sregs;			    /* define segment registers */

struct BTRIEVE_PARMS	  /* structure passed to Btrieve Record Manager */
 {
   char *BUF_OFFSET;			  /* callers data buffer offset */
#ifndef LMODEL
   int	 BUF_SEG;			 /* callers data buffer segment */
#endif
   int	 BUF_LEN;			       /* length of data buffer */
   char *CUR_OFFSET;			  /* user position block offset */
#ifndef LMODEL
   int	 CUR_SEG;			 /* user position block segment */
#endif
   char *FCB_OFFSET;				  /* offset of disk FCB */
#ifndef LMODEL
   int	 FCB_SEG;				 /* segment of disk FCB */
#endif
   int	 FUNCTION;				  /* requested function */
   char *KEY_OFFSET;			 /* offset of user's key buffer */
#ifndef LMODEL
   int	 KEY_SEG;			/* segment of user's key buffer */
#endif
   char  KEY_LENGTH;			 /* length of user's key buffer */
   char  KEY_NUMBER;			/* key of reference for request */
   int	*STAT_OFFSET;			       /* offset of status word */
#ifndef LMODEL
   int	 STAT_SEG;			      /* segment of status word */
#endif
   int	 XFACE_ID;				 /* language identifier */
 } XDATA;

int STAT = 0;				      /* status of Btrieve call */

/*									*/
/*  Check to see that the Btrieve Record Manager has been started.	*/
/*									*/

if (!VSet)		     /* if we don't know version of Btrieve yet */
 {
  VSet = 1;
  b_regs.x.ax = 0x3000; 			   /* check dos version */
#ifdef WINDOWS
  int86 (0x21, &b_regs, &b_regs);
#else
  int86x (0x21, &b_regs, &b_regs, &b_sregs);
#endif
  if ((b_regs.x.ax & 0x00FF) >= 3)	   /* if DOS version 3 or later */
   {
    b_regs.x.ax = _2FCODE;
#ifdef WINDOWS
    int86 (BTR2_INT, &b_regs, &b_regs); 	   /* is bmulti loaded? */
#else
    int86x (BTR2_INT, &b_regs, &b_regs, &b_sregs);
#endif
    MULTI = (char) ((b_regs.x.ax & 0xFF) == 'M');/* if al is M, bmulti is loaded */
   }
 }

if (!MULTI)
 {						 /* if bmulti not loaded */
  b_regs.x.ax = 0x3500 + BTR_INT;
#ifdef WINDOWS
  int86 (0x21, &b_regs, &b_regs);      /* check for btrieve being loaded */
#else
  int86x (0x21, &b_regs, &b_regs, &b_sregs);
#endif
  if (b_regs.x.bx != BTR_OFFSET)
     return (BTR_ERR);
 }

/*  Read segment registers and initialize segment part of addresses to	*/
/*  user's data segment.                                                */
/*									*/

segread (&b_sregs);
#ifndef LMODEL
XDATA.BUF_SEG = XDATA.CUR_SEG = XDATA.FCB_SEG =
  XDATA.KEY_SEG = XDATA.STAT_SEG = b_sregs.ss;
#endif

/*									*/
/*  Move user parameters to XDATA, the block where Btrieve expects them.*/
/*									*/

XDATA.FUNCTION	  = OP;
XDATA.STAT_OFFSET = &STAT;
XDATA.FCB_OFFSET  = POS_BLK;
XDATA.CUR_OFFSET  = POS_BLK + 38;
XDATA.BUF_OFFSET  = DATA_BUF;
XDATA.BUF_LEN	  = *DATA_LEN;
XDATA.KEY_OFFSET  = KEY_BUF;
XDATA.KEY_LENGTH  = 255;		 /* use max since we don't know */
XDATA.KEY_NUMBER  = (char) KEY_NUM;
XDATA.XFACE_ID	  = VARIABLE_ID;

/*									*/
/*  Make call to the Btrieve Record Manager.				*/
/*									*/

b_regs.x.dx = (int) &XDATA;  /* parameter block is expected to be in DX */
b_sregs.ds = b_sregs.ss;
if (!MULTI)
#ifdef WINDOWS			  /* if bmulti not loaded, call Btrieve */
  int86 (BTR_INT, &b_regs, &b_regs);
#else
  int86x (BTR_INT, &b_regs, &b_regs, &b_sregs);
#endif
else
 {							 /* call bmulti */
  while (1)
   {
    b_regs.x.ax = 1;		     /*  assume no proc id obtained yet */
    if ((b_regs.x.bx = ProcId) != 0)		/* if we have a proc id */
      b_regs.x.ax = 2;				    /* tell bmulti that */
    b_regs.x.ax += _2FCODE;
#ifdef WINDOWS
    int86 (BTR2_INT, &b_regs, &b_regs); 		 /* call bmulti */
#else
    int86x (BTR2_INT, &b_regs, &b_regs, &b_sregs);
#endif
    if ((b_regs.x.ax & 0x00FF) == 0) break;    /* if call was processed */
#ifndef WINDOWS 			       /* by bmulti, leave loop */
    b_regs.x.ax = 0x0200;   /* if multilink advanced is loaded, it will */
    int86x (0x7F, &b_regs, &b_regs, &b_sregs);	    /* switch processes */
#endif
   }
  if (ProcId == 0) ProcId = b_regs.x.bx;
 }

*DATA_LEN = XDATA.BUF_LEN;
return (STAT);					       /* return status */
}
