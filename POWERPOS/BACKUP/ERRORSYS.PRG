/***
*
*	Errorsys.prg
*
*  Standard Clipper error handler
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile:  /m /n /w
*
*/

#include "error.ch"
#define DISPLAY_ERRORS

#define  lstr(n)  ltrim(str(n))
#define  YN(L)    if(L, "Yes", "No ")


// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)


// used below
#define NTRIM(n)		( LTrim(Str(n)) )



/***
*	ErrorSys()
*
*	Note:  automatically executes at startup
*/

proc ErrorSys()
	ErrorBlock( {|e| DefError(e)} )
return



/***
*	DefError()
*/
static func DefError(e)
local filename := "err_" + substr(dtoc(date()), 1, 2) + ;
                  substr(dtoc(date()), 4, 2) + ".txt"
local i, cMessage, aOptions, nChoice
static lDejavu := .F.

   if (lDejavu)  
      power_end()             
      // give up
      ErrorLevel(1)
   
      ERRORINHANDLER()
   endif   

   lDejavu := .T.

	// by default, division by zero yields zero
	if ( e:genCode == EG_ZERODIV )
		return (0)
	end

	// for network open error, set NETERR() and subsystem default
	if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )

		NetErr(.t.)
		return (.f.)									// NOTE

	end


	// for lock error during APPEND BLANK, set NETERR() and subsystem default
	if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )

		NetErr(.t.)
		return (.f.)									// NOTE

	end

	// build error message
	cMessage := ErrorMessage(e)

	// display message and traceback
	if ( !Empty(e:osCode) )
		cMessage += " (DOS Error " + NTRIM(e:osCode) + ") "
	end
#ifdef SAVE_ERRORS
  set(_SET_ALTFILE,filename,.T.)
  set(_SET_ALTERNATE,.T.)

  ?  "*** System Error Occurred ***"
  ?  "DATE : " + dtoc(date()) 
  ?  "TIME : " + time() + CRLF
  ?  "DESCRIPTION : " + cMessage
  ?
  

  set(_SET_ALTFILE,"")
  set(_SET_ALTERNATE,.F.)
  close alternate    
  
#endif   

*	? cMessage
#ifdef DISPLAY_ERRORS   
   A_RJS_PRNT(1, 1, 0,cMessage,0)  
#endif   
  
	i := 2
	while ( !Empty(ProcName(i)) )
		cMessage :=  "Called from "+ Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "
*      ? cMessage                   
#ifdef DISPLAY_ERRORS                   
      A_RJS_PRNT(1, 1, 0,cMessage,0)                     
#endif      
		i++
	end

#ifdef DISPLAY_ERRORS                   
   A_RJS_FEED(1, 1, 0, 1)
   A_RJS_PRNT(1, 1, 0,"FEMA BUSINESS SYSTEM CORP.",0)
   A_RJS_PRNT(1, 1, 0,"FEMA BLDG. #44 Buendia Ave. Mkt.",0)
   A_RJS_PRNT(1, 1, 0,"Tel:8430966-70 Fax:817-5869",1)
   A_RJS_FEED(1, 1, 0, 1)   
   prnt_end()   
#endif

   // power_end()   

   lDejavu := .F.
   
   // give up
   // ErrorLevel(1)
   // QUIT

   BREAK 

return (.f.)




/***
*	ErrorMessage()
*/
static func ErrorMessage(e)
local cMessage


	// start error message
	cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )


	// add subsystem name if available
	if ( ValType(e:subsystem) == "C" )
		cMessage += e:subsystem()
	else
		cMessage += "???"
	end


	// add subsystem's error code if available
	if ( ValType(e:subCode) == "N" )
		cMessage += ("/" + NTRIM(e:subCode))
	else
		cMessage += "/???"
	end


	// add error description if available
	if ( ValType(e:description) == "C" )
		cMessage += ("  " + e:description)
	end


	// add either filename or operation
	if ( !Empty(e:filename) )
		cMessage += (": " + e:filename)

	elseif ( !Empty(e:operation) )
		cMessage += (": " + e:operation)

	end

return (cMessage)


/*  ? "Available    :"
  ? "Memory         (0)  "+lstr(MEMORY(0))
  ? "Largest block  (1)  " +lstr(memory(1))
  ? "Run area       (2)  " +lstr(memory(2))         
*/


      
