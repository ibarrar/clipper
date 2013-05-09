/*****
 *
 * GET9.PRG
 *
 *
 * Clipper get9 /N /W
 * RTLINK FILE get9
 *
 */

#define  AMEX       1
#define  DINERS     2

FUNCTION Main()
   LOCAL GetList := {}

   // Default
   LOCAL nType := AMEX
   LOCAL cCard := SPACE(14)

   // Arrays with definitions for both cards (AMEX/DINERS)
   LOCAL aSize := { SPACE(15), SPACE(14) }
   LOCAL aPict := { "@R 9999-999999-99999", "@R 9999-999999-9999" }

   // Screen
   LOCAL cScreen

   cScreen := savescreen()
   SCROLL()
   @ 10, 20 SAY "Card Type: (1) American  (2) Diners "
   @ 12, 20 SAY "Number:"

   // Edit
   @ 10, 57 GET nType PICTURE "9" VALID nType == AMEX .OR. ;
                                        nType == DINERS

   @ 12, 52 GET cCard SEND preBlock := {|| SCROLL( 12, 52, 12, 72 ), .T.};
            SEND reader := {|get| get:picture:= aPict[ nType ],;
                 get:varPut( aSize[ nType ] ),;
                 GetReader(get)}

   ReadModal( Getlist ) // or READ if you wish

   // Show it!
   ?
   ? nType
   ? cCard

   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET9.PRG //
