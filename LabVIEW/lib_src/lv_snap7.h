/*=============================================================================|
|  PROJECT SNAP7                                                         1.1.0 |
|==============================================================================|
|  Copyright (C) 2013, Davide Nardella                                         |
|  All rights reserved.                                                        |
|==============================================================================|
|  SNAP7 is free software: you can redistribute it and/or modify               |
|  it under the terms of the Lesser GNU General Public License as published by |
|  the Free Software Foundation, either version 3 of the License, or           |
|  (at your option) any later version.                                         |
|                                                                              |
|  It means that you can distribute your commercial software linked with       |
|  SMART7 without the requirement to distribute the source code of your        |
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
|  32/64 bit LabVIEW interface                                                 |
|                                                                              |
|=============================================================================*/
#ifndef lv_snap7_h
#define lv_snap7_h
//---------------------------------------------------------------------------
#include "snap7.h"
//---------------------------------------------------------------------------
#ifdef OS_WINDOWS
# define EXPORTSPEC extern "C" __declspec ( dllexport )
#else
# define EXPORTSPEC extern "C"
#endif

#pragma pack(1)

typedef struct {
   int32_t size;    // Block Size
   byte Data[1];    // Data
} TLVString, *PLVString;

typedef struct {
   int32_t size;    // Block Size
   byte Data[1];    // Data
} TAdaptToType1D, *PAdaptToType1D;

typedef struct {
    uint64_t attoseconds;
    int64_t seconds;
} lv_timestamp, *plv_timestamp;

#define delta_epoch 2082844800

// Int part of Blocks info
typedef struct {
   int BlkType;    // Block Type (OB, DB) 
   int BlkNumber;  // Block number
   int BlkLang;    // Block Language
   int BlkFlags;   // Block flags
   int MC7Size;    // The real size in bytes
   int LoadSize;   // Load memory size
   int LocalData;  // Local data
   int SBBLength;  // SBB Length
   int CheckSum;   // Checksum
   int Version;    // Block version
} TS7IntBlockInfo, *PS7IntBlockInfo ;

typedef int32_t *pint32_t;
//==============================================================================
// CLIENT EXPORT LIST - Sync functions
//==============================================================================

EXPORTSPEC S7Object S7API lv_Cli_Create();
EXPORTSPEC void S7API lv_Cli_Destroy(S7Object &Client);
EXPORTSPEC int S7API lv_Cli_Connect(S7Object Client);
EXPORTSPEC int S7API lv_Cli_ConnectTo(S7Object Client, const char *Address, int Rack, int Slot);
EXPORTSPEC int S7API lv_Cli_SetConnectionParams(S7Object Client, const char *Address, word LocalTSAP, word RemoteTSAP);
EXPORTSPEC int S7API lv_Cli_SetConnectionType(S7Object Client, word ConnectionType);
EXPORTSPEC int S7API lv_Cli_Disconnect(S7Object Client);
EXPORTSPEC int S7API lv_Cli_GetParam(S7Object Client, int ParamNumber, void *pValue);
EXPORTSPEC int S7API lv_Cli_SetParam(S7Object Client, int ParamNumber, void *pValue);
// Data I/O functions
EXPORTSPEC int S7API lv_Cli_ReadArea(S7Object Client, int Area, int DBNumber, int Start, int Amount, int WordLen, PLVString *pStringData);
EXPORTSPEC int S7API lv_Cli_WriteArea(S7Object Client, int Area, int DBNumber, int Start, int Amount, int WordLen, PLVString *pStringData);
// System Info functions
EXPORTSPEC int S7API lv_Cli_GetOrderCode(S7Object Client, PLVString *pStringData, byte &V1, byte &V2, byte &V3);
EXPORTSPEC int S7API lv_Cli_GetCpuInfo(S7Object Client, PLVString *pStringData);
EXPORTSPEC int S7API lv_Cli_GetCpInfo(S7Object Client, TS7CpInfo *pUsrData);
// Directory functions
EXPORTSPEC int S7API lv_Cli_ListBlocks(S7Object Client, TS7BlocksList *pUsrData);
EXPORTSPEC int S7API lv_Cli_ListBlocksOfType(S7Object Client, int BlockType, PAdaptToType1D *pArrayData, int &ItemsCount);
EXPORTSPEC int S7API lv_Cli_GetAgBlockInfo(S7Object Client, int BlockType, int BlockNum, TS7IntBlockInfo *pIntBlkInfo, PLVString *pChrBlkInfo);
EXPORTSPEC int S7API lv_Cli_GetPgBlockInfo(S7Object Client, TS7IntBlockInfo *pIntBlkInfo, PLVString *pChrBlkInfo, PLVString *pStringData, int BlockSize);
// Blocks functions
EXPORTSPEC int S7API lv_Cli_DBGet(S7Object Client, int DBNumber, PLVString *pStringData, int &SizeGet);
EXPORTSPEC int S7API lv_Cli_Upload(S7Object Client, int BlockType, int BlockNum, PLVString *pStringData, int &SizeGet);
EXPORTSPEC int S7API lv_Cli_FullUpload(S7Object Client, int BlockType, int BlockNum, PLVString *pStringData, int &SizeGet);
EXPORTSPEC int S7API lv_Cli_DBFill(S7Object Client, int DBNumber, byte FillChar);
EXPORTSPEC int S7API lv_Cli_Delete(S7Object Client, int BlockType, int BlockNum);
EXPORTSPEC int S7API lv_Cli_Download(S7Object Client, int BlockNum, PLVString *pStringData, int Size);
// Date/Time functions
EXPORTSPEC int S7API lv_Cli_GetPlcDateTime(S7Object Client, lv_timestamp *timestamp);
EXPORTSPEC int S7API lv_Cli_SetPlcDateTime(S7Object Client, lv_timestamp *timestamp);
EXPORTSPEC int S7API lv_Cli_SetPlcSystemDateTime(S7Object Client);
// System Info functions
EXPORTSPEC int S7API lv_Cli_ReadSZL(S7Object Client, int ID, int Index, word &LENTHDR, word &N_DR, PAdaptToType1D *pArrayData, int &Size);
EXPORTSPEC int S7API lv_Cli_ReadSZLList(S7Object Client, PAdaptToType1D *pArrayData, int &ItemsCount);
// Control functions
EXPORTSPEC int S7API lv_Cli_PlcHotStart(S7Object Client);
EXPORTSPEC int S7API lv_Cli_PlcColdStart(S7Object Client);
EXPORTSPEC int S7API lv_Cli_PlcStop(S7Object Client);
EXPORTSPEC int S7API lv_Cli_CopyRamToRom(S7Object Client, int Timeout);
EXPORTSPEC int S7API lv_Cli_Compress(S7Object Client, int Timeout);
EXPORTSPEC int S7API lv_Cli_GetPlcStatus(S7Object Client, int &Status);
// Security functions
EXPORTSPEC int S7API lv_Cli_GetProtection(S7Object Client, TS7Protection *pUsrData);
EXPORTSPEC int S7API lv_Cli_SetSessionPassword(S7Object Client, char *Password);
EXPORTSPEC int S7API lv_Cli_ClearSessionPassword(S7Object Client);
// Low level
EXPORTSPEC int S7API lv_Cli_IsoExchangeBuffer(S7Object Client, PLVString *pStringData, int &Size);
// Misc
EXPORTSPEC int S7API lv_Cli_GetExecTime(S7Object Client, int &Time);
EXPORTSPEC int S7API lv_Cli_GetLastError(S7Object Client, int &LastError);
EXPORTSPEC int S7API lv_Cli_GetPduLength(S7Object Client, int &Requested, int &Negotiated);
EXPORTSPEC int S7API lv_Cli_ErrorText(int Error, char *Text, int TxtLen);

//==============================================================================
//  SERVER EXPORT LIST
//==============================================================================
EXPORTSPEC S7Object S7API lv_Srv_Create();
EXPORTSPEC void S7API lv_Srv_Destroy(S7Object &Server);
EXPORTSPEC int S7API lv_Srv_Start(S7Object Server);
EXPORTSPEC int S7API lv_Srv_StartTo(S7Object Server, const char *Address);
EXPORTSPEC int S7API lv_Srv_Stop(S7Object Server);
EXPORTSPEC int S7API lv_Srv_GetParam(S7Object Client, int ParamNumber, void *pValue);
EXPORTSPEC int S7API lv_Srv_SetParam(S7Object Client, int ParamNumber, void *pValue);
// Events
EXPORTSPEC int S7API lv_Srv_GetMask(S7Object Server, longword &Mask);
EXPORTSPEC int S7API lv_Srv_SetMask(S7Object Server, longword Mask);
EXPORTSPEC int S7API lv_Srv_PickEvent(S7Object Server, TSrvEvent *pEvent, int &EvtReady);
EXPORTSPEC int S7API lv_Srv_EventText(TSrvEvent &Event, char *Text, int TxtLen);
EXPORTSPEC int S7API lv_Srv_ClearEvents(S7Object Server);
// Data
EXPORTSPEC int S7API lv_Srv_RegisterArea(S7Object Server, int AreaCode, word Index, PLVString *pStringData);
EXPORTSPEC int S7API lv_Srv_UnregisterArea(S7Object Server, int AreaCode, word Index);
EXPORTSPEC int S7API lv_Srv_LockArea(S7Object Server, int AreaCode, word Index);
EXPORTSPEC int S7API lv_Srv_UnlockArea(S7Object Server, int AreaCode, word Index);
// Misc
EXPORTSPEC int S7API lv_Srv_GetStatus(S7Object Server, int &ServerStatus, int &CpuStatus, int &ClientsCount);
EXPORTSPEC int S7API lv_Srv_SetCpuStatus(S7Object Server, int CpuStatus);
EXPORTSPEC int S7API lv_Srv_ErrorText(int Error, char *Text, int TxtLen);
//==============================================================================
//  PARTNER EXPORT LIST
//==============================================================================
EXPORTSPEC S7Object S7API lv_Par_Create(int Active);
EXPORTSPEC void S7API lv_Par_Destroy(S7Object &Partner);
EXPORTSPEC int S7API lv_Par_GetParam(S7Object Partner, int ParamNumber, void *pValue);
EXPORTSPEC int S7API lv_Par_SetParam(S7Object Partner, int ParamNumber, void *pValue);
EXPORTSPEC int S7API lv_Par_Start(S7Object Partner);
EXPORTSPEC int S7API lv_Par_StartTo(S7Object Partner, const char *LocalAddress, const char *RemoteAddress, 
	word LocTsap, word RemTsap);
EXPORTSPEC int S7API lv_Par_Stop(S7Object Partner);
// BSend
EXPORTSPEC int S7API lv_Par_BSend(S7Object Partner, longword R_ID, PLVString *pStringData, int Size);
// BRecv
EXPORTSPEC int S7API lv_Par_BRecv(S7Object Partner, longword &R_ID, PLVString *pStringData, int &Size, int &DataReady);
// Stat
EXPORTSPEC int S7API lv_Par_GetTimes(S7Object Partner, longword &SendTime, longword &RecvTime);
EXPORTSPEC int S7API lv_Par_GetStats(S7Object Partner, longword &BytesSent, longword &BytesRecv,
    longword &SendErrors, longword &RecvErrors);
EXPORTSPEC int S7API lv_Par_GetLastError(S7Object Partner, int &LastError);
EXPORTSPEC int S7API lv_Par_GetStatus(S7Object Partner, int &Status);
EXPORTSPEC int S7API lv_Par_ErrorText(int Error, char *Text, int TxtLen);

#pragma pack()
#endif // lv_snap7
