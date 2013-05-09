        PAGE    58, 132

; set title, memory model and instruction set
        TITLE   PFL_KEY.ASM - ISR for the keyboard sound.
        .MODEL  LARGE
        .286

; Macro definitions -----
;DISPSTR MACRO   TEXT_MSG

;        MOV     DX, OFFSET TEXT_MSG
;        MOV     AH, 9
;        INT     21H

;        ENDM        

; External definitions -----

        EXTRN   _sound:FAR, _delay:FAR, _nosound:FAR

; Equates -----
KEYBOARD_INT      EQU     09H            ; keyboard interrupt 
HSTACK_SIZE       EQU     2048           ; interrupt handler stack size
DATAPORT          EQU     60H            ; keyboard data port
STSPORT           EQU     64H            ; keyboard status port
FULLINPUT         EQU     02H            

; Data Segment -----
        .DATA
        
        EXTRN   _sound_active:WORD, _frqwency:WORD, _delay_cnt:WORD        

; no data
; MSG1    DB      "Keyboard interrupt has been hooked", 0DH, 0AH, '$'

; Code Segment -----
        .CODE
        
;-----------------------------------------------------------------------------
;  Syntax:
;
;    void hook_keytone(void)
;
;  Parameters:
; 
;    None.
;
;  Description:
;
;    HOOK_KEYTONE() hooks the keyboard sound routine in the keyboard interrupt 
;    (INT 9).
;
;  Returns:
;
;    None.
;
;  rnr  6-4-94
;-----------------------------------------------------------------------------

        PUBLIC  _hook_keytone

; function definition

_hook_keytone       PROC    FAR

        PUSH    ES                      ; save ES

        MOV     _sound_active, 0        
        MOV     CS:key_active, 0
        
; setup stack for the keyboard ISR

        MOV     AX, CS
        MOV     CS:NEW_SS, AX
        MOV     AX, OFFSET CS:HANDLER_STACK + HSTACK_SIZE
        MOV     CS:NEW_SP, AX

; get current keyboard handler

        MOV     AL, KEYBOARD_INT
        MOV     AH, 35H
        INT     21H

        MOV     CS:OLDINT9[0], BX        ; offset address
        MOV     CS:OLDINT9[2], ES        ; segment address

; setup the new keyboard handler

        PUSH    DS                      ; save DS
        MOV     AX, CS
        MOV     DS, AX                  ; DS ----> CS, segment address of the new handler
        MOV     DX, OFFSET NEWINT9      ; offset address of the new handler

        MOV     AL, KEYBOARD_INT
        MOV     AH, 25H
        INT     21H
        POP     DS

;        DISPSTR MSG1

        POP     ES                      ; restore ES

        RET
                
_hook_keytone       ENDP

;-----------------------------------------------------------------------------
;  Syntax:
;
;    void unhook_keytone(void)
;
;  Parameters:
; 
;    None.
;
;  Description:
;
;    UNHOOK_KEYTONE() restores the keyboard interrupt vector modified by HOOK_KEYTONE()
;    to its original state.
;
;  Returns:
;
;    None.
;
;  rnr  6-4-94
;-----------------------------------------------------------------------------

       PUBLIC  _unhook_keytone

; function definition

_unhook_keytone       PROC    FAR

; restore the timer tick handler

        PUSH    DS                    ; save DS
        MOV     AX, CS:OLDINT9[2]     
        MOV     DS, AX                ; segment address of the old handler
        MOV     DX, CS:OLDINT9[0]     ; offset address of the old handler

        MOV     AL, KEYBOARD_INT
        MOV     AH, 25H
        INT     21H

        POP     DS                    ; restore DS        

        MOV     _sound_active, 0      ; for good measure (since PRNTASYN.ASM
                                      ; uses also this flag)

        RET
                
_unhook_keytone       ENDP

; ---------- new keyboard handler

NEWINT9        PROC

; save registers

        PUSHA
        PUSHF
        PUSH    DS
        PUSH    ES
        PUSH    AX
        PUSH    DS

        MOV     AX, @DATA               ; setup addressing
        MOV     DS, AX                       
        
GETSTAT:
        JMP     SHORT $+2               ; put some delay
        JMP     SHORT $+2
        IN      AL, STSPORT             ; get keyboard status
        TEST    AL, FULLINPUT           ; is the coding complete
        JNZ     GETSTAT                 ; no, so loop
        JMP     SHORT $+2
        JMP     SHORT $+2        
        IN      AL, DATAPORT            ; yes, get key code
        
        TEST    AL, 80H                 ; test for break code
        JZ      SND_ON                  ; if no, turn on sound

SND_OFF:
        MOV     _sound_active, 0
        JMP     CALLINT                 ; call old interrupt handler

SND_ON: 
        MOV     _sound_active, 1        
        
CALLINT:        

        POP     DS
        POP     AX     
        
; call old interrupt handler

        PUSHF
        CALL    DWORD PTR CS:OLDINT9        

        MOV     AX, @DATA               ; setup addressing
        MOV     DS, AX               

        CMP     CS:key_active, 1
        JE      LONG_EXIT
        MOV     CS:key_active, 1
        JMP     SHORT DO_PROCESS

LONG_EXIT:

        JMP     DOS_EXIT_NOW

DO_PROCESS:                        

; do sound routine

        CMP     _sound_active, 1        ; if _sound_active == 1, do sound routine
        JE      MAKE_SOUND
        MOV     CS:key_active, 0
        JMP     DOS_EXIT_NOW        

MAKE_SOUND:
        
; swap new stack

        MOV     CS:ORIG_SS, SS
        MOV     CS:ORIG_SP, SP
        MOV     SS, CS:NEW_SS
        MOV     SP, CS:NEW_SP
        
; sound on
        CLI
        PUSH    _frqwency
        CALL    _sound
        ADD     SP, 2
        
; delay

        MOV     AH, 86H                 ; wait function
        MOV     CX, 0                   
        MOV     DX, _delay_cnt          ; delay in microseconds
        INT     15H
        
; sound off

        CALL    _nosound   

        MOV     _sound_active, 0
        
; swap old stack

        MOV     SS, CS:ORIG_SS
        MOV     SP, CS:ORIG_SP

        MOV     CS:key_active, 0        
        
DOS_EXIT_NOW:

        POP     ES
        POP     DS
        POPF
        POPA

        IRET
                
OLDINT9         DW      0, 0
ORIG_SS         DW      0
ORIG_SP         DW      0
NEW_SS          DW      0
NEW_SP          DW      0
key_active      DB      0
HANDLER_STACK   DB      HSTACK_SIZE DUP(0)

NEWINT9       ENDP

        END    
                