/*****
 *
 * MANAGER.CH
 * Header file for the MANAGER system
 *
 *
 * RMAKE manager
 *
 */

#define        GO_AHEAD            1
#define        ERASE_OK            0
#define        RENAME_OK           0

#xcommand      STABILIZE <x> =>    DISPBEGIN();;
                                   WHILE !(<x>:stabilize());;
                                   END;;
                                   DISPEND()

#xtranslate    .filename     =>    \[1\]
#xtranslate    .filesize     =>    \[2\]
#xtranslate    .filedate     =>    \[3\]
#xtranslate    .filetime     =>    \[4\]
#xtranslate    .fileattrib   =>    \[5\]

#xtranslate    .boxTitle     =>    \[1\]
#xtranslate    .boxMessage   =>    \[2\]
#xtranslate    .boxFileName  =>    \[3\]
#xtranslate    .boxFirstOpt  =>    \[4\]
#xtranslate    .boxSecondOpt =>    \[5\]

// EOF - MANAGER.CH //
