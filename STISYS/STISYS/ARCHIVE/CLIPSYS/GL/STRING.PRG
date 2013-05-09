/***
*
*  String.prg
*  Sample user-defined functions for processing character strings
*
*  Copyright, Nantucket Corporation, 1990
*
*  NOTE: compile with /n/w/a/m
*/

*function ConvertDate(cStrDate)
*local cMonth,MM,DD,YY
*   cMonth:=SubStr(cStrDate,3,3)
*   do case
*      case cMonth=="JAN" ; MM:="01"
*      case cMonth=="FEB" ; MM:="02"
*      case cMonth=="MAR" ; MM:="03"
*      case cMonth=="APR" ; MM:="04"
*      case cMonth=="MAY" ; MM:="05"
*      case cMonth=="JUN" ; MM:="06"
*      case cMonth=="JUL" ; MM:="07"
*      case cMonth=="AUG" ; MM:="08"
*      case cMonth=="SEP" ; MM:="09"
*      case cMonth=="OCT" ; MM:="10"
*      case cMonth=="NOV" ; MM:="11"
*      case cMonth=="DEC" ; MM:="12"
*   endcase
*   DD:=SubStr(cStrDate,1,2)
*   YY:=SubStr(cStrDate,6,2)
*return  CToD(MM+"/"+DD+"/"+YY)

*function CompleteDate(cString)
*local MM,DD,YY,cMonth
*   DD:=SubStr(cString,1,2)+", "
*   YY:="19"+SubStr(cString,6,2)
*   cMonth:=SubStr(cString,3,3)
*   do case
*      case cMonth=="JAN" ; MM:="January "
*      case cMonth=="FEB" ; MM:="February "
*      case cMonth=="MAR" ; MM:="March "
*      case cMonth=="APR" ; MM:="April "
*      case cMonth=="MAY" ; MM:="May "
*      case cMonth=="JUN" ; MM:="June "
*      case cMonth=="JUL" ; MM:="July "
*      case cMonth=="AUG" ; MM:="August "
*      case cMonth=="SEP" ; MM:="September "
*      case cMonth=="OCT" ; MM:="October "
*      case cMonth=="NOV" ; MM:="November "
*      case cMonth=="DEC" ; MM:="December "
*   endcase
*return MM+DD+YY

/***
*  ListAsArray( <cList>, <cDelimiter> ) --> aList
*  Convert a delimited string to an array
*
*/
FUNCTION ListAsArray( cList, cDelimiter )
   LOCAL nPos
   LOCAL aList := {}                            // Define an empty array

   IF cDelimiter = NIL
      cDelimiter := ","
   ENDIF
   //
   DO WHILE (nPos := AT(cDelimiter, cList)) != 0
      AADD(aList, SUBSTR(cList, 1, nPos - 1))   // Add a new element
      cList := SUBSTR(cList, nPos + 1)
   ENDDO
   AADD(aList, cList)                           // Add final element
   //
   RETURN aList                                 // Return the array



/***
*  Occurs( <cSearch>, <cTarget> ) --> nCount
*  Determine the number of times <cSearch> is found in <cTarget>
*
*/
FUNCTION Occurs( cSearch, cTarget )
   LOCAL nPos, nCount := 0
   DO WHILE !EMPTY( cTarget )
      IF (nPos := AT( cSearch, cTarget )) != 0
         nCount++
         cTarget := SUBSTR( cTarget, nPos + 1 )
      ELSE
         // End of string
         cTarget := ""
      ENDIF
   ENDDO
   RETURN nCount



/***
*  Proper( <cString> ) --> cProper
*  Capitalize each word in a string
*
*/
FUNCTION Proper( cString )
   LOCAL nPos, cWord, cProper := ""
   DO WHILE !EMPTY( cString )
	  IF (nPos := AT(" ", cString)) != 0
		 cWord := SUBSTR( cString, 1, nPos )
		 cString := SUBSTR( cString, nPos + 1 )
      ELSE
         // End of string
		 cWord := cString
		 cString := ""
      ENDIF
      cProper := cProper + UPPER(SUBSTR(cWord, 1, 1)) + SUBSTR(cWord, 2)
   ENDDO
   RETURN cProper


#ifdef NOTDEF

// duplicates StrZero() defined in EXAMPLEP.PRG

/***
*   StrZero( <nNumber>, <nLength>, <nDecimals> ) --> cNumber
*   Convert a numeric to a string padded with leading zeros
*
*/
FUNCTION StrZero( n, nLength, nDecimals )
   LOCAL cNumber
   IF PCOUNT() = 3
      cNumber = STR(n, nLength, nDecimals)
   ELSEIF PCOUNT() = 2
      cNumber = STR(n, nLength)
   ELSE
      cNumber = STR(n)
   ENDIF

   IF "-" $ cNumber
      // Negative number, move the minus sign in front of zeros
      RETURN "-" + REPLICATE("0", LEN(cNumber) - LEN(LTRIM(cNumber))) +;
            SUBSTR(cNumber, AT("-", cNumber) + 1)
   ELSE
      // Positive number
      RETURN REPLICATE("0", LEN(cNumber) - LEN(LTRIM(cNumber))) +;
            LTRIM(cNumber)
   ENDIF

#endif
