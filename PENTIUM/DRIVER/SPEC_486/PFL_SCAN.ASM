        PAGE    58, 132

; set title, memory model and instruction set
        TITLE   PFL_SCAN.ASM - PFL Scanner interface routines.
        .MODEL  LARGE
        .286

; EQUATES -------------------------------------------------------------------

FIRST_KEY       EQU     1               ; 1st key position
LAST_KEY        EQU     105             ; last key position

; External definitions -----
        EXTRN   _pfl_com_init:FAR

; Equates -----
HSTACK_SIZE       EQU     2048             ; interrupt handler stack size
LABEL_LEN         EQU     202              ; maximum label length
SCAN_BUFF_SIZE    EQU     (LABEL_LEN * 12) ; buffer size

; Code Segment -----
        .CODE
        
;-----------------------------------------------------------------------------
;  Syntax:
;
;    void asyn_scan_on(int label_size, unsigned char end_char, int default_irq,
;                      int port_no, int base_addrs, int setup, unsigned char protocol)
;
;  Parameters:
; 
;    int label_size           -  maximum no. of labels to be buffered.
;                                (1 >= label_size <= 10)
;
;    unsigned char end_char   -  bar code suffix character.
;
;    int default_irq          -  a flag that indicates if the default IRQ no
;                                is to be used for the specified ports.
;
;                                If default_irq is 1, the following table
;                                describes the IRQ no used by a port:
;                                
;                                Port      IRQ no 
;
;                                COM1       4
;                                COM2       3
;                                COM3       4
;                                COM4       3
;
;                                If default_irq is 0, the following table
;                                describes the IRQ no used by a port:
;                                
;                                Port      IRQ no 
;
;                                COM1       4
;                                COM2       3
;                                COM3       10
;                                COM4       11
;   
;    int port_no              -  serial port no (1-4).
;
;    int base_addrs           -  serial port base address
;
;    int setup                -  serial port communication parameters.
;
;    unsigned char protocol   -  handshaking protocol.
;
;  Description:
;
;    ASYN_SCAN_ON() hooks the specified scanner interrupt (irg_no) to provide
;    an asynchronous (event driven) mode of scanning bar code labels.
;
;  Returns:
;
;    Nothing.
;
;  Note:
;  
;    This function does not validate the parameters passed.
;
;  rnr  6-4-95
;-----------------------------------------------------------------------------

        PUBLIC  _asyn_scan_on

; set up parameter offsets from BP

        label_size  = 6                     
        end_char    = 8
        default_irq = 10
        port_no     = 12
        base_addrs  = 14
        setup       = 16
        protocol    = 18
        
; function definition

_asyn_scan_on   PROC   

        PUSH    BP                               ; save BP
        MOV     BP, SP                           ; get current SP position
        PUSH    ES                               ; save ES
        PUSH    DS                               ; save DS

        MOV     AX, WORD PTR [BP]+default_irq    ; get default_irq
        MOV     CS:DFLT_IRQ, AX                  ; save a copy for later use


        MOV     CS:SCAN_OKAY, 0                  ; no label has been completely
                                                 ; scanned
                
; set buffer pointers to start of buffer (empty)

        MOV     AX, OFFSET CS:SCAN_BUFF
        MOV     CS:BUFF_IN, AX
        MOV     CS:BUFF_OUT, AX
        MOV     CS:LOCAL_INDEX, AX               

; compute and set the buffer limit

        MOV     BX, WORD PTR [BP]+label_size ; get label size
        INC     BX                           ; + 1
        MOV     AX, LABEL_LEN

        MUL     BX                           ; label len x label size
        MOV     BX, AX                       ; copy result to BX
        LEA     AX, CS:SCAN_BUFF[BX]         ; get the offset
        MOV     CS:SCAN_LIMIT, AX

        MOV     AL, BYTE PTR [BP]+end_char   ; get label character terminator
        MOV     CS:END_BYTE, AL              ; save a copy of it for later use
        
; initialize serial port        

        MOV     AX, WORD PTR [BP]+port_no    ; set AX for the serial port no
        MOV     CS:COM_PORT_NO, AX           ; save a copy for later use
        DEC     AX                           ; --AX: port no begins at zero
                                             ; on BIOS init function
        MOV     BX, WORD PTR [BP]+setup      ; set BX for the communication parameters        
        MOV     CX, WORD PTR [BP]+protocol   ; set CX for the protocol        

        PUSH    CX
        PUSH    BX
        PUSH    AX

        CALL    _pfl_com_init
        ADD     SP, 6
                
; save current serial port interrupt handler

        MOV     BX, WORD PTR [BP]+port_no       ; get port no
        CMP     WORD PTR [BP]+default_irq, 0    ; use default IRQ ?
        JG      ASON_0                          ; yes, then use default port interrupt vectors
        MOV     AL, CS:A_COM_VECT[BX]           ; otherwise, use alternate port interrupt vectors
        JMP     ASON_1                          ; go save handler

ASON_0: 
        MOV     AL, CS:D_COM_VECT[BX]           ; use default port interrupt vectors

ASON_1:
        MOV     CS:COM_INT_NO, AL               ; save interrupt vector no
        MOV     AH, 35H
        INT     21H

        MOV     CS:OLD_PORT_INT[0], BX          ; offset address
        MOV     CS:OLD_PORT_INT[2], ES          ; segment address

; setup the new serial port interrupt handler

        MOV     AX, CS
        MOV     DS, AX                  ; DS ----> CS, segment address of the new handler
        MOV     DX, OFFSET NEW_PORT_INT ; offset address of the new handler

        MOV     AL, CS:COM_INT_NO
        MOV     AH, 25H
        INT     21H

        CLI                                   

; enable device interrupt        
        MOV     DX, WORD PTR [BP]+base_addrs  ; get serial port base address
        MOV     CS:COM_BASE_ADDRS, DX         ; save a copy for later use        
        ADD     DX, 4                         ; point to modem control register
        IN      AL, DX
        OR      AL, 08H                       ; enable interrupts (OUT2 line)
        AND     AL, 00001011B                 ; clear OUT1 line and UART loop back
                                              ; testing (for good measure)
        JMP     SHORT $+2                     ; put some delay
        JMP     SHORT $+2
        OUT     DX, AL
        
        SUB     DX, 3                         ; point to interrupt enable register
        MOV     AL, 05H                       ; enable data available and receive
                                              ; line status interrupt
        OUT     DX, AL                                              

; enable interrupt for PIC   

        MOV     BX, WORD PTR [BP]+port_no     ; set BX for the serial port no
        CMP     WORD PTR [BP]+default_irq, 0  ; use default IRQ ?       
        JG      ASON_2                        ; yes, then use default interrupt masks
        CMP     BX, 3                         ; if port is >= 3 ?
        JGE     ASON_3                        ; yes, then use IMR of slave PIC       
        MOV     DX, 21H                       ; otherwise, use IMR of master PIC
        JMP     ASON_4

ASON_3:        
        MOV     DX, 0A1H                      ; use IMR of slave PIC

ASON_4:        
        IN      AL, DX                        ; read interrupt mask register 
        AND     AL, CS:INT_MASK_2[BX]         ; enable the designated IRQ no
        JMP     ASON_EXIT                     ; using the alternate interrupt masks

ASON_2:
        MOV     DX, 21H
        IN      AL, DX                        ; read interrupt mask register from
                                              ; master PIC        
        AND     AL, CS:INT_MASK_1[BX]         ; enable the designated IRQ no
                                              ; using the default interrupt masks
ASON_EXIT:        
        JMP     SHORT $+2
        OUT     DX, AL                        ; set it
        
        STI

; restore registers used
        POP     DS
        POP     ES
        POP     BP

        RET

; data area

OLD_PORT_INT    DW      ?, ?                          ; old port interrupt vector
COM_INT_NO      DB      ?                             ; interrupt vector no
INT_MASK_1      DB      0FFH, 0EFH, 0F7H, 0EFH, 0F7H  ; default interrupt masks for the PIC
INT_MASK_2      DB      0FFH, 0EFH, 0F7H, 0FBH, 0F7H  ; alternate interrupt masks for the PIC
D_COM_VECT      DB      0CH, 0CH, 0BH, 0CH, 0BH       ; default port interrupt vectors
A_COM_VECT      DB      0CH, 0CH, 0BH, 72H, 73H       ; alternate port interrupt vectors

_asyn_scan_on       ENDP

        PAGE
;-----------------------------------------------------------------------------
;  Syntax:
;
;    void asyn_scan_off(void)
;
;  Parameters:
; 
;    None.
;
;  Description:
;
;    ASYN_SCAN_OFF() restores the interrupt vectors and IRQ level modified by 
;    ASYN_SCAN_ON() to its original state.
;
;  Returns:
;
;    None.
;
;  rnr  6-5-95
;-----------------------------------------------------------------------------

        PUBLIC  _asyn_scan_off

; function definition

_asyn_scan_off       PROC    

        CLI

; disable device interrupt
        
        MOV     DX, CS:COM_BASE_ADDRS
        ADD     DX, 4                   ; point to modem control register
        XOR     AL, AL                  ; reset to zero
        OUT     DX, AL                  ; clear it

        SUB     DX, 3                   ; point to interrupt enable register
        XOR     AL, AL                  ; reset to zero
        OUT     DX, AL                  ; clear it      

; disable interrupt for PIC        

        MOV     BX, CS:COM_PORT_NO            ; set BX for the serial port no
        CMP     CS:DFLT_IRQ, 0                ; use default IRQ ?       
        JG      ASOF_0                        ; yes, then use default interrupt masks
        CMP     BX, 3                         ; if port is >= 3 ?
        JGE     ASOF_1                        ; yes, then use IMR of slave PIC       
        MOV     DX, 21H                       ; otherwise, use IMR of master PIC
        JMP     ASOF_2

ASOF_1:        
        MOV     DX, 0A1H                      ; use IMR of slave PIC

ASOF_2:        
        IN      AL, DX                        ; read interrupt mask register 
        MOV     AH, CS:INT_MASK_2[BX]        
        NOT     AH
        OR      AL, AH                        ; disable the designated IRQ no
        JMP     ASOF_EXIT                     ; using the alternate interrupt masks

ASOF_0:
        MOV     DX, 21H
        IN      AL, DX                        ; read interrupt mask register from
                                              ; master PIC        
        MOV     AH, CS:INT_MASK_1[BX]        
        NOT     AH             
        OR      AL, AH                        ; disable the designated IRQ no
                                              ; using the default interrupt masks
ASOF_EXIT:        
        JMP     SHORT $+2
        OUT     DX, AL                        ; set it

; send EOI command to PIC (for good measure)

        MOV     AL, 20H
        CMP     CS:DFLT_IRQ, 0                ; using default IRQ ?
        JG      ASOF_3                        ; yes

        OUT     0A0H, AL                      ; otherwise, send EOI to slave PIC       

ASOF_3:
        JMP     SHORT $+2
        JMP     SHORT $+2
        OUT     20H, AL                       ; send EOI to master PIC
        
        STI
        
; restore the original serial port handler

        PUSH    DS                      ; save DS
        MOV     AX, CS:OLD_PORT_INT[2]     
        MOV     DS, AX                  ; segment address of the old handler
        MOV     DX, CS:OLD_PORT_INT[0]  ; offset address of the old handler

        MOV     AL, CS:COM_INT_NO
        MOV     AH, 25H
        INT     21H
        POP     DS                      ; restore DS

        RET
                
_asyn_scan_off       ENDP

        PAGE
;----------------------------------------------------------------------------
;  Get a complete scanned label from the circular buffer.
;  
;  Syntax: 
;
;    int pfl_get_label(char *byte_data)
;
;  Parameters:
;  
;    char *byte_data   - buffer that holds the label info.
;
;  Returns:
;
;    Negative one (-1) is returned if no label was fetched from the buffer.
;    Otherwise AH and AL will contain the following information:
;
;    AH holds the status.
;      0 - Normal
;      1 - Read error
;
;    AL contains the actual length of the label scanned.
;
;  Note:
;    A prior call to asyn_scan_on() is required. The suffix character is
;    included in byte_data[], but it is not included in the count.
;
;  rnr  6-8-95
;-----------------------------------------------------------------------------    

        PUBLIC  _pfl_get_label

; set up parameter offsets from BP

        byte_data  =  6        

; function definition

_pfl_get_label  PROC   

        PUSH    BP                      ; save BP
        MOV     BP, SP                  ; get current SP position

        PUSH    DI                      ; save DI
        PUSH    ES                      ; save ES
        PUSH    DS                      ; save DS
        PUSHF                           ; save flags

; setup data addressing

        MOV     AX, @CODE               ; DS ---> CS
        MOV     DS, AX
        ASSUME  DS: @CODE

        CLD     
        MOV     DI, WORD PTR [BP]+byte_data     ; offset of byte_data
        MOV     AX, WORD PTR [BP]+byte_data+2   ; segment of byte_data
        MOV     ES, AX

        CLI                             ; clear hardware interrupts
        MOV     BX, BUFF_OUT            ; get current buffer output index
        MOV     DX, BX                  ; make a copy of it
        CMP     BX, BUFF_IN             ; buffer is empty ?
        JE      PGL_1                   ; if yes, exit
        MOV     CL, 0                   ; byte counter

PGL_AGAIN:
        MOV     AL, [BX]                ; otherwise, retrieve data
        STOSB                           ; copy from AL        
        INC     BX                      ; increment buffer output index
        CMP     AL, END_BYTE            ; is it the end byte ?
        JE      PGL_2                   ; yes - a complete label has been fetched
        INC     CL                      ; increment byte counter
        JMP     SHORT PGL_AGAIN         ; fetch another byte from the buffer
        
PGL_2:
        MOV     AH, [BX]                ; get the status
        MOV     AL, CL                  ; get the length
        MOV     BX, DX                  ; get current BUFF_OUT
        ADD     BX, LABEL_LEN           ; next buffer output index
        CMP     BX, SCAN_LIMIT          ; past the end of buffer ?
        JNE     PGL_3                   ; if not, continue
        LEA     BX, SCAN_BUFF           ; otherwise, reset to start of buffer 

PGL_3:        
        MOV     BUFF_OUT, BX            ; update BUFF_OUT
        MOV     SCAN_OKAY, 0            ; assume no more labels to be retrieved from the buffer
        CMP     BX, BUFF_IN             ; buffer is empty ?
        JE      PGL_EXIT                ; yes
        MOV     SCAN_OKAY, 1            ; otherwise, there are still some labels to be fetched
        JMP     SHORT PGL_EXIT

PGL_1:
        MOV     SCAN_OKAY, 0            ; no label is completely scanned
        MOV     AX, -1
        
PGL_EXIT:
        STI

; restore registers used

        POPF
        POP     DS
        POP     ES
        POP     DI
        POP     BP

        RET

_pfl_get_label  ENDP

        PAGE
; ---------- new serial port interrupt handler

NEW_PORT_INT    PROC

; save registers

        PUSHA
        PUSH    DS
        PUSH    ES

; setup data addressing

        MOV     AX, @CODE               ; DS ---> CS
        MOV     DS, AX
        ASSUME  DS: @CODE

        MOV     DX, COM_BASE_ADDRS      ; get port base address
        ADD     DX, 2                   ; point to IIR register
        IN      AL, DX                  ; get IIR contents
        MOV     AH, AL                  ; make a copy of it
        AND     AH, 01H                 ; interrupt pending ?
        JNZ     NPI_EXIT                ; no interrupt pending so exit
        MOV     RECEIVE_ERR, 0          ; clear receive error flag

; determine what type of interrupt

TYPE_1:
        CMP     AL, 4                   ; received data available ?
        JNE     TYPE_2                  ; if no, then try other types
        SUB     DX, 2                   ; otherwise, read in the received character
                                        ; and store it in the circular buffer
        IN      AL, DX
        CALL    PUT_BYTE
        JMP     SEND_EOI                ; exit

TYPE_2:
        CMP     AL, 6                   ; receive error ?
        JNE     SEND_EOI                ; if no, then exit (ignore other 
                                        ; interrupts if any)
        ADD     DX, 3                   ; read the line status register
        IN      AL, DX                  ; to clear it                      
        MOV     RECEIVE_ERR, 1          ; set receive error flag
        
        MOV     AL, END_BYTE            ; put terminating byte
        CALL    PUT_BYTE
                
SEND_EOI: 
        
; send EOI command to PIC

        MOV     AL, 20H
        CMP     DFLT_IRQ, 0             ; using default IRQ ?
        JG      NPI_0                   ; yes

        CMP     COM_PORT_NO, 2          ; port no <= 2 ?
        JLE     NPI_0                   ; yes
        OUT     0A0H, AL                ; otherwise send EOI to slave PIC

NPI_0:
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2
        OUT     20H, AL                 ; send EOI to master PIC
        
; restore registers

NPI_EXIT:

        POP     ES
        POP     DS
        POPA    

; return from interrupt
        IRET        

; data area

COM_BASE_ADDRS  DW      ?                       ; serial port base address
COM_PORT_NO     DW      ?                       ; serial port no
DFLT_IRQ        DW      ?                       ; flag that indicates if default IRQ is to be used
END_BYTE        DB      ?                       ; label character terminator
RECEIVE_ERR     DB      ?                       ; receive error flag
SCAN_BUFF       DB      SCAN_BUFF_SIZE DUP(?)   ; scanner circular buffer
SCAN_LIMIT      DW      ?                       ; buffer limit
BUFF_IN         DW      ?                       ; buffer input pointer 
BUFF_OUT        DW      ?                       ; buffer output pointer
LOCAL_INDEX     DW      ?                       ; address of the next available
                                                ; byte-storage
SCAN_OKAY       DB      ?                       ; flag that indicates that at least
                                                ; one label is completely scanned

NEW_PORT_INT    ENDP

;----------------------------------------------------------------------------
;  PUT_BYTE
;
;  Routine that stores the data byte into the circular buffer.
; 
;  On entry: AL --> data byte
;
;  On exit : AH --> status
;                   0 - means successful
;                   1 - means unsuccessful, buffer is full
;
;  Note:
;
;  This is the label format inside the circular buffer. BUFF_IN (input pointer)
;  is incremented every LABEL_LEN.
;
;     1 complete label is scanned
;  :-------------------------------------- - - - - - - - - - - - - -:----- - - -
;  : Data bytes | End byte | Status byte | unused portion (if any)  : next label
;  :-------------------------------------- - - - - - - - - - - - - -:----- - - -
;  |                                                                |
;  0                                                            LABEL_LEN
;
;  The algorithm assumes that the label scanned is <= LABEL_LEN-1, including
;  the suffix (or terminating) character.
;
;  rnr  6-7-95
;----------------------------------------------------------------------------
PUT_BYTE        PROC    NEAR

        MOV     AH, 1                   ; assume buffer is full
        MOV     BX, BUFF_IN             ; get current buffer input index
        MOV     CX, BX                  ; make a copy of it
        ADD     CX, LABEL_LEN           ; next buffer input index
        CMP     CX, SCAN_LIMIT          ; past the end of buffer ?
        JNE     PB_0                    ; no
        LEA     CX, SCAN_BUFF           ; if yes, reset to start of buffer

PB_0:
        CMP     CX, BUFF_OUT            ; buffer is full ?
        JE      PB_EXIT                 ; yes, so exit        
        MOV     BX, LOCAL_INDEX         ; get current byte-storage pointer
        CMP     AL, END_BYTE            ; end byte terminator ?
        JNE     PB_2                    ; if not then store data byte
        MOV     [BX], AL                ; otherwise, store end byte
        INC     BX                      ; point to the next byte-storage
        MOV     BYTE PTR [BX], 1        ; assume receive error: status byte is 1
        TEST    RECEIVE_ERR, 01H        ; receive error ?
        JNZ     PB_3                    ; if yes, continue
        MOV     BYTE PTR [BX], 0        ; otherwise, status byte is 0 (normal)

PB_3:
        MOV     BX, BUFF_IN             ; get current buffer input index
        MOV     CX, BX                  ; make a copy of it
        ADD     CX, LABEL_LEN           ; next buffer input index
        CMP     CX, SCAN_LIMIT          ; past the end of buffer ?
        JNE     PB_4                    ; no
        LEA     CX, SCAN_BUFF           ; if yes, reset to start of buffer

PB_4:
        MOV     BUFF_IN, CX             ; update buffer input index
        MOV     LOCAL_INDEX, CX
        MOV     SCAN_OKAY, 1            ; at least one label is completely scanned        
        XOR     AH, AH                  ; zero AH        
        JMP     PB_EXIT

PB_2:
        MOV     [BX], AL                ; store data byte
        INC     BX                      ; point to the next available byte-storage
        MOV     LOCAL_INDEX, BX         ; update byte-storage pointer
        XOR     AH, AH                  ; zero AH                

PB_EXIT:
        RET        

PUT_BYTE        ENDP

        END    
                