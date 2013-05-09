//#include "powerpos.ch"
#include "spec_key.ch"
#include "message.ch"
#include "config.ch"

#define DEFINE_PASSWORD  "8812405"

function Get_Password()
local cPass := ""
local cKey,cData
local aPass_ := Access_Pass()

   while .T.
     disp_clr()      
     DISPTEXTXY(1,1,0,0,1,1,"PASSWORD PROTECTION.")
     DISPTEXTXY(2,1,0,0,2,1,"PLS. ENTER PASSWORD.")
     MsgAreaDisp("PLS. ENTER PASSWORD.")
     while .T.

*       DISPTEXTXY(3,1,0,0,0,0,pad(repl("*",len(cPass))+"_",20))

       disp_data(pad(repl("*",len(cPass))+"_",20))
        
       cKey := input()
       
       do case
          case !empty(cData := is_number())
              if len(cPass) < MAXIMUM_INPUT_LEN
                 cPass += cData
              endif      
              loop
#ifdef ALPHA_NUMERIC
          case !empty(cData := is_alpha() )
              if len(cPass) < MAXIMUM_INPUT_LEN
                 cPass += cData
              endif      
              loop
#endif          
          case cKey == BACK_SPACE
              cPass := subs(cPass,1,len(cPass)-1)
              loop
          case cKey == CLR
              if cPass == ""
                 exit
              endif   
              cPass   := ""                        
          case cKey == ENTER
              if cPass == ""
                MsgAreaDisp("* INVALID PASSWORD *")   
                tone(300,16)                  
                MsgAreaDisp("PLS. ENTER PASSWORD.")
              else
               exit
              endif   
          otherwise
              ErrorDisp(MSG_D006) // probable key sequence error
              MsgAreaDisp("PLS. ENTER PASSWORD.")
       endcase   
       
     enddo

     
     if empty(cPass)
        MsgAreaDisp("* REQUEST ABORTED..*")
        Bummer()
        exit
     elseif  (aScan(aPass_, { |x| cPass  == x } ) > 0)
        MsgAreaDisp("* ACCESS GRANTED ! *")
        HeyThere()
        exit
     else
        MsgAreaDisp("* INVALID PASSWORD *")   
        tone(300,16)
        cPass := ""
     endif   
           
   enddo  
   

return (aScan(aPass_, { |x| cPass  == x } ) > 0)

static function Access_Pass()
local Array_  := {}


    aAdd( Array_ , DEFINE_PASSWORD )
    aAdd( Array_ , config(POS_PASSWORD) )

return Array_


