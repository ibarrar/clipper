        PAGE    58, 132

; set title and memory model
        TITLE   PFL_LPT.ASM - PFL Parallel port interface routines.
        .MODEL  LARGE

        .CODE

;----------------------------------------------------------------------------                
;  Initialize the parallel port specified.
;  
;  Syntax: 
;
;    int pfl_lpt_init(int port_no)
;
;  Parameters:
;
;    int port_no  - parallel port no.
;    
;  Returns:
;
;    Returns an int describing the status of the parallel printer port.
;
;  rnr  5-9-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_lpt_init

; set up parameter offsets from BP

        port_no   = 6                     
        
; function definition
        
_pfl_lpt_init    PROC 

        PUSH    BP                           ; save BP
        MOV     BP, SP                       ; get current SP position

        MOV     DX, WORD PTR [BP]+port_no    ; get port no
        MOV     AH, 01H                      ; init port function
        INT     17H

        MOV     AL, AH                       ; return status in AX
        XOR     AH, AH                       ; zero AH

        POP     BP                           ; restore BP
                
        RET

_pfl_lpt_init   ENDP

        PAGE
;-----------------------------------------------------------------------------     
;  Send one byte to the specified parallel port. 
;  
;  Syntax: 
;
;    int pfl_lpt_send(int port_no, unsigned char byte_data)
;
;  Parameters:
;
;    int port_no              - parallel port no.
;
;    unsigned char byte_data  - data byte to be sent.
;    
;  Returns:
;
;    Returns an int describing the status of the parallel printer port.
;
;  rnr  5-9-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_lpt_send

; set up parameter offsets from BP

        port_no     = 6
        byte_data   = 8                     
        
; function definition
        
_pfl_lpt_send   PROC    

        PUSH    BP                           ; save BP
        MOV     BP, SP                       ; get current SP position

        MOV     DX, WORD PTR [BP]+port_no    ; get port no
        MOV     AL, BYTE PTR [BP]+byte_data  ; get byte_data
        MOV     AH, 00H                      ; send char function
        INT     17H

        MOV     AL, AH                       ; return status in AX
        XOR     AH, AH                       ; zero AH        

        POP     BP                           ; restore BP
        
        RET

_pfl_lpt_send   ENDP

        PAGE
;----------------------------------------------------------------------------
;  Send a number of bytes to the specified parallel port.
;  
;  Syntax: 
;
;    int pfl_lpt_nsend(int port, unsigned char *byte_data, int len)
;
;  Parameters:
;  
;    int port_no                - serial port no.
;
;    unsigned char *byte_data   - data byte(s) to be sent.
;
;    int len                    - length of byte_data
;
;  Returns:
;
;    Returns an int describing the status of the parallel printer port.
;    The status returned is the status of the last character sent.
;
;  rnr  5-9-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_lpt_nsend

; set up parameter offsets from BP

        port_no         = 6
        nsend_byte_data = 8             ; index 8 points to the offet, while index 10 points to the segment
        nsend_len       = 12

; function definition
        
_pfl_lpt_nsend  PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    SI                      ; save SI
        PUSH    DS                      ; save DS
        PUSHF                           ; save flags

        MOV     DX, WORD PTR [BP]+port_no                ; get lpt port 
        
        CLD
        MOV     SI, WORD PTR [BP]+nsend_byte_data        ; offset of byte_data
        MOV     AX, WORD PTR [BP]+nsend_byte_data+2      ; segment of byte_data
        MOV     DS, AX
        MOV     CX, WORD PTR [BP]+nsend_len              ; get length of byte_data

PLN_AGAIN:
        LODSB                       ; copy byte to AL
        MOV     AH, 00H             ; send char function
        INT     17H        

        LOOP    PLN_AGAIN
        
; restore registers used
        POPF
        POP     DS
        POP     SI        
        POP     BP
                
        RET

_pfl_lpt_nsend  ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Request parallel printer port status.
;  
;  Syntax: 
;
;    int pfl_lpt_sts(int port_no)
;
;  Parameters:
;
;    int port_no         - parallel port no.
;    
;  Returns:
;
;    Returns an int describing the status of the parallel printer port.
;
;  rnr  5-9-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_lpt_sts

; set up parameter offsets from BP

        port_no   = 6                     
        
; function definition
        
_pfl_lpt_sts     PROC    

        PUSH    BP                               ; save BP
        MOV     BP, SP                           ; get current SP position
        
        MOV     DX, WORD PTR [BP]+port_no        ; set DX to the port no
        MOV     AH, 02H                          ; printer status function
        INT     17H

        MOV     AL, AH                           ; return status in AX
        XOR     AH, AH                           ; zero AH                

        POP     BP                               ; restore BP
        
        RET
        
_pfl_lpt_sts     ENDP
        
               END
               