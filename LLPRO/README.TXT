************************************************************************
                         Traveling Software, Inc.
                        18702 North Creek Parkway
                       Bothell, Washington  98011
                             (206) 483-8088
************************************************************************

                       The Latest About LapLink Pro
                              Version 4.00

Welcome to LapLink Pro. The following notes include information that was
not available at the time the manual was printed. It also contains hints
for running LapLink Pro with specific kinds of hardware and software.

************************************************************************
If you're a new LapLink owner, be sure to mail in your registration card
to ensure that you will be notified of future releases of LapLink Pro.
************************************************************************

TABLE OF CONTENTS

   I. Modem Phone Numbers--Using Access Prefix and Account Suffix
  II. How the File Display Filters Affect Deletes, Copies, and Moves
 III. Hidden Files, Read-only Files, and System Files
  IV. Remote Install Tips and Notes
   V. Compression and the Selected Port
  VI. Using LapLink Pro with Other Traveling Software Products
 VII. Hardware Information
      A.   When LapLink Pro Does Not Recognize a Mouse or Port
      B.   The Xircom Parallel Port Multiplexor
      C.   Problems with Parallel Connections
      D.   Incompatible or Problem Modems
      E.   System Clock Speed
VIII. Miscellaneous Manual Corrections
  IX. Screen Savers and Memory-Resident Programs (TSRs)
   X. When File Lists Are Not Sorted
  XI. Working with Windows 3.0
      A.   Installing LapLink Pro in Windows
      B.   Suggestions for Working in the 386 Enhanced Mode
      C.   Running LapLink Pro in the Background
      D.   Windows and 9600 Baud Modems
 XII. Getting Technical Support
XIII. Making Suggestions to Improve LapLink Pro
------------------------------------------------------------------------
I.  MODEM PHONE NUMBERS--USING ACCESS PREFIX AND ACCOUNT SUFFIX

Since the LapLink Pro User's guide was written, two features have been
added to the Dial Modem dialog: Access Prefix and Account Suffix. You
can find instructions for using them in LapLink's on-line help.

Basically, these features let you create long phone numbers. When you
check the [ ] Use boxes, LapLink Pro attaches any number in the Access
Prefix record to the beginning of the number and any number in Account
Suffix to the end. It dials the resulting number.

Use Access Prefix to enter a number to dial out of a hotel or office--
"9," is common. Or, use it to enter an often used area code or country
code.

Use Account Suffix to enter a credit card number. Or, if your office
phone system requires you to type in an account number for long distance
calls, type it in here. If you have a WATS access code, it too could be
entered as an Account Suffix.

CAUTION: WHENEVER YOU DISPLAY THE DIAL MODEM DIALOG, THESE NUMBERS ARE
DISPLAYED. TAKE ANY PRECAUTIONS NECESSARY TO PREVENT UNAUTHORIZED
PERSONS FROM OBTAINING YOUR ACCOUNT NUMBERS.

To add the numbers, select the appropriate line and choose the <Modify>
button. In both numbers, commas may be used to pause dialing while the
phone system catches up to the modem. You can use as many commas as
needed for the length of the required pause.

------------------------------------------------------------------------
II. HOW THE FILE DISPLAY FILTERS AFFECT DELETES, COPIES, AND MOVES

The "File Display Options" command (Options menu) lets you show or hide
files. Files cannot be selected if they are hidden. Since hidden files
cannot be selected, they also cannot be copied, moved, or deleted.

This also holds true when you are working with directories and
subdirectories. (Subdirectories are indirectly selected when the Include
Lower Level Subdirectories copy option is enabled.)

For example, suppose you have set the "File Display Options" to display
only *.EXE and *.COM. If you select a directory and delete it, only the
.EXE and .COM files will be deleted. The directory structure and any
other files will remain in place.

If you want to delete, copy, or move an ENTIRE, directory, choose "File
Display Options" and check Show All Files first.

------------------------------------------------------------------------
III. HIDDEN FILES, READ-ONLY FILES, AND SYSTEM FILES

In order to protect important files, DOS allows files to have
"attributes." These include:

*   Hidden--The file does not show up when you use the DIR command
    (without special switches) and is not deleted when you type DEL *.*.

*   Read-only--The file cannot be deleted or edited but does show up
    with the DIR command.

*   System--The file has the same characteristics as a hidden file (it's
    not normally shown or deleted) and is essential to the functioning
    of DOS or another program.

Since LapLink Pro's main function is to simplify file management, it
lets you copy, move, and delete these types of files.

In a file list, hidden files are followed by an H; Read-only by an R;
and System by an S. WHEN YOU SEE ANY OF THESE CHARACTERS FOLLOWING A
FILE NAME, ALWAYS BE SURE YOU DO NOT NEED THE FILE BEFORE YOU DELETE IT.

In the file list mode, only one letter--H, R, or S--can be shown. If a
file has more than one attribute, an S will be shown before an H or R;
and an H will be shown before an R. For example if a file is both hidden
and read-only it will show as H; if a file has all three attributes, it
will show as S.

Because hidden files and system files are so rare, LapLink Pro does not
have a copy option that deals with them. They are displayed and can be
deleted as easily as other files.

The only files that are not displayed in a LapLink file list are those
that have both the hidden and system attribute AND are located in the
root directory of the disk. This is to protect two important files that
are always in the root directory of a bootable MS-DOS disk: IO.SYS and
MSDOS.SYS (they have slightly different names if you are using IBM DOS).
Because these files must be present in order to boot the disk, LapLink
Pro does not show them, or allow you to copy or delete them.

Read-only files are not as rare, and LapLink Pro offers two ways to
protect them. First, any time you make a selection and delete, LapLink
Pro will check the selection to see if it contains any read-only files.
If so, a warning box asks if you are sure you want to go on with the
deletion. Second, there is a copy option called Overwrite Read-only
Files. When the option is ON, a file WILL BE ALLOWED to copy over the
read-only file. When this option is OFF, LapLink Pro will not
automatically allow you to copy or move a file onto a read-only file of
the same name. Instead, the files are placed in a list from which you
must force the file transfer.

------------------------------------------------------------------------
IV. REMOTE INSTALL TIPS AND NOTES

Remote DOS Commands--When you use remote install, a user must type
commands on the remote PC. These commands are documented both in the
LapLink Pro User's Guide and in the instructions you see when you issue
the "Remote Install" command. If you have a problem with remote install,
always check to make sure the commands have been typed exactly as they
are shown in the instructions.

The remote user should be aware that some commands that he or she types
prevent the DOS prompt (C:>, for example) from displaying. And, the
final command, CTTY COMx, will make the remote PC appear to "lock up" as
the process begins.

Baud Rates--If you can't make remote install work over a cable, try
reducing the baud rate. You should reduce the rate from Automatic to
57,600 baud.

For modem remote installs, the transfer of the LapLink Pro program takes
place at 2400 or 1200 baud, even if both modems are capable of higher
speeds. This is because the initial modem connection is established by
the DOS MODE command, and once a modem connection is established the
speed cannot be changed. After the remote install, if both modems are
capable of higher speeds, you might want to hang up and change to a
higher speed (the remote user must also do this). Then, re-establish the
connection by dialing normally.

When LapLink is Already on the Target--If LapLink is already on the
target and the program is available on the DOS path, the remote's copy
of LapLink Pro will start and the remote install will not take place.
Over a modem, however, the resulting connection may not be seen. The
solution is to hang up. Have the remote user start LapLink Pro and you
can then dial the connection normally.

------------------------------------------------------------------------
V.  COMPRESSION AND THE SELECTED PORT

Even though you can manually turn the Compressed Data Transfer copy
option on or off, LapLink Pro may override your selection to enhance
transfer speeds. Specifically, if you have the option on and you are
using a parallel port in the accelerated (8-bit) mode, compression is
ignored (the parallel accelerated mode is more efficient by itself).

If you are running LapLink Pro under low memory conditions, compression
may be turned off automatically. The option will remain off until you
turn it on again with the "Copy Options" command.

When you are using a modem it is almost always more efficient to run
with compression on.

------------------------------------------------------------------------

VI. USING LAPLINK PRO WITH OTHER TRAVELING SOFTWARE PRODUCTS

Because WinConnect, DeskLink, and the LapLink III Device Driver compete
with LapLink Pro for port usage, using them with LapLink Pro may require
experimentation. In most cases, you need to delete the LapLink Pro
configuration file (LLPRO.CFG), start the other program, and then start
LapLink Pro. This causes LapLink Pro to re-check all available ports and
it then only uses the ports that are not currently in use by the other
program. (Note: When you delete LLPRO.CFG all Copy Options and Control
Panel settings are returned to their default values.) If you need help
with this procedure, call Traveling Software technical support.

Battery Watch Pro is compatible with LapLink Pro, but as with other
TSRs, you should avoid popping up the Battery Watch screen during a file
transfer.

------------------------------------------------------------------------

VII. HARDWARE INFORMATION

------------------------------------------------------------------------
   A.   When LapLink Pro Does Not Recognize a Mouse or Port

When you exit LapLink Pro, it saves a configuration file called
LLPRO.CFG. Among other things, this file saves the current port
information as shown by the "Port/Modem Setup" command.

This means that if you install a mouse AFTER using LapLink Pro, the
mouse will not be available the next time you start LapLink Pro. To
enable the mouse, choose the "Port/Modem Setup" command and select the
port to which the mouse is connected. Then, choose <Reset>. LapLink Pro
will check the port and show that it is using the mouse.

If you have been using a mouse but now want to use the port for LapLink,
use the same procedure.

For best results, you should also exit LapLink Pro and turn your PC off
and back on again.

------------------------------------------------------------------------
   B.   The Xircom Parallel Port Multiplexor

LapLink Pro has been designed to work with parallel ports that have a
Xircom Parallel Port Multiplexor. However, the system must first be set
up properly.

First, the LapLink parallel cable must be attached to the "A" port of
the multiplexor.

Second, you must make a change with the "Port/Modem Setup" command:

Choose the command, and in the Port/Modem Setup dialog, select the
parallel port with the multiplexor. In the next dialog place an x in the
Force Standard (4-bit) mode check box and choose <OK>. If you do not
make this change, the Multiplexor may try to switch between the printer
and the cable during the middle of a copy.

------------------------------------------------------------------------
   C.   Problems with Parallel Connections

Regardless of the communication program, some combinations of laptop PCs
cannot connect with each other, and a few cannot communicate in parallel
mode at all. Serial mode must be used with these combinations.

When you try to connect these problem PCs in parallel, LapLink Pro may
display a message--"Attempting to Connect"--and the system may "lock
up." One or both of the PCs may need to be restarted.

If you have problems connecting between two particular machines contact
Traveling Software technical support.

------------------------------------------------------------------------
   D.   Incompatible or Problem Modems

LapLink Pro is incompatible with modems that run at speeds less the
1,200 baud.

In addition, some external modems WILL NOT accept a modem remote
install. Internal modems do not exhibit this behavior. But, due to the
way the DSR pin is powered, these external modems will not accept data
when the remote user types: TYPE CON >COMx.

The easiest solution for PCs that use these modems is to install LapLink
Pro directly from disk. You may also be able to prepare a remote modem
to accept a remote install by using a communication program other than
the DOS MODE command. For further information, call Traveling Software
Technical Support.
------------------------------------------------------------------------
   E.   System Clock Speed

In very rare instances, after running LapLink Pro, the system clock on a
few PC models (including the PS/2 Model 50) seems to speed up. That is,
the time advances too quickly. If your PC seems to "gain time" after
running LapLink Pro, restart and exit LapLink Pro again. This usually
returns the speed to normal. Rebooting your PC will have the same
effect.

------------------------------------------------------------------------

VIII. MISCELLANEOUS MANUAL ADDITIONS AND CORRECTIONS

Using the "Make Directory" command.

The manual erroneously states that you can type a path when you create a
directory. This is not true. You can only type a valid directory name
(up to 8 characters optionally followed by a period and up to 3 more.)
The new directory is ALWAYS created as a subdirectory of the current
directory.

Using the "Clone Drive" command.

The "Clone Drive" command will not proceed if there is a possibility
that it will cause a previously bootable target disk to become
unbootable. This is a function of the DOS versions the disks use and
whether the drive is used to boot (start-up) the PC. The table below
shows you when Clone Drive will work:

Source ----> Target       DOS Version     Clone Drive Works?
--------     --------     -----------     ------------------
  Boot         Boot         Same                yes
  Boot       non-Boot       Any                 yes
non-Boot     non-Boot       Any                 yes
  Boot         Boot         Different           no
non-Boot       Boot         Any                 no

Remote Install Over Modems

During remote install, the clock on the local PC will lose time. If this
occurs, you can use the TIME command from the DOS command line to reset
your PC's clock. Rebooting the PC may perform the same function. See
your PC and DOS manual for more information.

In addition, sometimes the way a remote modem is set up will prevent
LapLink from remotely installing. Check the LapLink Pro Modem Tips and
Reference Guide for tips on preparing a remote modem for remote
installation.

Changing Your PC's Name

When you change your PC's name, the change will not be reflected on the
remote PCs during the current LapLink session. The next time you use
LapLink Pro, the new name will be shown.

Using the "Synchronize" Command

During Synchronize, copies are made in both directions and LapLink needs
to check BOTH PCs to see if there is enough room to hold the files.
First, one PC is checked; if there is enough room, the newer files are
copied. Then, the process proceeds in the opposite direction.

Because of this two-step operation, Synchronize will be halted if either
drive becomes full. This can happen during the first copy or the second.

Running Setup Programs Directly from LapLink Pro

CAUTION: DO NOT USE LAPLINK PRO TO LAUNCH A SETUP PROGRAM THAT IS USED
TO CHANGE CMOS MEMORY. YOUR PC MAY BECOME UNBOOTABLE.

For example, most laptop setup programs let you change power-saving
measures and the type of installed hard disk. Always exit LapLink Pro
before you use such a program. Setup programs are meant to be run stand-
alone and often reboot your PC. They should not be run from most shell
programs.

Using [Ctrl+Break] to Exit LapLink Pro

If LapLink Pro "locks up" you may still be able to exit the program by
pressing [Ctrl+Break]. If you use this procedure however, any options
changes that you have made in the current session will not be saved.

------------------------------------------------------------------------
IX. Screen Savers and Memory-Resident Programs (TSRs)

LapLink Pro allows most TSRs to pop-up during its operation. However,
you should not pop-up such programs during an active file transfer. The
PCs may become disconnected and the file transfer halted.

If you are using a screen saving device--either a software program that
you have purchased or the power-saving feature built into a laptop--the
screen saver may interfere with LapLink Pro. For example, if a remote
user has a connection with your PC and the screen saver activates, it
may cause the connection to be dropped.

This is because some screen savers block access to ports and others take
CPU (processing) power away from LapLink Pro.

If you want to set up a PC to receive remote modem calls, you should not
run a screen-saving program while LapLink Pro is active.

------------------------------------------------------------------------
X. When File Lists Are Not Sorted

Under some conditions your file lists may not be sorted, even if you
have specified a sort order with the "File Display Options" command
(Options menu). Two factors contribute to this condition: 1) The amount
of memory available to LapLink Pro, which you can check with the "System
Information" command in the Options menu; and 2) the number of files in
the directory. (In low memory situations, any directory containing more
than 150 to 200 files may be susceptible; with the maximum amount of
memory, failure to sort will not occur until there are about 2000
files.)

When a file list cannot be sorted, the files are displayed in the order
that they occur on your disk. Because of the lack of sorting, the quick
method of finding a file in the list is disabled--i.e. you can't press a
letter key to move to the file you want to find. However, the "Find
File" command (Disk menu) will still function. If you wish to select a
number of files that begin with the same letter but the list is
unsorted, you can use the "Select By" command on the Select menu.

------------------------------------------------------------------------
XI. WORKING WITH WINDOWS 3.0

------------------------------------------------------------------------
   A.   Adding LapLink Pro to Windows

1.  The LapLink Pro installation program installs two files especially
    for use with Windows 3.0: LLPRO.PIF and LLPRO.ICO. First, ensure
    that the files are located in the same directory as LLPRO.EXE. If
    they are not, copy the files from your LapLink Pro distribution
    disk.

2.  Next, start Windows. From the Program Manager, choose the program
    group (window) into which you want to place LapLink Pro. Then issue
    the "New" command from the File menu. In the next dialog, choose
    "Program Item" (the default) and OK. The "Program Item Properties"
    dialog box is displayed next.

3.  In the Command Line box, type LLPRO.PIF. Or, if you didn't allow the
    install program to add the LapLink Pro directory to your PATH
    statement, type the path and the file name--for example,
    C:\LLPRO\LLPRO.PIF. Don't click OK yet.

4.  Select the Change Icon button. In the File Name field in the next
    dialog, type LLPRO.ICO. (As in step 3, you may also need to include
    the path to the file.) After clicking OK, the icon should appear in
    the chosen group.

    NOTE: The LLPRO.PIF file does not allow LapLink Pro to function
    while the application is minimized. That is, you cannot transfer
    files while LapLink Pro is running in the background. Traveling
    Software has not tested background operation extensively. There are
    many Windows setup and hardware configurations that will prevent
    background operation completely. If you would like to try however,
    see "Running LapLink Pro in the Background" later in this file.

5.  To start LapLink Pro under Windows, double-click the LapLink Pro
    icon.

NOTE: If double-clicking does not start LapLink Pro, you may also have
to customize LLPRO.PIF. Use the Windows PIF Editor application and add
the LapLink directory to the Program Filename or Start-up Directory
fields. For more information see your Windows documentation.

------------------------------------------------------------------------
   B.   Suggestions for Working in the 386 Enhanced Mode

Under the Windows 386 Enhanced Mode, applications "contend" for the use
of devices such as serial and parallel ports. Because of this, you may
experience difficulties with LapLink Pro communications. The following
solutions will allow more robust connections.

*****Serial Port Solutions*****

Because of the way Windows 3.0 controls serial ports, LapLink Pro's
higher speeds may not be available. You have two solutions. You can
reduce the LapLink Pro's transfer mode and baud rate. Or, you can turn
off Window's serial port buffering. With the first solution you will
only be able to transfer files at a reduced rate. With the second
solution, LapLink will transfer as fast as it does directly from DOS,
but LapLink Pro cannot be used at the same time as other programs that
use the serial port (such as the Windows Terminal application).

a. Changing the Transfer Mode or Baud Rate

To change the transfer mode:

1.  Start LapLink Pro and choose the "Port/Modem Setup" command from the
    Options menu. A dialog is displayed that shows both serial and
    parallel ports. Select the serial port you are using for LapLink.

2.  Place an X in the Force Standard (3-wire) Mode field.

3.  Close both dialogs by selecting <OK> and then <Done>.

If you still experience communication problems, use the same method but
change the Max Baud Rate from Automatic to a lower value. 57,600 baud
may work but you may need to try as low as 19,200.

b. Turning Off Windows 3.0 Serial Port Buffering

NOTE: Although this solution will increase CABLE communication speed, it
may hamper modem communications. If you intend to use both a modem and a
cable, you may have to experiment to find the most optimal solution.

Your Windows default directory (usually C:\WINDOWS) contains a file
called SYSTEM.INI. This file contains many Windows environment settings
and is integral to the performance of Windows. Two lines in the [386
Enh] section of the file--device=*VCD and device=*COMBUFF--partially
control contention and buffering of serial ports. In the instructions
that follow, you edit SYSTEM.INI to turn these devices off.

CAUTION: ALWAYS MAKE A BACKUP OF THE SYSTEM.INI FILE BEFORE CHANGING IT.
WITHOUT A VALID SYSTEM.INI FILE WINDOWS WILL NOT RUN!

To edit your SYSTEM.INI file:
1.  Using a text editor, open SYSTEM.INI. You can use the LapLink Editor
    or the Windows Notepad application.

2.  Search for the following two lines in the [386 Enh] section:
      device=*vcd
      device=*combuff

3.  At the beginning of each line type a semicolon (;), so that they
    look like the following:
     ;device=*vcd
     ;device=*combuff

4.  Save the file and restart Windows.

*****Parallel Port Solutions*****

In most cases, LapLink Pro maintains parallel connections in all Windows
modes. If you experience problems in the 386 Enhanced mode, however, you
may want to add the following line to your SYSTEM.INI file:

SGrabLPT=#

For example, if you cannot connect over LPT1 add a line that reads:

SGrabLPT=1

The line does not normally appear in SYSTEM.INI. The line has the effect
of directing all of the ports "traffic" through the main Windows
program. Remember, anytime you edit SYSTEM.INI be sure to make a back up
the file first.

------------------------------------------------------------------------
   C.   Running LapLink Pro in the Background

Because of the way Windows "schedules" DOS background tasks, it is
difficult to configure Windows to allow background communication for any
DOS communication program, including LapLink Pro. And, there are many
Windows setup and hardware configurations that will prevent background
operation completely. Therefore, Traveling Software does not recommend
background operation, and the Windows PIF file that is shipped with
LapLink Pro (LLPRO.PIF) is not set up for background functionality.

However, if you want to try LapLink Pro in the background, you can edit
the PIF file and check the Background box. You will also need to
increase the number for background task priority.

If you just want to try to use LapLink Pro in the background for one
session without editing the PIF file, use the Settings command from the
LapLink Pro window's system menu. See your Windows documentation for
details.

In addition to these changes here are two more tips:

*   If you are running Windows in the 386 Enhanced mode, open the
    Windows Control Panel and choose 386 Enhanced. Make sure that the
    Exclusive in Foreground option is NOT checked. (When on, this option
    prevents any DOS application from running in the background.)

*   Try not to run other DOS applications while transferring files in
    the background.

------------------------------------------------------------------------
   D.   Windows and 9600 Baud Modems

If you are using a 9600 baud modem with Windows 3.0, you should be aware
that without modification, Windows may often "lock up" when running ANY
modem communications at 9600 baud. Unfortunately, this also includes
LapLink Pro. The problem is most notable when using a slower 80386SX PC.

There are two solutions to this problem:

*   Edit your SYSTEM.INI file to increase the number of characters that
    are buffered by the serial port. This allows the buffer to "keep up"
    with the modem's high speed.

*   In LapLink Pro, set your modem to run in the 2400 baud mode. This is
    a stable solution but forces your modem to run at a slower rate.

To edit SYSTEM.INI:

CAUTION: ALWAYS MAKE A BACKUP OF THE SYSTEM.INI FILE BEFORE CHANGING IT.
WITHOUT A VALID SYSTEM.INI FILE WINDOWS WILL NOT RUN!

1.  Using a text editor, open SYSTEM.INI. You can use the LapLink Editor
    or the Windows Notepad application.

2.  Search for the following two lines in the [386 Enh] section:
      device=*vcd
      device=*combuff

    Make sure these lines have not been turned off. (This read me
    recommends turning the lines off to permit higher speeds for CABLE
    connections only, not modem connections.)

3.  After these lines add a line that reads:
     COMxBuffer=4096

    For x, use the number of the serial port to which the modem is
    attached. (For example, if the modem is attached to COM1 the line
    would be:
    COM1Buffer=4096)

    This line increases the number of buffered characters from 128 to
    4096.

4.  Save the file and restart Windows.

To use a 9600 baud modem at 2400 baud:

1.  Choose the "Port/Modem Setup" command from the Options menu and
    select the port to which the modem is attached. If there are two
    initialization strings for your modem model, choose the one that
    ends in "@2400 baud."

2.  Choose the <Setup Port> button and set the Maximum Baud Rate to
    2,400.

------------------------------------------------------------------------
XII. GETTING TECHNICAL SUPPORT

If you have a question or need Technical Support, the following sources
are available:

In the U.S., Traveling Software telephone Technical Support is available
from 8:00 a.m. to 5:00 p.m., (Pacific Time) Monday-Friday at (206) 483-
8088. Please have your serial number ready before calling.

If you want to contact the TSI Technical Support bulletin board, set
your modem to dial (206) 485-1736. Use the following settings for your
communications program:

Baud rate      2400
Parity         None
Data bits      8
Stop bits      1

On GEnie type "LAPTOPS" to join the Laptops RoundTable. Then enter the
Laptops Bulletin Board and type "SET 3" to go to Traveling Software
Technical Support. Answers to the most frequently asked questions can be
found there. To sign up for GEnie call (800) 638-9636 (Voice).

For support in Europe, call +44 (0734) 321 154.

In Australia and New Zealand, Traveling Software products are sold and
supported by PC Extras. In Australia, phone (02) 319 2155; in New
Zealand, phone (09) 59 7834

For a complete listing of Traveling Software addresses and fax and phone
numbers see the back of the LapLink Pro User's Guide.

------------------------------------------------------------------------
XIII.  MAKING SUGGESTIONS TO IMPROVE LAPLINK PRO

Traveling Software is constantly looking for ways to improve its
products. Over the years, our customers have been the ones who have
provided some of the best product improvement suggestions.

We encourage you to send us your comments, criticisms, and ideas. We
will try to implement your requests in future versions.

You may address your comments to:

   Traveling Software, Inc.
   LapLink Pro Suggestions
   18702 North Creek Parkway
   Bothell, WA 98011

NOTE: For the LapLink Pro installation program, LHA was used to create a
self-extracting compressed file. LHA is a copyright of Yoshi, 1991. All
rights reserved.

Compiled October 11, 1991.
