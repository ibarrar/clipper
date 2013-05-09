#command @ <row>, <col> GET <var> [PICTURE <pic>] [MESSAGE <msg>] [WHEN <prev>] [VALID <postv>] => ;
         aadd(getlist,{0,0,"",<row>,<col>,{|v| if(pcount() > 0, <var> := v, <var>) },<pic>,<msg>,<{prev}>,<{postv}>})
         
#command @ <row>, <col> SAY <say> GET <var> [PICTURE <pic>] [MESSAGE <msg>] [WHEN <prev>] [VALID <postv>] => ;
         aadd(getlist,{<row>,<col>,<say>,<row>,<col>,{|v| if(pcount() > 0, <var> := v, <var>) },<pic>,<msg>,<{prev}>,<{postv}>})

#command @ <row>, <col> SAY <say> => ;
         SayString(<row>,<col>,<say>)

memvar getlist         
