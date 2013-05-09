
.model large
.stack 100h

extrn limerick:far

.code

main:
        mov     ax,DGROUP
        mov     ds,ax
        call    limerick
        mov     ax,4c00h
        int     21h

end


