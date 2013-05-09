/***
*
*  RddSys.prg
*
*  This program is run each time your application is started to setup
*  the proper default driver.  You should modify a copy of this file
*  if you wish to use a default RDD other than DBFNTX.
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

ANNOUNCE RDDSYS                        // This line must not change

INIT PROCEDURE RddInit
   REQUEST DBFNTX                      // Causes DBFNTX RDD to be linked in
                               
   rddSetDefault( "DBFNTX" )           // Set up DBFNTX as default driver

   RETURN

// eof: rddsys.prg
