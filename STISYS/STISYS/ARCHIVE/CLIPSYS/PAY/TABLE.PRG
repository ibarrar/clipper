*:*********************************************************************
*:
*:   Procedure file: Table.PRG
*:
*:           System: Payroll.PRG (Super Travel - Payroll System)
*:           Author: Ronan Japzon Paredes
*:                   Copyright (c) 1992, Super Travel, Inc.
*:    Last modified: 02/11/93     11:26a
*:
*:**********************************************************************

*!*******************************************************************
function MonthlyWT(cCategory,nCompensation)
local nWTax
   do case
      // 1993 tax table
      case cCategory=="A-1" ; nWTax:=WTaxA_A1(nCompensation)
      case cCategory=="A-2" ; nWTax:=WTaxA_A2(nCompensation)
      case cCategory=="A-3" ; nWTax:=WTaxA_A3(nCompensation)
      case cCategory=="A-4" ; nWTax:=WTaxA_A4(nCompensation)
      case cCategory=="A-5" ; nWTax:=WTaxA_A5(nCompensation)
      case cCategory=="A-6" ; nWTax:=WTaxA_A6(nCompensation)

      case cCategory=="B-1" ; nWTax:=WTaxA_B1(nCompensation)
      case cCategory=="B-2" ; nWTax:=WTaxA_B2(nCompensation)
      case cCategory=="B-3" ; nWTax:=WTaxA_B3(nCompensation)
      case cCategory=="B-4" ; nWTax:=WTaxA_B4(nCompensation)

      case cCategory=="C-1" ; nWTax:=WTaxA_C1(nCompensation)
      case cCategory=="C-2" ; nWTax:=WTaxA_C2(nCompensation)
      case cCategory=="C-3" ; nWTax:=WTaxA_C3(nCompensation)
      case cCategory=="C-4" ; nWTax:=WTaxA_C4(nCompensation)

      OTHERWISE             ;   nWtax:=0.00
   endcase
return nWTax

static function WTaxA_A1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=207)
     nTax:=0.00
  elseif (nCompensation>=208)   .and. (nCompensation<=416)
     nTax:=TaxA_Table(nCompensation-208,2)
  elseif (nCompensation>=417)   .and. (nCompensation<=832)
     nTax:=TaxA_Table(nCompensation-417,3)
  elseif (nCompensation>=833)   .and. (nCompensation<=1666)
     nTax:=TaxA_Table(nCompensation-833,4)
  elseif (nCompensation>=1667)  .and. (nCompensation<=3332)
     nTax:=TaxA_Table(nCompensation-1667,5)
  elseif (nCompensation>=3333)  .and. (nCompensation<=4999)
     nTax:=TaxA_Table(nCompensation-3333,6)
  elseif (nCompensation>=5000)  .and. (nCompensation<=8332)
     nTax:=TaxA_Table(nCompensation-5000,7)
  elseif (nCompensation>=8333)  .and. (nCompensation<=20832)
     nTax:=TaxA_Table(nCompensation-8333,8)
  elseif (nCompensation>=20833) .and. (nCompensation<=41666)
     nTax:=TaxA_Table(nCompensation-20833,9)
  elseif (nCompensation>=41667)
     nTax:=TaxA_Table(nCompensation-41667,10)
  endif
  return nTax

static function WTaxA_A2(NCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=957)
     nTax:=0.00
  elseif (nCompensation>=958)   .and. (nCompensation<=1166)
     nTax:=TaxA_Table(nCompensation-958,2)
  elseif (nCompensation>=1167)   .and. (nCompensation<=1582)
     nTax:=TaxA_Table(nCompensation-1167,3)
  elseif (nCompensation>=1583)  .and. (nCompensation<=2416)
     nTax:=TaxA_Table(nCompensation-1583,4)
  elseif (nCompensation>=2417)  .and. (nCompensation<=4082)
     nTax:=TaxA_Table(nCompensation-2417,5)
  elseif (nCompensation>=4083)  .and. (nCompensation<=5749)
     nTax:=TaxA_Table(nCompensation-4083,6)
  elseif (nCompensation>=5750)  .and. (nCompensation<=9082)
     nTax:=TaxA_Table(nCompensation-5750,7)
  elseif (nCompensation>=9083)  .and. (nCompensation<=21582)
     nTax:=TaxA_Table(nCompensation-9083,8)
  elseif (nCompensation>=21583) .and. (nCompensation<=42416)
     nTax:=TaxA_Table(nCompensation-21583,9)
  elseif (nCompensation>=42417)
     nTax:=TaxA_Table(nCompensation-42417,10)
   endif
return nTax

static function WTaxA_A3(nCompensation)
local nTax
  if (nCompensation>=0)        .and. (nCompensation<=1291)
     nTax:=0.00
  elseif (nCompensation>=1292) .and. (nCompensation<=1499)
     nTax:=TaxA_Table(nCompensation-1292,2)
  elseif (nCompensation>=1500)
     nTax:=TaxA_Table(nCompensation-1500,3)
  endif
return nTax

static function WTaxA_A4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1207)
     nTax:=0.00
  elseif (nCompensation>=1208)  .and. (nCompensation<=1416)
     nTax:=TaxA_Table(nCompensation-1208,2)
  elseif (nCompensation>=1417)  .and. (nCompensation<=1832)
     nTax:=TaxA_Table(nCompensation-1417,3)
  elseif (nCompensation>=1833)  .and. (nCompensation<=2666)
     nTax:=TaxA_Table(nCompensation-1833,4)
  elseif (nCompensation>=2667)  .and. (nCompensation<=4332)
     nTax:=TaxA_Table(nCompensation-2667,5)
  elseif (nCompensation>=4333)  .and. (nCompensation<=5999)
     nTax:=TaxA_Table(nCompensation-4333,6)
  elseif (nCompensation>=6000)  .and. (nCompensation<=9332)
     nTax:=TaxA_Table(nCompensation-6000,7)
  elseif (nCompensation>=9333)  .and. (nCompensation<=21832)
     nTax:=TaxA_Table(nCompensation-9333,8)
  elseif (nCompensation>=21833) .and. (nCompensation<=42666)
     nTax:=TaxA_Table(nCompensation-21833,9)
  elseif (nCompensation>=42667)
     nTax:=TaxA_Table(nCompensation-42667,10)
  endif
return nTax

static function WTaxA_A5(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1541)
     nTax:=0.00
  elseif (nCompensation>=1542)
     nTax:=TaxA_Table(nCompensation-1542,2)
  endif
return nTax

static function WTaxA_A6(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1707)
     nTax:=0.00
  elseif (nCompensation>=1708)  .and. (nCompensation<=1916)
     nTax:=TaxA_Table(nCompensation-1708,2)
  elseif (nCompensation>=1917)  .and. (nCompensation<=2332)
     nTax:=TaxA_Table(nCompensation-1917,3)
  elseif (nCompensation>=2333)  .and. (nCompensation<=3166)
     nTax:=TaxA_Table(nCompensation-2333,4)
  elseif (nCompensation>=3167)  .and. (nCompensation<=4832)
     nTax:=TaxA_Table(nCompensation-3167,5)
  elseif (nCompensation>=4833)  .and. (nCompensation<=6499)
     nTax:=TaxA_Table(nCompensation-4833,6)
  elseif (nCompensation>=6500)  .and. (nCompensation<=9832)
     nTax:=TaxA_Table(nCompensation-6500,7)
  elseif (nCompensation>=9833)  .and. (nCompensation<=22332)
     nTax:=TaxA_Table(nCompensation-9833,8)
  elseif (nCompensation>=22333) .and. (nCompensation<=42166)
     nTax:=TaxA_Table(nCompensation-22333,9)
  elseif (nCompensation>=43167)
     nTax:=TaxA_Table(nCompensation-43167,10)
  endif
return nTax

static function WTaxA_B1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1624)
     nTax:=0.00
  elseif (nCompensation>=1625)  .and. (nCompensation<=1832)
     nTax:=TaxA_Table(nCompensation-1625,2)
  elseif (nCompensation>=1833)  .and. (nCompensation<=2249)
     nTax:=TaxA_Table(nCompensation-1833,3)
  elseif (nCompensation>=2250)  .and. (nCompensation<=3082)
     nTax:=TaxA_Table(nCompensation-2250,4)
  elseif (nCompensation>=3083)  .and. (nCompensation<=4749)
     nTax:=TaxA_Table(nCompensation-3083,5)
  elseif (nCompensation>=4750)  .and. (nCompensation<=6416)
     nTax:=TaxA_Table(nCompensation-4750,6)
  elseif (nCompensation>=6417)  .and. (nCompensation<=9749)
     nTax:=TaxA_Table(nCompensation-6417,7)
  elseif (nCompensation>=9750)  .and. (nCompensation<=22249)
     nTax:=TaxA_Table(nCompensation-9750,8)
  elseif (nCompensation>=22250) .and. (nCompensation<=43082)
     nTax:=TaxA_Table(nCompensation-22250,9)
  elseif (nCompensation>=43083)
     nTax:=TaxA_Table(nCompensation-43083,9)
  endif
return nTax

static function WTaxA_B2(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2041)
     nTax:=0.00
  elseif (nCompensation>=2042)  .and. (nCompensation<=2249)
     nTax:=TaxA_Table(nCompensation-1542,2)
  elseif (nCompensation>=2250)  .and. (nCompensation<=2666)
     nTax:=TaxA_Table(nCompensation-2250,3)
  elseif (nCompensation>=2667)  .and. (nCompensation<=3499)
     nTax:=TaxA_Table(nCompensation-2667,4)
  elseif (nCompensation>=3500)  .and. (nCompensation<=5166)
     nTax:=TaxA_Table(nCompensation-3500,5)
  elseif (nCompensation>=5167)  .and. (nCompensation<=6832)
     nTax:=TaxA_Table(nCompensation-5167,6)
  elseif (nCompensation>=6833)  .and. (nCompensation<=10166)
     nTax:=TaxA_Table(nCompensation-6833,7)
  elseif (nCompensation>=10167) .and. (nCompensation<=22666)
     nTax:=TaxA_Table(nCompensation-10167,8)
  elseif (nCompensation>=22667) .and. (nCompensation<=43499)
     nTax:=TaxA_Table(nCompensation-22667,9)
  elseif (nCompensation>=43500)
     nTax:=TaxA_Table(nCompensation-43500,10)
  endif
return nTax

static function WTaxA_B3(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2457)
     nTax:=0.00
  elseif (nCompensation>=2458)  .and. (nCompensation<=2666)
     nTax:=TaxA_Table(nCompensation-2458,2)
  elseif (nCompensation>=2667)  .and. (nCompensation<=3082)
     nTax:=TaxA_Table(nCompensation-2667,3)
  elseif (nCompensation>=3083)  .and. (nCompensation<=3916)
     nTax:=TaxA_Table(nCompensation-3082,4)
  elseif (nCompensation>=3917)  .and. (nCompensation<=5582)
     nTax:=TaxA_Table(nCompensation-3917,5)
  elseif (nCompensation>=5583)  .and. (nCompensation<=7249)
     nTax:=TaxA_Table(nCompensation-5583,6)
  elseif (nCompensation>=7250)  .and. (nCompensation<=10582)
     nTax:=TaxA_Table(nCompensation-7250,7)
  elseif (nCompensation>=10583) .and. (nCompensation<=23082)
     nTax:=TaxA_Table(nCompensation-10583,8)
  elseif (nCompensation>=23083) .and. (nCompensation<=43916)
     nTax:=TaxA_Table(nCompensation-23083,8)
  elseif (nCompensation>=43917)
     nTax:=TaxA_Table(nCompensation-43917,10)
  endif
return nTax

static function WTaxA_B4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2874)
     nTax:=0.00
  elseif (nCompensation>=2875)  .and. (nCompensation<=3082)
     nTax:=TaxA_Table(nCompensation-2875,3)
  elseif (nCompensation>=3083)  .and. (nCompensation<=3499)
     nTax:=TaxA_Table(nCompensation-3083,4)
  elseif (nCompensation>=3500)  .and. (nCompensation<=4332)
     nTax:=TaxA_Table(nCompensation-3500,5)
  elseif (nCompensation>=4333)  .and. (nCompensation<=5999)
     nTax:=TaxA_Table(nCompensation-4333,6)
  elseif (nCompensation>=6000)  .and. (nCompensation<=7666)
     nTax:=TaxA_Table(nCompensation-6000,7)
  elseif (nCompensation>=7667)  .and. (nCompensation<=10999)
     nTax:=TaxA_Table(nCompensation-7667,8)
  elseif (nCompensation>=11000) .and. (nCompensation<=23499)
     nTax:=TaxA_Table(nCompensation-11000,9)
  elseif (nCompensation>=23500) .and. (nCompensation<=44332)
     nTax:=TaxA_Table(nCompensation-23500,9)
  elseif (nCompensation>=44333)
     nTax:=TaxA_Table(nCompensation-44333,10)
  endif
return nTax

static function WTaxA_C1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2124)
     nTax:=0.00
  elseif (nCompensation>=2125)  .and. (nCompensation<=2332)
     nTax:=TaxA_Table(nCompensation-2125,3)
  elseif (nCompensation>=2333)  .and. (nCompensation<=2749)
     nTax:=TaxA_Table(nCompensation-2333,4)
  elseif (nCompensation>=2750)  .and. (nCompensation<=3582)
     nTax:=TaxA_Table(nCompensation-2750,5)
  elseif (nCompensation>=3583)  .and. (nCompensation<=5249)
     nTax:=TaxA_Table(nCompensation-3583,6)
  elseif (nCompensation>=5250)  .and. (nCompensation<=6916)
     nTax:=TaxA_Table(nCompensation-5250,7)
  elseif (nCompensation>=6917)  .and. (nCompensation<=10249)
     nTax:=TaxA_Table(nCompensation-6917,8)
  elseif (nCompensation>=10250) .and. (nCompensation<=22749)
     nTax:=TaxA_Table(nCompensation-10250,9)
  elseif (nCompensation>=22750) .and. (nCompensation<=43582)
     nTax:=TaxA_Table(nCompensation-22750,9)
  elseif (nCompensation>=43583)
     nTax:=TaxA_Table(nCompensation-43583,10)
  endif
return nTax

static function WTaxA_C2(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2541)
     nTax:=0.00
  elseif (nCompensation>=2542)  .and. (nCompensation<=2749)
     nTax:=TaxA_Table(nCompensation-2542,2)
  elseif (nCompensation>=2750)  .and. (nCompensation<=3166)
     nTax:=TaxA_Table(nCompensation-2750,3)
  elseif (nCompensation>=3167)  .and. (nCompensation<=3999)
     nTax:=TaxA_Table(nCompensation-3167,4)
  elseif (nCompensation>=4000)  .and. (nCompensation<=5666)
     nTax:=TaxA_Table(nCompensation-4000,5)
  elseif (nCompensation>=5667)  .and. (nCompensation<=7332)
     nTax:=TaxA_Table(nCompensation-7333,6)
  elseif (nCompensation>=7333)  .and. (nCompensation<=10666)
     nTax:=TaxA_Table(nCompensation-7333,7)
  elseif (nCompensation>=10667) .and. (nCompensation<=23166)
     nTax:=TaxA_Table(nCompensation-10667,8)
  elseif (nCompensation>=23167) .and. (nCompensation<=43999)
     nTax:=TaxA_Table(nCompensation-22333,9)
  elseif (nCompensation>=44000)
     nTax:=TaxA_Table(nCompensation-44000,10)
  endif
return nTax

static function WTaxA_C3(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=2957)
     nTax:=0.00
  elseif (nCompensation>=2958)  .and. (nCompensation<=3166)
     nTax:=TaxA_Table(nCompensation-2958,2)
  elseif (nCompensation>=3167)  .and. (nCompensation<=3582)
     nTax:=TaxA_Table(nCompensation-3167,3)
  elseif (nCompensation>=3583)  .and. (nCompensation<=4416)
     nTax:=TaxA_Table(nCompensation-3583,4)
  elseif (nCompensation>=4417)  .and. (nCompensation<=6082)
     nTax:=TaxA_Table(nCompensation-4417,5)
  elseif (nCompensation>=6083)  .and. (nCompensation<=7749)
     nTax:=TaxA_Table(nCompensation-6083,6)
  elseif (nCompensation>=7750)  .and. (nCompensation<=11082)
     nTax:=TaxA_Table(nCompensation-7750,7)
  elseif (nCompensation>=11083) .and. (nCompensation<=23582)
     nTax:=TaxA_Table(nCompensation-11083,8)
  elseif (nCompensation>=23583) .and. (nCompensation<=44416)
     nTax:=TaxA_Table(nCompensation-23583,9)
  elseif (nCompensation>=44417)
     nTax:=TaxA_Table(nCompensation-44417,10)
  endif
return nTax

static function WTaxA_C4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=3374)
     nTax:=0.00
  elseif (nCompensation>=3375)  .and. (nCompensation<=3582)
     nTax:=TaxA_Table(nCompensation-3375,2)
  elseif (nCompensation>=3583)  .and. (nCompensation<=3999)
     nTax:=TaxA_Table(nCompensation-3583,3)
  elseif (nCompensation>=4000)  .and. (nCompensation<=4832)
     nTax:=TaxA_Table(nCompensation-4000,4)
  elseif (nCompensation>=4833)  .and. (nCompensation<=6499)
     nTax:=TaxA_Table(nCompensation-4833,5)
  elseif (nCompensation>=6500)  .and. (nCompensation<=8166)
     nTax:=TaxA_Table(nCompensation-6500,6)
  elseif (nCompensation>=8167)  .and. (nCompensation<=11499)
     nTax:=TaxA_Table(nCompensation-8167,7)
  elseif (nCompensation>=11500) .and. (nCompensation<=23999)
     nTax:=TaxA_Table(nCompensation-24000,8)
  elseif (nCompensation>=24000) .and. (nCompensation<=44832)
     nTax:=TaxA_Table(nCompensation-24000,9)
  elseif (nCompensation>=44833)
     nTax:=TaxA_Table(nCompensation-44833,10)
  endif
return nTax

static function TaxA_Table(nCompensation,nLevel)
local nTax
   do case
      case nLevel==1  ; nTax:=0.00
      case nLevel==2  ; nTax:=nCompensation * 0.01
      case nLevel==3  ; nTax:=2.08+(nCompensation * 0.03)
      case nLevel==4  ; nTax:=14.58+(nCompensation * 0.07)
      case nLevel==5  ; nTax:=72.92+(nCompensation * 0.11)
      case nLevel==6  ; nTax:=256.25+(nCompensation * 0.15)
      case nLevel==7  ; nTax:=506.25+(nCompensation * 0.19)
      case nLevel==8  ; nTax:=1139.58+(nCompensation * 0.24)
      case nLevel==9  ; nTax:=4139.58+(nCompensation * 0.29)
      case nLevel==10 ; nTax:=10181.00+(nCompensation * 0.35)
   endcase
return nTax

*!*******************************************************************
function SemiMonthlyWT(cCategory,nCompensation)
local nWTax
   do case
      // 1992 tax table
      case cCategory=="A-1" ; nWTax:=WTaxB_A1(nCompensation)
      case cCategory=="A-2" ; nWTax:=WTaxB_A2(nCompensation)
      case cCategory=="A-3" ; nWTax:=WTaxB_A3(nCompensation)
      case cCategory=="A-4" ; nWTax:=WTaxB_A4(nCompensation)
      case cCategory=="A-5" ; nWTax:=WTaxB_A5(nCompensation)
      case cCategory=="A-6" ; nWTax:=WTaxB_A6(nCompensation)

      case cCategory=="B-1" ; nWTax:=WTaxB_B1(nCompensation)
      case cCategory=="B-2" ; nWTax:=WTaxB_B2(nCompensation)
      case cCategory=="B-3" ; nWTax:=WTaxB_B3(nCompensation)
      case cCategory=="B-4" ; nWTax:=WTaxB_B4(nCompensation)

      case cCategory=="C-1" ; nWTax:=WTaxB_C1(nCompensation)
      case cCategory=="C-2" ; nWTax:=WTaxB_C2(nCompensation)
      case cCategory=="C-3" ; nWTax:=WTaxB_C3(nCompensation)
      case cCategory=="C-4" ; nWTax:=WTaxB_C4(nCompensation)

      OTHERWISE             ;   nWtax:=0.00
   endcase
return nWTax

static function WTaxB_A1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=104)
     nTax:=0.00
  elseif (nCompensation>=104)   .and. (nCompensation<=207)
     nTax:=TaxB_Table(nCompensation-104,2)
  elseif (nCompensation>=208)   .and. (nCompensation<=416)
     nTax:=TaxB_Table(nCompensation-208,3)
  elseif (nCompensation>=417)   .and. (nCompensation<=832)
     nTax:=TaxB_Table(nCompensation-417,4)
  elseif (nCompensation>=833)  .and. (nCompensation<=1666)
     nTax:=TaxB_Table(nCompensation-833,5)
  elseif (nCompensation>=1667)  .and. (nCompensation<=2499)
     nTax:=TaxB_Table(nCompensation-1667,6)
  elseif (nCompensation>=2500)  .and. (nCompensation<=4166)
     nTax:=TaxB_Table(nCompensation-2500,7)
  elseif (nCompensation>=4167)  .and. (nCompensation<=10416)
     nTax:=TaxB_Table(nCompensation-4167,8)
  elseif (nCompensation>=10417) .and. (nCompensation<=20832)
     nTax:=TaxB_Table(nCompensation-10417,9)
  elseif (nCompensation>=20833)
     nTax:=TaxB_Table(nCompensation-20833,10)
  endif
  return nTax

static function WTaxB_A2(NCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=478)
     nTax:=0.00
  elseif (nCompensation>=479)   .and. (nCompensation<=582)
     nTax:=TaxB_Table(nCompensation-479,2)
  elseif (nCompensation>=583)   .and. (nCompensation<=791)
     nTax:=TaxB_Table(nCompensation-583,3)
  elseif (nCompensation>=792)  .and. (nCompensation<=1207)
     nTax:=TaxB_Table(nCompensation-792,4)
  elseif (nCompensation>=1208)  .and. (nCompensation<=2041)
     nTax:=TaxB_Table(nCompensation-1208,5)
  elseif (nCompensation>=2042)  .and. (nCompensation<=2874)
     nTax:=TaxB_Table(nCompensation-2042,6)
  elseif (nCompensation>=2875)  .and. (nCompensation<=4541)
     nTax:=TaxB_Table(nCompensation-2875,7)
  elseif (nCompensation>=4542)  .and. (nCompensation<=10791)
     nTax:=TaxB_Table(nCompensation-4542,8)
  elseif (nCompensation>=10792) .and. (nCompensation<=21207)
     nTax:=TaxB_Table(nCompensation-10792,9)
  elseif (nCompensation>=21208)
     nTax:=TaxB_Table(nCompensation-21208,10)
   endif
return nTax

static function WTaxB_A3(nCompensation)
local nTax
  if (nCompensation>=0)        .and. (nCompensation<=645)
     nTax:=0.00
  elseif (nCompensation>=646) .and. (nCompensation<=749)
     nTax:=TaxB_Table(nCompensation-646,2)
  elseif (nCompensation>=750)
     nTax:=TaxB_Table(nCompensation-750,3)
  endif
return nTax

static function WTaxB_A4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=603)
     nTax:=0.00
  elseif (nCompensation>=604)  .and. (nCompensation<=707)
     nTax:=TaxB_Table(nCompensation-604,2)
  elseif (nCompensation>=708)  .and. (nCompensation<=916)
     nTax:=TaxB_Table(nCompensation-708,3)
  elseif (nCompensation>=917)  .and. (nCompensation<=1332)
     nTax:=TaxB_Table(nCompensation-917,4)
  elseif (nCompensation>=1333)  .and. (nCompensation<=2166)
     nTax:=TaxB_Table(nCompensation-1333,5)
  elseif (nCompensation>=2167)  .and. (nCompensation<=2999)
     nTax:=TaxB_Table(nCompensation-2167,6)
  elseif (nCompensation>=3000)  .and. (nCompensation<=4666)
     nTax:=TaxB_Table(nCompensation-3000,7)
  elseif (nCompensation>=4667)  .and. (nCompensation<=10916)
     nTax:=TaxB_Table(nCompensation-4667,8)
  elseif (nCompensation>=10917) .and. (nCompensation<=21333)
     nTax:=TaxB_Table(nCompensation-10917,9)
  elseif (nCompensation>=21333)
     nTax:=TaxB_Table(nCompensation-21333,10)
  endif
return nTax

static function WTaxB_A5(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=770)
     nTax:=0.00
  elseif (nCompensation>=771)
     nTax:=TaxB_Table(nCompensation-771,2)
  endif
return nTax

static function WTaxB_A6(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=853)
     nTax:=0.00
  elseif (nCompensation>=854)  .and. (nCompensation<=957)
     nTax:=TaxB_Table(nCompensation-854,2)
  elseif (nCompensation>=958)  .and. (nCompensation<=1166)
     nTax:=TaxB_Table(nCompensation-958,3)
  elseif (nCompensation>=1167)  .and. (nCompensation<=1582)
     nTax:=TaxB_Table(nCompensation-1167,4)
  elseif (nCompensation>=1583)  .and. (nCompensation<=2416)
     nTax:=TaxB_Table(nCompensation-1583,5)
  elseif (nCompensation>=2417)  .and. (nCompensation<=3249)
     nTax:=TaxB_Table(nCompensation-2417,6)
  elseif (nCompensation>=3250)  .and. (nCompensation<=4916)
     nTax:=TaxB_Table(nCompensation-3250,7)
  elseif (nCompensation>=4917)  .and. (nCompensation<=11166)
     nTax:=TaxB_Table(nCompensation-4917,8)
  elseif (nCompensation>=11167) .and. (nCompensation<=21582)
     nTax:=TaxB_Table(nCompensation-11167,9)
  elseif (nCompensation>=21583)
     nTax:=TaxB_Table(nCompensation-21583,10)
  endif
return nTax

static function WTaxB_B1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=812)
     nTax:=0.00
  elseif (nCompensation>=813)  .and. (nCompensation<=916)
     nTax:=TaxB_Table(nCompensation-813,2)
  elseif (nCompensation>=917)  .and. (nCompensation<=1124)
     nTax:=TaxB_Table(nCompensation-917,3)
  elseif (nCompensation>=1125)  .and. (nCompensation<=1541)
     nTax:=TaxB_Table(nCompensation-1125,4)
  elseif (nCompensation>=1542)  .and. (nCompensation<=2374)
     nTax:=TaxB_Table(nCompensation-1542,5)
  elseif (nCompensation>=2375)  .and. (nCompensation<=3207)
     nTax:=TaxB_Table(nCompensation-2375,6)
  elseif (nCompensation>=3208)  .and. (nCompensation<=4874)
     nTax:=TaxB_Table(nCompensation-3208,7)
  elseif (nCompensation>=4875)  .and. (nCompensation<=11124)
     nTax:=TaxB_Table(nCompensation-4875,8)
  elseif (nCompensation>=11125) .and. (nCompensation<=21541)
     nTax:=TaxB_Table(nCompensation-11125,9)
  elseif (nCompensation>=21542)
     nTax:=TaxB_Table(nCompensation-21542,9)
  endif
return nTax

static function WTaxB_B2(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1020)
     nTax:=0.00
  elseif (nCompensation>=1021)  .and. (nCompensation<=1124)
     nTax:=TaxB_Table(nCompensation-1021,2)
  elseif (nCompensation>=1125)  .and. (nCompensation<=1332)
     nTax:=TaxB_Table(nCompensation-1125,3)
  elseif (nCompensation>=1333)  .and. (nCompensation<=1749)
     nTax:=TaxB_Table(nCompensation-1333,4)
  elseif (nCompensation>=1750)  .and. (nCompensation<=2582)
     nTax:=TaxB_Table(nCompensation-1750,5)
  elseif (nCompensation>=2583)  .and. (nCompensation<=3416)
     nTax:=TaxB_Table(nCompensation-2583,6)
  elseif (nCompensation>=3417)  .and. (nCompensation<=5082)
     nTax:=TaxB_Table(nCompensation-3417,7)
  elseif (nCompensation>=5083) .and. (nCompensation<=11332)
     nTax:=TaxB_Table(nCompensation-5083,8)
  elseif (nCompensation>=11333) .and. (nCompensation<=21749)
     nTax:=TaxB_Table(nCompensation-11333,9)
  elseif (nCompensation>=21750)
     nTax:=TaxB_Table(nCompensation-21750,10)
  endif
return nTax

static function WTaxB_B3(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1228)
     nTax:=0.00
  elseif (nCompensation>=1229)  .and. (nCompensation<=1333)
     nTax:=TaxB_Table(nCompensation-1229,2)
  elseif (nCompensation>=1333)  .and. (nCompensation<=1541)
     nTax:=TaxB_Table(nCompensation-1333,3)
  elseif (nCompensation>=1542)  .and. (nCompensation<=1957)
     nTax:=TaxB_Table(nCompensation-3082,4)
  elseif (nCompensation>=1958)  .and. (nCompensation<=2791)
     nTax:=TaxB_Table(nCompensation-1958,5)
  elseif (nCompensation>=2792)  .and. (nCompensation<=3624)
     nTax:=TaxB_Table(nCompensation-2792,6)
  elseif (nCompensation>=3625)  .and. (nCompensation<=5291)
     nTax:=TaxB_Table(nCompensation-3625,7)
  elseif (nCompensation>=5292) .and. (nCompensation<=11541)
     nTax:=TaxB_Table(nCompensation-5542,8)
  elseif (nCompensation>=11542) .and. (nCompensation<=21957)
     nTax:=TaxB_Table(nCompensation-11542,8)
  elseif (nCompensation>=21958)
     nTax:=TaxB_Table(nCompensation-21958,10)
  endif
return nTax

static function WTaxB_B4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1431)
     nTax:=0.00
  elseif (nCompensation>=1438)  .and. (nCompensation<=1541)
     nTax:=TaxB_Table(nCompensation-1438,3)
  elseif (nCompensation>=1542)  .and. (nCompensation<=1749)
     nTax:=TaxB_Table(nCompensation-1542,4)
  elseif (nCompensation>=1750)  .and. (nCompensation<=2166)
     nTax:=TaxB_Table(nCompensation-1750,5)
  elseif (nCompensation>=2167)  .and. (nCompensation<=2999)
     nTax:=TaxB_Table(nCompensation-2167,6)
  elseif (nCompensation>=3000)  .and. (nCompensation<=3832)
     nTax:=TaxB_Table(nCompensation-3000,7)
  elseif (nCompensation>=3833)  .and. (nCompensation<=5499)
     nTax:=TaxB_Table(nCompensation-3833,8)
  elseif (nCompensation>=5500) .and. (nCompensation<=11749)
     nTax:=TaxB_Table(nCompensation-5500,9)
  elseif (nCompensation>=11750) .and. (nCompensation<=22166)
     nTax:=TaxB_Table(nCompensation-11750,9)
  elseif (nCompensation>=22167)
     nTax:=TaxB_Table(nCompensation-22167,10)
  endif
return nTax

static function WTaxB_C1(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1062)
     nTax:=0.00
  elseif (nCompensation>=1063)  .and. (nCompensation<=1166)
     nTax:=TaxB_Table(nCompensation-1063,3)
  elseif (nCompensation>=1167)  .and. (nCompensation<=1374)
     nTax:=TaxB_Table(nCompensation-1167,4)
  elseif (nCompensation>=1375)  .and. (nCompensation<=1791)
     nTax:=TaxB_Table(nCompensation-1375,5)
  elseif (nCompensation>=1792)  .and. (nCompensation<=2624)
     nTax:=TaxB_Table(nCompensation-1792,6)
  elseif (nCompensation>=2625)  .and. (nCompensation<=3457)
     nTax:=TaxB_Table(nCompensation-2625,7)
  elseif (nCompensation>=3458)  .and. (nCompensation<=5124)
     nTax:=TaxB_Table(nCompensation-3458,8)
  elseif (nCompensation>=5125) .and. (nCompensation<=11374)
     nTax:=TaxB_Table(nCompensation-5125,9)
  elseif (nCompensation>=11375) .and. (nCompensation<=21791)
     nTax:=TaxB_Table(nCompensation-11375,9)
  elseif (nCompensation>=21792)
     nTax:=TaxB_Table(nCompensation-21792,10)
  endif
return nTax

static function WTaxB_C2(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1270)
     nTax:=0.00
  elseif (nCompensation>=1271)  .and. (nCompensation<=1374)
     nTax:=TaxB_Table(nCompensation-1271,2)
  elseif (nCompensation>=1375)  .and. (nCompensation<=1582)
     nTax:=TaxB_Table(nCompensation-1375,3)
  elseif (nCompensation>=1583)  .and. (nCompensation<=1999)
     nTax:=TaxB_Table(nCompensation-1583,4)
  elseif (nCompensation>=2000)  .and. (nCompensation<=2832)
     nTax:=TaxB_Table(nCompensation-2000,5)
  elseif (nCompensation>=2833)  .and. (nCompensation<=3666)
     nTax:=TaxB_Table(nCompensation-2833,6)
  elseif (nCompensation>=3667)  .and. (nCompensation<=5332)
     nTax:=TaxB_Table(nCompensation-3667,7)
  elseif (nCompensation>=5333) .and. (nCompensation<=11582)
     nTax:=TaxB_Table(nCompensation-5333,8)
  elseif (nCompensation>=11583) .and. (nCompensation<=21999)
     nTax:=TaxB_Table(nCompensation-11583,9)
  elseif (nCompensation>=22000)
     nTax:=TaxB_Table(nCompensation-22000,10)
  endif
return nTax

static function WTaxB_C3(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=1478)
     nTax:=0.00
  elseif (nCompensation>=1479)  .and. (nCompensation<=1582)
     nTax:=TaxB_Table(nCompensation-1479,2)
  elseif (nCompensation>=1583)  .and. (nCompensation<=1791)
     nTax:=TaxB_Table(nCompensation-1583,3)
  elseif (nCompensation>=1792)  .and. (nCompensation<=2207)
     nTax:=TaxB_Table(nCompensation-1792,4)
  elseif (nCompensation>=2208)  .and. (nCompensation<=3041)
     nTax:=TaxB_Table(nCompensation-2208,5)
  elseif (nCompensation>=3042)  .and. (nCompensation<=3874)
     nTax:=TaxB_Table(nCompensation-3042,6)
  elseif (nCompensation>=3875)  .and. (nCompensation<=5541)
     nTax:=TaxB_Table(nCompensation-3875,7)
  elseif (nCompensation>=5542) .and. (nCompensation<=11791)
     nTax:=TaxB_Table(nCompensation-5542,8)
  elseif (nCompensation>=11792) .and. (nCompensation<=22207)
     nTax:=TaxB_Table(nCompensation-11792,9)
  elseif (nCompensation>=22208)
     nTax:=TaxB_Table(nCompensation-22208,10)
  endif
return nTax

static function WTaxB_C4(nCompensation)
local nTax
  if (nCompensation>=0)         .and. (nCompensation<=3374)
     nTax:=0.00
  elseif (nCompensation>=1688)  .and. (nCompensation<=3582)
     nTax:=TaxB_Table(nCompensation-1688,2)
  elseif (nCompensation>=1792)  .and. (nCompensation<=3999)
     nTax:=TaxB_Table(nCompensation-1792,3)
  elseif (nCompensation>=2000)  .and. (nCompensation<=4832)
     nTax:=TaxB_Table(nCompensation-2000,4)
  elseif (nCompensation>=2417)  .and. (nCompensation<=6499)
     nTax:=TaxB_Table(nCompensation-2417,5)
  elseif (nCompensation>=3250)  .and. (nCompensation<=8166)
     nTax:=TaxB_Table(nCompensation-3250,6)
  elseif (nCompensation>=4083)  .and. (nCompensation<=11499)
     nTax:=TaxB_Table(nCompensation-4083,7)
  elseif (nCompensation>=5750) .and. (nCompensation<=23999)
     nTax:=TaxB_Table(nCompensation-5758,8)
  elseif (nCompensation>=12000) .and. (nCompensation<=44832)
     nTax:=TaxB_Table(nCompensation-12000,9)
  elseif (nCompensation>=22417)
     nTax:=TaxB_Table(nCompensation-22417,10)
  endif
return nTax

static function TaxB_Table(nCompensation,nLevel)
local nTax
   do case
      case nLevel==1  ; nTax:=0.00
      case nLevel==2  ; nTax:=          nCompensation * 0.01
      case nLevel==3  ; nTax:=    1.04+(nCompensation * 0.03)
      case nLevel==4  ; nTax:=    7.29+(nCompensation * 0.07)
      case nLevel==5  ; nTax:=   36.46+(nCompensation * 0.11)
      case nLevel==6  ; nTax:=  128.13+(nCompensation * 0.15)
      case nLevel==7  ; nTax:=  253.13+(nCompensation * 0.19)
      case nLevel==8  ; nTax:=  569.79+(nCompensation * 0.24)
      case nLevel==9  ; nTax:= 2059.79+(nCompensation * 0.29)
      case nLevel==10 ; nTax:= 5090.63+(nCompensation * 0.35)
   endcase
return nTax

*!*********************************************************************
function GetSSS(nGross)
local nSSS := 0
  if     (nGross>=0001.00) .and. (nGross<=0149.99) ; nSSS:=  04.10
  elseif (nGross>=0150.00) .and. (nGross<=0199.99) ; nSSS:=  05.70
  elseif (nGross>=0200.00) .and. (nGross<=0249.99) ; nSSS:=  07.50
  elseif (nGross>=0250.00) .and. (nGross<=0349.99) ; nSSS:=  10.00
  elseif (nGross>=0350.00) .and. (nGross<=0499.99) ; nSSS:=  14.10
  elseif (nGross>=0500.00) .and. (nGross<=0699.99) ; nSSS:=  20.00
  elseif (nGross>=0700.00) .and. (nGross<=0899.99) ; nSSS:=  26.70
  elseif (nGross>=0900.00) .and. (nGross<=1099.99) ; nSSS:=  33.30
  elseif (nGross>=1100.00) .and. (nGross<=1399.99) ; nSSS:=  41.70
  elseif (nGross>=1400.00) .and. (nGross<=1749.99) ; nSSS:=  50.00
  elseif (nGross>=1750.00) .and. (nGross<=2249.99) ; nSSS:=  66.70
  elseif (nGross>=2250.00) .and. (nGross<=2724.99) ; nSSS:=  83.30
  elseif (nGross>=2725.00) .and. (nGross<=3249.99) ; nSSS:= 100.00
  elseif (nGross>=3250.00) .and. (nGross<=3749.99) ; nSSS:= 116.70
  elseif (nGross>=3750.00) .and. (nGross<=4249.99) ; nSSS:= 133.30
  elseif (nGross>=4250.00) .and. (nGross<=4749.99) ; nSSS:= 150.00
  elseif (nGross>=4750.00) .and. (nGross<=5249.99) ; nSSS:= 166.70
  elseif (nGross>=5250.00) .and. (nGross<=5749.99) ; nSSS:= 183.30
  elseif (nGross>=5750.00)                         ; nSSS:= 200.00
  else                                             ; nSSS:=   0.00
  endif
  return nSSS

*!*******************************************************************
function GetMED(nGross)
local nMED := 0
  if     (nGross>=0001.00) .and. (nGross<=0149.99) ; nMED:=  1.55
  elseif (nGross>=0150.00) .and. (nGross<=0199.99) ; nMED:=  2.20
  elseif (nGross>=0200.00) .and. (nGross<=0249.99) ; nMED:=  2.80
  elseif (nGross>=0250.00) .and. (nGross<=0349.99) ; nMED:=  3.75
  elseif (nGross>=0350.00) .and. (nGross<=0499.99) ; nMED:=  5.35
  elseif (nGross>=0500.00) .and. (nGross<=0699.99) ; nMED:=  7.50
  elseif (nGross>=0700.00) .and. (nGross<=0899.99) ; nMED:= 10.00
  elseif (nGross>=0900.00) .and. (nGross<=1099.99) ; nMED:= 12.50
  elseif (nGross>=1100.00) .and. (nGross<=1399.99) ; nMED:= 15.65
  elseif (nGross>=1400.00) .and. (nGross<=1749.99) ; nMED:= 18.75
  elseif (nGross>=1750.00) .and. (nGross<=2249.99) ; nMED:= 25.00
  elseif (nGross>=2250.00) .and. (nGross<=2724.99) ; nMED:= 31.25
  elseif (nGross>=2725.00)                         ; nMED:= 37.50
  else                                             ; nMED:=  0.00
  endif
  return nMED

*: End-of-File <Table.PRG> *******************************************