        PAGE    58, 132

; set title and instruction set

        TITLE   PFL_COM.ASM
        .286

COMMENT |
*****************************************************************************

  PFL_COM.ASM

  PFL_COM is a passive TSR for the PFL serial port interface routines.
  
  The purpose of this program is to hold all the communication parameters
  of all the devices, connected to the serial port interface of the POS 
  machine. This scheme will make the PFL serial port interface routines tran-
  sparent from the application side.

  See also PFLSRIAL.ASM and PFLSRIAL.H.

  rnr  4-25-95
****************************************************************************|

; ------------------------------------------------------------------- EQUATES

CR                      EQU     0DH             ; carriage return
LF                      EQU     0AH             ; line feed
PFL_COM_INSTALLED       EQU     -1
TSR_STACK_SIZE          EQU     256
BELL_SOUND              EQU     07H

; -------------------------------------------------------------- CODE SEGMENT

CSEG    SEGMENT 
        ASSUME CS:CSEG, SS:CSEG, DS:CSEG, ES:CSEG

; save space for PSP

        ORG     100H

MAIN:
        JMP     INSTALL_TSR             ; go to the installation process

;----------------------------------------------------------------------------
;  MLTIPLEX_HNDLR
;
;
;  The multiplex handler (INT 2FH) of PFL_COM contains the following functions:
;
;  1. INT 2FH, DD00H
;
;  Purpose :  Get PFL_COM installation state.
;
;  On entry:  AX --> function code DD00H
;  
;  Returns :  AX --> -1 if already installed, otherwise no change
;             
;
;  2. INT 2FH, DD01H
;
;  Purpose :  Read serial port device ID. 
;             - identifies the device connected to all the serial ports.
;
;  On entry:  AX --> function code DD01H
;
;  Returns :  AX --> device ID connected to COM1
;             BX --> device ID connected to COM2
;             CX --> device ID connected to COM3
;             DX --> device ID connected to COM4
;
;             A return value of -1 indicates that the designated port is not
;             in use.
;
;
;  3. INT 2FH, DD02H
;
;  Purpose :  Read serial port communication parameters.
;
;  On entry:  AX --> function code DD02H
;             CH --> serial port (0 - COM1, 1 - COM2, etc.)
;
;  Returns :  BX --> device ID
;             DX --> serial port communication settings
;             CL --> handshaking protocol
;
;
;  4. INT 2FH, DD03H
;
;  Purpose :  Store serial port communication parameters.
;
;  On entry:  AX --> function code DD03H
;             CH --> serial port (0 - COM1, 1 - COM2, etc.)
;             BX --> device ID
;             DX --> serial port communication settings
;             CL --> handshaking protocol
;
;  Returns :  Nothing
;
;  Any other subfunction is ignored and the registers are returned unchanged.
;
;
;  rnr  4-26-95
;----------------------------------------------------------------------------
MLTIPLEX_HNDLR PROC

        CMP     AH, 0DDH                ; TSR interrupt function code ?
        JE      INSIDE_PFL_COM          ; yes, then do process
        JMP     DWORD PTR CS:OLD_INT2FH ; skip to original interrupt

INSIDE_PFL_COM:
;        CLI                             ; use TSR stack
        MOV     CS:OLD_SS, SS
        MOV     CS:OLD_SP, SP
        MOV     SS, CS:TSR_SS
        MOV     SP, CS:TSR_SP                                        
;        STI        

; save registers 
        PUSH    DS                      
        PUSH    SI      
        
        PUSH    AX
        MOV     AX, CS                  ; set-up data segment addressing
        MOV     DS, AX        
        POP     AX
        
; determine subfunction        
        CMP     AL, 00H                 
        JE      SUB_FUNC_00             ; PFL_COM installation state
        
        CMP     AL, 01H
        JE      SUB_FUNC_01             ; read COM port device ID

        CMP     AL, 02H         
        JE      SUB_FUNC_02             ; read serial port communication parameters

        CMP     AL, 03H         
        JE      SUB_FUNC_03             ; store serial port communication parameters        

        JMP     PFL_COM_EXIT            ; otherwise, exit

SUB_FUNC_00:
        MOV     AX, PFL_COM_INSTALLED   ; already installed
        JMP     SHORT PFL_COM_EXIT        

SUB_FUNC_01:   ; read COM port device ID
        MOV     AX, COM_ID              ; read device ID connected to COM1
        MOV     BX, COM_ID[2]           ; read device ID connected to COM2
        MOV     CX, COM_ID[4]           ; read device ID connected to COM3
        MOV     DX, COM_ID[6]           ; read device ID connected to COM4
        JMP     SHORT PFL_COM_EXIT                

SUB_FUNC_02:   ; read serial port communication parameters
        CMP     CH, 0
        JL      PFL_COM_EXIT
        CMP     CH, 3
        JG      PFL_COM_EXIT
        
; Note: ----------------------------------------------------------------------
;
; _ID       - device ID
; _SETUP    - serial port communication settings
; _PROTOCOL - handshaking protocol

; calculate offset
        MOV     CL, CH                  ; copy CH to CL
        XOR     CH, CH                  ; zero CH
        MOV     SI, CX
        MOV     CL, 1                   ; multiply by 2
        SHL     SI, CL                  
        
        MOV     BX, COM_ID[SI]
        MOV     DX, COM_SETUP[SI]
        MOV     CL, BYTE PTR COM_PROTOCOL[SI]

        JMP     SHORT PFL_COM_EXIT

SUB_FUNC_03:   ; store serial port communication parameters        
        CMP     CH, 0
        JL      PFL_COM_EXIT
        CMP     CH, 3
        JG      PFL_COM_EXIT

; calculate offset
        PUSH    CX                      ; save CX
        MOV     CL, CH                  ; copy CH to CL
        XOR     CH, CH                  ; zero CH        
        MOV     SI, CX
        MOV     CL, 1                   ; multiply by 2
        SHL     SI, CL                  
        POP     CX                      ; restore CX
        
        MOV     COM_ID[SI], BX
        MOV     COM_SETUP[SI], DX
        XOR     CH, CH                  ; zero CH
        MOV     COM_PROTOCOL[SI], CX

PFL_COM_EXIT:

; restore registers
        POP     SI
        POP     DS                      

;        CLI
        MOV     SS, CS:OLD_SS           ; restore stack segment and offset
        MOV     SP, CS:OLD_SP
;        STI
        
        IRET        

; store data here -----------------------------------------------------------

OLD_INT2FH      DW ?,?                          ; holds the original int 2fh vector
OLD_SS          DW ?    
OLD_SP          DW ?
TSR_SS          DW ?
TSR_SP          DW ?
TSR_STACK       DB      TSR_STACK_SIZE DUP(?)   ; PFL_COM's stack space

; serial port communication parameters
COM_ID          DW      4 DUP(-1)               ; COM port device ID
COM_SETUP       DW      4 DUP(?)                ; COM port serial communication settings
COM_PROTOCOL    DW      4 DUP(?)                ; COM port handshaking protocol
        
MLTIPLEX_HNDLR ENDP

END_MAIN  LABEL    BYTE                 ; mark this offset
        
INSTALL_TSR:

; verify if already installed

        MOV     AX, 0DD00H
        INT     2FH                     ; multiplex interrupt

        CMP     AX, PFL_COM_INSTALLED   ; already installed ?
        JE      EXIT_PROG

; save original int 2fh vector

        MOV     AL, 2FH
        MOV     AH, 35H
        INT     21H

        MOV     OLD_INT2FH[0], BX       ; offset
        MOV     OLD_INT2FH[2], ES       ; segment
        
; modify interrupt vector 2fh (multiplex interrupt)

        MOV     AL, 2FH                 ; interrupt vector
        LEA     DX, MLTIPLEX_HNDLR      ; offset address (new interrupt handler)
        MOV     AH, 25H
        INT     21H        

; setup TSR stack for later use

        MOV     AX, CS
        MOV     TSR_SS, AX
        MOV     AX, OFFSET TSR_STACK+TSR_STACK_SIZE
        MOV     TSR_SP, AX

; free environment block (no use)

        MOV     ES, WORD PTR DS:[2CH]
        MOV     AH, 49H
        INT     21H        

        MOV     DX, OFFSET MSG1         ; Installation message
        MOV     AH, 9H
        INT     21H
                
; terminate and stay resident

        MOV     AL, 0                   ; return code
        LEA     DX, END_MAIN            ; compute resident size in paragraphs
        MOV     CL, 4                   ; divide by 16
        SHR     DX, CL                  
        INC     DX                      ; add 1 paragraph, just in case 
        MOV     AH, 31H
        INT     21H

EXIT_PROG:

        MOV     DX, OFFSET MSG2         ; already installed message
        MOV     AH, 9H
        INT     21H

; return to DOS
        MOV     AL, 1
        MOV     AH, 4CH
        INT     21H

; data area

MSG1    DB      "PFL_COM (R) - PFL Serial Port Configuration (Ver 1.00).", CR, LF
        DB      "Copyright (C) 1995 by FEMA Business Systems Corp.", CR, LF
        DB      "-------------------------------------------------------", CR, LF
        DB      "Installed...", BELL_SOUND, CR, LF, '$'  
MSG2    DB      "PFL_COM (R) - PFL Serial Port Configuration (Ver 1.00).", CR, LF
        DB      "Copyright (C) 1995 by FEMA Business Systems Corp.", CR, LF
        DB      "-------------------------------------------------------", CR, LF
        DB      "Already Installed...", BELL_SOUND, CR, LF, '$'
CSEG    ENDS

        END     MAIN
        