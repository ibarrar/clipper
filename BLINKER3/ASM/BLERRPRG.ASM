
PAGE      60,132

; €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
; €€                                                                                             €€
; €€      92.03.14            BLINKER                                                            €€
; €€                                                                                             €€
; €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

.model    large

title     BLERRPRG.ASM        BLINKER overlay manager error handler for ASM

extrn     _BLIERRNUM:far                          ; Get error number procedure


; €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
; €                 Constant data                                                                 €
; €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

.data             

ovlerrmsg db        'BLINKER ' 
ovlerrnum db        '0000 : $'

ovler1201 db        'unable to find overlay file in the current PATH$'
ovler1202 db        'DOS read error in overlay file$'
ovler1203 db        '.EXE file is not a valid .EXE file$'
ovler1204 db        'overlay file does not match the .EXE file$'
ovler1205 db        'not enough memory to load procedure$'
ovler1206 db        'maximum procedure nesting depth exceeded$'
ovler1207 db        'demonstration calls limit exceeded$'
ovler1208 db        'demonstration date limit exceeded$'
ovler1209 db        'demonstration time limit exceeded$'
ovler1210 db        'overlay has been prematurely freed$'
ovler1211 db        'overlay manager stack overflow$'
ovler1212 db        'Overlay Opsize exceeded - increase Opsize$'
ovler1213 db        'attempt to call DEFINED routine$'
ovler1214 db        'error accessing EMS overlay cache$'
ovler1215 db        'error accessing XMS overlay cache$'
ovler1216 db        'overlay manager unable to resume$'
ovler1217 db        'overlay vector corrupted during execution$'

ovlercrlf db        0dh,0ah,'$'

ovlerrtbl dw        offset DGROUP:ovler1201
          dw        offset DGROUP:ovler1202
          dw        offset DGROUP:ovler1203
          dw        offset DGROUP:ovler1204
          dw        offset DGROUP:ovler1205
          dw        offset DGROUP:ovler1206
          dw        offset DGROUP:ovler1207
          dw        offset DGROUP:ovler1208
          dw        offset DGROUP:ovler1209
          dw        offset DGROUP:ovler1210
          dw        offset DGROUP:ovler1211
          dw        offset DGROUP:ovler1212
          dw        offset DGROUP:ovler1213
          dw        offset DGROUP:ovler1214
          dw        offset DGROUP:ovler1215
          dw        offset DGROUP:ovler1216
          dw        offset DGROUP:ovler1217


; €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
; €                 Code segment                                                                  €
; €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

.code        

public    _BLERRPRG                               ; Error handler


; €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
; €                 ASM error handler                                                             €
; €                 -----------------                                                             €
; €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

_BLERRPRG proc      far
          call      _BLIERRNUM                    ; Get the error number
          mov       bx,DGROUP                     ; Default data segment
          mov       ds,bx                         ; Set it up
          mov       es,bx                         ; Set it up as destination
          mov       bx,ax                         ; Save error number here
          mov       di,offset DGROUP:ovlerrnum    ; Temporary buffer
          mov       cx,3                          ; Width 4
          call      strfmtdec                     ; Format the decimal number
          mov       ah,9                          ; Display a string
          mov       dx,offset DGROUP:ovlerrmsg    ; Point to the string
          int       21h                           ; Display it
          sub       bx,1201d                      ; Relative to zero
          shl       bx,1                          ; Word offset
          mov       dx,ovlerrtbl [bx]             ; Get offset of error message
          mov       ah,9                          ; Display a string
          int       21h                           ; Display it
          mov       ah,9                          ; Display a string
          mov       dx,offset DGROUP:ovlercrlf    ; Carriage return, line feed
          int       21h                           ; Display it
          mov       ax,4cffh                      ; Terminate with error code -1
          int       21h                           ; The end
_BLERRPRG endp


; €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
; €                 Format a decimal number                                                       €
; €                 -----------------------                                                       €
; €       P :                                                                                     €
; €                 AX    =  Number                                                               €
; €                 CX    =  Field width                                                          €
; €                 ES:DI -> Destination field                                                    €
; €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

strfmtdec proc      near
          cmp       ax,0Ah                        ; Is it less than 10
          jb        fmtdec010                     ; Yes - the last digit
          push      dx                            ; Save DX
          push      bx                            ; Save BX
          mov       bx,0Ah                        ; Base 10
          sub       dx,dx                         ; Clear high part
          div       bx                            ; Divide by 10
          pop       bx                            ; Restore BX
          dec       cx                            ; One less position
          call      strfmtdec                     ; Display the result
          mov       ax,dx                         ; Remainder
          pop       dx                            ; Restore DX
          jmp       short fmtdec020               ; And finish
fmtdec010:
          cmp       cx,0                          ; Leading zeros
          jle       fmtdec020                     ; No
          push      ax                            ; Save remainder
          mov       al,'0'                        ; Leading zero
          rep       stosb                         ; Write leading zeros
          pop       ax                            ; Restore remainder
fmtdec020:
          add       al,'0'                        ; Convert to ASCII
          stosb                                   ; Save it
          ret                                     ; Done
strfmtdec endp

          end
