''****************************************************************************
'
' Blinker 2.1 swap function demo
'
' Copyright (c) A.S.M. Inc, 1992, 1993
'
' Microsoft BASIC PDS / Quick Basic / VB DOS
'
' Compile: BC swapdemo /O;
'
'****************************************************************************
'
' $INCLUDE: 'blinker.bi'
'
enable  = 1
disable = 0

   if SWPGETPIDBAS%("swapdemo.bas") = 0 THEN

      ' if we're not running already

      print "Basic Swap example"
      print "=================="
      print
      print "Swap defaults      "
      print
      print "Use EMS memory                  : ",SWPUSEEMS%(disable)
      print "Use XMS memory                  : ",SWPUSEXMS%(disable)
      print "Use UMBs                        : ",SWPUSEUMB%(disable)
      print "Save/restore video mode         : ",SWPVIDMDE%(disable)
      print "Save/restore directory          : ",SWPCURDIR%(disable)
      print "Display message                 : ",SWPDISMSG%(disable)
      print "Wait for keypress               : ",SWPGETKEY%(disable)
      print "Suppress <Ctrl><Alt><Del>       : ",SWPNOBOOT%(disable)
      print

      print "Program already running?        : ",SWPGETPIDBAS%("swapdemo.bas")
      print "Set program ID to swapdemo.bas  : ",SWPSETPIDBAS%("swapdemo.bas")
      print

      ' enable ems / xms / umbs

      i = SWPUSEEMS%(enable)
      i = SWPUSEXMS%(enable)
      i = SWPUSEUMB%(enable)

      ' save / restore current directory and video mode
      ' video buffer contents are not saved

      i = SWPCURDIR%(enable)
      i = SWPVIDMDE%(enable)

      print "Shelling to DOS..."
      print "Run swapdemo again to see SWPGETPIDBAS()."
      print "-------------------------------------------------------------------------"

      ' Set a new prompt

      i = SWPSETENVBAS%("PROMPT=BASIC SwapDemo - $p$g")

      keystr$ = "'dir /w'{enter}'swapdemo'"
      i = SWPKEYBRDBAS%(keystr$)

      ' status = SWPRUNCMDBAS%(ChildProg, Memory, Shell Directory, Temporary directory)

      i = SWPRUNCMDBAS%( "", 0, "", "")

      print "-------------------------------------------------------------------------"
      print "Back from shell, status is      : ",i

      i = SWPERRMAJ%

      ' get major error code

      print "Major error code                : ",i;" ";

      SELECT CASE i
            CASE SWPNONERR
               print "(no error)"
            CASE SWPFULERR
               print "(disk full error)"
            CASE SWPDSKERR
               print "(disk error)"
            CASE SWPDIRERR
               print "(change directory error)"
            CASE SWPCREERR
               print "(create file error)"
            CASE SWPDRVERR
               print "(change drive error)"
            CASE SWPEMSERR
               print "(EMS error)"
            CASE SWPXMSERR
               print "(XMS error)"
            CASE SWPCMDERR
               print "(SHELL error)"
            CASE SWPHANERR
               print "(handle table too large error)"
            CASE SWPMEMERR
               print "(top of memory address changed)"
            CASE SWPMCBERR
               print "(corrupt memory chain error)"
            CASE ELSE
               print "(unknown error)"
      END SELECT

      print "Minor error code                : ",SWPERRMIN%
      print "Child process return code was   : ",SWPERRLEV%
      print "Child process return string was : ",SWPGETSTRBAS$

   else
      ' we're already running, terminate the program
      print "This is the second invocation of Swapdemo"
      print "Please enter a message to return to the parent"
      input "Message : ", msgstr$

      i = swpsetstrbas%("swapdemo.bas",msgstr$)

      print "Type EXIT to return to previous swapdemo.bas"
   endif

