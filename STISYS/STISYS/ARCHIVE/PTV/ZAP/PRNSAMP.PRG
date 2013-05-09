tranfile = 'AR' + REGMM + REGDD + REGYY
use &tranfile inde &tranfile
set console off
*set device to print
report form ptv_rep to file ptv_rep
set console on
*set devi to screen
