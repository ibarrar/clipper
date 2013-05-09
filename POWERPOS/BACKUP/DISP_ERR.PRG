*
* System......... POWERPOS for Spectrum
* Program I.D.... DISP_ERR.prg
* Description.... Displays error messages
*

#include "pfl_clip.ch"
#include "Message.ch"

function pfl_msg(status, exit, pos_device, f_handle, err_desc)
**************************************************************
local error_msg := { "NORMAL", "HARD_ERR", "NO_DRIVER", "DEV_EXIST",;
                     "DEV_NOT_EXIST", "DEV_NOT_READY", "INVP", "PAPER_ERR",;
                     "RCPT_END", "RCPT_NTEND", "JRNL_END_TORN",;
                     "JRNL_END_NTORN", "JRNL_NTEND_TORN", "JRNL_NTEND_NTORN",;
                     "DOC_IN_END", "DOC_IN_NTEND", "DOC_OUT", "COVER_OPEN",;
                     "DRAWER_OPEN", "DRAWER_CLOSED", "TRACK_EMPTY","CRC_ERR",;
                     "END_OF_DATA", "POWER_ERR", "POWER_OK", "MEM_OUT",;
                     "NV_FILE_EXISTS", "NV_USERDATA_ERR",;
                     "NV_FILE_NOT_EXIST", "SLIP_PAPER_OUT", "SLIP_PAPER_OFF" }
if !empty(status)
   //
   // issue an error beep...
   //
   beep_3()

   // clear displays...
   //
   *disp_clr()

   if pos_device = "DOS"
      if err_desc = nil
         disp_device("FILE HANDLING", pos_device + " CODE " + ;
                     ltrim(str(status)))
      else
         disp_device(err_desc, pos_device + " CODE " + ;
                     ltrim(str(status)))
      endif
      fclose(f_handle)
   else
      disp_device(error_msg[status +1], pos_device)
   endif

   power_end()

   // return to DOS...
   //   
   QUIT
endif

return nil 


function disp_device(msg, pos_device)
*************************************

pos_device := if (pos_device = nil, "", pos_device)

// cashier display (4x20)
//
DISPTEXTXY(2, 1, 0, 0, 0, 0, "ERROR " + pos_device)
DISPTEXTXY(3, 1, 0, 0, 0, 0, msg)

// customer display 1 (1x9)
//
DISPTEXTXY(0, 0, 1, 1, 0, 0, "E")

// customer display 2 (2x20)
//
DISPTEXTXY(0, 0, 0, 0, 1, 1, "ERROR " + pos_device)
DISPTEXTXY(0, 0, 0, 0, 2, 1, msg)

// display error message in message box
// MsgAreaDisp( "Error : " + msg)
// delay_msec(1500)
// MsgAreaDisp("")

return nil

* eop 01/15/96

