#ifndef KEYMAP_HEADER
#define KEYMAP_HEADER

#include "powerpos.ch"
#define CONFIG_KEY_FILE     "KEYMAP.CFG"

#ifdef ONESHOT_PLU
  #include "keymap1.ch"
#else
  #include "keymap2.ch"
#endif
                            

#endif
