/***
*
*   Clipdefs.h
*
*   C language defines and types for CA-Clipper
*
*   Copyright (c) 1992-1993, Computer Associates International, Inc.
*   All rights reserved.
*
*   Clipper uses Microsoft C large model calling conventions.
*
*/

#ifndef _CLIPDEFS_H

/* 
*  old types 
*/
typedef unsigned char byte;
typedef unsigned short quant;
typedef unsigned short Boolean;

/* 
*  newest and most wonderful types 
*/
typedef unsigned char BYTE;
typedef BYTE far * BYTEP;
typedef BYTEP PBYTE;

typedef BYTEP far * BYTEPP;

typedef short SHORT;
typedef SHORT far * SHORTP;
typedef SHORTP PSHORT;

typedef unsigned short USHORT;
typedef USHORT far * USHORTP;
typedef USHORTP PUSHORT;

typedef unsigned int WORD;
typedef WORD far * WORDP;
typedef WORDP PWORD;

typedef long LONG;
typedef LONG far * LONGP;
typedef LONGP PLONG;

typedef unsigned long ULONG;
typedef ULONG far * ULONGP;
typedef ULONGP PULONG;

typedef unsigned long DWORD;
typedef DWORD far * DWORDP;
typedef DWORDP PDWORD;


typedef USHORT BOOL;
typedef BOOL far * BOOLP;
typedef BOOLP PBOOL;

typedef USHORT HANDLE;

typedef USHORT ERRCODE;
typedef ERRCODE IHELP;
typedef ERRCODE ICODE;

/* default func ptr -- USHORT return, USHORT param */
typedef USHORT (far * FUNCP)(USHORT param, ...);
typedef FUNCP far * FUNCPP;

typedef void near * NEARP;
typedef NEARP far * NEARPP;

typedef void far * FARP;
typedef FARP far * FARPP;

typedef FARP VOIDP;
typedef FARP PVOID;

#define HIDE      static
#define CLIPPER   void pascal
               
#define FALSE      0
#define TRUE       1
#define NIL     '\0'
#define NULL      0L

#define _CLIPDEFS_H

#endif
