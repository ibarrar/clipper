*
*        BLFRGPRG - Fragmentation display program
*
declare x [1000]
m = memory (0)

for i = 1 To m             && Loop through a few times
  x [i] = space (1000)     && Take some big blocks
next i
for i = 1 to m             && Loop through a few times
   x [i] = "  "            && Replace them with some small ones
next
clear
blidisfrg ()               && Display the fragmentation
@ 23,0
wait
blimempak (-1)             && Pack memory
clear
blidisfrg ()               && Display the fragmentation again
@ 23,0
wait
