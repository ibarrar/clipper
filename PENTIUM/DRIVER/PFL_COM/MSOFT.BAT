:------------------------------------------------------------------------:
: MSOFT.BAT  [/c, /l, /cl] filename                                      :
:                                                                        :
: Input Parameters:                                                      :
:                                                                        :
:    /c   - assemble only (%1)                                           :
:    /l   - link only (%1)                                               :
:    /cl  - assemble and link (%1)                                       :
:    %2   - filename                                                     :
:                                                                        :
: rnr                                                                    :
:------------------------------------------------------------------------:


  @ECHO OFF
  CLS

: validate parameters passed

  IF "%1" == "/c"  GOTO FIND_ASM
  IF "%1" == "/l"  GOTO FIND_OBJ
  IF "%1" == "/cl" GOTO FIND_ASM
  IF "%1" == ""    GOTO USAGE

  ECHO *** Error: Invalid parameter %1...

:USAGE

  ECHO.
  ECHO Usage: MSOFT [/c, /l, /cl] filename 
  ECHO.
  ECHO        /c  - assemble only
  ECHO        /l  - link only
  ECHO        /cl - assemble and link
  ECHO.

  GOTO END

:FIND_ASM

  IF EXIST %2.asm GOTO COMPILE
  ECHO *** Error: File %2.asm does not exist... 
  GOTO END

: assemble *.asm; create a listing and a cross-reference info
:COMPILE

  ECHO Assembling...
  C:\MASM\BIN\MASM %2, %2, %2, %2 > err

  type err  
  IF ERRORLEVEL 1 GOTO END
  IF "%1" == "/cl" GOTO FIND_OBJ
  GOTO END

:FIND_OBJ

  IF EXIST %2.obj GOTO LINK
  ECHO *** Error: File %2.obj does not exist... 
  GOTO END 

: link *.obj; create a map file
:LINK

  ECHO Linking...
  LINK %2, %2, %2;
  
:END  
