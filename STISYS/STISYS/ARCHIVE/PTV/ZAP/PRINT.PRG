mastfile = "MR" + REGMM + REGDD + REGYY
use &mastfile inde &mastfile

report form ptv_rep to file ptv_rep.txt
!read ptv_rep.txt
