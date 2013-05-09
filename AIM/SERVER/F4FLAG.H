/* f4flag.h   (c)Copyright Sequiter Software Inc., 1990-1992.  All rights reserved. */

typedef struct
{
   C4CODE S4PTR *code_base ;
   unsigned char S4PTR *flags ;
   long     num_flags ;
} F4FLAG ;

#ifdef __cplusplus
   extern "C" {
#endif

int  f4flag_init( F4FLAG S4PTR *, C4CODE S4PTR *, long ) ;
int  f4flag_set( F4FLAG S4PTR *, long ) ;
int  f4flag_set_range( F4FLAG S4PTR *, long, long ) ;
int  f4flag_is_set( F4FLAG S4PTR *, long ) ;
int  f4flag_is_all_set( F4FLAG S4PTR *, long, long ) ;
int  f4flag_is_any_set( F4FLAG S4PTR *, long, long ) ;

#ifdef __cplusplus
   }
#endif

