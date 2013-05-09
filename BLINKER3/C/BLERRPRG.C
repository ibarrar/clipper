/*****************************************************************
*
*  Program  : BLERRPRG.C
*           : Blinker / C Error Handler
*  Date     : 93.03.26
*
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
*/

#include <process.h>
#include <stdio.h>
#include <string.h>

#include <blinker.h>

void blerrprg(void)
{

  int   tmperrnum;
  char  tmperrmsg [128];
  char  errparam [128];

  tmperrnum = BLIERRNUM();
  strcpy (errparam,BLIERRPRM());

  switch (tmperrnum)
  {
     case 1201 : strcpy(tmperrmsg, "unable to find overlay ") ;
		 strcat(tmperrmsg, errparam) ;
		 strcat(tmperrmsg, " in the current PATH") ;
		 break ;

     case 1202 : strcpy(tmperrmsg, "DOS read error in file ") ;
		 strcat(tmperrmsg, errparam) ;
		 break ;

     case 1203 : strcpy(tmperrmsg, "file ") ;
		 strcat(tmperrmsg, errparam) ;
		 strcat(tmperrmsg, " is not a valid .EXE file") ;
		 break ;

     case 1204 : strcpy(tmperrmsg, "overlay file ") ;
		 strcat(tmperrmsg, errparam) ;
		 strcat(tmperrmsg, " does not match the .EXE file") ;
		 break ;

     case 1205 : strcpy(tmperrmsg, "not enough memory to load procedure") ;
		 break ;

     case 1206 : strcpy(tmperrmsg, "maximum procedure nesting depth exceeded") ;
		 break;

     case 1207 : strcpy(tmperrmsg, "demonstration calls limit exceeded") ;
		 break ;

     case 1208 : strcpy(tmperrmsg, "demonstration date limit exceeded") ;
		 break ;

     case 1209 : strcpy(tmperrmsg, "demonstration time limit exceeded") ;
		 break ;

     case 1210 : strcpy(tmperrmsg, "overlay has been prematurely freed") ;
		 break ;

     case 1211 : strcpy(tmperrmsg, "overlay manager stack overflow") ;
		 break ;

     case 1212 : strcpy(tmperrmsg, "Overlay Opsize exceeded - increase Opsize") ;
		 break ;

     case 1213 : strcpy(tmperrmsg, "Attempt to call DEFINED routine") ;
		 break ;

     case 1214 : strcpy(tmperrmsg, "Error accessing EMS overlay cache") ;
		 break ;

     case 1215 : strcpy(tmperrmsg, "Error accessing XMS overlay cache") ;
		 break ;

     case 1216 : strcpy(tmperrmsg, "Overlay manager unable to resume") ;
		 break ;

     case 1217 : strcpy(tmperrmsg, "overlay vector corrupted during execution") ;
         break ;

     default : strcpy(tmperrmsg, "undefined error");
  }
  printf("BLINKER : %4d : %s\n", tmperrnum, tmperrmsg) ;
  exit (tmperrnum) ;
}
