/*****
 *
 * GET7.PRG
 *
 *
 * Clipper get7 /N /W
 * RTLINK FILE get7
 *
 */

#include "inkey.ch"

#define     FLD1     1
#define     FLD2     2
#define     FLD3     3
#define     FLD4     4
#define     FLD5     5
#define     FLD6     6
#define     FLD7     7
#define     FLD8     8

FUNCTION Main()
   LOCAL aArray, GetList := {}
   LOCAL lWasFound := .F.
   LOCAL cScreen

   cScreen := savescreen()

   DBUSEAREA( , , "test" )
   DBSETINDEX( "test3" )

   SCROLL()
   WHILE .T.
      // "Phantom" empty record
      DBGOTO( LASTREC() + 1 )
      aArray := LoadData()

      // Please NOTE the by reference operator (@) on the array
      @ 10,10 GET aArray[FLD3] ;
                  VALID LookUp(TRIM(aArray[FLD3]), @aArray,;
                                GetList, @lWasFound)
      @ 12,10 GET aArray[FLD4]
      @ 14,10 GET aArray[FLD7]
      @ 16,10 GET aArray[FLD2]
      @ 18,10 GET aArray[FLD8]
      READ

      IF LASTKEY() == K_ESC
         EXIT

      ENDIF

      IF !lWasFound
         DBAPPEND()

      ENDIF

      ReplData(aArray)
      DBCOMMIT()

   END

   restscreen(,,,,cScreen)
   RETURN(NIL)

STATIC FUNCTION LoadData()
   LOCAL aArray[FCOUNT()]
   AEVAL( aArray, {|x,i| aArray[i] := FIELDGET(i)} )
   RETURN (aArray)

STATIC FUNCTION ReplData(aArray)
   AEVAL( aArray, {|x,i| FIELDPUT(i, x)} )
   RETURN (.T.)

STATIC FUNCTION LookUp(cVar, aArray, GetList)
   IF DBSEEK(cVar)
      // Key was found!
      aArray := LoadData()

      // Refresh Gets
      AEVAL( GetList, {|g| g:display()} )

   ENDIF
   RETURN (.T.)

// EOF - GET7.PRG //
