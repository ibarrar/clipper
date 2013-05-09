#include "keymap.ch"
#include "powerpos.ch"

static key_val := 0
static keymap_ := {}

function keymap_init()
local i,nTemp

#ifdef SPECTRUM_586_MACHINE
local key_fix_val_ := { 28, -1, -2, -3,-4, -5, -6,-7, -8,-9,22, 1,18, 5,  3, ;
                        27,-40,-41, 91,93,123,125,60, 62,63, 7, 6,19,24,  4, ;
                        09, 33, 64, 35,36, 37, 94,38, 42,40,41,95,61,47,  8, ;
                        81, 87, 69, 82,84, 89, 85,73,205,13,55,56,57,42,203, ;
                        65, 83, 68, 70,71, 72, 74,75, 76,58,52,53,54,45,208, ;
                       122, 88, 67, 86,66, 78, 77,79, 80,59,49,50,51,43,206, ;
                        00, 96,126,209,32, 92,124,44, 39,34,48,00,46,13,204  }
#else
#ifdef NUMERIC_KEY_FIX			
local key_fix_val_ := {  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, ;
                        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, ;
                        31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, ;
                        46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 86, 87, 88, 59, 60, ; 
                        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, ;
                        76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 56, 57, 58, 89, 90, ;
                        91, 92, 93, 94, 95, 96, 97, 98, 99,100,101,102,103,104,105  } 
#else
local key_fix_val_ := {  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, ;
                        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, ;
                        31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, ;
                        46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, ; 
                        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, ;
                        76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, ;
                        91, 92, 93, 94, 95, 96, 97, 98, 99,100,101,102,103,104,105  } 
#endif			

#endif                        

  
     asize (keymap_, CONFIG_KEY_LEN)
     afill (keymap_, "")  
     
     if !parse(CONFIG_KEY_FILE,CONFIG_KEY_LINES,keymap_)
        ?
        ? "Error Opening "
        ?? CONFIG_KEY_FILE
        ?
        quit
     endif
     
     for i:=1 to len(keymap_)
        nTemp := val(keymap_[i])
        if nTemp > 0 .and. nTemp <= CONFIG_KEY_LEN
          keymap_[i] := key_fix_val_[nTemp]
        else
          keymap_[i] := 0  
        endif

     next
     
return nil

function keymap(nVar)
return key_val

function getkeyval(nVar)
  key_val := ascan(keymap_, { |x| x == nVar} )
return key_val 

function putkeyval(nVar)
   key_val := nVar
return key_val

function lastinput()
return key_val

function clearkeys()
#ifdef DEF_SCANNER
local nBRead,cSBuffer
#endif

   key_val := 0
   while nextkey() != 0 
     inkey(0) 
   enddo
#ifdef DEF_SCANNER   
    while .T.
      nBread := 0 
      cSBuffer := "XXXXXXXXXXXXXXXXXXXX"
      if ( READ_SCAN( @nBRead, @cSBuffer, .T. ) != NORMAL )
         exit
      endif   
    enddo  
#endif        
   
return key_val

// determines if key pressed is a number...
//
function is_number(nVar)
local cRetVal := ""

  do case 
     case KEY_ZERO == key_val
       cRetVal := "0"
     case KEY_ONE == key_val
       cRetVal := "1"
     case KEY_TWO == key_val
       cRetVal := "2"
     case KEY_THREE == key_val
       cRetVal := "3"
     case KEY_FOUR == key_val
       cRetVal := "4"
     case KEY_FIVE == key_val
       cRetVal := "5"
     case KEY_SIX == key_val
       cRetVal := "6"
     case KEY_SEVEN == key_val
       cRetVal := "7"
     case KEY_EIGHT == key_val
       cRetVal := "8"
     case KEY_NINE== key_val
       cRetVal := "9"
     case KEY_PERIOD == key_val 
        cRetVal := "."
#ifndef SPECTRUM_586_MACHINE	      
     case KEY_TWOZ == key_val
        cRetVal := "00"
#endif	
#ifdef DEBUG
     otherwise
        ? "Not a number digit..."
#endif          
  endcase 
    
return cRetVal

// determines if key pressed is a department...
//
function is_dept(nVar)
local nRetVal := 0

 if key_val >= KEY_DEPT_1 .and. key_val <= KEY_DEPT_30
     nRetVal := key_val - KEY_DEPT_1 + 1
 elseif key_val == KEY_SUB_DEPT
     nRetVal := 100
#ifdef DEBUG     
 else 
    ? " Not a Dept key..."       
#endif 
 endif

return nRetVal

function is_alpha(nVar)
local cRetVal := ""

  if key_val >= KEY_A .and. key_val <= KEY_Z
     cRetVal := CHR(key_val - KEY_A + 1 + 64)     
  elseif key_val == KEY_SPACE
     cRetVal := " "
  elseif key_val == KEY_PERIOD
     cRetVal := "."   

#ifdef DEBUG
  else 
     ? " Not an Alpha key..."
#endif
  endif   

return cRetVal

function is_payment(nVar)
local nRetVal := -1  // default error
      if key_val == KEY_CASH
         nRetVal := 0
      elseif key_val == KEY_MISC
         nRetVal := 100
      elseif key_val >= KEY_MISC_1 .and. key_val <= KEY_MISC_20
         nRetVal := key_val - KEY_MISC_1 + 1
#ifdef OTHER_PAYMENTS	 	 
      elseif key_val == KEY_CHEQUE
         nRetVal := 50   
      elseif key_val == KEY_INHOUSE
         nRetVal := 200   
      elseif key_val == KEY_POCARD
         nRetVal := 250   
      elseif key_val == KEY_GIFTCHK
         nRetVal := 300   
#endif	    
#ifdef DEBUG         
      else
         ? " Not a Payment key ... "         
#endif         
      endif
      
return nRetVal

#ifdef ONESHOT_PLU
function isPLU(nVar)
local n
local nRetval := 0

  if key_val >= KEY_ONESHOT_01 .and. key_val <= KEY_ONESHOT_60
      nRetVal :=  key_val - KEY_ONESHOT_01  + 1
  endif 

return nRetVal
#endif
       
/* eof */
