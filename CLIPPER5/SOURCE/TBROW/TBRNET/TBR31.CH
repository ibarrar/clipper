/*****
 *
 * TBR31.CH
 *
 * Header file for TBR31.PRG
 *
 */

#define     TOP                 2
#define     LEFT                6
#define     BOTTOM              MAXROW() - 2
#define     RIGHT               MAXCOL() - 7

#define     COLSEP              CHR(32)  + CHR(179) + CHR(32) 
#define     HEADSEP             CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP             CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS            "W+/BG,N/W,W/N,N," +;
                                "GR+/W,N/BG,B+/BG,GR+/BG"
#define     SCREEN_FOOTER          "ESC - Quit" +;
                                   "          " +;
                                   "ENTER - Edit "
#define     GETCOLORS           "W+/BG,W+/B"

#define     PRG_CNT             1
#define     FILE_CNT            2
#define     REC_NO              3

#define     MAX_CNT             99
#define     MAX_CNT_DIGITS      2

#define     NEW                 .T.
#define     SHARED              .T.
#define     LOCK_RETRY          10
#define     WAIT_TIME           0.2

#define     GoBOF(handle)       (FSEEK(handle, 0, 0))

#define     MSG_SEM_NOT_FOUND   "Critical Error: " +;
                                   "Semaphore file not found"

// EOF - TBR31.CH //
