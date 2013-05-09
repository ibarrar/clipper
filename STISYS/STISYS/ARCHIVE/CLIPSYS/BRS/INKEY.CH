/***
*       Inkey.ch
*       Standard INKEY() key-code definitions
*       Copyright (c) 1990-1991 Nantucket Corp.  All rights reserved.
*/

// Cursor movement keys
#define K_UP            5       // Uparrow, Ctrl-E
#define K_DOWN          24      // Dnarrow, Ctrl-X
#define K_LEFT          19      // Leftarrow, Ctrl-S
#define K_RIGHT         4       // Rightarrow, Ctrl-D
#define K_HOME          1       // Home, Ctrl-A
#define K_END           6       // End, Ctrl-F
#define K_PGUP          18      // PgUp, Ctrl-R
#define K_PGDN          3       // PgDn, Ctrl-C
#define K_CTRL_LEFT     26      // Ctrl-Leftarrow, Ctrl-Z
#define K_CTRL_RIGHT    2       // Ctrl-Rightarrow, Ctrl-B
#define K_CTRL_HOME     29      // Ctrl-Home, Ctrl-]
#define K_CTRL_END      23      // Ctrl-End, Ctrl-W
#define K_CTRL_PGUP     31      // Ctrl-PgUp, Ctrl-Hyphen
#define K_CTRL_PGDN     30      // Ctrl-PgDn, Ctrl-^
#define K_CTRL_RET      10      // Ctrl-Return

#define K_ESC           27      // Esc, Ctrl-[
#define K_RETURN        13      // Return, Ctrl-M
#define K_ENTER         13      // Enter, Ctrl-M


// Editing keys
#define K_INS           22      // Ins, Ctrl-V
#define K_DEL           7       // Del, Ctrl-G
#define K_BS            8       // Backspace, Ctrl-H
#define K_CTRL_BS       127     // Ctrl-Backspace
#define K_TAB           9       // Tab, Ctrl-I
#define K_SH_TAB        271     // Shift-Tab


// Control keys
#define K_CTRL_A        1       // Ctrl-A, Home
#define K_CTRL_B        2       // Ctrl-B, Ctrl-Rightarrow
#define K_CTRL_C        3       // Ctrl-C, PgDn, Ctrl-ScrollLock
#define K_CTRL_D        4       // Ctrl-D, Rightarrow
#define K_CTRL_E        5       // Ctrl-E, Uparrow
#define K_CTRL_F        6       // Ctrl-F, End
#define K_CTRL_G        7       // Ctrl-G, Del
#define K_CTRL_H        8       // Ctrl-H, Backspace
#define K_CTRL_I        9       // Ctrl-I, Tab
#define K_CTRL_J        10      // Ctrl-J
#define K_CTRL_K        11      // Ctrl-K
#define K_CTRL_L        12      // Ctrl-L
#define K_CTRL_M        13      // Ctrl-M, Return
#define K_CTRL_N        14      // Ctrl-N
#define K_CTRL_O        15      // Ctrl-O
#define K_CTRL_P        16      // Ctrl-P
#define K_CTRL_Q        17      // Ctrl-Q
#define K_CTRL_R        18      // Ctrl-R, PgUp
#define K_CTRL_S        19      // Ctrl-S, Leftarrow
#define K_CTRL_T        20      // Ctrl-T
#define K_CTRL_U        21      // Ctrl-U
#define K_CTRL_V        22      // Ctrl-V, Ins
#define K_CTRL_W        23      // Ctrl-W, Ctrl-End
#define K_CTRL_X        24      // Ctrl-X, Dnarrow
#define K_CTRL_Y        25      // Ctrl-Y
#define K_CTRL_Z        26      // Ctrl-Z, Ctrl-Leftarrow


// Alt keys
#define K_ALT_A         286     // Alt-A
#define K_ALT_B         304     // Alt-B
#define K_ALT_C         302     // Alt-C
#define K_ALT_D         288     // Alt-D
#define K_ALT_E         274     // Alt-E
#define K_ALT_F         289     // Alt-F
#define K_ALT_G         290     // Alt-G
#define K_ALT_H         291     // Alt-H
#define K_ALT_I         279     // Alt-I
#define K_ALT_J         292     // Alt-J
#define K_ALT_K         293     // Alt-K
#define K_ALT_L         294     // Alt-L
#define K_ALT_M         306     // Alt-M
#define K_ALT_N         305     // Alt-N
#define K_ALT_O         280     // Alt-O
#define K_ALT_P         281     // Alt-P
#define K_ALT_Q         272     // Alt-Q
#define K_ALT_R         275     // Alt-R
#define K_ALT_S         287     // Alt-S
#define K_ALT_T         276     // Alt-T
#define K_ALT_U         278     // Alt-U
#define K_ALT_V         303     // Alt-V
#define K_ALT_W         273     // Alt-W
#define K_ALT_X         301     // Alt-X
#define K_ALT_Y         277     // Alt-Y
#define K_ALT_Z         300     // Alt-Z
#define K_ALT_1         376     // Alt-1
#define K_ALT_2         377     // Alt-2
#define K_ALT_3         378     // Alt-3
#define K_ALT_4         379     // Alt-4
#define K_ALT_5         380     // Alt-5
#define K_ALT_6         381     // Alt-6
#define K_ALT_7         382     // Alt-7
#define K_ALT_8         383     // Alt-8
#define K_ALT_9         384     // Alt-9
#define K_ALT_0         385     // Alt-0

// Function keys
#define K_F1            28      // F1, Ctrl-\
#define K_F2            -1      // F2
#define K_F3            -2      // F3
#define K_F4            -3      // F4
#define K_F5            -4      // F5
#define K_F6            -5      // F6
#define K_F7            -6      // F7
#define K_F8            -7      // F8
#define K_F9            -8      // F9
#define K_F10           -9      // F10
#define K_F11           -40     // F11
#define K_F12           -41     // F12

// Control-function keys
#define K_CTRL_F1       -20     // Ctrl-F1
#define K_CTRL_F2       -21     // Ctrl-F2
#define K_CTRL_F3       -22     // Ctrl-F4
#define K_CTRL_F4       -23     // Ctrl-F3
#define K_CTRL_F5       -24     // Ctrl-F5
#define K_CTRL_F6       -25     // Ctrl-F6
#define K_CTRL_F7       -26     // Ctrl-F7
#define K_CTRL_F8       -27     // Ctrl-F8
#define K_CTRL_F9       -28     // Ctrl-F9
#define K_CTRL_F10      -29     // Ctrl-F10
#define K_CTRL_F11      -44     // Ctrl-F11
#define K_CTRL_F12      -45     // Ctrl-F12

// Alt-function keys
#define K_ALT_F1        -30     // Alt-F1
#define K_ALT_F2        -31     // Alt-F2
#define K_ALT_F3        -32     // Alt-F3
#define K_ALT_F4        -33     // Alt-F4
#define K_ALT_F5        -34     // Alt-F5
#define K_ALT_F6        -35     // Alt-F6
#define K_ALT_F7        -36     // Alt-F7
#define K_ALT_F8        -37     // Alt-F8
#define K_ALT_F9        -38     // Alt-F9
#define K_ALT_F10       -39     // Alt-F10
#define K_ALT_F11       -46     // Alt-F11
#define K_ALT_F12       -47     // Alt-F12

// Shift-function keys
#define K_SH_F1         -10     // Shift-F1
#define K_SH_F2         -11     // Shift-F2
#define K_SH_F3         -12     // Shift-F3
#define K_SH_F4         -13     // Shift-F4
#define K_SH_F5         -14     // Shift-F5
#define K_SH_F6         -15     // Shift-F6
#define K_SH_F7         -16     // Shift-F7
#define K_SH_F8         -17     // Shift-F8
#define K_SH_F9         -18     // Shift-F9
#define K_SH_F10        -19     // Shift-F10
#define K_SH_F11        -42     // Shift-F11
#define K_SH_F12        -43     // Shift-F12

