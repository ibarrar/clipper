/*d4data.h   (c)Copyright Sequiter Software Inc., 1990-1992.  All rights reserved. */

#ifndef S4UNIX
#ifndef _SIZE_T_DEFINED_     /* Watcom */
#ifndef _SIZE_T_DEFINED      /* Microsoft */
#ifndef _SIZE_T              /* Borland  */
   typedef unsigned size_t ;
#endif
#endif
#endif
#endif

#ifndef S4CLIPPER
   #define S4CLIPPER
#endif

#ifdef S4GERMAN
   #define S4LANGUAGE
#endif

#ifdef S4FRENCH
   #define S4LANGUAGE
#endif

#ifdef __TURBOC__
   #ifdef S4DLL
      #define S4CLASS huge
      #define S4FUNCTION far pascal
   #endif
#endif

#ifdef _MSC_VER
   #ifdef S4DLL
      #ifdef __cplusplus
         #define S4CLASS
      #else
         #define S4CLASS huge
      #endif
      #define S4FUNCTION far pascal
   #endif
#endif

#ifdef __ZTC__
   #ifdef S4DLL
      #ifdef __cplusplus
         #define S4CLASS
      #else
         #define S4CLASS huge
      #endif
      #define S4FUNCTION far pascal
   #endif
#endif

#ifdef S4DLL_BUILD
   #define __DLL__
#endif

#ifdef __DLL__
   #define S4DLL
   #define S4CLASS _export
   #define S4FUNCTION far pascal _export
#endif

#ifdef S4DLL
   #define S4WINDOWS
#endif

#ifndef S4CLASS
   #define S4CLASS
   #define S4FUNCTION
#endif

#ifdef S4DLL
   #define S4CALL far pascal _export
#else
   #ifdef _MSC_VER
      #define S4CALL _cdecl S4FUNCTION
   #else
      #define S4CALL S4FUNCTION
   #endif
#endif

#ifdef S4WINDOWS
   typedef unsigned int UINT ;
#endif

#ifdef _MSC_VER
   #define S4ERROR cdecl
#endif
#ifdef __TURBOC__
   #define S4ERROR cdecl
#endif
#ifdef __ZTC__
   #define S4ERROR cdecl
#endif
#ifdef __WATCOMC__
   #define S4ERROR cdecl
#endif
#ifndef S4ERROR
   #define S4ERROR S4FUNCTION
#endif

#ifdef S4DLL
   #define S4PTR far
#else
   #define S4PTR
#endif

#ifdef S4UNIX
   #include "p4port.h"
   #define S4MDX
#endif

#ifdef S4NDX
/* default is to use dBASE III+/Clipper memo file formats if using .NDX index file formats */
#define S4MNDX
#define N4OTHER
#endif

#ifdef S4CLIPPER
/* default is to use dBASE III+/Clipper memo file formats if using .NTX index file formats */
#define S4MNDX
#define N4OTHER
#endif

#ifdef S4FOX
/* default is to use foxpro memo file formats if using foxpro index file formats */
#define S4MFOX
#endif

#ifndef S4FOX
#ifndef N4OTHER
   #define S4MDX
#endif
#endif

#ifndef S4MDX
   #ifdef S4BYTE_SWAP
      #error: Byte Swap Not Supported for Non-Mdx Formats.
   #endif
#endif

#ifdef S4MNDX
#define   M4MEMO_SIZE   0x200
#endif

#ifndef S4UNIX
   typedef  const void S4PTR *  S4CMP_PARM ;
#endif

typedef int S4CALL  S4CMP_FUNCTION( S4CMP_PARM, S4CMP_PARM, size_t) ;

#ifdef S4DLL
   #define s4assign_cmp(s4,f)  (s4)->cmp = (S4CMP_FUNCTION S4PTR *) MakeProcInstance((FARPROC) f, (s4)->code_base->hInst)
#else
   #define s4assign_cmp(s4,f)  (s4)->cmp = (S4CMP_FUNCTION S4PTR *) (f)
#endif

/* Integer Return Codes */
#define r4success  0
#define r4found    1    /* Primary Key Match */
#define r4after    2
#define r4eof      3
#define r4bof      4
#define r4entry    5    /* No index file entry or no record (go) */
#define r4descending   10
#define r4unique   20   /* Key is not unique, do not write/append */
#define r4unique_continue  25    /* Key is not unique, write/append anyway */
#define r4ignore   40
#define r4keep     45
#define r4locked   50
#define r4no_create 60   /* Could not create file */
#define r4no_open  70   /* Could not open file */
#define r4no_tag   80   /* d4seek, with no default tag */

/* General Disk Access Errors */
#define e4close   -10
#define e4create  -20 
#define e4len     -30 
#define e4len_set -40 
#define e4lock    -50 
#define e4open    -60 
#define e4read    -70
#define e4remove  -80
#define e4rename  -90
#define e4seek    -100 
#define e4unlock  -110 
#define e4write   -120 

/* Database Specific Errors */
#define e4data  -200 
#define e4field_name -210   /* Invalid field name */
#define e4field_type -220
#define e4record_len -230 

/* Index File Specific Errors */
#define e4entry  -300  /* Tag entry not located */
#define e4index  -310 
#define e4tag_name  -330 
#define e4unique    -340  /* Key is not unique */

/* Expression Errors */
#define e4comma_expected   -400 
#define e4complete   -410 
#define e4data_name  -420 
#define e4num_parms   -430 
#define e4overflow   -440  /* Overflow while evaluating expression */
#define e4right_missing   -450
#define e4type_sub      -460 
#define e4unrec_function   -470 
#define e4unrec_operator   -480 
#define e4unrec_value   -490
#define e4unterminated   -500 

/* Critical Errors */
#define e4info     -910  /* Unexpected information in internal variable */
#define e4memory   -920  /* Out of memory */
#define e4parm     -930  /* Unexpected parameter */
#define e4demo     -940  /* Exceeded maximum record number for demo */
#define e4result   -950  /* Unexpected result */

#define E4DEMO_MAX 200 

/* garbage between expression and filter is length */
#ifdef  S4FOX
#define I4MULTIPLY     1
#define B4DO_BACK_LEVEL 3
#define I4MAX_KEY_SIZE 240
#else
   #define I4MULTIPLY     512

   #ifdef S4NDX
      #define I4MAX_KEY_SIZE 100
   #else
      #ifdef S4CLIPPER
         #define I4MAX_KEY_SIZE 338
      #else
         #define I4MAX_KEY_SIZE 102 
      #endif
   #endif
#endif

#define D4GARBAGE_LEN  518
#define L4LOCK_POS     1000000000L 
#define E4ACCURACY     1.0e-13
#define E4ACCURACY_DIGITS  15

typedef void C4STOK( char S4PTR *, char S4PTR *, int ) ;
typedef void C4DTOK( char S4PTR *, double ) ;

struct D4DATA_st ;
struct F4MEMO_st ;
struct I4INDEX_st ;
struct T4TAG_st ;

typedef struct l4link_st
{
   struct l4link_st S4PTR *n, S4PTR *p ;
} L4LINK ;

#ifdef __cplusplus
typedef struct S4CLASS
#else
typedef struct
#endif
{
   L4LINK S4PTR *last ;           /* The last Link */
   void   S4PTR *selected ;
   int     n_link ;         /* The number of links in the list */
} L4LIST ;

typedef struct
{
   L4LINK link ;
   double  data ;  /* Make sure it is on a boundry good for at least a double  */
} Y4CHUNK ;

typedef struct
{
   L4LINK link ;

   L4LIST      chunks ;      /* Chunks of pieces */
   L4LIST      pieces ;      /* A list of available memory pieces */

   int         unit_start;   /* The starting # of entries for the Memory Type */
   unsigned    unit_size ;   /* The size of each allocated piece */
   int         unit_expand ; /* The expansion # of entries for the Memory Type */
   int         n_repeat ;    /* The number of times entry returned for 'new' */
                             /* If n_repeat is '-1', it is a temporary entry. */
   int         n_used ;      /* The number of entries used */
}  Y4MEMORY_TYPE ;

#ifdef __cplusplus
typedef struct S4CLASS
#else
typedef struct
#endif
{
   unsigned hWnd ;            /* For use under Microsoft Windows */
   unsigned hInst ;

   L4LIST   data_list ;     /* A list of open data files. */
   int default_unique_error ; /* e4unique, r4unique, r4unique_continue */
   char date_format[19]; /* Longest is September 15, 1990 */

   unsigned mem_size_block ;      /* Block size (bytes) for memo and index files */
   unsigned mem_size_sort_pool ;  /* The default pool size for sorting */
   unsigned mem_size_sort_buffer ;/* The default file buffer size when sorting */
   unsigned mem_size_buffer ;     /* Pack, Zap */

   int mem_expand_block ;  /* Expanding block memory allocation */
   int mem_expand_data ;   /* Expanding data file allocation */
   int mem_expand_index ;  /* Expanding index file allocation */
   int mem_expand_tag ;    /* Expanding index file allocation */

   int mem_start_data ;    /* Initial data file allocation */
   int mem_start_block ;   /* Initial block memory allocation for index files */
   int mem_start_index ;   /* Initial index file allocation */
   int mem_start_tag ;     /* Initial index file allocation */

   /* True/False Flags */
   int  field_name_error ;    
   int  go_error ;             /* Do 'Data::go' error ? */
   int  open_error ;           /* Do 'File::open' error ? */
   int  create_error ;         /* Do 'File::create' error ? */
   int  read_lock ;            /* Do lock when reading database ? */
   int  skip_error ;           /* Do 'DataIndex::skip' error ? */
   int  tag_name_error ;     
   int  safety ;               /* File create with safety ? */
   int  wait   ;               /* Wait when locking ? */
   int  auto_open ;            /* Automatic production index file opening */

   Y4MEMORY_TYPE S4PTR *index_memory ;
   Y4MEMORY_TYPE S4PTR *data_memory ;
   Y4MEMORY_TYPE S4PTR *tag_memory ;

   #ifdef S4CLIPPER
      int numeric_str_len ;    /* the default length for clipper index files */
      int decimals ;           /* the default # decimals for clipper index files */
   #endif

   int  error_code ;          
   int  debug_int ;            /* used to check structure integrity (set to 0x5281) */
} C4CODE ;

typedef struct
{
   char S4PTR *name ;
   C4CODE S4PTR *code_base ;
   int   hand ;
   char  is_temp ;      /* True if it is a temporary file */
   char  do_alloc_free ;
} H4FILE ;

typedef struct
{
   H4FILE     file ;
   short      block_size ;               /* Bytes */
   struct D4DATA_st  S4PTR *data ;
} M4FILE ;

typedef struct
{
   H4FILE S4PTR *file ;

   long  pos ;          /* The next position to read from */
   char S4PTR *buffer ;
   unsigned next_read_len ;
   unsigned total ;     /* Total buffer length */
   unsigned working ;   /* Temporary working buffer length (to help align write) */
   unsigned avail ;     /* # of bytes currently available */
} H4SEQ_READ ;

typedef struct
{
   H4FILE S4PTR *file ;

   long  pos ;          /* The next position to read from */
   char S4PTR *buffer ;
   unsigned total ;     /* Total buffer length */
   unsigned working ;   /* Temporary working buffer length (to help align write) */
   unsigned avail ;     /* # of bytes left in working buffer */
} H4SEQ_WRITE ;

typedef struct  /* Data File Format */
{
   char     name[11] ;
   char     type ;
   char     filler[4] ;
   unsigned char  len ;
   unsigned char  dec ;
   char     filler2[13] ;
   char    has_tag ;
} F4FIELD_IMAGE ;

typedef struct  /* Internal Structure and Field Routines. */
{
   char        name[11] ;
   unsigned    len ;
   int         dec ;
   int         type ;
   int         offset ;
   struct D4DATA_st  S4PTR *data ;
   struct F4MEMO_st  S4PTR *memo ;
   #ifdef S4VBASIC
      int  debug_int ;         /* used to check structure integrity (set to 0x5281) */
   #endif
} F4FIELD ;

typedef struct F4MEMO_st
{
   int    is_changed ;

   int    status ;           /* 0 - Current contents, 1 - Unknown */
   char  S4PTR *contents ;
   unsigned  len ;
   unsigned  len_max ;
   F4FIELD  S4PTR *field ;
} F4MEMO ;

typedef struct  /* Creating Data File */
{
   char   S4PTR *name ;
   char    type ;
   short   len ;
   short   dec ;
} F4FIELD_INFO ;

typedef struct
{
   /* Database Header Information */
   char     version ;        /* 83H with .dbt, 03H without */
   char     yy ;             /* Last Update */
   char     mm ;
   char     dd ;
   long     num_recs ;
   unsigned short header_len; /* Header Length, Indicates start of data */
   unsigned short record_len;
   char     zero[16] ;
   short    has_mdx ;    /* 1 for true */
   char     zero2[2] ;
} D4DATA_HEADER_FULL ;

typedef struct D4DATA_st
{
   L4LINK  link ;

   /* Database Header Information */
   char     version ;        /* 83H with .dbt, 03H without */
   char     yy ;             /* Last Update */
   char     mm ;
   char     dd ;
   long     num_recs ;
   unsigned short header_len; /* Header Length, Indicates start of data */

   char     S4PTR *record_old ;          /* Data allocated with 'u4alloc' */
   char     S4PTR *record ;              /* Data allocated with 'u4alloc' */
                                 /* Extra byte added for temporary CTRL_Z */
   unsigned record_width ;
   int      record_changed ;      /* T/F */
   long     rec_num ;             /* Record number; -1 unknown; 0 for append */
   long     rec_num_old ;         /* Record number, -1 none present; 0 for append */

   H4FILE   file ;
   char     alias[11] ;

   char     memo_validated ; /* Can we be sure memo id #'s are up to date. */

   C4CODE   S4PTR *code_base ;
   short    has_mdx ;        /* Has an MDX file attached to it */

   F4FIELD  S4PTR *fields ;        /* An array of field pointers */
   int      n_fields ;       /* The number of data fields in the database */

   F4MEMO   S4PTR *fields_memo ;    /* A list of fields to be flushed */
   int      n_fields_memo ;  /* The number of memo files in the database */

   long     locked_record ;  /* 'locks' data when 'n_locks <= 1' */
   long     S4PTR *locks ;
   int      n_locks ;        /* Number of elements in 'locks' allocated */
   int      num_locked ;     /* Number of records locked */
   int      file_lock ;      /* True if entire file is locked */
   int      append_lock ;    /* True if the file is locked for appending */

   int      file_changed ;   /* True if the file has been changed since */
                                /* the header has been updated. */

   L4LIST   indexes ;
   int      bof_flag, eof_flag ;    /* Beginning/End of File flags */

   short    block_size ;
   M4FILE   memo_file ;      /* Memo file handle */
   #ifdef S4VBASIC
      int  debug_int ;      /* used to check structure integrity (set to 0x5281) */
   #endif
} D4DATA ;

typedef struct e4expr_st
{
   char    S4PTR *source ;       /* The character version of the expression */
   D4DATA  S4PTR *data ;         /* The selected database when originally parsed */
   char    S4PTR *parsed ;       /* The parsed version of the expression */
   int     type ;
   #ifdef S4CLIPPER
      int   num_decimals ;         /* used for CLIPPER version */
   #endif
} E4EXPR ;

#ifdef N4OTHER
   typedef struct
   {
      long  pointer ;    /* =0L if record, not pointer */
      long  num ;
      char  value[1] ;  /* The key size is variable */
   } B4KEY_DATA ;
   
   #define I4MAX_EXPR_SIZE 256
   #ifdef S4NDX
      #define B4BLOCK_SIZE 512
   #else
      #ifdef S4CLIPPER
         #define B4BLOCK_SIZE 1024
      #endif
   #endif
#else
   typedef struct
   {
      long  num ;
      char  value[1] ;  /* The key size is variable */
   } B4KEY_DATA ;
#endif

#ifdef S4FOX
#define VERSION_POS 498L

typedef struct
{
   int trail1 ;
   int trail2 ;
   int dup1 ;
   int dup2 ;
} INSERT_STRUCT ;

/* the following structure is used only on the leaf nodes of the tree structure */
typedef struct
{
   short            free_space ;        /* # bytes available in node */
   unsigned long    rec_num_mask ;      /* record number mask */
   unsigned char    dup_byte_cnt ;      /* duplicate byte mask count */
   unsigned char    trail_byte_cnt ;    /* Trailing byte mask count */
   unsigned char    rec_num_len ;       /* # bits used for record number */
   unsigned char    dup_cnt_len ;       /* # bits used for duplicate count */
   unsigned char    trail_cnt_len ;     /* # bits used for trail count */
   unsigned char    info_len ;          /* # bytes for holding record number, */
} B4NODE_HEADER ;

typedef struct
{
      short      node_attribute ;    /* 0=index, 1=root, 2=leaf */
      short      n_keys ;            /* Block Image starts here */
      long       left_node ;         /* -1 if not present */
      long       right_node ;        /* -1 if not present */
} B4STD_HEADER ;

typedef struct
{
   L4LINK link ;
   struct T4TAG_st  *tag ;

   int   changed ;
   long  file_block ;     /* Identifies block within index file */
   int   key_on ;         /* The current key within the block */
   int   built_on ;       /* the 'current' key value (i.e. key really 'on') */
   int   cur_trail_cnt ;  /* current value used for seeking */
   int   cur_dup_cnt ;    /* current value used for seeking */
   int   dup_pos ;        /* bit offset into the info for the duplicate data */
   int   trail_pos ;      /* bit offset into the info for the trail data */
   int   rec_pos ;        /* bit offset into the info for the record # data */
   char  *cur_pos ;       /* current position into the data (starts at end) */
   B4KEY_DATA *current ;
   B4KEY_DATA *saved ;

   B4STD_HEADER header ;
   B4NODE_HEADER node_hdr ;    /* only if the block is a leaf */
   char  data[1] ;        /* the remaining data */
} B4BLOCK ;

/* next is the # of bytes of important info for T4HEADER */
#define T4HEADER_WR_LEN 0x10
/* block_size is 512 for foxpro */
#define B4BLOCK_SIZE 512
#endif  /* ifdef S4FOX  */

#ifndef S4FOX

#ifdef S4NDX
   typedef struct
   {
      long     root ;
      long     eof ;
      char     n1_dummy ;
      char     db_type ;
      char     n2_dummy[2] ;
      short    key_len  ;
      short    keys_max ;           /* Maximum # of keys per block;  <= 100 */
      short    int_or_date ;        /* TRUE (1) if Numeric or Date Key */
      short    group_len ;          /* key_len plus 8 increased to a multiple of 2 */
      short    dummy ;
      short    unique ;             /* TRUE if Unique */

 /*   char     expression[256] ; */
 /*   long     version ; */
   } I4IND_HEAD_WRITE;
#else
   #ifdef S4CLIPPER
      typedef struct
      {
         short          sign ;
         short          version ;
         long           root ;          /* Root Block */
         long           eof ;           /* First Free Block Pointer */
         short          group_len ;     /* Key Length + 2*sizeof(long) */
         short          key_len ;       /* Key Length */
         short          key_dec ;       /* Number of Decimals in Key */
         short          keys_max ;      /* Maximum # of keys per block;  <= 100 */
         short          keys_half ;     /* Maximum # of keys per half block */

    /*   char           expression[256];   The index expression corresponding to the database. */ 
    /*   short          unique   ;         TRUE if Unique */ 
      } I4IND_HEAD_WRITE;
   #endif
#endif

#ifdef S4NDX
typedef struct
{
   long     old_version ;
   int      header_offset ;
   char     type ;

   long     root ;
   long     eof ;
   char     n1_dummy ;
   char     db_type ;
   char     n2_dummy[2] ;
   short    key_len  ;
   short    keys_max ;           /* Maximum # of keys per block;  <= 100 */
   short    int_or_date ;        /* TRUE (1) if Numeric or Date Key */
   short    group_len ;          /* key_len plus 8 increased to a multiple of 2 */
   short    dummy ;
   short    unique ;             /* TRUE if Unique */
/* char     expression[256] ; */
   long     version ;
}  T4HEADER ;
#else
   #ifdef S4CLIPPER
      typedef struct
      {
         long       old_version ;
         int        header_offset ;
         char       type ;
         long       virtual_eof ;   /* The next available file block */
         short      sign ;
         short      version ;
         long       root ;          /* Root Block */
         long       eof ;           /* First Free Block Pointer */
         short      group_len ;     /* Key Length + 2*sizeof(long) */
         short      key_len ;       /* Key Length */
         short      key_dec ;       /* Number of Decimals in Key */
         short      keys_max ;      /* Maximum # of keys per block;  <= 100 */
         short      keys_half ;     /* Maximum # of keys per half block */
      /* char       expression[256];   The index expression corresponding to the database. */ 
         short      unique   ;      /* TRUE if Unique */
      }  T4HEADER ;
   #else
      typedef struct
      {
         char   two ;                /* Version number (currently 2) */
         char   yymmdd[3] ;          /* Date of last reindex */
         char   data_name[12] ;      /* Name of associated data file */
         char   dummy1[4] ;          /* extra 4 bytes for data-names-not used in DOS */
         short  block_chunks ;       /* Block Size 1 to 32 (512 byte chunks) */
         short  block_rw ;           /* Block Read/Write Size in bytes */
         char   is_production ;      /* 1 if production index, else 0 */
         char   num_slots ;          /* number possible tags (48) */
         short  slot_size ;          /* number bytes/tag slot (32) */
         long   num_tags ;
         long   eof ;
         long   free_list ;          /* start of the free list */
         char   zero[4] ;
         char   create_date[3];      /* not used by CodeBase++ */
         char   blank ;
         long   version ;
      }  I4HEADER ;
   #endif     /*   ifdef S4CLIPPER  */
#endif     /*   ifdef S4NDX   */
#endif     /*   ifndef S4FOX  */


#ifndef S4FOX
typedef struct
{
   L4LINK link ;
   struct T4TAG_st  S4PTR *tag ;

   long  file_block ;  /* Identifies block within index file */
   int   changed ;
   int   key_on ;      /* The current key within the block */

   short      n_keys ; /* Block Image starts here */
   #ifdef S4NDX
      char       dummy[2] ;
      B4KEY_DATA data ;
   #else
      #ifdef S4CLIPPER
         short pointers[511] ;
         B4KEY_DATA *data ;
      #else
         char       dummy[6] ;
         B4KEY_DATA info ;
      #endif
   #endif
} B4BLOCK ;

typedef struct
{
   long  header_pos ;          /* Header position (in 512 byte chunks) */
   char  tag[10] ;
   short x1000 ;               /* used for dBASE/SQL expression type - dBASE only allowed for CBPP 1.0x */
   char  left_chld ;
   char  right_chld ;
   char  parent ;
   char  x2 ;
   char  index_type ;
   char  zeros[11] ;
} T4DESC ;
#endif     /* ifndef  S4FOX  */

#ifndef N4OTHER
typedef struct
{
#ifdef S4FOX
   long           root ;            /* -1 means unknown */
   long           free_list ;       /* start of the free list (-1 if none) */
   char           dummy1[4] ;       /* Key Length */
   short          key_len ;         /* 0x01 Uniq; 0x08 For Clause; 0x32 Compact; 0x80 Compound */
   unsigned char  type_code;        /* unused */
   unsigned char  signature ;     
                                    
/* char           dummy2[482] ;        unused */
   long           version ;         /* CodeBase uses for version # */
   short          descending   ;    /* 1 = descending, 0 = ascending */
   short          filter_pos ;      /* not used, == to expr_len */
   short          filter_len ;      /* length of filter clause */
   short          expr_pos ;        /* not used, == to 0  */
   short          expr_len ;        /* length of expression */
/* char           expr_pool[512] ;  expression and filter pool */
#else
   long           root ;            /* -1 means unknown */
   char           dummy1[4] ;
   char           type_code;        /* 0x10 Normal; 0x58 Uniq,Desc; 0x50 Uniq; 0x18 Desc */
   char           type ;            /* N,D, or C (F is type N)  */
   char           dummy2[2] ;
   short          value_len ;
   short          keys_max ;        /* Maximum # of keys per block;  <= 100  */
   char           dummy3[2] ;       /* 1 if Numeric or Date Key (NDX only) */
   short          group_len ;       /* value_len plus 4 (MDX); plus 8 (NDX) */
   char           version ;
   char           dummy4 ;
   short          unique   ;        /* 0x4000 (TRUE)if Unique */

   /* Note, 'expr_key[220]' comes after 'unique' and */
   /*       'expr_filter[220]' comes at position 0x2FA */
#endif
}  T4HEADER ;
#endif   /*  ifndef N4OTHER  */

typedef struct T4TAG_st
{
   L4LINK link ;

   E4EXPR   S4PTR  *expr ;
   E4EXPR   S4PTR  *filter ;
   int              unique_error; /* Is rewriting a unique key an error ? */
   struct I4INDEX_st S4PTR *index ;
   S4CMP_FUNCTION  *cmp ;
   C4STOK S4PTR    *stok ;               /* Conversion for 'seek' */
   C4DTOK S4PTR    *dtok ;               /* Conversion for 'seek' */
   C4CODE S4PTR    *code_base ;
   char             alias[11] ;
   char             has_keys ;
   L4LIST           blocks ;

   #ifdef S4FOX
      char          p_char ;
   #endif

   #ifdef N4OTHER
      H4FILE        file ;
      int           file_locked ;
   #endif

   T4HEADER    header ;
   long        header_offset ;     /* Offset in file to the tag's header info. */
   int         root_write ;        /* True if 'header.root' needs to be written */
   long        lock_pos ;          /* The file offset to physically lock */
   int         key_dec ;
   L4LIST      saved ;
   int         debug_int ;         /* used to check structure integrity (set to 0x5281) */
} T4TAG ;

typedef struct
{
   char S4PTR *name ;
   char S4PTR *expression ;
   char S4PTR *filter ;
   int   unique ;
   int   descending ;
} T4TAG_INFO ;

typedef struct I4INDEX_st
{
   L4LINK  link ;

   H4FILE  file ;
   D4DATA S4PTR *data ;
   C4CODE S4PTR *code_base ;
   L4LIST  tags ;

   #ifdef S4FOX
      T4TAG *tag_index ;    /* the tags are a tag in the index file! */
      long  eof ;
   #else
      #ifdef N4OTHER
         char alias[11] ;
        char *path ;
      #else
         I4HEADER header ;
      #endif
   #endif

   Y4MEMORY_TYPE S4PTR *block_memory ;
   T4TAG  S4PTR *tag_locked ;     /* The locked tag.  Null if none. */
   int   file_locked ;    /* True if locked */
   long  version_old ;
} I4INDEX ;


/* Memo File Structures */

typedef struct
{
   #ifdef S4MFOX
      long  next_block ;  /* Memo Entry 1,2, ... */
      char  usused[2] ;
      short block_size ;  /* Bytes */
   #else
      #ifdef S4MNDX
         long  next_block ;  /* Memo Entry 1,2, ... */
      #else
         long  next_block ;  /* Memo Entry 1,2, ... */
         long  zero ;
         char  file_name[8] ;
         short zero2 ;
         short x102 ;
         short block_size ;  /* Bytes */
         short zero3 ;
      #endif
   #endif
} M4MEMO_HEADER ;

#ifndef S4MNDX
#ifndef S4MFOX
typedef struct
{
   long  next ;       /* The next free block area */
   long  num ;        /* The number of free blocks in the free block area */
   int   to_disk ;    /* TRUE if this information needs to be written to disk */
   long  block_no ;   /* The current block number */
} M4CHAIN_ENTRY ;
#endif /*  ifndef S4MFOX  */

typedef struct
{
   #ifdef S4MFOX
      long  type ;         /* 0 for picture, 1 for text -- picture not supported */
      long  num_chars ;    /* Including the 'MemoBlock' */
   #else
      short minus_one ;    /* '-1' for dBASE IV */
      short start_pos ;
      long  num_chars ;    /* Including the 'MemoBlock' */
   #endif
} M4MEMO_BLOCK ;
#endif  /*  ifndef S4MNDX  */

#ifdef S4UNIX
   typedef struct
   {
      unsigned  char  sig_dig ;  /* The number of significant digits; 52 is zero */
      unsigned  char  digit_info ; /* contains one, len and sign */
      unsigned  char  bcd[10] ;
   }  C4BCD ;
#else
   typedef struct
   {
      unsigned  sig_dig : 8 ;  /* The number of significant digits; 52 is zero */
      #ifndef __ZTC__
         /* Turbo C++ order */
         unsigned  one  : 2 ;     /* Always 1 */
         unsigned  len  : 5 ;     /* The number of encoded digits */
         unsigned  sign : 1 ;     /* The sign of the digits */
      #else
         #if __ZTC__ > 0x300   /* Zortech 3.0 is now compatible */
            unsigned  one  : 2 ;     /* Always 1 */
            unsigned  len  : 5 ;     /* The number of encoded digits */
            unsigned  sign : 1 ;     /* The sign of the digits */
         #else
            unsigned  sign : 1 ;     /* The sign of the digits */
            unsigned  len  : 5 ;     /* The number of encoded digits */
            unsigned  one  : 2 ;     /* Always 1 */
         #endif
      #endif
      unsigned  char  bcd[10] ;
   }  C4BCD ;
#endif

extern char   v4buffer[257] ;

#ifdef __cplusplus
   extern "C" {
#endif

void   S4FUNCTION a4assign( char S4PTR *, long ) ;
long   S4FUNCTION a4long( char S4PTR * ) ;  /* Date Arithmetic */
char S4PTR * S4FUNCTION a4cdow( char S4PTR * ) ;
char S4PTR * S4FUNCTION a4cmonth( char S4PTR * ) ;
int    S4FUNCTION a4day( char S4PTR * ) ;
int    S4FUNCTION a4dow( char S4PTR * ) ;
void   S4FUNCTION a4format( char S4PTR *, char S4PTR *, char S4PTR * ) ;/* 'dt' may be 'result'*/
int    S4FUNCTION a4format_mdx2( char S4PTR *, double S4PTR * ) ;
double S4FUNCTION a4format_mdx( char S4PTR *) ;
void   S4FUNCTION a4init( char S4PTR *, char S4PTR *, char S4PTR * ) ;
int    S4FUNCTION a4month( char S4PTR * ) ;
void   S4FUNCTION a4today( char S4PTR * ) ;
int    S4FUNCTION a4year( char S4PTR * ) ;
void   S4FUNCTION a4time_now( char S4PTR * ) ;

#ifdef S4FOX
int    S4FUNCTION b4back_skip( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION b4branch_skip( B4BLOCK S4PTR *, long ) ;
int    S4FUNCTION b4calc_blanks( char S4PTR *, int, char ) ;
int    S4FUNCTION b4calc_dups( char S4PTR *, char S4PTR *, int ) ;
int    S4FUNCTION b4bytes_reqd( B4BLOCK S4PTR *, INSERT_STRUCT S4PTR *, char S4PTR *, int ) ;
int    S4FUNCTION b4do_skip( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION b4go( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION b4insert_leaf( B4BLOCK S4PTR *, void S4PTR *, long ) ;
int    S4FUNCTION b4insert_branch( B4BLOCK S4PTR *, void S4PTR *, long, long, char ) ;
void   S4FUNCTION b4leaf_init( B4BLOCK * ) ;
int    S4FUNCTION b4cmp( B4BLOCK *, char *, char *, size_t, int, int ) ;
int    S4FUNCTION b4leaf_seek( B4BLOCK S4PTR *, char S4PTR *, int ) ;
int    S4FUNCTION b4rec_len( long ) ;
int    S4FUNCTION b4reindex( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4remove_leaf( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4remove_branch( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4br_replace( B4BLOCK S4PTR *, char S4PTR *, long ) ;
int    S4FUNCTION b4top( B4BLOCK S4PTR * ) ;
int    S4CALL     t4desc_memcmp( S4CMP_PARM, S4CMP_PARM, size_t ) ;
void   S4FUNCTION t4branch_split( T4TAG S4PTR *, B4BLOCK S4PTR *, B4BLOCK S4PTR * ) ;
void   S4FUNCTION t4leaf_split( T4TAG S4PTR *, B4BLOCK S4PTR *, B4BLOCK S4PTR * ) ;
int    S4FUNCTION t4r_seek( T4TAG S4PTR *, void S4PTR *, int, long ) ;
int    S4FUNCTION t4rl_bottom( T4TAG * ) ;
int    S4FUNCTION t4rl_top( T4TAG * ) ;
int    S4FUNCTION b4r_brseek( B4BLOCK S4PTR *, char S4PTR *, int, long ) ;
long   S4FUNCTION x4recno( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION x4dup_cnt( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION x4trail_cnt( B4BLOCK S4PTR *, int ) ;
void   S4FUNCTION x4put_info( B4NODE_HEADER S4PTR *, void S4PTR *, long, int, int ) ;
int    S4FUNCTION b4insert( B4BLOCK S4PTR *, void S4PTR *, long, long, char ) ;
int    S4FUNCTION b4skip( B4BLOCK S4PTR *, long, int ) ;
int    S4FUNCTION t4init( T4TAG S4PTR *, I4INDEX S4PTR *, long, long, char S4PTR *) ;
#else
   #ifdef N4OTHER
      void   S4FUNCTION b4append( B4BLOCK S4PTR *, long ) ;
      int    S4FUNCTION b4skip( B4BLOCK S4PTR *, long ) ;
      void   S4FUNCTION b4insert( B4BLOCK S4PTR *, void S4PTR *, long, long ) ;
      #ifdef S4NDX
         int    S4FUNCTION b4find( B4BLOCK S4PTR *, long, B4BLOCK S4PTR * ) ;
         int    S4FUNCTION b4get_last_key( B4BLOCK S4PTR *, char S4PTR * ) ;
         int    S4FUNCTION i4get_last_key( T4TAG S4PTR *,char S4PTR *, long ) ;
      #else
         #ifdef S4CLIPPER
         int    S4FUNCTION c4clip( char S4PTR *, int ) ;
         void   S4FUNCTION b4append2( B4BLOCK S4PTR *, void S4PTR *, long, long ) ;
         void   S4FUNCTION t4remove_ref( T4TAG S4PTR * ) ;
         int    S4FUNCTION t4get_replace_entry( T4TAG S4PTR *, B4KEY_DATA S4PTR *, B4BLOCK S4PTR * ) ;
         int    S4FUNCTION t4shrink( T4TAG S4PTR *, long ) ;
         #endif
      #endif
      int    S4FUNCTION b4room( B4BLOCK S4PTR * ) ;
      int    S4FUNCTION t4close( T4TAG S4PTR * ) ;
      long   S4FUNCTION t4extend( T4TAG S4PTR * ) ;
      T4TAG *S4FUNCTION t4open( D4DATA S4PTR *, I4INDEX S4PTR *, char S4PTR * ) ;
      int    S4FUNCTION t4update_header( T4TAG S4PTR * ) ;
      int    S4FUNCTION t4version_check( T4TAG S4PTR* ) ;
      T4TAG *S4FUNCTION t4create( D4DATA S4PTR *, T4TAG_INFO S4PTR *, I4INDEX S4PTR * ) ;
      int    S4FUNCTION t4reindex( T4TAG S4PTR * ) ;
   #else
      void   S4FUNCTION b4insert( B4BLOCK S4PTR *, void S4PTR *, long ) ;
      int    S4FUNCTION b4skip( B4BLOCK S4PTR *, long ) ;
      int    S4FUNCTION t4init( T4TAG S4PTR *, I4INDEX S4PTR *, T4DESC S4PTR *, long ) ;
   #endif
#endif

#ifdef S4NDX
int S4FUNCTION b4find( B4BLOCK S4PTR *, long, B4BLOCK S4PTR * ) ;
int S4FUNCTION b4get_last_key( B4BLOCK S4PTR *, char S4PTR * ) ;
int S4FUNCTION i4get_last_key( T4TAG S4PTR *, char S4PTR *, long ) ;
#endif

B4BLOCK S4PTR *S4FUNCTION b4alloc( T4TAG S4PTR *, long ) ;
int    S4FUNCTION b4flush( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4free( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4go_eof( B4BLOCK S4PTR * ) ;
B4KEY_DATA S4PTR * S4FUNCTION b4key( B4BLOCK S4PTR *, int ) ;
unsigned char S4PTR * S4FUNCTION b4key_key( B4BLOCK S4PTR *, int ) ;
int    S4FUNCTION b4lastpos( B4BLOCK S4PTR * ) ;
int    S4FUNCTION b4leaf( B4BLOCK S4PTR * ) ;
long   S4FUNCTION b4recno( B4BLOCK S4PTR * ) ;
void   S4FUNCTION b4remove( B4BLOCK S4PTR *);
int    S4FUNCTION b4seek( B4BLOCK S4PTR *, char S4PTR *, int ) ;

int    S4FUNCTION c4atod2( char S4PTR *, int, double S4PTR * ) ;
double S4FUNCTION c4atod( char S4PTR *, int) ;
int    S4FUNCTION c4atoi( char S4PTR *, int) ;
long   S4FUNCTION c4atol( char S4PTR *, int) ;

int S4CALL c4bcd_cmp( S4CMP_PARM, S4CMP_PARM, size_t ) ;

#ifndef S4FOX
   #ifdef S4UNIX
      void c4bcd_from_a( char S4PTR *, char S4PTR *, int ) ;
      void t4str_to_date_mdx( char S4PTR *, char S4PTR *, int ) ;
      void t4no_change_str( char S4PTR *, char S4PTR *, int ) ;
      void c4bcd_from_d( char S4PTR *, double ) ;
      void t4no_change_double( char S4PTR *, double ) ;
   #else
      C4STOK c4bcd_from_a ;
      C4DTOK c4bcd_from_d ;
   #endif
#else
   C4STOK t4dtstr_to_fox ;
   C4STOK t4str_to_fox ;
   C4DTOK t4dbl_to_fox ;
#endif

void   S4FUNCTION c4dtoa45( double, char S4PTR *, int, int) ;
void   S4FUNCTION c4encode( char S4PTR *, char S4PTR *, char S4PTR *, char S4PTR *) ;
void   S4FUNCTION c4lower( char S4PTR * ) ;
void   S4FUNCTION c4ltoa45( long, char S4PTR *, int) ;
void   S4FUNCTION c4trim_n( char S4PTR *, int ) ;
void   S4FUNCTION c4upper( char S4PTR * ) ;

#ifdef S4VBASIC
   int c4parm_check( void *, int, char * ) ;
#endif   

char S4PTR * S4FUNCTION d4alias( D4DATA S4PTR * ) ;
void   S4FUNCTION d4alias_set( D4DATA S4PTR *, char S4PTR * ) ;
int    S4FUNCTION d4append( D4DATA S4PTR * ) ;
int    S4FUNCTION d4append_data( D4DATA S4PTR * ) ;
int    S4FUNCTION d4append_blank( D4DATA S4PTR * ) ;
int    S4FUNCTION d4append_start( D4DATA S4PTR *, int ) ;
void   S4FUNCTION d4blank( D4DATA S4PTR * ) ;
int    S4FUNCTION d4bof( D4DATA S4PTR * ) ;
int    S4FUNCTION d4bottom( D4DATA S4PTR * ) ;
int    S4FUNCTION d4check( D4DATA S4PTR * ) ;
int    S4FUNCTION d4close( D4DATA S4PTR * ) ;
int    S4FUNCTION d4close_all( C4CODE S4PTR * ) ;
D4DATA S4PTR * S4FUNCTION d4create( C4CODE S4PTR *, char S4PTR *, F4FIELD_INFO S4PTR *, T4TAG_INFO S4PTR * ) ;
D4DATA S4PTR * S4FUNCTION d4data( C4CODE S4PTR *, char S4PTR * ) ;
void   S4FUNCTION d4delete( D4DATA S4PTR * ) ;
int    S4FUNCTION d4deleted( D4DATA S4PTR * ) ;
int    S4FUNCTION d4eof( D4DATA S4PTR * ) ;
F4FIELD S4PTR * S4FUNCTION d4field( D4DATA S4PTR *, char S4PTR * ) ;
F4FIELD S4PTR * S4FUNCTION d4field_j( D4DATA S4PTR *, int ) ;
int    S4FUNCTION d4field_number( D4DATA S4PTR *, char S4PTR * ) ;
int    S4FUNCTION d4flush_all( D4DATA S4PTR * ) ;
int    S4FUNCTION d4flush_record( D4DATA S4PTR * ) ;
int    S4FUNCTION d4free_blocks( D4DATA S4PTR * ) ;
int    S4FUNCTION d4go( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4go_data( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4go_eof( D4DATA S4PTR * ) ;
I4INDEX S4PTR * S4FUNCTION d4index( D4DATA S4PTR *, char S4PTR * ) ;
void   S4FUNCTION d4init( C4CODE S4PTR * ) ;
int    S4FUNCTION d4init_undo( C4CODE S4PTR * ) ;
int    S4FUNCTION d4lock( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4lock_append( D4DATA S4PTR * ) ;
int    S4FUNCTION d4lock_file( D4DATA S4PTR * ) ;
int    S4FUNCTION d4lock_index( D4DATA S4PTR * ) ;
int    S4FUNCTION d4lock_group( D4DATA S4PTR *, long S4PTR *, int ) ;
int    S4FUNCTION d4lock_test( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4lock_test_file( D4DATA S4PTR * ) ;
int    S4FUNCTION d4lock_test_append( D4DATA S4PTR * ) ;
int    S4FUNCTION d4memo_compress( D4DATA S4PTR * ) ;
int    S4FUNCTION d4num_fields ( D4DATA S4PTR * ) ;
D4DATA S4PTR *S4FUNCTION d4open( C4CODE S4PTR *, char S4PTR * ) ;
int    S4FUNCTION d4pack( D4DATA S4PTR * ) ;
int    S4FUNCTION d4pack_data( D4DATA S4PTR * ) ;
int    S4FUNCTION d4position2( D4DATA S4PTR *, double S4PTR * ) ;
double S4FUNCTION d4position( D4DATA S4PTR * ) ;
int    S4FUNCTION d4position_set( D4DATA S4PTR *, double ) ;
int    S4FUNCTION d4read( D4DATA S4PTR *, long, char S4PTR * ) ;
int    S4FUNCTION d4read_old( D4DATA S4PTR *, long ) ;
void   S4FUNCTION d4recall( D4DATA S4PTR * ) ;
long   S4FUNCTION d4reccount( D4DATA S4PTR * ) ;
long   S4FUNCTION d4recno( D4DATA S4PTR * ) ;
char  S4PTR *S4FUNCTION d4record( D4DATA S4PTR * ) ;
long   S4FUNCTION d4record_width( D4DATA S4PTR * ) ;
long   S4FUNCTION d4rec_pos( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4reindex( D4DATA S4PTR * ) ;
int    S4FUNCTION d4seek( D4DATA S4PTR *, char S4PTR * ) ;
int    S4FUNCTION d4seek_double( D4DATA S4PTR *, double ) ;
int    S4FUNCTION d4skip( D4DATA S4PTR *, long ) ;
T4TAG S4PTR *S4FUNCTION d4tag( D4DATA S4PTR *, char S4PTR * ) ;
T4TAG S4PTR *S4FUNCTION d4tag_default( D4DATA S4PTR * ) ;
T4TAG S4PTR *S4FUNCTION d4tag_next( D4DATA S4PTR *, T4TAG S4PTR * ) ;
T4TAG S4PTR *S4FUNCTION d4tag_prev( D4DATA S4PTR *, T4TAG S4PTR * ) ;
void   S4FUNCTION d4tag_select( D4DATA S4PTR *, T4TAG S4PTR * ) ;
T4TAG S4PTR *S4FUNCTION d4tag_selected( D4DATA S4PTR * ) ;
int    S4FUNCTION d4top( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_all( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_all_data( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_append( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_file( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_index( D4DATA S4PTR * ) ;
int    S4FUNCTION d4unlock_records( D4DATA S4PTR * ) ;
int    S4FUNCTION d4update_header( D4DATA S4PTR *, int, int ) ;
int    S4FUNCTION d4validate_memo_ids( D4DATA S4PTR * ) ;
int    S4FUNCTION d4write( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4write_data( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4write_keys( D4DATA S4PTR *, long ) ;
int    S4FUNCTION d4zap( D4DATA S4PTR *, long, long ) ;
int    S4FUNCTION d4zap_data( D4DATA S4PTR *, long, long ) ;

int    S4FUNCTION e4error_set( C4CODE S4PTR *, int ) ;
void   S4FUNCTION e4exit(C4CODE S4PTR *) ;
void   S4FUNCTION e4exit_test( C4CODE S4PTR * ) ;

#ifdef S4VARARGS
   int    S4ERROR    e4error( ) ;
   void   S4ERROR    e4severe( ) ;
#else
   int    S4ERROR    e4error( C4CODE S4PTR *, int, char *, ... ) ;
   void   S4ERROR    e4severe( int, char *, ... ) ;
   #ifdef S4VBASIC
      void   S4ERROR   e4severe_vbasic( int, char *, ... ) ;
   #endif
#endif

void   S4FUNCTION f4assign( F4FIELD S4PTR *, char S4PTR * ) ;
void   S4FUNCTION f4assign_char( F4FIELD S4PTR *, int ) ;
void   S4FUNCTION f4assign_double( F4FIELD S4PTR *, double ) ;
void   S4FUNCTION f4assign_int( F4FIELD S4PTR *, int ) ;
void   S4FUNCTION f4assign_long( F4FIELD S4PTR *, long ) ;
void   S4FUNCTION f4assign_n( F4FIELD S4PTR *, char S4PTR *, unsigned ) ;
char S4PTR * S4FUNCTION f4assign_ptr( F4FIELD S4PTR * ) ;
void   S4FUNCTION f4blank( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4char( F4FIELD S4PTR * ) ;
D4DATA S4PTR *S4FUNCTION f4data( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4decimals( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4double2( F4FIELD S4PTR *, double S4PTR * ) ;
double S4FUNCTION f4double( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4int( F4FIELD S4PTR * ) ;
unsigned  S4FUNCTION f4len( F4FIELD S4PTR * ) ;
long   S4FUNCTION f4long( F4FIELD S4PTR * ) ;
char S4PTR * S4FUNCTION f4name( F4FIELD S4PTR * ) ;
unsigned S4FUNCTION f4ncpy( F4FIELD S4PTR *, char S4PTR *, unsigned ) ;
char S4PTR * S4FUNCTION f4ptr( F4FIELD S4PTR * ) ;
char S4PTR * S4FUNCTION f4str( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4true( F4FIELD S4PTR * ) ;
int    S4FUNCTION f4type( F4FIELD S4PTR * ) ;

int    S4FUNCTION h4close( H4FILE S4PTR * ) ;
int    S4FUNCTION h4create( H4FILE S4PTR *, C4CODE S4PTR *, char S4PTR *, int ) ;
long   S4FUNCTION h4length( H4FILE S4PTR * ) ;
int    S4FUNCTION h4length_set( H4FILE S4PTR *, long ) ;
int    S4FUNCTION h4lock( H4FILE S4PTR *, long, long ) ;
int    S4FUNCTION h4open( H4FILE S4PTR *, C4CODE S4PTR *, char S4PTR *, int ) ;
int    S4FUNCTION h4open_test( H4FILE S4PTR * ) ;
unsigned  S4FUNCTION h4read( H4FILE S4PTR *, long, void S4PTR *, unsigned ) ;
int    S4FUNCTION h4read_all( H4FILE S4PTR *, long, void S4PTR *, unsigned ) ;
int    S4FUNCTION h4read_error( H4FILE S4PTR * ) ;
int    S4FUNCTION h4replace( H4FILE S4PTR *, H4FILE S4PTR * ) ;
int    S4FUNCTION h4temp( H4FILE S4PTR *, C4CODE S4PTR *, char S4PTR *, int ) ;
int    S4FUNCTION h4unlock( H4FILE S4PTR *, long, long ) ;
int    S4FUNCTION h4write( H4FILE S4PTR *, long, void S4PTR *, unsigned ) ;

void   S4FUNCTION h4seq_read_init( H4SEQ_READ S4PTR *, H4FILE S4PTR *, long, void S4PTR *, unsigned ) ;
unsigned  S4FUNCTION h4seq_read( H4SEQ_READ S4PTR *, void S4PTR *, unsigned ) ;
int    S4FUNCTION h4seq_read_all( H4SEQ_READ S4PTR *, void S4PTR *, unsigned ) ;

void   S4FUNCTION h4seq_write_init( H4SEQ_WRITE S4PTR *, H4FILE S4PTR *, long, void S4PTR *, unsigned ) ;
int    S4FUNCTION h4seq_write( H4SEQ_WRITE S4PTR *, void S4PTR *, unsigned ) ;
int    S4FUNCTION h4seq_write_flush( H4SEQ_WRITE S4PTR * ) ;
int    S4FUNCTION h4seq_write_repeat( H4SEQ_WRITE S4PTR *, long, char ) ;

int    S4FUNCTION i4check( I4INDEX S4PTR * ) ;
int    S4FUNCTION i4close( I4INDEX S4PTR * ) ;
I4INDEX S4PTR *S4FUNCTION i4create( D4DATA S4PTR *, char S4PTR *, T4TAG_INFO S4PTR * ) ; /* 0 name -> productn */
long   S4FUNCTION i4extend( I4INDEX S4PTR * ) ;   /* Allocates a block at the end of the file */
int    S4FUNCTION i4flush( I4INDEX S4PTR * ) ;
int    S4FUNCTION i4lock( I4INDEX S4PTR * ) ;
I4INDEX S4PTR *S4FUNCTION i4open( D4DATA S4PTR *, char S4PTR * ) ;
int    S4FUNCTION i4reindex( I4INDEX S4PTR * ) ;
int    S4FUNCTION i4shrink( I4INDEX S4PTR *, long ) ;  /* Returns a block of disk space */
T4TAG S4PTR *S4FUNCTION i4tag( I4INDEX S4PTR *, char S4PTR * ) ;
int    S4FUNCTION i4unlock( I4INDEX S4PTR * ) ;
int    S4FUNCTION i4update_header( I4INDEX S4PTR * ) ;
int    S4FUNCTION i4version_check( I4INDEX S4PTR * ) ;

void   S4FUNCTION l4add( L4LIST S4PTR *, void S4PTR * ) ;
void   S4FUNCTION l4add_after(   L4LIST S4PTR *, void S4PTR *, void S4PTR * ) ;
void   S4FUNCTION l4add_before( L4LIST S4PTR *, void S4PTR *, void S4PTR * ) ;
void   l4check( L4LIST S4PTR * ) ;
void S4PTR * S4FUNCTION l4first( L4LIST S4PTR * ) ;  /* Returns 0 if none */
void S4PTR * S4FUNCTION l4last( L4LIST S4PTR * ) ;   /* Returns 0 if none */
void S4PTR * S4FUNCTION l4next( L4LIST S4PTR *, void S4PTR * ) ;  /* Returns 0 if none */
void S4PTR * S4FUNCTION l4prev( L4LIST S4PTR *, void S4PTR * ) ;
void S4PTR * S4FUNCTION l4pop( L4LIST S4PTR * ) ;
void   S4FUNCTION l4remove( L4LIST S4PTR *, void S4PTR * ) ;

int    S4FUNCTION l4lock_check( void ) ;
void   l4lock_remove( int,long,long) ;
void   l4lock_save( int,long,long) ;

#ifndef S4MFOX
#ifndef S4MNDX
int    m4file_chain_flush( M4FILE S4PTR *, M4CHAIN_ENTRY S4PTR * ) ;
int    m4file_chain_skip( M4FILE S4PTR *, M4CHAIN_ENTRY S4PTR * ) ;
int    S4FUNCTION m4check( M4FILE S4PTR * ) ;
#endif  /*  ifndef S4MFOX  */
#endif  /*  ifndef S4MNDX  */

int    m4file_check( M4FILE S4PTR * ) ;
int    m4file_create( M4FILE S4PTR *, C4CODE S4PTR *, D4DATA S4PTR *, char S4PTR * );
          /* if (name == 0), it is a temporary file */
int    m4file_dump( M4FILE S4PTR *, long, char S4PTR *, unsigned ) ; 
int    m4file_open( M4FILE S4PTR *, D4DATA S4PTR *, char S4PTR * ) ;
int    m4file_read( M4FILE S4PTR *, long , char S4PTR **, unsigned S4PTR * ) ;
int    m4file_write( M4FILE S4PTR *, long S4PTR *, char S4PTR *, unsigned ) ; /* Pass the old id */

int    S4FUNCTION m4assign( F4FIELD S4PTR *, char S4PTR * ) ;
int    S4FUNCTION m4assign_n( F4FIELD S4PTR *, char S4PTR *, unsigned ) ;
unsigned S4FUNCTION m4len( F4FIELD S4PTR * ) ;
unsigned S4FUNCTION m4ncpy( F4FIELD S4PTR *, char S4PTR *, unsigned ) ;
int    S4FUNCTION m4set_len( F4FIELD S4PTR *, unsigned ) ;
char   S4PTR * S4FUNCTION m4str( F4FIELD S4PTR * ) ;
char   S4PTR * S4FUNCTION m4ptr( F4FIELD S4PTR * ) ;

int    S4FUNCTION m4flush( F4FIELD S4PTR * ) ;
void   S4FUNCTION m4free( F4FIELD S4PTR * ) ;
int    S4FUNCTION m4read( F4FIELD S4PTR * ) ;       /* Validates memo id's first */
int    S4FUNCTION m4read_low( F4FIELD S4PTR * ) ;   /* Assumes the current memo id is valid */
void   S4FUNCTION m4reset( F4FIELD S4PTR * ) ;      /* Resets to 'Unknown state' */
int    S4FUNCTION m4write( F4FIELD S4PTR * ) ;

int    S4FUNCTION t4add( T4TAG S4PTR *, unsigned char S4PTR *, long ) ;  /* Returns r4unique, r4success, r4repeat */
int    S4FUNCTION t4add_calc( T4TAG S4PTR *, long ) ; /* Calculates expression and adds */
B4BLOCK S4PTR *S4FUNCTION t4block( T4TAG S4PTR * ) ;
int    S4FUNCTION t4bottom( T4TAG S4PTR * ) ;
int    S4FUNCTION t4check( T4TAG S4PTR * ) ;
int    S4FUNCTION t4down( T4TAG S4PTR * ) ;
int    S4FUNCTION t4dump( T4TAG S4PTR *, int, int ) ;
int    S4FUNCTION t4eof( T4TAG S4PTR * ) ;
int    S4FUNCTION t4flush( T4TAG S4PTR * ) ;
int    S4FUNCTION t4free_all( T4TAG S4PTR * ) ;
int    S4FUNCTION t4free_saved( T4TAG S4PTR * ) ;
int    S4FUNCTION t4go( T4TAG S4PTR *, char S4PTR *, long ) ;
void   S4FUNCTION t4init_seek_conv( T4TAG S4PTR *, int) ;    /* Initialize 'stok' and 'dtok' */
B4KEY_DATA S4PTR *S4FUNCTION t4key( T4TAG S4PTR * ) ;              /* The current key */
int    S4FUNCTION t4lock( T4TAG S4PTR * ) ;
int    S4FUNCTION t4position2( T4TAG S4PTR *, double S4PTR * ) ;     
double S4FUNCTION t4position( T4TAG S4PTR * ) ;              /* Returns the position as a percent */
int    S4FUNCTION t4position_set( T4TAG S4PTR *, double ) ;  /* Positions a percentage */
long   S4FUNCTION t4recno( T4TAG S4PTR * ) ;
int    S4FUNCTION t4remove_current( T4TAG S4PTR * ) ;        /* Remove the current key */
int    S4FUNCTION t4remove( T4TAG S4PTR *, char S4PTR *, long ) ;  /* Remove specified key */
int    S4FUNCTION t4remove_calc( T4TAG S4PTR *, long ) ; /* Calculates expression and removes */
int    S4FUNCTION t4seek( T4TAG S4PTR *, void S4PTR *, int ) ;    /* r4success, r4found, r4after, r4eof */
long   S4FUNCTION t4skip( T4TAG S4PTR *, long ) ;
B4BLOCK S4PTR *S4FUNCTION t4split( T4TAG S4PTR *, B4BLOCK S4PTR * ) ;
int    S4FUNCTION t4top( T4TAG S4PTR * ) ;
int    S4FUNCTION t4type( T4TAG S4PTR * ) ;
int    S4FUNCTION t4up( T4TAG S4PTR * ) ;
int    S4FUNCTION t4up_to_root( T4TAG S4PTR * ) ;

/* File name lengths include one extra null character at end */
int    S4FUNCTION u4name_char( char ) ;
void   S4FUNCTION u4name_ext( char S4PTR *, int, char S4PTR *, int ) ;
void   S4FUNCTION u4name_piece( char S4PTR *, int, char S4PTR *, int, int ) ;
int    S4FUNCTION u4name_path( char S4PTR *, int, char S4PTR * ) ;

#ifdef S4WINDOWS
   int S4FUNCTION u4commit( D4DATA S4PTR * ) ;
#endif
unsigned S4FUNCTION u4ncpy( char S4PTR *, char S4PTR *, unsigned ) ;
int    S4FUNCTION u4ptr_equal( void S4PTR *, void S4PTR * ) ;
int    S4FUNCTION u4remove( char S4PTR * ) ;
void   S4FUNCTION u4yymmdd( char S4PTR * ) ;
int    S4FUNCTION u4rename( char S4PTR *, char S4PTR * ) ;

#ifdef S4CLIPPER
   char S4PTR * S4FUNCTION u4descend_char(char S4PTR*);
   char S4PTR * S4FUNCTION u4descend_date(char S4PTR*);
   char S4PTR * S4FUNCTION u4descend_num(char S4PTR*);
   char S4PTR * S4FUNCTION u4descend(F4FIELD S4PTR*);
#endif

void  S4PTR *S4FUNCTION u4alloc( long ) ;
int    S4FUNCTION u4alloc_again( C4CODE S4PTR *, char S4PTR **, unsigned S4PTR *, unsigned ) ;
void   S4FUNCTION u4free( void S4PTR * ) ;
short  S4FUNCTION x4reverse_short( short ) ;
long   S4FUNCTION x4reverse_long( long ) ;

void  S4PTR *S4FUNCTION y4alloc( Y4MEMORY_TYPE S4PTR * ) ;  /* 0 Parm causes 0 return */
Y4CHUNK S4PTR *S4FUNCTION y4alloc_chunk( Y4MEMORY_TYPE S4PTR * ) ;  /* 0 Parm causes 0 return */
void   S4FUNCTION y4free( Y4MEMORY_TYPE S4PTR *, void S4PTR * ) ;
int    S4FUNCTION y4free_check( int ) ;
void   S4FUNCTION y4check_memory( void ) ;
void   S4FUNCTION y4init( void ) ;
Y4MEMORY_TYPE S4PTR *S4FUNCTION y4memory_type( int, unsigned, int, int ) ;
void  S4PTR *S4FUNCTION y4memory_type_alloc( Y4MEMORY_TYPE S4PTR **, int, unsigned, int, int ) ;
void   S4FUNCTION y4release( Y4MEMORY_TYPE S4PTR * ) ;
void   S4FUNCTION y4reset( void ) ;

int S4CALL u4memcmp( S4CMP_PARM, S4CMP_PARM, size_t ) ;

#ifdef __cplusplus
   }
#endif


