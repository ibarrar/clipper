
#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "
#define MY_FOOTSEP      "мом"


#define DELETED_MARK   Chr(7)

#ifdef COLOR_STAT 
 #define COLOR_SCREEN
#endif

// #define COLOR_SCREEN

#ifdef COLOR_SCREEN
  #define BAR1 if( access==VIEW_MODE,"Arrow_Keys-Navigate   Ctrl_End-Exit",
  #define BAR2  "F1-Help    Ins-Add    Del-Delete    Ctrl_End-Exit")
#else
  #define BAR1 if( access==VIEW_MODE,"Arrow_Keys-Navigate   Ctrl_End-Exit",
  #define BAR2  "F1-Help    Ins-Add    Del-Delete    Ctrl_End-Exit")
#endif
#define BAR BAR1 BAR2