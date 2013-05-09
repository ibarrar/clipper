        PAGE    58, 132

; set title and memory model
        TITLE   KLCK_FIX.ASM - Multiplex (INT 2FH) C interface routines for PFL_KLCK.
        .MODEL  LARGE

        .CODE

COMMENT |
*****************************************************************************

 KLCK_FIX.ASM

 KLCK_FIX.ASM provides C interface routines to access the multiplex interrupt 
 (INT 2FH) functions used by PFL_KLCK. 

 rnr  6-26-95
****************************************************************************|

;----------------------------------------------------------------------------                
;  Verify PFL_KLCK installation state.
;  
;  Syntax: 
;
;    int check_pfl_klck(void)
;
;  Parameters:
;
;    None.
;
;  Returns:
;
;    Returns 1 if PFL_KLCK is installed, otherwise it returns 0.
;
;  rnr  6-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _check_pfl_klck

; function definition
        
_check_pfl_klck PROC 

; get PFL_KLCK installation state
        MOV     AX, 0DE00H
        INT     2FH

        CMP     AX, -1                  ; installed ?
        JE      PFL_KLCK_OKAY
        MOV     AX, 0                   ; not installed
        JMP     CPK_EXIT        

PFL_KLCK_OKAY:                          ; PFL_KLCK already installed
        MOV     AX, 1

CPK_EXIT:
        RET        
        
_check_pfl_klck ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Restore the keyboard intercept handler before KEYMAP.EXE was installed.
;
;  Syntax: 
;
;    void klck_fix_on(void)
;
;  Parameters:
;
;    None.
;
;  Returns:
;
;    Nothing.
;
;  rnr  6-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _klck_fix_on

; function definition
        
_klck_fix_on    PROC    

        MOV     AX, 0DE01H
        INT     2FH

        RET

_klck_fix_on    ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Restore the current keyboard intercept handler.
;  
;  Syntax: 
;
;    void klck_fix_off(void)
;
;  Parameters:
;
;    None
;    
;  Returns:
;
;    Nothing.
;
;  rnr  6-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _klck_fix_off

; function definition
        
_klck_fix_off   PROC    

        MOV     AX, 0DE02H
        INT     2FH
        
        RET

_klck_fix_off   ENDP

;----------------------------------------------------------------------------                
;  Stuff a keyboard dummy data.
;  
;  Syntax: 
;
;    void klck_stuff(void)
;
;  Parameters:
;
;    None
;    
;  Returns:
;
;    Nothing.
;
;  rnr  7-25-95
;-----------------------------------------------------------------------------    

        PUBLIC  _klck_stuff

; function definition
        
_klck_stuff     PROC    

        MOV     AH, 5H
        MOV     CH, 0                   ; scan code
        MOV     CL, 20H                 ; ASCII code (space character)
        INT     16H
        
        RET

_klck_stuff     ENDP

               END
      