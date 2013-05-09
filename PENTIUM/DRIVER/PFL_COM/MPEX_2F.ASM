        PAGE    58, 132

; set title and memory model
        TITLE   MPEX_2F.ASM - Multiplex (INT 2FH) C interface routines.
        .MODEL  SMALL

        .CODE

COMMENT |
*****************************************************************************

 MPEX_2F.ASM

 MPEX_2F.ASM provides C interface routines to access the multiplex interrupt 
 (INT 2FH) functions used by PFL_COM. The C routines enable posting and re-
 trieving of communication parameters to and from PFL_COM (see PFL_COM.ASM
 for details).

 rnr  5-2-95
****************************************************************************|

;----------------------------------------------------------------------------                
;  Verify PFL_COM installation state.
;  
;  Syntax: 
;
;    int check_pfl_com(void)
;
;  Parameters:
;
;    None.
;
;  Returns:
;
;    Returns 1 if PFL_COM is installed, otherwise it returns 0.
;
;  rnr  5-2-95
;-----------------------------------------------------------------------------    

        PUBLIC  _check_pfl_com

; function definition
        
_check_pfl_com  PROC 

; get PFL_COM installation state
        MOV     AX, 0DD00H
        INT     2FH

        CMP     AX, -1                  ; installed ?
        JE      PFL_COM_OKAY
        MOV     AX, 0                   ; not installed
        JMP     CPC_EXIT        

PFL_COM_OKAY:                           ; PFL_COM already installed
        MOV     AX, 1

CPC_EXIT:
        RET        
        
_check_pfl_com  ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Read serial port device ID.
;  
;  Syntax: 
;
;    void read_dev_id(int *com1_id, int *com2_id, int *com3_id, int *com4_id)
;
;  Parameters:
;
;    int *com1_id    - device ID connected to COM1
;    
;    int *com2_id    - device ID connected to COM2
;
;    int *com3_id    - device ID connected to COM3
;
;    int *com4_id    - device ID connected to COM4
;
;    On return from this function, these parameters will contain the device
;    ID assigned to the corresponding serial port. A value of -1 indicates
;    that the corresponding serial port is unassigned.
;
;  Returns:
;
;    Nothing.
;
;  rnr  5-2-95
;-----------------------------------------------------------------------------    

        PUBLIC  _read_dev_id

; set up parameter offsets from BP

        com1_id = 4
        com2_id = 6
        com3_id = 8
        com4_id = 10
        
; function definition
        
_read_dev_id    PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

; read serial port device ID
        MOV     AX, 0DD01H
        INT     2FH

        PUSH    BX                          ; save BX
        MOV     BX, WORD PTR [BP]+com1_id   ; get offset of com1_id arg
        MOV     [BX], AX                    ; store COM1 ID at this offset
        POP     BX                          ; restore BX
        MOV     AX, BX                      ; copy BX to AX
        MOV     BX, WORD PTR [BP]+com2_id   ; get offset of com2_id arg
        MOV     [BX], AX                    ; store COM2 ID at this offset
        MOV     BX, WORD PTR [BP]+com3_id   ; get offset of com3_id arg
        MOV     [BX], CX                    ; store COM3 ID at this offset
        MOV     BX, WORD PTR [BP]+com4_id   ; get offset of com4_id arg
        MOV     [BX], DX                    ; store COM4 ID at this offset

        POP     BP                      ; restore BP
        
        RET

_read_dev_id    ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Read serial port communication parameters.
;  
;  Syntax: 
;
;    void read_com_parm(int port, int *dev_id, int *setup, int *protocol)
;
;  Parameters:
;
;    int port        - serial port (0 - COM1, 1 - COM2, etc.)
;    
;    int *dev_id     - device ID connected to this port on return
;
;    int *setup      - serial port communication settings on return
;
;    int *protocol   - handshaking protocol on return 
;
;  Returns:
;
;    Nothing.
;
;  rnr  5-2-95
;-----------------------------------------------------------------------------    

        PUBLIC  _read_com_parm

; set up parameter offsets from BP

        port     = 4
        dev_id   = 6
        setup    = 8
        protocol = 10
        
; function definition
        
_read_com_parm  PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

; read serial port communication parameters
        MOV     CH, BYTE PTR [BP]+port      ; get designated serial port
        MOV     AX, 0DD02H
        INT     2FH

        MOV     AX, BX                      ; copy BX to AX
        MOV     BX, WORD PTR [BP]+dev_id    ; get offset of dev_id arg
        MOV     [BX], AX                    ; store device ID at this offset
        MOV     BX, WORD PTR [BP]+setup     ; get offset of setup arg
        MOV     [BX], DX                    ; store communication settings at this offset
        MOV     BX, WORD PTR [BP]+protocol  ; get offset of protocol arg
        XOR     CH, CH                      ; zero CH
        MOV     [BX], CX                    ; store handshaking protocol at
                                            ; this offset

        POP     BP                      ; restore BP
        
        RET

_read_com_parm  ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Store serial port communication parameters.
;  
;  Syntax: 
;
;    void store_com_parm(int port, int dev_id, int setup, int protocol)
;
;  Parameters:
;
;    int port       - serial port (0 - COM1, 1 - COM2, etc.)
;    
;    int dev_id     - device ID
;
;    int setup      - serial port communication settings
;
;    int protocol   - handshaking protocol
;
;  Returns:
;
;    Nothing.
;
;  rnr  5-2-95
;-----------------------------------------------------------------------------    

        PUBLIC  _store_com_parm

; set up parameter offsets from BP

        port     = 4
        dev_id   = 6
        setup    = 8
        protocol = 10
        
; function definition
        
_store_com_parm PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

; store serial port communication parameters
        MOV     CH, BYTE PTR [BP]+port      ; get serial port
        MOV     BX, WORD PTR [BP]+dev_id    ; get device ID
        MOV     DX, WORD PTR [BP]+setup     ; get serial port communication settings
        MOV     CL, BYTE PTR [BP]+protocol  ; get handshaking protocol
        MOV     AX, 0DD03H
        INT     2FH

        POP     BP                      ; restore BP
        
        RET

_store_com_parm ENDP

               END

      