/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  GRFX_API.CH                                         บ
บ  Description     :  API Pattern Definition File                         บ
บ                                                                         บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  June 1994                                           บ
บ  Last Revision   :                                                      บ
บ  Dialect         :  Clipper plus Extend Libraries from Turbo C++        บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/



** Define Row Movement Flag
#define MSCALE     0                    /* Row & Column movement is scaled -- from (0,0) home position */
#define MPIXEL     1                    /* Use Col & Row parameters are (x, y) coordinate : NOT RECOMMENDED !!! */
#define MFIX       2                    /* Row & Column movement is fixed -- from (0,0) home position */
#define MROWREL    3                    /* Row movement is relative to current Row position  */
#define MCOLREL    4                    /* Column movement is relative to current Col position */
#define MBOTHREL   5                    /* Row & Column is relative to current (Col, Row) position */



