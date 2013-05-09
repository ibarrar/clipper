;
;       Extasm.inc
;
;       Clipper Extend System definitions for assembly language
;
;       Copyright (c) 1990-1993, Computer Associates International, Inc.
;       All rights reserved.
;
        extrn   __parinfo:far
        extrn   __parinfa:far
        extrn   __parc:far
        extrn   __parclen:far
        extrn   __parni:far
        extrn   __parnl:far
        extrn   __parnd:far
        extrn   __pards:far
        extrn   __parl:far

        extrn   __storc:far
        extrn   __storclen:far
        extrn   __storni:far
        extrn   __stornl:far
        extrn   __stornd:far
        extrn   __stords:far
        extrn   __storl:far

        extrn   __retc:far
        extrn   __retclen:far
        extrn   __retni:far
        extrn   __retnl:far
        extrn   __retnd:far
        extrn   __retds:far
        extrn   __retl:far
        extrn   __ret:far

        extrn   __xalloc:far
        extrn   __xfree:far
        extrn   __xgrab:far


	; Extend System type codes

UNDEF       equ     0h
CHARACTER   equ     1h
NUMERIC     equ     2h
LOGICAL     equ     4h
DATE        equ     8h
MPTR        equ     20h
MEMO        equ     41h
ARRAY       equ     200h

