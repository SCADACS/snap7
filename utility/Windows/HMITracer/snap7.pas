(*=============================================================================|
|  PROJECT SNAP7                                                         1.4.0 |
|==============================================================================|
|  Copyright (C) 2013, 2014 Davide Nardella                                    |
|  All rights reserved.                                                        |
|==============================================================================|
|  SNAP7 is free software: you can redistribute it and/or modify               |
|  it under the terms of the Lesser GNU General Public License as published by |
|  the Free Software Foundation, either version 3 of the License, or           |
|  (at your option) any later version.                                         |
|                                                                              |
|  It means that you can distribute your commercial software linked with       |
|  SNAP7 without the requirement to distribute the source code of your         |
|  application and without the requirement that your application be itself     |
|  distributed under LGPL.                                                     |
|                                                                              |
|  SNAP7 is distributed in the hope that it will be useful,                    |
|  but WITHOUT ANY WARRANTY; without even the implied warranty of              |
|  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               |
|  Lesser GNU General Public License for more details.                         |
|                                                                              |
|  You should have received a copy of the GNU General Public License and a     |
|  copy of Lesser GNU General Public License along with Snap7.                 |
|  If not, see  http://www.gnu.org/licenses/                                   |
|==============================================================================|
|                                                                              |
|  Object PASCAL Interface Classes                                             |
|                                                                              |
|  Compatibility :                                                             |
|     Delphi/Embarcadero RAD : All 32/64 bit releases (Windows)                |
|     FreePascal (1)         : 2.4.0+  32/64 bit      (Windows/Unix)           |
|                                                                              |
|=============================================================================*)
unit snap7;
interface
{$IFDEF FPC}
   {$MODE DELPHI}
{$ENDIF}

// Old compilers don't define MSWINDOWS
{$IFDEF WIN32}
  {$IFNDEF MSWINDOWS}
    {$DEFINE MSWINDOWS}
  {$ENDIF}
{$ENDIF}

Const
// Library name
{$IFDEF MSWINDOWS}
  snaplib = 'snap7.dll';
{$ELSE}
  snaplib = 'libsnap7.so';  // valid for all Unix platforms
{$ENDIF}

// Native integrals
{$IFNDEF FPC}
  {$IF CompilerVersion<21} // below Delphi 7
    Type
      NativeUint = LongWord;
      NativeInt  = LongInt;
  {$IFEND}
{$ENDIF}

Type
  S7Object = NativeUint; // Platform independent Object reference
                         // DON'T CONFUSE IT WITH AN OLE OBJECT, IT'S SIMPLY
                         // AN INTEGER (32 OR 64 BIT) VALUE USED AS HANDLE.

//******************************************************************************
//                                   COMMON
//******************************************************************************
Const
  errLibInvalidParam     = -1;
  errLibInvalidObject    = -2;

// CPU status
  S7CpuStatusUnknown     = $00;
  S7CpuStatusRun         = $08;
  S7CpuStatusStop        = $04;
// ISO Errors
  errIsoConnect          = $00010000; // Connection error
  errIsoDisconnect       = $00020000; // Disconnect error
  errIsoInvalidPDU       = $00030000; // Bad format
  errIsoInvalidDataSize  = $00040000; // Bad Datasize passed to send/recv buffer is invalid
  errIsoNullPointer    	 = $00050000; // Null passed as pointer
  errIsoShortPacket    	 = $00060000; // A short packet received
  errIsoTooManyFragments = $00070000; // Too many packets without EoT flag
  errIsoPduOverflow    	 = $00080000; // The sum of fragments data exceded maximum packet size
  errIsoSendPacket       = $00090000; // An error occurred during send
  errIsoRecvPacket    	 = $000A0000; // An error occurred during recv
  errIsoInvalidParams    = $000B0000; // Invalid TSAP params
  errIsoResvd_1          = $000C0000; // Unassigned
  errIsoResvd_2          = $000D0000; // Unassigned
  errIsoResvd_3          = $000E0000; // Unassigned
  errIsoResvd_4          = $000F0000; // Unassigned
// Jobs
  JobComplete            = 0;
  JobPending             = 1;

Type
  TS7Tag = packed record
    Area      : integer;
    DBNumber  : integer;
    Start     : integer;
    Elements  : integer;
    WordLen   : integer;
  end;
  PS7Tag = ^TS7Tag;
//------------------------------------------------------------------------------
//                                  PARAMS LIST
//------------------------------------------------------------------------------
Const
  p_u16_LocalPort        = 1;
  p_u16_RemotePort       = 2;
  p_i32_PingTimeout      = 3;
  p_i32_SendTimeout      = 4;
  p_i32_RecvTimeout      = 5;
  p_i32_WorkInterval     = 6;
  p_u16_SrcRef           = 7;
  p_u16_DstRef           = 8;
  p_u16_SrcTSap          = 9;
  p_i32_PDURequest       = 10;
  p_i32_MaxClients       = 11;
  p_i32_BSendTimeout     = 12;
  p_i32_BRecvTimeout     = 13;
  p_u32_RecoveryTime     = 14;
  p_u32_KeepAliveTime    = 15;

//******************************************************************************
//                                   CLIENT
//******************************************************************************
// Error codes
  errNegotiatingPDU            = $00100000;
  errCliInvalidParams          = $00200000;
  errCliJobPending             = $00300000;
  errCliTooManyItems           = $00400000;
  errCliInvalidWordLen         = $00500000;
  errCliPartialDataWritten     = $00600000;
  errCliSizeOverPDU            = $00700000;
  errCliInvalidPlcAnswer       = $00800000;
  errCliAddressOutOfRange      = $00900000;
  errCliInvalidTransportSize   = $00A00000;
  errCliWriteDataSizeMismatch  = $00B00000;
  errCliItemNotAvailable       = $00C00000;
  errCliInvalidValue           = $00D00000;
  errCliCannotStartPLC         = $00E00000;
  errCliAlreadyRun             = $00F00000;
  errCliCannotStopPLC          = $01000000;
  errCliCannotCopyRamToRom     = $01100000;
  errCliCannotCompress         = $01200000;
  errCliAlreadyStop            = $01300000;
  errCliFunNotAvailable        = $01400000;
  errCliUploadSequenceFailed   = $01500000;
  errCliInvalidDataSizeRecvd   = $01600000;
  errCliInvalidBlockType       = $01700000;
  errCliInvalidBlockNumber     = $01800000;
  errCliInvalidBlockSize       = $01900000;
  errCliDownloadSequenceFailed = $01A00000;
  errCliInsertRefused          = $01B00000;
  errCliDeleteRefused          = $01C00000;
  errCliNeedPassword           = $01D00000;
  errCliInvalidPassword        = $01E00000;
  errCliNoPasswordToSetOrClear = $01F00000;
  errCliJobTimeout             = $02000000;
  errCliPartialDataRead        = $02100000;
  errCliBufferTooSmall         = $02200000;
  errCliFunctionRefused        = $02300000;
  errCliDestroying             = $02400000;
  errCliInvalidParamNumber     = $02500000;
  errCliCannotChangeParam      = $02600000;

  MaxVars     = 20; // Max vars that can be transferred with MultiRead/MultiWrite

// Client Connection Type
  CONNTYPE_PG                 = $01;  // Connect to the PLC as a PG
  CONNTYPE_OP                 = $02;  // Connect to the PLC as an OP
  CONNTYPE_BASIC              = $03;  // Basic connection

// Area ID
  S7AreaPE   =	$81;
  S7AreaPA   =	$82;
  S7AreaMK   =	$83;
  S7AreaDB   =	$84;
  S7AreaCT   =	$1C;
  S7AreaTM   =	$1D;
// Word Length
  S7WLBit     = $01;
  S7WLByte    = $02;
  S7WLChar    = $03;
  S7WLWord    = $04;
  S7WLInt     = $05;
  S7WLDWord   = $06;
  S7WLDInt    = $07;
  S7WLReal    = $08;
  S7WLDate    = $09;
  S7WLTOD     = $0A;
  S7WLTime    = $0B;
  S7WLS5Time  = $0C;
  S7WLDT      = $0F;
  S7WLCounter = $1C;
  S7WLTimer   = $1D;
// Block type
  Block_OB    = $38;
  Block_DB    = $41;
  Block_SDB   = $42;
  Block_FC    = $43;
  Block_SFC   = $44;
  Block_FB    = $45;
  Block_SFB   = $46;
// Sub Block Type
  SubBlk_OB   = $08;
  SubBlk_DB   = $0A;
  SubBlk_SDB  = $0B;
  SubBlk_FC   = $0C;
  SubBlk_SFC  = $0D;
  SubBlk_FB   = $0E;
  SubBlk_SFB  = $0F;
// Block languages
  BlockLangAWL   = $01;
  BlockLangKOP   = $02;
  BlockLangFUP   = $03;
  BlockLangSCL   = $04;
  BlockLangDB    = $05;
  BlockLangGRAPH = $06;

Type
  TS7Buffer = packed array[0..$FFFF] of byte;
  PS7Buffer = ^TS7Buffer;

  TS7DataItem = packed record
    Area     : integer;
    WordLen  : integer;
    Result   : integer;
    DBNumber : integer;
    Start    : integer;
    Amount   : integer;
    pdata    : pbyte;
  end;
  PS7DataItem = ^TS7DataItem;

  TS7DataItems = packed array[0..MaxVars-1] of TS7DataItem;
  PS7DataItems = ^TS7DataItems;

  TS7BlocksList = packed record
    OBCount  : integer;
    FBCount  : integer;
    FCCount  : integer;
    SFBCount : integer;
    SFCCount : integer;
    DBCount  : integer;
    SDBCount : integer;
  end;

  PS7BlocksList = ^TS7BlocksList;

  TS7BlockInfo = packed record
    BlkType    : integer;
    BlkNumber  : integer;
    BlkLang    : integer;
    BlkFlags   : integer;
    MC7Size    : integer;  // The real size in bytes
    LoadSize   : integer;
    LocalData  : integer;
    SBBLength  : integer;
    CheckSum   : integer;
    Version    : integer;
    // Chars info
    CodeDate   : packed array[0..10] of AnsiChar;
    IntfDate   : packed array[0..10] of AnsiChar;
    Author     : packed array[0..8] of AnsiChar;
    Family     : packed array[0..8] of AnsiChar;
    Header     : packed array[0..8] of AnsiChar;
  end;
  PS7BlockInfo = ^TS7BlockInfo;

  TS7BlocksOfType = packed array[0..$1FFF] of word;
  PS7BlocksOfType = ^TS7BlocksOfType;

  TS7OrderCode = packed record
    Code    : packed array[0..20] of AnsiChar;
    V1      : byte;
    V2      : byte;
    V3      : byte;
  end;
  PS7OrderCode = ^TS7OrderCode;

  TS7CpuInfo = packed record
    ModuleTypeName : packed array[0..32] of AnsiChar;
    SerialNumber   : packed array[0..24] of AnsiChar;
    ASName         : packed array[0..24] of AnsiChar;
    Copyright      : packed array[0..26] of AnsiChar;
    ModuleName     : packed array[0..24] of AnsiChar;
  end;
  PS7CpuInfo = ^TS7CpuInfo;

  TS7CpInfo = packed record
    MaxPduLengt    : integer;
    MaxConnections : integer;
    MaxMpiRate     : integer;
    MaxBusRate     : integer;
  end;
  PS7CpInfo = ^TS7CpInfo;

  // See §33.1 of "System Software for S7-300/400 System and Standard Functions"
  // and see SFC51 description too
  SZL_HEADER = packed record
    LENTHDR : word;
    N_DR    : word;
  end;
  PSZL_HEADER = ^SZL_HEADER;

  // SZL Record
  TS7SZL = packed record
    Header : SZL_HEADER;
    Data   : packed array[0..$3FFF-4] of byte;
  end;
  PS7SZL = ^TS7SZL;

  // List of available SZL IDs : same as SZL but List items are big-endian adjusted
  TS7SZLList = packed record
    Header : SZL_HEADER;
    List   : packed array[0..$1FFF-2] of word;
  end;
  PS7SZLList = ^TS7SZLList;

  // See §33.19 of "System Software for S7-300/400 System and Standard Functions"
  TS7Protection = packed record
    sch_schal : word;
    sch_par   : word;
    sch_rel   : word;
    bart_sch  : word;
    anl_sch   : word;
  end;
  PS7Protection = ^TS7Protection;

  // C++ time record, functions to convert it from/to TDateTime are provided ;-)
  TCPP_tm = packed record
    tm_sec    : integer;
    tm_min    : integer;
    tm_hour   : integer;
    tm_mday   : integer;
    tm_mon    : integer;
    tm_year   : integer;
    tm_wday   : integer;
    tm_yday   : integer;
    tm_isdst  : integer;
  end;
  PCPP_tm = ^TCPP_tm;

// Client completion callback
TS7CliCompletion = procedure(usrPtr : Pointer; opCode, opResult : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

// Control functions
function Cli_Create : S7Object;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
procedure Cli_Destroy(var Client : S7Object);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ConnectTo(Client : S7Object; Address : PAnsiChar; Rack, Slot : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetConnectionParams(Client : S7Object; Address : PAnsiChar; LocalTSAP, RemoteTSAP : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetConnectionType(Client : S7Object; ConnectionType : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_Connect(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_Disconnect(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetParam(Client : S7Object; ParamNumber : integer; pValue : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetParam(Client : S7Object; ParamNumber : integer; pValue : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetAsCallback(Client : S7Object; pCompletion, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Data I/O functions
function Cli_ReadArea(Client : S7Object; Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_WriteArea(Client : S7Object; Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ReadMultiVars(Client : S7Object; Items : PS7DataItems; ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_WriteMultiVars(Client : S7Object; Items : PS7DataItems; ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Data I/O Lean functions
function Cli_DBRead(Client : S7Object; DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_DBWrite(Client : S7Object; DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_MBRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_MBWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_EBRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_EBWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ABRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ABWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_TMRead(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_TMWrite(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_CTRead(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_CTWrite(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Directory functions
function Cli_ListBlocks(Client : S7Object; pUsrData : PS7BlocksList) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetAgBlockInfo(Client : S7Object; BlockType, BlockNum : integer; pUsrData : PS7BlockInfo) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetPgBlockInfo(Client : S7Object; pBlock : pointer; pUsrData : PS7BlockInfo; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ListBlocksOfType(Client : S7Object; BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Blocks functions
function Cli_Upload(Client : S7Object; BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_FullUpload(Client : S7Object; BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_Download(Client : S7Object; BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_Delete(Client : S7Object; BlockType, BlockNum : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_DBGet(Client : S7Object; DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_DBFill(Client : S7Object; DBNumber : integer; FillChar : byte) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Date/Time functions
function Cli_GetPlcDateTime(Client : S7Object; var DateTime : TCPP_tm) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetPlcDateTime(Client : S7Object; var DateTime : TCPP_tm) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetPlcSystemDateTime(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// System Info functions
function Cli_GetOrderCode(Client : S7Object; pUsrData : PS7OrderCode) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetCpuInfo(Client : S7Object; pUsrData : PS7CpuInfo) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetCPInfo(Client : S7Object; pUsrData : PS7CpInfo) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ReadSZL(Client : S7Object; ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ReadSZLList(Client : S7Object; pUsrData : PS7SZLList; var ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Control functions
function Cli_PlcHotStart(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_PlcColdStart(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_PlcStop(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_CopyRamToRom(Client : S7Object; Timeout : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_Compress(Client : S7Object; Timeout : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetPlcStatus(Client : S7Object; var Status : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Security functions
function Cli_GetProtection(Client : S7Object; pUsrData : PS7Protection) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_SetSessionPassword(Client : S7Object; Password : PAnsiChar) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ClearSessionPassword(Client : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Async functions
function Cli_AsReadArea(Client : S7Object; Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsWriteArea(Client : S7Object; Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsDBRead(Client : S7Object; DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsDBWrite(Client : S7Object; DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsMBRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsMBWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsEBRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsEBWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsABRead(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsABWrite(Client : S7Object; Start, Size : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsTMRead(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsTMWrite(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsCTRead(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsCTWrite(Client : S7Object; Start, Amount : integer; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsListBlocksOfType(Client : S7Object; BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsReadSZL(Client : S7Object; ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsReadSZLList(Client : S7Object; pUsrData : PS7SZLList; var ItemsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsUpload(Client : S7Object; BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsFullUpload(Client : S7Object; BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsDownload(Client : S7Object; BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsCopyRamToRom(Client : S7Object; Timeout : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsCompress(Client : S7Object; Timeout : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsDBGet(Client : S7Object; DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_AsDBFill(Client : S7Object; DBNumber : integer; FillChar : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_CheckAsCompletion(Client : S7Object; var opResult : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_WaitAsCompletion(Client : S7Object; Timeout : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Low level
function Cli_IsoExchangeBuffer(Client : S7Object; pUsrData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Utility/Misc functions
function Cli_GetExecTime(Client : S7Object; var Time : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetLastError(Client : S7Object; var LastError : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetPduLength(Client : S7Object; Var Requested, Negotiated : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_ErrorText(Error : integer; Text : PAnsiChar; TextLen : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Cli_GetConnected(Client : S7Object; var IsConnected : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

//******************************************************************************
//                                   SERVER
//******************************************************************************
Const
  mkEvent = 0;
  mkLog   = 1;

  OperationRead  = 0;
  OperationWrite = 1;

// Server Area ID  (use with Register/unregister - Lock/unlock Area)
  srvAreaPE = 0;
  srvAreaPA = 1;
  srvAreaMK = 2;
  srvAreaCT = 3;
  srvAreaTM = 4;
  srvAreaDB = 5;

// Errors
  errSrvCannotStart        = $00100000; // Server cannot start
  errSrvDBNullPointer      = $00200000; // Passed null as PData
  errSrvAreaAlreadyExists  = $00300000; // Area Re-registration
  errSrvUnknownArea        = $00400000; // Unknown area
  errSrvInvalidParams      = $00500000; // Invalid param(s) supplied
  errSrvTooManyDB          = $00600000; // Cannot register DB
  errSrvInvalidParamNumber = $00700000; // Invalid param (srv_get/set_param)
  errSrvCannotChangeParam  = $00800000; // Cannot change because running

// TCP Server Event codes
  evcServerStarted        = $00000001;
  evcServerStopped        = $00000002;
  evcListenerCannotStart  = $00000004;
  evcClientAdded          = $00000008;
  evcClientRejected       = $00000010;
  evcClientNoRoom         = $00000020;
  evcClientException      = $00000040;
  evcClientDisconnected   = $00000080;
  evcClientTerminated     = $00000100;
  evcClientsDropped       = $00000200;
  evcReserved_00000400    = $00000400; // currently unused
  evcReserved_00000800    = $00000800; // currently unused
  evcReserved_00001000    = $00001000; // currently unused
  evcReserved_00002000    = $00002000; // currently unused
  evcReserved_00004000    = $00004000; // currently unused
  evcReserved_00008000    = $00008000; // currently unused
// S7 Server Event Code
  evcPDUincoming          = $00010000;
  evcDataRead             = $00020000;
  evcDataWrite            = $00040000;
  evcNegotiatePDU         = $00080000;
  evcReadSZL              = $00100000;
  evcClock                = $00200000;
  evcUpload               = $00400000;
  evcDownload             = $00800000;
  evcDirectory            = $01000000;
  evcSecurity             = $02000000;
  evcControl              = $04000000;
  evcReserved_08000000    = $08000000; // currently unused
  evcReserved_10000000    = $10000000; // currently unused
  evcReserved_20000000    = $20000000; // currently unused
  evcReserved_40000000    = $40000000; // currently unused
  evcReserved_80000000    = $80000000; // currently unused
// Masks to enable/disable all
  evcAll                  = $FFFFFFFF;
  evcNone                 = $00000000;
// Event SubCodes
  evsUnknown              = $0000;
  evsStartUpload          = $0001;
  evsStartDownload        = $0001;
  evsGetBlockList         = $0001;
  evsStartListBoT         = $0002;
  evsListBoT              = $0003;
  evsGetBlockInfo         = $0004;
  evsGetClock             = $0001;
  evsSetClock             = $0002;
  evsSetPassword          = $0001;
  evsClrPassword          = $0002;
// Event Params : functions group
  grProgrammer            = $0041;
  grCyclicData            = $0042;
  grBlocksInfo            = $0043;
  grSZL                   = $0044;
  grPassword              = $0045;
  grBSend                 = $0046;
  grClock                 = $0047;
  grSecurity              = $0045;
// Event Params : control codes
  CodeControlUnknown      = $0000;
  CodeControlColdStart    = $0001;
  CodeControlWarmStart    = $0002;
  CodeControlStop         = $0003;
  CodeControlCompress     = $0004;
  CodeControlCpyRamRom    = $0005;
  CodeControlInsDel       = $0006;
// Event Result
  evrNoError              = $0000;
  evrFragmentRejected     = $0001;
  evrMalformedPDU         = $0002;
  evrSparseBytes          = $0003;
  evrCannotHandlePDU      = $0004;
  evrNotImplemented       = $0005;
  evrErrException         = $0006;
  evrErrAreaNotFound      = $0007;
  evrErrOutOfRange        = $0008;
  evrErrOverPDU           = $0009;
  evrErrTransportSize     = $000A;
  evrInvalidGroupUData    = $000B;
  evrInvalidSZL           = $000C;
  evrDataSizeMismatch     = $000D;
  evrCannotUpload         = $000E;
  evrCannotDownload       = $000F;
  evrUploadInvalidID      = $0010;
  evrResNotFound          = $0011;

type
// Unix Timestamp, the best compact way to store date/time if we don't need
// millisecond resolution.
  time_t = NativeInt;

Type

  TSrvEvent = packed record
    EvtTime    : time_t;    // Timestamp
    EvtSender  : integer;   // Sender
    EvtCode    : longword;  // Event code
    EvtRetCode : word;      // Event result
    EvtParam1  : word;      // Param 1
    EvtParam2  : word;      // Param 2
    EvtParam3  : word;      // Param 3
    EvtParam4  : word;      // Param 4
  end;
  PSrvEvent = ^TSrvEvent;

TSrvCallBack = procedure(usrPtr : pointer; PEvent : PSrvEvent; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
TSrvRWAreaCallBack = function(usrPtr : pointer; Sender, Operation : integer; PTag : PS7Tag; pUsrData : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

Const
  // Server status
  SrvStopped = 0;
  SrvRunning = 1;
  SrvError   = 2;

function Srv_Create : S7Object;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
procedure Srv_Destroy(var Server : S7Object);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_GetParam(Server : S7Object; ParamNumber : integer; pValue : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetParam(Server : S7Object; ParamNumber : integer; pValue : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_Start(Server : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_StartTo(Server : S7Object; Address : PAnsiChar) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_Stop(Server : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_RegisterArea(Server : S7Object; AreaCode : integer; Index : word; pUsrData : pointer; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_UnregisterArea(Server : S7Object; AreaCode : integer; Index : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_LockArea(Server : S7Object; AreaCode : integer; Index : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_UnlockArea(Server : S7Object; AreaCode : integer; Index : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_GetStatus(Server : S7Object; Var ServerStatus, CpuStatus, ClientsCount : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetCpuStatus(Server : S7Object; CpuStatus : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_PickEvent(Server : S7Object; var Event : TSrvEvent; var EvtReady : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_ClearEvents(Server : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_GetMask(Server : S7Object; MaskKind : integer; Var Mask : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetMask(Server : S7Object; MaskKind : integer; Mask : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetEventsCallback(Server : S7Object; CallBack, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetReadEventsCallback(Server : S7Object; CallBack, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_SetRWAreaCallback(Server : S7Object; CallBack, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_ErrorText(Error : integer; Text : PAnsiChar; TextLen : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Srv_EventText(var Event : TSrvEvent; Text : PAnsiChar; TextLen : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

//******************************************************************************
//                                   PARTNER
//******************************************************************************
Const
// Partner status
  par_stopped         = 0;   // stopped
  par_connecting      = 1;   // running and active, connecting
  par_waiting         = 2;   // running and waiting for a connection
  par_linked          = 3;   // running and connected : linked
  par_sending         = 4;   // sending data
  par_receiving       = 5;   // receiving data
  par_binderror       = 6;   // error starting passive server

// Errors
  errParAddressInUse       = $00200000;
  errParNoRoom             = $00300000;
  errServerNoRoom          = $00400000;
  errParInvalidParams      = $00500000;
  errParNotLinked          = $00600000;
  errParBusy               = $00700000;
  errParFrameTimeout       = $00800000;
  errParInvalidPDU         = $00900000;
  errParSendTimeout        = $00A00000;
  errParRecvTimeout        = $00B00000;
  errParSendRefused        = $00C00000;
  errParNegotiatingPDU     = $00D00000;
  errParSendingBlock       = $00E00000;
  errParRecvingBlock       = $00F00000;
  errBindError             = $01000000;
  errParDestroying         = $01100000;
  errParInvalidParamNumber = $01200000; 
  errParCannotChangeParam  = $01300000;
  errParBufferTooSmall     = $01400000;

Type

TParBRecvEvent = procedure(usrPtr : pointer; opResult : integer; R_ID : longword; pdata : pointer; size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
TParBSendCompletion = procedure(usrPtr : pointer; opResult : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

// Control
function Par_Create(Active : longbool) : S7Object;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
procedure Par_Destroy(var Partner : S7Object);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_GetParam(Partner : S7Object; ParamNumber : integer; pValue : Pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_SetParam(Partner : S7Object; ParamNumber : integer; pValue : Pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_Start(Partner : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_StartTo(Partner       : S7Object;
                     LocalAddress  : PAnsiChar;
                     RemoteAddress : PAnsiChar;
                     LocalTSAP     : word;
                     RemoteTSAP    : word) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_Stop(Partner : S7Object) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Data I/O functions : BSend
function Par_BSend(Partner : S7Object; R_ID : longword; pUsrData : pointer; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_AsBSend(Partner : S7Object;R_ID : longword; pUsrData : pointer; Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_CheckAsBSendCompletion(Partner : S7Object; var opResult : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_WaitAsBSendCompletion(Partner : S7Object; Timeout : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_SetSendCallback(Partner : S7Object; pCompletion, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Data I/O functions : BRecv
function Par_BRecv(Partner : S7Object; var R_ID : longword; pData : pointer; var Size : integer; Timeout : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_CheckAsBRecvCompletion(Partner : S7Object; var opResult : integer; var R_ID : longword; pData : pointer; var Size : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_SetRecvCallback(Partner : S7Object; pCompletion, usrPtr : pointer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
// Utility functions
function Par_GetTimes(Partner : S7Object; var SendTime : longword; var RecvTime : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_GetLastError(Partner : S7Object; var LastError : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_GetStatus(Partner : S7Object; Var Status : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_GetStats(Partner : S7Object; Var BytesSent, BytesRecv, SendErrors, RecvErrors : longword) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
function Par_ErrorText(Error : integer; Text : PAnsiChar; TextLen : integer) : integer;
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

//******************************************************************************
//                                 S7CLIENT CLASS
//******************************************************************************
Type

  { TS7Client }

  TS7Client = class
  private
    HC : S7Object;
  public
    constructor Create;
    destructor Destroy; override;
    // Control functions
    function ConnectTo(Address : AnsiString; Rack, Slot : integer) : integer;
    function SetConnectionParams(Address : AnsiString; LocalTSAP, RemoteTSAP : word) : integer;
    function SetConnectionType(ConnectionType : word) : integer;
    function Connect : integer;
    function Disconnect : integer;
    function GetParam(ParamNumber : integer; pValue : pointer) : integer;
    function SetParam(ParamNumber : integer; pValue : pointer) : integer;
    function SetAsCallback(pCompletion, usrPtr : pointer) : integer;
    // Data I/O Main functions
    function ReadArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
    function WriteArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
    function ReadMultiVars(Items : PS7DataItems; ItemsCount : integer) : integer;
    function WriteMultiVars(Items : PS7DataItems; ItemsCount : integer) : integer;
    // Data I/O Lean functions
    function DBRead(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
    function DBWrite(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
    function MBRead(Start, Size : integer; pUsrData : pointer) : integer;
    function MBWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function EBRead(Start, Size : integer; pUsrData : pointer) : integer;
    function EBWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function ABRead(Start, Size : integer; pUsrData : pointer) : integer;
    function ABWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function TMRead(Start, Amount : integer; pUsrData : pointer) : integer;
    function TMWrite(Start, Amount : integer; pUsrData : pointer) : integer;
    function CTRead(Start, Amount : integer; pUsrData : pointer) : integer;
    function CTWrite(Start, Amount : integer; pUsrData : pointer) : integer;
    // Directory functions
    function ListBlocks(pUsrData : PS7BlocksList) : integer;
    function GetAgBlockInfo(BlockType, BlockNum : integer; pUsrData : PS7BlockInfo) : integer;
    function GetPgBlockInfo(pBlock : pointer; pUsrData : PS7BlockInfo; Size : integer) : integer;
    function ListBlocksOfType(BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
    // Blocks functions
    function Upload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
    function FullUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
    function Download(BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
    function Delete(BlockType, BlockNum : integer) : integer;
    function DBGet(DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
    function DBFill(DBNumber : integer; FillChar : integer) : integer;
    // Date/Time functions
    function GetPlcDateTime(Var DateTime : TDateTime) : integer;
    function SetPlcDateTime(Var DateTime : TDateTime) : integer;
    function SetPlcSystemDateTime : integer;
    // System Info functions
    function GetOrderCode(pUsrData : PS7OrderCode) : integer;
    function GetCpuInfo(pUsrData : PS7CpuInfo) : integer;
    function GetCPInfo(pUsrData : PS7CpInfo) : integer;
    function ReadSZL(ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
    function ReadSZLList(pUsrData : PS7SZLList; var ItemsCount : integer) : integer;
    // Control functions
    function PlcHotStart : integer;
    function PlcColdStart : integer;
    function PlcStop : integer;
    function CopyRamToRom(Timeout : integer) : integer;
    function Compress(Timeout : integer) : integer;
    function GetPlcStatus(var Status : integer) : integer;
    // Security functions
    function GetProtection(pUsrData : PS7Protection) : integer;
    function SetSessionPassword(Password : AnsiString) : integer;
    function ClearSessionPassword : integer;
    // Async functions
    function AsReadArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
    function AsWriteArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
    function AsDBRead(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
    function AsDBWrite(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
    function AsMBRead(Start, Size : integer; pUsrData : pointer) : integer;
    function AsMBWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function AsEBRead(Start, Size : integer; pUsrData : pointer) : integer;
    function AsEBWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function AsABRead(Start, Size : integer; pUsrData : pointer) : integer;
    function AsABWrite(Start, Size : integer; pUsrData : pointer) : integer;
    function AsTMRead(Start, Amount : integer; pUsrData : pointer) : integer;
    function AsTMWrite(Start, Amount : integer; pUsrData : pointer) : integer;
    function AsCTRead(Start, Amount : integer; pUsrData : pointer) : integer;
    function AsCTWrite(Start, Amount : integer; pUsrData : pointer) : integer;
    function AsListBlocksOfType(BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
    function AsReadSZL(ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
    function AsReadSZLList(pUsrData : PS7SZLList; var ItemsCount : integer) : integer;
    function AsUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
    function AsFullUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
    function AsDownload(BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
    function AsCopyRamToRom(Timeout : integer) : integer;
    function AsCompress(Timeout : integer) : integer;
    function AsDBGet(DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
    function AsDBFill(DBNumber : integer; FillChar : integer) : integer;
    function CheckAsCompletion(var opResult : integer) : boolean;
    function WaitAsCompletion(Timeout : longword) : integer;
    // Low level
    function IsoExchangeBuffer(pUsrData : pointer; var Size : integer) : integer;
    // Utility/Misc functions
    function Time : longword;
    function LastError : integer;
    function PduLength : integer;
    function PduRequested : integer;
    function PlcStatus : integer;
    function Connected : boolean;
  end;
//******************************************************************************
//                                 SNAP7SERVER CLASS
//******************************************************************************
  TS7Server = class
  private
    HS : S7Object;
    function GetEventsMask: longword;
    function GetLogMask: longword;
    procedure SetEventsMask(const Value: longword);
    procedure SetLogMask(const Value: longword);
    function GetStatus(Var ServerStatus, CpuStatus, ClientsCount : integer) : integer;
    function GetClientsCount: integer;
    function GetCpuStatus: integer;
    function GetServerStatus: integer;
    procedure SetCpuStatus(const Value: integer);
  public
    constructor Create;
    destructor Destroy; override;
    // Control
    function Start : integer;
    function StartTo(Address : String) : integer;
    function Stop : integer;
    function GetParam(ParamNumber : integer; pValue : pointer) : integer;
    function SetParam(ParamNumber : integer; pValue : pointer) : integer;
    // Resources
    function RegisterArea(AreaCode : integer; Index : integer; pUsrData : pointer; Size : integer) : integer;
    function UnregisterArea(AreaCode : integer; Index : integer) : integer;
    function LockArea(AreaCode : integer; Index : integer) : integer;
    function UnlockArea(AreaCode : integer; Index : integer) : integer;
    // Events
    function PickEvent(var Event : TSrvEvent) : boolean;
    function ClearEvents : integer;
    function SetEventsCallback(CallBack, usrPtr : pointer) : integer;
    function SetReadEventsCallback(CallBack, usrPtr : pointer) : integer;
    function SetRWAreaCallback(CallBack, usrPtr : pointer) : integer;
    // Properties
    property EventsMask : longword read GetEventsMask write SetEventsMask;
    property LogMask : longword read GetLogMask write SetLogMask;
    property ServerStatus : integer read GetServerStatus;
    property CpuStatus : integer read GetCpuStatus write SetCpuStatus;
    property ClientsCount : integer read GetClientsCount;
  end;
//******************************************************************************
//                                SNAP7PARTNER CLASS
//******************************************************************************
  TS7Partner = class
  private
    HP : S7Object;
    FBytesSent : longword;
    FBytesRecv : longword;
    FSendErrors : longword;
    FRecvErrors : longword;
    FActive: boolean;
    procedure GetStatistics;
    function GetLastError : integer;
    function GetBytesRecv: integer;
    function GetBytesSent: integer;
    function GetRecvErrors: integer;
    function GetRecvTime: longword;
    function GetSendErrors: integer;
    function GetSendTime: longword;
    function GetStatus: integer;
    function GetLinked: boolean;
  public
    constructor Create(AsActive : boolean);
    destructor Destroy; override;
    function GetParam(ParamNumber : integer; pValue : Pointer) : integer;
    function SetParam(ParamNumber : integer; pValue : Pointer) : integer;
    function Start : integer;
    function StartTo(LocalAddress, RemoteAddress : AnsiString;
      LocalTSAP, RemoteTSAP : word ) : integer;
    function Stop : integer;
    // Block send
    function BSend(R_ID : longword; pUsrData : pointer; size : integer) : integer;
    function AsBSend(R_ID : longword; pUsrData : pointer; size : integer) : integer;
    function CheckAsBSendCompletion(var opResult : integer) : boolean;
    function WaitAsBSendCompletion(Timeout : longword) : integer;
    function SetSendCallback(pSendCompletion, usrPtr : pointer) : integer;
    // Block recv
    function BRecv(Timeout : longword; var R_ID : longword;
      pUsrData : pointer; var Size : integer) : integer;
    function CheckAsBRecvCompletion(var opResult : integer; var R_ID : longword;
      pUsrData : pointer; var Size : integer) : boolean;
    function SetRecvCallback(pRecvCompletion, usrPtr : pointer) : integer;
    // Read only properties
    property Active : boolean read FActive;
    property Status : integer read GetStatus;
    property Linked : boolean read GetLinked;
    property BytesSent : integer read GetBytesSent;
    property BytesRecv : integer read GetBytesRecv;
    property SendErrors : integer read GetSendErrors;
    property RecvErrors : integer read GetRecvErrors;
    property LastError : integer read GetLastError;
    property SendTime : longword read GetSendTime;
    property RecvTime : longword read GetRecvTime;
  end;

//******************************************************************************
//                                S7 CONVERSION CLASS
//******************************************************************************
  TS7Type = (S7Int, S7DInt, S7Word, S7DWord, S7Real, S7DT_To_DateTime, DateTime_To_S7DT);

  TS7Helper = class
  private
    function GetInt(pval: pointer): smallint;
    procedure SetInt(pval: pointer; const Value: smallint);
    function GetWord(pval: pointer): word;
    procedure SetWord(pval: pointer; const Value: word);
    function GetDInt(pval: pointer): longint;
    procedure SetDInt(pval: pointer; const Value: longint);
    function GetDWord(pval: pointer): longword;
    procedure SetDWord(pval: pointer; const Value: longword);
    function GetDateTime(pval: pointer): TDateTime;
    procedure SetDateTime(pval: pointer; const Value: TDateTime);
    function GetReal(pval: pointer): single;
    procedure SetReal(pval: pointer; const Value: single);
    function GetBit(pval: pointer; BitIndex: integer): boolean;
    procedure SetBit(pval: pointer; BitIndex: integer; const Value: boolean);
  public
    procedure Reverse(pval : pointer; const S7Type : TS7Type);
    property ValBit[pval : pointer; BitIndex : integer] : boolean read GetBit write SetBit;
    property ValInt[pval : pointer] : smallint read GetInt write SetInt;
    property ValDInt[pval : pointer] : longint read GetDInt write SetDInt;
    property ValWord[pval : pointer] : word read GetWord write SetWord;
    property ValDWord[pval : pointer] : longword read GetDWord write SetDWord;
    property ValReal[pval : pointer] : single read GetReal write SetReal;
    property ValDateTime[pval : pointer] : TDateTime read GetDateTime write SetDateTime;
  end;

// Error text
function CliErrorText(Error : integer) : string;
function SrvErrorText(Error : integer) : string;
function ParErrorText(Error : integer) : string;
function SrvEventText(var Event : TSrvEvent) : string;

Var
  S7 : TS7Helper;

implementation
Uses
  DateUtils,
  SysUtils;

Const
  TextLen = 1024;
//------------------------------------------------------------------------------
// C++ Datatime conversion helpers
//------------------------------------------------------------------------------
function DateTimeToCPP_tm(T : TDateTime) : TCPP_tm;
Var
  YY,MM,DD,HH,NN,SS,DOW,MS : word;
begin
  DecodeDateFully(T,YY,MM,DD,DOW);
  DecodeTime(T,HH,NN,SS,MS);
  with Result do
  begin
    tm_year :=YY-1900;
    tm_mon  :=MM-1;
    tm_mday :=DD;
    tm_hour :=HH;
    tm_min  :=NN;
    tm_sec  :=SS;
    tm_wday :=DOW-1;
    tm_isdst:=-1; // Info not available
  end;
end;
//------------------------------------------------------------------------------
function CPP_tmToDateTime(var T : TCPP_tm) : TDateTime;
Var
  Date, Time : TDateTime;
begin
  with T do
  begin
    if TryEncodeDate(tm_year+1900,tm_mon+1,tm_mday,Date) then
    begin
       if TryEncodeTime(tm_hour,tm_min,tm_sec,0,Time) then
          Result:=Date+Time
       else
          Result:=0;
    end
    else
      Result:=0;
  end;
end;
//******************************************************************************
//                               CLIENT FORWARDS
//******************************************************************************
function Cli_Create;                  external snaplib name 'Cli_Create';
procedure Cli_Destroy;                external snaplib name 'Cli_Destroy';
function Cli_ConnectTo;               external snaplib name 'Cli_ConnectTo';
function Cli_SetConnectionParams;     external snaplib name 'Cli_SetConnectionParams';
function Cli_SetConnectionType;       external snaplib name 'Cli_SetConnectionType';
function Cli_Disconnect;              external snaplib name 'Cli_Disconnect';
function Cli_Connect;                 external snaplib name 'Cli_Connect';
function Cli_GetParam;                external snaplib name 'Cli_GetParam';
function Cli_SetParam;                external snaplib name 'Cli_SetParam';
function Cli_SetAsCallback;           external snaplib name 'Cli_SetAsCallback';
function Cli_ReadArea;                external snaplib name 'Cli_ReadArea';
function Cli_WriteArea;               external snaplib name 'Cli_WriteArea';
function Cli_ReadMultiVars;           external snaplib name 'Cli_ReadMultiVars';
function Cli_WriteMultiVars;          external snaplib name 'Cli_WriteMultiVars';
function Cli_DBRead;                  external snaplib name 'Cli_DBRead';
function Cli_DBWrite;                 external snaplib name 'Cli_DBWrite';
function Cli_MBRead;                  external snaplib name 'Cli_MBRead';
function Cli_MBWrite;                 external snaplib name 'Cli_MBWrite';
function Cli_EBRead;                  external snaplib name 'Cli_EBRead';
function Cli_EBWrite;                 external snaplib name 'Cli_EBWrite';
function Cli_ABRead;                  external snaplib name 'Cli_ABRead';
function Cli_ABWrite;                 external snaplib name 'Cli_ABWrite';
function Cli_TMRead;                  external snaplib name 'Cli_TMRead';
function Cli_TMWrite;                 external snaplib name 'Cli_TMWrite';
function Cli_CTRead;                  external snaplib name 'Cli_CTRead';
function Cli_CTWrite;                 external snaplib name 'Cli_CTWrite';
function Cli_ListBlocks;              external snaplib name 'Cli_ListBlocks';
function Cli_GetAgBlockInfo;          external snaplib name 'Cli_GetAgBlockInfo';
function Cli_GetPgBlockInfo;          external snaplib name 'Cli_GetPgBlockInfo';
function Cli_ListBlocksOfType;        external snaplib name 'Cli_ListBlocksOfType';
function Cli_Upload;                  external snaplib name 'Cli_Upload';
function Cli_FullUpload;              external snaplib name 'Cli_FullUpload';
function Cli_Download;                external snaplib name 'Cli_Download';
function Cli_Delete;                  external snaplib name 'Cli_Delete';
function Cli_GetPlcDateTime;          external snaplib name 'Cli_GetPlcDateTime';
function Cli_SetPlcDateTime;          external snaplib name 'Cli_SetPlcDateTime';
function Cli_SetPlcSystemDateTime;    external snaplib name 'Cli_SetPlcSystemDateTime';
function Cli_GetOrderCode;            external snaplib name 'Cli_GetOrderCode';
function Cli_GetCpuInfo;              external snaplib name 'Cli_GetCpuInfo';
function Cli_GetCPInfo;               external snaplib name 'Cli_GetCpInfo';
function Cli_ReadSZL;                 external snaplib name 'Cli_ReadSZL';
function Cli_ReadSZLList;             external snaplib name 'Cli_ReadSZLList';
function Cli_PlcHotStart;             external snaplib name 'Cli_PlcHotStart';
function Cli_PlcColdStart;            external snaplib name 'Cli_PlcColdStart';
function Cli_PlcStop;                 external snaplib name 'Cli_PlcStop';
function Cli_CopyRamToRom;            external snaplib name 'Cli_CopyRamToRom';
function Cli_Compress;                external snaplib name 'Cli_Compress';
function Cli_GetPlcStatus;            external snaplib name 'Cli_GetPlcStatus';
function Cli_GetProtection;           external snaplib name 'Cli_GetProtection';
function Cli_SetSessionPassword;      external snaplib name 'Cli_SetSessionPassword';
function Cli_ClearSessionPassword;    external snaplib name 'Cli_ClearSessionPassword';
function Cli_DBGet;                   external snaplib name 'Cli_DBGet';
function Cli_DBFill;                  external snaplib name 'Cli_DBFill';
function Cli_GetExecTime;             external snaplib name 'Cli_GetExecTime';
function Cli_GetPduLength;            external snaplib name 'Cli_GetPduLength';
function Cli_GetLastError;            external snaplib name 'Cli_GetLastError';
function Cli_AsReadArea;              external snaplib name 'Cli_AsReadArea';
function Cli_AsWriteArea;             external snaplib name 'Cli_AsWriteArea';
function Cli_AsDBRead;                external snaplib name 'Cli_AsDBRead';
function Cli_AsDBWrite;               external snaplib name 'Cli_AsDBWrite';
function Cli_AsMBRead;                external snaplib name 'Cli_AsMBRead';
function Cli_AsMBWrite;               external snaplib name 'Cli_AsMBWrite';
function Cli_AsEBRead;                external snaplib name 'Cli_AsEBRead';
function Cli_AsEBWrite;               external snaplib name 'Cli_AsEBWrite';
function Cli_AsABRead;                external snaplib name 'Cli_AsABRead';
function Cli_AsABWrite;               external snaplib name 'Cli_AsABWrite';
function Cli_AsTMRead;                external snaplib name 'Cli_AsTMRead';
function Cli_AsTMWrite;               external snaplib name 'Cli_AsTMWrite';
function Cli_AsCTRead;                external snaplib name 'Cli_AsCTRead';
function Cli_AsCTWrite;               external snaplib name 'Cli_AsCTWrite';
function Cli_AsListBlocksOfType;      external snaplib name 'Cli_AsListBlocksOfType';
function Cli_AsReadSZL;               external snaplib name 'Cli_AsReadSZL';
function Cli_AsReadSZLList;           external snaplib name 'Cli_AsReadSZLList';
function Cli_AsUpload;                external snaplib name 'Cli_AsUpload';
function Cli_AsFullUpload;            external snaplib name 'Cli_AsFullUpload';
function Cli_AsDownload;              external snaplib name 'Cli_AsDownload';
function Cli_AsCopyRamToRom;          external snaplib name 'Cli_AsCopyRamToRom';
function Cli_AsCompress;              external snaplib name 'Cli_AsCompress';
function Cli_AsDBGet;                 external snaplib name 'Cli_AsDBGet';
function Cli_AsDBFill;                external snaplib name 'Cli_AsDBFill';
function Cli_CheckAsCompletion;       external snaplib name 'Cli_CheckAsCompletion';
function Cli_WaitAsCompletion;        external snaplib name 'Cli_WaitAsCompletion';
function Cli_IsoExchangeBuffer;       external snaplib name 'Cli_IsoExchangeBuffer';
function Cli_ErrorText;               external snaplib name 'Cli_ErrorText';
function Cli_GetConnected;            external snaplib name 'Cli_GetConnected';
//******************************************************************************
//                               SERVER FORWARDS
//******************************************************************************
function Srv_Create;                  external snaplib name 'Srv_Create';
procedure Srv_Destroy;                external snaplib name 'Srv_Destroy';
function Srv_GetParam;                external snaplib name 'Srv_GetParam';
function Srv_SetParam;                external snaplib name 'Srv_SetParam';
function Srv_Start;                   external snaplib name 'Srv_Start';
function Srv_StartTo;                 external snaplib name 'Srv_StartTo';
function Srv_Stop;                    external snaplib name 'Srv_Stop';
function Srv_RegisterArea;            external snaplib name 'Srv_RegisterArea';
function Srv_UnregisterArea;          external snaplib name 'Srv_UnregisterArea';
function Srv_LockArea;                external snaplib name 'Srv_LockArea';
function Srv_UnlockArea;              external snaplib name 'Srv_UnlockArea';
function Srv_GetStatus;               external snaplib name 'Srv_GetStatus';
function Srv_SetCpuStatus;            external snaplib name 'Srv_SetCpuStatus';
function Srv_PickEvent;               external snaplib name 'Srv_PickEvent';
function Srv_ClearEvents;             external snaplib name 'Srv_ClearEvents';
function Srv_GetMask;                 external snaplib name 'Srv_GetMask';
function Srv_SetMask;                 external snaplib name 'Srv_SetMask';
function Srv_SetEventsCallback;       external snaplib name 'Srv_SetEventsCallback';
function Srv_SetReadEventsCallback;   external snaplib name 'Srv_SetReadEventsCallback';
function Srv_SetRWAreaCallback;       external snaplib name 'Srv_SetRWAreaCallback';
function Srv_ErrorText;               external snaplib name 'Srv_ErrorText';
function Srv_EventText;               external snaplib name 'Srv_EventText';
//******************************************************************************
//                              PARTNER FORWARDS
//******************************************************************************
function Par_Create;                  external snaplib name 'Par_Create';
procedure Par_Destroy;                external snaplib name 'Par_Destroy';
function Par_GetParam;                external snaplib name 'Par_GetParam';
function Par_SetParam;                external snaplib name 'Par_SetParam';
function Par_Start;                   external snaplib name 'Par_Start';
function Par_StartTo;                 external snaplib name 'Par_StartTo';
function Par_Stop;                    external snaplib name 'Par_Stop';
function Par_BSend;                   external snaplib name 'Par_BSend';
function Par_AsBSend;                 external snaplib name 'Par_AsBSend';
function Par_CheckAsBSendCompletion;  external snaplib name 'Par_CheckAsBSendCompletion';
function Par_WaitAsBSendCompletion;   external snaplib name 'Par_WaitAsBSendCompletion';
function Par_SetSendCallback;         external snaplib name 'Par_SetSendCallback';
function Par_BRecv;                   external snaplib name 'Par_BRecv';
function Par_CheckAsBRecvCompletion;  external snaplib name 'Par_CheckAsBRecvCompletion';
function Par_SetRecvCallback;         external snaplib name 'Par_SetRecvCallback';
function Par_GetTimes;                external snaplib name 'Par_GetTimes';
function Par_GetLastError;            external snaplib name 'Par_GetLastError';
function Par_GetStatus;               external snaplib name 'Par_GetStatus';
function Par_GetStats;                external snaplib name 'Par_GetStats';
function Par_ErrorText;               external snaplib name 'Par_ErrorText';
//******************************************************************************
//  TS7Client CLASS IMPLEMENTATION
//******************************************************************************
constructor TS7Client.Create;
begin
  inherited;
  HC:=Cli_Create;
end;
//------------------------------------------------------------------------------
destructor TS7Client.Destroy;
begin
  Cli_Destroy(HC);
  inherited;
end;
//------------------------------------------------------------------------------
function TS7Client.ConnectTo(Address : AnsiString; Rack,Slot : integer) : integer;
begin
  Result:=Cli_ConnectTo(HC,PAnsiChar(Address), Rack, Slot)
end;
//------------------------------------------------------------------------------
function TS7Client.SetConnectionParams(Address: AnsiString; LocalTSAP, RemoteTSAP: word ) : integer;
begin
  Result:=Cli_SetConnectionParams(HC,PAnsiChar(Address), LocalTSAP, RemoteTSAP)
end;
//------------------------------------------------------------------------------
function TS7Client.SetConnectionType(ConnectionType : word ) : integer;
begin
  Result:=Cli_SetConnectionType(HC, ConnectionType)
end;
//------------------------------------------------------------------------------
function TS7Client.Connect : integer;
begin
  Result:=Cli_Connect(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.Disconnect : integer;
begin
  Result:=Cli_Disconnect(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.SetAsCallback(pCompletion, usrPtr : pointer) : integer;
begin
  Result:=Cli_SetAsCallback(HC,pCompletion,usrPtr)
end;
//------------------------------------------------------------------------------
function TS7Client.ReadArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_ReadArea(HC,Area,DBNumber,Start,Amount,WordLen,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.WaitAsCompletion(Timeout: longword): integer;
begin
  Result:=Cli_WaitAsCompletion(HC,Timeout)
end;
//------------------------------------------------------------------------------
function TS7Client.WriteArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_WriteArea(HC,Area,DBNumber,Start,Amount,WordLen,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.ReadMultiVars(Items : PS7DataItems; ItemsCount : integer) : integer;
begin
  Result:=Cli_ReadMultiVars(HC,Items,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.WriteMultiVars(Items : PS7DataItems; ItemsCount : integer) : integer;
begin
  Result:=Cli_WriteMultiVars(HC,Items,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.DBRead(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_DBRead(HC,DBNumber,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.DBWrite(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_DBWrite(HC,DBNumber,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.MBRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_MBRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.MBWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_MBWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.EBRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_EBRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.EBWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_EBWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.ABRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_ABRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.ABWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_ABWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.TMRead(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_TMRead(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.TMWrite(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_TMWrite(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.CTRead(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_CTRead(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.CTWrite(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_CTWrite(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.ListBlocks(pUsrData : PS7BlocksList) : integer;
begin
  Result:=Cli_ListBlocks(HC,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.GetAgBlockInfo(BlockType, BlockNum : integer; pUsrData : PS7BlockInfo) : integer;
begin
  Result:=Cli_GetAgBlockInfo(HC,BlockType,BlockNum,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.GetPgBlockInfo(pBlock : pointer; pUsrData : PS7BlockInfo; Size : integer) : integer;
begin
  Result:=Cli_GetPgBlockInfo(HC,pBlock,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.ListBlocksOfType(BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
begin
  Result:=Cli_ListBlocksOfType(HC,BlockType,pUsrData,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.Upload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_Upload(HC,BlockType,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.FullUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_FullUpload(HC,BlockType,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.Download(BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
begin
  Result:=Cli_Download(HC,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.Delete(BlockType, BlockNum : integer) : integer;
begin
  Result:=Cli_Delete(HC,BlockType,BlockNum)
end;
//------------------------------------------------------------------------------
function TS7Client.DBGet(DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_DBGet(HC,DBNumber,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.DBFill(DBNumber : integer; FillChar : integer) : integer;
begin
  Result:=Cli_DBFill(HC,DBNumber,FillChar)
end;
//------------------------------------------------------------------------------
function TS7Client.GetPlcDateTime(Var DateTime : TDateTime) : integer;
Var
  CPP_tm : TCPP_tm;
begin
  Result:=Cli_GetPlcDateTime(HC,CPP_tm);
  if Result=0 then
    DateTime:=CPP_tmToDateTime(CPP_tm);
end;
//------------------------------------------------------------------------------
function TS7Client.GetParam(ParamNumber : integer; pValue: pointer): integer;
begin
  Result:=Cli_GetParam(HC, ParamNumber, pValue);
end;
//------------------------------------------------------------------------------
function TS7Client.SetParam(ParamNumber : integer; pValue: pointer): integer;
begin
  Result:=Cli_SetParam(HC, ParamNumber, pValue);
end;
//------------------------------------------------------------------------------
function TS7Client.SetPlcDateTime(Var DateTime : TDateTime) : integer;
Var
  CPP_tm : TCPP_tm;
begin
  CPP_tm:=DateTimeToCPP_tm(DateTime);
  Result:=Cli_SetPlcDateTime(HC,CPP_tm);
end;
//------------------------------------------------------------------------------
function TS7Client.SetPlcSystemDateTime : integer;
begin
  Result:=Cli_SetPlcSystemDateTime(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.GetOrderCode(pUsrData : PS7OrderCode) : integer;
begin
  Result:=Cli_GetOrderCode(HC,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.GetCpuInfo(pUsrData : PS7CpuInfo) : integer;
begin
  Result:=Cli_GetCpuInfo(HC,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.GetCPInfo(pUsrData : PS7CpInfo) : integer;
begin
  Result:=Cli_GetCPInfo(HC,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.ReadSZL(ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
begin
  Result:=Cli_ReadSZL(HC,ID,Index,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.ReadSZLList(pUsrData : PS7SZLList; var ItemsCount : integer) : integer;
begin
  Result:=Cli_ReadSZLList(HC,pUsrData,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.PlcHotStart : integer;
begin
  Result:=Cli_PlcHotStart(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.PlcColdStart : integer;
begin
  Result:=Cli_PlcColdStart(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.PlcStatus: integer;
Var
  Return : integer;
begin
  Return:=Cli_GetPlcStatus(HC, Result);
  if (Return<>0) then
    Result:=Return;
end;
//------------------------------------------------------------------------------
function TS7Client.Connected: boolean;
Var
  IsConnected : integer;
begin
  if Cli_GetConnected(HC, IsConnected)=0 then
    Result:=IsConnected<>0
  else
    Result:=false;
end;
//------------------------------------------------------------------------------
function TS7Client.PlcStop : integer;
begin
  Result:=Cli_PlcStop(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.CopyRamToRom(Timeout : integer) : integer;
begin
  Result:=Cli_CopyRamToRom(HC,Timeout)
end;
//------------------------------------------------------------------------------
function TS7Client.Compress(Timeout : integer) : integer;
begin
  Result:=Cli_Compress(HC,Timeout)
end;
//------------------------------------------------------------------------------
function TS7Client.GetPlcStatus(var Status : integer) : integer;
begin
  Result:=Cli_GetPlcStatus(HC,Status)
end;
//------------------------------------------------------------------------------
function TS7Client.GetProtection(pUsrData : PS7Protection) : integer;
begin
  Result:=Cli_GetProtection(HC,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.SetSessionPassword(Password : AnsiString) : integer;
begin
  Result:=Cli_SetSessionPassword(HC,PAnsiChar(Password))
end;
//------------------------------------------------------------------------------
function TS7Client.ClearSessionPassword : integer;
begin
  Result:=Cli_ClearSessionPassword(HC)
end;
//------------------------------------------------------------------------------
function TS7Client.AsReadArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsReadArea(HC,Area,DBNumber,Start,Amount,WordLen,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsWriteArea(Area, DBNumber, Start, Amount, WordLen : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsWriteArea(HC,Area,DBNumber,Start,Amount,WordLen,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsDBRead(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsDBRead(HC,DBNumber,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsDBWrite(DBNumber, Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsDBWrite(HC,DBNumber,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsMBRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsMBRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsMBWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsMBWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsEBRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsEBRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsEBWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsEBWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsABRead(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsABRead(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsABWrite(Start, Size : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsABWrite(HC,Start,Size,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsTMRead(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsTMRead(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsTMWrite(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsTMWrite(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsCTRead(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsCTRead(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsCTWrite(Start, Amount : integer; pUsrData : pointer) : integer;
begin
  Result:=Cli_AsCTWrite(HC,Start,Amount,pUsrData)
end;
//------------------------------------------------------------------------------
function TS7Client.AsListBlocksOfType(BlockType : integer; pUsrData : PS7BlocksOfType; var ItemsCount : integer) : integer;
begin
  Result:=Cli_AsListBlocksOfType(HC,BlockType,pUsrData,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.AsReadSZL(ID, Index : integer; pUsrData : PS7SZL; var Size : integer) : integer;
begin
  Result:=Cli_AsReadSZL(HC,ID,Index,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.AsReadSZLList(pUsrData: PS7SZLList;
  var ItemsCount: integer): integer;
begin
  Result:=Cli_AsReadSZLList(HC,pUsrData,ItemsCount)
end;
//------------------------------------------------------------------------------
function TS7Client.AsUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_AsUpload(HC,BlockType,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.AsFullUpload(BlockType, BlockNum : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_AsFullUpload(HC,BlockType,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.AsDownload(BlockNum : integer; pUsrData : pointer; Size : integer) : integer;
begin
  Result:=Cli_AsDownload(HC,BlockNum,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.AsCopyRamToRom(Timeout : integer) : integer;
begin
  Result:=Cli_AsCopyRamToRom(HC,Timeout)
end;
//------------------------------------------------------------------------------
function TS7Client.AsCompress(Timeout : integer) : integer;
begin
  Result:=Cli_AsCompress(HC,Timeout)
end;
//------------------------------------------------------------------------------
function TS7Client.AsDBGet(DBNumber : integer; pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_AsDBGet(HC,DBNumber,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.AsDBFill(DBNumber : integer; FillChar : integer) : integer;
begin
  Result:=Cli_AsDBFill(HC,DBNumber,FillChar)
end;
//------------------------------------------------------------------------------
function TS7Client.CheckAsCompletion(var opResult : integer) : boolean;
begin
   Result:=Cli_CheckAsCompletion(HC,opResult)=JobComplete;
end;
//------------------------------------------------------------------------------
function TS7Client.IsoExchangeBuffer(pUsrData : pointer; var Size : integer) : integer;
begin
  Result:=Cli_IsoExchangeBuffer(HC,pUsrData,Size)
end;
//------------------------------------------------------------------------------
function TS7Client.Time : longword;
Var
  Return : integer;
begin
   Return:=Cli_GetExecTime(HC,Result);
   if Return<>0 then
       Result:=longword(-1);
end;
//------------------------------------------------------------------------------
function TS7Client.LastError : integer;
begin
  Cli_GetLastError(HC,Result);
end;
//------------------------------------------------------------------------------
function TS7Client.PduLength : integer;
Var
  Requested : integer;
begin
  Cli_GetPduLength(HC, Requested, Result);
end;
//------------------------------------------------------------------------------
function TS7Client.PduRequested: integer;
Var
  PduLength : integer;
begin
  Cli_GetPduLength(HC, Result, PduLength);
end;
//******************************************************************************
//  TS7Server CLASS IMPLEMENTATION
//******************************************************************************
constructor TS7Server.Create;
begin
  inherited Create;
  HS:=Srv_Create;
end;
//------------------------------------------------------------------------------
destructor TS7Server.Destroy;
begin
  if HS<>0 then
    Srv_Destroy(HS);
  inherited;
end;
//------------------------------------------------------------------------------
function TS7Server.ClearEvents: integer;
begin
  Result:=Srv_ClearEvents(HS)
end;
//------------------------------------------------------------------------------
function TS7Server.PickEvent(var Event: TSrvEvent) : boolean;
Var
  EvtReady : integer;
begin
  if Srv_PickEvent(HS, Event, EvtReady)=0 then
    Result := EvtReady<>0
  else
    Result:=False;
end;
//------------------------------------------------------------------------------
function TS7Server.GetClientsCount: integer;
Var
  ServerStatus, CpuStatus : integer;
begin
  if GetStatus(ServerStatus, CpuStatus, Result)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Server.GetCpuStatus: integer;
Var
  ServerStatus, ClientsCount : integer;
begin
  if GetStatus(ServerStatus, Result, ClientsCount)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Server.GetEventsMask: longword;
begin
  if Srv_GetMask(HS, mkEvent, Result)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Server.GetLogMask: longword;
begin
  if Srv_GetMask(HS, mkLog, Result)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Server.GetServerStatus: integer;
Var
  CpuStatus, ClientsCount : integer;
begin
  if GetStatus(Result, CpuStatus, ClientsCount)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Server.GetStatus(var ServerStatus, CpuStatus,
  ClientsCount: integer): integer;
begin
  Result:=Srv_GetStatus(HS, ServerStatus, CpuStatus, ClientsCount);
end;
//------------------------------------------------------------------------------
function TS7Server.LockArea(AreaCode, Index: integer): integer;
begin
  Result:=Srv_LockArea(HS, AreaCode, Index);
end;
//------------------------------------------------------------------------------
function TS7Server.RegisterArea(AreaCode, Index: integer; pUsrData: pointer;
  Size: integer): integer;
begin
  Result:=Srv_RegisterArea(HS,AreaCode,Index,pUsrData,Size);
end;
//------------------------------------------------------------------------------
procedure TS7Server.SetCpuStatus(const Value: integer);
begin
  Srv_SetCpuStatus(HS, Value);
end;
//------------------------------------------------------------------------------
function TS7Server.SetEventsCallback(CallBack, usrPtr: pointer): integer;
begin
  Result:=Srv_SetEventsCallback(HS,CallBack,usrPtr);
end;
//------------------------------------------------------------------------------
function TS7Server.SetReadEventsCallback(CallBack, usrPtr: pointer): integer;
begin
  Result:=Srv_SetReadEventsCallback(HS,CallBack,usrPtr);
end;
//------------------------------------------------------------------------------
function TS7Server.SetRWAreaCallback(CallBack, usrPtr : pointer) : integer;
begin
  Result:=Srv_SetRWAreaCallback(HS,CallBack,usrPtr);
end;
//------------------------------------------------------------------------------
procedure TS7Server.SetEventsMask(const Value: longword);
begin
  Srv_SetMask(HS, mkEvent, Value);
end;
//------------------------------------------------------------------------------
procedure TS7Server.SetLogMask(const Value: longword);
begin
  Srv_SetMask(HS, mkLog, Value);
end;
//------------------------------------------------------------------------------
function TS7Server.GetParam(ParamNumber : integer; pValue: pointer): integer;
begin
  Result:=Srv_GetParam(HS, ParamNumber ,pValue)
end;
//------------------------------------------------------------------------------
function TS7Server.SetParam(ParamNumber : integer; pValue: pointer): integer;
begin
  Result:=Srv_SetParam(HS, ParamNumber ,pValue)
end;
//------------------------------------------------------------------------------
function TS7Server.Start: integer;
begin
  Result:=Srv_Start(HS)
end;
//------------------------------------------------------------------------------
function TS7Server.StartTo(Address: String): integer;
begin
  Result:=Srv_StartTo(HS, PAnsiChar(AnsiString(Address)));
end;
//------------------------------------------------------------------------------
function TS7Server.Stop: integer;
begin
  Result:=Srv_Stop(HS)
end;
//------------------------------------------------------------------------------
function TS7Server.UnlockArea(AreaCode, Index: integer): integer;
begin
  Result:=Srv_UnlockArea(HS,AreaCode,Index)
end;
//------------------------------------------------------------------------------
function TS7Server.UnregisterArea(AreaCode, Index: integer): integer;
begin
  Result:=Srv_UnregisterArea(HS,AreaCode, Index)
end;
//******************************************************************************
//  TS7Partner CLASS IMPLEMENTATION
//******************************************************************************
function TS7Partner.AsBSend(R_ID: longword; pUsrData: pointer;
  size: integer): integer;
begin
  Result:=Par_AsBSend(HP, R_ID, pUsrData, Size);
end;
//------------------------------------------------------------------------------
function TS7Partner.BRecv(Timeout: longword; var R_ID: longword;
  pUsrData: pointer; var Size: integer): integer;
begin
  Result:=Par_BRecv(HP, R_ID, pUsrData, Size, Timeout);
end;
//------------------------------------------------------------------------------
function TS7Partner.BSend(R_ID: longword; pUsrData: pointer;
  size: integer): integer;
begin
  Result:=Par_BSend(HP, R_ID, pUsrData, Size);
end;
//------------------------------------------------------------------------------
function TS7Partner.CheckAsBRecvCompletion(var opResult: integer;
  var R_ID: longword; pUsrData: pointer; var Size: integer): boolean;
begin
   Result:=Par_CheckAsBRecvCompletion(HP, opResult, R_ID, pUsrData, Size)=JobComplete;
end;
//------------------------------------------------------------------------------
function TS7Partner.CheckAsBSendCompletion(var opResult: integer): boolean;
begin
   Result:=Par_CheckAsBSendCompletion(HP, opResult)=JobComplete;
end;
//------------------------------------------------------------------------------
constructor TS7Partner.Create(AsActive: boolean);
begin
  HP := Par_Create(AsActive);
end;
//------------------------------------------------------------------------------
destructor TS7Partner.Destroy;
begin
  Par_Destroy(HP);
  inherited;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetBytesRecv: integer;
begin
  GetStatistics;
  Result:=FBytesRecv;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetBytesSent: integer;
begin
  GetStatistics;
  Result:=FBytesSent;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetLastError: integer;
begin
  if Par_GetLastError(HP, Result)<>0 then
    Result:=errLibInvalidObject;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetLinked: boolean;
begin
  Result:=Status=par_linked;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetRecvErrors: integer;
begin
  GetStatistics;
  Result:=FRecvErrors;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetRecvTime: longword;
Var
  FSendTime : longword;
begin
  if Par_GetTimes(HP, FSendTime, Result)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetSendErrors: integer;
begin
  GetStatistics;
  Result:=FSendErrors;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetSendTime: longword;
Var
  FRecvTime : longword;
begin
  if Par_GetTimes(HP, Result, FRecvTime)<>0 then
    Result:=0;
end;
//------------------------------------------------------------------------------
procedure TS7Partner.GetStatistics;
begin
   if Par_GetStats(HP, FBytesSent, FBytesRecv, FSendErrors, FRecvErrors)<>0 then
   begin
     FBytesSent :=0;
     FBytesRecv :=0;
     FSendErrors:=0;
     FRecvErrors:=0;
   end;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetStatus: integer;
begin
  if Par_GetStatus(HP, Result)<>0 then
    Result:=errLibInvalidObject;
end;
//------------------------------------------------------------------------------
function TS7Partner.GetParam(ParamNumber: integer; pValue: Pointer): integer;
begin
  Result:=Par_SetParam(HP, ParamNumber, pValue);
end;
//------------------------------------------------------------------------------
function TS7Partner.SetParam(ParamNumber: integer; pValue: Pointer): integer;
begin
  Result:=Par_SetParam(HP, ParamNumber, pValue);
end;
//------------------------------------------------------------------------------
function TS7Partner.SetRecvCallback(pRecvCompletion, usrPtr: pointer): integer;
begin
  Result:=Par_SetRecvCallback(HP, pRecvCompletion, usrPtr);
end;
//------------------------------------------------------------------------------
function TS7Partner.SetSendCallback(pSendCompletion, usrPtr: pointer): integer;
begin
  Result:=Par_SetSendCallback(HP, pSendCompletion, usrPtr);
end;
//------------------------------------------------------------------------------
function TS7Partner.Start: integer;
begin
  Result:=Par_Start(HP);
end;
//------------------------------------------------------------------------------
function TS7Partner.StartTo(LocalAddress, RemoteAddress: AnsiString; LocalTSAP,
  RemoteTSAP: word): integer;
begin
  Result:=Par_StartTo(HP, PAnsiChar(LocalAddress), PAnsiChar(RemoteAddress),
    LocalTSAP, RemoteTSAP);
end;
//------------------------------------------------------------------------------
function TS7Partner.Stop: integer;
begin
  Result:=Par_Stop(HP);
end;
//------------------------------------------------------------------------------
function TS7Partner.WaitAsBSendCompletion(Timeout: longword): integer;
begin
  Result:=Par_WaitAsBSendCompletion(HP, Timeout);
end;
//******************************************************************************
//  S7 CLASS IMPLEMENTATION
//******************************************************************************
function TS7Helper.GetBit(pval: pointer; BitIndex: integer): boolean;
Const
  Mask : array[0..7] of byte = ($01,$02,$04,$08,$10,$20,$40,$80);
begin
  if BitIndex<0 then BitIndex:=0;
  if BitIndex>7 then BitIndex:=7;
  Result:=pbyte(pval)^ and Mask[BitIndex] <> 0;
end;
//------------------------------------------------------------------------------
function TS7Helper.GetDateTime(pval: pointer): TDateTime;
Type
  S7DT   = packed array[0..7] of byte;
Var
  Buffer : ^S7DT;
  YY,MM,DD,HH,NN,SS,MS : word;
  C,D,U : integer;

  function BCD(const B: byte): word;
  begin
    Result:=(B and $0F) + ((B shr 4) * 10);
  end;

begin
  Buffer:=pval;

  YY:= Buffer^[0];
  if YY>137 then // 137 dec = 89 BCD
    YY:=1900+BCD(YY)
  else
    YY:=2000+BCD(YY);

  MM:=BCD(Buffer^[1]);
  DD:=BCD(Buffer^[2]);
  HH:=BCD(Buffer^[3]);
  NN:=BCD(Buffer^[4]);
  SS:=BCD(Buffer^[5]);

  // Millisec
  MS:=Buffer^[6];
  MS:=(MS shl 8)+Buffer^[7];
  // Last 4 bit are Day of Week
  MS:=MS shr 4;

  // Hex to Int
  C:=((MS and $0F00) shr 8) * 100;
  D:=((MS and $00F0) shr 4) * 10;
  U:= (MS and $000F);

  MS:=C+D+U;
  TryEncodeDateTime(YY,MM,DD,HH,NN,SS,MS,Result);
end;
//------------------------------------------------------------------------------
function TS7Helper.GetDInt(pval: pointer): longint;
Var
  DW : packed array[0..3] of byte absolute Result;
begin
  DW[0]:=pbyte(NativeInt(pval)+3)^;
  DW[1]:=pbyte(NativeInt(pval)+2)^;
  DW[2]:=pbyte(NativeInt(pval)+1)^;
  DW[3]:=pbyte(pval)^;
end;
//------------------------------------------------------------------------------
function TS7Helper.GetDWord(pval: pointer): longword;
Var
  DW : packed array[0..3] of byte absolute Result;
begin
  DW[0]:=pbyte(NativeInt(pval)+3)^;
  DW[1]:=pbyte(NativeInt(pval)+2)^;
  DW[2]:=pbyte(NativeInt(pval)+1)^;
  DW[3]:=pbyte(pval)^;
end;
//------------------------------------------------------------------------------
function TS7Helper.GetInt(pval: pointer): smallint;
Var
  BW : packed array[0..1] of byte absolute Result;
begin
  BW[0]:=pbyte(NativeInt(pval)+1)^;
  BW[1]:=pbyte(pval)^;
end;
//------------------------------------------------------------------------------
function TS7Helper.GetReal(pval: pointer): single;
Var
  DW : packed array[0..3] of byte absolute Result;
begin
  DW[0]:=pbyte(NativeInt(pval)+3)^;
  DW[1]:=pbyte(NativeInt(pval)+2)^;
  DW[2]:=pbyte(NativeInt(pval)+1)^;
  DW[3]:=pbyte(pval)^;
end;
//------------------------------------------------------------------------------
function TS7Helper.GetWord(pval: pointer): word;
Var
  BW : packed array[0..1] of byte absolute Result;
begin
  BW[0]:=pbyte(NativeInt(pval)+1)^;
  BW[1]:=pbyte(pval)^;
end;
//------------------------------------------------------------------------------
procedure TS7Helper.Reverse(pval: pointer; const S7Type: TS7Type);
Var
  DT : TDateTime;
begin
  case S7Type of
    S7Int,
    S7Word: SetWord(pval, pword(pval)^);
    S7DInt,
    S7DWord,
    S7Real: SetDWord(pval, plongword(pval)^);
    S7DT_To_DateTime: pDateTime(pval)^:=GetDateTime(pval);
    DateTime_To_S7DT: begin
      DT:=pdateTime(pval)^;
      SetDateTime(pval, DT);
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetBit(pval: pointer; BitIndex: integer; const Value: boolean);
Const
  Mask : array[0..7] of byte = ($01,$02,$04,$08,$10,$20,$40,$80);
begin
  if BitIndex<0 then BitIndex:=0;
  if BitIndex>7 then BitIndex:=7;
  if Value then
    pbyte(pval)^ := pbyte(pval)^ or Mask[BitIndex]
  else
    pbyte(pval)^ := pbyte(pval)^ and not Mask[BitIndex];
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetDateTime(pval: pointer; const Value: TDateTime);
Type
  DATE_AND_TIME = packed array[1..8] of byte;
  pDT = ^DATE_AND_TIME;

  function BCD(Value : word) : byte;
  begin
    Result:=((Value div 10) shl 4) OR (Value mod 10);
  end;

  function BCDW(Value : word) : word;
  Var
    AppC, AppD : word;
  begin
    AppC :=(Value div 100);
    Dec(Value,AppC * 100);
    AppD :=(Value div 10);
    Dec(Value,AppD * 10);
    Result:=(AppC shl 8) + (AppD shl 4) + Value;
  end;

Var
  DT : pDT;
  MsDOW, AYear, AMonth, ADay,
  AHour, AMinute, ASecond, AMilliSecond: Word;
begin
  DT:=pval;
  DecodeDateTime(Value,AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
  if AYear>1999 then
    AYear:=AYear-2000
  else
    AYear:=AYear-1900;

  DT^[1]:=BCD(AYear);
  DT^[2]:=BCD(AMonth);
  DT^[3]:=BCD(ADay);
  DT^[4]:=BCD(AHour);
  DT^[5]:=BCD(AMinute);
  DT^[6]:=BCD(ASecond);
  MsDOW:=(BCDW(AMillisecond) shl 4) + DayOfWeek(Value)+1;
  DT^[7]:=HI(MsDOW);
  DT^[8]:=LO(MsDOW);
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetDInt(pval: pointer; const Value: longint);
Var
  DW : packed array[0..3] of byte absolute value;
begin
  pbyte(pval)^:=DW[3];
  pbyte(NativeInt(pval)+1)^:=DW[2];
  pbyte(NativeInt(pval)+2)^:=DW[1];
  pbyte(NativeInt(pval)+3)^:=DW[0];
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetDWord(pval: pointer; const Value: longword);
Var
  DW : packed array[0..3] of byte absolute value;
begin
  pbyte(pval)^:=DW[3];
  pbyte(NativeInt(pval)+1)^:=DW[2];
  pbyte(NativeInt(pval)+2)^:=DW[1];
  pbyte(NativeInt(pval)+3)^:=DW[0];
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetInt(pval: pointer; const Value: smallint);
Var
  BW : packed array[0..1] of byte absolute value;
begin
  pbyte(NativeInt(pval)+1)^:=BW[0];
  pbyte(pval)^:=BW[1];
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetReal(pval: pointer; const Value: single);
Var
  DW : packed array[0..3] of byte absolute value;
begin
  pbyte(pval)^:=DW[3];
  pbyte(NativeInt(pval)+1)^:=DW[2];
  pbyte(NativeInt(pval)+2)^:=DW[1];
  pbyte(NativeInt(pval)+3)^:=DW[0];
end;
//------------------------------------------------------------------------------
procedure TS7Helper.SetWord(pval: pointer; const Value: word);
Var
  BW : packed array[0..1] of byte absolute value;
begin
  pbyte(NativeInt(pval)+1)^:=BW[0];
  pbyte(pval)^:=BW[1];
end;
//******************************************************************************
//                               TEXT ROUTINES
//******************************************************************************
function CliErrorText(Error : integer) : string;
Var
  Text : packed array[0..TextLen-1] of AnsiChar;
begin
  if Cli_ErrorText(Error, @Text, TextLen)=0 then
    Result:=String(Text)
  else
    Result:='LIB : Error getting text';
end;
//---------------------------------------------------------------------------
function SrvErrorText(Error : integer) : string;
Var
  Text : packed array[0..TextLen-1] of AnsiChar;
begin
  if Srv_ErrorText(Error, @Text, TextLen)=0 then
    Result:=String(Text)
  else
    Result:='LIB : Error getting text';
end;
//---------------------------------------------------------------------------
function ParErrorText(Error : integer) : string;
Var
  Text : packed array[0..TextLen-1] of AnsiChar;
begin
  if Par_ErrorText(Error, @Text, TextLen)=0 then
    Result:=String(Text)
  else
    Result:='LIB : Error getting text';
end;
//---------------------------------------------------------------------------
function SrvEventText(var Event : TSrvEvent) : string;
Var
  Text : packed array[0..TextLen-1] of AnsiChar;
begin
  if Srv_EventText(Event, @Text, TextLen)=0 then
    Result:=String(Text)
  else
    Result:='LIB : Error getting text';
end;

initialization

  S7 := TS7Helper.Create;

finalization

  S7.Free;

end.
