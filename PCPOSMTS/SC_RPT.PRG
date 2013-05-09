#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "its.ch"
#include "Memoedit.ch"
#include "janus.ch"

#define MAX_SIZE  (memory(1) * 768)

memvar getlist,nUnit,n,dStartDate,dEndDate,nLimit, cReport

static nMaxLen, nChrSize // , cReport

function ScreenEdit( ThisFile,  nLnt, cTitle, nFont )
local clr:=Setcolor()
local wWindBuff,nMaxrow := maxrow()+1,nMaxcol := maxcol()+1
cReport := MemoRead(ThisFile+".PRN")
nMaxLen := nLnt
nChrSize := nFont 

 scroll(03,01,maxrow(),maxcol())
  
 if !setmode(50,80) .and. !setmode(43,80)
    setmode(nMaxrow,nMaxcol)    
 endif 

 _logo() 
 
 wWindBuff:=OpenWindow(2,1,maxrow()-2,78,cTitle)
 Message("  Use cursor keys to navigate, press F10 to print, "+ ;
         "Esc to abort.",nUnit) 

 if !empty(cReport)
    MemoEdit(cReport,3,2,maxrow()-2,77,.f.,'MyEditFunc',nMaxLen )
 else
    alert(" Error:00006 File "+ThisFile+" does not exist")
 endif
 
 Setcolor(clr)
 setcursor(SC_NONE)
 CloseWindow(wWindBuff)
 setmode(nMaxrow,nMaxcol)  
return (lastkey()==K_ESC) 


function MyEditFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 02,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     
                     // set printer char size
                     GetCharSize(nChrSize)   
                     
                     nLines:=MLCount(cReport,254)
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(cReport,nMaxLen,nCurrLine)
                        if nLineCtr>60
                         //  eject
                           nLineCtr:=0
                        endif
                        ? "    " + cLine
                        nLineCtr++
                     next
                     // eject
                     COND_OFF
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif

            Message("  Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal



// check if file size is less than 64k - maximum for memoreading
// if greater it will be directed to the printer 
// else, memoedit

function lChkFSize( ThisFile )
 local lStat := .f., nFSize, nFHandle

 IF !FILE(THISFILE+".PRN")
  ?? CHR(7)
  ALERT("File : " + ThisFile + " not found !!!")
 ENDIF 
 // open file to check
 nFHandle := fOpen(ThisFile+".PRN")           
 
 // get file size
 nFSize   := fSeek(nFHandle, 0, FS_END)
 fClose(nFHandle)

 *alert( "File : " + ThisFile + ", Size : " + alltrim(str(nFSize)) )
return (nFSize < MAX_SIZE)   


// Added for screen or printed reports.
// if file created is less than 64K, it can be
// listed to screen else report directed to printer

// eso - 08/01/95
function Repgen( cRepID, cRepName, nCharType, nMaxLen )  
 local nGoPrint := 2, cStr
 local nHandle
  
   // check file size, true if lesser than 64K - 
   // maximum for memoread

   if lChkFSize(cRepID)         
     ScreenEdit( cRepID, nMaxLen, cRepName, 1 )
   else
    ?? CHR(7)
    if Alert("File : "+cRepID+" too large, will be directed to PRINTER", ;
       {"Proceed", "Quit"} ) == 1
       
      do while nGoPrint != 1
       if isprinter()
        alert("Presss Any Key to Start Printing")     
        Message("Printing FILE : "+cRepID+".PRN") 
        
        SET CONSOLE OFF
        SET PRINTER ON
        // Set print char
        GetCharSize(nCharType)
        
         while ((nHandle := fopen(cRepID+".PRN",FO_READ)) == -1)
             if alert("Error Opening "+cRepID+".PRN...",{"Retry","Abort"}) != 1
                return nil
             endif
         enddo      

         while !Feof(nHandle)
          cStr := Freadstr(nHandle,MAX_SIZE)
          ?? cStr
         enddo
         
         fClose(nHandle) 
        
        COND_OFF
        CPS_10 
        SET PRINTER OFF
        SET CONSOLE ON
        exit
      else
       nGoPrint := alert("Printer Not Ready ! ", {"Quit", "Retry"})  
     endif  
     enddo 
    endif 
   endif  
   *if file(cRepID+".PRN")
   *  if alert("Delete FILE : " +cRepID+".PRN",{"YES","NO"}) == 1
   *    ferase(cRepID+".PRN")
   *  endif  
   *endif  
return nil


static function GetCharSize(cSize)
 do case
   case cSize == 0
     COND_OFF
   case cSize == 1
     CPS_12
     COND_ON
   case cSize == 2
     COND_ON
 end case   
 
return nil


function Qty2Disp()
local wValid
  nLimit:=100
    Message("Enter number of items to list")
    wValid := OpenWindow(09,12,14,66,"Printing Validation Box")
    @ 10,12 to 14,66 double    
      @ 12,17 say "Enter item count to display" get nLimit pict "999999"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return lastkey() <> K_ESC


function GetValid()
local wValid
    dStartDate :=  dEndDate := date()
    Message("Enter dates of last updates to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "Enter starting date (MM-DD-YY format)" get dStartDate pict "@D"
      @ 13,17 say "        Ending date (MM-DD-YY format)" get dEndDate pict "@D"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return if(LastKey()==K_ESC,.F.,.T.)

function DatesOk(cFile)
local lRetVal
  
  if empty(dStartDate) .and. empty(dEndDate) 
     lRetVal := .T.
  elseif empty(dStartDate)
     lRetVal := cFile <= dEndDate
  elseif empty(dEndDate)
     lREtVal := cFile >= dStartdate
  else    
     lRetval := cFile >= dStartDate .and. cFile <= dEndDate
  endif        
  
return lretVal

function DatesOk2(dDate)
local lRetVal
  
  if empty(dStartDate) .and. empty(dEndDate) 
     lRetVal := .T.
  elseif empty(dStartDate)
     lRetVal := dDate <= dEndDate
  elseif empty(dEndDate)
     lREtVal := dDate >= dStartdate
  else    
     lRetval := dDate >= dStartDate .and. dDate <= dEndDate
  endif        
  
return lretVal

      
function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 01,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,200)
                    // ?  chr(27) + chr(120) + chr(1)   // select NLQ
                     
		     ? chr(15)
                    // ?? chr(27) + chr(107) + chr(0)   // select Roman
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(cReport,200,nCurrLine)
#ifndef EJECT_FROM_FILE                        
                        if nLineCtr>60
//                           eject
                           nLineCtr:=0
                        endif
#endif                        
                        ? cLine
                        nLineCtr++
                     next
#ifndef EJECT_FROM_FILE                     
//                     eject
#endif                     
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
							?? chr(18)
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal


function Editor2Func(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 01,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,80)
                    // ?  chr(27) + chr(120) + chr(1)   // select NLQ
                    // ?? chr(15) 
                    // ?? chr(27) + chr(107) + chr(0)   // select Roman
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(cReport,80,nCurrLine)
								
#ifndef EJECT_FROM_FILE                        
                        if nLineCtr>60
                  //         eject
                           nLineCtr:=0
                        endif
#endif                        
                        ? cLine
                        nLineCtr++
                     next
#ifndef EJECT_FROM_FILE                     
                //     eject
#endif                     
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
//                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
	
return nRetVal




function Editor3Func(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 01,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,80)
                    // ?  chr(27) + chr(120) + chr(1)   // select NLQ
                    // ?? chr(15) 
                    // ?? chr(27) + chr(107) + chr(0)   // select Roman
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(cReport,186,nCurrLine)
								
#ifndef EJECT_FROM_FILE                        
                        if nLineCtr>60
                         //  eject
                           nLineCtr:=0
                        endif
#endif                        
                        ? cLine
                        nLineCtr++
                     next
#ifndef EJECT_FROM_FILE                     
                    // eject
#endif                     
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
//                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
	
return nRetVal

//jzo
      
function Editor4Func(nMode,nLine,nCol)
#undef very_wide
#undef wide_page
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 01,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,230)
                    // ?  chr(27) + chr(120) + chr(1)   // select NLQ
                     
		     ? chr(15)
                    // ?? chr(27) + chr(107) + chr(0)   // select Roman
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(cReport,230,nCurrLine)
#ifndef EJECT_FROM_FILE                        
                        if nLineCtr>60
//                           eject
                           nLineCtr:=0
                        endif
#endif                        
                        ? cLine
                        nLineCtr++
                     next
#ifndef EJECT_FROM_FILE                     
//                     eject
#endif                     
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
							?? chr(18)
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal


function Direct2Prn(cFName)
local nFH, cStr := "", cReadStr := ""
local nContinue := 0, lReady := .F.

  // check printer
  //  alert("press any key to print ...")

  while !IsPrinter() 
    BUMMER()
    if Alert("Printer not ready / on-line, ESC - Abort",{"Retry", "Quit"}) != 1
      return nil   
    endif
  enddo
  
  Message("Printing....please wait!")
  Set(_SET_CONSOLE,.F.)
  Set(_SET_PRINTER,.T.)
  ?? chr(15) 
  setprc(0,0)

  nFH := fopen(cfName, FO_READ)

  while !feof(nFH)
  
   cStr := ""
   while (cReadStr := freadstr(nFh,1)) != chr(13) .and. !feof(nFH)
     cStr += cReadStr
     cReadStr := ""
   enddo  
   
   lReady := IsPrinter()  
   
   if lReady 
    ?? cStr
   else
    BUMMER()
    nContinue := alert("I/O error : Printer not ready", {"Retry","Quit"})
   endif 

   if nContinue == 2
    exit
    eject
   endif 

  enddo 

  Set(_SET_CONSOLE,.T.)
  Set(_SET_PRINTER,.F.)
  
 fclose(nFH)
return nil