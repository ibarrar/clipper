/*****
 *
 * BROWSKIP.DBF
 * Custom skipp blocks for WHILE scoping
 *
 */

/*****
 *
 * Skip to top of condition
 *
 */

FUNCTION GoTopDb(cCond)
   DBSEEK(cCond)
   RETURN (NIL)

/*****
 *
 * Skip to the bottom of condition
 *
 */

FUNCTION GoBottomDb(cCond)
   DBSEEK(SUBSTR(cCond, 1, LEN(cCond) - 1) +;
            CHR(ASC(SUBSTR(cCond, LEN(cCond))) + 1), .T.)
   DBSKIP(-1)
   RETURN (NIL)

/*****
 *
 * Main Skippper
 *
 */

FUNCTION Skipper( nRequest, bCond )
   // nRequest is the number of records to be skipped
   // nActually is the actual number of records skipped
   LOCAL nActually := 0

   IF (nRequest == 0)
      DBSKIP(0)

   ELSEIF (nRequest > 0) .AND. (!EOF())
      // Keep skipping until number of skips
      // requested is satisfied
      WHILE (nActually < nRequest)
         DBSKIP(1)
         // Evaluate condition for each record
         IF !EVAL(bCond) .OR. EOF()
            DBSKIP(-1)
            EXIT

         ENDIF
      
         // Skip counter 
         nActually++

      END

   ELSEIF (nRequest < 0)
      WHILE (nActually > nRequest)
         DBSKIP(-1)
         // This is check is important!
         // BOF bangs do not sit on phanton record
         // Rather, the top record is evaluated, 
         // and may meet the condition
         IF BOF()
            EXIT

         ENDIF
         // Evaluate condition for each record
         IF !EVAL(bCond)
            DBSKIP(1)
            EXIT

         ENDIF

         // Skip counter
         nActually--

      END

   ENDIF
   // Returns number of records actually skipped
   RETURN (nActually)

// EOF - BROWSKIP.DBF //
