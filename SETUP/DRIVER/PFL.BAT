:--------------------------------------------------------------------------:
:  PFL.BAT                                                                 :
:                                                                          :
:  Batch file for setting the serial devices connected.                    :
:                                                                          :
:  rnr  5-4-95                                                             :
:--------------------------------------------------------------------------:
@ECHO OFF
: Load PFL Serial port configuration     
LH PFL_COM
: Specify device connected
PFL_SPEC ser_drawer  com2 br_9600 p_even db_8 sb_1 h_rts
rem PFL_SPEC ser_printer com1 br_9600 p_even db_8 sb_1 h_dtr_rts
PFL_SPEC ser_scanner com4 br_9600 p_even db_8 sb_1 h_dtr_rts
PFL_SPEC ser_cust_disp com3 br_19200 p_none db_8 sb_1 h_dtr_rts
