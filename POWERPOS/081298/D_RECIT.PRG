/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  D_RECIT.PRG                                         บ
บ  Description     :  Display Receipt Image on Screen                     บ
บ                                                                         บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  November 1994                                       บ
บ  Last Revision   :                                                      บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "powerpos.ch"
#include "grfx_all.ch"
#include "config.ch"

/*---------------------------------------------------------------------------*/

/*  Usage : Display Receipt Image
    Descr :
    Parm  :
            cBMPfile   -> BITMAP filename
    Return: NIL
*/

function Rcpt_Image( cBMPfile )
local cOutText, disptext 

  MainDisplay()

  // Draw Receipt Box
  gDrawBox(2, 21, 98, 82, BUTTON_UP_LINE,,, SOLID_FILL, CFG_DFILL, MSCALE, 4)

  // Display Receipt Logo
  gLoad_BMP( cBMPfile , 3, 4, 49, 19 )

  disptext := subs(alltrim(config(POS_4X20_DISP2)), 1, 20)
  // Display Receipt Heading
  gDrawText(2, 23, disptext, TRIPLEX_FONT, 4, CFG_DHLITE, MSCALE, CENTER_TEXT)

  disptext := subs(alltrim(config(POS_REC_HEAD2)), 1, 24)
  gDrawText(1, 0, disptext, TRIPLEX_FONT, 2, CFG_DHLITE, MBOTHREL, CENTER_TEXT)

  disptext := subs(alltrim(config(POS_REC_HEAD3)), 1, 30)
  gDrawText(1, 0, disptext, TRIPLEX_FONT, 2, CFG_DHLITE, MBOTHREL, CENTER_TEXT)
            
  gDrawText(1, 0, VERSION_ID, TRIPLEX_SCR_FONT, 2, CFG_DHLITE, MBOTHREL, CENTER_TEXT)

  gDrawBox(0, 91, 100, 100, THIN_THICK_LINE, NORM_WIDTH, ;
           CFG_DBORDR, SOLID_FILL, CFG_DBACK)

return nil

