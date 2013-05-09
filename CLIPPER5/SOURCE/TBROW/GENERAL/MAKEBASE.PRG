/*****
 *
 * MAKEBASE.PRG
 * Create test database file and its indexes
 *
 * Clipper makebase /N /W
 * RTLINK FILE makebase
 *
 */

#define MAXRECS 1000

FUNCTION Main()
   LOCAL aArray := { {"FLD1", "N", 15, 3},;
                     {"FLD2", "C", 30, 0},;
                     {"FLD3", "C", 30, 0},;
                     {"FLD4", "N", 15, 0},;
                     {"FLD5", "N", 15, 2},;
                     {"FLD6", "C", 40, 0},;
                     {"FLD7", "D",  8, 0},;
                     {"FLD8", "L",  1, 0} }
   LOCAL i := 0
   LOCAL j := 65
   LOCAL k := 90

   FIELD fld1, fld2, fld3, fld4, fld5, fld6,;
         fld7, fld8 IN test

   SCROLL()
   // DBCreate() does not Open the File
   DBCREATE("Test", aArray)
   USE test NEW

   // Adding Records
   FOR i := 1 TO MAXRECS
      DBAPPEND()
      fld1 := (5432 - i) * 100.23
      fld2 := STR(i * j * k)
      j    := IF(j == 90, 65, ++j)
      fld3 := REPLICATE(CHR(j),30)
      fld4 := (SECONDS()/100) + (i * k)
      k    := IF(j == 65, 90, ++k)
      fld5 := IF(i < 66, 3, ;
              IF(i > 130, 5, 4))
      fld6 := REPLICATE(CHR(j),40)
      fld7 := CTOD(IF(i <= 100, "09/19/52", "06/17/58"))
      fld8 := IF(i <= 150 .AND. i >= 75, .T., .F.)

   NEXT
   // Create Indexes
   INDEX ON test->fld3       TO test3
   INDEX ON DTOS(test->fld7) TO test7

   RETURN (NIL)

// EOF - MAKEBASE.PRG //
