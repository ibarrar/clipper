;
;   Extenda.inc
;
;   Clipper Summer87 Extend System definitions
;
;   Copyright (c) 1987-1993, Computer Associates International, Inc.
;   All rights reserved.
;


.XLIST
;.LALL

$gen macro p1
p1
endm

$err macro m
  if2
    .err
    %out (m)
  endif
endm


SES macro p1, p2
  $gen <		MOV	WORD PTR p2[2], ES>
  $gen <		MOV	WORD PTR p2, p1>
endm

SDS macro p1, p2
  $gen <		MOV	WORD PTR p2[2], DS>
  $gen <		MOV	WORD PTR p2, p1>
endm


DOSREQ macro p1
  $gen <		MOV	AH, p1>
  $gen <		INT	021H>
endm

$define macro p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14
  $gen <p1		EQU	p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14>
endm


$define PCOUNT		<<[WORD PTR [BP - 2]]>>
$define OFFPART		<<WORD PTR>>
$define SEGPART		<<WORD PTR [2]>>
$define LSW		<<WORD PTR>>
$define MSW		<<WORD PTR [2]>>


$$lev = 0
$$stat = 0
$$work = 0
$$cseg = 0
$$dseg = 0


CLextern macro p1

  irp $$item, <p1>
    $x_&&$$item

  endm
endm

$define $$UNDEF		0
$define $$CHARACTER	1
$define $$NUMERIC	2
$define $$LOGICAL	4
$define $$DATE		8
$define $$ALIAS		16
$define $$MPTR		32
$define $$MEMO		65
$define $$WORD		128
$define $$ARRAY		512

CLextern <far _parinfo, far _parinfa, far _parc, far _parcsiz, far _parclen>
CLextern <far _parni, far _parnl, far _parnd, far _parl, far _pards>

CLextern <far _retc, far _retclen, far _retni, far _retnl>
CLextern <far _retnd, far _retl, far _retds, far _ret>

$cass macro
endm

$dass macro
endm

$cseg macro p1
  if $$cseg
    $err <already have CODESEG>

  else
    $cbeg macro
      $gen <p1		SEGMENT	BYTE PUBLIC 'CODE'>
    endm

    $cass macro
      $gen <		ASSUME	CS:&p1, DS:NOTHING, ES:NOTHING>
    endm

    $cend macro
      $gen <p1		ENDS>
    endm

    $$cseg = 1

  endif
endm

CODESEG macro p1
  ifnb <p1>
    $cseg p1&_TEXT

  else
    $result macro p2
      $cseg p2&&_TEXT
    endm

    $result %@fileName
    purge $result

  endif
endm

$dseg macro p1
  if $$dseg
    $err <already have DATASEG>

  else
    $gen <DGROUP		GROUP	p1>

    $dbeg macro
      $gen <p1		SEGMENT	WORD PUBLIC 'DATA'>
    endm

    $dass macro
      $gen <		ASSUME	DS:DGROUP, ES:NOTHING>
    endm

    $dend macro
      $gen <p1		ENDS>
    endm

    $$dseg = 1
  endif
endm

DATASEG macro p1
  ifnb <p1>
    $dseg p1

  else
    $dseg _DATA

  endif
endm

$static macro
  if $$dseg EQ 0
    $err <STATIC w/o DATASEG>

  else
    if $$lev EQ 3
      $err <STATIC within CLfunc must precede CLcode>

    else
      if $$stat EQ 0
        $dbeg
        $dass
        $$stat = 1
      endif

    endif

  endif
endm

$endstatic macro
  if $$stat
    $dend
    $$stat = 0
  endif
endm

CLstatic macro p1
  $static

  ifb <p1>
  else
    irp $$item, <p1>
      $s_&&$$item

    endm
  endif
endm

$s_byte macro p1, p2
  $gen <p1&_BYTE$	=	1>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DB	p2>

      else
	$gen <_&&$$item		DB	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DB	p2>

      else
	$gen <$$item		DB	0>

      endif
    endif

  endm
endm

$s_len macro p1, p2

  irp $$item, <p2>
    ifdef $$item&&_PUBLIC$
      $gen <p1		EQU	$-_&&$$item>

    else
      $gen <p1		EQU	$-&&$$item>

    endif

  endm
endm

$s_int macro p1, p2
  $gen <p1&_BYTE$	=	2>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DW	p2>

      else
	$gen <_&&$$item		DW	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DW	p2>

      else
	$gen <$$item		DW	0>

      endif
    endif

  endm
endm

$s_log macro p1, p2
  $s_int p1, <p2>
endm

$s_long macro p1, p2
  $gen <p1&_BYTE$	=	4>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DD	p2>

      else
	$gen <_&&$$item		DD	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DD	p2>

      else
	$gen <$$item		DD	0>

      endif
    endif

  endm
endm

$s_double macro p1, p2
  $gen <p1&_BYTE$	=	8>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DQ	p2>

      else
	$gen <_&&$$item		DQ	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DQ	p2>

      else
	$gen <$$item		DQ	0>

      endif
    endif

  endm
endm

$s_cptr macro p1, p2
  $gen <p1&_BYTE$	=	4>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DD	DGROUP:p2>

      else
	$gen <_&&$$item		DD	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DD	DGROUP:p2>

      else
	$gen <$$item		DD	0>

      endif
    endif
  endm

  $gen <p1&_OFF		EQU	WORD PTR p1>
  $gen <p1&_SEG		EQU	WORD PTR p1[2]>
  $gen <p1&_OFF_BYTE$		=	2>
  $gen <p1&_SEG_BYTE$		=	2>

endm

$s_string macro p1, p2
  $gen <p1&_BYTE$	=	1>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      ifnb <p2>
	$gen <_&&$$item		DB	p2,0>

      else
	$gen <_&&$$item		DB	0>

      endif

    else
      ifnb <p2>
	$gen <$$item		DB	p2,0>

      else
	$gen <$$item		DB	0>

      endif
    endif

  endm
endm

WORKFUNCS macro
  if $$lev
    $err <WORKFUNCS within CLfunc/CLret>

  else
    if $$stat
      $endstatic
    endif

    if $$cseg EQ 0
      CODESEG
    endif

    if $$work EQ 0
      $cbeg
      $cass
      $dass
      $$work = 1
    endif

  endif
endm

ENDWORK macro
  if $$work
    $cend
    $$work = 0
  endif
endm

$func macro p1
  if $$stat
    $endstatic
  endif

  if $$work
    ENDWORK
  endif

  if $$cseg EQ 0
    CODESEG
  endif

  if $$lev
    $err <nested CLfunc>

  else
    $$lev = 2

    $entry macro
      $gen <p1		PROC	FAR>
    endm

    $$pb = 10
    $$tb = 2

    $exit macro
      $gen <p1		ENDP>
    endm

  endif
endm

CLfunc macro p1, p2, p3
  $&p1
  $func p2

  $define $$pl	<<p3>>

  ifnb <p3>
    $$lev = 2

    irp $$item, <p3>
      $&&$$item

    endm
  endif
endm

$temp macro

  if ($$lev GE 1) AND ($$lev LE 2)
    $$lev = 2

  else
    $err <CLlocal w/o CLfunc>

  endif
endm

CLlocal macro p1
  $temp

  irp $$item, <p1>
    $&&$$item

  endm
endm

CLcode macro

  if ($$lev GE 1) AND ($$lev LE 2)
    $cbeg
    $cass
    $dass
    $entry
    $gen <		PUSH	BP>
    $gen <		PUSH	SI>
    $gen <		PUSH	DI>
    $gen <		MOV	BP, SP>

    if $$lev EQ 2
      $result macro p4
	$gen <		SUB	SP, p4>
      endm

      $result %$$tb
      purge $result

      $getparam %$$pl

    endif

    purge $entry
    $$lev = 3

  else
    $err <CLcode w/o CLfunc>

  endif
endm

$getparam macro p1
  ifb <p1>
    exitm
  endif

  Ccall	_parinfo <0>
  $gen <		MOV	PCOUNT, AX>
  $gen <		XOR	AX, AX>

  irp $$item, <p1>
    $gen <		INC	AX>
    $gen <		PUSH	AX>

    $p_&&$$item

    $gen <		POP	AX>
  endm
endm

$chktype macro p1
  $gen <		PUSH	AX>

  Ccall	_parinfo <AX>
  $gen <		TEST	AX, p1>

  $gen <		POP	AX>
endm

$p_char macro p1
  LOCAL noparam
  $gen <		MOV	WORD PTR p1, 0>
  $gen <		MOV	WORD PTR p1[2], 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$CHARACTER
  $gen <		JZ	noparam>

  Ccall _parc <AX>
  $gen <		MOV	WORD PTR p1, AX>
  $gen <		MOV	WORD PTR p1[2], DX>
noparam:
endm

$p_int macro p1
  LOCAL noparam
  $gen <		MOV	p1, 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$NUMERIC
  $gen <		JZ	noparam>

  Ccall _parni <AX>
  $gen <		MOV	p1, AX>
noparam:
endm

$p_long macro p1
  LOCAL noparam
  $gen <		MOV	WORD PTR p1, 0>
  $gen <		MOV	WORD PTR p1[2], 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$NUMERIC
  $gen <		JZ	noparam>

  Ccall _parnl <AX>
  $gen <		MOV	WORD PTR p1, AX>
  $gen <		MOV	WORD PTR p1[2], DX>
noparam:
endm

$p_double macro p1
  LOCAL noparam
  $gen <		MOV	WORD PTR p1, 0>
  $gen <		MOV	WORD PTR p1[2], 0>
  $gen <		MOV	WORD PTR p1[4], 0>
  $gen <		MOV	WORD PTR p1[6], 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$NUMERIC
  $gen <		JZ	noparam>

  Ccall _parnd <AX>

  $gen <		PUSH	ES>
  $gen <		MOV	ES, DX>
  $gen <		MOV	BX, AX>

  $gen <		MOV	AX, ES:[BX]>
  $gen <		MOV	WORD PTR p1, AX>
  $gen <		MOV	AX, ES:[BX + 2]>
  $gen <		MOV	WORD PTR p1[2], AX>
  $gen <		MOV	AX, ES:[BX + 4]>
  $gen <		MOV	WORD PTR p1[4], AX>
  $gen <		MOV	AX, ES:[BX + 6]>
  $gen <		MOV	WORD PTR p1[6], AX>

  $gen <		POP	ES>
noparam:
endm

$p_log macro p1
  LOCAL noparam
  $gen <		MOV	p1, 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$LOGICAL
  $gen <		JZ	noparam>

  Ccall _parl <AX>
  $gen <		MOV	p1, AX>
noparam:
endm

$p_date macro p1
  LOCAL noparam
  $gen <		MOV	WORD PTR p1, 0>
  $gen <		MOV	WORD PTR p1[2], 0>
  $gen <		CMP	AX, PCOUNT>
  $gen <		JA	noparam>

  $chktype $$DATE
  $gen <		JZ	noparam>

  Ccall _pards <AX>
  $gen <		MOV	WORD PTR p1, AX>
  $gen <		MOV	WORD PTR p1[2], DX>
noparam:
endm

TESTNUL macro p1
  if (p1&_BYTE$) EQ 4
    $gen <		PUSH	AX>
    $gen <		MOV	AX, WORD PTR p1>
    $gen <		OR	AX, WORD PTR p1[2]>
    $gen <		POP	AX>

  else
    if (p1&_BYTE$) EQ 2
      $gen <		TEST	p1, 0FFFFH>

    else
      if (p1&_BYTE$) EQ 1
	$gen <		TEST	p1, 0FFH>

      else
	$gen <		PUSH	AX>
	$gen <		MOV	AX, WORD PTR p1>
	$gen <		OR	AX, WORD PTR p1[2]>
	$gen <		OR	AX, WORD PTR p1[4]>
	$gen <		OR	AX, WORD PTR p1[6]>
	$gen <		POP	AX>

      endif
    endif
  endif
endm

$treg macro p1

  irp $$reg, <AX, BX, CX, DX, SI, DI, CS, DS, ES, SS, BP, SP>

    ifidni <p1>, <$$reg>
      $$isreg = 1
      exitm
    endif

  endm
endm

$putparam macro p1,p2
  $$q = 0

  irp $$item, <p1>
    $$q = $$q + 1

    if $$q EQ p2
      $$isreg = 0

      $treg <$$item>
      if $$isreg
	$$pval = $$pval + 2
	$gen <		PUSH	$$item>

      else
	ifdef $$item
	  if ($$item&&_BYTE$) EQ 4
	    $$pval = $$pval + 4
	    $gen <		PUSH	WORD PTR $$item[2]>
	    $gen <		PUSH	WORD PTR $$item>

	  else
	    if ($$item&&_BYTE$) EQ 2
	      $$pval = $$pval + 2
	      $gen <		PUSH	$$item>

	    else
	      if ($$item&&_BYTE$) EQ 1
		$$pval = $$pval + 2
		$gen <		PUSH	AX>
		$gen <		MOV	AL, $$item>
		$gen <		MOV	AH, 0>
		$gen <		PUSH	BP>
		$gen <		MOV	BP, SP>
		$gen <		XCHG	AX, [BP + 2]>
		$gen <		POP	BP>

	      else
		$$pval = $$pval + 8
		$gen <		PUSH	WORD PTR $$item[6]>
		$gen <		PUSH	WORD PTR $$item[4]>
		$gen <		PUSH	WORD PTR $$item[2]>
		$gen <		PUSH	WORD PTR $$item>

	      endif
	    endif
	  endif

	else
	  $$pval = $$pval + 2
	  $gen <		PUSH	AX>
	  $gen <		MOV	AX, $$item>
	  $gen <		PUSH	BP>
	  $gen <		MOV	BP, SP>
	  $gen <		XCHG	AX, [BP + 2]>
	  $gen <		POP	BP>

	endif
      endif

      exitm

    endif
  endm
endm

Ccall macro p1,p2
  $$pval = 0

  ifnb <p2>
    $$param_count = 0

    irp $$item, <p2>
      $$param_count = $$param_count + 1

    endm

    $$param = $$param_count

    rept $$param_count
      $putparam <p2>,%$$param
      $$param = $$param - 1

    endm
  endif

  $gen <		CALL	FAR PTR p1>

  if $$pval
    $gen <		ADD	SP,$$pval>

  endif
endm

CLret macro p1,p2

  if $$lev EQ 3

    ifnb <p1>
      $$isreg = 0

      $treg p1
      if $$isreg

	ifnb <p2>
	  if $$rb NE 4
	    $err <Function return mismatch>

	  else
	    Ccall $$rf <p2, p1>

	  endif

	else
	  if ($$rb LT 1) OR ($$rb GT 2)
	    $err <Function return mismatch>

	  else
	    Ccall $$rf <p1>

	  endif
	endif

      else
	if (p1&_BYTE$) NE $$rb
	  $err <Function return mismatch>

	else
	  Ccall $$rf <p1>

	endif
      endif

    else
      if $$rb NE 0
	$err <Function return mismatch>

      else
	Ccall $$rf

      endif
    endif

    if $$tb
      $result macro p4
	$gen <		ADD	SP, p4>
      endm

      $result %$$tb
      purge $result

    endif

    $gen <		POP	DI>
    $gen <		POP	SI>
    $gen <		POP	BP>
    $gen <		RET>
    $exit
    purge $exit
    $cend

  else
    $err <Return w/o CLfunc/CLcode>

  endif

  $$lev = 0
endm

$decl macro p1, p2, p3

  if $$lev EQ 1
    $result macro p4
      $gen <p1		EQU	[p3 PTR [BP + p4]]>
    endm

    $result %$$pb
    purge $result

    $$pb = $$pb + p2

  else
    if $$lev EQ 2
      $$tb = $$tb + p2

      $result macro p4
        $gen <p1		EQU	[p3 PTR [BP - p4]]>
      endm

      $result %$$tb
      purge $result

    else
      $err <decl w/o CLfunc>

    endif
  endif

  ifidni <p3>, <BYTE>
    $gen <p1&_BYTE$	=	1>
  else
    $gen <p1&_BYTE$	=	p2>
  endif

endm

$void macro
  $$rb = 0
  $define $$rf	<<_ret>>
endm

$char macro p1
  ifnb <p1>
    $decl p1, 4, DWORD
  else
    $$rb = 4
    $define $$rf	<<_retc>>
  endif
endm

$int macro p1
  ifnb <p1>
    $decl p1, 2, WORD
  else
    $$rb = 2
    $define $$rf	<<_retni>>
  endif
endm

$long macro p1
  ifnb <p1>
    $decl p1, 4, DWORD
  else
    $$rb = 4
    $define $$rf	<<_retnl>>
  endif
endm

$double macro p1
  ifnb <p1>
    $decl p1, 8, QWORD
  else
    $$rb = 8
    $define $$rf	<<_retnd>>
  endif
endm

$log macro p1
  ifnb <p1>
    $decl p1, 2, WORD
  else
    $$rb = 2
    $define $$rf	<<_retl>>
  endif
endm

$date macro p1
  ifnb <p1>
    $decl p1, 4, DWORD
  else
    $$rb = 4
    $define $$rf	<<_retds>>
  endif
endm

CLpublic macro p1

  irp $$item, <p1>
    $gen <		PUBLIC	$$item>

  endm
endm

Cglobal macro p1

  irp $$item, <p1>
    $gen <		PUBLIC	_&&$$item>
    $gen <$$item	EQU	_&&$$item>
    $gen <$$item&&_PUBLIC$	=	1>

  endm
endm

CLlabel macro p1

  irp $$item, <p1>
    $l_&&$$item

  endm
endm

$l_byte macro p1
  $gen <p1&_BYTE$	=	1>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      $gen <_&&$$item		LABEL	BYTE>

    else
      $gen <$$item		LABEL	BYTE>

    endif

  endm
endm

$l_string macro p1
  $l_byte p1
endm

$l_int macro p1
  $gen <p1&_BYTE$	=	2>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      $gen <_&&$$item		LABEL	WORD>

    else
      $gen <$$item		LABEL	WORD>

    endif

  endm
endm

$l_log macro p1
  $l_int p1
endm

$l_long macro p1
  $gen <p1&_BYTE$	=	4>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      $gen <_&&$$item		LABEL	DWORD>

    else
      $gen <$$item		LABEL	DWORD>

    endif

  endm
endm

$l_double macro p1
  $gen <p1&_BYTE$	=	8>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      $gen <_&&$$item		LABEL	QWORD>

    else
      $gen <$$item		LABEL	QWORD>

    endif

  endm
endm

$l_cptr macro p1
  $gen <p1&_BYTE$	=	4>

  irp $$item, <p1>
    ifdef $$item&&_PUBLIC$
      $gen <_&&$$item		LABEL	DWORD>

    else
      $gen <$$item		LABEL	DWORD>

    endif
  endm

  $gen <p1&_OFF		EQU	WORD PTR p1>
  $gen <p1&_SEG		EQU	WORD PTR p1[2]>
  $gen <p1&_OFF_BYTE$		=	2>
  $gen <p1&_SEG_BYTE$		=	2>

endm

$import macro p1, p2
  if $$stat
    $dend
  endif

  if $$lev EQ 3
    $cend
  endif

  $gen <		EXTRN	_&p1:p2>
  $gen <p1		EQU	_&p1>

  if $$stat
    $dbeg
  endif

  if $$lev EQ 3
    $cbeg
  endif

endm

$x_byte macro p1
  $gen <p1&_BYTE$	=	2>

  $import p1 WORD
endm

$x_int macro p1
  $gen <p1&_BYTE$	=	2>

  $import p1 WORD
endm

$x_log macro p1
  $x_int p1
endm

$x_long macro p1
  $gen <p1&_BYTE$	=	4>

  $import p1 DWORD
endm

$x_double macro p1
  $gen <p1&_BYTE$	=	8>

  $import p1 QWORD
endm

$x_cptr macro p1
  $gen <p1&_BYTE$	=	4>

  $import p1 DWORD
endm

$x_far macro p1
  $import p1 FAR
endm


.LIST


