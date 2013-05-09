/***
*
*  Mod.prg
*
*  Summer '87 MOD() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	MOD( <expN1>, <expN2> )
*
*	Return remainder of <expN1> divided by <expN2>
*
*	Note: Difference between the dBASE modulus function and the Clipper
*         modulus operator is indicated by an arrow <-->:
*
*         Clipper operator:        dBASE function:
*         -----------------        -----------------
*          3 %  3 ::=  0.00        MOD( 3, 3) ::=  0      
*          3 %  2 ::=  1.00        MOD( 3, 2) ::=  1      
*          3 %  1 ::=  0.00        MOD( 3, 1) ::=  0      
*          3 %  0 ::=  0.00  <-->  MOD( 3, 0) ::=  3      
*          3 % -1 ::=  0.00        MOD( 3,-1) ::=  0      
*          3 % -2 ::=  1.00  <-->  MOD( 3,-2) ::= -1      
*          3 % -3 ::=  0.00        MOD( 3,-3) ::=  0      
*                                                            
*         -3 %  3 ::=  0.00        MOD(-3, 3) ::=  0      
*         -3 %  2 ::= -1.00  <-->  MOD(-3, 2) ::=  1      
*         -3 %  1 ::=  0.00        MOD(-3, 1) ::=  0      
*         -3 %  0 ::=  0.00  <-->  MOD(-3, 0) ::= -3      
*         -3 % -1 ::=  0.00        MOD(-3,-1) ::=  0      
*         -3 % -2 ::= -1.00        MOD(-3,-2) ::= -1      
*         -3 % -3 ::=  0.00        MOD(-3,-3) ::=  0      
*                                                            
*          3 %  3 ::=  0.00        MOD( 3, 3) ::=  0      
*          2 %  3 ::=  2.00        MOD( 2, 3) ::=  2      
*          1 %  3 ::=  1.00        MOD( 1, 3) ::=  1      
*          0 %  3 ::=  0.00        MOD( 0, 3) ::=  0      
*         -1 %  3 ::= -1.00  <-->  MOD(-1, 3) ::=  2      
*         -2 %  3 ::= -2.00  <-->  MOD(-2, 3) ::=  1      
*         -3 %  3 ::=  0.00        MOD(-3, 3) ::=  0      
*                                                            
*          3 % -3 ::=  0.00        MOD( 3,-3) ::=  0      
*          2 % -3 ::=  2.00  <-->  MOD( 2,-3) ::= -1      
*          1 % -3 ::=  1.00  <-->  MOD( 1,-3) ::= -2      
*          0 % -3 ::=  0.00        MOD( 0,-3) ::=  0      
*         -1 % -3 ::= -1.00        MOD(-1,-3) ::= -1      
*         -2 % -3 ::= -2.00        MOD(-2,-3) ::= -2      
*         -3 % -3 ::=  0.00        MOD(-3,-3) ::=  0      
*/
FUNCTION MOD(cl_num, cl_base)
   
   LOCAL cl_result

	cl_result = cl_num % cl_base

	RETURN IF( cl_base = 0, ;
			   cl_num,;
			   IF(cl_result * cl_base < 0, cl_result + cl_base, cl_result) )
