/***
*
*  Memoedit.ch
*
*  Standard definitions for MEMOEDIT() user function
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


// User function entry modes

#define ME_IDLE       0      // idle, all keys processed
#define ME_UNKEY      1      // unknown key, memo unaltered
#define ME_UNKEYX     2      // unknown key, memo altered
#define ME_INIT       3      // initialization mode


// User function return codes

#define ME_DEFAULT       0      // perform default action
#define ME_IGNORE       32      // ignore unknown key
#define ME_DATA         33      // treat unknown key as data
#define ME_TOGGLEWRAP   34      // toggle word-wrap mode
#define ME_TOGGLESCROLL 35      // toggle scrolling mode
#define ME_WORDRIGHT   100      // perform word-right operation
#define ME_BOTTOMRIGHT 101      // perform bottom-right operation


// NOTE:  Return codes 1 - 31 cause MEMOEDIT() to perform the
// edit action corresponding to the key whose value is returned.

#define _MEMOEDIT_CH

