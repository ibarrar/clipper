REM  Create FONTDRVR library including Graphic Drivers and Fonts 

@ECHO OFF


REM Compile Graphic Drivers
    bgiobj /F ATT
    bgiobj /F CGA
    bgiobj /F EGAVGA
    bgiobj /F HERC
    bgiobj /F IBM8514
    bgiobj /F PC3270


REM Compile Font Files
    bgiobj /F TRIP
    bgiobj /F LITT
    bgiobj /F SANS
    bgiobj /F GOTH
    bgiobj /F BOLD.CHR BOLDF.OBJ  _bold_font_far         bold_text
    bgiobj /F EURO.CHR EUROF.OBJ  _european_font_far     euro_text
    bgiobj /F LCOM.CHR LCOMF.OBJ  _complex_font_far      lcomf_text
    bgiobj /F SCRI.CHR SCRIF.OBJ  _script_font_far       scri_text
    bgiobj /F SIMP.CHR SIMPF.OBJ  _simplex_font_far      simp_text
    bgiobj /F TSCR.CHR TSCRF.OBJ  _triplex_scr_font_far  tscr_text

REM add BGI obj files to GRAPHICS.LIB

    tlib ..\lib\fontdrvr +ATTf +CGAf +EGAVGAf +HERCf +IBM8514f +PC3270f
    tlib ..\lib\fontdrvr +TRIPf +LITTf +SANSf +GOTHf
    tlib ..\lib\fontdrvr +BOLDf +EUROf +LCOMf +SCRIf +SIMPf +TSCRf


REM Link the Large Model Start-up Code to your Large Model Run-time library
REM CD ..\LIB
REM copy cl.lib cl.old
REM tlib cl  + C0L.OBJ

