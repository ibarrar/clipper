        PAGE    58, 132

; set title, memory model and instruction set
        TITLE   PRNTASYN.ASM
        .MODEL  LARGE
        .286

; Macro definitions -----
;DISPSTR MACRO   TEXT_MSG

;        MOV     DX, OFFSET TEXT_MSG
;        MOV     AH, 9
;        INT     21H

;        ENDM        

; External definitions -----
        EXTRN   _rjs_asyn:FAR

; Equates -----
TIMERTICK_INT     EQU     1CH            ; timer tick interrupt
DOS_IDLE_INT      EQU     28H            ; DOS Idle interrupt
HSTACK_SIZE       EQU     2048           ; interrupt handler stack size

; Data Segment -----
        .DATA

        EXTRN   _print_active:WORD, _buffer_empty:WORD, _sound_active:WORD

; MSG1    DB      "Timer Tick interrupt has been hooked", 0DH, 0AH, '$'

; Code Segment -----
        .CODE
        
;-----------------------------------------------------------------------------
;  Syntax:
;
;    void asyn_prnt_on(void)
;
;  Parameters:
; 
;    None.
;
;  Description:
;
;    ASYN_PRNT_ON() hooks the timer tick (INT 1CH) and the DOS Idle (INT 28H) 
;    interrupt to provide an asynchronous mode of printing.
;
;  Returns:
;
;    None.
;
;  rnr  6-4-94
;-----------------------------------------------------------------------------

        PUBLIC  _asyn_prnt_on

; function definition

_asyn_prnt_on       PROC    FAR

        PUSH    ES                      ; save ES
        
        MOV     _sound_active, 0
        
        MOV     AH, 34H                 ; get InDos flag address
        INT     21H                

        MOV     CS:INDOS_FLAG[2], ES    ; segment address
        MOV     CS:INDOS_FLAG[0], BX    ; offset address

; setup stack for the timer tick ISR

        MOV     AX, CS
        MOV     CS:NEW_SS, AX
        MOV     AX, OFFSET CS:HANDLER_STACK + HSTACK_SIZE
        MOV     CS:NEW_SP, AX

; setup stack for DOS Idle ISR

        MOV     AX, CS
        MOV     CS:NEW_SS2, AX
        MOV     AX, OFFSET CS:HANDLER_STACK2 + HSTACK_SIZE          
        MOV     CS:NEW_SP2, AX

; get current timer tick handler

        MOV     AL, TIMERTICK_INT
        MOV     AH, 35H
        INT     21H

        MOV     CS:OLDINT1CH[0], BX        ; offset address
        MOV     CS:OLDINT1CH[2], ES        ; segment address

; get current DOS Idle handler

        MOV     AL, DOS_IDLE_INT
        MOV     AH, 35H
        INT     21H

        MOV     CS:OLD_IDLE_INT[0], BX        ; offset address
        MOV     CS:OLD_IDLE_INT[2], ES        ; segment address

; setup the new timer tick handler

        PUSH    DS                      ; save DS
        MOV     AX, CS
        MOV     DS, AX                  ; DS ----> CS, segment address of the new handler
        MOV     DX, OFFSET NEWINT1CH    ; offset address of the new handler

        MOV     AL, TIMERTICK_INT
        MOV     AH, 25H
        INT     21H
        POP     DS

; setup the new DOS Idle handler

        PUSH    DS                      ; save DS
        MOV     AX, CS
        MOV     DS, AX                  ; DS ----> CS, segment address of the new handler
        MOV     DX, OFFSET DOS_IDLER    ; offset address of the new handler

        MOV     AL, DOS_IDLE_INT
        MOV     AH, 25H
        INT     21H
        POP     DS                      ; restore DS        

;        DISPSTR MSG1

        POP     ES                      ; restore ES

        RET
                
_asyn_prnt_on       ENDP

;-----------------------------------------------------------------------------
;  Syntax:
;
;    void asyn_prnt_off(void)
;
;  Parameters:
; 
;    None.
;
;  Description:
;
;    ASYN_PRNT_OFF() restores the interrupt vectors modified by ASYN_PRNT_ON()
;    to its original state.
;
;  Returns:
;
;    None.
;
;  rnr  6-4-94
;-----------------------------------------------------------------------------

        PUBLIC  _asyn_prnt_off

; function definition

_asyn_prnt_off       PROC    FAR

; restore the timer tick handler

        PUSH    DS                      ; save DS
        MOV     AX, CS:OLDINT1CH[2]     
        MOV     DS, AX                  ; segment address of the old handler
        MOV     DX, CS:OLDINT1CH[0]     ; offset address of the old handler

        MOV     AL, TIMERTICK_INT
        MOV     AH, 25H
        INT     21H

; restore the DOS Idle handler

        MOV     AX, CS:OLD_IDLE_INT[2]
        MOV     DS, AX                  ; segment address of the old handler
        MOV     DX, CS:OLD_IDLE_INT[0]  ; offset address of the new handler

        MOV     AL, DOS_IDLE_INT
        MOV     AH, 25H
        INT     21H

        POP     DS                      ; restore DS        

        RET
                
_asyn_prnt_off       ENDP

; ---------- new timer tick handler

NEWINT1CH        PROC

; save registers

        PUSHA
        PUSH    DS
        PUSH    ES
        
; call old interrupt handler

        PUSHF
        CALL    DWORD PTR CS:OLDINT1CH

        MOV     AX, CS:INDOS_FLAG[2]
        MOV     ES, AX
        MOV     BX, CS:INDOS_FLAG[0]
        
        CMP     BYTE PTR ES:[BX], 0     ; if DOS is busy then exit
        JNE     NEW_EXIT                ; otherwise do print jobs

        MOV     AX, @DATA               ; setup addressing
        MOV     DS, AX               

; do print jobs

        CMP     _sound_active, 1        ; don't interrupt keyboard sound
        JE      NEW_EXIT
        CMP     _print_active, 1        ; print job is in process
        JE      NEW_EXIT
        CMP     _buffer_empty, 0        ; print buffer is not empty
        JNE     NEW_EXIT
        MOV     _print_active, 1
        MOV     AL, 20H                 ; signify end of interrupt
        OUT     20H, AL        
        
; swap new stack 

        CLI
        MOV     CS:ORIG_SS, SS
        MOV     CS:ORIG_SP, SP
        MOV     SS, CS:NEW_SS
        MOV     SP, CS:NEW_SP
        STI                
        
        CALL    _rjs_asyn              ; go print handler

; swap old stack

        CLI
        MOV     SS, CS:ORIG_SS
        MOV     SP, CS:ORIG_SP
        STI                        

        MOV     _print_active, 0

; restore registers

NEW_EXIT:

        POP     ES
        POP     DS
        POPA    

; return from interrupt
        IRET        

OLDINT1CH       DW      0, 0
INDOS_FLAG      DW      0, 0
ORIG_SS         DW      0
ORIG_SP         DW      0
NEW_SS          DW      0
NEW_SP          DW      0
HANDLER_STACK   DB      HSTACK_SIZE DUP(0)

NEWINT1CH       ENDP

; ---------- new DOS Idle handler

DOS_IDLER       PROC

; save registers

        PUSHA
        PUSHF
        PUSH    DS
        PUSH    ES

        MOV     AX, @DATA               ; setup addressing
        MOV     DS, AX               

; do print jobs

        CMP     _sound_active, 1        ; don't interrupt keyboard sound
        JE      DOS_EXIT_NOW
        CMP     _print_active, 1        ; print job is in process
        JE      DOS_EXIT_NOW
        CMP     _buffer_empty, 0        ; print buffer is not empty
        JNE     DOS_EXIT_NOW
        MOV     _print_active, 1

; swap new stack

        CLI
        MOV     CS:ORIG_SS2, SS
        MOV     CS:ORIG_SP2, SP
        MOV     SS, CS:NEW_SS2
        MOV     SP, CS:NEW_SP2
        STI                
        
        CALL    _rjs_asyn              ; go print handler

; swap old stack

        CLI
        MOV     SS, CS:ORIG_SS2
        MOV     SP, CS:ORIG_SP2
        STI                                

        MOV     _print_active, 0        

DOS_EXIT_NOW:

        POP     ES
        POP     DS
        POPF
        POPA

        JMP     DWORD PTR CS:OLD_IDLE_INT   ; chain to old interrupt
        
OLD_IDLE_INT     DW      0, 0        
ORIG_SS2         DW      0
ORIG_SP2         DW      0
NEW_SS2          DW      0
NEW_SP2          DW      0
HANDLER_STACK2   DB      HSTACK_SIZE DUP(0)

DOS_IDLER       ENDP        

        END    
                