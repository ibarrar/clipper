set wrap on
set message to 21 center

do drawbox with 8,19,15,40,.f.

@ 10,20 prompt 'Employee Master File';
               message 'Print Employees 201 File'
@ 11,20 prompt 'Payroll Register    ';
               message 'Print Payroll'
@ 12,20 prompt 'Payslips            ';
               message 'Print Payslips'
@ 13,20 prompt 'Loans Update        ';
               message 'Print GSIS Salary Loans'
menu to printing

if lastkey() = 27
   return
endif

do case
   case printing = 1
        do estatus
        if lastkey() = 27
           return
        endif
        do ptvprrep
   case printing = 2
        *
   case printing = 3
        *
   case printing = 4
        *
endcase
return