/* e4error.h  (c)Copyright Sequiter Software Inc., 1990-1992.  All rights reserved. */
/*            (c)Copyright Sequiter Software Inc.,1990-1991. Alle Rechte vorbehalten.  */
/*                German translation: Mgr. Gertruda TKACIKOVA, Jan. 1992.  */                                                                  

/*   error messages  */

#ifndef S4LANGUAGE     

   /* e4error() messages */
   #define  E4_CLOSE         "Unknown Name"
   #define  E4_CREATE_FIL    "File Name:"
   #define  E4_CREATE_TEM    "Temporary Working File"
   #define  E4_CREATE_TOO    "Too Many Fields"
   #define  E4_ERROR         "Error"
   #define  E4_ERROR_NUM     "\r\n\r\nError Number"
   #define  E4_ERROR_SEV     "\r\n\r\nSevere Error Number"
   #define  E4_ERROR_BAS     "CODEBASIC ERROR"
   #define  E4_ERROR_COD     "CODEBASE ERROR"
   #define  E4_ERROR_CDS     "CODEBASE SEVERE ERROR"
   #define  E4_ERROR_ENT     "\r\nPress Enter ..."
   #define  E4_ERROR_KEY     "\r\nPress a key ..."
   #define  E4_INDEX_COR     "Corrupted Free Block Chain in Index File"
   #define  E4_INDEX_EXP     "Expected '.CDX' file is of the '.IDX' type"
   #define  E4_INDEX_FIL     "Filter should be Logical"
   #define  E4_INFO_AME      "A memo block is used twice."
   #define  E4_INFO_CAL      "Call to d4reccount() in r4reindex_blocks_init() failed"
   #define  E4_INFO_CLO      "Error closing group file in i4open()"
   #define  E4_INFO_DAT      "Database is empty."
   #define  E4_INFO_INC      "Incorrect Record Number in tag:"
   #define  E4_INFO_KEY      "Error in Key Evaluation"
   #define  E4_INFO_LOC      "Error locking in i4open()"
   #define  E4_INFO_REA      "Error reading group file in i4open()"
   #define  E4_INFO_REC      "Record is missing."
   #define  E4_INFO_REP      "Repeated Record Number in tag:"
   #define  E4_INFO_SET      "Set C4CODE.auto_open to 'off'"
   #define  E4_INFO_SKI      "Skip must be made from valid record number"
   #define  E4_INFO_TAG      "Tag is corrupted"
   #define  E4_INFO_UNL      "Error unlocking group file in i4open()"
   #define  E4_MEMORY_B      "Block Size too Large for Indexing"
   #define  E4_MEMORY_S      "Sorting"
   #define  E4_NUM_PARMS     "Function"
   #define  E4_RESULT_D4F    "d4flush_record() did not work."
   #define  E4_RESULT_EXP    "Expecting logical result."
   #define  E4_RESULT_IDE    "Identical keys in unique key tag:"
   #define  E4_RESULT_LOS    "Lost Block in Index File"
   #define  E4_RESULT_REC    "Record numbers out of order for equal keys:"
   #define  E4_RESULT_TAG    "Tag is out of date:"
   #define  E4_RESULT_THE    "The tag is out of order:"
   #define  E4_RESULT_UNE    "Unexpected key evaluation length:"
   #define  E4_RESULT_WAS    "Wasted Space in Memo File"
   #define  E4_TYPE_SUB      "Expression:"
   #define  E4_UNIQUE        "Creating Tag"
   
   /* e4severe() messages */
   #define  E4_DATA_ILL      "Illegal field data."
   #define  E4_DATA_MEM      "Memo File not Open for Append"
   #define  E4_INFO_ALR      "Already initialized"
   #define  E4_INFO_BAD      "Bad NTX Clipper index file"
   #define  E4_INFO_BLO      "Block size is less than 1024 bytes"
   #define  E4_INFO_BLS      "This is unsupported since dBASE IV compatibility requires minimum blocks sizes of 1024 bytes"
   #define  E4_INFO_BMC      "Block/memory corruption"
   #define  E4_INFO_C4C      "'C4CODE.mem_size_block' is an illegal value."
   #define  E4_INFO_COD      "CodeBase internal error"
   #define  E4_INFO_CIF      "Corrupt index file"
   #define  E4_INFO_CIB      "Corrupt index block"
   #define  E4_INFO_CIS      "Corrupt index structure"
   #define  E4_INFO_CMF      "Corrupt memo file"
   #define  E4_INFO_CRL      "Corrupted Linked List"
   #define  E4_INFO_DAO      "Database file already open"
   #define  E4_INFO_DEL      "Deleted block not empty"
   #define  E4_INFO_DUP      "Duplicate Alias"
   #define  E4_INFO_EPV      "Expected value not built"
   #define  E4_INFO_EVA      "Evaluating Tag Expression"
   #define  E4_INFO_EXK      "Expression key is larger than maximum 102 characters"
   #define  E4_INFO_EXP      "Expression too large"
   #define  E4_INFO_FOR      "For tag"
   #define  E4_INFO_ILF      "Illegal file block reference"
   #define  E4_INFO_ILL      "Illegal locking configuration"
   #define  E4_INFO_ILP      "Illegal position"
   #define  E4_INFO_INT      "Internal t4remove_current() failure--index file corrupt"
   #define  E4_INFO_INV      "Invalid key type in index file"
   #define  E4_INFO_IVT      "Invalid type"
   #define  E4_INFO_LIN      "Link not on list"
   #define  E4_INFO_NKE      "n_keys invalid"
   #define  E4_INFO_STR      "Function was Passed an Invalid Structure Pointer"
   #define  E4_INFO_UNE      "Unexpected empty block"
   #define  E4_INFO_UNT      "Unexpected tag locks in index file"
   #define  E4_INFO_WRO      "Wrong number of links in linked list"
   #define  E4_INFO_WT4      "Wrong T4TAG Type"
   #define  E4_MEMORY_ERR    "Memory Error"
   #define  E4_MEMORY_SAV    "l4lock_save(), Saving Lock Information"
   #define  E4_MEMORY_YPO    "y4pop_pointer() with S4DEBUG switch."
   #define  E4_MEMORY_YPU    "y4push_pointer() with S4DEBUG switch."
   #define  E4_OPEN_NOD      "i4open(): No database specified"
   #define  E4_PARM_FLA      "Flag should be 'r4descending'."
   #define  E4_PARM_FOR      "For S4CLIPPER/NDX version, filter and descending should be 0"
   #define  E4_PARM_H4R      "h4read() with negative position"
   #define  E4_PARM_ILP      "Illegal position"
   #define  E4_PARM_IND      "Index file already open"
   #define  E4_PARM_INV      "Invalid lock position"
   #define  E4_PARM_NUL      "Null Data File Pointer"
   #define  E4_PARM_REC      "Record Numbers are not Consecutive"
   #define  E4_PARM_TAG      "Tag expression is missing."
   #define  E4_PARM_TOO      "Too many tags"
   #define  E4_PARM_UNI      "Unique flag data is an unrecognized value."
   #define  E4_PARM_ZER      "Zero parameter"
   #define  E4_RESULT_CLI    "Clipper Key Conversion failed"
   #define  E4_RESULT_COM    "Corrupted Memory Detected"
   #define  E4_RESULT_COR    "Corrupted Index File in Check"
   #define  E4_RESULT_D4A    "d4append_start() was not completed."
   #define  E4_RESULT_D4I    "d4init() has not been called."
   #define  E4_RESULT_EXI    "Exiting from within lock wait"
   #define  E4_RESULT_FRE    "Free value not found"
   #define  E4_RESULT_INC    "Incorrect index file locking order."
   #define  E4_RESULT_INQ    "In quick sort."
   #define  E4_RESULT_LOC    "Locking index could create deadlock."
   #define  E4_RESULT_LCO    "Locking Overlap Detected"
   #define  E4_RESULT_MEM    "Memory items not freed"
   #define  E4_RESULT_REM    "Removing Lock which was never placed."
   #define  E4_RESULT_S4L    "S4LOCK_CHECK cannot be used with 'y4reset'"
   #define  E4_RESULT_STC    "Stack length variable _stklen below minimum."
   #define  E4_RESULT_TOO    "Too many pointers"
   
   #ifdef S4WINDOWS
      #define E4_RESULT_CRE     "Creating Printer Display Context"
      #define E4_RESULT_DEL     "Deleting Display Context"
      #define E4_RESULT_END     "Ending Document"
      #define E4_RESULT_G4D     "G4DISPLAY buffer missing"
      #define E4_RESULT_G4E     "G4EDIT buffer missing"
      #define E4_RESULT_G4L     "G4LIST buffer missing"
      #define E4_RESULT_ON      "On New Frame"
      #define E4_RESULT_SET     "Setting Font"
      #define E4_RESULT_STA     "Starting Print Document"
      #define E4_MESSAG_EXI     "EXITING APPLICATION"
      #define E4_MESSAG_CAN     "Cancel"
      #define E4_MESSAG_OK      "OK"
      #define E4_MESSAG_PAC     "Are you sure you want to pack ?"
      #define E4_MESSAG_REC     "RECORD NUMBER"
      #define E4_MESSAG_REI     "Are you sure you want to reindex ?"
      #define E4_PARM_ADD       "Choice length must be > 0"
      #define E4_PARM_SA        "Invalid G4DISPLAY Pointer"
      #define E4_PARM_VIS       "WS_VISIBLE Style not Present"
      #define E4_PARM_WIN       "Invalid Window Dimensions"
      #define E4_RESULT_ADD     "Add String Failed"
      #define E4_RESULT_BUF     "G4LIST Buffer Not Big Enough"
      #define E4_RESULT_CDC     "CreateCompatibleDC() Failed"
      #define E4_RESULT_ENW     "EnableWindow() Failed"
      #define E4_RESULT_GDC     "GetDC() Failed"
      #define E4_RESULT_GTM     "GetTextMetrics Failed"
      #define E4_RESULT_ID      "Invalid Id Number"
      #define E4_RESULT_IDB     "Not A G4BUTTON Id Number"
      #define E4_RESULT_IDC     "Not A G4COMBO Id Number"
      #define E4_RESULT_IDD     "Not A G4DISPLAY Id Number"
      #define E4_RESULT_IDL     "Not A G4LIST Id Number"
      #define E4_RESULT_IDT     "Not A G4EDIT Id Number"
      #define E4_RESULT_PIC     "Bad Picture"
      #define E4_RESULT_POS     "Bad Caret Position"
      #define E4_RESULT_RDC     "ReleaseDC() Failed"
      #define E4_RESULT_RES     "FindResource() Failed"
      #define E4_RESULT_TA1     "No WM_TABSTOP Style Present"
      #define E4_RESULT_TA2     "Control Cannot Have The WM_TABSTOP Style"
      #define E4_RESULT_WIN     "CreateWindow() Failed"
   #endif

#else     /*  if S4LANGUAGE is defined  */
   #ifdef S4FRENCH
   
      #define  E4_CLOSE         "Unknown Name"
      #define  E4_CREATE_FIL    "File Name:"
      #define  E4_CREATE_TEM    "Temporary Working File"
      #define  E4_CREATE_TOO    "Too Many Fields"
      #define  E4_ERROR         "Error"
      #define  E4_ERROR_NUM     "\r\n\r\nError Number"
      #define  E4_ERROR_SEV     "\r\n\r\nSevere Error Number"
      #define  E4_ERROR_BAS     "CODEBASIC ERROR"
      #define  E4_ERROR_COD     "CODEBASE ERROR"
      #define  E4_ERROR_CDS     "CODEBASE SEVERE ERROR"
      #define  E4_ERROR_ENT     "\r\nPress Enter ..."
      #define  E4_ERROR_KEY     "\r\nPress a key ..."
      #define  E4_INDEX_COR     "Corrupted Free Block Chain in Index File"
      #define  E4_INDEX_EXP     "Expected '.CDX' file is of the '.IDX' type"
      #define  E4_INDEX_FIL     "Filter should be Logical"
      #define  E4_INFO_AME      "A memo block is used twice."
      #define  E4_INFO_CAL      "Call to d4reccount() in r4reindex_blocks_init() failed"
      #define  E4_INFO_CLO      "Error closing group file in i4open()"
      #define  E4_INFO_DAT      "Database is empty."
      #define  E4_INFO_INC      "Incorrect Record Number in tag:"
      #define  E4_INFO_KEY      "Error in Key Evaluation"
      #define  E4_INFO_LOC      "Error locking in i4open()"
      #define  E4_INFO_REA      "Error reading group file in i4open()"
      #define  E4_INFO_REC      "Record is missing."
      #define  E4_INFO_REP      "Repeated Record Number in tag:"
      #define  E4_INFO_SET      "Set C4CODE.auto_open to 'off'"
      #define  E4_INFO_SKI      "Skip must be made from valid record number"
      #define  E4_INFO_TAG      "Tag is corrupted"
      #define  E4_INFO_UNL      "Error unlocking group file in i4open()"
      #define  E4_MEMORY_B      "Block Size too Large for Indexing"
      #define  E4_MEMORY_S      "Sorting"
      #define  E4_NUM_PARMS     "Function"
      #define  E4_RESULT_D4F    "d4flush_record() did not work."
      #define  E4_RESULT_EXP    "Expecting logical result."
      #define  E4_RESULT_IDE    "Identical keys in unique key tag:"
      #define  E4_RESULT_LOS    "Lost Block in Index File"
      #define  E4_RESULT_REC    "Record numbers out of order for equal keys:"
      #define  E4_RESULT_TAG    "Tag is out of date:"
      #define  E4_RESULT_THE    "The tag is out of order:"
      #define  E4_RESULT_UNE    "Unexpected key evaluation length:"
      #define  E4_RESULT_WAS    "Wasted SPace in Memo File"
      #define  E4_TYPE_SUB      "Expression:"
      #define  E4_UNIQUE        "Creating Tag"
      
      /* e4severe() messages */
      #define  E4_DATA_ILL      "Illegal field data."
      #define  E4_DATA_MEM      "Memo File not Open for Append"
      #define  E4_INFO_ALR      "Already initialized"
      #define  E4_INFO_BAD      "Bad NTX Clipper index file"
      #define  E4_INFO_BLO      "Block size is less than 1024 bytes"
      #define  E4_INFO_BLS      "This is unsupported since dBASE IV compatibility requires minimum blocks sizes of 1024 bytes"
      #define  E4_INFO_BMC      "Block/memory corruption"
      #define  E4_INFO_C4C      "'C4CODE.mem_size_block' is an illegal value."
      #define  E4_INFO_COD      "CodeBase internal error"
      #define  E4_INFO_CIF      "Corrupt index file"
      #define  E4_INFO_CIB      "Corrupt index block"
      #define  E4_INFO_CIS      "Corrupt index structure"
      #define  E4_INFO_CMF      "Corrupt memo file"
      #define  E4_INFO_CRL      "Corrupted Linked List"
      #define  E4_INFO_DAO      "Database file already open"
      #define  E4_INFO_DEL      "Deleted block not empty"
      #define  E4_INFO_DUP      "Duplicate Alias"
      #define  E4_INFO_EPV      "Expected value not built"
      #define  E4_INFO_EVA      "Evaluating Tag Expression"
      #define  E4_INFO_EXK      "Expression key is larger than maximum 102 characters"
      #define  E4_INFO_EXP      "Expression too large"
      #define  E4_INFO_FOR      "for tag"
      #define  E4_INFO_ILF      "Illegal file block reference"
      #define  E4_INFO_ILL      "Illegal locking configuration"
      #define  E4_INFO_ILP      "Illegal position"
      #define  E4_INFO_INT      "Internal t4remove_current() failure--index file corrupt"
      #define  E4_INFO_INV      "Invalid key type in index file"
      #define  E4_INFO_IVT      "Invalid type"
      #define  E4_INFO_LIN      "Link not on list"
      #define  E4_INFO_NKE      "n_keys invalid"
      #define  E4_INFO_STR      "Function was Passed an Invalid Structure Pointer"
      #define  E4_INFO_UNE      "Unexpected empty block"
      #define  E4_INFO_UNT      "Unexpected tag locks in index file"
      #define  E4_INFO_WRO      "Wrong number of links in linked list"
      #define  E4_INFO_WT4      "Wrong T4TAG Type"
      #define  E4_MEMORY_ERR    "Memory Error"
      #define  E4_MEMORY_SAV    "l4lock_save(), Saving Lock Information"
      #define  E4_MEMORY_YPO    "y4pop_pointer() with S4DEBUG switch."
      #define  E4_MEMORY_YPU    "y4push_pointer() with S4DEBUG switch."
      #define  E4_OPEN_NOD      "i4open(): No database specified"
      #define  E4_PARM_FLA      "Flag should be 'r4descending'."
      #define  E4_PARM_FOR      "For S4CLIPPER/NDX version, filter and descending should be 0"
      #define  E4_PARM_H4R      "h4read() with negative position"
      #define  E4_PARM_ILP      "Illegal position"
      #define  E4_PARM_IND      "Index file already open"
      #define  E4_PARM_INV      "Invalid lock position"
      #define  E4_PARM_NUL      "Null Data File Pointer"
      #define  E4_PARM_REC      "Record Numbers are not Consecutive"
      #define  E4_PARM_TAG      "Tag expression is missing."
      #define  E4_PARM_TOO      "Too many tags"
      #define  E4_PARM_UNI      "Unique flag data is an unrecognized value."
      #define  E4_PARM_ZER      "Zero parameter"
      #define  E4_RESULT_CLI    "Clipper Key Conversion failed"
      #define  E4_RESULT_COM    "Corrupted Memory Detected"
      #define  E4_RESULT_COR    "Corrupted Index File in Check"
      #define  E4_RESULT_D4A    "d4append_start() was not completed."
      #define  E4_RESULT_D4I    "d4init() has not been called."
      #define  E4_RESULT_EXI    "Exiting from within lock wait"
      #define  E4_RESULT_FRE    "Free value not found"
      #define  E4_RESULT_INC    "Incorrect index file locking order."
      #define  E4_RESULT_INQ    "In quick sort."
      #define  E4_RESULT_LOC    "Locking index could create deadlock."
      #define  E4_RESULT_LCO    "Locking Overlap Detected"
      #define  E4_RESULT_MEM    "Memory items not freed"
      #define  E4_RESULT_REM    "Removing Lock which was never placed."
      #define  E4_RESULT_S4L    "S4LOCK_CHECK cannot be used with 'y4reset'"
      #define  E4_RESULT_STC    "Stack length variable _stklen below minimum."
      #define  E4_RESULT_TOO    "Too many pointers"
      
      #ifdef S4WINDOWS
         #define E4_RESULT_CRE     "Creating Printer Display Context"
         #define E4_RESULT_DEL     "Deleting Display Context"
         #define E4_RESULT_END     "Ending Document"
         #define E4_RESULT_G4D     "G4DISPLAY buffer missing"
         #define E4_RESULT_G4E     "G4EDIT buffer missing"
         #define E4_RESULT_G4L     "G4LIST buffer missing"
         #define E4_RESULT_ON      "On New Frame"
         #define E4_RESULT_SET     "Setting Font"
         #define E4_RESULT_STA     "Starting Print Document"
         #define E4_MESSAG_EXI     "EXITING APPLICATION"
         #define E4_MESSAG_CAN     "Cancel"
         #define E4_MESSAG_OK      "OK"
         #define E4_MESSAG_PAC     "Are you sure you want to pack ?"
         #define E4_MESSAG_REC     "RECORD NUMBER"
         #define E4_MESSAG_REI     "Are you sure you want to reindex ?"
         #define E4_PARM_ADD       "Choice length must be > 0"
         #define E4_PARM_SA        "Invalid G4DISPLAY Pointer"
         #define E4_PARM_VIS       "WS_VISIBLE Style not Present"
         #define E4_PARM_WIN       "Invalid Window Dimensions"
         #define E4_RESULT_ADD     "Add String Failed"
         #define E4_RESULT_BUF     "G4LIST Buffer Not Big Enough"
         #define E4_RESULT_CDC     "CreateCompatibleDC() Failed"
         #define E4_RESULT_ENW     "EnableWindow() Failed"
         #define E4_RESULT_GDC     "GetDC() Failed"
         #define E4_RESULT_GTM     "GetTextMetrics Failed"
         #define E4_RESULT_ID      "Invalid Id Number"
         #define E4_RESULT_IDB     "Not A G4BUTTON Id Number"
         #define E4_RESULT_IDC     "Not A G4COMBO Id Number"
         #define E4_RESULT_IDD     "Not A G4DISPLAY Id Number"
         #define E4_RESULT_IDL     "Not A G4LIST Id Number"
         #define E4_RESULT_IDT     "Not A G4EDIT Id Number"
         #define E4_RESULT_PIC     "Bad Picture"
         #define E4_RESULT_POS     "Bad Caret Position"
         #define E4_RESULT_RDC     "ReleaseDC() Failed"
         #define E4_RESULT_RES     "FindResource() Failed"
         #define E4_RESULT_TA1     "No WM_TABSTOP Style Present"
         #define E4_RESULT_TA2     "Control Cannot Have The WM_TABSTOP Style"
         #define E4_RESULT_WIN     "CreateWindow() Failed"
      #endif
   
      #define  E4A_GRA   0x85
      #define  E4A_CIR   0x83
      #define  E4A_CI2   0x86
      #define  E4A_TRE   0x84
      #define  E4A_EGU   0xA0
      #define  E4C_CED   0x87
      #define  E4E_EGU   0x82
      #define  E4E_GRA   0x8A
      #define  E4E_CIR   0x88
      #define  E4E_TRE   0x89
      #define  E4I_TRE   0x8B
      #define  E4I_CIR   0x8C
      #define  E4I_EGU   0xA1
      #define  E4I_GRA   0x8D
      #define  E4N_ACC   0xA4
      #define  E4O_CIR   0x93
      #define  E4O_TRE   0x94
      #define  E4O_GRA   0x95
      #define  E4O_EGU   0xA2
      #define  E4U_CIR   0x96
      #define  E4U_GRA   0x97
      #define  E4U_TRE   0x81
      #define  E4U_EGU   0xA3
      #define  E4Y_TRE   0x98
      #define  E4CM_CED  0x80
      #define  E4AM_TRE  0x8E
      #define  E4AM_CIR  0x8F
      #define  E4EM_EGU  0x90
      #define  E4OM_TRE  0x89
      #define  E4UM_TRE  0x9A
   
   #else
   #ifdef S4GERMAN
   
      #define  E4_CLOSE            "Unbekannter Name"
      #define  E4_CREATE_FIL       "Dateiname"
      #define  E4_CREATE_TEM       "Zeitweilig arbeitende Datei"
      #define  E4_CREATE_TOO       "Zuviele Felder vorhanden"
      #define  E4_ERROR            "Fehler"
      #define  E4_ERROR_NUM        "\r\n\r\nFehler Nummer"
      #define  E4_ERROR_SEV        "\r\n\r\nSevere Fehler Nummer"  
      #define  E4_ERROR_BAS        "CODEBASIC FEHLER"
      #define  E4_ERROR_COD        "CODEBASE FEHLER"
      #define  E4_ERROR_CDS        "CODEBASE SEVERE FEHLER" 
      #define  E4_ERROR_ENT        "\r\nPress Enter ..."     /* */
      #define  E4_ERROR_KEY        "\r\nPress a key ..."     /* */
      #define  E4_INDEX_COR        "Besch�digte freie Blockkette in der Indexdatei"
      #define  E4_INDEX_EXP        "Die erwartete '.CDX' Datei ist vom '.IDX' Typ"
      #define  E4_INDEX_FIL        "Der Filter sollte logisch sein"
      #define  E4_INFO_AME         "Ein Memo Block wurde zweimal gen�tzt"
      #define  E4_INFO_CAL         "Der Aufruf von d4reccount() in r4reindex_blocks init() ist nicht gelungen"
      #define  E4_INFO_CLO         "Fehler bei Abschlu� der Gruppendatei in i4open()"
      #define  E4_INFO_DAT         "Datenbank ist leer"
      #define  E4_INFO_INC         "Fehlerhafte Satznummer in 'Tag'"
      #define  E4_INFO_KEY         "Fehler bei der Schl�sselauswertung"
      #define  E4_INFO_LOC         "Fehler beim Locken in i4open()"         
      #define  E4_INFO_REA         "Fehler beim Lesen der Gruppendatei in i4open()"
      #define  E4_INFO_REC         "Ein Satz fehlt"
      #define  E4_INFO_REP         "Wiederholte Satznummer in 'Tag'"
      #define  E4_INFO_SET         "C4CODE.auto_open ausschalten"
      #define  E4_INFO_SKI         "Skip must be made from valid record number"   /* */
      #define  E4_INFO_TAG         "'Tag' ist besch�digt"
      #define  E4_INFO_UNL         "Fehler bei der Freigabe der Gruppendatei in i4open()"
      #define  E4_MEMORY_B         "Der Block ist zum Indexieren zu umfangreich"
      #define  E4_MEMORY_S         "Sortieren"
      #define  E4_NUM_PARMS        "Funktion"
      #define  E4_RESULT_D4F       "d4flush record() funktionierte nicht" 
      #define  E4_RESULT_EXP       "Es werden logische Ergebnisse erwartet"
      #define  E4_RESULT_IDE       "Identische Schl�ssel in eindeutigem 'Tag'"                  
      #define  E4_RESULT_LOS       "Block in Indexdatei ging verloren"
      #define  E4_RESULT_REC       "Nummern der Datens�tze f�r gleiche Schl�ssel folgen nicht der Reihe nach"
      #define  E4_RESULT_TAG       "'Tag' ist veraltet"
      #define  E4_RESULT_THE       "'Tag' ist nicht in Ordnung" 
      #define  E4_RESULT_UNE       "Unerwartete L�nge bei Schl�sselauswertung"
      #define  E4_RESULT_WAS       "Raum in der Memo Datei ging verloren" 
      #define  E4_TYPE_SUB         "Ausdruck"
      #define  E4_UNIQUE           "'Tag' wird angelegt"
      
      /* e4severe() Meldungen*/      
      #define  E4_DATA_ILL         "Nichtzul�ssige Felddaten"
      #define  E4_DATA_MEM         "Memo Datei f�r 'Append' wurde nicht angelegt"
      #define  E4_INFO_ALR         "Wurde bereits initialisiert"
      #define  E4_INFO_BAD         "Defekte NTX Clipper Indexdatei"
      #define  E4_INFO_BLO         "Blockgr��e betr�gt weniger als 1024 Byte"
      #define  E4_INFO_BLS         "Die minimale Blockgr��e von 1024 Byte ben�tigt"                
      #define  E4_INFO_BMC         "Blockspeicher besch�digt"
      #define  E4_INFO_C4C         "'C4CODE.mem size block' ist ein unzul�ssiger Wert"
      #define  E4_INFO_COD         "Innerer Fehler in CodeBase"
      #define  E4_INFO_CIF         "Indexdatei ist besch�digt"
      #define  E4_INFO_CIB         "Indexblock ist besch�digt"
      #define  E4_INFO_CIS         "Indexblockstruktur ist besch�digt"
      #define  E4_INFO_CMF         "Speicherdatei ist besch�digt"
      #define  E4_INFO_CRL         "Verkettete Liste ist besch�digt"
      #define  E4_INFO_DAO         "Datenbank-Datei bereits angelegt" 
      #define  E4_INFO_DEL         "Der zu l�schende Block ist nicht leer"  
      #define  E4_INFO_DUP         "Alias ist verdoppelt"                                     
      #define  E4_INFO_EPV         "Erwarteter Wert wurde nicht gebildet"
      #define  E4_INFO_EVA         "'Tag' Ausdruck wird ausgewertet"
      #define  E4_INFO_EXK         "Ausdrucksschl�ssel �berschreitet das maximum von 102 Zeichen"
      #define  E4_INFO_EXP         "Ausdruck ist zu lang"
      #define  E4_INFO_FOR         "f�r 'Tag'"
      #define  E4_INFO_ILF         "nichtzul�ssiger Bezug auf Dateiblock"
      #define  E4_INFO_ILL         "nichtzul�ssige Konfiguration beim Locken" 
      #define  E4_INFO_ILP         "nichtzul�ssige Position"
      #define  E4_INFO_INT         "innerer Fehler im t4remove_current() Indexdatei besch�digt"  
      #define  E4_INFO_INV         "Ung�ltiger Schl�sseltyp in der Indexdatei"                                                                  
      #define  E4_INFO_IVT         "Ung�ltiger Typ"
      #define  E4_INFO_LIN         "Linker befindet sich nicht auf der Liste"
      #define  E4_INFO_NKE         "n_Schl�ssel sind ung�ltig"
      #define  E4_INFO_STR         "Funktion entdeckte ung�ltigen Strukturzeiger"
      #define  E4_INFO_UNE         "Unerwarteter leerer Block"
      #define  E4_INFO_UNT         "Unerwartetes Locken des 'Tag' in der Indexdatei"
      #define  E4_INFO_WRO         "Falsche Nummer der Linker auf der verketteten Liste"
      #define  E4_INFO_WT4         "Falscher T4TAG Typ"
      #define  E4_MEMORY_ERR       "Fehler des Speichers"
      #define  E4_MEMORY_SAV       "14lock_save(), Information zum Locken wird gespeichert"
      #define  E4_MEMORY_YPO       "y4pop_pointer() mit S4DEBUG Umschalter"
      #define  E4_MEMORY_YPU       "y4push_pointer() mit S4DEBUG Umschalter"
      #define  E4_OPEN_NOD         "i4open(): keine Datenbank wurde spezifiziert"
      #define  E4_PARM_FLA         "Wert des Flags sollte 'r4descending' sein"
      #define  E4_PARM_FOR         "F�r die Version S4CLIPPER/NDX sollten Filter und Abstieg gleich 0 sein"
      #define  E4_PARM_H4R         "h4read() mit negativer Position"
      #define  E4_PARM_ILP         "nichtzul�ssige Position"
      #define  E4_PARM_IND         "Indexdatei wurde bereits angelegt"
      #define  E4_PARM_INV         "Ung�ltige Position beim Locken"
      #define  E4_PARM_NUL         "Nullwertiger Datenbankzeiger"
      #define  E4_PARM_REC         "Nummern der Datens�tze befinden sich nicht in der Reihenfolge"
      #define  E4_PARM_TAG         "'Tag' Ausdruck ist nicht vorhanden"
      #define  E4_PARM_TOO         "Zuviele 'Tags' vorhanden"
      #define  E4_PARM_UNI         "Der Wert der eindeutigen Flag Daten wurde nicht erkannt"
      #define  E4_PARM_ZER         "Nullparameter"
      #define  E4_RESULT_CLI       "Schl�sselkonvertierung f�r CLIPPER konnte nicht vollzogen werden" 
      #define  E4_RESULT_COM       "Besch�digter Speicher wurde entdeckt"
      #define  E4_RESULT_COR       "Besch�digte Indexdatei wird gepr�ft"
      #define  E4_RESULT_D4A       "d4append_start() wurde nicht beendet"
      #define  E4_RESULT_D4I       "d4init() wurde nicht aufgerufen"
      #define  E4_RESULT_EXI       "Die Warteposition beim Locken wird verlassen"
      #define  E4_RESULT_FRE       "Freier Wert wurde nicht gefunden"
      #define  E4_RESULT_INC       "Unrichtige Reihenfolge beim Locken der Indexdatei"
      #define  E4_RESULT_INQ       "Schnelle Sortierung" 
      #define  E4_RESULT_LOC       "Locken des Indexes k�nnte einen 'deadlock' bewirken"
      #define  E4_RESULT_LCO       "�berlappung beim Locken wurde entdeckt"
      #define  E4_RESULT_MEM       "Speicherplatz wurde nicht freigegeben"
      #define  E4_RESULT_REM       "Ein niemals plazierter Locker wird entfernt"
      #define  E4_RESULT_S4L       "S4LOCK_CHECK kann nicht mit 'y4reset' ben�tzt werden"
      #define  E4_RESULT_STC       "Die gestapelte L�ngenvariable _stklen ist unter dem Minimum"
      #define  E4_RESULT_TOO       "Zuviele Zeiger vorhanden"
      
      #ifdef S4WINDOWS
         #define E4_RESULT_CRE     "Anlegen eines Drucker Bildschirm Kontextes"
         #define E4_RESULT_DEL     "L�schen eines Bildschirm Kontextes" 
         #define E4_RESULT_END     "Ein Dokument wird beendet"  
         #define E4_RESULT_G4D     "G4DISPLAY Puffer fehlt"
         #define E4_RESULT_G4E     "G4EDIT Puffer fehlt"
         #define E4_RESULT_G4L     "G4LIST Puffer fehlt"
         #define E4_RESULT_ON      "Im neuen Rahmen" 
         #define E4_RESULT_SET     "Ein Font wird definiert"
         #define E4_RESULT_STA     "Drucken eines Dokuments beginnt"
         #define E4_MESSAG_EXI     "APPLIKATION VERLASSEN"
         #define E4_MESSAG_CAN     "Cancel"
         #define E4_MESSAG_OK      "OK"
         #define E4_MESSAG_PAC     "Sind Sie sicher, da� Sie packen m�chten?"
         #define E4_MESSAG_REC     "SATZNUMMER"
         #define E4_MESSAG_REI     "Sind Sie sicher, da� Sie umindexieren m�chten?"
         #define E4_PARM_ADD       "Auswahll�nge mu� > 0 sein"
         #define E4_PARM_SA        "Ung�ltiger G4DISPLAY Zeiger"
         #define E4_PARM_VIS       "WS_VISIBLE-Modus nicht aktiv"
         #define E4_PARM_WIN       "Invalid Window Dimensions"  /* new */
         #define E4_RESULT_ADD     "String kann nicht angeh�ngt werden"
         #define E4_RESULT_BUF     "G4LIST-Buffer nicht gro� genug"
         #define E4_RESULT_CDC     "CreateCompatibleDC() nicht erfolgreich"
         #define E4_RESULT_ENW     "EnableWindow() nicht erfolgreich"
         #define E4_RESULT_GDC     "GetDC() nicht erfolgreich"
         #define E4_RESULT_GTM     "GetTextMetrics nicht erfolgreich"
         #define E4_RESULT_ID      "Ung�ltige ID Nummer"
         #define E4_RESULT_IDB     "Keine G4BUTTON ID Nummer"
         #define E4_RESULT_IDC     "Keine G4COMBO ID Nummer"
         #define E4_RESULT_IDD     "Keine G4DISPLAY ID Nummer"
         #define E4_RESULT_IDL     "Keine G4LIST ID Nummer"
         #define E4_RESULT_IDT     "Keine G4EDIT ID Nummer"
         #define E4_RESULT_PIC     "Falsches Eingabeformat"
         #define E4_RESULT_POS     "Falsche Position"
         #define E4_RESULT_RDC     "ReleaseDC() nicht erfolgreich"
         #define E4_RESULT_RES     "FindResource() nicht erfolgreich"
         #define E4_RESULT_TA1     "WM_TABSTOP-Modus nicht aktiv"
         #define E4_RESULT_TA2     "Auswahl darf nicht im WM_TABSTOP-Modus sein"
         #define E4_RESULT_WIN     "CreateWindow() nicht erfolgreich"
      #endif
   #else 
        #error No Specific Language Defined.
   #endif   /* ifdef S4GERMAN  */
   #endif   /* ifdef S4FRENCH  */
#endif  /*  ifndef S4LANGUAGE  */

