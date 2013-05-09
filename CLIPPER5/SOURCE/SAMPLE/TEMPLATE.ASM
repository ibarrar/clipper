PUBLIC               <func_name>
EXTRN                <exten_func>:FAR
DGROUP               GROUP   <data_seg>

<data_seg>   SEGMENT PUBLIC  'DATA'
;
;    <your data declarations>
;
<data_seg>   ENDS

<code_seg>   SEGMENT 'CODE'
             ASSUME cs:<code_seg>, ds:DGROUP

<func_name>  PROC    FAR

             push    bp              ; Save registers
             mov     bp,sp
             push    ds
             push    es
             push    si
             push    di

<your code goes here>

             pop     di              ; Restore registers
             pop     si
             pop     es
             pop     ds
             pop     bp

<func_name>  ENDP                    ; End of routine

<code_seg>   ENDS                    ; End of code segment
             END


