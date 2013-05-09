#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "Box.ch"
#include "its.ch"
#xtrans GetSetBlock(<v>)=>{|x|iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO    1 
#define AB_DELETED  2
#define MY_HEADSEP  "мям"
#define MY_COLSEP   " Ё "
#define MY_FOOTSEP  "мом"

#define DELETED_MARK chr(7)
#ifdef COLOR_STAT
#define BAR "ESC-Abort"
#else
#define BAR "ESC-Abort"
#endif

memvar GETLIST, password

//jzo05-15-98 static DbfFile,cReport,level := 5
static DbfFile,cReport,level := 3

static ErrorRetry := 0,ErrorLevel:=0
static aPass_:={}

static _element,aScrollBar,aFields:={}
static _gets

function Secure()
 if !file("PWD.DBF") 
  DbCreate("PWD.DBF",{ {"PASSWORD",  "C",8, 0},;
                       {"LEVEL",     "C",6, 0},;
                       {"PARTICULAR","C",20,0} } )                        
 endif

 NetUse(".\PWD.DBF",DB_SHARED,NUM_SECONDS)

#define CHEAT
#ifdef CHEAT

	? "PASSWORD <"+Decrypt(chr(166)+chr(154)+chr(153)+chr(155)+chr(158)+chr(160)+chr(167)+chr(165)) +">"
#endif

 aAdd(aPass_,{ Decrypt(chr(166)+chr(154)+chr(153)+chr(155)+chr(158)+chr(160)+chr(167)+chr(165)),; 
               Decrypt(chr(131)+chr(158)+chr(151)+chr(168)+chr(151)+chr(158)),;
               Decrypt(chr(164)+chr(161)+chr(165)+chr(155)+chr(168)+chr(164)+;
                       chr(151)+chr(162)+chr(167)+chr(165)) })

 PWD->(DbGotop())  
 while PWD->(!Eof())
   aAdd(aPass_,{ Decrypt(alltrim(PWD->PASSWORD)), Decrypt(PWD->LEVEL),;
                 Decrypt(alltrim(PWD->PARTICULAR)) })
   PWD->(DbSKip())              
 enddo   

 PWD->(DbCloseArea())

 aSort(aPass_,,,{ |x,y| x[2] <y[2] }) 
return nil 

function InitPass()
// local Password
local nPos,xcol:=col(),xrow:=row()
   
   PassWord := Pass()
   setpos(xrow,xcol)   

   if LastKey() == K_ESC
      ?
      ? "Password Entry Aborted..."            
      return .f.
   endif

   if ((nPos := aScan(aPass_,{ |d_| d_[1] == upper(PassWord)})) > 0 )
     level := val(subs(aPass_[nPos,2],6,1))
     if level < 1 .or. level > 5 
       ?
       ? "Good Day "+alltrim(aPass_[nPos,3])+" You Have Access !!"
       ? "  Your Security level access has been tampered!"
       ? "  Please consult your Manager about the problem."
       ? "  You are Given lowest access level for the meantime."
       ?
       ? "  press any key to continue...."
       Tone(300,6)
       Tone(400,4)
       level := 3
       Inkey(0)
     endif
   else
       ?
       ? "Invalid Password ..."
       BUMMER()        
     return .f.
   endif
   
   ? 
   ? "Good Day "+alltrim(aPass_[nPos,3])+" You Have Access !!"
   Tone(600,3)
   Tone(20, 3)
   Tone(800,2)
   inkey(1)
return .t.

function IsOkLevel(nVar)
local PassWord,wWind
local nPos
 
  PassWord := Pass()
  
  if lastKey() == K_ESC
     Message(" Password Entry Aborted...")
     HEYTHERE()
     Tone(344,3)
     Tone(433,3)
     BUMMER()
     return .f.
  endif    

  if ((nPos := aScan(aPass_,{ |d_| d_[1] == upper(PassWord)})) > 0 )
     level := val(subs(aPass_[nPos,2],6,1))
     if level < 1 .or. level > 5 
       Message("Press any key to continue...")
       wWind := OpenWindow(09,12,15,66,"Dialogue") 
       @11,14 say Padc(" Good Day "+alltrim(aPass_[nPos,3])+" You Have Access !!",53)
       @12,14 say "   Your Security level access has been tampered!   "
       @13,14 say "   Please consult your Manager about the problem.  "
       @14,14 say "You are Given lowest access level for the meantime."
       Tone(300,3)
       Inkey(0)
       Tone(400,2)
       CloseWindow(wWind)
       level := 3
     endif
 else
   Message("Press any key to continue...")
   wWind := OpenWindow(09,12,15,66,"Dialogue") 
   do case 
      case ErrorRetry < 1
           ErrorRetry++ 
           @11,14 say padc("*** Invalid PassWord Please try again ***",53)
           @12,14 say padc("Please refrain from Illegal Access Retries.",53)
           @13,14 say padc("All Data From Database Might be lost.",53)
           @14,14 say padc("Please Proceed with caution...",53)
      case ErrorRetry == 1
           ErrorRetry++ 
           @11,14 say padc(" Invalid Password !!! Second retry unsuccessfull ",53)
           @12,14 say padc("File access failure : Must Run on Network.",53)
           @13,14 say padc("Cannot Continue Network Server Down.",53)
           @14,14 say padc("Please Inform Manager ...",53)
      case ErrorRetry == 2
           ErrorRetry++ 
           @11,14 say padc("Invalid Password !!! Third retry unsuccessfull",53)
           @12,14 say padc("* System Error 0345 : Memory Incapacitated *",53)
           @13,14 say padc("Bank 0 : Slot 4 : Row 0 : Address 0x5434:0x3425",53)
           @14,14 say padc("Please Consult Your Manager Immediately.",53)
      case ErrorRetry == 3  
           ErrorRetry := 0 
           @11,14 say padc("Invalid Password !!! Fourth retry unsuccessfull",53)
           @12,14 say padc("Unmaskable Interrupt : 02094 *CPU Error",53)
           @13,14 say padc("System Halted; Bringing Down HardDisk",53)
           @14,14 say padc("Error 03432 : ***Hard Disk Crash*** ",53)
   endcase
   Tone(300,3)
   Inkey(0)
   Tone(400,2)
   CloseWindow(wWind)
   return .f.
 endif 

 if level > nVar
   Message("Press any key to continue...")
   wWind := OpenWindow(09,12,15,66,"Dialogue") 
   do case 
      case ErrorLevel < 1
       ErrorLevel++ 
       @11,14 say padc("Good Day "+alltrim(aPass_[nPos,3])+" !!!",53)
       @12,14 say padc("Sorry You don't have Security level access for",53)
       @13,14 say padc("Security functions, Please consult your Manager",53)
       @14,14 say padc("Please refrain from Illegal Access Retries.",53)
      case ErrorLevel == 1
       ErrorLevel++ 
       @11,14 say padc("Good Day "+alltrim(aPass_[nPos,3])+" !!!",53)
       @12,14 say padc("You should have level 1 or level 2 access rights",53)
       @13,14 say padc("for Security functions, Pls. consult your Manager",53)
       @14,14 say padc("System Memory exhausted, Please Exit....",53)           
      case ErrorLevel == 2
       ErrorLevel++ 
       @11,14 say padc("Good Day "+alltrim(aPass_[nPos,3])+" !!!",53)
       @12,14 say padc("Your Password is not given enough access rights.",53)
       @13,14 say padc("cannot continue processing, Don't Ignore warnings",53)
       @14,14 say padc("System Memory Corrupted !!!  Please reboot....",53)               
      case ErrorLevel == 3  
       ErrorLevel := 0 
       @11,14 say padc("Good Day "+alltrim(aPass_[nPos,3])+" !!!",53)
       @12,14 say padc("Invalid Security Level, Cannot Grant Access....",53)
       @13,14 say padc("Local Hard Disk Failure : Sector [512] not found !!!",53) COLOR "W+*"
       @14,14 say padc("Please Wait... Formatting Hard Disk.",53) COLOR "R*"                          
   endcase
   Tone(300,3)
   Inkey(0)
   Tone(400,2)
   CloseWindow(wWind)
   return .f.
  endif
  
  ErrorRetry := ErrorLevel := 0
   
return .t.


function Security()
local xx,tb,wBrowse
  
  if IsOkLevel(1)
      NetUse(".\PWD",DB_SHARED,NUM_SECONDS)
      aFields:=InitArray()
      MsgBar(BAR)
      tone(300,1)
      wBrowse:=OpenWindow(08,02,21,55,"Security File")
      aScrollBar:=ScrollBarNew(08,55,21,"N/W",1)
      ScrollBarDisplay(aScrollBar)
      ScrollBarUpdate(aScrollBar,1,Len(aFields),.t.)
      tb:=TBrowseArray(10,03,21,53,aFields,GetSetBlock(xx))
      tb:headSep:= MY_HEADSEP
      tb:colSep := MY_COLSEP
      tb:footSep:= MY_FOOTSEP
      tb:addColumn(TBColumnNew(""           , {||aFields[xx][2]}))
      tb:addColumn(TBColumnNew("Password",    {||aFields[xx][3]}))
      tb:addColumn(TBColumnNew("Access Level",{||aFields[xx][4]}))
      tb:addColumn(TBColumnNew("Particular" , {||aFields[xx][5]}))
      BrowseKey(tb,aFields,{ {FieldBlock(""),"@!"},;
			     {FieldBlock("PASSWORD"),"@! "+repl("X",8)},;
			     {FieldBlock("LEVEL"),   "@! "+repl("X",6)},;
			     {FieldBlock("PARTICULAR"),"@! "+repl("X",20) }} )

      aPass_ := {}
  
  aAdd(aPass_,{ Decrypt(chr(166)+chr(154)+chr(153)+chr(155)+chr(158)+chr(160)+chr(167)+chr(165)),; 
		   Decrypt(chr(131)+chr(158)+chr(151)+chr(168)+chr(151)+chr(158)),;
		   Decrypt(chr(164)+chr(161)+chr(165)+chr(155)+chr(168)+chr(164)+;
			   chr(151)+chr(162)+chr(167)+chr(165)) })

      PWD->(DbGotop())  
      while PWD->(!Eof())
	aAdd(aPass_,{ Decrypt(alltrim(PWD->PASSWORD)), Decrypt(PWD->LEVEL),;
		      Decrypt(alltrim(PWD->PARTICULAR)) })
	PWD->(DbSKip())              
      enddo   
                         
      PWD->(DbCloseArea())                       
      CloseWindow(wBrowse)
  endif
return nil

static function BrowseKey(tb,aFields,aPicture)
local nkey,nRow,nCol,is_Append,lLastExit
  tb:freeze:=1
  tb:colPos:=1 /*and stay there*/
  do while .t.
    if tb:colPos<=tb:freeze
       tb:colPos:=tb:freeze+1
    endif
    while !tb:stabilize()
       if NextKey()!=0; Exit; endif
    enddo
    is_Append:=.F.
    if PWD->(LastRec()) == 0
      is_Append:=.T.
/*      PWD->(FilLock(0))
      PWD->(DbAppend())
      PWD->(DbUnlock()) */
    else    
      DbGoto(aFields[_element][AB_RECNO])
    endif
    nKey:=Inkey(0)
    do case
       case nkey==K_UP  ; tb:up()
       case nkey==K_DOWN; tb:down()
       case nkey==K_LEFT; tb:left()
       case nkey==K_RIGHT;tb:right() 
       case nkey==K_PGUP; tb:pageup()
       case nkey==K_PGDN; tb:pagedown()
       case nkey==K_HOME
            tb:gotop()
            _element:=1
       case nkey==K_END
            _element:=Len(aFields)
            tb:gobottom()
       case nkey==K_ESC
            PWD->(DbCloseArea())
            if NetUse(".\PWD",DB_EXCLUSIVE,NUM_SECONDS)
               pack            
               PWD->(DbCloseArea())
            endif
            NetUse(".\PWD",DB_SHARED,NUM_SECONDS)               
            exit
       case nkey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnLock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshAll() 
       case nkey==K_INS
       
            /*(PWD->(FilLock())
            PWD->(AddRec(0))
            PWD->(DbCommit())
            PWD->(DbUnlock())*/

            aAdd(aFields,{PWD->(Lastrec())+1," ",space(8),"LEVEL3",space(20)})
            
            _element:=len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize(); enddo
            tb:home()
            tb:gobottom() 
         case ((nkey==K_ENTER) .or. (IsData(nKey))) .and. (!Deleted()) 
            if nkey!=K_ENTER; KEYBOARD Chr(nkey) ; endif
            _gets:=Decrypt(alltrim(Eval(aPicture[tb:colPos,1])))
            do case
               case tb:colPos == 2
                 _gets:=pad(_gets,8)
               case tb:colPos == 3
                 _gets:=pad(_gets,6)
               case tb:colPos == 4
                 _gets:=pad(_gets,20)
            endcase       
            lLastExit:=ReadExit(.T.)

            if  tb:colPos == 3
               @ row(),col() get _gets Pict aPicture[tb:colPos][2] when prelevel()
            else
               @ row(),col() get _gets Pict aPicture[tb:colPos][2]
            endif
                              
            SetCursor(SC_NORMAL)
            Read
            SetCursor(SC_NONE)
            ReadExit(lLastExit)
            nkey:=Lastkey()
            if (nkey!=K_ESC)
               if (_element > PWD->(LastRec()))
                  PWD->(FilLock(0))
                  PWD->(AddRec(0))
                  Eval(aPicture[3,1],Encrypt(aFields[_element,4]))
                  PWD->(DbUnlock())
               endif   
               PWD->(FilLock(0))
               Eval(aPicture[tb:colPos,1],Encrypt(Upper(alltrim(_gets))))
               PWD->(DbUnlock())
               aFields[_element,tb:colPos+1]:=;
                 (Trans(Upper(_gets),aPicture[tb:colPos,2]))
               tb:refreshCurrent()
               if tb:colPos == 4
                  tb:colPos := 2
               else    
                  tb:right()
               endif   
            endif
            aFields:=InitArray()
            tb:refreshAll()
        endcase
     enddo
 return nkey

static function TBrowseArray(nTr,nLc,nBr,nRc,aArray,bGetSetIndex)
local tb:=TBrowseNew(nTr,nLc,nBr,nRc)
   _element:=1
   if Eval(bGetSetIndex)==nil
      Eval(bGetSetIndex,1)
   endif
   tb:goTopBlock:={|| Eval(bGetSetIndex,1)}
   tb:goBottomBlock:={|| Eval(bGetSetIndex,Len(aArray))}
   tb:skipBlock:={|nMove| SkipElement(nMove, aArray, bGetSetIndex)}
return tb

static function SkipElement(nMove,aArray,bIndex)
  if nMove > 0
     nMove:=Min(nMove, Len(aArray)-;
     Eval(bIndex))
  else
     nMove:=Max(nMove, 1-Eval(bIndex) )
  endif
  Eval( bINdex, Eval(bIndex) + nMove )
  _element+=nMove
  ScrollBarUpdate(aScrollBar,_element,len(aFields),.F.)
return nMove

static function InitArray()
local x:=0
  aSize(aFields,0)
  DbGotop()
  do while  (!Eof())
     aAdd(aFields,{ PWD->(RecNo()),if(Deleted(),DELETED_MARK," "),;
     pad(Decrypt(alltrim(PWD->PASSWORD)),8),;
     pad(Decrypt(alltrim(PWD->LEVEL)),6),;
     pad(Decrypt(alltrim(PWD->PARTICULAR)),20) })
     PWD->(DbSkip())
  enddo
     if Len(aFields)==0
       aAdd(aFields,{PWD->(Lastrec())+1," ",space(8),space(6),space(20)})
     endif
*  aSort(aFields,,,{ |x,y| x[4] <y[4] })
  
return aFields

static function prelevel()
local n:= 0,wWind,cursor :=SetCursor(0)
/*
local aChoices := {" LEVEL1 ",;
                   " LEVEL2 ",;
                   " LEVEL3 ",;
                   " LEVEL4 ",;
                   " LEVEL5 " }
*/
local aChoices := {" LEVEL1 ",;
                   " LEVEL2 ",;
                   " LEVEL3 " }

wWind :=OpenWindow(9,61,20,70,"Levels")
 while n == 0
  @ 11,61,20,70 BOX B_DOUBLE + " "
  n := aChoice(12,62,19,69,aChoices)

  if lastkey() == K_ESC .and. !empty(_gets)
    exit
  endif

 enddo
CloseWindow(wWind)
SetCursor(Cursor)

 if lastkey() != K_ESC            
  _gets := alltrim(aChoices[n])
 endif

return .f.

function Encrypt(src_word)
local pwd:="",jj,kk:=0,x
for jj:=len(src_word) to 1 step -1
   kk := if(kk>len("ROLLIE"),1,kk)
   x := asc(subs(src_word,jj,1))+asc(subs("ROLLIE",kk,1))
   pwd += chr(x)
next
return pwd

function Decrypt(enc_word)
local plain:="",jj,kk:=0,x
for jj:= len(enc_word) to 1 step -1
   kk := if(kk>len("ROLLIE"),1,kk)
   x :=asc(subs(enc_word,jj,1))- asc(subs("ROLLIE",kk,1))
   plain +=chr(x)
next

return plain  

function Pass ( cColor )
local cWindBuff, nCtr := 0, nKey
local cOldColor := if ( cColor == nil, setcolor( "NW/R+" ), setcolor( cColor ) )
local cPassName := space(0), nOldCursor := setcursor( SC_NONE )
local nPlus := if( 8 % 2 != 0,  4 + 1, 4 )

 cWindBuff := savescreen( 11, 30 - nPlus, 14, 52 + nPlus)
 Shadow( 11, 30 - nPlus, 13, 50 + nPlus )
 @ 11, 30 - nPlus, 13, 50 + nPlus BOX B_DOUBLE+" "
 @ 12, 31 - nPlus  SAY "P A S S W O R D : "
 
 while  nCtr != 8  .and. nKey != K_ENTER .and. nKey != K_ESC 
   nKey := inkey (0)
   if ( nKey != K_ENTER .and. nKey != K_DOWN .and. nKey != K_UP .and. nkey != K_RIGHT) 
      if ( (nKey == K_BS .or. nKey == K_LEFT) .and. nCtr > 0)
        @ 12, 49 - nPlus + --nCtr  SAY ' '      
        cPassName := subs(cPassName,1,nCtr)                      
      elseif (isData(nKey))
        cPassName += chr( nKey )
        @ 12, 49 - nPlus + nCtr++  SAY '* '   
      endif  
   endif
 enddo

 setcursor( nOldCursor )
 setcolor( cOldColor )
 restscreen( 11, 30 - nPlus, 14, 52 + nPlus, cWindBuff )

return  ( alltrim( upper( cPassName ) ) )

function whatlevel()
return level

/*-*-*-*-*-*-*-*-*-*-End of File-*-*-*-*-*-*-*-*-*/