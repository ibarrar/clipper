        PAGE    58, 132

; set title and memory model
        TITLE   COMITASM.ASM 
        .MODEL  LARGE

        .CODE

;----------------------------------------------------------------------------                
;  Flush all buffered data.
;  
;  Syntax: 
;
;    int asm_commit(int file_handle)
;
;  Parameters:
;
;    int file_handle    - file handle.
;    
;  Returns:
;
;    Returns zero (0) if successful. Otherwise, it returns the DOS error code.
;
;  rnr  5-29-95
;-----------------------------------------------------------------------------    

        PUBLIC  _asm_commit

; set up parameter offsets from BP

        file_handle   = 6                     
        
; function definition
        
_asm_commit     PROC

        PUSH    BP                           ; save BP
        MOV     BP, SP                       ; get current SP position
        PUSHF                                ; save flags

        MOV     BX, WORD PTR [BP]+file_handle; get file handle
        MOV     AH, 68H                      ; flush buffer function
        INT     21H

        JC      AC_EXIT                      ; return with error code at AX
        MOV     AX, 0                        ; normal return

AC_EXIT:        
        POPF                                 ; restore flags
        POP     BP                           ; restore BP
                
        RET

_asm_commit     ENDP
        
               END
               