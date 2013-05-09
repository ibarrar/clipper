/***
*
*  Date.prg
*
*  Sample user-defined functions for manipulating dates
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: compile with /a /m /n /w
*
*/



/***
*
*  Mdy( <dDate> ) --> cDate
*
*  Convert a date to a string in the format "month dd, yyyy".
*
*  Parameter:
*     dDate - Date value to convert to a string
*
*  Returns: The date value in "long," string form
*
*/
FUNCTION Mdy( dDate )
   
   LOCAL cYear

   // Handle SET CENTURY
   IF SUBSTR( SET( _SET_DATEFORMAT ), -4 ) == "YYYY"
      cYear := STR( YEAR( dDate ))
   ELSE
      cYear := " " + SUBSTR( STR( YEAR( dDate )), 4, 2 )
   ENDIF

   RETURN ( CMONTH( dDate ) + " " + LTRIM( STR( DAY( dDate ))) + "," + cYear )



/***
*
*  Dmy( <dDate> ) --> cDate
*
*  Convert a date to string formatted as "dd month yyyy".
*
*  Parameter:
*     dDate - Date value to convert
*
*  Returns: The date value in european date format
*
*/
FUNCTION Dmy( dDate )
   
   LOCAL cYear

   // Handle SET CENTURY
   IF SUBSTR( SET( _SET_DATEFORMAT ), -4 ) == "YYYY"
      cYear := STR( YEAR( dDate ))
   ELSE
      cYear := " " + SUBSTR( STR( YEAR( dDate )), 4, 2 )
   ENDIF

   RETURN ( LTRIM( STR( DAY( dDate ))) + " " + CMONTH( dDate ) + cYear )



/***
*
*  DateAsAge( <dDate> ) --> nAge
*
*  Convert a date of birth to an age in years.
*
*  Parameter:
*     dDate - Birthdate for which to calculate the age
*
*  Returns: The number of years elapsed since <dDate>
*
*/
FUNCTION DateAsAge( dDate ) 
   
   LOCAL nAge := 0

   IF YEAR( DATE() ) > YEAR( dDate )
      
      nAge := YEAR( DATE() ) - YEAR( dDate )

      // Decrease the age by one if the date (month/day) has not yet
      // occurred this year
      IF ( MONTH( DATE() ) < MONTH( dDate )  .OR.  ;
         ( MONTH( DATE() ) == MONTH( dDate ) .AND. ;
           DAY( DATE() ) < DAY( dDate )            ;
         ))
         
         --nAge

      ENDIF
   ENDIF

   RETURN nAge



/***
*
*  AddMonth( <dDate>, <nMonths> ) --> dNewDate
*
*  Calculate a new date by adding a number of months to a given
*  date.
*
*  Parameters:
*     dDate   - Date value to add <nMonths> to
*     nMonths - Number of months to add to <dDate>
*
*  Returns: The date value representing <dDate> + <nMonths>
*
*/
FUNCTION AddMonth( dDate, nMonths)
   
   LOCAL nMonth
   LOCAL nDay
   LOCAL nYear
   LOCAL nLimit
   LOCAL nMonthAdd
   LOCAL nYearAdd
   LOCAL dNew
   
   // Break date up into its numeric components
   nMonth := MONTH( dDate )
   nDay   := DAY( dDate )
   nYear  := YEAR( dDate )

   // nLimit determines the minimum number of months that will push the
   // date into the next year.  If the number of months added to the date
   // exceeds this limit, the year must be advanced by one
   nLimit := 12 - nMonth + 1

   // Compute number of years to add
   nYearAdd := INT( nMonths / 12 )

   IF nMonths >= nLimit
      nYearAdd++
   ENDIF

   nYear += nYearAdd

   // Compute number of months to add and normalize month
   nMonthAdd := nMonths % 12 
   nMonth    := ( nMonth + nMonthAdd ) % 12

   // Convert numeric portions to new date
   dNew := NtoD( nMonth, nDay, nYear )

   RETURN ( dNew )



/***
*
*  DateAsArray( dDate ) --> aDate
*
*  Convert a date to an array of year, month, and day
*
*  Parameter:
*     dDate - Date value to convert into array form
*
*  Returns: The date in the format { nYear, nMonth, nDay }
*           If the parameter is invalid, an empty array ({}) is returned
*
*/
FUNCTION DateAsArray( dDate )
   
   LOCAL aDate := {}

   IF VALTYPE( dDate ) == "D"
      aDate := { YEAR( dDate ), MONTH( dDate ), DAY( dDate ) }
   ENDIF

   RETURN aDate



/***
*
*  ArrayAsDate( aDate ) --> dDate
*
*  Convert an array of year, month, and day to a date value
*
*  Parameter:
*     aDate - Array holding a date in the form { nYear, nMonth, nDay }
*
*  Returns: aDate in date value form
*
*/
FUNCTION ArrayAsDate( aDate )
   RETURN NtoD( aDate[2], aDate[3], aDate[1] )



/***
*
*  DateIsLeap( <dDate> ) --> lLeap
*
*  Determine if the year of a supplied date is a leap year
*
*/
FUNCTION DateIsleap( dDate )
   
   LOCAL nYear := YEAR( dDate )

   RETURN (( nYear % 4 ) == 0 )    .AND. ;
          ((( nYear % 100 ) != 0 ) .OR.  ;
          (( nYear % 400 ) == 0)   )



/***
*
*  NtoD( nMonth, nDay, nYear ) --> dNew
*
*  Convert a date passed as separate numeric parameters to a date value
*
*/
FUNCTION NtoD( nMonth, nDay, nYear )
   
   LOCAL cSavDateFormat := SET( _SET_DATEFORMAT, "MM/DD/YYYY" )
   LOCAL dDate

   dDate := CTOD( TRANSFORM( nMonth, "99/" ) + ;
                  TRANSFORM( nDay,   "99/" ) + ;
                  TRANSFORM( nYear,  "9999" )  )

   SET( _SET_DATEFORMAT, cSavDateFormat )

   RETURN ( dDate )

