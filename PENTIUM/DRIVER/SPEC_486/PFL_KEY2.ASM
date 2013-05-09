        PAGE    58, 132

; set title and memory model
        TITLE   PFL_KEY2.ASM - POS Keyboard interface routines.
        .MODEL  LARGE

; EQUATES -------------------------------------------------------------------

FIRST_KEY       EQU     1               ; 1st key position
LAST_KEY        EQU     105             ; last key position

; MACRO Definitions ---------------------------------------------------------

JUMP_DELAYS     MACRO

        JMP     SHORT $+2
        JMP     SHORT $+2
        JMP     SHORT $+2
        JMP     SHORT $+2        

                ENDM        

        .CODE

;----------------------------------------------------------------------------
;  Clear POS keyboard buffer.
;  
;  Syntax: 
;
;    void pfl_key_clear(void)
;
;  Parameters:
;  
;    None.
;
;  Returns:
;
;    Nothing.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_clear

; function definition
        
_pfl_key_clear  PROC    

PKC_1:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKC_EXIT                ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        JMP     SHORT PKC_1             ; repeat until no keystroke is available

PKC_EXIT:        
        RET
        
_pfl_key_clear  ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard ASCII code.
;  
;  Syntax: 
;
;    int pfl_key_geta(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the ASCII codes read
;
;    int len          - size of word_data (len > 0)
;
;  Returns:
;
;    Returns the number of ASCII codes read.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_geta

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_geta   PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             ; 
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKG_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKG_EXIT                ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        AND     AX, 00FFH               ; get only ASCII code
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKG_AGAIN

PKG_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_geta   ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard ASCII code. 
;  
;  Syntax: 
;
;    int pfl_key_wgeta(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the ASCII codes read
;
;    int len          - size of word_data (len > 1)
;
;  Returns:
;
;    Returns the number of ASCII codes read. 
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_wgeta

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_wgeta   PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             ; 
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKWA_1:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWA_1                  ; no available keystroke, so read again
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        AND     AX, 00FFH               ; get only ASCII code
        CMP     AX, LAST_KEY            ; validate key positions returned
        JA      PKWA_AGAIN
        CMP     AX, FIRST_KEY
        JB      PKWA_AGAIN    
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read
        DEC     CX                      ; decrement length
        
PKWA_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWA_EXIT               ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        AND     AX, 00FFH               ; get only ASCII code
        CMP     AX, LAST_KEY            ; validate key positions returned
        JA      PKWA_AGAIN
        CMP     AX, FIRST_KEY
        JB      PKWA_AGAIN            
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKWA_AGAIN

PKWA_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_wgeta   ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard scan code.
;  
;  Syntax: 
;
;    int pfl_key_gets(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the scan codes read
;
;    int len          - size of word_data (len > 0)
;
;  Returns:
;
;    Returns the number of scan codes read.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_gets

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_gets   PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKGS_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKGS_EXIT               ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        PUSH    CX
        MOV     CL, 8                   
        SHR     AX, CL                  ; get only scan code
        POP     CX
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKGS_AGAIN

PKGS_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_gets   ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard scan code.
;  
;  Syntax: 
;
;    int pfl_key_wgets(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the scan codes read
;
;    int len          - size of word_data (len > 1)
;
;  Returns:
;
;    Returns the number of scan codes read. This function reads at least 
;    1 scan code before returning.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_wgets

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_wgets   PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKWS_1:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWS_1                  ; no available keystroke, so read again
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        PUSH    CX
        MOV     CL, 8                   
        SHR     AX, CL                  ; get only scan code
        POP     CX
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read
        DEC     CX                      ; decrement length        
        
PKWS_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWS_EXIT               ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        PUSH    CX
        MOV     CL, 8                   
        SHR     AX, CL                  ; get only scan code
        POP     CX
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKWS_AGAIN

PKWS_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_wgets   ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard scan code and ASCII code
;  
;  Syntax: 
;
;    int pfl_key_getsa(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the scan codes and ASCII codes read
;
;    int len          - size of word_data (len > 0)
;
;  Returns:
;
;    Returns the number of scan codes and ASCII codes read.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_key_getsa

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_getsa  PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKGSA_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKGSA_EXIT              ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKGSA_AGAIN

PKGSA_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_getsa  ENDP

        PAGE
;----------------------------------------------------------------------------
;  Read POS keyboard scan code and ASCII code.
;  
;  Syntax: 
;
;    int pfl_key_wgetsa(int *word_data, int len)
;
;  Parameters:
;  
;    int *word_data   - buffer that holds the scan codes and ASCII codes read
;
;    int len          - size of word_data (len > 1)
;
;  Returns:
;
;    Returns the number of scan codes and ASCII codes read. This function 
;    reads at least 1 scan code and 1 ASCII code before returning.
;
;  rnr  5-17-95
;-----------------------------------------------------------------------------

        PUBLIC  _pfl_key_wgetsa

; set up parameter offsets from BP

        word_data = 6
        len       = 10

; function definition
        
_pfl_key_wgetsa  PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    DI                      ; save SI
        PUSH    ES                      ; save ES
        PUSHF                           ; save flags

        CLD
        MOV     DI, WORD PTR [BP]+word_data        ; offset of word_data
        MOV     AX, WORD PTR [BP]+word_data+2      ; segment of word_data
        MOV     ES, AX                             
        MOV     BX, 0                              ; no of keystrokes read
        MOV     CX, WORD PTR [BP]+len              ; get length of word_data

PKWSA_1:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWSA_1                 ; no available keystroke, so read again
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read
        DEC     CX                      ; decrement length
        
PKWSA_AGAIN:
        MOV     AH, 11H                 ; check keyboard status
        INT     16H
        JZ      PKWSA_EXIT              ; no available keystroke, so exit
        MOV     AH, 10H                 ; read keyboard character
        INT     16H
        STOSW                           ; copy from AX
        INC     BX                      ; increment no of keystrokes read

        LOOP    PKWSA_AGAIN

PKWSA_EXIT:        
        MOV     AX, BX                  ; return AX with the no of keystrokes read
         
; restore registers used
        POPF
        POP     ES
        POP     DI        
        POP     BP
                
        RET

_pfl_key_wgetsa  ENDP

        PAGE

;----------------------------------------------------------------------------
;  Read Keylock position directly.
;  
;  Syntax: 
;
;    int pfl_rid_klock(void)
;
;  Parameters:
;  
;    None.
;
;  Returns:
;
;    Returns -1 if an error occurs, otherwise it returns the keylock position
;    code.
;
;  rnr  10-15-95
;-----------------------------------------------------------------------------

        PUBLIC  _pfl_rid_klock

; function definition
        
_pfl_rid_klock  PROC    

; disable keyboard interrupt 

        CLI
        IN      AL, 21H                 ; read IMR
        OR      AL, 02H                 ; turn off Keyboard IRQ
        JUMP_DELAYS
        OUT     21H, AL
        STI
        

;        MOV     BL, 0F5H                ; disable keyboard input
;        CALL    SET_KBRD_CMD2

;        MOV     AX, -1                  ; assume error status
;        CMP     BX, 1                   ; if error ?
;        JE      PRK_EXIT                ; if yes, return with error status
                                        ; otherwise, continue

; verify if the motherboard keyboard controller's input buffer is empty

        MOV     CX, 0FFFFH              ; loop count

PRK_1:
        JUMP_DELAYS
        IN      AL, 64H                 ; read keyboard status
        TEST    AL, 02H
        JZ      PRK_2                   ; quit if input buffer is empty
        LOOP    PRK_1                   ; otherwise, loop while input buffer 
                                        ; is full

        MOV     AX, -1                  ; return with error status
        JMP     PRK_EXIT

PRK_2:                                  ; send command byte        
        MOV     AL, 0F9H
        OUT     60H, AL

; verify if the motherboard keyboard controller's output buffer is full

        MOV     CX, 0FFFFH

PRK_3:
        JUMP_DELAYS
        IN      AL, 64H                 ; read keyboard status
        TEST    AL, 01H
        JNZ     PRK_4                   ; quit if output buffer is full
        LOOP    PRK_3                   ; otherwise, loop while output buffer 
                                        ; is empty

        IN      AL, 60H                 ; timeout: disregard any data byte
        MOV     AX, -1                  ; return with error status
        JMP     SHORT PRK_EXIT        

PRK_4:
        IN      AL, 60H                 ; read data byte        
        CMP     AL, 0FAH                ; is it the acknowledgment byte ?
        JE      PRK_5                   ; if yes, read next data byte

        JUMP_DELAYS                     ; if no, ...
        IN      AL, 60H                 ; disregard any data byte
        MOV     AX, -1                  ; return with error status
        JMP     SHORT PRK_EXIT                
        
PRK_5:

; verify if the motherboard keyboard controller's output buffer is full

        MOV     CX, 0FFFFH              ; loop count

PRK_6:
        JUMP_DELAYS
        IN      AL, 64H                 ; read keyboard status
        TEST    AL, 01H
        JNZ     PRK_7                   ; quit if output buffer is full
        LOOP    PRK_6                   ; otherwise, loop while output buffer 
                                        ; is empty

        IN      AL, 60H                 ; timeout: disregard any data byte
        MOV     AX, -1                  ; return with error status
        JMP     SHORT PRK_EXIT        

PRK_7:
        IN      AL, 60H                 ; read data byte        
        XOR     AH, AH                  ; zero AH
                
PRK_EXIT:
        PUSH    AX                      ; save return code

;        MOV     BL, 0F4H                ; enable keyboard input
;        CALL    SET_KBRD_CMD2

; enable keyboard interrupt
        CLI
        IN      AL, 21H                 ; read IMR
        AND     AL, 0FDH                ; turn on Keyboard IRQ
        JUMP_DELAYS
        OUT     21H, AL
        STI

        POP     AX                      ; return error status/keylock code
        
        RET
        
_pfl_rid_klock  ENDP

;-----------------------------------------------------------------------------
; SET_KBRD_CMD
;
; Send a command in register BL to the keyboard controller (port 64h).
; 
; If the routine times out due to the input buffer remaining full, AX is
; non-zero.
;
; On entry: BL -> command byte
; 
; Returns: AX -> 0, successful
;             -> 1, failed
;
;          Destroys AX and CX registers.
;
; rnr  10-15-95
;-----------------------------------------------------------------------------
SET_KBRD_CMD     PROC    NEAR

        MOV     CX, 0FFFFH              ; loop count

CMD_WAIT:
        JUMP_DELAYS
        IN      AL, 64H                 ; get controller status
        TEST    AL, 2                   ; is input buffer full ?
        JZ      CMD_SEND                ; ready to accept command ?
        LOOP    CMD_WAIT                ; jump if not
                                        ; fall through, still busy

        JMP     SHORT CMD_ERROR

CMD_SEND:                               ; send command byte

        MOV     AL, BL
        OUT     64H, AL                 ; send command
        
        MOV     CX, 0FFFFH              ; loop count                

CMD_ACCEPT:
        JUMP_DELAYS
        IN      AL, 64H                 ; get controller status
        TEST    AL, 2                   ; is input buffer full
        JZ      CMD_OK                  ; jump if command accepted
        LOOP    CMD_ACCEPT              ; try again        
                                        ; fall through, still busy

CMD_ERROR:
        MOV     AX, 1                   ; return status - failed
        JMP     SHORT CMD_EXIT

CMD_OK:
        XOR     AX, AX                  ; return status - ok

CMD_EXIT:
        RET

SET_KBRD_CMD    ENDP

;-----------------------------------------------------------------------------
; SET_KBRD_CMD2
;
; Send a command in register BL to the keyboard controller (port 60h).
; 
; If the routine times out due to the input buffer remaining full, AX is
; non-zero.
;
; On entry: BL -> command byte
; 
; Returns: BX -> 0, successful
;             -> 1, failed
;
;          Destroys AX, BX and CX registers.
;
; rnr  10-15-95
;-----------------------------------------------------------------------------
SET_KBRD_CMD2   PROC    NEAR

        MOV     CX, 0FFFFH              ; loop count

KBRD_WRT_LOOP:
        JUMP_DELAYS
        IN      AL, 64H                 ; get keyboard status
        TEST    AL, 2                   ; is input buffer full ?
        JZ      KBRD_WRT_OK             ; ready to accept command ?
        LOOP    KBRD_WRT_LOOP           ; jump if not
                                        ; fall through, still busy


        MOV     BX, 1                   ; return status - failed 
        JMP     SHORT KBRD_WRT_EXIT

KBRD_WRT_OK:                            ; send command byte
        MOV     AL, BL
        OUT     60H, AL                 ; data to controller/keyboard

; verify if the motherboard keyboard controller's output buffer is full

        MOV     CX, 0FFFFH              ; loop count

SKC_1:
        JUMP_DELAYS
        IN      AL, 64H                 ; read keyboard status
        TEST    AL, 01H
        JNZ     SKC_2                   ; quit if output buffer is full
        LOOP    SKC_1                   ; otherwise, loop while output buffer 
                                        ; is empty

        IN      AL, 60H                 ; timeout: disregard any data byte
        MOV     BX, 1                   ; return with error status
        JMP     SHORT KBRD_WRT_EXIT

SKC_2:
        IN      AL, 60H                 ; read data byte        
        CMP     AL, 0FAH                ; is it the acknowledgment byte ?
        JE      SKC_3                   ; if yes, return normal status

        JUMP_DELAYS                     ; if no, ...
        IN      AL, 60H                 ; disregard any data byte
        MOV     BX, 1                   ; return with error status
        JMP     SHORT KBRD_WRT_EXIT                
        
SKC_3:
        XOR     BX, BX                  ; return status - ok
        
KBRD_WRT_EXIT:
        RET        
                
SET_KBRD_CMD2   ENDP

               END
               