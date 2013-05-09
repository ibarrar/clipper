/***************** TECHNO SOFTWARE CORPORATION, Philippines ****************
*   BUFFERS.C
*
*   Queue Buffering scheme.
*
*   MONTY 10/28/93
***************************************************************************/

#include "buffers.h"


#define N_OF_BLOCKS  20   //Assuming maximum terminals can transmit
                          //simultaneously.
#define BLOCKSIZE   268   //268 bytes per frame
#define QUESIZE     ((BLOCKSIZE * N_OF_BLOCKS)+1)
#define BUFFERFULL  ((headptr+1)%QUESIZE==tailptr)
#define BLKS_IN_BUFF (((QUESIZE + headptr - tailptr)%QUESIZE)/BLOCKSIZE)

static char quebuff[ QUESIZE ] = {0};  //declare static QUEUE buffer
static unsigned int tailptr=0;
static unsigned int headptr=0;

/****** FUNCTION DECLARATIONS ***********/

/**********************************
*  blks_in_buff(void)
*  - returns the no. of blks in buffer
*  Monty 10/28/93
**********************************/
unsigned int blks_in_buff(void)
{
   return (BLKS_IN_BUFF);
}

/********************************
*  putdata2buf(char *)
*  - put the param1 (268 bytes) to queue buffer for later retrieval
*  Monty 10/28/93
********************************/
void putdata2buf(char *buf)
{
   static unsigned int i;  /* 0..267 */
   for (i=0; i<BLOCKSIZE; i++) {
      if (headptr>=QUESIZE)
          headptr=0;                  /* move to first queue */
      quebuff[headptr++] = buf[i];  /* move it there...*/
   }//next i;
}

/*************************************
*  getdata2buf(char *)
*  - get a 268 bytes from queue buffer
*  - returns 1 if data exist, 0 if buffer is empty
*  Monty 10/28/93
*************************************/
int getdata2buf(char *buf)
{
   static unsigned int i;  /* 0..267 */
   if (headptr!=tailptr) {
      for (i=0; i < BLOCKSIZE; i++) {
         if (tailptr >= QUESIZE)
            tailptr=0;
         buf[i] = quebuff[ tailptr++ ];
      }//next i
      return 1;  //data exist
   } else
      return 0;  //data not available
}
