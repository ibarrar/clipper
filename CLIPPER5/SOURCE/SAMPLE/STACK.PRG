/***
*
*  Stack.prg
*
*  Functions to implement a stack data type
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/


/***
*
*    What Is a Stack?
* 
*    A stack is a common Last-In-First-Out (LIFO) data structure.
*    An analogy would be a stack of books on a table. If you
*    place Book A on the table, then place Book B on top of Book
*    A, then place Book C on top of Book B, you have created a
*    stack with three members. Book C is the "top" of the stack;
*    Book A is the "bottom" of the stack.
*
*    Adding a new item to a stack is referred to as "pushing"
*    the item onto the stack. Thus we have "pushed" three items
*    onto our stack of books.  Removing the top item of the
*    stack is called "popping" the item. Unlike a stack of books,
*    you can't pull something out of the middle of a stack data
*    structure -- the items are always popped in reverse order.
*    That is, the last item in is the first item out (LIFO).
*
*    Using the functions in this file, we could model our stack
*    of books like this:
*
*    // Create an empty stack
*    aStack := StackNew()
* 
*    // "Push" each item onto the stack
*    StackPush( aStack, "Book A" )
*    StackPush( aStack, "Book B" )
*    StackPush( aStack, "Book C" )
*
*    // Now "pop" them off
*    ? StackPop( aStack )      // Prints "Book C"
*    ? StackPop( aStack )      // Prints "Book B"
*    ? StackPop( aStack )      // Prints "Book A" (the stack is now empty)
*
*
*    A real example might be a stack of color settings:
*
*    aColors := StackNew()
*
*    StackPush( aColors, SETCOLOR() )  // Save current color setting
*    SETCOLOR( ... )                   // Change color setting
*
*    ...                               // Routine's code here
*
*    SETCOLOR( StackPop( aColors ) )   // Restore color on way out
*
*
*
*  This implementation involves the following functions:
*
*    StackNew() --> aStack
*    Create a new stack
*
*    StackPush( <aStack>, <exp> ) --> aStack
*    Push a new value onto the stack
*
*    StackPop( <aStack> ) --> xValue
*    Pop a value from the stack, return NIL is stack is empty
*
*    StackIsEmpty( <aStack> ) --> lEmpty
*    Determine if a stack has no members
*
*    StackTop( <aStack> ) --> xValue
*    Return top stack member without removing from stack
*
*/


/***
*
*   StackNew() --> aStack
*
*   Create a new stack
*
*/
FUNCTION StackNew()
   RETURN ( {} )     // Return an empty array



/***
*
*   StackPush( <aStack>, <xValue> ) --> aStack
*
*   Push a new value onto the stack
*
*/
FUNCTION StackPush( aStack, xVal )
   
   // Add new element to the stack array and then return the array
   RETURN ( AADD( aStack, xVal ) )



/***
*
*   StackPop( <aStack> ) --> xValue
*
*   Pop a value from the stack
*
*   NOTE: Returns NIL if nothing is on the stack
*
*/
FUNCTION StackPop( aStack )
   
   LOCAL xValueLast
   LOCAL nLen := LEN( aStack )

   // Check for underflow condition
   IF nLen == 0
      RETURN ( NIL )       // NOTE
   ENDIF

   // Get the last element value
   xValueLast := aStack[ nLen ]

   // Remove the last element by shrinking the stack
   ASIZE( aStack, nLen - 1 )

   // Return the last element's value
   RETURN ( xValueLast )



/***
*
*  StackIsEmpty( <aStack> ) --> lEmpty
*
*  Determine if a stack has no members
*
*/
FUNCTION StackIsEmpty( aStack )
   RETURN ( EMPTY( aStack ) )



/***
*
*  StackTop( <aStack> ) --> xValue
*
*  Retrieve top stack member without removing
*
*/
FUNCTION StackTop( aStack )
   
   // Return the value of the last element in the stack array
   RETURN ( ATAIL( aStack ) )
