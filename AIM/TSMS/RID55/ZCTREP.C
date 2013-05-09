#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#pragma intrinsic (memcpy)
#include "tdl55.h"
#include "aim55.h"

static struct {
    union {
        short addr;                 /* RAM adresses */
        struct {
            unsigned char addl;     /* Byte components */
            unsigned char addh;
        } a;
    } address;
} out[2] = {
      { 0 },
      { 0 }
};

int z_read(int);

static int isc;
FILE *zr;
static char outline[26],date[10],timer[10];

int zrep55(int iscn, FILE *save_file )
{
 FCB terminal;
 enum {CENTR, DCENTR};
 
 terminal.ftype = DCENTR;
 memcpy(terminal.u.isc,SCT.term,8);

 zr = save_file;
 
 /* RAM ADDRESSES */
 out[0].address.addr = SCT.ram[CTZ1].addr;          /*   */
 
 return(xconsldt(iscn, &terminal, z_read));

 /*z_read(iscn);*/
 
}

int z_read(int iscn)
{
 int n,days = 0,i;
 
 /* Command Block for Direct Get */
 outdata[0] = 0;                                /* Len High Byte */
 outdata[1] = 7;                                /* Len Low Byte */
 outdata[2] = (unsigned char) iscn;             /* ISC Number */
 outdata[3] = 0;                                /* MSG */
 outdata[4] = 0xb0;                             /* CMD */
 outdata[5] = 0x08;                             /* PARM */  
 outdata[6] = SCT.ram[CTZ1].bank;               /* BANK */
 *(short *)(outdata + 7) = 0x9517;              /* 0x1795 */    /* ADDRESS */
 outdata[9] = 0x08;                             /* DATA LEN */
 
 n = xmit(0,NULL);
 if (n)
   return(n);

 
 if (save_z()) 
 {
   return(SAVE_ERR);
 }    

 return(NORMAL);
}

int save_z()
{
 char dest[22];
   _strtime(timer);
   _strdate(date);
   strcpy(outline,"Z-COUNTER  Report<  > ");
   sprintf(outline + 18, "%.2d>", isc);
   outline[21] = '\n';
   if (fwrite(outline,1,22,zr) < 22)
      return(SAVE_ERR);
   memset(outline,0x20,25);
   outline[21] = '\n';
   memcpy(outline, date,8);
   memcpy(outline+16,timer,5);
   if (fwrite(outline,1,22,zr) < 22)
       return(SAVE_ERR);

   memset(outline,0x20,25);
   bcdtoa(indata+5,dest,2);
   memcpy(outline,"Z1-CTR",6);
   memcpy(outline+17,dest, 22);
   outline[21] = '\n';
  
   if (fwrite ( outline, 1, 22 ,zr) < 22)
       return(SAVE_ERR);
       
   memset(outline,0x20,25);    
   bcdtoa(indata+7,dest,2);   
   memcpy(outline,"Z2-CTR",6);
   memcpy(outline+17,dest, 22);
   outline[21] = '\n';
   
   if (fwrite ( outline, 1, 22 ,zr) < 22)
       return(SAVE_ERR);
          
   return(NORMAL);    
}
        
