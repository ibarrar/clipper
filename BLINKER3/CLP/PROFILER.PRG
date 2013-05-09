*******************************************************************************
*
*        93.05.16    PROFILER.PRG
*
* BLINKER Profiling routines written by Frederick W. Stangl, President of
* Dynamic Performance Inc. Fred is a Clipper developer and lecturer in the
* Philadelphia area. He may be reached at (215) 579-9884. This code is provided
* to BLINKER users free of charge. If you like what you see, call Fred - ask
* him about StanglWare...
*
* Add the following code stub at the top of your main routine:
*
*   external ovl_stat
*   parameter startup_param              && Use command line switch to activate
*   if type ("startup_param") <> "U"     && Check for existence
*
*      if upper(startup_param) = "/P"    && Not case sensitive
*
*                                        && Make arrays big enough to cover
*                                        && All your procedures & functions
*          public bl_himem, bl_lomem, bl_count, ;
*                 bl_proc[500], bl_size[500], bl_call[500], bl_disk[500]
*
*          bl_himem = memory(0)          && Initialize hi & lo memory counters
*          bl_lomem = bl_himem
*          bl_count = 0                  && Initialize array element counter
*
*          set key 281 to ovl_stat       && Use Alt-P for hot-key
*          bliprfmod(.T.)                && Turn profiling mode on
*
*      endif
*   endif
*
*
*   NOTE: if bliprfmod() is .T., profiling is turned on, and every call to
*         an overlaid function or procedure is accompanied by a call to
*         blprfprg(). This profiler collects statistics for later display
*         via the hot key call to ovl_stat().
*
*         To activate the profiling functions, add these linker commands
*         above your BEGINAREA statements in the link script file:
*
*           FI profiler                  && This program
*           BLINKER CLIPPER PROFILE ON   && This is a linker command
*
*
*******************************************************************************

*** Profiling function for gathering operating statistics ***

function blprfprg                            && Called on every overlay call
private call, pointer, free

call = blicurnme()                           && Get name of called routine

pointer = ascan(bl_proc,call)                && See if we already have it

if pointer = 0                               && If not, stuff it into arrays
    ains(bl_proc,1)
    ains(bl_size,1)
    ains(bl_call,1)
    ains(bl_disk,1)
    pointer = 1
    bl_count = bl_count + 1                  && Increment array element counter
    bl_proc[pointer] = call                  && Store statistics for later
    bl_size[pointer] = blicursiz()           && Viewing via hot-key pop-up
endif

bl_call[pointer] = blicurcal()
bl_disk[pointer] = blicurdsk()

free = blitotcal ()
if free = int (free / 10) * 10               && Every tenth call
   free=memory(0)
   if free>bl_himem                          && Record highest & lowest
      bl_himem=free                          && Memory excursions
   elseif free<bl_lomem
      bl_lomem=free
   endif
endif

return(.T.)


*** Display function for viewing statistics via hot-key ***

function ovl_stat

private spot, choice, free, oldrow, oldcol, oldmod
private prfmemhig,prfmemzer,prfmemlow,prfmempak,prfovlops,prfovlsiz
private prftotsiz,prftotlod,prftotact,prftotcal,prftotdsk,prftotper

oldmod = bliprfmod(.F.)                      && Turn profiling mode off

oldrow = row ()
oldcol = col ()
spot=savescreen(04,17,21,64)                 && Save screen area to be used

free=memory(0)

if free>bl_himem                             && Record highest & lowest
   bl_himem=free                             && memory excursions
elseif free<bl_lomem
   bl_lomem=free
endif

prfmemhig = tran(bl_himem*1024,"###,###")    && Set up counts for display
prfmemzer = tran(memory(0)*1024,"###,###")
prfmemlow = tran(bl_lomem*1024,"###,###")
prfmempak = tran(blimempak(),"###,###")
prfovlops = tran(bliovlops(),"###,###")
prfovlsiz = tran(bliovlsiz(),"###,###")
prftotsiz = tran(blitotsiz(),"###,###")
prftotlod = tran(blitotlod(),"###,###")
prftotact = tran(blitotact(),"###,###")
prftotcal = tran(blitotcal(),"###,###")
prftotdsk = tran(blitotdsk(),"###,###")
prftotper = tran(iif(blitotcal()=0,0,100*(1-blitotdsk()/blitotcal()))," ###.#%")

do while .T.
                                             && Paint screen
   @ 04,17,21,64 box "旼엿耗윰 "
   @ 05,22 say "      RUNTIME OVERLAY ANALYSIS"
   @ 06,22 say "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
   @ 07,22 say "Highest Free Pool Memory:      " + prfmemhig
   @ 08,22 say "Current Free Pool Memory:      " + prfmemzer
   @ 09,22 say "Lowest Free Pool Memory:       " + prfmemlow
   @ 10,22 say "Blinker Memory Pack Frequency: " + prfmempak
   @ 11,22 say "Blinker Overlay Pool OpSize:   " + prfovlops
   @ 12,22 say "Current Overlay Pool Size:     " + prfovlsiz
   @ 13,22 say "Total Proc Size Since Startup: " + prftotsiz
   @ 14,22 say "Procedures Currently Loaded    " + prftotlod
   @ 15,22 say "Procedures Currently Active:   " + prftotact
   @ 16,22 say "Total Calls Since Startup:     " + prftotcal
   @ 17,22 say "Total Disk Loads Since Startup:" + prftotdsk
   @ 18,22 say "% Serviced from Overlay Pool:  " + prftotper

   @ 20,22 say "F2 Detail                 F3 Bar Chart"

   choice=inkey(0)                        && Wait for keypress

   do case

   case choice = -1              && use ACHOICE to display a scrolling window
                                 && of statistics by called procedures

      private count, spot2, bl_stats[bl_count + 5]

                                          && Build array for display
      for count = 1 to bl_count
        bl_stats[count] = left(bl_proc[count]+space(10),10) + ;
                          tran(bl_size[count],"   ###,###") + ;
                          tran(bl_call[count],"   ###,###") + ;
                          tran(bl_disk[count],"   ###,###") + ;
                          tran(iif(bl_call[count]=0, 0, ;
                          100*(1-bl_disk[count]/bl_call[count])),"#######.#%")
      next

                                          && Display array of statistics
      spot2 = savescreen(02,10,22,64)
      @ 02,10,22,64 box "旼엿耗윰 "
      @ 03,12 say "Procedure       Size     Calls     Loads   Service"
      @ 04,12 say "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
      choice=achoice(05,12,21,62,bl_stats)
      restscreen(02,10,22,64,spot2)

    case choice = -2                      && Display bar chart

      private tmpsavscr
      save screen to tmpsavscr
      clear

      private bl_bar1[bl_count+5], bl_bar2[bl_count+5]

      private count, max_calls, bar, sorted

      max_calls=0                         && Get max number of calls
      for count = 1 to bl_count
          max_calls=max(max_calls,bl_call[count])
      next

                                          && Build array for display

      bar=177                             && ASCII code for bar symbol
      for count = 1 to bl_count

        bar = iif(bar=176,177,176)        && Alternate bars

        bl_bar1[count] = left(bl_proc[count]+space(11),11) + ;
                       replicate(chr(bar),int(1+64*bl_call[count]/max_calls)) ;
                       + str(bl_call[count],4)

                                          && Make copy for sorting - note
                                          && inverse key for descending sort

        bl_bar2[count] = str(10000-bl_call[count],4)+bl_bar1[count]

      next

      asort(bl_bar2)                      && Sort by calls in descending order


                                          && Trim sort key from string
      for count = 1 to bl_count
          bl_bar2[count] = substr(bl_bar2[count],5,len(bl_bar2[count])-4)
      next

      set key -2 to bl_toggle             && Stuff achoice toggle sequence
      sorted = .F.

      @ 00,00 say "Procedure  Number of Calls"
      @ 01,00 say replicate(chr(196),80)

      do while .T.                        && Display window

        if sorted                         && Display appropriate array
          @ 00,54 say "Press F3 for Natural Order"
          achoice(02,00,23,79,bl_bar2)
        else
          @ 00,54 say " Press F3 for Sorted Order"
          achoice(02,00,23,79,bl_bar1)
        endif

        if inkey(.1) = 84                 && Toggle between sorted/natural
          sorted = ! sorted               && Note: use inkey() to pop extra
        endif                             && character stuffed by F3, wait
                                          && 1/10 second if no extra key,
        if lastkey() = 27                 && and exit if ESC was pressed
          exit
        endif

      enddo

      set key -2 to                       && Clear F3 setting
      restore screen from tmpsavscr

    otherwise                             && Any other key exits profile
      exit

   endcase

enddo

restscreen(04,17,21,64,spot)
@ oldrow,oldcol say ""

bliprfmod(oldmod)                         && Restore profiling mode

return(.T.)

procedure bl_toggle                       && Esc from achoice, stuff "T"
keyboard chr(27)+"T"                      && to toggle display of arrays
return

