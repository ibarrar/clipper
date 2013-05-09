/*
 * System........ PowerPos for Spectrum
 * Program I.D... faccess.c
 * Description... File Access function for NETWORK using file I/O
 *
 * Author........ Rollie Castro Ibarra Jr.
 * Date Started.. Sept 1, 1996
 * Date Finished. 
 * Dialect....... C callable by Clipper 5.2e
 *
 * NetWork O.S... NETWARE, LANSMART, LANTASTIC
 *
 * Remarks....... Compile in MicroSoft C greater than Version 5.1
 *                CL /c /AL /FPc /Gs /Oalt /Zl <filename>.c  .OR.
 *                CL -c -AL -Gs -FPa -Oalt -Zl -Gh <filename>.c
 *                Compile in MicroSoft C 5.1
 *                CL -c -AL -Gs -FPa -Zl <filename>.c
 *                Compile in Borland C/C++ version 3.x
 *                BCC -c -ml -f -rd -Oalt -X -k- -N- <filename>.c
 *                Compile in Turbo C++
 *                TCC -c -ml -f- -rd -X- -k- -N- <filename>.c
*/

#include <string.h>
#include <stdlib.h>

#include "extend.h"
#include "faccess.h"

#ifdef DEBUG
  #include <stdio.h>
#endif  

#pragma check_stack-

/* define clipper parameters... */

#define HEADER       1    /* server name to send request buffer... */
#define SEND_BUFFER  2    /* access request buffer... */
#define RECV_BUFFER  3    /* answer to calling module (passed by ref.)... */
#define PATH_BUFFER  4    /* path of the data to be accessed... */


/* HEADER Format:

        LOCAL_IP_ADDRESS         8  
        LOCAL_MACHINE_NUMBER     2
        SERVER_IP_ADDRESS        8
        SERVER_MACHINE_NUMBER    2
        LENGTH                   2
        SEQ_NUMBER               1
        COMMAND                  1
        PAR                      1
   
        FN                       2

*/

CLIPPER f_access(void)
{
  unsigned char asc_machno[5];
  unsigned char asc_command[3];
  unsigned char asc_parm[3];
  unsigned char asc_fn[3];
  unsigned char bcd_machno[3];
  unsigned char bcd_command[2];
  unsigned char bcd_parm[2];
  unsigned int headerLen;
  unsigned int send_Len;
  unsigned int receiveLen;
  unsigned int path_Len;   
  unsigned int command;
  unsigned int retv;
  unsigned int par;
  void far *bcd_header;
  void far *sendBuff;
  void far *receiveBuff;
  void far *pathBuff;
  
  _bset(asc_machno,0x0,sizeof(asc_machno));
  _bset(asc_command,0x0,sizeof(asc_command));
  _bset(asc_parm,0x0,sizeof(asc_parm));
  _bset(asc_fn,0x0,sizeof(asc_fn));    
  _bset(bcd_machno,0x0,sizeof(bcd_machno));
  _bset(bcd_command,0x0,sizeof(bcd_command));
  _bset(bcd_parm,0x0,sizeof(bcd_parm));

  if (PCOUNT == 4  && ISCHAR(HEADER) && ISCHAR(SEND_BUFFER)
      && ISCHAR(RECV_BUFFER) && ISBYREF(RECV_BUFFER)
      && ISCHAR(PATH_BUFFER) && ISBYREF(HEADER))
  {       

      /* validate parameters... */

      /* get the expected length of the returned buffer and access request... */

      headerLen  = _parclen(HEADER);
      send_Len   = _parclen(SEND_BUFFER);
      receiveLen = _parclen(RECV_BUFFER);
      path_Len   = _parclen(PATH_BUFFER);

#ifdef DEBUG
      printf("\n header len :%d send len :%d receive len :%d path len :%d\n",
              headerLen,
              send_Len,
              receiveLen,
              path_Len);      
#endif              
      
      bcd_header = _parc(HEADER);
      /* process first the machine no */
      
      _bcopy(bcd_machno,(char far *)bcd_header+8,2);
      BCDTOA(asc_machno,bcd_machno,2);

      /* process then the command */
      _bcopy(bcd_command,(char far *)bcd_header+23,1);
      BCDTOA(asc_command,bcd_command,1);
      command = atoi(asc_command);

      /* process last the parameter */
      _bcopy(bcd_parm,(char far *)bcd_header+24,1);
      BCDTOA(asc_parm,bcd_parm,1);
      par = atoi(asc_parm);

      /* now the filename */
      _bcopy(asc_fn,(char far *)bcd_header+25,2);

#ifdef DEBUG
      printf("\n machine no. :%s\n command :%s\n parm :%s\n filename :%s",
             asc_machno,
             asc_command,
             asc_parm,
             asc_fn);                
#endif

      sendBuff    = _parc(SEND_BUFFER);
      receiveBuff = _parc(RECV_BUFFER);
      pathBuff    = _parc(PATH_BUFFER);              

      if ( asc_fn[0] == 'I' && asc_fn[1] == 'T' )
      {
        switch(command) 
        { 
           case 3:
              retv = itemtran_append(sendBuff,send_Len,asc_machno,pathBuff,path_Len,par); 
              break;
           default:       
              retv = INV_CMMD_PARAM;                            
        }                                          
      }
#ifdef FM_FILE
      else if (asc_fn[0] == 'F' && asc_fn[1] == 'M')
      { 
        switch(command)
        {
           case FA_CMD_SRCHGET :
              retv = fmf_search_and_get(receiveBuff,receiveLen,
                                        sendBuff, send_Len,
                                        pathBuff, path_Len );
              break;
           case FA_CMD_SRCHDEL :
              retv = fmf_delete(pathBuff, path_Len);   
              break;                           
           case FA_CMD_FREEINQ :
              retv = fmf_comp_last_trans_no(receiveBuff,receiveLen,
                                            pathBuff,path_Len );
              break;
           case FA_CMD_CLOSEFL :
              retv = fmf_close_file();
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :   
              retv = fmf_get_first(receiveBuff,receiveLen,
                                       pathBuff,path_Len);           
              break;                            
           case FA_CMD_GETNEXT :           
              retv = fmf_get_next(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                              
              break;                     
           case FA_CMD_GETPREV :           
              retv = fmf_get_previous(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                              
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = fmf_get_last(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                
              break;   
#endif                                       
           default:
              retv = INV_CMMD_PARAM;
        }     
      }
#endif
#ifdef CS_FILE
      else if (asc_fn[0] == 'C' && asc_fn[1] == 'S')
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET : /* search and find and get */
              retv = cashier_search_and_get(receiveBuff,receiveLen,
                                            sendBuff,send_Len,
                                            pathBuff,path_Len );
              break;
           case FA_CMD_SRCHPUT : /* search and find and put */
              retv = cashier_search_and_put(sendBuff,send_Len,
                                            pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL : /* search and find and delete (turn "*" on)*/
              retv = cashier_search_and_del(sendBuff,send_Len,
                                            pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :
              retv = cashier_create(pathBuff, path_Len);
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :   
              retv = cashier_get_first(receiveBuff,receiveLen,
                                       pathBuff,path_Len);           
              break;                            
           case FA_CMD_GETNEXT :           
              retv = cashier_get_next(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                              
              break;                     
           case FA_CMD_GETPREV :           
              retv = cashier_get_previous(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                              
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = cashier_get_last(receiveBuff,receiveLen,
                                      pathBuff,path_Len);                
              break;              
#endif
           default:
              retv = INV_CMMD_PARAM;
        }      
      }
#endif 
#ifdef PL_FILE
      else if (asc_fn[0] == 'P' && asc_fn[1] == 'L')
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET :   /* PLU File Search and Get */
              retv = plu_search_and_get(receiveBuff,receiveLen,
                                         sendBuff,send_Len,
                                         pathBuff,path_Len, par);
              break;
           case FA_CMD_SRCHPUT :
              retv = plu_search_and_put( sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL :
              retv = plu_search_and_delete(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :
              retv = plu_create(pathBuff,path_Len );
              break;
           case FA_CMD_GETCNTR :
              retv = plucount_search_and_get(receiveBuff,receiveLen,
                                             sendBuff, send_Len,
                                             pathBuff, path_Len, par );
              break;
           case FA_CMD_PUTCNTR :
              retv = plucount_search_and_put(sendBuff, send_Len,
                                             pathBuff, path_Len, par );
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :   
              retv = plu_get_first(receiveBuff,receiveLen,
                                         pathBuff,path_Len, par);           
              break;                            
           case FA_CMD_GETNEXT :           
              retv = plu_get_next(receiveBuff,receiveLen,
                                   pathBuff,path_Len, par);                              
              break;                     
           case FA_CMD_GETPREV :           
              retv = plu_get_previous(receiveBuff,receiveLen,
                                      pathBuff,path_Len, par);                              
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = plu_get_last(receiveBuff,receiveLen,
                                      pathBuff,path_Len, par);                
              break;   
#endif                                   
           case FA_CMD_CLOSEFL :
              retv = plu_close_file();
              retv += fmf_close_file();
              retv += plucount_close_file();
              break;      
           default:
              retv = INV_CMMD_PARAM;
        }      
      }
#endif
#ifdef DP_FILE  
      else if (asc_fn[0] == 'D' && asc_fn[1] == 'P' )
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET :
              retv = dept_search_and_get(receiveBuff,receiveLen,
                                         sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHPUT :
              retv = dept_search_and_put(sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL :
              retv = dept_search_and_delete(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :
              retv = dept_create(pathBuff,path_Len );
              break;
           case FA_CMD_GETCNTR :
              retv = dpcount_search_and_get( sendBuff,send_Len,
                                             receiveBuff,receiveLen,
                                             pathBuff, path_Len, par );
              break;
           case FA_CMD_PUTCNTR :
              retv = dpcount_search_and_put(sendBuff, send_Len,
                                            pathBuff, path_Len, par );
              break;              
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :   
              retv = dept_get_first(receiveBuff,receiveLen,
                                         pathBuff,path_Len);           
              break;                            
           case FA_CMD_GETNEXT :           
              retv = dept_get_next(receiveBuff,receiveLen,
                                   pathBuff,path_Len );
              break;                     
           case FA_CMD_GETPREV :           
              retv = dept_get_previous(receiveBuff,receiveLen,
                                         pathBuff,path_Len ); 
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = dept_get_last(receiveBuff,receiveLen,
                                      pathBuff,path_Len );                
              break;   
#endif                                         
           default:
              retv = INV_CMMD_PARAM;
              break;
        }
      }  
#endif
#ifdef CK_FILE              
      else if (asc_fn[0] == 'C' && asc_fn[1] == 'K')
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET :
              retv = clerk_search_and_get(receiveBuff,receiveLen,
                                         sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHPUT :
              retv = clerk_search_and_put(sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL :
              retv = clerk_search_and_delete(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :
              retv = clerk_create(pathBuff,path_Len );
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :   
              retv = clerk_get_first(receiveBuff,receiveLen,
                                         pathBuff,path_Len);           
              break;                            
           case FA_CMD_GETNEXT :           
              retv = clerk_get_next(receiveBuff,receiveLen,
                                   pathBuff,path_Len );
              break;                     
           case FA_CMD_GETPREV :           
              retv = clerk_get_previous(receiveBuff,receiveLen,
                                         pathBuff,path_Len ); 
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = clerk_get_last(receiveBuff,receiveLen,
                                      pathBuff,path_Len );                
              break;   
#endif                                         
           default:
              retv = INV_CMMD_PARAM;

         }          
      }    
#endif   
#ifdef RR_FILE
      else if (asc_fn[0] == 'R' && asc_fn[1] == 'R')
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET :           
              retv = rtrn_search_and_get(receiveBuff,receiveLen,
                                         sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHPUT :              
              retv = rtrn_search_and_put(sendBuff,send_Len,
                                        pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL :              
              retv = rtrn_search_and_delete(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :              
              retv = rtrn_create(pathBuff,path_Len);
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :                 
              retv = rtrn_get_first(receiveBuff,receiveLen,
                                       pathBuff,path_Len );
              break;                             
           case FA_CMD_GETNEXT :           
              retv = rtrn_get_next(receiveBuff,receiveLen,
                                   pathBuff,path_Len );
              break;                     
           case FA_CMD_GETPREV :           
              retv = rtrn_get_previous(receiveBuff,receiveLen,
                                       pathBuff,path_Len ); 
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = rtrn_get_last(receiveBuff,receiveLen,
                                   pathBuff,path_Len );                
              break;   
#endif                                                       
           default:
              retv = INV_CMMD_PARAM;
         }          
      }     
#endif
#ifdef RT_FILE
      else if (asc_fn[0] == 'R' && asc_fn[1] == 'T')
      {
        switch(command) 
        {
           case FA_CMD_SRCHGET :           
              retv = return_search_and_get(receiveBuff,receiveLen,
                                         sendBuff,send_Len,
                                         pathBuff,path_Len );
              break;
           case FA_CMD_SRCHPUT :              
              retv = return_search_and_put(sendBuff,send_Len,
                                        pathBuff,path_Len );
              break;
           case FA_CMD_SRCHDEL :              
              retv = return_search_and_delete(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;
           case FA_CMD_CREATEF :              
              retv = return_create(pathBuff,path_Len);
              break;
#ifdef BROWSE_FUNCTIONS              
           case FA_CMD_GETFRST :                 
              retv = return_get_first(receiveBuff,receiveLen,
                                       pathBuff,path_Len );
              break;                             
           case FA_CMD_GETNEXT :           
              retv = return_get_next(receiveBuff,receiveLen,
                                   pathBuff,path_Len );
              break;                     
           case FA_CMD_GETPREV :           
              retv = return_get_previous(receiveBuff,receiveLen,
                                       pathBuff,path_Len ); 
              break;                                   
           case FA_CMD_GETLAST :                 
              retv = return_get_last(receiveBuff,receiveLen,
                                   pathBuff,path_Len );                
              break;   
#endif                                                       
           default:
              retv = INV_CMMD_PARAM;
         }          
      }     
#endif
#ifdef PT_FILE
      else if (asc_fn[0] == 'P' && asc_fn[1] == 'T')
      {
        switch(command) 
        {
           case 2:
              retv = plutmp_search_and_find(receiveBuff, receiveLen,
                                            sendBuff, send_Len,
                                            pathBuff, path_Len );
              break;
           case 3:
              retv = plutmp_search_and_put(sendBuff,send_Len,
                                           pathBuff,path_Len );
              break;                            
           case 4:
              retv = plutmp_search_and_delete(sendBuff,send_Len,
                                              pathBuff,path_Len );
              break;
           case 6:
              retv = plutmp_create(pathBuff,path_Len);
              break;
           default:
              retv = INV_CMMD_PARAM;
         }          
      }     
#endif
     else
         retv = INV_FILE_ID_PARAM;
         
     _storclen(receiveBuff, receiveLen, RECV_BUFFER);    
     _retni(retv);
  }
  else
    _retni(INVALID_PARAM);      
}

/* EOF */