/***
*
*  Sdx.h
*
*  SDX driver header file
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#define EOF                ( 0x1A )
#define ISWHITESPACE( x )  ( (x) == ' ' || (x) == '\t' || (x) == '\n' )
#define TOKEN_CHAR         '['
#define ISTOKEN( x )       ( (x) == TOKEN_CHAR )
#define SPACE              ( '\x20' )
#define CRLF               ( "\r\n" )
#define SDX_REC_DELIM      CRLF

#define MAXLEN_DOSFILE     80  // Length of fully qualified DOS filename
#define MAXLEN_IDENTIFIER  10  // Length of an alias in Clipper
#define MAXLEN_RDD         15  // Length of an RDD name in Clipper
#define MAX_SDX_TOKENS      2  // number of [...] captions in an .SDX file
#define MAX_WIDTH_LONG     10  // Width of a LONG in character representation


/*
*  
*  SDX error subcodes
*
*  Note: These values are the same as those documented for the existing
*  RDD drivers  
*/

#define E_SUCCESS          E_DEFAULT

#define ESDX_OPEN          1001
#define ESDX_CLOSE         1002
#define ESDX_CREATE        1004
#define ESDX_READ          1010
#define ESDX_WRITE         1011
#define ESDX_CORRUPT       1012
#define ESDX_DATATYPE      1020
#define ESDX_DATAWIDTH     1021
#define ESDX_SHARED        1023
#define ESDX_READONLY      1025



/*
*  
*  SDXAREA
*  
*  SDX workarea structure
*  
*  This structure "inherits" the basic structure of WORKAREA and adds
*  to it those members needed for implementation of this driver
*  
*/

typedef struct _SDXAREA_

{
   DBFUNCTABLEP ftable;       // Virtual method table for this workarea

   USHORT  area;              // The number assigned to this workarea
   FARP    alias;             // Pointer to this workarea's alias symbol

   USHORT fieldExtent;        // Total number of fields allocated
   USHORT fieldCount;         // Total number of fields used
   FIELDP fields;             // Pointer to an array of fields

   ITEM result;               // All purpose result holder

   BOOL top;                  // Unused in this implementation
   BOOL bottom;               // Unused in this implementation
   BOOL bof;                  // TRUE if "bof"
   BOOL eof;                  // TRUE if "eof"
   BOOL found;                // Unused in this implementation

   DBSCOPEINFO  locate;       // Unused in this implementation
   DBFILTERINFO filter;       // Unused in this implementation

   DBRELINFOP   relations;    // Unused in this implementation
   USHORT       parents;      // Unused in this implementation

   HANDLE  heap;              // Unused in this implementation
   USHORT  heapSize;          // Unused in this implementation

   USHORT   rddID;            // Unused in this implementation

   /*
   *  SDX's additions to the workarea structure
   *  
   *  Warning: The above section MUST match WORKAREA exactly!  Any
   *  additions to the structure MUST be added below, as in this
   *  example.
   */
   BYTEP    infoName;         // Name of header file (.SDX)
   FHANDLE  infoHandle;       // File handle for the header file

   BYTEP    dbName;           // Name of database file (.SDF)
   FHANDLE  dbHandle;         // File handle for the database file

   BOOL  shared;              // File sharing flag
   BOOL  readonly;            // File access mode

   ULONG recSize;             // Record size
   ULONG recCount;            // Number of records in the (.SDF) file 
   ULONG recNo;               // Current record number

   BOOL    buffIsHot;         // Indicates record buffer needs to be flushed
   BOOL    buffIsValid;       // Indicates validity of record buffer
   BYTEP   buff;              // Record buffer
   USHORTP fieldOffsets;      // Each field's offset in the record buffer

} SDXAREA;

typedef SDXAREA far * SDXAREAP;

