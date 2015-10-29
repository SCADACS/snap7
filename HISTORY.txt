======================================================================[2015-06-14]
Version 1.4.0 - release for gourmets (fully compatible with 1.0.0)
----------------------------------------------------------------------------------

- Resourceless Server
- Utility added
- Improved .NET wrapper
- New .NET Demos
- Solution also for .NET Console demos
- Small bugfix

[Added]

- Resourceless server
  Now Snap7Server can work in "resourceless" mode, i.e. you don’t need to share 
  resources (DB, E, A…) with it : On every read/write request a callback is 
  called passing it the TAG (Type of memory E,A,DB..,DB number if any, Start, 
  Size, WordLen), and a pointer to the internal server area to read/write your 
  data “on demand”.

  The 1.4.0 wrappers were updated to reflect this new mode and I wrote some 
  examples on how to use this feature, that however is very simple.
  Purpose:
  - Protocol converters.
  - HMI Analyzers.
  - Flow Splitters/Routers.

- Utility 
  There is a new folder that contains some interesting (I hope) utilities.
  They are demo programs with a "real purpose".
  The first is HMITracer, a program that shows how use the new resourceless
  server. It simulates a PLC and lists all Tags referenced by an external HMI.
  A detailed PDF report is generated also.

[Improved]

- Improved .NET wrapper 
  Now the S7 Helper class can convert *ALL* S7 types, including the new 
  S71200/1500 64 bit   types : 
  - 8, 16, 32, 64 bit signed and unsigned values.
  - Long real (64 bit)
  - Long Date/Time, Long Time of Day

- Added the class S7MultiVars which greatly simplifies the reading and writing of
  MultiVars.

- New .NET Demos
  Added WinForm Server Demo and MultiRead vars Demo.
  Added 64 platform for all demos
  Added the compilation of Snap7.net.cs for VB demos.

- Solution also for .NET Console demos
  A VS2013 solution for .NET console demos was added.
  you no longer need the of the batch file to build the demos.

- Reduced the memory footprint of Snap7Server (there was an unused memory block).

[Fixed]

- (Only Windows) If an attacker gains control of the application directory, he 
  could force the application to load a malicious copy of iphlpapi.dll (which 
  is used for ping).
  Now iphlpapi.dll is loaded from the Windows system directory.
  Thanks to the Security engineer Alexandre CHERON for reporting it.


======================================================================[2015-01-01]
Version 1.3.0 - Platform / Comfort release (fully compatible with 1.0.0)
----------------------------------------------------------------------------------

Platform
- Runtime Big-Endian architecture support. No compilers swithes are needed.
- Sun Sparc and Mips BE architectures are now supported.
- Arduino YUN

Comfort
- Added WinForm.net demos (C# and VB)
- Improved documentation (added .NET chapter for beginners *please read it*)
  Added also a chapter about Siemens data format.
- Added Helper class/functions

==================================================================================
[Added]


- Helper class/function to insert/extract S7 typed vars from a byte[] buffer. 
  You will find them into the wrappers (.net/Pascal/C++)
- Solaris Sparc support
  (Thanks to Rolf Stalder for makefiles)
- Arduino YUN support
  (Thanks to Fulvio Bosco and Stefano Bonnin)
- .Net Winform small demos
- .Net solution for rebuilding snap7.net.cs


[Improved]

- Unix, now the client doesn't need root priviledges to perform the SmartConnect.
  (Thanks to Rolf Stalder)
- Solaris now uses standard pthreads.
  (Thanks to Rolf Stalder)
- Read/WriteMultiVars now checks in advance if the data fits into the PDU size.
- .net S7Client.ReadMultivars (and Write) was improved.
  (Thanks to LanceL who made it)
- S7Client now checks if it's connected before do anything.
  (Thanks to Mathias Küsel for reporting it)


[Latest OS]

- Tested with Ubuntu 14.10 (32/64)
- Tested with Windows 10 Technical Preview (32/64)


[fixed]

- Fixed some Typo errors into snap7.net.cs
- Fixed a small bug into Read/WriteMultiVars


======================================================================[2014-04-17]
Version 1.2.1 - Bugfix/Small changes release (fully compatible with 1.0.0)
----------------------------------------------------------------------------------
- Some small Apple Mac OSX changes (Tested under OSX 10.9.1 Mavericks)
- Some bug fixed
- Documentation updated.

- Some OLD/RARELY USED libraries are not longer deployed.
  but *THEY ARE STILL TESTED AND SUPPORTED*

  If you don't have the way to rebuild Snap7 in these platforms please contact me 
  and I will try to help you.

  They are :
  - Linux i386/x86_64 GLIBC 2.11 up to 2.15  
  - Linux ARMHF BeagleBone Black, CubieBoard 2, PcDuino.

- A new Linux distro is supported (Ubuntu 14.04 LTS and derivatives GLIBC 2.19)

- Old Windows Platforms are still fully supported but you will find them into
  \release\windows\Legacy\Win32 and Win64.

  This because many people had problems with .NET environment (which doesn't like
  non-Microsoft Libraries on some platforms), so the official Windows libraries are
  now compiled with Visual Studio.

  If you plan to use MinGW64, use Legacy libraries (wich work fine up to Windows 8).

==================================================================================

[Changed]

- Unix, now it's possible to specify the destination folder of the library using the
  optional param LibInstall=<NewPath> into the make command line. If not specified
  the default path is /usr/lib.
  (thanks to Gijs Molenaar)

- Apple OSX, now the library suffix is .dylib instead of .so
  however it's possible override the suffix using the LibExt param (see doc.)
  (thanks to Gijs Molenaar)

[fixed]

- Fixed a typo error into snap7.net.cs (Cli_GetPlcStatus)
  (Thanks to Dabbadoeber for reporting)

- Fixed a bug into s7_micro_client.cpp into block download function.
  (Thanks to Mark Konst for reporting)

- fixed a bug into s7_partner.cpp (issues for transfers>PDU size)
  (Thanks to Volker Sarnes)

- fixed a bug into s7_server.cpp (wrong bit access)
  (Thanks to Thomas Costa)

- little modification to client.cs and ppartner.cs to be compiled with VS2008 which
  doesn't handle the constant (default) parameter in a method declaration.
  (thanks to Max Schaetzel for reporting) 


======================================================================[2014-01-01]
Version 1.2.0 - New Minor platform release (fully compatible with 1.0.0)
----------------------------------------------------------------------------------
- Apple Mac OSX support (Tested under OSX 10.9.1 Mavericks)
- Some bug fixed
- Documentation improved and updated.
==================================================================================

[Added]

- Apple OSX full support :
  makefiles, source examples, binary library and binary demos supplied.
  new osx folders added in the entire project. 

[fixed]

- S7API directive missing for two functions in snap7_libmain.h
  (Thanks to Mathias Küsel for reporting)

- fixed Snap7.S7Server.Srv_RegisterArea in snap7.net.cs
  (Thanks to André for reporting).

- Added a static var to contain the callback addresses into c# examples.
  The .net garbage collector *sometime* garbages the delegates (called by unmanaged
  code) if their address is not stored into a static var.
  MS says that it's not a clr bug (maybe a feature ????)
  However this solves the problem.
  PLEASE SEE THE .NET EXAMPLES IF YOU PLAN TO USE SNAP7 (or other unmanaged)
  CALLBACKS.
  (Thanks to Martin Bratt for reporting).

- Srv_SetReadEventsCallback prototype missing in Snap7.pas


======================================================================[2013-11-10]
Version 1.1.0 - New Minor hardware release (fully compatible with 1.0.0)
----------------------------------------------------------------------------------
- LOGO 0BA7 Ethernet support (as client/server and Network I/O blocks)
- S7200 (via CP243) experimental support
- New Callback for S7Server that allow writing full synchronous gateways (protocol
  translators)
- New rich-demos
- Some bug fixed
- Documentation improved and updated.
==================================================================================

[Added]

- Cli_GetConnected function added.
  It returns the connection status of the client.

- Cli_SetConnectionType function added.
  For a Client it's possible to connect to a PLC as PG/OP/S7 Basic.

- Cli_SetConnectionParams function added.
  For a Client now it's possible to specifying Local and Remote TSAP before the
  connection.
  Needed for LOGO, S7200 and future hardware compatible with S7Protocol.

- Srv_SetReadEventsCallback function added.
  It allows to trap the read event from a client *before* the data getting.

- New ClientDemo and ServerDemo for the latter functions were supplied.

- LOGO examples were supplied.

- New rich-demos for Cubieboard 2 (under Cubian OS)

- Glibc_2.11 for Linux x86_64 Release

- Full documentation updated.

[Fixed]

- Expression bug in line 491 of /examples/pascal/client.dpr
  "if ParamCount=4" must be "if ParamCount=3"
  (thanks to Jean-Noel Voirol)

- Bug in S7Worker (Snap7Server) that returned "Data mismatch" error in MultiWrite
  function when writing ODD amount of bytes in items with index>1

- Bug in TSAP calculation in S7Client connection that sent wrong connection
  telegram to S7400 when the CPU was in Rack>1
  (thanks to hujingqi for the detailed analysis)


======================================================================[2013-09-03]
Version 1.0.0 
==================================================================================

- First public release.

==================================================================================




