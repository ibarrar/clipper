/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it310012.prg - Hourly Sales Report
			for Inventory Tracking System (ITS)

   acr / 05.17.93
   dcn / 09.14.93
   eso / 07.04.95 
       - edited hourly conversion
   
============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "HR-SLS-M"
#define RPT_NAME "HOURLY SALES REPORT"
#define THIS_WIDTH 221 + LEFT_MARGIN

STATIC nPage := 0, nTCost := 0, footer_now := 0

STATIC aHRSale
FUNCTION it310012()

	LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
	LOCAL dRdate := date(), nDOW := 0, nTF := 0, cBuffer := space(31)
	LOCAL nCCount := 0, nICount := 0, nTSale := 0
	LOCAL nD1 := 0, nD2 := 0, nD3 := 0, i, j
     local nGoPrint := 2

	/* Create a three-dimensional array. First dimension is Day of Week;
	   second dimension is the 37 time frames, and the third dimension
	   contains customer count, item count and total sale. */
	aHRSale := array ( 7, 24, 3 )
   /* Change time frame from 36 to 24) */

	for i:= 1 to 7   // Zero out all elements in the array first.
         for j:= 1 to 24
          aHRSale [i, j, 1] := aHRSale [i, j, 2] := aHRSale [i, j, 3] := 0
	 next
	next

	nPage := 0

	nOldCursor = setcursor ( SC_NONE )

	// Create display window.
	window( 19, 1, 22, 60, CONFIRM_COLOR )
	@ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

	if NetUse("HR",DB_SHARED,NUM_SECONDS)
      Set Index to HR_001 
   endif   

	while !HR->(Eof())

		// Convert report date from string to date and get day of week.
		nDOW := dow ( HR->HR_001 )

		// Cycle through all 37 time frames.

		for nTF := 1 to 24	// This is time frame indicator.

			// Transfer contents of field for conversion.
			cBuffer = fieldget ( nTF + 1 )

			// Test for zero value in order not to overwrite
         // previous values if reading was done more than
         // once for a specific day of week. 

			// Convert customer count.

         /*************************************    
         eso / 07-04-95
         for RS35 machine
         
               010019330300000001001001                  
               123456789012345678901234
               
                2 - key
               10 - total
                6 - count customer
                6 - count quantity
                
               offset  1 - key 
                       3 - total 
                      13 - cust 
                      19 - qty 
         **************************************/              
                
               
         //if aHRSale[nDOW, nTF, 1] == 0
                 // edited for rs35
          	  // aHRSale[nDOW, nTF, 1] +=  val (substr ( cBuffer,  9, 6 ))         
          	  aHRSale[nDOW, nTF, 1] +=  val (substr ( cBuffer, 11, 6 ))
         // endif
			
			// Convert item count.
         //if aHRSale[nDOW, nTF, 2] == 0
               // edited for rs35         
               // aHRSale[nDOW, nTF, 2] += val (substr ( cBuffer,  15, 6 ))         
              aHRSale[nDOW, nTF, 2] += val (substr ( cBuffer,  17, 6 ))
         // endif 

			// Convert total cost.
         //if aHRSale[nDOW, nTF, 3]  == 0
                // edited for rs35
                // aHRSale[nDOW, nTF, 3] += val (substr ( cBuffer, 1, 8 )) * 0.01 
              aHRSale[nDOW, nTF, 3] += val (substr ( cBuffer, 1, 10 )) * 0.01 
         //endif 
		next
		
		skip
	enddo

	close all

#ifdef TO_FILE
	set printer to ".\"+RPT_ID
#endif

	set device to printer
	set printer on
	set console off

	for nD2 := 1 to 24	// The 24 time frames.

		// Check for conditional page eject.
		if it390002 ( RPT_ID, PAGE_LEN, TOP_MARGIN, BOT_MARGIN, LEFT_MARGIN, RIGHT_MARGIN, nPage, THIS_WIDTH )

			// Standard page header routine.
			it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
			nPage++

			// Advance to next row.
			// ? MARGIN 

			// Print the headers for this report.
			it31001201()

		endif

		// Print on next row.
		 ? MARGIN + tran( nD2, "999999")

       // Move over by 3
       ?? space(4)     

		for nD1 := 1 to 7	// All the days of a week

			// Print on same row.
			?? space(1) + tran( aHRSale[nD1, nD2, 1], "999,999" )
			?? space(1) + tran( aHRSale[nD1, nD2, 2], "999,999" )
			?? space(1) + tran( aHRSale[nD1, nD2, 3], "99,999,999.99" )
		next

	next

	 ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
	it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
	eject

	set device to screen
	set printer off
	set console on
	set cursor on
	set printer to

	// Remove window.
	killwindow()
	tone ( 2100, 3 )

	// Restore cursor shape.
	setcursor ( nOldCursor )

	// Restore color set.
	setcolor ( cOldClr )

     // Screen or Printed Reports.
     RepGen( ".\"+RPT_ID, RPT_NAME, 1, 238 )

RETURN NIL

/*============================================================================
	Page Header
============================================================================*/
STATIC FUNCTION it31001201

		LOCAL nI := 0

       ? MARGIN + "TIME FRAME" 

		for nI := 1 to 7
			?? space(1) + padl ( "Cust", 7 )
			?? space(1) + padl ( "Item", 7 )
			?? space(1) + padl ( "Total Sold", 13 )
		next

		 ? MARGIN + repl ( "-", THIS_WIDTH - LEFT_MARGIN)
RETURN NIL
