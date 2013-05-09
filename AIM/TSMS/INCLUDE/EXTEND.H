/***
*	extend.h
*	C language definitions for Clipper EXTEND system.
*	Copyright (c) 1987,1988,1989,1990 Nantucket Corp.  All rights reserved.
*
*	Clipper uses Microsoft C large model calling conventions.
*/


#ifndef CLIPPERDEFS

#define CLIPPER		void pascal

#define FALSE	0
#define TRUE	1

#define NIL		'\0'
#define NULL	0L

typedef unsigned char byte;
typedef unsigned int quant;
typedef int Boolean;
typedef double XDOUBLE;

#define CLIPPERDEFS
#endif



#define UNDEF		0
#define CHARACTER	1
#define NUMERIC		2
#define LOGICAL		4
#define DATE		8
#define ALIAS		16
#define MPTR		32		/* or'ed with type when passed by reference */
#define MEMO		65
#define WORD		128
#define ARRAY		512


/* parameter count/type */
extern int _parinfo(int);
extern int _parinfa(int, unsigned int);


/* parameter values */
extern char *_parc(int, ...);
extern unsigned int _parcsiz(int, ...);
extern unsigned int _parclen(int, ...);
extern int _parni(int, ...);
extern long _parnl(int, ...);
extern XDOUBLE _parnd(int, ...);
extern int _parl(int, ...);
extern char *_pards(int, ...);


/* return a value */
extern void _retc(char far *);
extern void _retclen(char far *, unsigned int);
extern void _retni(int);
extern void _retnl(long);
extern void _retnd(XDOUBLE);
extern void _retl(int);
extern void _retds(char far *);

/* return no value (NIL) */
extern void _ret(void);


/* store values */
int _storc(char far *, int, ...);
int _storclen(char far *, int, ...);
int _storni(int, int, ...);
int _stornl(long, int, ...);
int _stornd(XDOUBLE, int, ...);
int _storl(int, int, ...);
int _stords(char far *, int, ...);


/***
*	Note:
*	_xalloc() returns NULL if the request cannot be satisfied
*	_xgrab() generates a runtime error if the request cannot be satisfied
*/

/*	allocate memory */
extern void far * _xalloc(unsigned int numberOfBytes);
extern void far * _xgrab(unsigned int numberOfBytes);
extern void _xfree(void far *allocatedBlock);


/* S87 compat. */
#define _exmgrab(size)			_xgrab(size)
#define _exmback(ptr, size)		_xfree(ptr)


/* parameter check macros */
#define PCOUNT		(_parinfo(0))
#define ISCHAR(n)	(_parinfo(n) & CHARACTER)
#define ISNUM(n)	(_parinfo(n) & NUMERIC)
#define ISLOG(n)	(_parinfo(n) & LOGICAL)
#define ISDATE(n)	(_parinfo(n) & DATE)
#define ISMEMO(n)	(_parinfo(n) & MEMO)
#define ISBYREF(n)	(_parinfo(n) & MPTR)
#define ISARRAY(n)	(_parinfo(n) & ARRAY)
#define ALENGTH(n)	(_parinfa(n, 0))

