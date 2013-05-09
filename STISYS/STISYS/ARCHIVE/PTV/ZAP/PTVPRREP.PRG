@ 24,00 CLEA
@ 23,00 SAY ""
WAIT "READY PRINTER. Press any key when ready..."
clea
NOEMPSW = 0
FSW = 0
PCTR = 0
STORE 0.00 TO GTRATE,GTABSENCES,GTOVER,GTEARN,GTTAX,GTPERA,GTGSIS,GTGARIR,GTMCARE
STORE 0.00 TO GTMARIR,GTPHILAM,GTPTEA,GTLIFE,GTNETPAY,GTTXFOUR

IF REGDD = "15"
   FROMDD = "01"
ELSE
   IF REGDD = "28" .OR. REGDD = "29" .OR. REGDD = "30" .OR. REGDD = "31"
      FROMDD = "16"
   ENDIF
ENDIF
FROMDATE = REGMM + "/" + FROMDD + "/" + REGYY
TODATE = REGMM + "/" + REGDD + "/" + REGYY

SET DEVICE TO PRINT
I = 0

DO WHIL .T.
   I = I + 1
   IF I > 10
      CLEAR
      CLOS DATA
      EJECT
      SET DEVICE TO SCREE
      RETURN
   ENDIF
   DO WHIL .T.
      IF E_STATUS = "R"
         DO CASE
            CASE I = 1
                 NEWFILE = "AR"
                 DIVISION = "GM's Office                "
            CASE I = 2
                 NEWFILE = "BR"
                 DIVISION = "Program Production Services"
            CASE I = 3
                 NEWFILE = "CR"
                 DIVISION = "News                       "
            CASE I = 4
                 NEWFILE = "DR"
                 DIVISION = "Public Affairs             "
            CASE I = 5
                 NEWFILE = "ER"
                 DIVISION = "EEC                        "
            CASE I = 6
                 NEWFILE = "FR"         
                 DIVISION = "Engineering                "
            CASE I = 7
                 NEWFILE = "GR"
                 DIVISION = "Provincial                 "
            CASE I = 8
                 NEWFILE = "HR"
                 DIVISION = "Sales                      "
            CASE I = 9
                 NEWFILE = "IR"
                 DIVISION = "Administrative             "
            CASE I = 10
                 NEWFILE = "JR"
                 DIVISION = "Finance                    "
         ENDCASE
      ENDIF
      IF E_STATUS = "C"
         DO CASE
            CASE I = 1
                 NEWFILE = "AC"
                 DIVISION = "GM's Office                "
            CASE I = 2
                 NEWFILE = "BC"
                 DIVISION = "Program Production Services"
            CASE I = 3
                 NEWFILE = "CC"
                 DIVISION = "News                       "
            CASE I = 4
                 NEWFILE = "DC"
                 DIVISION = "Public Affairs             "
            CASE I = 5
                 NEWFILE = "EC"
                 DIVISION = "EEC                        "
            CASE I = 6
                 NEWFILE = "FC"
                 DIVISION = "Engineering                "
            CASE I = 7
                 NEWFILE = "GC"
                 DIVISION = "Provincial                 "
            CASE I = 8
                 NEWFILE = "HC"
                 DIVISION = "Sales                      "
            CASE I = 9
                 NEWFILE = "IC"
                 DIVISION = "Administrative             "
            CASE I = 10
                 NEWFILE = "JC"
                 DIVISION = "Finance                    "
         ENDCASE
      ENDIF
      IF E_STATUS = "T"
         DO CASE
            CASE I = 1
                 NEWFILE = "AT"
                 DIVISION = "GM's Office                "
            CASE I = 2
                 NEWFILE = "BT"
                 DIVISION = "Program Production Services"
            CASE I = 3
                 NEWFILE = "CT"
                 DIVISION = "News                       "
            CASE I = 4
                 NEWFILE = "DT"
                 DIVISION = "Public Affairs             "
            CASE I = 5
                 NEWFILE = "ET"
                 DIVISION = "EEC                        "
            CASE I = 6
                 NEWFILE = "FT"
                 DIVISION = "Engineering                "
            CASE I = 7
                 NEWFILE = "GT"
                 DIVISION = "Provincial                 "
            CASE I = 8
                 NEWFILE = "HT"
                 DIVISION = "Sales                      "
            CASE I = 9
                 NEWFILE = "IT"
                 DIVISION = "Administrative             "
            CASE I = 10
                 NEWFILE = "JT"
                 DIVISION = "Finance                    "  
         ENDCASE
      ENDIF
      NOWFILE = NEWFILE + REGMM + REGDD + REGYY +".DBF"
      IF .NOT. FILE("&NOWFILE")
         @ 24,00 CLEA
         @ 23,00 SAY ""
         WAIT "FATAL ERROR. FILE MISSING."
         CLEAR
         CLOS DATA
         RETURN
      ENDIF
      NOWFILE = SUBS(NOWFILE,1,8)   

      USE &NOWFILE 
      INDEX ON STATE + NAME TO TEMPIDX
      TNAME = SPAC(30)


      DO WHIL .T.     
         TNAME = NAME
         IF TNAME = SPAC(30)
            NOEMPSW = 1
         ENDIF
         EXIT
      ENDDO
      EXIT
   ENDDO
   LCTR = 57
   PEMPNO = SPAC(3)
   PNAME = SPAC(30)
   PTITLE = SPAC(45)
   STORE 0.00 TO PRATE,PABSENCES,POVER,PEARN,PTAX,PPERA,PGSIS,PGARIR,PMCARE
   STORE 0.00 TO PMARIR,PPHILAM,PPTEA,PLIFE,PNETPAY
   STORE 0.00 TO GRATE,GABSENCES,GOVER,GEARN,GTAX,GPERA,GGSIS,GGARIR,GMCARE
   STORE 0.00 TO GMARIR,GPHILAM,GPTEA,GLIFE,GNETPAY

   DO WHIL .T.
      IF NOEMPSW = 1
         NOEMPSW = 0
         EXIT
      ENDIF
      IF LCTR >= 56
         IF FSW = 0
            FSW = 1
         ELSE
            EJECT
            LCTR = 1
         ENDIF
         PCTR = PCTR + 1
         SET PRINT ON 
         ?
         ??CHR(14) + SPACE(17) + "PEOPLE'S TELEVISION NETWORK, INC."
         ??CHR(20)
         SET PRINT OFF
         @ 02,60 SAY "PAYROLL REGISTER OF"
         @ 02,80 SAY EMPSTAT
         @ 02,122 SAY "PAGE NO. "
         @ 02,131 SAY PCTR PICT "99"
         @ 03,00 SAY DIVISION 
         SET PRINT ON
         ??CHR(15)
        @ 04,00 SAY "We hereby acknowledge to have received from";
                    + " MILDRED VALDOZ the sums therein specified opposite our+;
                    + " respective names, being in full compensation for our";
                    + " services for the period " + FROMDATE + " - " + TODATE;
                    + ", except as noted otherwise."
        @ 05,00 SAY "====================================================================================================================================================================================================================================="
        @ 06,00 SAY "EMP.           E M P L O Y E E   N A M E/             SEMI-MONTHLY    ABSENCES/               EARNED                 R/A      GSIS             MEDICARE               OTHERS              LIFE-"
        @ 07,00 SAY "NO.              D E S I G N A T I O N                    RATE        UNDERTIME   OVERTIME     P A Y      W/TAX      PERA    ARREARS    GSIS    ARREARS   MEDICARE   (PHILAM)    PTEA     CARE      NETPAY            SIGNATURE"      
        @ 08,00 SAY "====================================================================================================================================================================================================================================="

         ??CHR(18)
         SET PRINT OFF
         LCTR = 10
      ENDIF
      PEMPNO    = EMPNO
      PNAME     = NAME
      PTITLE    = TITLE
      PRATE     = RATE
      PABSENCES = ABSENCES
      POVER     = OVERTIME
      PEARN     = EARNEDPAY
      PTAX      = TAX
     
      PPERA     = PERA
      PGARIR    = GSISARIR
      PGSIS     = GSIS
      PMARIR    = MCAREARIR
      PMCARE    = MCARE
      PPHILAM   = PHILAM
      PPTEA     = PTEA
      PLIFE     = LIFECARE 
      PNETPAY   = NETPAY   
      PNETPAY = PNETPAY - (PLOAN + PPHILAM)
      SET PRINT ON
      ??CHR(15)
      @ LCTR,000 SAY PEMPNO
      @ LCTR,007 SAY NAME
      @ LCTR,057 SAY PRATE PICT "9,999.99"
      @ LCTR,070 SAY PABSENCES PICT "9,999.99"
      @ LCTR,082 SAY POVER PICT "9,999.99"
      @ LCTR,094 SAY PEARN PICT "9,999.99"
      @ LCTR,105 SAY PTAX PICT "9,999.99"

      IF PEARN = 0.00 
         PPERA = 0.00
         PGARIR = 0.00
         PGSIS = 0.00
         PMARIR = 0.00
         PMCARE = 0.00
         PPHILAM = 0.00
         PPTEA = 0.00
         PLIFE = 0.00
         PNETPAY = 0.00
      ENDIF

      SELE 1
      TTOT_DED = 0.00
      TTOT_DED = TOT_DED + PLOAN
      REPL TOT_DED WITH TTOT_DED
      SELE 3
    
      @ LCTR,117 SAY PPERA PICT "999.99"
      @ LCTR,126 SAY PGARIR PICT "999.99"
      @ LCTR,135 SAY PGSIS PICT "999.99"
      @ LCTR,144 SAY PMARIR PICT "999.99"
      @ LCTR,155 SAY PMCARE PICT "999.99"
      @ LCTR,167 SAY PPHILAM PICT "999.99"
      @ LCTR,176 SAY PPTEA PICT "999.99"
      @ LCTR,186 SAY PLIFE PICT "999.99"
      @ LCTR,196 SAY PNETPAY PICT "9,999.99"
      @ LCTR,206 SAY "_____________________"
      @ LCTR,228 SAY PEMPNO 
       
      LCTR = LCTR + 1
      @ LCTR,007 SAY PTITLE
      GRATE = GRATE + PRATE
      GABSENCES = GABSENCES + PABSENCES
      GOVER = GOVER + POVER
      GEARN = GEARN + PEARN
      GTAX = GTAX + PTAX

      GPERA = GPERA + PPERA
      GGARIR = GGARIR + PGARIR
      GGSIS = GGSIS + PGSIS
      GMARIR = GMARIR + PMARIR
      GMCARE = GMCARE + PMCARE
      GPHILAM = GPHILAM + PPHILAM
      GPTEA = GPTEA + PPTEA
      GLIFE = GLIFE + PLIFE
      GNETPAY = GNETPAY + PNETPAY
      ??CHR(18)
      SET PRINT OFF
      LCTR = LCTR + 2   
      SKIP 
      IF EOF()
         LCTR = LCTR - 1
         IF LCTR <= 52 
            SET PRINT ON 
            ??CHR(15) 
            @ LCTR + 01,000 SAY REPL("=",228)
            @ LCTR + 02,000 SAY "T O T A L   " + DIVISION
            @ LCTR + 02,055 SAY GRATE PICT "999,999.99"
            @ LCTR + 02,069 SAY GABSENCES PICT "999,999.99"
            @ LCTR + 02,080 SAY GOVER PICT "999,999.99"
            @ LCTR + 02,092 SAY GEARN PICT "999,999.99"
            @ LCTR + 02,104 SAY GTAX PICT "99,999.99"
            @ LCTR + 02,115 SAY GPERA PICT "99,999.99"
            @ LCTR + 02,123 SAY GGARIR PICT "99,999.99"
            @ LCTR + 02,132 SAY GGSIS PICT "99,999.99"
            @ LCTR + 02,142 SAY GMARIR PICT "9,999.99"
            @ LCTR + 02,153 SAY GMCARE PICT "9,999.99"
            @ LCTR + 02,164 SAY GPHILAM PICT "99,999.99"
            @ LCTR + 02,174 SAY GPTEA PICT "9,999.99"
            @ LCTR + 02,184 SAY GLIFE PICT "9,999.99"
            @ LCTR + 02,194 SAY GNETPAY PICT "999,999.99"
            @ LCTR + 03,000 SAY REPL("=",228)
            ??CHR(18)
            SET PRINT OFF
            EXIT
         ELSE 
            EJECT
            SET PRINT ON
            ?
            ??CHR(14) + SPACE(17) + "PEOPLE'S TELEVISION NETWORK, INC."
            ??CHR(20)
            SET PRINT OFF
            @ 02,60 SAY "PAYROLL REGISTER OF"
            @ 02,80 SAY EMPSTAT
            @ 02,122 SAY "PAGE NO. "
            PCTR = PCTR + 1
            @ 02,131 SAY PCTR PICT "99"
            @ 03,00 SAY DIVISION 
            SET PRINT ON
            ??CHR(15)
            @ 04,00 SAY "We hereby acknowledge to have received from";
                        + " MILDRED VALDOZ the sums therein specified opposite our";
                        + " respective names, being in full compensation for our";
                        + " services for the period " + FROMDATE + " - " + TODATE;
                        + ", except as noted otherwise."
            @ 05,00 SAY REPL("=",228)
            @ 06,00 SAY "EMP.           E M P L O Y E E   N A M E/             SEMI-MONTHLY    ABSENCES/               EARNED                 R/A      GSIS             MEDICARE               OTHERS              LIFE-"
            @ 07,00 SAY "NO.              D E S I G N A T I O N                    RATE        UNDERTIME   OVERTIME     P A Y      W/TAX      PERA    ARREARS    GSIS    ARREARS   MEDICARE   (PHILAM)    PTEA     CARE      NETPAY            SIGNATURE"      
            @ 08,00 SAY REPL("=",228)

            LCTR = 10
            @ LCTR + 01,000 SAY REPL("=",228)
            @ LCTR + 02,000 SAY "T O T A L   " + DIVISION
            @ LCTR + 02,055 SAY GRATE PICT "999,999.99"
            @ LCTR + 02,069 SAY GABSENCES PICT "999,999.99"
            @ LCTR + 02,080 SAY GOVER PICT "999,999.99"
            @ LCTR + 02,092 SAY GEARN PICT "999,999.99"
            @ LCTR + 02,104 SAY GTAX PICT "99,999.99"
            @ LCTR + 02,115 SAY GPERA PICT "99,999.99"
            @ LCTR + 02,123 SAY GGARIR PICT "99,999.99"
            @ LCTR + 02,132 SAY GGSIS PICT "99,999.99"
            @ LCTR + 02,142 SAY GMARIR PICT "9,999.99"
            @ LCTR + 02,153 SAY GMCARE PICT "9,999.99"
            @ LCTR + 02,164 SAY GPHILAM PICT "99,999.99"
            @ LCTR + 02,174 SAY GPTEA PICT "9,999.99"
            @ LCTR + 02,184 SAY GLIFE PICT "9,999.99"
            @ LCTR + 02,194 SAY GNETPAY PICT "999,999.99"
            @ LCTR + 03,000 SAY REPL("=",228)

            ??CHR(18)
            SET PRINT OFF
            EXIT
         ENDIF
      ENDIF
   ENDDO
   GTRATE = GTRATE + GRATE
   GTABSENCES = GTABSENCES + GABSENCES
   GTOVER = GTOVER + GOVER
   GTEARN = GTEARN + GEARN
   GTTAX = GTTAX + GTAX

   GTPERA = GTPERA + GPERA
   GTGARIR = GTGARIR + GGARIR
   GTGSIS = GTGSIS + GGSIS
   GTMARIR = GTMARIR + GMARIR
   GTMCARE = GTMCARE + GMCARE
   GTPHILAM = GTPHILAM + GPHILAM
   GTPTEA = GTPTEA + GPTEA
   GTLIFE = GTLIFE + GLIFE
   GTNETPAY = GTNETPAY + GNETPAY
   IF I = 10
      IF LCTR > 32
         EJECT
         SET PRINT ON
         ?
         ??CHR(14) + SPACE(17) + "PEOPLE'S TELEVISION NETWORK, INC."
         ??CHR(20)
         SET PRINT OFF
         @ 02,60 SAY "PAYROLL REGISTER OF"
         @ 02,80 SAY EMPSTAT
         @ 02,122 SAY "PAGE NO. "
         PCTR = PCTR + 1
         @ 02,131 SAY PCTR PICT "99"
         SET PRINT ON
         ??CHR(15)
         @ 04,00 SAY "We hereby acknowledge to have received from";
                     + " MILDRED VALDOZ the sums therein specified opposite our";
                     + " respective names, being in full compensation for our";
                     + " services for the period " + FROMDATE + " - " + TODATE;
                     + ", except as noted otherwise."
         @ 05,00 SAY REPL("=",228)
         @ 06,00 SAY "EMP.           E M P L O Y E E   N A M E/             SEMI-MONTHLY    ABSENCES/               EARNED                 R/A      GSIS             MEDICARE               OTHERS              LIFE-"
         @ 07,00 SAY "NO.              D E S I G N A T I O N                    RATE        UNDERTIME   OVERTIME     P A Y      W/TAX      PERA    ARREARS    GSIS    ARREARS   MEDICARE   (PHILAM)    PTEA     CARE      NETPAY            SIGNATURE"      
         @ 08,00 SAY REPL("=",228)

         LCTR = 10
         SET PRINT ON
         ??CHR(15)
         @ LCTR + 01,000 SAY REPL("=",228)
         @ LCTR + 02,000 SAY "G R A N D  T O T A L   " 
         @ LCTR + 02,055 SAY GTRATE PICT "999,999.99"
         @ LCTR + 02,069 SAY GTABSENCES PICT "999,999.99"
         @ LCTR + 02,080 SAY GTOVER PICT "999,999.99"
         @ LCTR + 02,092 SAY GTEARN PICT "999,999.99"
         @ LCTR + 02,104 SAY GTTAX PICT "99,999.99"
         @ LCTR + 02,115 SAY GTPERA PICT "999,999.99"
         @ LCTR + 02,123 SAY GTGARIR PICT "99,999.99"
         @ LCTR + 02,132 SAY GTGSIS PICT "99,999.99"
         @ LCTR + 02,142 SAY GTMARIR PICT "9,999.99"
         @ LCTR + 02,153 SAY GTMCARE PICT "9,999.99"
         @ LCTR + 02,164 SAY GTPHILAM PICT "99,999.99"
         @ LCTR + 02,174 SAY GTPTEA PICT "9,999.99"
         @ LCTR + 02,184 SAY GTLIFE PICT "9,999.99"
         @ LCTR + 02,194 SAY GTNETPAY PICT "999,999.99"

         @ LCTR + 03,000 SAY REPL("=",228)
         @ LCTR + 05,005 SAY "(1) I CERTIFY on my official oath that the above payroll is                          (3) I CERTIFY on my official oath that I have paid to"                            
         @ LCTR + 06,005 SAY "correct and the the services have been duly rendered as                              each " + EMPSTAT + " employee whose name appears on the above"
         @ LCTR + 07,005 SAY "stated.                                                                              payroll the amount set opposite his name, having presented"
         @ LCTR + 08,005 SAY "                                                                                     his Residence Certificate."
         @ LCTR + 12,000 SAY "              _______________________________                                                     _____________________________"
         @ LCTR + 13,000 SAY "                     ROSA N, QUINCENA                                                                    MILDRED S. VALDOZ"                                                                                       
         @ LCTR + 14,000 SAY "                  ADMINISTRATIVE MANAGER                                                                     CASHIER II"
         @ LCTR + 16,005 SAY "(2) APPROVED, payable from appropriations for PEOPLE'S                               (4) I CERTIFY on my official oath that I have witnessed"
         @ LCTR + 17,005 SAY "TELEVISION FOUR.                                                                     payment to each person, whose name appears hereon, of"
         @ LCTR + 18,005 SAY "                                                                                     the amount set opposite his name and my initials."
         @ LCTR + 22,000 SAY "              _______________________________                                                     _____________________________"
         @ LCTR + 23,000 SAY "                         RAMY DIEZ                                                                      ACCOUNTING CLERK"
         @ LCTR + 24,000 SAY "                  Network General Manager"            
         ??CHR(18)
         SET PRINT OFF
      ELSE
         SET PRINT ON
         ??CHR(15)
         @ LCTR + 05,000 SAY REPL("=",228)
         @ LCTR + 06,000 SAY "G R A N D  T O T A L   " 
         @ LCTR + 06,055 SAY GTRATE PICT "999,999.99"
         @ LCTR + 06,069 SAY GTABSENCES PICT "999,999.99"
         @ LCTR + 06,080 SAY GTOVER PICT "999,999.99"
         @ LCTR + 06,092 SAY GTEARN PICT "999,999.99"
         @ LCTR + 06,104 SAY GTTAX PICT "99,999.99"
         @ LCTR + 06,115 SAY GTPERA PICT "999,999.99"
         @ LCTR + 06,123 SAY GTGARIR PICT "99,999.99"
         @ LCTR + 06,132 SAY GTGSIS PICT "99,999.99"
         @ LCTR + 06,142 SAY GTMARIR PICT "9,999.99"
         @ LCTR + 06,153 SAY GTMCARE PICT "9,999.99"
         @ LCTR + 06,164 SAY GTPHILAM PICT "99,999.99"
         @ LCTR + 06,174 SAY GTPTEA PICT "9,999.99"
         @ LCTR + 06,184 SAY GTLIFE PICT "9,999.99"
         @ LCTR + 06,194 SAY GTNETPAY PICT "999,999.99" 

         @ LCTR + 07,000 SAY REPL("=",228)
         @ LCTR + 09,005 SAY "(1) I CERTIFY on my official oath that the above payroll is                          (3) I CERTIFY on my official oath that I have paid to"                            
         @ LCTR + 10,005 SAY "correct and the the services have been duly rendered as                              each " + EMPSTAT + " employee whose name appears on the above"
         @ LCTR + 11,005 SAY "stated.                                                                              payroll the amount set opposite his name, having presented"
         @ LCTR + 12,005 SAY "                                                                                     his Residence Certificate."
         @ LCTR + 16,000 SAY "              _______________________________                                                     _____________________________"
         @ LCTR + 17,000 SAY "                     ROSA N. QUINCENA                                                                    MILDRED S. VALDOZ"                                                                                       
         @ LCTR + 18,000 SAY "                  ADMINISTRATIVE MANAGER                                                                     CASHIER II"
         @ LCTR + 20,005 SAY "(2) APPROVED, payable from appropriations for PEOPLE'S                               (4) I CERTIFY on my official oath that I have witnessed" 
         @ LCTR + 21,005 SAY "TELEVISION FOUR.                                                                     payment to each person, whose name appears hereon, of"
         @ LCTR + 22,005 SAY "                                                                                     the amount set opposite his name and my initials."
         @ LCTR + 26,000 SAY "              _______________________________                                                     _____________________________"
         @ LCTR + 27,000 SAY "                         RAMY DIEZ                                                                      ACCOUNTING CLERK"
         @ LCTR + 28,000 SAY "                  Network General Manager"             
         ??CHR(18)
         SET PRINT OFF
      ENDIF
      CLOS DATA  
      EJECT
      SET DEVICE TO SCREEN
      CLEAR  
      RETURN
   ENDIF
ENDDO



