/*
          Filename : PLUITEMS.PRG
           Remarks : pluitems.idx download utility program
            Author : Rollie C. Ibarra Jr. 
      Date-Written : 17 August, 1997

      Note: compiled under Clipper 5.xx 
            switches < /n/a/m >
            no library 
            no include
            not modular

      ** Modifications **
      Date      Who       Remarks

*/


// Constant definitions for Window.
#define GET_T(cWindow)   Asc(SubStr(cWindow,1,1))
#define GET_L(cWindow)   Asc(SubStr(cWindow,2,1))
#define GET_B(cWindow)   Asc(SubStr(cWindow,3,1))
#define GET_R(cWindow)   Asc(SubStr(cWindow,4,1))
#define GET_WIN(cWindow) SubStr(cWindow,5)

// Constant definitions for Shadow.
#define ATTR_CONV(FORE,BACK) (BACK)/16+(FORE)
#define BLACK   0
#define WHITE   7
#define DK_GRAY 9
#define COL_SHADOW_ATTRIBUTE ATTR_CONV(DK_GRAY,BLACK)
#define BW_SHADOW_ATTRIBUTE  ATTR_CONV(WHITE,BLACK)
#undef  NUM_RETRIES   

#xtranslate PLAYTUNE( <a> )                                                ;
            => aeval( <a>, {|t| tone( t\[1],t\[2] ) })

#xtranslate BUMMER()                                                       ;
            => PlayTune({ {392,1}, {98,1}, {49,5} })

#xtranslate HEYTHERE()                                                     ;
            => PlayTune({ {392,1}, {880,1} })

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                        ;
          =>                                                            ;
          IF <v1> == NIL ; <v1> := <x1> ; END                           ;
          [; IF <vn> == NIL ; <vn> := <xn> ; END ]

#define NET_WAIT     0.5   // Seconds to wait between between retries
#define NET_SECS     2     // Number of seconds to continue retry

#define SC_NONE      0
#define SC_NORMAL    1
#define K_ESC        27

#define FO_READ      0     // Open for reading (default)
#define FO_WRITE     1     // Open for writing
#define FO_READWRITE 2     // Open for reading or writing

#define FO_SHARED    64    // Same as FO_DENYNONE

#define FS_SET       0     // Seek from beginning of file
#define FS_RELATIVE  1     // Seek from current file position
#define FS_END       2     // Seek from end of file

#define FC_NORMAL    0     // Create normal read/write file (default)

#define NORMAL    0
#define F_POSNO   1
#define F_HANDLE  2

memvar getlist

function main(cParm1,cParm2)
local cPath
local cBuffer       
local k,fh,fsource,fdest,nreadbytes := 1024
local hGauge, nPercent 
local totalbytes 
local readbytes := 0
local tot_files := 0
local nOx,nOy
local wOriginal
local nRetries

   set(_SET_SCOREBOARD,.F.)
   set(_SET_WRAP,.T.)
   set(_SET_DATEFORMAT,"mm-dd-yy")
   set(_SET_DELETED,.F.)
   set(_SET_EXACT,.T.)
   set(_SET_SOFTSEEK,.T.)
   set(_SET_CONFIRM,.T.)
   setcancel(.f.)             // disable alt-c
   setcursor(SC_NONE)
   readinsert(.F.)
   nOx := col() ; nOy := row()
   wOriginal := savescreen(0,0,maxrow(),maxcol())
   cOriginal := SetColor("B/W,W+/B,,N/W,N/W")

   cSource := alltrim(cSource)
   if subs(cSource,len(cSource),1) != "\"
      cSource += "\"
   endif   

   SAVE TO PATH.MEM
  
   if !file("location.dbf")
      DbCreate("LOCATION.DBF", aDbf )
   endif   

   NetUse("LOCATION",DB_SHARED,NUM_SECONDS)

   LOCATION->(DbGoTop())

   while LOCATION->(!Eof())

     if LOCATION->(!Deleted())
        cPath := alltrim(LOCATION->PATH)
        if subs(cPath,len(cPath),1) != "\"
           cPath += "\"
           FilLock(0)
           LOCATION->PATH := cPath
        endif     
        // check first if the path exist            
        fh := fopen(cPath+"NUL",FO_READWRITE)
        if ferror() == 3
           Bummer()
           Alert("Path does not Exist or Access Denied at "+cPath,{"<Skip>"})           
        else   

#ifdef NUM_RETRIES        
           nRetries := 1
           while nRetries++ <= NUM_RETRIES
             fdest := fopen(cPath+"FM_TRANS.TXT",FO_READWRITE+FO_SHARED)
             if ferror() == 2 //not found
                fdest := fcreate(cPath+"FM_TRANS.TXT",FC_NORMAL)
             endif
             if ferror()  == NORMAL
                exit
             endif   
           enddo  
#else
           fdest := fopen(cPath+"FM_TRANS.TXT",FO_READWRITE+FO_SHARED)
           if ferror() == 2 //not found
              fdest := fcreate(cPath+"FM_TRANS.TXT",FC_NORMAL)
           endif

           if ferror()
              if Alert("Destination Path FM_TRANS Open/Create Error:"+Str(ferror()),;
                     {" Skip "," Retry "} ) == 2
                 fclose(fh)
                 loop
              endif       
           endif
#endif           
           if ferror() == NORMAL
              tot_files++ 
              fseek( fdest , 0 , FS_END )             
           endif              
           aAdd(aArray,{cPath, fdest })
        endif   
        fclose(fh)
     endif

     LOCATION->(DbSkip())

   enddo        

   LOCATION->(DbCloseArea())

   // do the transfer here

   fsource := fopen(cSource+"FM_TRANS.TXT",FO_READ)

   totalbytes := (fseek(fSource,0,FS_END) * tot_files)
   fseek(fSource,0,FS_SET)
   
   if ferror() != NORMAL
      Bummer() 
      Alert("Error Opening Source "+cSource+"FM_TRANS.TXT;"+;
            "Dos Error : "+trans(ferror(),"99"),{"<Abort>"})
   else   
      hGauge := GaugeNew( 10, 5, 12, MAXCOL() - 5, "W/N", "W+/N" )
      GaugeDisplay( hGauge )
      nPercent := 0      
      cBuffer := space(nReadBytes)
      while ( ( nReadBytes := fread( fsource, @cBuffer, nReadBytes)) > 0)

        for k:=1 to len(aArray)

          if aArray[k,F_HANDLE] > 0
             fwrite( aArray[k,F_HANDLE] ,cBuffer, nReadBytes )
             readbytes += nReadBytes        
             nPercent := (ReadBytes/totalbytes)
             GaugeUpdate( hGauge, nPercent )
          endif

        next k
      
      enddo
      HeyThere()
      
   endif   

   // Close all open files
   for k:= 1 to len(aArray)
     fclose(aArray[k,F_HANDLE])
   next k  

   readinsert(.F.)
   setCursor(SC_NORMAL)
   setcolor(cOriginal)
   set(_SET_EXACT,.T.)
   set(_SET_DELETED,.F.)
   set(_SET_SCOREBOARD,.T.)
   restscreen(0,0,maxrow(),maxcol(),wOriginal)
   setpos(nOy,nOx)
   ?
   ? " FMTRANS Normal Shutdown..."
return nil      


/***
*
*  Gauge.prg
*
*  Sample functions to create, display, and update a percentage completed
*  progress gauge.  This function can be used for creating user interface 
*  options such as a status bar to indicate the current status of a process.
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Note: Compile with /W /N options
*
*/

// Box array definitions
#define B_LEN           9
#define B_TOP           1
#define B_LEFT          2
#define B_BOTTOM        3
#define B_RIGHT         4
#define B_BACKCOLOR     5
#define B_BARCOLOR      6
#define B_DISPLAYNUM    7
#define B_BARCHAR       8
#define B_PERCENT       9

#define B_BOXLINES      "ÚÄ¿³ÙÄÀ³"


/***
*  GaugeNew( <nRowTop>, <nColumnTop>, <nRowBottom>, <nColumnBottom>, 
*     [<cBackgroundColor>], 
*     [<cGaugeColor>], 
*     [<cGaugeCharacter>] ) --> aGauge
*
*  Create a new gauge array
*
*/
FUNCTION GaugeNew( nTop, nLeft, nBottom, nRight, ;
                 cBackColor, cBarColor, cBarCharacter )

   LOCAL aHandle[ B_LEN ]     // Contains info about the gauge

   // Assign default values
   aHandle[ B_TOP ]        := nTop
   aHandle[ B_LEFT ]       := nLeft
   aHandle[ B_BOTTOM ]     := nBottom
   aHandle[ B_RIGHT ]      := nRight
   aHandle[ B_BACKCOLOR ]  := "W/N"
   aHandle[ B_BARCOLOR ]   := "W+/N"
   aHandle[ B_DISPLAYNUM ] := .T.
   aHandle[ B_BARCHAR ]    := chr(177) //CHR( 219 )
   aHandle[ B_PERCENT ]    := 0

   // Resolve parameters
   IF cBackColor <> NIL
      aHandle[ B_BACKCOLOR ] := cBackColor
   ENDIF

   IF cBarColor <> NIL
      aHandle[ B_BARCOLOR ] := cBarColor
   ENDIF

   IF cBarCharacter <> NIL
      aHandle[ B_BARCHAR ] := cBarCharacter
   ENDIF

   // OK, the defaults are set, now let's make sure it will fit on the
   // screen correctly
   IF aHandle[ B_RIGHT ] < aHandle[ B_LEFT ] + 4
      aHandle[ B_RIGHT ] := aHandle[ B_LEFT ] + 4
   ENDIF

   IF aHandle[ B_BOTTOM ] < aHandle[ B_TOP ] + 2
      aHandle[ B_BOTTOM ] := aHandle[ B_TOP ] + 2
   ENDIF

   // Determine if we can fit the bracketed number on top of the graph
   IF aHandle[ B_RIGHT ] < aHandle[ B_LEFT ] + 9
      aHandle[ B_DISPLAYNUM ] := .F.
   ENDIF

   RETURN( aHandle )



/***
*
*  GaugeDisplay( aGauge ) --> aGauge
*
*  Display a gauge array to the screen
*
*/
FUNCTION GaugeDisplay( aHandle )
   
   LOCAL nCenter   := ROUND( (aHandle[B_RIGHT] - aHandle[B_LEFT]) / 2, 0) + 1
   LOCAL cOldColor := SETCOLOR( aHandle[ B_BACKCOLOR ] )

   @ aHandle[ B_TOP ], aHandle[ B_LEFT ] CLEAR TO ;
     aHandle[ B_BOTTOM ], aHandle[ B_RIGHT ]

   @ aHandle[ B_TOP ], aHandle[ B_LEFT ], ;
     aHandle[ B_BOTTOM ], aHandle[ B_RIGHT ] BOX B_BOXLINES

   IF aHandle[ B_DISPLAYNUM ]
      @ aHandle[ B_TOP ], nCenter SAY "[      ]"
   ENDIF

   SETCOLOR( cOldColor )

   // Draw bar to show current percent
   GaugeUpdate( aHandle, aHandle[ B_PERCENT ] )

   RETURN( aHandle )



/***
*
*  GaugeUpdate( aGauge, nPercent ) --> aGauge
*
*  Updates a gauge with a new progress value and redisplays the gauge 
*  to the screen to the screen
*
*/
FUNCTION GaugeUpdate( aHandle, nPercent )
   
   LOCAL nCenter   := ROUND( (aHandle[B_RIGHT] - aHandle[B_LEFT]) / 2, 0) + 1
   LOCAL cOldColor := SETCOLOR( aHandle[ B_BARCOLOR ] )
   LOCAL nBarRatio := (aHandle[ B_RIGHT ]) - (aHandle[ B_LEFT ] + 1)
   LOCAL nRow      := 0
   LOCAL nCols     := 0

   IF aHandle[ B_DISPLAYNUM ]
      @ aHandle[ B_TOP ], nCenter + 2 SAY STR( nPercent * 100, 3 ) + "%"
   ENDIF

   IF nPercent > 1
      nPercent := 1
   ENDIF

   IF nPercent < 0
      nPercent := 0
   ENDIF

   nCols := ROUND( nPercent * nBarRatio, 0 )

   @ aHandle[ B_TOP ] + 1, aHandle[ B_LEFT ] + 1 CLEAR TO ;
     aHandle[ B_BOTTOM ] - 1, aHandle[ B_RIGHT ] - 1

   FOR nRow := 1 TO (aHandle[ B_BOTTOM ] - aHandle[ B_TOP ] - 1)
      @ nRow + aHandle[ B_TOP ], aHandle[ B_LEFT ] + 1 SAY ;
        REPLICATE( aHandle[ B_BARCHAR ], nCols )
   NEXT

   SETCOLOR( cOldColor )

RETURN( aHandle )





/***
*
*  FilLock( [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to FLOCK() with optional retry
*
*  Parameter:
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True if successful, false if not
*
*/
FUNCTION FilLock( nSeconds )
   
   LOCAL lForever    // Retry forever?

   DEFAULT nSeconds TO NET_SECS

   IF FLOCK()
      RETURN ( .T. )       // NOTE
   ENDIF

   lForever := ( nSeconds == 0 )

   // Keep trying until our time's up
   DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
      
      INKEY( NET_WAIT )    // Wait NET_WAIT seconds
      nSeconds -= NET_WAIT

      IF FLOCK()
         RETURN ( .T. )    // NOTE
      ENDIF

   ENDDO

   RETURN ( .F. )          // Not locked



/***
*
*  NetUse( <cDatabase>, <lOpenMode>, [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to USE a database file with optional retry
*
*  Parameters:
*     cDatabase    - Database file to open
*     lOpenMode    - Sharing mode: True indicates EXCLUSIVE, false
*                    indicates SHARED
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True if successfull, false if not
*
*/
FUNCTION NetUse( cDatabase, lOpenMode, nSeconds )
   
   LOCAL lForever    // Retry forever?

   DEFAULT nSeconds TO NET_SECS
   lForever := ( nSeconds == 0 )

   // Keep trying as long as our time's not up
   DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
     
     // lOpenMode determines the mode files are opened in
     IF lOpenMode       
         USE ( cDatabase ) EXCLUSIVE  
     ELSE
         USE ( cDatabase ) SHARED
     ENDIF

     IF !NETERR()
        RETURN ( .T. )     // NOTE
     ENDIF

     INKEY( NET_WAIT )     // Wait
     nSeconds -= NET_WAIT

   ENDDO

RETURN ( .F. )          // USE fails

function OpenWindow(t,l,b,r,cTitle)
local cWindow,i,k,c,delay
   SetColor("N/W")                     // Change color to Black on White.
   // Save coordinates and screen to buffer.
   cWindow:=chr(t)+chr(l)+chr(b+1)+chr(r+1)+SaveScreen(t,l,b+1,r+1)
   k:=((r-l)/2)
   for i:=((b-t)/2) to b
   for c:=1 to 3
    @ max(t,b-i),max(l,(r-k)) clear to min(b,t+i),min(r,(l+k))
    for delay := 1 to 1200
     /*delay for half a sec */
    next
   next
   k++
   next                                // palabok
   @ t,l clear to b,r                  // Clear window.
   @ t,l to b,r                      // Draw box.
   Shadow(t,l,b,r)                     // Draw shadow of window.
   if Len(AllTrim(cTitle))>0           // Is there a title?
      SetColor(if(isColor(),"W+/RB+","W+/N"))                // Change color to White on Cyan.
      @ t,l clear to t,r               // Clear title area.
      @ t,l+2 say cTitle               // Display title.
      SetColor("N/W")                  // Change color to Black on White.
   endif
return cWindow                         // Value returned: CHAR cWindow

function CloseWindow(cWindow)
   // Restore previously saved screen.
   RestScreen(GET_T(cWindow),GET_L(cWindow),GET_B(cWindow),;
   GET_R(cWindow),GET_WIN(cWindow))
return nil                             // Value returned: NIL

function Shadow(t,l,b,r)
local shadow_attribute
   // Only if there is room.
   if r<MaxCol() .and. b<MaxRow()
      shadow_attribute:=iif(IsColor(),COL_SHADOW_ATTRIBUTE,BW_SHADOW_ATTRIBUTE)
      ShadowAttr(b+1,l+1,b+1,r+1,shadow_attribute)
      ShadowAttr(t+1,r+1,b+1,r+1,shadow_attribute)
   endif
return nil

static function ShadowAttr(t,l,b,r,new_attr)
local old_scr_area,new_scr_area,i
   // Save screen area in a variable.
   old_scr_area:=SaveScreen(t,l,b,r)
   // Initialize new screen area.
   new_scr_area:=""
   // Copy each character in saved area to new string & change attribute.
   for i:=1 to Len(old_scr_area) step 2
      new_scr_area:=new_scr_area+SubStr(old_scr_area,i,1)+chr(new_attr)
   next
   // Restore new area in same position.
   RestScreen(t,l,b,r,new_scr_area)
return nil

