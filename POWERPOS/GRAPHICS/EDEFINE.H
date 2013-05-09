/*

   EDEFINE.H Extended headers for C
 
*/ 

#ifndef _EDEF_DEFINE_
#if ( _MSC_VER <= 600 )
   #define __far  _far
   #define __near _near
   #define __pascal _pascal
   #define __cdecl _cdecl
   #undef  _HIDEDOUBLE_
#else
   #define _HIDEDOUBLE_ 1
#endif

#define PASCAL    __pascal
#define CDECL     __cdecl
#define LONG      long
#define SHORT     short
#define VOID      void
#define LOCAL     static
#define HIDE      static
#define GLOBAL    extern
#define NOARG     void
#define FAR       __far
#define NEAR      __near
#define REG       register
#define CONST     const
#define VOLATILE  volatile
#define TYPE      typedef
#define UNS       unsigned
#define SIZE(p)   sizeof(p)
#define FALSE     0
#define TRUE      1
#define NIL       '\0'
#define NULL      0L
#define NULLP     ((PVOID)0)
#define LPNULL    ((LPVOID)0)

TYPE SHORT        BOOL;
TYPE UNS char     BYTE;
TYPE UNS SHORT    WORD;
TYPE UNS SHORT    USHORT;
TYPE UNS LONG     ULONG;
TYPE UNS LONG     DWORD;
TYPE char         STR;
TYPE double       DOUBLE;
TYPE struct
{
   WORD wLo;
   WORD wHi;
}XDOUBLE;
TYPE BYTE         *PBYTE;
TYPE BYTE FAR     *LPBYTE;
TYPE BYTE NEAR    *NPBYTE;
TYPE STR          *PSTR;
TYPE STR FAR      *LPSTR;
TYPE STR NEAR     *NPSTR;
TYPE WORD         *PWORD;
TYPE WORD FAR     *LPWORD;   
TYPE WORD NEAR    *NPWORD;
TYPE DWORD        *PDWORD;
TYPE DWORD FAR    *LPDWORD;
TYPE DWORD NEAR   *NPDWORD;
#ifdef _HIDEDOUBLE_
      TYPE XDOUBLE DBL;
#else
      TYPE DOUBLE  DBL;
#endif 
TYPE DBL          *PDBL;
TYPE DBL FAR      *LPDBL;
TYPE DBL NEAR     *NPDBL;

#define _EDEF_DEFINED_ 1
#endif

 


   
   
   


