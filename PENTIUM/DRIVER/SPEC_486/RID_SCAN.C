/****************************************************************************
  RID_SCAN.C

  Syntax:

    READ_SCAN( <bytes_read>, <str_buffer>, <check_flag>)

  Parameters:

    <bytes_read> - a numeric argument that will contain the actual length 
                   (in bytes) of the label scanned. The count does not include
                   the label terminator or the suffix character.
                   
                   This argument must always be passed by reference (@) and
                   must be initialized by a numeric data type.
                        
    <str_buffer> - a buffer that contains the label information read by the 
                   optical reader (or scanner). Data read is stored as charac-
                   ter string. The label terminator or the suffix character
                   is included, but it is not included in the count.

                   This argument must always be passed by reference (@) and 
                   must be initialized by a character data type (for example,
                   a null string - "").

    <check_flag> - a logical argument that contains a .T. or .F. value.
                   If .T. then the check digit is used to check if the
                   scanned data is error-free.  If .F. or upon call to
                   this function without this parameter will simply return
                   the scanned digit if there were no errors in scanning
                   the device via hardware checking.
       
  Description:

    READ_SCAN() reads a complete scanned label asynchronously. On a NORMAL
    return from this function - <bytes_read> will contain the label count,
    while <str_buffer> will contain the label data.

    A prior call to A_SCAN_ON() is required.    
    
  Return values:

    NORMAL         - Normal operation
    READ_ERR       - Read operation error
    DEV_NOT_EXIST  - Device not initialized
    INVP           - Invalid parameter or invalid command
    SCAN_ERR       - Scan operation error (via check digit)

    See header file - PFL_CLIP.CH for details.
    

  rnr  4-17-96
  aea  10-28-96
*****************************************************************************/

#include <stdio.h>


/*
#include <stdlib.h>
#include <string.h>
*/

#include "extend.h"
#include "pcr_ext.h"
#include "pfl_scan.h"
#include "pfl_clip.ch"

#define BUFF_SIZE   205  /* maximum buffer size for reading */

int checkdgt(char *cCode, int nLen);


/* parameter constants */
enum arguments { BYTES_READ=1, STR_BUFF, CHECK_FLAG };

/* External definitions */
extern POS_TABLE pos_setup[];
extern int async_scan; /* flag that indicates the asynchronous scanning mode */

/* Other variables */
static char label_buff[BUFF_SIZE];  /* scanner input buffer */

CLIPPER read_scan(void)
{
  int barcode_sts;  /* scanner input status */
  int barcode_len;  /* holds the no. of bytes actually read */
  int check_flag = 0;  
  int label_chkdigit,chkdigit;
    
  if ((PCOUNT >= 2) && ISBYREF(BYTES_READ) && ISNUM(BYTES_READ) &&
                     ISBYREF(STR_BUFF) && ISCHAR(STR_BUFF))
  {
     /* verify initial status */
     if (chk_init_flag(POS_SCAN) == 0)
     {
        _retni(DEV_NOT_EXIST);   
        return;
     } /* device not yet initialized */

    /* not in asynchronous scanning mode */
    if (!async_scan)
    {
      _retni(INVP);
      return;
    }
    
    /* read scanner input */
    if ((barcode_sts = pfl_get_label(label_buff)) == -1)
      barcode_sts = READ_ERR;  /* no available data to be fetched */
    else
    {
      barcode_len = barcode_sts & 0x00ff;              /* get label length */
      barcode_sts >>= 8;                               /* label status     */

      barcode_sts = (barcode_sts == 0)? NORMAL: SCAN_ERR;  /* status      */
      
      if ( PCOUNT == 3 )
      {
        int check_flag = _parl(CHECK_FLAG);      
        if (check_flag)
        {  
           barcode_len--;                
                    
           label_chkdigit = (int) label_buff[barcode_len] - 48 ;
           
           chkdigit = checkdgt(label_buff,barcode_len);           

           if ( label_chkdigit !=  chkdigit )
             barcode_sts = SCAN_ERR;
                                       
        }   
        
      }     

      _storni(barcode_len, BYTES_READ);                /* length */
        
      *(label_buff+barcode_len+1) = '\0';              /* insert a NULL character */
      _storclen(label_buff, barcode_len+2, STR_BUFF);  /* bar code data */        
                          
    }
    
    _retni(barcode_sts);
  }
  else
    _retni(INVP);
}

int checkdgt(char *cCode,int nLen)
{
  int ntot1 = 0,ntot2 = 0, k;
  char cstr[9];
  char ctmp[25];

  if ( nLen % 2 )
  {   
      ctmp[0] = '0';
      _bcopy(ctmp+1,cCode,nLen);
      nLen++;
  }
  else
    _bcopy(ctmp,cCode,nLen);
       
          
  for (k=0;k<nLen;k++)
  {
    if ( k % 2 )
      ntot1 += (int) ctmp[k] - 48 ;
    else
      ntot2 += (int) ctmp[k] - 48 ;
  }
  
  k = (ntot1*3) + (ntot2) ;
  
  sprintf(cstr,"%08d",k);
  
  k = (int) cstr[7] - 48 ;
  
  return k==0?0:10-k;
}  

