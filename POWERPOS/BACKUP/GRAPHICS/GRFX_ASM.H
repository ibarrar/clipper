/*
* System......... Graphics Interface Library for Clipper 
* Program I.D.... Grfx_asm.H
* Description.... Prototype of Assembly Routines for C++    
* Author......... jay ocampo
* Date Started... November 1994
*/



int iscale( int i, int n, int d );

/* Function Name : iscale
   Syntax        : int iscale( int i, int n, int d )
   Usage         : Integer scaling function
                   - prevent integer overflow without resulting to "long" arithmetic
			    - avoid use of double or float data types
   Returns       : ( i * n / d)
*/
  
                   				   