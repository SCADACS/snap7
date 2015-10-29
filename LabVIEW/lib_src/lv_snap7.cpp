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
#include "lv_snap7.h"

#ifndef OS_WINDOWS
void libinit(void) __attribute__((constructor));
void libdone(void) __attribute__((destructor));
#endif

#ifdef OS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

static bool libresult = true;

void libinit(void)
{
     // in future expansions here can be inserted some initialization code
     libresult=true;
}

void libdone(void)
{
     // in future expansions here can be inserted some destruction code
}

#ifdef OS_WINDOWS
BOOL APIENTRY DllMain (HINSTANCE hInst,
                       DWORD reason,
                       LPVOID reserved)
{
    switch (reason)
    {
      case DLL_PROCESS_ATTACH:
        libinit();
        break;
      case DLL_PROCESS_DETACH:
        libdone();
        break;
      case DLL_THREAD_ATTACH:
        break;
      case DLL_THREAD_DETACH:
        break;
    }
    return libresult;
}
#endif

//***************************************************************************
// CLIENT
//***************************************************************************
int DataSizeByte(int WordLength)
{
     switch (WordLength){
          case S7WLBit     : return 1;  // S7 sends 1 byte per bit
          case S7WLByte    : return 1;
          case S7WLWord    : return 2;
          case S7WLDWord   : return 4;
          case S7WLReal    : return 4;
          case S7WLCounter : return 2;
          case S7WLTimer   : return 2;
          default          : return 0;
     }
}
#pragma pack(1)
//---------------------------------------------------------------------------
S7Object S7API lv_Cli_Create()
{    
    return Cli_Create();
}
//---------------------------------------------------------------------------
void S7API lv_Cli_Destroy(S7Object &Client)
{
    Cli_Destroy(&Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ConnectTo(S7Object Client, const char *Address, int Rack, int Slot)
{
    return Cli_ConnectTo(Client, Address, Rack, Slot);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetConnectionParams(S7Object Client, const char *Address, word LocalTSAP, word RemoteTSAP)
{
    return Cli_SetConnectionParams(Client, Address, LocalTSAP, RemoteTSAP);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetConnectionType(S7Object Client, word ConnectionType)
{
    return Cli_SetConnectionType(Client, ConnectionType);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Connect(S7Object Client)
{
	return Cli_Connect(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Disconnect(S7Object Client)
{
    return Cli_Disconnect(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetParam(S7Object Client, int ParamNumber, void *pValue)
{
    return Cli_GetParam(Client, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetParam(S7Object Client, int ParamNumber, void *pValue)
{
    return Cli_SetParam(Client, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ReadArea(S7Object Client, int Area, int DBNumber, int Start, int Amount, int WordLen, PLVString *pStringData)
{
    bool Trimmed = false;
	int32_t Multiplier = DataSizeByte(WordLen);
	if (Multiplier==0) Multiplier=1; // Assume byte wide
	int32_t BufferSize = Multiplier * Amount;
	int32_t StringSize = *pint32_t(*pStringData);
	pbyte pData=pbyte(*pStringData) + sizeof(int32_t);
	// Check the string size against the buffer size
	if (StringSize<BufferSize)
	{
	    Trimmed=true;
		Amount=StringSize/Multiplier; // trim the amount to fit into the string 
	};
	int Result=Cli_ReadArea(Client, Area, DBNumber, Start, Amount, WordLen, pData);
	if ((Result==0) && Trimmed)
		Result=errCliPartialDataRead;
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_WriteArea(S7Object Client, int Area, int DBNumber, int Start, int Amount, int WordLen, PLVString *pStringData)
{
    bool Trimmed = false;
	int32_t Multiplier = DataSizeByte(WordLen);
	if (Multiplier==0) Multiplier=1; // Assume byte wide
	int32_t BufferSize = Multiplier * Amount;
	int32_t StringSize = *pint32_t(*pStringData);
	pbyte pData=pbyte(*pStringData) + sizeof(int32_t);
	// Check the string size against the buffer size
	if (StringSize<BufferSize)
	{
	    Trimmed=true;
		Amount=StringSize/Multiplier; // trim the amount to fit into the string 
	};
	int Result=Cli_WriteArea(Client, Area, DBNumber, Start, Amount, WordLen, pData);
	if ((Result==0) && Trimmed)
		Result=errCliPartialDataWritten;
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_DBGet(S7Object Client, int DBNumber, PLVString *pStringData, int &SizeGet)
{
    int32_t Size = *pint32_t(*pStringData);
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
	int Result=Cli_DBGet(Client, DBNumber, pUsrData, &Size);
    SizeGet=Size;
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ListBlocks(S7Object Client, TS7BlocksList *pUsrData)
{
    return Cli_ListBlocks(Client, pUsrData);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetAgBlockInfo(S7Object Client, int BlockType, int BlockNum, TS7IntBlockInfo *pIntBlkInfo, PLVString *pChrBlkInfo)
{
	TS7BlockInfo Info;
    int32_t StringSize = *pint32_t(*pChrBlkInfo);
    int32_t ChrBlkInfoSize = sizeof(TS7BlockInfo)-sizeof(TS7IntBlockInfo);
    pbyte pUsrStrings = pbyte(*pChrBlkInfo) + sizeof(int32_t);
    pbyte pBlkStrings = pbyte(&Info) + sizeof(TS7IntBlockInfo);
    if (StringSize>=ChrBlkInfoSize)
    {
        int Result=Cli_GetAgBlockInfo(Client, BlockType, BlockNum, &Info);
        if (Result==0)
        {
            memcpy(pIntBlkInfo, &Info, sizeof(TS7IntBlockInfo));
            memcpy(pUsrStrings, pBlkStrings, ChrBlkInfoSize);
        }
        return Result;
    }	
	else
        return errCliBufferTooSmall;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetPgBlockInfo(S7Object Client, TS7IntBlockInfo *pIntBlkInfo, PLVString *pChrBlkInfo, PLVString *pStringData, int BlockSize)
{
	int Result;
	TS7BlockInfo Info;
    int32_t StringSize = *pint32_t(*pChrBlkInfo);
    int32_t ChrBlkInfoSize = sizeof(TS7BlockInfo)-sizeof(TS7IntBlockInfo);
    pbyte pUsrStrings = pbyte(*pChrBlkInfo) + sizeof(int32_t);
    pbyte pBlkStrings = pbyte(&Info) + sizeof(TS7IntBlockInfo);
    // User Buffer
	int32_t Size = *pint32_t(*pStringData);
	pbyte pBlock=pbyte(*pStringData) + sizeof(int32_t);
    if (StringSize>=ChrBlkInfoSize)
    {
        Result = Cli_GetPgBlockInfo(Client, pBlock, &Info, BlockSize);
        if (Result==0)
        {
            memcpy(pIntBlkInfo, &Info, sizeof(TS7IntBlockInfo));
            memcpy(pUsrStrings, pBlkStrings, ChrBlkInfoSize);
        }
    }	
	else
        Result = errCliBufferTooSmall;
	
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ListBlocksOfType(S7Object Client, int BlockType, PAdaptToType1D *pArrayData, int &ItemsCount)
{  
	PS7BlocksOfType pUsrData=PS7BlocksOfType(pbyte(*pArrayData) + sizeof(int32_t));
    return Cli_ListBlocksOfType(Client, BlockType, pUsrData, &ItemsCount);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Upload(S7Object Client, int BlockType, int BlockNum, PLVString *pStringData, int &SizeGet)
{

    int32_t Size = *pint32_t(*pStringData);
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
	int Result=Cli_Upload(Client, BlockType, BlockNum, pUsrData, &Size);
    SizeGet=Size;
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_FullUpload(S7Object Client, int BlockType, int BlockNum, PLVString *pStringData, int &SizeGet)
{

    int32_t Size = *pint32_t(*pStringData);
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
	int Result=Cli_FullUpload(Client, BlockType, BlockNum, pUsrData, &Size);
    SizeGet=Size;
	return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Download(S7Object Client, int BlockNum, PLVString *pStringData, int Size)
{
    int32_t BufferSize = *pint32_t(*pStringData);
    if (BufferSize<Size)
        return errCliBufferTooSmall;
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
    return Cli_Download(Client, BlockNum, pUsrData, Size);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Delete(S7Object Client, int BlockType, int BlockNum)
{
    return Cli_Delete(Client, BlockType, BlockNum);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_DBFill(S7Object Client, int DBNumber, byte FillChar)
{
    return Cli_DBFill(Client, DBNumber, FillChar);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetPlcDateTime(S7Object Client, lv_timestamp *timestamp)
{
    tm DateTime;
    int Result=Cli_GetPlcDateTime(Client, &DateTime);
    if (Result==0)
    {
        timestamp->seconds=int64_t(mktime(&DateTime))+delta_epoch;
        timestamp->attoseconds=0;  
    }
    return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetPlcDateTime(S7Object Client, lv_timestamp *timestamp)
{
    time_t time_toset = time_t(timestamp->seconds - delta_epoch);
    struct tm * DateTime = localtime (&time_toset);
    return Cli_SetPlcDateTime(Client, DateTime);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetPlcSystemDateTime(S7Object Client)
{
    return Cli_SetPlcSystemDateTime(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetOrderCode(S7Object Client, PLVString *pStringData, byte &V1, byte &V2, byte &V3)
{
	int32_t StringSize = *pint32_t(*pStringData);
	PS7OrderCode Info=PS7OrderCode(pbyte(*pStringData) + sizeof(int32_t));
	if (StringSize<sizeof(TS7OrderCode))
		return errCliBufferTooSmall;
	else
	{
	    int Result = Cli_GetOrderCode(Client, Info);
		if (Result==0)
		{
			V1=Info->V1;
			V2=Info->V2;
			V3=Info->V3;
		}
		return Result;
	}
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetCpuInfo(S7Object Client, PLVString *pStringData)
{
	int32_t StringSize = *pint32_t(*pStringData);
	PS7CpuInfo Info=PS7CpuInfo(pbyte(*pStringData) + sizeof(int32_t));
	if (StringSize<sizeof(TS7CpuInfo))
		return errCliBufferTooSmall;
	else
		return Cli_GetCpuInfo(Client, Info);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetCpInfo(S7Object Client, TS7CpInfo *pUsrData)
{
	return Cli_GetCpInfo(Client, pUsrData);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ReadSZL(S7Object Client, int ID, int Index, word &LENTHDR, word &N_DR, PAdaptToType1D *pArrayData, int &Size)
{
	int32_t ArraySize = *pint32_t(*pArrayData);
    pbyte pUsrData=pbyte(*pArrayData) + sizeof(int32_t);
    TS7SZL SZL;
    int SZLSize = sizeof(TS7SZL);
    
    int Result = Cli_ReadSZL(Client, ID, Index, &SZL, &SZLSize);
    if (Result==0)
    {
        bool partial = SZLSize > ArraySize;

        if (partial) 
            Size = ArraySize;
        else
            Size = SZLSize;

        LENTHDR = SZL.Header.LENTHDR;
        N_DR = SZL.Header.N_DR;

        memcpy(pUsrData, &SZL.Data, Size);

        if (partial)
            Result = errCliBufferTooSmall;
    }
    return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ReadSZLList(S7Object Client, PAdaptToType1D *pArrayData, int &ItemsCount)
{
	int32_t ArrayCount = (*pint32_t(*pArrayData))/2;
    pbyte pUsrData=pbyte(*pArrayData) + sizeof(int32_t);
    TS7SZLList SZLList;
    int SZLListCount = (sizeof(TS7SZLList)-sizeof(SZL_HEADER))/2;

    int Result=Cli_ReadSZLList(Client, &SZLList, &SZLListCount);

    if (Result==0)
    {
        bool partial = SZLListCount > ArrayCount;
        if (partial) 
            ItemsCount = ArrayCount;
        else
            ItemsCount = SZLListCount;

        memcpy(pUsrData, &SZLList.List, ItemsCount * 2);

        if (partial)
            Result = errCliBufferTooSmall;
    }
    return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Cli_PlcHotStart(S7Object Client)
{
	return Cli_PlcHotStart(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_PlcColdStart(S7Object Client)
{
	return Cli_PlcColdStart(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_PlcStop(S7Object Client)
{
	return Cli_PlcStop(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_CopyRamToRom(S7Object Client, int Timeout)
{
	return Cli_CopyRamToRom(Client, Timeout);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_Compress(S7Object Client, int Timeout)
{
	return Cli_Compress(Client, Timeout);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetPlcStatus(S7Object Client, int &Status)
{
	return Cli_GetPlcStatus(Client, &Status);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetProtection(S7Object Client, TS7Protection *pUsrData)
{
    return Cli_GetProtection(Client, pUsrData);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_SetSessionPassword(S7Object Client, char *Password)
{
    return Cli_SetSessionPassword(Client, Password);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ClearSessionPassword(S7Object Client)
{
    return Cli_ClearSessionPassword(Client);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_IsoExchangeBuffer(S7Object Client, PLVString *pStringData, int &Size)
{
    int32_t BufferSize = *pint32_t(*pStringData);
    if (BufferSize<Size)
        return errCliBufferTooSmall;
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
    return Cli_IsoExchangeBuffer(Client, pUsrData, &Size);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetExecTime(S7Object Client, int &Time)
{
    return Cli_GetExecTime(Client, &Time);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetLastError(S7Object Client, int &LastError)
{
    return Cli_GetLastError(Client, &LastError);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_GetPduLength(S7Object Client, int &Requested, int &Negotiated)
{
    return Cli_GetPduLength(Client, &Requested, &Negotiated);
}
//---------------------------------------------------------------------------
int S7API lv_Cli_ErrorText(int Error, char *Text, int TxtLen)
{
	return Cli_ErrorText(Error, Text, TxtLen);
}
//***************************************************************************
// SERVER
//***************************************************************************
S7Object S7API lv_Srv_Create()
{
    return Srv_Create();
}
//---------------------------------------------------------------------------
void S7API lv_Srv_Destroy(S7Object &Server)
{
    Srv_Destroy(&Server);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_GetParam(S7Object Client, int ParamNumber, void *pValue)
{
    return Srv_GetParam(Client, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_SetParam(S7Object Client, int ParamNumber, void *pValue)
{
    return Srv_SetParam(Client, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_StartTo(S7Object Server, const char *Address)
{
    return Srv_StartTo(Server, Address);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_Start(S7Object Server)
{
	return Srv_Start(Server);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_Stop(S7Object Server)
{
	return Srv_Stop(Server);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_RegisterArea(S7Object Server, int AreaCode, word Index, PLVString *pStringData)
{
    int32_t Size = *pint32_t(*pStringData);
	pbyte pData=pbyte(*pStringData) + sizeof(int32_t);
	return Srv_RegisterArea(Server, AreaCode, Index, pData, Size);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_UnregisterArea(S7Object Server, int AreaCode, word Index)
{
	return Srv_UnregisterArea(Server, AreaCode, Index);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_LockArea(S7Object Server, int AreaCode, word Index)
{
	return Srv_LockArea(Server, AreaCode, Index);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_UnlockArea(S7Object Server, int AreaCode, word Index)
{
	return Srv_UnlockArea(Server, AreaCode, Index);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_GetStatus(S7Object Server, int &ServerStatus, int &CpuStatus, int &ClientsCount)
{
    return Srv_GetStatus(Server, &ServerStatus, &CpuStatus, &ClientsCount);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_SetCpuStatus(S7Object Server, int CpuStatus)
{
	return Srv_SetCpuStatus(Server, CpuStatus);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_ClearEvents(S7Object Server)
{
	return Srv_ClearEvents(Server);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_GetMask(S7Object Server, int MaskKind, longword &Mask)
{
	return Srv_GetMask(Server, mkLog, &Mask);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_SetMask(S7Object Server, int MaskKind, longword Mask)
{
	return Srv_SetMask(Server, mkLog, Mask);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_PickEvent(S7Object Server, TSrvEvent *pEvent, int &EvtReady)
{
	return Srv_PickEvent(Server, pEvent, &EvtReady);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_EventText(TSrvEvent &Event, char *Text, int TxtLen)
{
	return Srv_EventText(&Event, Text, TxtLen);
}
//---------------------------------------------------------------------------
int S7API lv_Srv_ErrorText(int Error, char *Text, int TxtLen)
{
	return Srv_ErrorText(Error, Text, TxtLen);
}

//***************************************************************************
// PARTNER
//***************************************************************************
S7Object S7API lv_Par_Create(int Active)
{
	return Par_Create(Active);
}
//---------------------------------------------------------------------------
void S7API lv_Par_Destroy(S7Object &Partner)
{
    Par_Destroy(&Partner);
}
//---------------------------------------------------------------------------
int S7API lv_Par_GetParam(S7Object Partner, int ParamNumber, void *pValue)
{
    return Par_GetParam(Partner, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Par_SetParam(S7Object Partner, int ParamNumber, void *pValue)
{
    return Par_SetParam(Partner, ParamNumber, pValue);
}
//---------------------------------------------------------------------------
int S7API lv_Par_StartTo(S7Object Partner, const char *LocalAddress, const char *RemoteAddress,
    word LocTsap, word RemTsap)
{
    return Par_StartTo(Partner, LocalAddress, RemoteAddress, LocTsap, RemTsap);
}
//---------------------------------------------------------------------------
int S7API lv_Par_Start(S7Object Partner)
{
    return Par_Start(Partner);
}
//---------------------------------------------------------------------------
int S7API lv_Par_Stop(S7Object Partner)
{
    return Par_Stop(Partner);
}
//---------------------------------------------------------------------------
int S7API lv_Par_BSend(S7Object Partner, longword R_ID, PLVString *pStringData, int Size)
{
    int32_t BufferSize = *pint32_t(*pStringData);
    if (BufferSize<Size)
        return errParBufferTooSmall;
	pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
    return Par_BSend(Partner, R_ID, pUsrData, Size);
}
//---------------------------------------------------------------------------
int S7API lv_Par_BRecv(S7Object Partner, longword &R_ID, PLVString *pStringData, int &Size, int &DataReady)
{
    byte Buffer[0x10000]; //64k buffer (max for S7400)
    int Result = Par_BRecv(Partner, &R_ID, &Buffer, &Size, 0); // Timeout=0, we don't want to wait
    if (Result==0)
    {
        int32_t BufferSize = *pint32_t(*pStringData);
        pbyte pUsrData=pbyte(*pStringData) + sizeof(int32_t);
        if (BufferSize<Size)
            Result=errParBufferTooSmall;
        else
            memcpy(pUsrData, &Buffer, Size);
    }
    DataReady=Result==0;
    if (Result==errParRecvTimeout) // for polling operation this is not an error
        Result=0;
    return Result;
}
//---------------------------------------------------------------------------
int S7API lv_Par_GetTimes(S7Object Partner, longword &SendTime, longword &RecvTime)
{
    return Par_GetTimes(Partner, &SendTime, &RecvTime);
}
//---------------------------------------------------------------------------
int S7API lv_Par_GetStats(S7Object Partner, longword &BytesSent, longword &BytesRecv,
    longword &SendErrors, longword &RecvErrors)
{
    return Par_GetStats(Partner, &BytesSent, &BytesRecv, &SendErrors, &RecvErrors);
}
//---------------------------------------------------------------------------
int S7API lv_Par_GetLastError(S7Object Partner, int &LastError)
{
    return Par_GetLastError(Partner, &LastError);
}
//---------------------------------------------------------------------------
int S7API lv_Par_GetStatus(S7Object Partner, int &Status)
{
    return Par_GetStatus(Partner, &Status);
}
//---------------------------------------------------------------------------
int S7API lv_Par_ErrorText(int Error, char *Text, int TxtLen)
{
    return Par_ErrorText(Error, Text, TxtLen);
}


#pragma pack()