/***
*
*   Reserved.ch
*
*   Header file to check for reserved function names.
*
*   Copyright (c) 1990-1995, Computer Associates International, Inc.
*   All rights reserved.
*
*   Clipper 5.2 defines a number of new functions that didn't
*   exist in previous releases. This header file offers an easy
*   way to check your programs to see if they define functions
*   or procedures whose names collide with those of standard
*   Clipper functions.
*
*   This header simply causes a compiler error to be generated
*   if such a collision is detected, it doesn't correct the
*   problem! To rectify the situation you'll have to decide
*   whether you really mean to redefine the function. If not,
*   change the name of the offending function in your code.
*
*   To use this header, first make sure that the compiler is
*   able to find it, either by copying it into your working
*   directory or by putting it in one of the directories
*   specified in the INCLUDE environment variable. Then
*   compile each of your programs using the following command
*   line option:
*
*      /ureserved.ch
*
*   Example:
*
*      clipper myprog /ureserved.ch
*
*
*   A .CLP file can be used if desired. Example:
*
*      clipper @prglist /ureserved.ch
*
*
*   NOTE: If you get a 3012 compiler error using this header file,
*         then you will need to comment out some #xcommand lines.
*
*   IMPORTANT: the preprocessor can only check names for exact
*   equivalence to the reserved names. The compiler itself,
*   however, treats names as equivalent if the first ten
*   characters match. If you have a function or procedure that
*   that collides with a reserved name because of the ten
*   character rule, this header may not catch it. As an aid,
*   here is a list of the standard functions whose names are
*   ten or more characters in length:
*
*   COLORSELECT
*   DBCLEARFILTER
*   DBCLEARINDEX
*   DBCLEARRELATION
*   DBCLOSEALL
*   DBCLOSEAREA
*   DBCOMMITALL
*   DBCREATEINDEX
*   DBFIELDINFO
*   DBGOBOTTOM
*   DBORDERINFO
*   DBRECORDINFO
*   DBRELATION
*   DBSELECTAREA
*   DBSETDRIVER
*   DBSETFILTER
*   DBSETINDEX
*   DBSETORDER
*   DBSETRELATION
*   DBUNLOCKALL
*   DEVOUTPICT
*   ERRORBLOCK
*   ERRORINHANDLER
*   ERRORLEVEL
*   FIELDBLOCK
*   FIELDWBLOCK
*   GETAPPLYKEY
*   GETDOSETKEY
*   GETPOSTVALIDATE
*   GETPREVALIDATE
*   MEMVARBLOCK
*   ORDBAGNAME
*   ORDCONDSET
*   ORDDESTROY
*   ORDLISTADD
*   ORDLISTCLEAR
*   ORDLISTREBUILD
*   ORDSETFOCUS
*   RANGECHECK
*   PARSEHEADER
*   RDDREGISTER
*   RDDSETDEFAULT
*   READFORMAT
*   READINSERT
*   RESTSCREEN
*   READUPDATED
*   SAVESCREEN
*   SETTYPEAHEAD
*   TBCOLUMNNEW
*   TBROWSENEW
*   =================
*/

// This keeps the compiler from generating an object file.
// (This header would make for a bad object file.)
#error (Ignore this error...)


// include Std.ch so normal commands won't give errors
#include "Std.ch"


// translate all variations of FUNCTION and PROCEDURE to
// simply PROC <name>

// Uncomment the correct style that you are using:

#xcommand FUNCTION <name> ([ <params,...>])                             ;
       => PROC <name>

//#xcommand FUNCTIO  <name> ([ <params,...> ])                            ;
//       => PROC <name>

//#xcommand FUNCTI   <name> ([ <params,...> ])                            ;
//       => PROC <name>

//#xcommand FUNCT    <name> ([ <params,...> ])                            ;
//       => PROC <name>

//#xcommand FUNC     <name> ([ <params,...> ])                            ;
//       => PROC <name>

//#xcommand FUNCTION <name>                                               ;
//       => PROC <name>

//#xcommand FUNCTIO  <name>                                               ;
//       => PROC <name>

//#xcommand FUNCTI   <name>                                               ;
//       => PROC <name>

//#xcommand FUNCT    <name>                                               ;
//       => PROC <name>

//#xcommand FUNC     <name>                                               ;
//       => PROC <name>


#xcommand PROCEDURE <name> ([ <params,...> ])                           ;
       => PROC <name>

//#xcommand PROCEDURE <name> ([ <params,...> ])                           ;
//       => PROC <name>

//#xcommand PROCEDUR  <name> ([ <params,...> ])                           ;
//       => PROC <name>

//#xcommand PROCEDU   <name> ([ <params,...> ])                           ;
//       => PROC <name>

//#xcommand PROCED    <name> ([ <params,...> ])                           ;
//       => PROC <name>

//#xcommand PROCE     <name> ([ <params,...> ])                           ;
//       => PROC <name>

//#xcommand PROCEDURE <name>                                              ;
//       => PROC <name>

//#xcommand PROCEDURE <name>                                              ;
//       => PROC <name>

//#xcommand PROCEDUR  <name>                                              ;
//       => PROC <name>

//#xcommand PROCEDU   <name>                                              ;
//       => PROC <name>

//#xcommand PROCED    <name>                                              ;
//       => PROC <name>

//#xcommand PROCE     <name>                                              ;
//       => PROC <name>


// These functions are reserved but not "built in" to the compiler
// If you redefine one of these, you'll probably wish you hadn't.

#xcommand PROC ACHOICE         => PROC _ACHOICE         ; #error ACHOICE
#xcommand PROC ACLONE          => PROC _ACLONE          ; #error ACLONE
#xcommand PROC ACOPY           => PROC _ACOPY           ; #error ACOPY
#xcommand PROC ADEL            => PROC _ADEL            ; #error ADEL
#xcommand PROC ADIR            => PROC _ADIR            ; #error ADIR
#xcommand PROC AEVAL           => PROC _AEVAL           ; #error AEVAL
#xcommand PROC AFIELDS         => PROC _AFIELDS         ; #error AFIELDS
#xcommand PROC AFILL           => PROC _AFILL           ; #error AFILL
#xcommand PROC AINS            => PROC _AINS            ; #error AINS
#xcommand PROC ALERT           => PROC _ALERT           ; #error ALERT
#xcommand PROC ALIAS           => PROC _ALIAS           ; #error ALIAS
#xcommand PROC ALLTRIM         => PROC _ALLTRIM         ; #error ALLTRIM
#xcommand PROC ALTD            => PROC _ALTD            ; #error ALTD
#xcommand PROC ARRAY           => PROC _ARRAY           ; #error ARRAY
#xcommand PROC ASCAN           => PROC _ASCAN           ; #error ASCAN
#xcommand PROC ASIZE           => PROC _ASIZE           ; #error ASIZE
#xcommand PROC ASORT           => PROC _ASORT           ; #error ASORT
#xcommand PROC ATAIL           => PROC _ATAIL           ; #error ATAIL
#xcommand PROC BIN2I           => PROC _BIN2I           ; #error BIN2I
#xcommand PROC BIN2L           => PROC _BIN2L           ; #error BIN2L
#xcommand PROC BIN2W           => PROC _BIN2W           ; #error BIN2W
#xcommand PROC CURDIR          => PROC _CURDIR          ; #error CURDIR
#xcommand PROC DBAPPEND        => PROC _DBAPPEND        ; #error DBAPPEND
#xcommand PROC DBCLEARFILTER   => PROC _DBCLEARFILTER   ; #error DBCLEARFILTER
#xcommand PROC DBCLEARINDEX    => PROC _DBCLEARINDEX    ; #error DBCLEARINDEX
#xcommand PROC DBCLEARRELATION => PROC _DBCLEARRELATION ; #error DBCLEARRELATION
#xcommand PROC DBCLOSEALL      => PROC _DBCLOSEALL      ; #error DBCLOSEALL
#xcommand PROC DBCLOSEAREA     => PROC _DBCLOSEAREA     ; #error DBCLOSEAREA
#xcommand PROC DBCOMMIT        => PROC _DBCOMMIT        ; #error DBCOMMIT
#xcommand PROC DBCOMMITALL     => PROC _DBCOMMITALL     ; #error DBCOMMITALL
#xcommand PROC DBCREATE        => PROC _DBCREATE        ; #error DBCREATE
#xcommand PROC DBCREATEINDEX   => PROC _DBCREATEINDEX   ; #error DBCREATEINDEX
#xcommand PROC DBDELETE        => PROC _DBDELETE        ; #error DBDELETE
#xcommand PROC DBEDIT          => PROC _DBEDIT          ; #error DBEDIT
#xcommand PROC DBEVAL          => PROC _DBEVAL          ; #error DBEVAL
#xcommand PROC DBFILTER        => PROC _DBFILTER        ; #error DBFILTER
#xcommand PROC DBGOBOTTOM      => PROC _DBGOBOTTOM      ; #error DBGOBOTTOM
#xcommand PROC DBGOTO          => PROC _DBGOTO          ; #error DBGOTO
#xcommand PROC DBGOTOP         => PROC _DBGOTOP         ; #error DBGOTOP
#xcommand PROC DBRECALL        => PROC _DBRECALL        ; #error DBRECALL
#xcommand PROC DBREINDEX       => PROC _DBREINDEX       ; #error DBREINDEX
#xcommand PROC DBRELATION      => PROC _DBRELATION      ; #error DBRELATION
#xcommand PROC DBRSELECT       => PROC _DBRSELECT       ; #error DBRSELECT
#xcommand PROC DBSEEK          => PROC _DBSEEK          ; #error DBSEEK
#xcommand PROC DBSELECTAREA    => PROC _DBSELECTAREA    ; #error DBSELECTAREA
#xcommand PROC DBSETDRIVER     => PROC _DBSETDRIVER     ; #error DBSETDRIVER
#xcommand PROC DBSETFILTER     => PROC _DBSETFILTER     ; #error DBSETFILTER
#xcommand PROC DBSETINDEX      => PROC _DBSETINDEX      ; #error DBSETINDEX
#xcommand PROC DBSETORDER      => PROC _DBSETORDER      ; #error DBSETORDER
#xcommand PROC DBSETRELATION   => PROC _DBSETRELATION   ; #error DBSETRELATION
#xcommand PROC DBSKIP          => PROC _DBSKIP          ; #error DBSKIP
#xcommand PROC DBSTRUCT        => PROC _DBSTRUCT        ; #error DBSTRUCT
#xcommand PROC DBUNLOCK        => PROC _DBUNLOCK        ; #error DBUNLOCK
#xcommand PROC DBUNLOCKALL     => PROC _DBUNLOCKALL     ; #error DBUNLOCKALL
#xcommand PROC DBUSEAREA       => PROC _DBUSEAREA       ; #error DBUSEAREA
#xcommand PROC DESCEND         => PROC _DESCEND         ; #error DESCEND
#xcommand PROC DEVOUT          => PROC _DEVOUT          ; #error DEVOUT
#xcommand PROC DEVOUTPICT      => PROC _DEVOUTPICT      ; #error DEVOUTPICT
#xcommand PROC DIRECTORY       => PROC _DIRECTORY       ; #error DIRECTORY
#xcommand PROC DISKSPACE       => PROC _DISKSPACE       ; #error DISKSPACE
#xcommand PROC DISPBEGIN       => PROC _DISPBEGIN       ; #error DISPBEGIN
#xcommand PROC DISPBOX         => PROC _DISPBOX         ; #error DISPBOX
#xcommand PROC DISPEND         => PROC _DISPEND         ; #error DISPEND
#xcommand PROC DISPOUT         => PROC _DISPOUT         ; #error DISPOUT
#xcommand PROC DOSERROR        => PROC _DOSERROR        ; #error DOSERROR
#xcommand PROC ERRORBLOCK      => PROC _ERRORBLOCK      ; #error ERRORBLOCK
#xcommand PROC ERRORLEVEL      => PROC _ERRORLEVEL      ; #error ERRORLEVEL
#xcommand PROC ERRORNEW        => PROC _ERRORNEW        ; #error ERRORNEW
#xcommand PROC FCLOSE          => PROC _FCLOSE          ; #error FCLOSE
#xcommand PROC FCREATE         => PROC _FCREATE         ; #error FCREATE
#xcommand PROC FERASE          => PROC _FERASE          ; #error FERASE
#xcommand PROC FERROR          => PROC _FERROR          ; #error FERROR
#xcommand PROC FIELDBLOCK      => PROC _FIELDBLOCK      ; #error FIELDBLOCK
#xcommand PROC FIELDGET        => PROC _FIELDGET        ; #error FIELDGET
#xcommand PROC FIELDPOS        => PROC _FIELDPOS        ; #error FIELDPOS
#xcommand PROC FIELDPUT        => PROC _FIELDPUT        ; #error FIELDPUT
#xcommand PROC FIELDWBLOCK     => PROC _FIELDWBLOCK     ; #error FIELDWBLOCK
#xcommand PROC FILE            => PROC _FILE            ; #error FILE
#xcommand PROC FOPEN           => PROC _FOPEN           ; #error FOPEN
#xcommand PROC FREAD           => PROC _FREAD           ; #error FREAD
#xcommand PROC FREADSTR        => PROC _FREADSTR        ; #error FREADSTR
#xcommand PROC FRENAME         => PROC _FRENAME         ; #error FRENAME
#xcommand PROC FSEEK           => PROC _FSEEK           ; #error FSEEK
#xcommand PROC FWRITE          => PROC _FWRITE          ; #error FWRITE
#xcommand PROC GETACTIVE       => PROC _GETACTIVE       ; #error GETACTIVE
#xcommand PROC GETAPPLYKEY     => PROC _GETAPPLYKEY     ; #error GETAPPLYKEY
#xcommand PROC GETDOSETKEY     => PROC _GETDOSETKEY     ; #error GETDOSETKEY
#xcommand PROC GETE            => PROC _GETE            ; #error GETE
#xcommand PROC GETENV          => PROC _GETENV          ; #error GETENV
#xcommand PROC GETNEW          => PROC _GETNEW          ; #error GETNEW
#xcommand PROC GETPOSTVALIDATE => PROC _GETPOSTVALIDATE ; #error GETPOSTVALIDATE
#xcommand PROC GETPREVALIDATE  => PROC _GETPREVALIDATE  ; #error GETPREVALIDATE
#xcommand PROC GETREADER       => PROC _GETREADER       ; #error GETREADER
#xcommand PROC HARDCR          => PROC _HARDCR          ; #error HARDCR
#xcommand PROC HEADER          => PROC _HEADER          ; #error HEADER
#xcommand PROC I2BIN           => PROC _I2BIN           ; #error I2BIN
#xcommand PROC INDEXEXT        => PROC _INDEXEXT        ; #error INDEXEXT
#xcommand PROC INDEXKEY        => PROC _INDEXKEY        ; #error INDEXKEY
#xcommand PROC INDEXORD        => PROC _INDEXORD        ; #error INDEXORD
#xcommand PROC ISALPHA         => PROC _ISALPHA         ; #error ISALPHA
#xcommand PROC ISCOLOR         => PROC _ISCOLOR         ; #error ISCOLOR
#xcommand PROC ISDIGIT         => PROC _ISDIGIT         ; #error ISDIGIT
#xcommand PROC ISLOWER         => PROC _ISLOWER         ; #error ISLOWER
#xcommand PROC ISPRINTER       => PROC _ISPRINTER       ; #error ISPRINTER
#xcommand PROC ISUPPER         => PROC _ISUPPER         ; #error ISUPPER
#xcommand PROC L2BIN           => PROC _L2BIN           ; #error L2BIN
#xcommand PROC LASTKEY         => PROC _LASTKEY         ; #error LASTKEY
#xcommand PROC LEFT            => PROC _LEFT            ; #error LEFT
#xcommand PROC LUPDATE         => PROC _LUPDATE         ; #error LUPDATE
#xcommand PROC MAXCOL          => PROC _MAXCOL          ; #error MAXCOL
#xcommand PROC MAXROW          => PROC _MAXROW          ; #error MAXROW
#xcommand PROC MEMOEDIT        => PROC _MEMOEDIT        ; #error MEMOEDIT
#xcommand PROC MEMOLINE        => PROC _MEMOLINE        ; #error MEMOLINE
#xcommand PROC MEMOREAD        => PROC _MEMOREAD        ; #error MEMOREAD
#xcommand PROC MEMORY          => PROC _MEMORY          ; #error MEMORY
#xcommand PROC MEMOTRAN        => PROC _MEMOTRAN        ; #error MEMOTRAN
#xcommand PROC MEMOWRIT        => PROC _MEMOWRIT        ; #error MEMOWRIT
#xcommand PROC MEMVARBLOCK     => PROC _MEMVARBLOCK     ; #error MEMVARBLOCK
#xcommand PROC MLCOUNT         => PROC _MLCOUNT         ; #error MLCOUNT
#xcommand PROC MLCTOPOS        => PROC _MLCTOPOS        ; #error MLCTOPOS
#xcommand PROC MLPOS           => PROC _MLPOS           ; #error MLPOS
#xcommand PROC MPOSTOLC        => PROC _MPOSTOLC        ; #error MPOSTOLC
#xcommand PROC NETERR          => PROC _NETERR          ; #error NETERR
#xcommand PROC NETNAME         => PROC _NETNAME         ; #error NETNAME
#xcommand PROC NEXTKEY         => PROC _NEXTKEY         ; #error NEXTKEY
#xcommand PROC NOSNOW          => PROC _NOSNOW          ; #error NOSNOW
#xcommand PROC OS              => PROC _OS              ; #error OS
#xcommand PROC OUTERR          => PROC _OUTERR          ; #error OUTERR
#xcommand PROC OUTSTD          => PROC _OUTSTD          ; #error OUTSTD
#xcommand PROC PAD             => PROC _PAD             ; #error PAD
#xcommand PROC PADC            => PROC _PADC            ; #error PADC
#xcommand PROC PADL            => PROC _PADL            ; #error PADL
#xcommand PROC PADR            => PROC _PADR            ; #error PADR
#xcommand PROC PROCLINE        => PROC _PROCLINE        ; #error PROCLINE
#xcommand PROC PROCNAME        => PROC _PROCNAME        ; #error PROCNAME
#xcommand PROC QOUT            => PROC _QOUT            ; #error QOUT
#xcommand PROC QQOUT           => PROC _QQOUT           ; #error QQOUT
#xcommand PROC RANGECHECK      => PROC _RANGECHECK      ; #error RANGECHECK
#xcommand PROC RAT             => PROC _RAT             ; #error RAT
#xcommand PROC READEXIT        => PROC _READEXIT        ; #error READEXIT
#xcommand PROC READINSERT      => PROC _READINSERT      ; #error READINSERT
#xcommand PROC READKEY         => PROC _READKEY         ; #error READKEY
#xcommand PROC READMODAL       => PROC _READMODAL       ; #error READMODAL
#xcommand PROC READVAR         => PROC _READVAR         ; #error READVAR
#xcommand PROC RECSIZE         => PROC _RECSIZE         ; #error RECSIZE
#xcommand PROC RESTSCREEN      => PROC _RESTSCREEN      ; #error RESTSCREEN
#xcommand PROC RIGHT           => PROC _RIGHT           ; #error RIGHT
#xcommand PROC SAVESCREEN      => PROC _SAVESCREEN      ; #error SAVESCREEN
#xcommand PROC SCROLL          => PROC _SCROLL          ; #error SCROLL
#xcommand PROC SET             => PROC _SET             ; #error SET
#xcommand PROC SETBLINK        => PROC _SETBLINK        ; #error SETBLINK
#xcommand PROC SETCANCEL       => PROC _SETCANCEL       ; #error SETCANCEL
#xcommand PROC SETCOLOR        => PROC _SETCOLOR        ; #error SETCOLOR
#xcommand PROC SETCURSOR       => PROC _SETCURSOR       ; #error SETCURSOR
#xcommand PROC SETKEY          => PROC _SETKEY          ; #error SETKEY
#xcommand PROC SETMODE         => PROC _SETMODE         ; #error SETMODE
#xcommand PROC SETPRC          => PROC _SETPRC          ; #error SETPRC
#xcommand PROC SOUNDEX         => PROC _SOUNDEX         ; #error SOUNDEX
#xcommand PROC STRTRAN         => PROC _STRTRAN         ; #error STRTRAN
#xcommand PROC STUFF           => PROC _STUFF           ; #error STUFF
#xcommand PROC TBCOLUMNNEW     => PROC _TBCOLUMNNEW     ; #error TBCOLUMNNEW
#xcommand PROC TBROWSEDB       => PROC _TBROWSEDB       ; #error TBROWSEDB
#xcommand PROC TBROWSENEW      => PROC _TBROWSENEW      ; #error TBROWSENEW
#xcommand PROC TONE            => PROC _TONE            ; #error TONE
#xcommand PROC TRANSFORM       => PROC _TRANSFORM       ; #error TRANSFORM
#xcommand PROC UPDATED         => PROC _UPDATED         ; #error UPDATED
#xcommand PROC USED            => PROC _USED            ; #error USED
#xcommand PROC VERSION         => PROC _VERSION         ; #error VERSION


// These functions are Clipper functions supplied in source code
// in the SAMPLE directory. If you redefine one of these, you're
// probably glad you did.

#xcommand PROC AMPM            => PROC _AMPM            ; #error AMPM
#xcommand PROC BROWSE          => PROC _BROWSE          ; #error BROWSE
#xcommand PROC DAYS            => PROC _DAYS            ; #error DAYS
#xcommand PROC DBF             => PROC _DBF             ; #error DBF
#xcommand PROC ELAPTIME        => PROC _ELAPTIME        ; #error ELAPTIME
#xcommand PROC FKLABEL         => PROC _FKLABEL         ; #error FKLABEL
#xcommand PROC FKMAX           => PROC _FKMAX           ; #error FKMAX
#xcommand PROC LENNUM          => PROC _LENNUM          ; #error LENNUM
#xcommand PROC MOD             => PROC _MOD             ; #error MOD
#xcommand PROC SECS            => PROC _SECS            ; #error SECS
#xcommand PROC STRZERO         => PROC _STRZERO         ; #error STRZERO
#xcommand PROC TSTRING         => PROC _TSTRING         ; #error TSTRING


// This is something you would presumably want to redefine
// (so we've commented it out here).

//#xcommand PROC ERRORSYS      => PROC _ERRORSYS        ; #error ERRORSYS

#xcommand PROC COLORSELECT     => PROC _COLORSELECT     ; #error COLORSELECT
#xcommand PROC DBFONLY         => PROC _DBFONLY         ; #error DBFONLY
#xcommand PROC DBGSHADOW       => PROC _DBGSHADOW       ; #error DBGSHADOW
//There's a _defpath in the same file as defpath - This is only used by adir
#xcommand PROC DEFPATH         => PROC _DEFPATH         ; #error DEFPATH
#xcommand PROC DELIM           => PROC _DELIM           ; #error DELIM
#xcommand PROC DISPCOUNT       => PROC _DISPCOUNT       ; #error DISPCOUNT
#xcommand PROC DISPOUTAT       => PROC _DISPOUTAT       ; #error DISPOUTAT
#xcommand PROC ERRORINHANDLER  => PROC _ERRORINHANDLER  ; #error ERRORINHANDLER
#xcommand PROC ORDBAGEXT       => PROC _ORDBAGEXT       ; #error ORDBAGEXT
#xcommand PROC ORDBAGNAME      => PROC _ORDBAGNAME      ; #error ORDBAGNAME
#xcommand PROC ORDCONDSET      => PROC _ORDCONDSET      ; #error ORDCONDSET
#xcommand PROC ORDCREATE       => PROC _ORDCREATE       ; #error ORDCREATE
#xcommand PROC ORDDESTROY      => PROC _ORDDESTROY      ; #error ORDDESTROY
#xcommand PROC ORDFOR          => PROC _ORDFOR          ; #error ORDFOR
#xcommand PROC ORDKEY          => PROC _ORDKEY          ; #error ORDKEY
#xcommand PROC ORDLISTADD      => PROC _ORDLISTADD      ; #error ORDLISTADD
#xcommand PROC ORDLISTCLEAR    => PROC _ORDLISTCLEAR    ; #error ORDLISTCLEAR
#xcommand PROC ORDLISTREBUILD  => PROC _ORDLISTREBUILD  ; #error ORDLISTREBUILD
#xcommand PROC ORDNAME         => PROC _ORDNAME         ; #error ORDNAME
#xcommand PROC ORDNUMBER       => PROC _ORDNUMBER       ; #error ORDNUMBER
#xcommand PROC ORDSETFOCUS     => PROC _ORDSETFOCUS     ; #error ORDSETFOCUS
#xcommand PROC PARSEHEADER     => PROC _PARSEHEADER     ; #error PARSEHEADER
#xcommand PROC RDDLIST         => PROC _RDDLIST         ; #error RDDLIST
#xcommand PROC RDDNAME         => PROC _RDDNAME         ; #error RDDNAME
#xcommand PROC RDDSYS          => PROC _RDDSYS          ; #error RDDSYS
#xcommand PROC RDDREGISTER     => PROC _RDDREGISTER     ; #error RDDREGISTER
#xcommand PROC RDDSETDEFAULT   => PROC _RDDSETDEFAULT   ; #error RDDSETDEFAULT
#xcommand PROC READFORMAT      => PROC _READFORMAT      ; #error READFORMAT
#xcommand PROC READKILL        => PROC _READKILL        ; #error READKILL
#xcommand PROC READUPDATED     => PROC _READUPDATED     ; #error READUPDATED
#xcommand PROC SDF             => PROC _SDF             ; #error SDF
#xcommand PROC SETTYPEAHEAD    => PROC _SETTYPEAHEAD    ; #error SETTYPEAHEAD
#xcommand PROC SYSINIT         => PROC _SYSINIT         ; #error SYSINIT

