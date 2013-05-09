/***
*
*	Dict.prg
*
*	Keyed dictionary utility.
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*	Uses an array to contain list of "dictionary" entries.
*	Each entry consists of a character key and a value of any type.
*	New keys and values can be entered, and existing values can be
*	retrieved based on their key.
*
*
*  Index of functions contained in Dict.prg (this file):
*  -----------------------------------------------------
*
*  DictNew() --> <aDictionary>
*
*     Creates and returns an empty dictionary.
*
*
*  DictAt( <aDictionary>, <cKey> ) --> <xValue>
*
*     Returns the <xValue> associated with <cKey> in dictionary,
*     NIL if <cKey> is not present in dictionary.
*
*
*  DictPut( <aDictionary>, <cKey>, <xValue> ) --> <xValue>
*
*     Associates <cKey> to <xValue> in <aDictionary>. Returns
*		<xValue>.
*
*
*  DictPutPair( <aDictionary>, <aPair> ) --> <aPair>
*
*		Adds <aPair> to <aDictionary>. Returns <aPair>.
*     <aPair> is a <cKey>/<xValue> pair: { <cKey>, <xValue> }.
*
*
*  DictRemove( <aDictionary>, <cKey> ) --> <aDictionary>
*
*     Removes the <cKey>/<xValue> pair for <cKey>.
*		Returns <aDictionary>.
*
*
*  DictEval( <aDictionary>, <bBlock> ) --> <aDictionary>
*
*		Evaluates <bBlock> against each <cKey>/<xValue> pair in
*		dictionary. Pair is passed to block as { <cKey>, <xValue> }
*     (pair array indexes defined in "Dict.ch").
*		Returns <aDictionary>.
*
*
*  NOTES:
*     Compile with /a /m /n /w
*
*     Key values must all be of type 'C' (character), case is significant.
*
*		These dictionaries are useful if you want to keep a list
*		of keyed values without using a database. Since they're
*     arrays, you can hang onto them with any variable or
*		array element (handy for keeping track of multiple "cargo"
*		items, for example). If you have lots of values, though,
*		a database/index is usually more appropriate.
*
*/

#include "Dict.ch"


// Hash machinery
#define KEY_HASH( key )       ( BIN2W( key ) + BIN2W( SUBSTR(TRIM( key ), -2 )))
#define HASH_VAL( key, size ) ( ( KEY_HASH( key ) % size ) + 1 )

#define DEFAULT_HASH_SIZE		31
#define MAX_ARRAY_LEN			4096



/***
*
*  DictNew() --> aDictionary
*
*  Create a new, empty dictionary
*
*/
FUNCTION DictNew()

	LOCAL i
   LOCAL aDict

   aDict := ARRAY( DEFAULT_HASH_SIZE )

   FOR i := 1 TO DEFAULT_HASH_SIZE
      aDict[i] := {}
	NEXT

   RETURN ( aDict )



/***
*
*  DictAt( <aDict>, <cKey> ) --> xValue
*
*  Return the value for a particular key
*
*/
FUNCTION DictAt( aDict, cKey )

   LOCAL aBucket     // Array that contains the key/value pair
   LOCAL nPairNo     // Location of the matching pair, zero if none matches

   aBucket := aDict[ HASH_VAL( cKey, LEN( aDict )) ]
   nPairNo := ASCAN( aBucket, { |aPair| aPair[DI_KEY] == cKey } )

   IF ( nPairNo == 0 )
      RETURN ( NIL )    // NOTE
   END

   RETURN ( aBucket[nPairNo][DI_VAL] )



/***
*
*  DictPut( <aDictionary>, <cKey>, <xValue> ) --> <xValue>
*
*  Add or replace the value for a particular key
*  Returns the value being added
*
*/
FUNCTION DictPut( aDict, cKey, xVal )

   DictPutPair( aDict, { cKey, xVal } )   // Put an item by putting the pair

   RETURN ( xVal )



/***
*
*  DictPutPair( <aDictionary>, <aPair> ) --> <aPair>
*
*  Add or replace key/value pair for a particular key
*  Returns the pair being added
*
*/
FUNCTION DictPutPair( aDict, aPair )

   LOCAL aBucket        // Contains the key/value pair
   LOCAL cKey           // Key value of the pair to be 'put'
   LOCAL nLocation      // Location in aDict where aPair will reside

   cKey := aPair[ DI_KEY ]

   aBucket := aDict[ HASH_VAL( cKey, LEN( aDict )) ]
   nLocation := ASCAN( aBucket, { |aPair| aPair[ DI_KEY ] == cKey } )

   IF ( nLocation == 0 )
      AAdd( aBucket, aPair )
      nLocation := Len( aBucket )
   ELSE
      aBucket[nLocation] := aPair
   ENDIF

   IF ( nLocation > 3 .AND. LEN( aDict ) < MAX_ARRAY_LEN )
		// this bucket is big, grow dict
      DictResize( aDict )
   ENDIF

   RETURN ( aPair )



/***
*
*  DictRemove( <aDict>, <cKey> ) --> <aDict>
*
*  Remove the key/value pair for a particular key
*  Returns a reference to the dictionary
*
*/
FUNCTION DictRemove( aDict, cKey )

   LOCAL aBucket     // Pair corresponding to cKey
   LOCAL nLocation   // Location of the pair in aDict

   aBucket := aDict[ HASH_VAL( cKey, LEN( aDict )) ]
   nLocation := ASCAN( aBucket, { |aPair| aPair[ DI_KEY ] == cKey } )

   IF ( nLocation <> 0 )
      ADEL( aBucket, nLocation )
      ASIZE( aBucket, LEN( aBucket ) - 1 )
   ENDIF

   RETURN ( aDict )



/***
*
*  DictEval( <aDict>, <bCode> ) --> <aDict>
*
*  Evaluate block against each pair in the dictionary
*  The pair is passed to the block.
*
*  Returns reference to <aDict>
*
*/
FUNCTION DictEval( aDict, bCode )

   AEVAL( aDict, ;
      { |aBucket| AEVAL( aBucket, { |aPair| EVAL( bCode, aPair ) } ) } )

   RETURN ( aDict )



/***
*
*  DictResize( <aDict> ) --> aNewDictionary
*
*  Grows dictionary hash table
*
*  NOTES:
*     Rehashes, invalidating any direct indexes into <aDict> held
*     by caller across this call
*
*     Since DictResize is a service routine, it is declared STATIC and is
*     is invisible to other program (.prg) files.
*
*/
STATIC FUNCTION DictResize( aDict )

   LOCAL aOldDict
   LOCAL nNewDictSize
   LOCAL nCounter

   // Make a copy of the old dictionary
   aOldDict := ARRAY( LEN( aDict ))
   ACOPY( aDict, aOldDict )

   // Resize and clear the dictionary
   nNewDictSize := MIN( LEN( aDict ) * 4 - 1, MAX_ARRAY_LEN )
   ASIZE( aDict, nNewDictSize )

   FOR nCounter := 1 TO nNewDictSize
      aDict[nCounter] := {}
	NEXT

   // Rehash pairs into dict
   AEVAL( aOldDict,                                                     ;
          { |aBucket| AEVAL( aBucket,                                   ;
                             { |aPair| DictPutPair( aDict, aPair ) } )  ;
          } )

   RETURN ( aDict )
