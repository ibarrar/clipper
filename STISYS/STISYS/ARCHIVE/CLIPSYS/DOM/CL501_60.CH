/* Color Constants
*/

#define DATA_COLORS if(iscolor(),"N/W,W+/B,,,W/B","N/W,W+/N,,,W/N")
#define MENU_COLORS if(iscolor(),"N/BG,W+/BG,W+/R","N/W,N+/W,W/N")
#define STAT_COLORS if(iscolor(),"N/BG","N/W")

#define SELECT_BAR  chr(24)+chr(25)+chr(26)+chr(27)+"- Select   "+;
                    chr(17)+chr(217)+"-Choose"

#xcommand Charge => ;
          tunes({ {440,1}, {880,1} , {880,2},;
                {1046,4}, {880,2}, {446,4} } )
#xcommand Retreat => ;
          tunes({ {196,4}, {196,4}, {220,2},;
                { 164,2}, {196,2} , {196,2} } )
#xcommand NannyBoo => ;
          tunes( { {196,2}, {196,2}, {164,2}, ;
                 {220,2}, {196,4}, {196,4} } )

#xtranslate PopSound()  =>    Charge
#xtranslate UnPopSound() => Retreat
#xtranslate ErrorSound() => NannyBoo

#xtranslate BUMMER()                                                       ;
            => tunes({ {392,1}, {98,1}, {49,5} })
#xtranslate HEYTHERE()                                                     ;
            => tunes({ {392,1}, {880,1} })
#xtranslate OKDONE()                                                       ;
            => tunes({ {784,1}, {784,1} })

#xtranslate tunes(<a>) => ;
           aeval(<a>, { | a | tone(a\[1],a\[2]) } )


/* Eof Cl501_60.ch ->
*/