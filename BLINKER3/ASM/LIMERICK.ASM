
.model large

public limerick

.data

testmsg   db   'There was a young fellow from Borland'
          db   0dh,0ah,'$'

.code

limerick:
        mov     ah,9
        mov     dx,offset DGROUP:testmsg
        int     21h
        retf

end

