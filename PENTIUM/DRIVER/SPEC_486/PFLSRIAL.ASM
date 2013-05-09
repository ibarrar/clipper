PAGE    58, 132

; set title and memory model
        TITLE   PFLSRIAL.ASM - PFL Serial port interface routines.
        .MODEL  LARGE

; Equates -------------------------------------------------------------------

XMIT_WAIT       EQU     9              ; 1/2 second (approximate)
RECV_WAIT       EQU     5              ; approximately 1/4th of a second

        .CODE

COMMENT |
*****************************************************************************

 Note: For a better understanding of these codes, I assume you have a basic 
 knowledge of asynchronous serial communications. 

 rnr  4-24-95  Verifying the line status is redundant in the transmit functions.
****************************************************************************|

;----------------------------------------------------------------------------                
;  Initialize serial port.
;  
;  Syntax: 
;
;    int pfl_com_init(int port_no, int setup, unsigned char protocol)
;
;  Parameters:
;
;    int port_no            - serial port no.
;    
;    int setup              - serial port communication settings.
; 
;    unsigned char protocol - 0 for None
;                             1 for DTR/RTS                               
;
;  Returns:
;
;    Returns an int describing the line status (high-order byte) and the modem 
;    status (low-order byte).
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_init

; set up parameter offsets from BP

        port_no   = 6                     
        setup     = 8
        protocol  = 10
        
; function definition
        
_pfl_com_init    PROC 

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     BX, WORD PTR [BP]+port_no    ; get port no
        CALL    SET_PORT                     
                              
        MOV     DX, WORD PTR [BP]+port_no    ; set DX to the serial port no
        MOV     AX, WORD PTR [BP]+setup      ; set AL for the communication parameters

        MOV     AH, 0                        ; initialize port
        INT     14H                     

        CLI
        MOV     DX, CS:com_addrs             ; get base address
        
        TEST    WORD PTR [BP]+setup, 0100H   ; baud rate is 19200 (see pflsrial.h) ?
        JNZ     BR_19200
        TEST    WORD PTR [BP]+setup, 0200H   ; baud rate is 38400 (see pflsrial.h) ?
        JNZ     BR_38400        
        JMP     SHORT SET_PROTOCOL           ; otherwise set protocol 

BR_19200:
        MOV     CX, 0006H                    ; baud rate divisor for 19200 bps
        JMP     SHORT SET_BPS
BR_38400:
        MOV     CX, 0003H                    ; baud rate divisor for 38400 bps

SET_BPS:
        CALL    SET_BAUD_RATE
        
; set protocol at chip level
SET_PROTOCOL:           
        ADD     DX, 4                      ; point to modem control register 
        IN      AL, DX                     ; read current values
        XOR     BH, BH                     ; zero BH
        MOV     BL, BYTE PTR [BP]+protocol ; save a copy of the protocol value 
        CMP     BL, 0                      ; no protocol ?
        JNE     SET_DTR_RTS 
        AND     AL, CS:pcol_masks[BX]      ; clear DTR/RTS bits
        OUT     DX, AL                     ; output byte
        JMP     SHORT END_IF_ELSE1

SET_DTR_RTS:        
        OR      AL, CS:pcol_masks[BX]      ; set DTR/RTS bits
        OUT     DX, AL                     ; output byte

END_IF_ELSE1:
        STI

; request port status
        MOV     DX, WORD PTR [BP]+port_no  ; set DX to the serial port no

        MOV     AH, 03H                    ; get serial port status
        INT     14H                        ; note: status is returned in AX

        POP     BP                         ; restore BP
                
        RET

; variables to be used stored here
com_addrs       DW      3F8H            ; serial port base address (default to COM1)
pcol_masks      DB      11111100B, 00000011B, 00000001B, 00000010B  ; protocol masks

_pfl_com_init   ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Set explicitly the serial port to be used by the following functions:
;
;    a. pfl_com_send()
;    b. pfl_com_nsend()
;    c. pfl_com_drecv()
;  
;  Syntax: 
;
;    int pfl_com_port(int port_no)
;
;  Parameters:
;
;    int port_no  - serial port no.
;    
;  Returns:
;
;    Returns -1 for an invalid serial port, otherwise it returns 0.
;
;  Note: 
;
;  If pfl_com_init() is called prior to the functions mentioned above, the
;  default serial port to be used is the 'port' argument used in pfl_com_init().
;
;  rnr  5-4-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_port

; set up parameter offsets from BP

        port_no   = 6                     

; function definition

_pfl_com_port   PROC 

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        PUSH    DS                      ; save DS

; setup DS register
        MOV     AX, @CODE               ; DS --> CS
        MOV     DS, AX
        ASSUME  DS: @CODE
        
        MOV     BX, WORD PTR [BP]+port_no       ; get port_no

; validate port no passed
        CMP     BX, 0
        JL      PORT_INVALID
        CMP     BX, 3
        JG      PORT_INVALID

; determine serial port base address
        MOV     CL, 1
        SHL     BX, CL                  ; multiply by 2
        MOV     AX, port_addrs[BX]
        MOV     com_addrs, AX

        MOV     AX, 0                   ; normal return
        JMP     SHORT PCP_EXIT

PORT_INVALID:
        MOV     AX, -1                  ; return with error

PCP_EXIT:
        POP     DS                      ; restore DS
        POP     BP                      ; restore BP

        RET          

; store variables here
port_addrs      DW      3F8H, 2F8H, 3E8H, 2E8H              

_pfl_com_port   ENDP        
        
        PAGE
;----------------------------------------------------------------------------                
;  Send one byte to the serial port. Port is specified using pfl_com_port() or
;  uses the previous 'port_no' or 'base_addrs' argument.
;  
;  Syntax: 
;
;    int pfl_com_send(unsigned char byte_data)
;
;  Parameters:
;
;    unsigned char byte_data  - data byte to be sent.
;    
;  Returns:
;
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_send

; set up parameter offsets from BP

        byte_data   = 6                     
        
; function definition
        
_pfl_com_send    PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCS_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCS_2                   ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCS_1                   ; time not up, wait in loop
        JMP     SHORT MAY_ERROR         ; time up, exit with error          

PCS_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        MOV     AL, BYTE PTR [BP]+byte_data
        OUT     DX, AL                  ; output byte       

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     MAY_ERROR               ; framing, parity, overrun) error ?

        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCS_EXIT
        
MAY_ERROR:
         MOV     AX, -1                  ; return with error

PCS_EXIT:        
        POP     BP                      ; restore BP
        
        RET

; store variables here
xmitcount       DW      ?               ; old clock ticks (lower word)
        
_pfl_com_send    ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Send one byte to the specified serial port.
;  
;  Syntax: 
;
;    int pfl_com_sendp(int port, unsigned char byte_data)
;
;  Parameters:
;
;    int port_no              - serial port no.
;
;    unsigned char byte_data  - data byte to be sent.
;    
;  Returns:
;
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_sendp

; set up parameter offsets from BP

        port_no     = 6
        byte_data   = 8                     
        
; function definition
        
_pfl_com_sendp  PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     BX, WORD PTR [BP]+port_no  ; get port no
        CALL    SET_PORT
        
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCSP_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCSP_2                  ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCSP_1                  ; time not up, wait in loop
        JMP     SHORT PCSP_ERROR        ; time up, exit with error          

PCSP_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        MOV     AL, BYTE PTR [BP]+byte_data
        OUT     DX, AL                  ; output byte       

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCSP_ERROR              ; framing, parity, overrun) error ?

        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCSP_EXIT
        
PCSP_ERROR:
         MOV     AX, -1                  ; return with error

PCSP_EXIT:        
        POP     BP                      ; restore BP
        
        RET

_pfl_com_sendp  ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Send one byte to the specified serial port base address.
;  
;  Syntax: 
;
;    int pfl_com_sendb(int base_addrs, unsigned char byte_data)
;
;  Parameters:
;
;    int base_addrs           - serial port base address
;
;    unsigned char byte_data  - data byte to be sent.
;    
;  Returns:
;
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_sendb

; set up parameter offsets from BP

        base_addrs  = 6
        byte_data   = 8                     
        
; function definition
        
_pfl_com_sendb  PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs  ; get base address
        MOV     CS:com_addrs, AX
        
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCSB_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCSB_2                  ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCSB_1                  ; time not up, wait in loop
        JMP     SHORT PCSB_ERROR        ; time up, exit with error          

PCSB_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        MOV     AL, BYTE PTR [BP]+byte_data
        OUT     DX, AL                  ; output byte       

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCSB_ERROR              ; framing, parity, overrun) error ?

        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCSB_EXIT
        
PCSB_ERROR:
         MOV     AX, -1                  ; return with error

PCSB_EXIT:        
        POP     BP                      ; restore BP
        
        RET

_pfl_com_sendb  ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Send a number of bytes to the serial port. Port is specified using 
;  pfl_com_port() or uses the previous 'port_no' or 'base_addrs' argument.
;  
;  Syntax: 
;
;    int pfl_com_nsend(unsigned char *byte_data, int len)
;
;  Parameters:
;
;    unsigned char *byte_data  - data byte(s) to be sent.
;
;    int len                   - length of byte_data
;
;  Returns:
;
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_nsend

; set up parameter offsets from BP

        nsend_byte_data = 6             ; index 6 points to the offet, while index 8 points to the segment
        nsend_len       = 10

; function definition
        
_pfl_com_nsend    PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    SI                      ; save SI
        PUSH    DS                      ; save DS
        PUSHF                           ; save flags

        CLD
        MOV     SI, WORD PTR [BP]+nsend_byte_data        ; offset of byte_data
        MOV     AX, WORD PTR [BP]+nsend_byte_data+2      ; segment of byte_data
        MOV     DS, AX
        MOV     CX, WORD PTR [BP]+nsend_len              ; get length of byte_data

PCN_AGAIN:        

        PUSH    CX                      ; save CX, since GET_CLOCK_COUNT modifies it 
                
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCN_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCN_2                   ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCN_1                   ; time not up, wait in loop
        JMP     SHORT MAY_ERROR3        ; time up, exit with error          

PCN_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        LODSB                           ; load byte to AL
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2
        OUT     DX, AL                  ; output byte       
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2
        
; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     MAY_ERROR3              ; framing, parity, overrun) error ?

        POP     CX                      ; restore CX
        
        LOOP    PCN_AGAIN               ; otherwise, continue
        
        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCN_EXIT        
        
MAY_ERROR3:
        POP     CX                     
        MOV     AX, -1                  ; return with error

PCN_EXIT:        

; restore registers used
        POPF
        POP     DS
        POP     SI
        POP     BP
                
        RET

_pfl_com_nsend    ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Send a number of bytes to the specified serial port.
;  
;  Syntax: 
;
;    int pfl_com_nsendp(int port, unsigned char *byte_data, int len)
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
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_nsendp

; set up parameter offsets from BP

        port_no         = 6
        nsend_byte_data = 8             ; index 8 points to the offet, while index 10 points to the segment
        nsend_len       = 12

; function definition
        
_pfl_com_nsendp PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    SI                      ; save SI
        PUSH    DS                      ; save DS
        PUSHF                           ; save flags

        MOV     BX, WORD PTR [BP]+port_no                ; get port no
        CALL    SET_PORT

        CLD
        MOV     SI, WORD PTR [BP]+nsend_byte_data        ; offset of byte_data
        MOV     AX, WORD PTR [BP]+nsend_byte_data+2      ; segment of byte_data
        MOV     DS, AX
        MOV     CX, WORD PTR [BP]+nsend_len              ; get length of byte_data

PCNP_AGAIN:        

        PUSH    CX                      ; save CX, since GET_CLOCK_COUNT modifies it 
                
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCNP_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCNP_2                  ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCNP_1                  ; time not up, wait in loop
        JMP     SHORT PCNP_ERROR        ; time up, exit with error          

PCNP_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        LODSB                           ; load byte to AL
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2        
        OUT     DX, AL                  ; output byte       
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2        

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCNP_ERROR              ; framing, parity, overrun) error ?

        POP     CX                      ; restore CX
        
        LOOP    PCNP_AGAIN              ; otherwise, continue
        
        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCNP_EXIT        
        
PCNP_ERROR:
        POP     CX                     
        MOV     AX, -1                  ; return with error

PCNP_EXIT:        

; restore registers used
        POPF
        POP     DS
        POP     SI
        POP     BP
                
        RET

_pfl_com_nsendp ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Send a number of bytes to the specified serial port base address.
;  
;  Syntax: 
;
;    int pfl_com_nsendb(int base_addrs, unsigned char *byte_data, int len)
;
;  Parameters:
;  
;    int base_addrs             - serial port base address
;
;    unsigned char *byte_data   - data byte(s) to be sent.
;
;    int len                    - length of byte_data
;
;  Returns:
;
;    Returns -1 if an error occurred, otherwise it returns 0.
;
;  Note: 
;
;    The errors detected by this function is limited or generalized, since
;    the error status of a port varies from different serial devices connected.
;    Therefore, a return value of 0 does not actually mean successful trans-
;    mission. To verify or determine other errors use pfl_com_sts() or
;    pfl_com_dsts().
;
;  rnr  4-26-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_nsendb

; set up parameter offsets from BP

        base_addrs      = 6
        nsend_byte_data = 8             ; index 8 points to the offet, while index 10 points to the segment
        nsend_len       = 12

; function definition
        
_pfl_com_nsendb PROC

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        PUSH    SI                      ; save SI
        PUSH    DS                      ; save DS
        PUSHF                           ; save flags

        MOV     AX, WORD PTR [BP]+base_addrs             ; get port base address
        MOV     CS:com_addrs, AX

        CLD
        MOV     SI, WORD PTR [BP]+nsend_byte_data        ; offset of byte_data
        MOV     AX, WORD PTR [BP]+nsend_byte_data+2      ; segment of byte_data
        MOV     DS, AX
        MOV     CX, WORD PTR [BP]+nsend_len              ; get length of byte_data

PCNB_AGAIN:        

        PUSH    CX                      ; save CX, since GET_CLOCK_COUNT modifies it 
                
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:xmitcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCNB_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 20H                 ; transmit holding register empty ?
        JNZ     PCNB_2                  ; yes, so continue
        MOV     BX, CS:xmitcount
        MOV     AX, XMIT_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCNB_1                  ; time not up, wait in loop
        JMP     SHORT PCNB_ERROR        ; time up, exit with error          

PCNB_2:
        MOV     DX, CS:com_addrs        ; point to transmit holding register
        LODSB                           ; load byte to AL
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2                                  
        OUT     DX, AL                  ; output byte       
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2        

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCNB_ERROR              ; framing, parity, overrun) error ?

        POP     CX                      ; restore CX
        
        LOOP    PCNB_AGAIN              ; otherwise, continue
        
        MOV     AX, 0                   ; return without error        
        JMP     SHORT PCNB_EXIT        
        
PCNB_ERROR:
        POP     CX                     
        MOV     AX, -1                  ; return with error

PCNB_EXIT:        

; restore registers used
        POPF
        POP     DS
        POP     SI
        POP     BP
                
        RET

_pfl_com_nsendb ENDP

        PAGE
;----------------------------------------------------------------------------   
;  Fetch byte-data from the serial port. Reading is done at chip level
;  (direct i/o). Port is specified using pfl_com_port() or uses the previous
;  'port_no' or 'base_addrs' argument.
;
;  Syntax: 
;
;    int pfl_com_drecv(void)
;
;  Parameters:
;
;    None.
;   
;  Returns:
;
;    If the high-order byte is 0, it returns the data byte received in the
;    low-order byte. Otherwise, it returns -1 if no data byte was retrieved
;    from the port requested.
;
;  Note: 
;
;    Pfl_com_sts() or pfl_com_dsts() can be used to determine the status of 
;    the port, if a -1 is returned by this function.
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_drecv

; function definition
        
_pfl_com_drecv   PROC    

        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:recvcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCD_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 01H                 ; data available ?
        JNZ     PCD_2                   ; yes, so continue
        MOV     BX, CS:recvcount
        MOV     AX, RECV_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCD_1                   ; time not up, wait in loop
        JMP     SHORT MAY_ERROR2        ; time up, exit with error          

PCD_2:
        MOV     DX, CS:com_addrs        ; point to receiver data register
        IN      AL, DX                  ; get data byte
        MOV     CS:port_data, AL

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     MAY_ERROR2              ; framing, parity, overrun) error ?

        MOV     AH, 0                   ; return without error        
        MOV     AL, CS:port_data        ; low-order byte contains the data 
        JMP     SHORT PCD_EXIT
        
MAY_ERROR2:
        MOV     AX, -1                  ; return with error

PCD_EXIT:        
        RET

; store variables here
recvcount       DW      ?                ; old clock ticks (lower word)
port_data       DB      ?                ; holds the data byte
        
_pfl_com_drecv   ENDP

        PAGE
;----------------------------------------------------------------------------   
;  Fetch byte-data from the specified serial port. Reading is done at chip 
;  level (direct i/o).
;
;  Syntax: 
;
;    int pfl_com_drecvp(int port_no)
;
;  Parameters:
;
;    int port_no    - serial port no.
;
;  Returns:
;
;    If the high-order byte is 0, it returns the data byte received in the
;    low-order byte. Otherwise, it returns -1 if no data byte was retrieved
;    from the port requested.
;
;  Note: 
;
;    Pfl_com_sts() or pfl_com_dsts() can be used to determine the status of 
;    the port, if a -1 is returned by this function.
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_drecvp

; set up parameter offsets from BP

        port_no   = 6
        
; function definition
        
_pfl_com_drecvp PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     BX, WORD PTR [BP]+port_no    ; get port no
        CALL    SET_PORT                     
                
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:recvcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCDP_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 01H                 ; data available ?
        JNZ     PCDP_2                  ; yes, so continue
        MOV     BX, CS:recvcount
        MOV     AX, RECV_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCDP_1                  ; time not up, wait in loop
        JMP     SHORT PCDP_ERROR        ; time up, exit with error          

PCDP_2:
        MOV     DX, CS:com_addrs        ; point to receiver data register
        IN      AL, DX                  ; get data byte
        MOV     CS:port_data, AL

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCDP_ERROR              ; framing, parity, overrun) error ?

        MOV     AH, 0                   ; return without error        
        MOV     AL, CS:port_data        ; low-order byte contains the data 
        JMP     SHORT PCDP_EXIT
        
PCDP_ERROR:
        MOV     AX, -1                  ; return with error

PCDP_EXIT:        
        POP     BP                      ; restore BP
        
        RET

_pfl_com_drecvp ENDP

        PAGE
;----------------------------------------------------------------------------
;  Fetch byte-data from the specified serial port base address. Reading is 
;  done at chip level (direct i/o).
;
;  Syntax: 
;
;    int pfl_com_drecvb(int base_addrs)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;
;  Returns:
;
;    If the high-order byte is 0, it returns the data byte received in the
;    low-order byte. Otherwise, it returns -1 if no data byte was retrieved
;    from the port requested.
;
;  Note: 
;
;    Pfl_com_sts() or pfl_com_dsts() can be used to determine the 
;    status of the port, if a -1 is returned by this function.
;
;  rnr  4-24-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_drecvb

; set up parameter offsets from BP

        base_addrs   = 6
        
; function definition
        
_pfl_com_drecvb PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX
                
        CALL    GET_CLOCK_COUNT         ; get clock ticks
        MOV     CS:recvcount, DX        ; store lower word of clock ticks for 
                                        ; later use
PCDB_1:
        MOV     DX, CS:com_addrs
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
        TEST    AL, 01H                 ; data available ?
        JNZ     PCDB_2                  ; yes, so continue
        MOV     BX, CS:recvcount
        MOV     AX, RECV_WAIT           ; wait by no. of clock ticks
        CALL    CHECKTIME               ; go see if time expired
        JNC     PCDB_1                  ; time not up, wait in loop
        JMP     SHORT PCDB_ERROR        ; time up, exit with error          

PCDB_2:
        MOV     DX, CS:com_addrs        ; point to receiver data register
        IN      AL, DX                  ; get data byte
        MOV     CS:port_data, AL

; verify line status

        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; get status byte
                
; check for errors

        TEST    AL, 10011110B           ; line status (time-out, break-detect,
        JNZ     PCDB_ERROR              ; framing, parity, overrun) error ?

        MOV     AH, 0                   ; return without error        
        MOV     AL, CS:port_data        ; low-order byte contains the data 
        JMP     SHORT PCDB_EXIT
        
PCDB_ERROR:
        MOV     AX, -1                  ; return with error

PCDB_EXIT:        
        POP     BP                      ; restore BP
        
        RET

_pfl_com_drecvb ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Fetch byte-data to the specified serial port. Uses ROM BIOS serial read 
;  function.
;  
;  Syntax: 
;
;    int pfl_com_brecv(int port_no)
;
;  Parameters:
;
;    int port_no         - serial port no.
;   
;  Returns:
;
;    Returns an int describing the line status (high-order byte) and the data
;    byte received (low-order byte).
;
;  Note: 
;
;    If the MSB of the return value is set, an error in receiving occurred. Use
;    pfl_com_sts() or pfl_com_dsts() for a more detailed error status.
;
;  rnr
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_brecv

; set up parameter offsets from BP

        port_no   = 6                             

; function definition
        
_pfl_com_brecv    PROC  

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     DX, [BP]+port_no        ; set DX to the serial port no

        MOV     AH, 02H                 ; read character from port
        INT     14H

        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_brecv    ENDP


        PAGE
;----------------------------------------------------------------------------                
;  Get serial port status.
;  
;  Syntax: 
;
;    int pfl_com_sts(int port_no)
;
;  Parameters:
;
;    int port_no         - serial port no.
;    
;  Returns:
;
;    Returns an int describing the line status (high-order byte) and the modem 
;    status (low-order byte).
;
;  rnr
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_sts

; set up parameter offsets from BP

        port_no   = 6                     
        
; function definition
        
_pfl_com_sts     PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position
        
        MOV     DX, [BP]+port_no        ; set DX to the serial port no

        MOV     AH, 03H                 ; get port status
        INT     14H

        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_sts     ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Get serial port status at chip level (direct i/o).
;  
;  Syntax: 
;
;    int pfl_com_dsts(int base_addrs)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;    
;  Returns:
;
;    Returns an int describing the line status (high-order byte) and the modem 
;    status (low-order byte).
;
;  rnr  5-11-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_dsts

; set up parameter offsets from BP

        base_addrs   = 6
                
; function definition
        
_pfl_com_dsts   PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX        

        CLI
        MOV     DX, CS:com_addrs        ; get base address
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; read status byte
        MOV     AH, AL                  ; copy AL to AH
        INC     DX                      ; point to modem status register
        IN      AL, DX                  ; read status byte
        STI
        
        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_dsts   ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Get serial port status at chip level (direct i/o).
;  
;  Syntax: 
;
;    int pfl_com_ndsts(int base_addrs)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;    
;  Returns:
;
;    Returns an int describing the line status (high-order byte) and the modem 
;    status (low-order byte).
;
;  Note:
;
;    This version does not clear the interrupts.
;
;  rnr  5-11-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_ndsts

; set up parameter offsets from BP

        base_addrs   = 6
                
; function definition
        
_pfl_com_ndsts   PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX        

;        CLI
        MOV     DX, CS:com_addrs        ; get base address
        ADD     DX, 5                   ; point to line status register
        IN      AL, DX                  ; read status byte
        MOV     AH, AL                  ; copy AL to AH
        INC     DX                      ; point to modem status register
        IN      AL, DX                  ; read status byte
;        STI
        
        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_ndsts   ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Read serial port modem control register (MCR).
;  
;  Syntax: 
;
;    int pfl_com_rmcr(int base_addrs)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;    
;  Returns:
;
;    Returns an int containing the current value of the modem control register 
;    in the low-order byte.
;
;  rnr  6-15-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_rmcr

; set up parameter offsets from BP

        base_addrs   = 6
                
; function definition
        
_pfl_com_rmcr   PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX        

;        CLI
        MOV     DX, CS:com_addrs        ; get base address
        ADD     DX, 4                   ; point to modem control register
        IN      AL, DX                  ; read contents
        XOR     AH, AH                  ; zero AH
;        STI
        
        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_rmcr   ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Write (set bits) to serial port modem control register (MCR).
;  
;  Syntax: 
;
;    int pfl_com_wmcr_or(int base_addrs, int or_bits)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;    
;    int or_bits         - bits to set in the modem control register
;    
;  Returns:
;
;    Nothing.
;
;
;  rnr  8-11-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_wmcr_or

; set up parameter offsets from BP

        or_bits      = 8
        base_addrs   = 6
                
; function definition
        
_pfl_com_wmcr_or   PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX        

        MOV     AH, BYTE PTR [BP]+or_bits       ; get bits to set

;        CLI
        MOV     DX, CS:com_addrs        ; get base address
        ADD     DX, 4                   ; point to modem control register
        IN      AL, DX                  ; read contents
        OR      AL, AH                  ; turn the appropriate bits on
        JMP     SHORT $+2
        JMP     SHORT $+2                 
        OUT     DX, AL
;        STI
        
        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_wmcr_or   ENDP

        PAGE
;----------------------------------------------------------------------------                
;  Write (clear bits) to serial port modem control register (MCR).
;  
;  Syntax: 
;
;    int pfl_com_wmcr_and(int base_addrs, int and_bits)
;
;  Parameters:
;
;    int base_addrs      - serial port base address.
;    
;    int and_bits        - bits to clear in the modem control register
;    
;  Returns:
;
;    Nothing.
;
;
;  rnr  8-11-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_com_wmcr_and

; set up parameter offsets from BP

        and_bits     = 8
        base_addrs   = 6
                
; function definition
        
_pfl_com_wmcr_and    PROC    

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        MOV     AX, WORD PTR [BP]+base_addrs    ; get port base address
        MOV     CS:com_addrs, AX        

        MOV     AH, BYTE PTR [BP]+and_bits      ; get bits to clear

;        CLI
        MOV     DX, CS:com_addrs        ; get base address
        ADD     DX, 4                   ; point to modem control register
        IN      AL, DX                  ; read contents
        AND     AL, AH                  ; clear the appropriate bits
        JMP     SHORT $+2
        JMP     SHORT $+2                 
        OUT     DX, AL
;        STI
        
        POP     BP                      ; restore BP
        
        RET
        
_pfl_com_wmcr_and    ENDP

        PAGE
        
;------------------------------------------------------ other support routines

;-----------------------------------------------------------------------------
; SET_BAUD_RATE
;
; Routine that sets the bit rate at chip level.
; 
; On entry: DX --> COM port base address
;           CX --> baud rate divisors
;                  CH - high byte baud rate divisor
;                  CL - low  byte baud rate divisor
;
; Returns: Nothing
;
; rnr  4-24-95
;-----------------------------------------------------------------------------
SET_BAUD_RATE   PROC    NEAR

; save registers
        PUSH    AX
        PUSH    CX
        PUSH    DX        

        ADD     DX, 3                   ; point to line control register
        IN      AL, DX                  ; read current values
        OR      AL, 10000000B           ; set bit 7
        OUT     DX, AL                  ; output the byte

        SUB     DX, 2                   ; point to MSB of baud rate divisor
        MOV     AL, CH                  ; value of MSB
        OUT     DX, AL                  

        DEC     DX                      ; point to LSB of baud rate divisor
        MOV     AL, CL                  ; value of LSB
        OUT     DX, AL

        ADD     DX, 3                   ; point to line control register
        IN      AL, DX                  ; read current values
        AND     AL, 01111111B           ; clear bit 7
        OUT     DX, AL                  ; output the byte

; restore registers
        POP     DX
        POP     CX
        POP     AX        
        
        RET
        
SET_BAUD_RATE   ENDP

;-----------------------------------------------------------------------------
; CHECKTIME
;
; Routine to check if time has elapsed
; Enter with original clock ticks in BX and maximum wait (in ticks) in AX
; Returns with carry set if time is expired; all other registers intact
;-----------------------------------------------------------------------------
CHECKTIME       PROC    NEAR

            PUSH    AX
            PUSH    BX
            PUSH    CX
            PUSH    DX
            
            MOV     CS:waitcount,AX     ; store maximum ticks
            CALL    GET_CLOCK_COUNT     ; check for timeout
            CMP     BX,DX               ; check for wrap around
            JG      CT1                 ; yup, it was there
            SUB     DX,BX               ; now we have elapsed ticks in DX
            JMP     SHORT CT2   
CT1:        
            MOV     AX,0FFFFH
            SUB     AX,BX
            ADD     DX,AX
CT2:        
            CMP     DX,CS:waitcount     ; is our time up?
            JA      TimeUp              ; yes, so exit accordingly
            CLC                         ; no, no error
            JNC     CTExit
TimeUp:     
            STC                         ; set for time up
CTExit:     
            POP     DX
            POP     CX
            POP     BX
            POP     AX
            
            RET

; store variables here            
waitcount       DW      ?               ; maximum wait (in clock ticks)
            
CHECKTIME       ENDP

;-----------------------------------------------------------------------------
; GET_CLOCK_COUNT
;
; Routine that retrieves the 4-byte BIOS Time-of-Day count from the BIOS data 
; area (0040:006c).
;
; Returns: CX --> high-order part of clock count
;          DX --> low-order part of clock count
;
;          Destroys AX, CX and DX registers.
; 
; rnr  10-17-95
;-----------------------------------------------------------------------------
GET_CLOCK_COUNT PROC    NEAR

        PUSH    ES                      ; save ES

        MOV     AX, 40H                 ; segment at 0040h (BIOS data area)
        MOV     ES, AX                  ; ES --> BIOS data area

        CLI
        MOV     DX, ES:[6CH]            ; low-order part of clock count
        MOV     CX, ES:[6CH]+2          ; high-order part of clock count
        STI

        POP     ES                      ; restore ES

        RET
        
GET_CLOCK_COUNT ENDP

;-----------------------------------------------------------------------------
; SET_PORT
;
; Routine that sets the serial port base address. Defaults to COM1 base add-
; ress (3f8h), when an invalid port no is passed.
;
; On entry: BX --> serial port no
; 
; Returns: Nothing. Destroys AX, BX and CX registers.
;
; rnr  5-4-95
;-----------------------------------------------------------------------------
SET_PORT        PROC    NEAR

        PUSH    DS                      ; save DS

; setup DS register        
        MOV     AX, @CODE               ; DS --> CS
        MOV     DS, AX
        ASSUME  DS:@CODE
        
; validate port no passed
        CMP     BX, 0
        JL      DEFAULT_ADRS
        CMP     BX, 3
        JG      DEFAULT_ADRS

; determine serial port base address
        MOV     CL, 1
        SHL     BX, CL                  ; multiply by 2
        MOV     AX, port_addrs[BX]
        MOV     com_addrs, AX
        
        JMP     SHORT SP_EXIT

DEFAULT_ADRS:
        MOV     com_addrs, 3F8H         ; default to COM1 
        
SP_EXIT:        
        POP     DS                      ; restore DS

        RET
        
SET_PORT        ENDP
        
               END