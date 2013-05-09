/***
*
*   Ntxerr.prg
* 
*   Replaceable DBFNTX error handler error handler.
*
*   Copyright (c) 1993, Computer Associates International, Inc.
*   All rights reserved.
*
*   Contains the error handler for lock time-outs.  The default behavior
*   is to just retry forever (backwards compatible).
*
*   A better behavior would be to warn the user to notify the Network 
*   Administrator that some other user may have hung with an active lock
*   on the index.  (Or they have it in a window that doesn't have any 
*   background ticks assigned to it.)
*
*   Warning: changing the behavior to allow a lock to failure to be 
*   ignored will produce different results depending on the operation
*   that is in progress at the time the lock failed.  The index will 
*   most likely be left in an invalid state and should be recreated.
*
*/

#include "error.ch"


ANNOUNCE _ntxerr



INIT PROCEDURE InitHandler()
   LOCAL bDefError

	bDefError := ErrorBlock( { |err| LockErrHandler( err, bDefError ) } )

   return

	

STATIC FUNCTION LockErrHandler( oErr, bDefError )

   if ( oErr:genCode == EG_LOCK )
   
      return ( .T. )

	end

   return ( eval( bDefError, oErr ) )  // chain back to default error handler
		
