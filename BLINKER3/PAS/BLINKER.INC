{ Blinker 2.1 function include file

  MS Pascal 4.0

  Copyright (C) ASM inc, 1992, 1993
}

TYPE
    CSTR = ARRAY [0..127] OF CHAR ;

{ function prototypes }

{ Get Current Overlay Number }
function BLICUROVL : integer [C] ; extern ;

{ Get Current Procedure Size }
function BLICURSIZ : integer4 [C] ; extern ;

{ Set the Blinker debug handle }
function BLIDBGHAN(handle : integer) : integer [C] ; extern ;

{ Get / Set number of demonstration calls }
function BLIDEMCAL(DemoLimit : integer) : integer [C] ; extern ;

{ Get demonstration date }
function BLIDEMDTE : integer [C] ; extern ;

{ Get / Set demonstration minutes }
function BLIDEMMIN(DemoLimit : integer) : integer [C] ; extern ;

{ Display overlaid procedure call trace }
procedure BLIDISTRC(handle : integer) ; extern ;

{ Get Blinker error number }
function BLIERRNUM : integer [C] ; extern ;

{ Get Blinker error parameter }
function BLIERRPRM : integer [C] ; extern ;

{ Get size of overlay pool memory }
function BLIOVLOPS : integer4 [C] ; extern ;

{ Resume overlay manager operation }
procedure BLIOVLRES ; extern ;

{ Get current size of overlay pool memory }
function BLIOVLSIZ : integer4 [C] ; extern ;

{ Suspend overlay manager operations }
procedure BLIOVLSUS(level : integer) ; extern ;

{ Get burned in serial }
function BLISERNUM : integer [C] ; extern ;

{ Get total number of overlays currently active }
function BLITOTACT : integer [C] ; extern ;

{ Get total number of overlays currently loaded in memory }
function BLITOTLOD : integer [C] ; extern ;

{ Get total size of all overlays ever loaded }
function BLITOTSIZ : integer4 [C] ; extern ;

{ Get Blinker version number }
function BLIVERNUM : integer [C] ; extern ;

{ Increase child process environment block }
function SWPADDENV( ExtraBytes : integer ) : integer [C] ; extern ;

{ Add to a program's return string }
function SWPADDSTR : integer [c,varying] ; extern ;

{ Enable / Disable saving/restoring of current directory (ON) }
function SWPCURDIR(flag : integer) : integer [C] ; extern ;

{ Enable / Disable display of msg & wait for keypress before restore (OFF) }
function SWPDISMSG(flag : integer) : integer [C] ; extern ;

{ Use only EMS 3.2 calls }
function SWPEMS320(flag : integer) : integer [C] ; extern ;

{ Get child process return code }
function SWPERRLEV : integer [C] ; extern ;

{ Major error code }
function SWPERRMAJ : integer [C] ; extern ;

{ Minor error code }
function SWPERRMIN : integer [C] ; extern ;

{ Enable / Disable use of EMS (ON) }
function SWPFREEMS(MemKB : integer) : integer [C] ; extern ;

{ Enable / Disable use of XMS (ON) }
function SWPFREXMS(MemKB : integer) : integer [C] ; extern ;

{ Enable / Disable wait for keypress before restore (OFF) }
function SWPGETKEY(flag : integer) : integer [C] ; extern ;

{ Check for program ID }
function SWPGETPID : integer [c,varying] ; extern ;

{ Get swapped program's return string }
function SWPGETSTR : ADSMEM [C] ; extern ;

{ Stuff keyboard strokes }
function SWPKEYBRD : integer [c,varying] ; extern ;

{ Set number of 'keyboard not ready' signals sent }
function SWPKEYCLR(flag : integer) : integer [C] ; extern ;

{ Enable / Disable trapping of <Crtl><Alt><Del> during swap (OFF) }
function SWPNOBOOT(flag : integer) : integer [C] ; extern ;

{ Execute child process }
function SWPRUNCMD : integer [c,varying] ; extern ;

{ Set environment variable(s) }
function SWPSETENV : integer [c,varying] ; extern ;

{ Set program ID }
function SWPSETPID : integer [c,varying] ; extern ;

{ Set a program's return string }
function SWPSETSTR : integer [c,varying] ; extern ;

{ Enable / Disable use of EMS (ON) }
function SWPUSEEMS(flag : integer) : integer [C] ; extern ;

{ Enable / Disable use of UMBs (ON) }
function SWPUSEUMB(flag : integer) : integer [C] ; extern ;

{ Enable / Disable use of XMS (ON) }
function SWPUSEXMS(flag : integer) : integer [C] ; extern ;

{ Enable / Disable display of video mode (OFF) }
function SWPVIDMDE(flag : integer) : integer [C] ; extern ;

{ --------------------------------------------------------------------------- }

{ SWPRUNCMD major error return codes }

CONST
  SWPNONERR=0 ;  { No error }
  SWPDSKFUL=1 ;  { Disk full }
  SWPDSKOPE=2 ;  { Disk file open error }
  SWPDSKERR=3 ;  { Disk i/o error }
  SWPDIRERR=4 ;  { Change directory error }
  SWPCREERR=5 ;  { Temp file create error }
  SWPDRVERR=6 ;  { Change drive error }
  SWPEMSERR=7 ;  { EMS error }
  SWPXMSERR=8 ;  { XMS error }
  SWPCMDERR=9 ;  { SHELL error }
  SWPHANERR=10;  { Handle table too big to save }
  SWPMEMERR=11;  { Top of memory decreased error }
  SWPMCBERR=12;  { MCB chain corrupt }
  SWPMCBCNT=13;  { Too many MCBs }
  SWPBLKERR=14;  { DOS memory function call error }
  SWPMEMRES=15;  { Error reallocating segment }
  SWPCSPERR=16;  { Comspec variable not found }
  SWPINTERR=254; { Internal error }

{Non fatal minor error codes when major error code is zero }

  SWPKILTSR=1;   { TSR was removed }
  SWPMEMINC=2;   { Top of memory increased }

