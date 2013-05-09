/* e4expr.h   (c)Copyright Sequiter Software Inc., 1990-1992.  All rights reserved. */

#define E4PARM_STACK_SIZE 20
#define E4MAX_PARMS 3

extern unsigned e4buf_len ;
extern char    S4PTR *e4buf ;

typedef struct
{
   char    S4PTR *ptr ;         /* The original string */
   int      pos, len ;    /* Source expression position and length */
} S4SCAN ;

typedef struct
{
   char S4PTR *ptr ;
   int   pos, len ;
   int   do_extend ;
   C4CODE S4PTR *code_base ;
} S4STACK ;

typedef struct parse_parm_st
{
   char    S4PTR *ptr ;
   int      type ;
} E4PARSE_PARM ;

typedef struct 
{
   unsigned pos ;       /* Parameter position within the string */
   int      type ;      /* The type of the parameter */
   unsigned len ;       /* The number of bytes in the parameter */
} E4EXPR_PARM ;

typedef struct 
{
   E4EXPR_PARM  parms[E4PARM_STACK_SIZE] ;
   int     on_parm ;
   D4DATA S4PTR *data ;
   C4CODE S4PTR *code_base ;
} E4PARMS ;

typedef struct
{
   E4EXPR   expr ;

   S4SCAN   scan ;     /* Character Expression */
   S4STACK  op ;    /* Operation stack */
   S4STACK  result ;
   C4CODE  S4PTR *code_base ;
} E4PARSE ;

typedef struct
{
   int      code ;
   int      name_len ;
   char     name[12] ;
   #ifdef S4UNIX
      void     (S4PTR *function_ptr)() ;
   #else
      void     (S4PTR *function_ptr)(E4PARMS S4PTR *) ;
   #endif
   int      priority ;
   int      return_type ;
   int      num_parms ;             /* 0 - No Return;  -1 First Parm. Specifies # */
   int      type[E4MAX_PARMS] ;        /* type[0] is the return type */
}  E4FUNCTIONS ;

/* Integer Codes for Function/Operator parameters and returns */
#define  t4num_str   'n'
#define  t4num_doub  'F'
#define  t4num_bcd   'N'
#define  t4date_doub 'D'
#define  t4date_str  'd'
#define  t4str       'C'
#define  t4log       'L'
#ifdef S4CLIPPER
#define  t4num_clip  'c'
#endif
#ifdef S4FOX
   #define  t4num_fox       'f'
   #define  t4date_fox      'x'
#endif


/* This section specifies the breakdown of the functions in file 'e4functi.c'. */

/* Codes for Immediate Data in Compile String */
#define  I4FIELD_STR        0
#define  I4FIELD_LOG        1
#define  I4FIELD_DATE_D     2
#define  I4FIELD_DATE_S     3
#define  I4FIELD_NUM_D      4
#define  I4FIELD_NUM_S      5
#define  I4FIELD_MEMO       6

#define  LAST_I4FIELD       5

#define  I4STRING           6
#define  I4DOUBLE           7

#define  I4LAST_IMMEDIATE   7


#define  E4FIRST_LOG          8  /* Range of Logical Operators */
#define  E4LAST_LOG          12
         
#define  E4FIRST_OPERATOR    13  /* Range of Other Operators */
#define  E4LAST_OPERATOR     48

#define  E4FIRST_FUNCTION    49  /* Start of the List of Functions */

/* Additional Definitions */

extern E4FUNCTIONS  v4functions[] ;

#define E4OPERATOR_LEN  128

/* Quasi Operators */
#define  Q4NO_FUNCTION  -2
#define  Q4L_BRACKET    -3
#define  Q4R_BRACKET    -4
#define  Q4COMMA        -5

#ifdef __cplusplus
   extern "C" {
#endif

double  S4FUNCTION e4double( E4EXPR S4PTR * ) ;
void    S4FUNCTION e4free( E4EXPR S4PTR * ) ;
int     S4FUNCTION e4key( E4EXPR S4PTR *, char S4PTR ** ) ;
E4EXPR S4PTR *S4FUNCTION e4parse( D4DATA S4PTR *, char S4PTR * ) ;
char S4PTR *  S4FUNCTION e4source( E4EXPR S4PTR * ) ;
int     S4FUNCTION e4true( E4EXPR S4PTR * ) ;
int     S4FUNCTION e4type( E4EXPR S4PTR * ) ;
int        S4FUNCTION e4vary( E4EXPR S4PTR *, char S4PTR ** ) ;

#ifdef __cplusplus
   }
#endif

int    e4field_function( F4FIELD S4PTR *) ;
int    e4get_f_code( E4PARSE S4PTR *, char S4PTR *, E4PARSE_PARM S4PTR * ) ;
int    e4get_operator( E4PARSE S4PTR *, int S4PTR * ) ;
int    e4lookup( char S4PTR *,int,int,int ) ;
int    e4parse_expr( E4PARSE S4PTR * ) ;
int    e4parse_function( E4PARSE S4PTR *, char S4PTR *,int ) ;
int    e4parse_value( E4PARSE S4PTR * ) ;
int    e4type_check( E4PARSE S4PTR * ) ;

char   s4scan_char( S4SCAN S4PTR * ) ;
void   s4scan_init( S4SCAN S4PTR *, char S4PTR * ) ;
char   s4scan_pop( S4SCAN S4PTR *) ; /* Returns current char and goes to the next */
int    s4scan_search( S4SCAN S4PTR *, char ) ; /* Returns # of characters scanned */
int    s4scan_range( S4SCAN S4PTR *, char, char ) ;

int    s4stack_cur( S4STACK S4PTR * ) ;
int    s4stack_pop( S4STACK S4PTR * ) ;
int    s4stack_push_int( S4STACK S4PTR *, int ) ;
int    s4stack_push_str( S4STACK S4PTR *, void S4PTR *, int ) ;

void   e4parms_set( E4PARMS S4PTR *, void S4PTR *, unsigned, int ) ;
void   e4parms_set_logical( E4PARMS S4PTR *, int ) ;
void   e4parms_set_double( E4PARMS S4PTR *, double ) ;
#ifdef S4FOX
   char  S4PTR *e4parms_int_ptr( E4PARMS S4PTR *, int ) ;
#else
   int   S4PTR *e4parms_int_ptr( E4PARMS S4PTR *, int ) ;
#endif
double S4PTR *e4parms_double_ptr( E4PARMS S4PTR *, int ) ;

void   e4parms_init( E4PARMS S4PTR *, D4DATA S4PTR * ) ;
int    e4parms_check( E4PARMS S4PTR * ) ;
int    e4parms_pop( E4PARMS S4PTR *, int ) ;
void   e4parms_pos_align( E4PARMS S4PTR *) ;
void   e4parms_fix_pos( E4PARMS S4PTR * );
int    e4parms_push( E4PARMS S4PTR * ) ;

int    e4parms_space_reserve( E4PARMS S4PTR *, unsigned ) ;

void   e4true_eval(E4PARMS S4PTR *) ;
void   e4false(E4PARMS S4PTR *) ;
void   e4add(E4PARMS S4PTR *) ;
void   e4concatenate(E4PARMS S4PTR *) ;
void   e4sub(E4PARMS S4PTR *) ;
void   e4concat_two(E4PARMS S4PTR *) ;
void   e4multiply(E4PARMS S4PTR *) ;
void   e4divide(E4PARMS S4PTR *) ;
void   e4power(E4PARMS S4PTR *) ;
void   e4not_equal(E4PARMS S4PTR *) ;
void   e4equal(E4PARMS S4PTR *) ;
void   e4greater(E4PARMS S4PTR *) ;
void   e4less(E4PARMS S4PTR *) ;
void   e4greater_eq(E4PARMS S4PTR *) ;
void   e4less_eq(E4PARMS S4PTR *) ;
void   e4not(E4PARMS S4PTR *) ;
void   e4or(E4PARMS S4PTR *) ;
void   e4and(E4PARMS S4PTR *) ;
void   e4ctod(E4PARMS S4PTR *) ;
void   e4dtoc(E4PARMS S4PTR *) ;
void   e4dtos(E4PARMS S4PTR *) ;
void   e4stod(E4PARMS S4PTR *) ;
void   e4date(E4PARMS S4PTR *) ;
void   e4year(E4PARMS S4PTR *) ;
void   e4month(E4PARMS S4PTR *) ;
void   e4day(E4PARMS S4PTR *) ;
void   e4del(E4PARMS S4PTR *) ;
void   e4deleted(E4PARMS S4PTR *) ;
void   e4iif(E4PARMS S4PTR *) ;
void   e4reccount(E4PARMS S4PTR *) ;
void   e4recno(E4PARMS S4PTR *) ;
void   e4str(E4PARMS S4PTR *) ;
void   e4substr(E4PARMS S4PTR *) ;
void   e4time(E4PARMS S4PTR *) ;
void   e4upper(E4PARMS S4PTR *) ;
void   e4val(E4PARMS S4PTR *) ;
void   e4contain(E4PARMS S4PTR *) ;

#ifdef S4CLIPPER
   void e4descend(E4PARMS S4PTR *);
#endif
