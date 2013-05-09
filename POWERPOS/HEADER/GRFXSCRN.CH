/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  GRFXSCRN.CH                                         บ
บ  Description     :  Header file for Graphics Screen Save/Restore        บ
บ                     Module                                              บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  November 1994                                       บ
บ  Last Revision   :                                                      บ
บ  Dialect         :  Clipper plus Extend Libraries from Turbo C++        บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/


// *** Status Codes for Screen Save/Restore operation ***
// grSCRStatusCodes


#define  grSCR_OKAY          0 
#define  grSCR_INVALID      -1 
#define  grSCR_ENDOFIMAGE   -2 
#define  grSCR_IOERROR      -3 
#define  grSCR_NOMEMORY     -4 
#define  grSCR_BADPARAM     -5 
#define  grSCR_UNSUPPORTED  -6


/*--------------------------------------------------------------------------*/

// Restore screen operator

#define  COPY_PUT  0  // Copies source bitmap onto screen
#define  XOR_PUT   1  // Exclusive ORs source image with that already onscreen
#define  OR_PUT    2  // Inclusive ORs image with that already onscreen
#define  AND_PUT   3  // ANDs image with that already onscreen
#define  NOT_PUT   4  // Copy the inverse of the source
