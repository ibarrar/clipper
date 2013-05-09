;
;       Sdxdyn.asm
;
;       Dummy dyn-link for module 'SDX'
;
;       Copyright (c) 1993, Computer Associates International, Inc.
;       All rights reserved.
;
;

        NAME    SDXDYN                          ; Name of the module (OBJ)
	.MODEL	LARGE, PASCAL


        ; Hard-link hook - this is the public name of your RDD
        PUBLIC  _SDX

        ; External entry points
        EXTRN   SDXINIT:PROC                    ; Must be pascal call!
        EXTRN   SDXGETFUNCTABLE:PROC

        ; Data definitions
        .DATA

_SDX    LABEL   WORD                            ; Must match hard link hook
        DB      "SDX", 0                        ; Name of RDD (for Clipper)

; Strings for dummy dyn link names, format: (Length, "string")
;
strModule  DB       3, "SDX"                    ; Module name for load

; Ordinal list
; Note that names of entry points need not match their actual function names.
;
strEntry1  DB       12, "GETFUNCTABLE"

; Dummy dynlink header data
;
ModuleInfo LABEL WORD
           DD       DGROUP:strModule            ; Module name length + name
           DD       SDXINIT                     ; Init entry (void pascal)
           DW       1                           ; Number of entry points
           DW       0                           ; Reference count (always zero)

; Ordinal entry points
;
           DD       DGROUP:strEntry1            ; Module name length + name
           DD       SDXGETFUNCTABLE             ; Address of external entry


; Put everything in a DLL segment
;
DMTB       SEGMENT  WORD PUBLIC 'DLL'           ; Define Beginning Segment
DMTB       ENDS

DMT        SEGMENT  WORD PUBLIC 'DLL'           ; Dummy DLL header goes here
           DD       DGROUP:ModuleInfo           ; Dummy DLL header
DMT        ENDS

DMTE       SEGMENT  WORD PUBLIC 'DLL'           ; Define Ending Segment
DMTE       ENDS

END


