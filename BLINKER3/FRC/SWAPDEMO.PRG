*****************************************************************************
* Blinker swap function demo
*
* Force 2.1e
*
* Compile: FORCE swapdemo
* Link   : BLINKER FILE swapdemo LIB force
*
*****************************************************************************

#include blinker.hdr
#include io.hdr

VARDEF
   CHAR (100) keystr
ENDDEF

PROCEDURE force_main

   VARDEF
      LOGICAL   enable, disable, i
   ENDDEF

   enable  = .T.
   disable = .F.

   if .NOT. SWPGETPID("swapdemo.prg")

      * If we're not already running

      ? "Force Swap example"
      ? "=================="
      ?
      ? "Swap defaults      "
      ?
      ? "Use EMS memory                  : ",SWPUSEEMS(disable)
      ? "Use XMS memory                  : ",SWPUSEXMS(disable)
      ? "Use UMBs                        : ",SWPUSEUMB(disable)
      ? "Save/restore video mode         : ",SWPVIDMDE(disable)
      ? "Save/restore directory          : ",SWPCURDIR(disable)
      ? "Display message                 : ",SWPDISMSG(disable)
      ? "Wait for keypress               : ",SWPGETKEY(disable)
      ? "Suppress <Ctrl><Alt><Del>       : ",SWPNOBOOT(disable)
      ?

      ? "Program already running?        : ",SWPGETPID("swapdemo.prg")
      ? "Set program ID to swapdemo.prg  : ",SWPSETPID("swapdemo.prg")
      ?

      * enable ems / xms / umbs

      i = SWPUSEEMS(enable)
      i = SWPUSEXMS(enable)
      i = SWPUSEUMB(enable)

      * save / restore current directory and video mode
      * video buffer contents are not saved

      i = SWPCURDIR(enable)
      i = SWPVIDMDE(enable)

      ? "Shelling to DOS...(Type EXIT to return)"
      ? "Run swapdemo again to see SWPGETPID()."
      ? "-------------------------------------------------------------------------"

      * Set a new prompt

      i = SWPSETENV("PROMPT=Force SwapDemo - $p$g")

      keystr = "'dir /w'{enter}'swapdemo'"
      i = swpkeybrd(keystr)

      * status = SWPRUNCMD(ChildProg, Memory, Shell Directory, Temporary directory)

      i = SWPRUNCMD( "", 0, "", "")

      ? "-------------------------------------------------------------------------"
      ? "Back from shell, status is      : ",i
      ? "Major error code is             : ",SWPERRMAJ()
      ? "Minor error code is             : ",SWPERRMIN()
      ? "Child process return code was   : ",SWPERRLEV()
      ? "Child process return string was : ",SWPGETSTRFOR()

   else
      CLEAR
      * we're already running, terminate the program
      keystr = "                           "
      @ 0,0 SAY "This is the second invocation of Swapdemo"
      @ 1,0 SAY "Please enter a message to return to the parent"
      @ 2,0 SAY "Message : " get keystr
      READ
      i = swpsetstr("swapdemo.prg",keystr)
      @ 4,0 SAY "Type EXIT to return to previous swapdemo.prg"
      @ 6,0 SAY ""
      QUIT
   endif
ENDPRO

