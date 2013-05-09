#include "message.ch"

function disp_ready()

   // additional customer display (2x20)
   DISPTEXTXY(0, 0, 0, 0, 1, 1, "CASHIER READY       ")
   DISPTEXTXY(0, 0, 0, 0, 2, 1, "SIGN-ON:            ")

#ifdef DEF_DISP4X20
   // cashier display (4x20)
   DISPTEXTXY(1, 1, 0, 0, 0, 0, "ENTER CASHIER CODE  ")
   DISPTEXTXY(2, 1, 0, 0, 0, 0, "SIGN-ON : _         ")
   DISPTEXTXY(3, 1, 0, 0, 0, 0, "MESSAGE :           ")
#endif   

   // message box
   MsgAreaDisp(MSG_D002)
   
return nil

