/*****************************************************************************
  PFL_SPEC.C

  PFL_SPEC assigns the designated serial port to a particular device. It
  also specifies the serial port communication parameters used for communi-
  cating with the device. All this information is passed to PFL_COM, which is
  used by the serial port interface routines of PFL (see PFLSRIAL.ASM).

  Note:
    PFL_SPEC requires that PFL_COM is previously installed. 

    Compile with small memory model (/AS) and stack checking off (/Gs). Then
    link with the object of MPEX_2F.SML.
  
  rnr  4-28-95
*****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pfl_clip.ch"
#include "pflsrial.h"
#include "mpex_2f.h"

#pragma intrinsic (strcpy, strlen)

#define DEBUGGING       0

/* parameter constants */
#define DEVICE_ARG      argv[1]
#define PORT_ARG        argv[2]
#define BRATE_ARG       argv[3]
#define PARITY_ARG      argv[4]
#define DBITS_ARG       argv[5]
#define SBITS_ARG       argv[6]
#define PTCOL_ARG       argv[7]

#define STRING_BEEP     printf("\a")

/* define arguments to be used */
typedef struct  
{
  char *name;
  int num;
} PARM_FIELD; /* parameter field */

PARM_FIELD device_parm[] =  /* device name or device ID */
  {
    {"SER_CUST_DISP", POS_CUST_DISP2 },
    {"SER_SCANNER"  , POS_SCAN       },
    {"SER_PRINTER"  , OPT_SLIP_PRNTR },
    {"SER_DRAWER"   , POS_CASH_DRAW  },
    {NULL           , -1             },
  };

PARM_FIELD port_parm[] =  /* COM port to be used */
  {
    {"COM1", PFL_COM1},
    {"COM2", PFL_COM2},
    {"COM3", PFL_COM3},
    {"COM4", PFL_COM4},
    {NULL  , -1       }
  };

PARM_FIELD baud_parm[] =  /* baud rate */
  {
    {"BR_110"  , BR_110  },
    {"BR_150"  , BR_150  },
    {"BR_300"  , BR_300  },
    {"BR_600"  , BR_600  },
    {"BR_1200" , BR_1200 },
    {"BR_2400" , BR_2400 },
    {"BR_4800" , BR_4800 }, 
    {"BR_9600" , BR_9600 },
    {"BR_19200", BR_19200},
    {"BR_38400", BR_38400},
    {NULL      , -1      }
  };

PARM_FIELD parity_parm[] =  /* parity */
  {
    {"P_NONE", P_NONE},
    {"P_ODD" , P_ODD },
    {"P_EVEN", P_EVEN},
    {NULL    , -1    }
  };

PARM_FIELD data_bit_parm[] =  /* data bits */
  {
    {"DB_7", DB_7},
    {"DB_8", DB_8},
    {NULL  , -1  }
  };  

PARM_FIELD stop_bit_parm[] =  /* stop bits */
  {
    {"SB_1", SB_1},
    {"SB_2", SB_2},
    {NULL  , -1  }
  };    

PARM_FIELD protocol_parm[] =  /* handshaking protocol */
  {
    {"H_NONE"   , H_NONE   },
    {"H_DTR_RTS", H_DTR_RTS},
    {"H_DTR"    , H_DTR    },
    {"H_RTS"    , H_RTS    },
    {NULL       , -1       }
  };

/* Function prototypes */
void check_parameter(int *par_ndex, PARM_FIELD *str_1, char *str_2, char *err_msg);

void main(int argc, char *argv[])
{
  /* parameter index */
  int par1_ndex, par2_ndex, par3_ndex, par4_ndex, par5_ndex;
  int par6_ndex, par7_ndex;
  int com1_id, com2_id, com3_id, com4_id;  /* port device ID */
  char port_assigned;
  int setup;
  
  if (argc != 8)
  {
    STRING_BEEP;
    puts("PFL_SPEC (R) - PFL Serial Port Device Specifier (Ver 1.01).");
    puts("Copyright (C) 1995 by FEMA Business Systems Corp.");
    puts("-----------------------------------------------------------");
    puts("Specify the following arguments:");
    puts("-- Device name");
    puts("  SER_CUST_DISP, SER_SCANNER, SER_PRINTER, SER_DRAWER");
    puts("-- COM port");
    puts("  COM1, COM2, COM3, COM4");
    puts("-- Baud rate");
    puts("  BR_110, BR_150, BR_300, BR_600, BR_1200, BR_2400,");
    puts("  BR_4800, BR_9600, BR_19200, BR_38400");
    puts("-- Parity");
    puts("  P_NONE, P_ODD, P_EVEN");
    puts("-- Data bits");
    puts("  DB_7, DB_8");
    puts("-- Stop bits");
    puts("  SB_1, SB_2");
    puts("-- Protocol");
    puts("  H_NONE, H_DTR_RTS, H_DTR, H_RTS\n");
    puts("Example: PFL_SPEC SER_SCANNER COM3 BR_9600 P_NONE DB_8 SB_1 H_NONE");

    exit(1);
  }
   
  /* validate command line arguments */
  
  /* verify device name */
  check_parameter(&par1_ndex, device_parm, DEVICE_ARG, "Device name...");

  /* verify port parameter */
  check_parameter(&par2_ndex, port_parm, PORT_ARG, "Port...");

  /* verify baud rate parameter */
  check_parameter(&par3_ndex, baud_parm, BRATE_ARG, "Baud rate...");

  /* verify parity parameter */  
  check_parameter(&par4_ndex, parity_parm, PARITY_ARG, "Parity...");

  /* verify data bit parameter */  
  check_parameter(&par5_ndex, data_bit_parm, DBITS_ARG, "Data bits...");

  /* verify stop bit parameter */  
  check_parameter(&par6_ndex, stop_bit_parm, SBITS_ARG, "Stop bits...");    

  /* verify protocol parameter */  
  check_parameter(&par7_ndex, protocol_parm, PTCOL_ARG, "Protocol...");      

  /* verify if PFL_COM is not installed */
  if (check_pfl_com() == 0)
  {
    STRING_BEEP;
    puts("PFL_COM not yet installed...");
    exit(1);
  }

  /* read serial port device ID */
  read_dev_id(&com1_id, &com2_id, &com3_id, &com4_id);

  /* check if the device is already assigned to a serial port */
  if (device_parm[par1_ndex].num == com1_id || 
      device_parm[par1_ndex].num == com2_id || 
      device_parm[par1_ndex].num == com3_id ||
      device_parm[par1_ndex].num == com4_id)
  {
    STRING_BEEP;
    printf("%s is already assigned...", DEVICE_ARG);
    exit(1);
  }      

  /* check if the designated serial port is already assigned to another device */
  port_assigned = 0;  
  switch (port_parm[par2_ndex].num)
  {
    case PFL_COM1: if (com1_id != -1)
                     port_assigned = 1;
                   break;
    case PFL_COM2: if (com2_id != -1)
                     port_assigned = 1;
                   break;
    case PFL_COM3: if (com3_id != -1)
                     port_assigned = 1;
                   break;
    case PFL_COM4: if (com4_id != -1)
                     port_assigned = 1;
                   break;
  }   

  if (port_assigned)  /* port already assigned */
  {
    STRING_BEEP;
    printf("%s already assigned to another device...", PORT_ARG);
    exit(1);
  }

  /* store serial port communication parameters */
  setup = baud_parm[par3_ndex].num | parity_parm[par4_ndex].num |
          data_bit_parm[par5_ndex].num | stop_bit_parm[par6_ndex].num;

  store_com_parm(port_parm[par2_ndex].num, device_parm[par1_ndex].num,
                 setup, protocol_parm[par7_ndex].num);          

#if DEBUGGING
  {
    int dev_id, setup2, protocol;

    printf("Stored device ID = %d, setup = %04x, protocol = %d\n", 
            device_parm[par1_ndex].num, setup, protocol_parm[par7_ndex].num);
                   
    read_com_parm(port_parm[par2_ndex].num, &dev_id, &setup2, &protocol);

    printf("Retrieved device ID = %d, setup = %04x, protocol = %d\n", 
            dev_id, setup2, protocol);

  }
#endif
  
  exit(0);
}  

void invalid_parameter(char *err_msg2, char *user_arg);

/*  check_parameter: validates the specified command line argument  */
void check_parameter(int *par_ndex, PARM_FIELD *str_1, char *str_2, char *err_msg)
{
  char match;  /* 1 if a match is found, otherwise it is set to 0 */
  
  /* verify device name */
  match = 0;  
  for (*par_ndex = 0; str_1[*par_ndex].name != NULL; ++(*par_ndex))
  {
    if (stricmp(str_1[*par_ndex].name, str_2) == 0)
    {
      match = 1;  /* match found */
      break;
    }
  }

  if (!match)
    invalid_parameter(err_msg, str_2);
}

/*  invalid_parameter: displays an error message and exits the program  */
void invalid_parameter(char *err_msg2, char *user_arg)
{
  static char err_msg[150] = "Invalid ";

  strcpy(err_msg+8, err_msg2);
  strcpy(err_msg+strlen(err_msg), user_arg);
  STRING_BEEP; 
  puts(err_msg);

  exit(1);
}
