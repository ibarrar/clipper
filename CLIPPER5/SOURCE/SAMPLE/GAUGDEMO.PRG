/***
*
*  GaugDemo.prg
*
*  Sample program to demonstrate the use of a bar progress gauge
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/

#include "Inkey.ch"

PROCEDURE GaugDemo
   
   LOCAL i
   LOCAL hGauge
   LOCAL nPercent
   
   CLS
   SET CURSOR OFF
   
   hGauge := GaugeNew( 5, 5, 7, MAXCOL() - 5, "W/B", "W+/B" )
   GaugeDisplay( hGauge )
   
   SETCOLOR( "W+/N" )
   @ 1,0 SAY PADC( "Gauge Demo", MAXCOL() )
   
   SETCOLOR( "W/N" )
   @ 3,0 SAY PADC( "Use , , PgUp and PgDn to change gauge, Esc to exit", MAXCOL() )
   
   nPercent := 0
   
   i := 0
   DO WHILE i <> K_ESC
      
      i := INKEY(0)
      
      DO CASE
      CASE i == K_UP
         nPercent += .01
         
      CASE i == K_DOWN
         nPercent -= .01
         
      CASE i == K_PGUP
         nPercent += .1
         
      CASE i == K_PGDN
         nPercent -= .1
      ENDCASE
      
      // Ensure that nPercent is within bounds
      IF nPercent < 0
         TONE(300, 1)
         nPercent := 0
      ENDIF
      
      IF nPercent > 1
         TONE(300, 1)
         nPercent := 1
      ENDIF
      
      GaugeUpdate( hGauge, nPercent )

   ENDDO
   
   SET CURSOR ON
   SETPOS( MAXROW(), 0 )
   
   RETURN
