.MODEL  LARGE
   INCLUDE EXTASM.INC
   PUBLIC _keyhook
   PUBLIC _keyunhook
   PUBLIC NEWINT15

.DATA
   Keypress    db      00
   key36       db      00
   keyE0       db      00
.CODE


; The following is the new keyboard interrupt to replace Int 15/4F

NewInt15    PROC    FAR
   CMP     AH,4Fh              ;Is it the keyboard intercept?
   JE      Process             ;Yes, so continue
   JMP     DWORD PTR CS:KeyInt ;Skip to original interrupt handler

Process:
; Check Flags for scan code 36H and E0H

   CMP     key36,1
   JNE     CMP_Next1
   MOV     key36,0
   JMP     Key_Is_36
CMP_Next1:
   CMP     keyE0,1
   JNE     CMP_Next2
   MOV     keyE0,0
   JMP     Key_Is_E0

; Check the individual keys

CMP_Next2:
   CMP     AL,57H
   JNE     Check_Keys1
   MOV     Keypress,17
   JMP     Store
Check_Keys1:
   CMP     AL,58H
   JNE     Check_Keys2
   MOV     Keypress,18
   JMP     Store
Check_Keys2:
   CMP     AL,1
   JNE     Check_Keys3
   MOV     Keypress,16
   JMP     STore
Check_Keys3:
   CMP     AL,1AH
   JNE     Check_Keys4
   MOV     Keypress,19
   JMP     STore
Check_Keys4:
   CMP     AL,1BH
   JNE     Check_Keys5
   MOV     Keypress,20
   JMP     STore
Check_Keys5:
   CMP     AL,0FH
   JNE     Check_Keys6
   MOV     Keypress,31
   JMP     STore
Check_Keys6:
   CMP     AL,0DH
   JNE     Check_Keys7
   MOV     Keypress,43
   JMP     STore
Check_Keys7:
   CMP     AL,35H
   JNE     Check_Keys8
   MOV     Keypress,44
   JMP     STore
Check_Keys8:
   CMP     AL,0EH
   JNE     Check_Keys9
   MOV     Keypress,45
   JMP     STore
Check_Keys9:
   CMP     AL,5DH
   JNE     Check_Keys10
   MOV     Keypress,54
   JMP     STore
Check_Keys10:
   CMP     AL,1CH
   JNE     Check_Keys11
   MOV     Keypress,55
   JMP     STore
Check_Keys11:
   CMP     AL,4FH
   JNE     Check_Keys12
   MOV     Keypress,56
   JMP     STore
Check_Keys12:
   CMP     AL,50H
   JNE     Check_Keys13
   MOV     Keypress,57
   JMP     STore
Check_Keys13:
   CMP     AL,51H
   JNE     Check_Keys14
   MOV     Keypress,58
   JMP     STore
Check_Keys14:
   CMP     AL,37H
   JNE     Check_Keys15
   MOV     Keypress,59
   JMP     STore
Check_Keys15:
   CMP     AL,5BH
   JNE     Check_Keys16
   MOV     Keypress,60
   JMP     STore
Check_Keys16:
   CMP     AL,4BH
   JNE     Check_Keys17
   MOV     Keypress,71
   JMP     STore
Check_Keys17:
   CMP     AL,4CH
   JNE     Check_Keys18
   MOV     Keypress,72
   JMP     STore
Check_Keys18:
   CMP     AL,4DH
   JNE     Check_Keys19
   MOV     Keypress,73
   JMP     STore
Check_Keys19:
   CMP     AL,4AH
   JNE     Check_Keys20
   MOV     Keypress,74
   JMP     STore
Check_Keys20:
   CMP     AL,60H
   JNE     Check_Keys21
   MOV     Keypress,75
   JMP     STore
Check_Keys21:
   CMP     AL,18H
   JNE     Check_Keys22
   MOV     Keypress,83
   JMP     STore
Check_Keys22:
   CMP     AL,19H
   JNE     Check_Keys23
   MOV     Keypress,84
   JMP     STore
Check_Keys23:
   CMP     AL,27H
   JNE     Check_Keys24
   MOV     Keypress,85
   JMP     STore
Check_Keys24:
   CMP     AL,47H
   JNE     Check_Keys25
   MOV     Keypress,86
   JMP     STore
Check_Keys25:
   CMP     AL,48H
   JNE     Check_Keys26
   MOV     Keypress,87
   JMP     STore
Check_Keys26:
   CMP     AL,49H
   JNE     Check_Keys27
   MOV     Keypress,88
   JMP     STore
Check_Keys27:
   CMP     AL,4EH
   JNE     Check_Keys28
   MOV     Keypress,89
   JMP     STore
Check_Keys28:
   CMP     AL,5EH
   JNE     Check_Keys29
   MOV     Keypress,90
   JMP     STore
Check_Keys29:
   CMP     AL,5FH
   JNE     Check_Keys30
   MOV     Keypress,91
   JMP     STore
Check_Keys30:
   CMP     AL,29H
   JNE     Check_Keys31
   MOV     Keypress,92
   JMP     STore
Check_Keys31:
   CMP     AL,61H
   JNE     Check_Keys32
   MOV     Keypress,94
   JMP     STore
Check_Keys32:
   CMP     AL,39H
   JNE     Check_Keys33
   MOV     Keypress,95
   JMP     STore
Check_Keys33:
   CMP     AL,2BH
   JNE     Check_Keys34
   MOV     Keypress,96
   JMP     STore
Check_Keys34:
   CMP     AL,33H
   JNE     Check_Keys35
   MOV     Keypress,98
   JMP     STore
Check_Keys35:
   CMP     AL,28H
   JNE     Check_Keys36
   MOV     Keypress,99
   JMP     STore
Check_Keys36:
   CMP     AL,52H
   JNE     Check_Keys37
   MOV     Keypress,101
   JMP     STore
Check_Keys37:
   CMP     AL,5AH
   JNE     Check_Keys38
   MOV     Keypress,102
   JMP     STore
Check_Keys38:
   CMP     AL,53H
   JNE     Check_Keys39
   MOV     Keypress,103
   JMP     STore
Check_Keys39:
   CMP     AL,5CH
   JNE     Check_Keys40
   MOV     Keypress,105
   JMP     STore
Check_Keys40:
   CMP     AL,3BH
   JB      Check_Next1
   CMP     AL,44H
   JA      Check_Next1
   SUB     AL,3AH
   MOV     keypress,AL
   JMP     Store
Check_Next1:
   CMP     AL,10H
   JB      Check_Next2
   CMP     AL,17H
   JA      Check_Next2
   ADD     AL,30
   MOV     keypress,AL
   JMP     Store
Check_Next2:
   CMP     AL,1EH
   JB      Check_Next3
   CMP     AL,26H
   JA      Check_Next3
   ADD     AL,31
   MOV     keypress,AL
   JMP     Store
Check_Next3:
   CMP     AL,2CH
   JB      Check_Next4
   CMP     AL,32H
   JA      Check_Next4
   ADD     AL,32
   MOV     keypress,AL
   JMP     Store

; Check if E0H or 36H then set respective flags and exit

Check_Next4:
   CMP     AL,0E0h
   JNE     Check_36
   MOV     keyE0,1
   JMP     Good_bye
Check_36:
   CMP     AL,36H
   JNE     Check_unknown
   MOV     key36,1
   JMP     Good_Bye
Check_unknown:
   JMP     Drop_code

; Check what is the next scan code after E0H

Key_Is_E0:
   CMP     AL,52H
   JNE     Key_Is_E0_1
   MOV     Keypress,11
   JMP     Store
Key_Is_E0_1:
   CMP     AL,47H
   JNE     Key_Is_E0_2
   MOV     Keypress,12
   JMP     Store
Key_Is_E0_2:
   CMP     AL,49H
   JNE     Key_Is_E0_3
   MOV     Keypress,13
   JMP     Store
Key_Is_E0_3:
   CMP     AL,48H
   JNE     Key_Is_E0_4
   MOV     Keypress,14
   JMP     Store
Key_Is_E0_4:
   CMP     AL,51H
   JNE     Key_Is_E0_5
   MOV     Keypress,15
   JMP     Store
Key_Is_E0_5:
   CMP     AL,53H
   JNE     Key_Is_E0_6
   MOV     Keypress,26
   JMP     Store
Key_Is_E0_6:
   CMP     AL,4FH
   JNE     Key_Is_E0_7
   MOV     Keypress,27
   JMP     Store
Key_Is_E0_7:
   CMP     AL,4BH
   JNE     Key_Is_E0_8
   MOV     Keypress,28
   JMP     Store
Key_Is_E0_8:
   CMP     AL,50H
   JNE     Key_Is_E0_9
   MOV     Keypress,29
   JMP     Store
Key_Is_E0_9:
   CMP     AL,4DH
   JNE     Key_Is_E0_10
   MOV     Keypress,30
   JMP     Store
Key_Is_E0_10:
   CMP     AL,1CH
   JNE     Key_Is_E0_11
   MOV     Keypress,104
   JMP     Store
Key_Is_E0_11:
   JMP     Drop_Code

; Check what is the next scan code after 36H

Key_Is_36:
   CMP     AL,2H
   JB      Key_Is_36_1
   CMP     AL,0CH
   JA      Key_Is_36_1
   ADD     AL,30
   MOV     keypress,AL
   JMP     Store
Key_Is_36_1:
   CMP     AL,1AH
   JNE     Key_Is_36_2
   MOV     keypress,21
   JMP     Store
Key_Is_36_2:
   CMP     AL,1BH
   JNE     Key_Is_36_3
   MOV     keypress,22
   JMP     Store
Key_Is_36_3:
   CMP     AL,33H
   JNE     Key_Is_36_4
   MOV     keypress,23
   JMP     Store
Key_Is_36_4:
   CMP     AL,34H
   JNE     Key_Is_36_5
   MOV     keypress,24
   JMP     Store
Key_Is_36_5:
   CMP     AL,35H
   JNE     Key_Is_36_6
   MOV     keypress,25
   JMP     Store
Key_Is_36_6:
   CMP     AL,27H
   JNE     Key_Is_36_7
   MOV     keypress,70
   JMP     Store
Key_Is_36_7:
   CMP     AL,28H
   JNE     Key_Is_36_8
   MOV     keypress,100
   JMP     Store
Key_Is_36_8:
   CMP     AL,29H
   JNE     Key_Is_36_9
   MOV     keypress,93
   JMP     Store
Key_Is_36_9:
   CMP     AL,2BH
   JNE     Key_Unknown
   MOV     Keypress,97
   JMP     STore
Key_Unknown:
   JMP     Drop_code
   
Store:
   STI
   MOV     AL,keypress
   MOV     AH,05H
   MOV     CH,keypress
   MOV     CL,keypress
   INT     16H
   CLI
Drop_code:
   AND     key36,0
   AND     keyE0,0
   AND     keypress,0
   XOR     AL,AL
   POP     BX
   POP     CX
   POPF
   CLC
   PUSHF
   PUSH    CX
   PUSH    BX
   ;IRET
   JMP     DWORD PTR CS:KeyInt
GOOD_BYE:
   XOR     AL,AL
   AND     keypress,0
   ;IRET
   JMP     DWORD PTR CS:KeyInt

; The following bytes are for the original Int 15 routine.  It is necessary
; for it to be here because of the JMP hook at the end of the Pass section
; of the new interrupt handler.

KeyInt      DW      0000,0000           ;Address for old keyboard routine


NewInt15    ENDP


_keyhook     PROC   FAR
   MOV    AL,15H
   MOV    AH,35H
   INT    21H
   MOV    CS:KEYINT[0],BX
   MOV    CS:KEYINT[2],ES

   PUSH    DS                  ;Store data segment
   MOV     AX,CS               ;New segment address
   MOV     DS,AX
   MOV     DX,OFFSET NewInt15  ;New offset address
   MOV     AL,15h              ;Change keyboard vector
   MOV     AH,25h              ;to point to new handler
   INT     21h
   POP     DS                  ;Restore data segment
   RET

_keyhook     ENDP


_keyunhook   PROC    FAR
   PUSH    DS                  ;Store for later
   MOV     DX,CS:KeyInt[0]     ;Get offset address
   MOV     AX,CS:KeyInt[2]     ;Get segment address
   MOV     DS,AX
   MOV     AL,15h              ;Change keyboard vector
   MOV     AH,25h              ;to point to old interrupt
   INT     21h
   POP     DS                  ;Restore data segment
   RET
_keyunhook   ENDP


END
