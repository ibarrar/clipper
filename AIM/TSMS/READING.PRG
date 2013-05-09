/*#define SL_ROW  23
#define SL_COL1 1
#define SL_COL2 78*/
/*local cLineSave*/
/*    cLineSave := savescreen ( SL_ROW, SL_COL1, SL_ROW, SL_COL2 )*/  // Save Status line
/*  restscreen ( SL_ROW, SL_COL1, SL_ROW, SL_COL2, cLineSave )*/ // Restore Status line

#define M_ROW   10
#define M_COL   20

function Terminal_Read ( cISCno, cClus, cMode )

 cClus := alltrim ( cClus) // Remove spaces from the cluster

 // Prompt the user what is happening.
 Message ( "Reading ISC no. "  + cISCno + " in "+cMode+"-Mode ..." )

 if (CheckifExist(cClus))
    do case
     case substr(cClus, 1, 1) == "1"  // RS3460
      RUN("RID34 "+cClus+" 0 "+cIscNo+" "+cMode )
     case substr(cClus, 1, 1) == "2"  // RS35M_ROW
      RUN("RID35 "+cClus+" 0 "+cIscNo+" "+cMode )
     case substr(cClus, 1, 1) == "3"  // RS4540
      RUN("RID45 "+cClus+" 0 "+cIscNo+" "+cMode )
     case substr(cClus, 1, 1) == "4"  // RS5550
      RUN("RID55 "+cClus+" 0 "+cIscNo+" "+cMode )
   endcase
 endif
return nil

function Department_Read ( cISCno, cClus, nMode )
cClus := alltrim ( cClus) // Remove spaces from the cluster

 Message ("Reading ISC no. " + cISCno +" in "+nMode+"-Mode ..." )
 if (CheckifExist(cClus))
 do case
    case substr(cClus, 1, 1) == "1"  // RS3460
      RUN("RID34 "+cClus+" 1 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "2"  // RS3510
      RUN("RID35 "+cClus+" 1 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "3"  // RS4540
      RUN("RID45 "+cClus+" 1 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "4"  // RS5550
      RUN("RID55 "+cClus+" 1 "+cIscNo+" "+nMode )
 endcase
 endif
return nil

function PLU_SDP_Read ( cISCno, cClus, nMode )
 cClus := alltrim ( cClus) // Remove spaces from the cluster

 Message ( "Reading ISC no. " + cISCno+" in "+nMode+"-Mode ..." )
 if (CheckifExist(cClus))
 do case
    case substr(cClus, 1, 1) == "1"  // RS3460
      RUN("RID34 "+cClus+" 2 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "2"  // RS3510
      RUN("RID35 "+cClus+" 2 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "3"  // RS4540
      RUN("RID45 "+cClus+" 2 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "4"  // RS5550
      RUN("RID55 "+cClus+" 2 "+cIscNo+" "+nMode )
 endcase
 endif
return nil

function Hourly_Read ( cISCno, cClus, nMode )
 cClus := alltrim ( cClus) // Remove spaces from the cluster

 Message ( "Reading ISC no. " + cISCno+" in "+nMode+"-Mode ..." )
 if (CheckifExist(cClus))
 do case
    case substr(cClus, 1, 1) == "1"  // RS3460
      RUN("RID34 "+cClus+" 3 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "2"  // RS3510
      RUN("RID35 "+cClus+" 3 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "3"  // RS4540
      RUN("RID45 "+cClus+" 3 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "4"  // RS5550
      RUN("RID55 "+cClus+" 3 "+cIscNo+" "+nMode )
 endcase
 endif
return nil

function Cashier_Read ( cISCno, cClus, nMode )
 cClus := alltrim ( cClus) // Remove spaces from the cluster

 Message ( "Reading ISC no. " + cISCno+" in "+nMode+"-Mode ..." )
 if (CheckifExist(cClus))
 do case
    case substr(cClus, 1, 1) == "1"  // RS3460
      RUN("RID34 "+cClus+" 4 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "2"  // RS3510
      RUN("RID35 "+cClus+" 4 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "3"  // RS4540
      RUN("RID45 "+cClus+" 4 "+cIscNo+" "+nMode )
    case substr(cClus, 1, 1) == "4"  // RS5550
      RUN("RID55 "+cClus+" 4 "+cIscNo+" "+nMode )
 endcase
 endif
return nil

function Checkifexist(cClus)
local lRetVal:= .T.
 do case
    case substr(cClus, 1, 1) == "1"  // RS3460
      if !(lRetVal:= File("RID34.exe"))
         alert("File RID34.EXE not found")
      endif
    case substr(cClus, 1, 1) == "2"  // RS3510
      if !(lRetVal:= File("RID35.exe"))
         alert("File RID35.EXE not found")
      endif
    case substr(cClus, 1, 1) == "3"  // RS4540
      if !(lRetVal:= File("RID45.exe"))
         alert("File RID45.EXE not found")
      endif
    case substr(cClus, 1, 1) == "4" //  RS5550
      if !(lRetVal:= File("RID55.exe"))
         alert("File RID55.EXE not found")
      endif
 endcase
 if (!lRetVal)
   Message("Error : 00006 Missing files...")
   tone(400,3)
 endif
return lretval

/*-*-*-*-*-*-*-eof(reading)-*-*-*-*-*-*-*/