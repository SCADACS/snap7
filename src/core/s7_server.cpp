/*=============================================================================|
|  PROJECT SNAP7                                                         1.3.0 |
|==============================================================================|
|  Copyright (C) 2013, 2015 Davide Nardella                                    |
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
|=============================================================================*/
#include "s7_server.h"
#include "s7_firmware.h"
const byte BitMask[8] = {0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80};

//---------------------------------------------------------------------------
void FillTime(PS7Time PTime)
{
    time_t Now;
    struct timespec ts;
    int ms;

    time(&Now);
    struct tm *DT = localtime(&Now);

    clock_gettime(CLOCK_REALTIME, &ts);
    ms = ts.tv_nsec / 1000000;

    PTime->bcd_year=BCD(DT->tm_year-100);
    PTime->bcd_mon =BCD(DT->tm_mon+1);
    PTime->bcd_day =BCD(DT->tm_mday);
    PTime->bcd_hour=BCD(DT->tm_hour);
    PTime->bcd_min =BCD(DT->tm_min);
    PTime->bcd_sec =BCD(DT->tm_sec);
    PTime->bcd_himsec=BCD(word(ms / 10)); // first 2 ms digits, last is in dow
    PTime->bcd_dow =BCD((ms % 10)*10 + DT->tm_wday);
}
//------------------------------------------------------------------------------
// AREA CONTAINER CLASS
//------------------------------------------------------------------------------
PS7AreaContainer::PS7AreaContainer(size_t size) : size(size) {
    area = new PS7Area[size];
    memset(area, 0, size);
    count = 0;
    limit = 0;
}
PS7AreaContainer::~PS7AreaContainer() {
    Dispose();
}
PS7Area PS7AreaContainer::Find(word Number) {
    int index = IndexOf(Number);
    return index < 0 ? NULL : area[index];
}
int PS7AreaContainer::FindFirstFree() {
    int c;
    for (c=0; c < size; c++)
    {
        if (area[c]==NULL)
            return c;
    }
    return -1;
}
int PS7AreaContainer::IndexOf(word Number) {
    int c;
    int max=limit+1;

    for (c=0; c<max; c++)
    {
        if (area[c]!=NULL)
        {
            if (area[c]->Number==Number)
            {
                return c;
            }
        }
    }
    return -1;
}
PS7Area* PS7AreaContainer::get() {
    return area;
}
int PS7AreaContainer::Register(word Number, void* pUsrData, word Size) {
    PS7Area TheArea;
    int index;

    if (pUsrData==NULL)
        return errSrvDBNullPointer;

    if (Find(Number)!=NULL)
        return errSrvAreaAlreadyExists;

    index=FindFirstFree();
    if (index==-1)
        return errSrvTooManyDB;

    TheArea =new TS7Area;
    TheArea->Number=Number;
    TheArea->cs=new TSnapCriticalSection();
    TheArea->PData=pbyte(pUsrData);
    TheArea->Size=Size;
    area[index]=TheArea;
    count++;
    if (limit<index)
        limit=index;
    return 0;
}
int PS7AreaContainer::Unregister(word Number) {
    PS7Area TheDB;
    size_t index = IndexOf(Number);
    if (index==-1)
        return errSrvInvalidParams;

    // Unregister should be done with the server in stop mode
    // however we can minimize the risk...
    TheDB=area[index];
    area[index]=NULL;
    if (TheDB->cs!=NULL)
        delete TheDB->cs;
    delete TheDB;
    count--;

    return 0;
}
void PS7AreaContainer::Dispose() {
    PS7Area TheDB;
    int c;
    // Unregister DBs
    for (c = 0; c < size; c++)
    {
        if (area[c]!=NULL)
        {
            // Unregister should be done with the server in stop mode
            // however we can minimize the risk...
            TheDB=area[c];
            area[c]=NULL;
            if (TheDB->cs!=0)
                    delete TheDB->cs;
            delete TheDB;
        }
    }
    count=0;
    limit=0;
    delete area;
}
//------------------------------------------------------------------------------
// ISO/TCP WORKER  CLASS
//------------------------------------------------------------------------------
bool TIsoTcpWorker::IsoPerformCommand(int &Size)
{
    return true;
}
//---------------------------------------------------------------------------
bool TIsoTcpWorker::ExecuteSend()
{
    return true;
}
//---------------------------------------------------------------------------
bool TIsoTcpWorker::ExecuteRecv()
{
    TPDUKind PduKind;
    int PayloadSize;

    if (CanRead(WorkInterval)) // should be Small to avoid time wait during the close
    {
        isoRecvPDU(&PDU);
        if (LastTcpError==0)
        {
            IsoPeek(&PDU,PduKind);
            // First check valid data incoming (most likely situation)
            if (PduKind==pkValidData)
            {
                PayloadSize=PDUSize(&PDU)-DataHeaderSize;
                return IsoPerformCommand(PayloadSize);
            };
            // Connection request incoming
            if (PduKind==pkConnectionRequest)
            {
                IsoConfirmConnection(pdu_type_CC); // <- Connection confirm
                return LastTcpError!=WSAECONNRESET;
            };
            // Disconnect request incoming (only for isotcp full complient equipment, not S7)
            if (PduKind==pkDisconnectRequest)
            {
                IsoConfirmConnection(pdu_type_DC); // <- Disconnect confirm
                return false;
            };
            // Empty fragment, maybe an ACK
            if (PduKind==pkEmptyFragment)
            {
                PayloadSize=0;
                return IsoPerformCommand(PayloadSize);
            };
            // Valid PDU format but we have to discard it
            if (PduKind==pkUnrecognizedType)
            {
                return LastTcpError!=WSAECONNRESET;
            };
            // Here we have an Invalid PDU
            Purge();
            return true;
        }
        else
            return LastTcpError!=WSAECONNRESET;
    }
    else
        return true;
}
//---------------------------------------------------------------------------
bool TIsoTcpWorker::Execute()
{
    return ExecuteSend() && ExecuteRecv();
}
//------------------------------------------------------------------------------
// S7 WORKER CLASS
//------------------------------------------------------------------------------
TS7Worker::TS7Worker()
{
    // We skip RFC/ISO header, our PDU is the payload
    PDUH_in   =PS7ReqHeader(&PDU.Payload);
    FPDULength=2048;
    DBCnt     =0;
    LastBlk   =Block_DB;
}

bool TS7Worker::ExecuteRecv()
{
    WorkInterval=FServer->WorkInterval;
    return TIsoTcpWorker::ExecuteRecv();
}
//------------------------------------------------------------------------------
bool TS7Worker::CheckPDU_in(int PayloadSize)
{
    // Checks the size : packet size must match with header infos
    int Size=SwapWord(PDUH_in->ParLen)+SwapWord(PDUH_in->DataLen)+ReqHeaderSize;
    if (Size!=PayloadSize)
        return false;
    // Checks PDUType : must be 1 or 7
    if ((PDUH_in->PDUType!=PduType_request) &&
        (PDUH_in->PDUType!=PduType_userdata))
        return false;
    else
        return true;
}
//------------------------------------------------------------------------------
byte TS7Worker::BCD(word Value)
{
    return ((Value / 10) << 4) + (Value % 10);
}
//------------------------------------------------------------------------------
void TS7Worker::FillTime(PS7Time PTime)
{
    time_t Now;
    time(&Now);
    struct tm *DT = localtime (&Now);

    PTime->bcd_year=BCD(DT->tm_year-100);
    PTime->bcd_mon =BCD(DT->tm_mon+1);
    PTime->bcd_day =BCD(DT->tm_mday);
    PTime->bcd_hour=BCD(DT->tm_hour);
    PTime->bcd_min =BCD(DT->tm_min);
    PTime->bcd_sec =BCD(DT->tm_sec);
    PTime->bcd_himsec=0;
    PTime->bcd_dow =BCD(DT->tm_wday);
}
//------------------------------------------------------------------------------
void TS7Worker::DoEvent(longword Code, word RetCode, word Param1, word Param2,
  word Param3, word Param4)
{
    FServer->DoEvent(ClientHandle,Code,RetCode,Param1,Param2,Param3,Param4);
}
//------------------------------------------------------------------------------
void TS7Worker::DoReadEvent(longword Code, word RetCode, word Param1, word Param2,
  word Param3, word Param4)
{
    FServer->DoReadEvent(ClientHandle,Code,RetCode,Param1,Param2,Param3,Param4);
}
//------------------------------------------------------------------------------
void TS7Worker::FragmentSkipped(int Size)
{
// do nothing could be used for debug purpose
}
//------------------------------------------------------------------------------
bool TS7Worker::IsoPerformCommand(int &Size)
{
    // Checks for Ack fragment
    if (Size==0)
        return PerformPDUAck(Size);
    // First checks PDU consistence
    if (CheckPDU_in(Size))
    {
        switch (PDUH_in->PDUType)
        {
            case PduType_request    : return PerformPDURequest(Size);
            case PduType_userdata   : return PerformPDUUsrData(Size);
        }
    }
    else
        DoEvent(evcPDUincoming, evrMalformedPDU, Size, 0, 0, 0);
    return false;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformPDUAck(int &Size)
{
    // here we could keep track of ack empty fragment for debug purpose
    return true;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformPDURequest(int &Size)
{
    pbyte P;
    byte PDUFun;
    bool Result = true;

    // We have to store PDUfun since it will be overwritten
    P = pbyte(PDUH_in)+ReqHeaderSize;
    PDUFun=*P;
    // Watches the function
    switch (PDUFun)
    {
        case pduFuncRead    : Result=PerformFunctionRead();
             break;
        case pduFuncWrite   : Result=PerformFunctionWrite();
             break;
        case pduNegotiate   : Result=PerformFunctionNegotiate();
             break;
        case pduStart       :
        case pduStop        : Result=PerformFunctionControl(PDUFun);
             break;
        case pduStartUpload :
        case pduUpload      :
        case pduEndUpload   : Result=PerformFunctionUpload();
             break;
        case pduReqDownload : Result=PerformFunctionDownload();
             break;
        // <-- Further (custom) functions can be added here
        default:
             DoEvent(evcPDUincoming, evrCannotHandlePDU, Size, 0, 0, 0);
    };
    return Result;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformPDUUsrData(int &Size)
{
    PS7ReqParams7 ReqParams;
    byte Tg, SubFun;
    bool Result = true;
    // Set Pointer to request params
    ReqParams=PS7ReqParams7(pbyte(PDUH_in)+ReqHeaderSize);
    Tg=ReqParams->Tg;
    SubFun=ReqParams->SubFun;
    // Switch type_group
    switch (Tg)
    {
      case grProgrammer : Result=PerformGroupProgrammer();
          break;
      case grCyclicData : Result=PerformGroupCyclicData();
          break;
      case grBlocksInfo : Result=PerformGroupBlockInfo();
          break;
      case grSZL        : Result=PerformGroupSZL();
          break;
      case grPassword   : Result=PerformGroupSecurity();
          break;
      case grClock      : switch (SubFun)
                         {
                             case 0x01 : Result=PerformGetClock();
                                 break;
                             case 0x02 : Result=PerformSetClock();
                                 break;
                         };
                         break;
      default:
          DoEvent(evcPDUincoming, evrInvalidGroupUData, Tg, 0, 0, 0);
    };
    return Result;
}
//------------------------------------------------------------------------------
int TS7Worker::DataSizeByte(int WordLength)
{
	switch (WordLength){
		case S7WLBit     : return 1;  // S7 sends 1 byte per bit
		case S7WLByte    : return 1;
		case S7WLChar    : return 1;
		case S7WLWord    : return 2;
		case S7WLDWord   : return 4;
		case S7WLInt     : return 2;
		case S7WLDInt    : return 4;
		case S7WLReal    : return 4;
		case S7WLCounter : return 2;
		case S7WLTimer   : return 2;
		default          : return 0;
     }
}
//==============================================================================
// FUNCTION READ
//==============================================================================
word TS7Worker::RA_NotFound(PResFunReadItem ResItem, TEv &EV)
{
    ResItem->DataLength=SwapWord(0x0004);
    ResItem->ReturnCode=Code7ResItemNotAvailable;
    ResItem->TransportSize=0x00;
    EV.EvRetCode=evrErrAreaNotFound;
    return 0;
}
//------------------------------------------------------------------------------
word TS7Worker::RA_OutOfRange(PResFunReadItem ResItem, TEv &EV)
{
    ResItem->DataLength=SwapWord(0x0004);
    ResItem->ReturnCode=Code7AddressOutOfRange;
    ResItem->TransportSize=0x00;
    EV.EvRetCode=evrErrOutOfRange;
    return 0;
}
//------------------------------------------------------------------------------
word TS7Worker::RA_SizeOverPDU(PResFunReadItem ResItem, TEv &EV)
{
    ResItem->DataLength=SwapWord(0x0004);
    ResItem->ReturnCode=byte(SwapWord(Code7DataOverPDU));
    ResItem->TransportSize=0x00;
    EV.EvRetCode=evrErrOverPDU;
    return 0;
}
//------------------------------------------------------------------------------
PS7Area TS7Worker::GetArea(byte S7Code, word index)
{
    switch(S7Code)
    {
    case S7AreaPE : return FServer->HA[srvAreaPE];
    case S7AreaPA : return FServer->HA[srvAreaPA];
    case S7AreaMK : return FServer->HA[srvAreaMK];
    case S7AreaCT : return FServer->HA[srvAreaCT];
    case S7AreaTM : return FServer->HA[srvAreaTM];
    case S7AreaDB : return FServer->DBArea->Find(index);
    default       : return NULL;
    };
}
//------------------------------------------------------------------------------
word TS7Worker::ReadArea(PResFunReadItem ResItemData, PReqFunReadItem ReqItemPar,
     int &PDURemainder, TEv &EV)
{
    PS7Area P;
	word DBNum, Elements;
    longword Start, Size, ASize, AStart;
    longword *PAdd;
    byte BitIndex, ByteVal;
	int Multiplier;
    void *Source;
    PSnapCriticalSection pcs;

    P=NULL;
    EV.EvStart   =0;
    EV.EvSize    =0;
    EV.EvRetCode =0;
    EV.EvIndex   =0;

    EV.EvArea=ReqItemPar->Area;
    // Get Pointer to selected Area

	if (ReqItemPar->Area==S7AreaDB)
	{
        DBNum=SwapWord(ReqItemPar->DBNumber);
        EV.EvIndex=DBNum;
	};

	if (!FServer->ResourceLess)
	{
		P = GetArea(ReqItemPar->Area, DBNum);
		if (P == NULL)
			return RA_NotFound(ResItemData, EV);
	}

    // Calcs the amount
	Multiplier = DataSizeByte(ReqItemPar->TransportSize);
	if (Multiplier==0)
		return RA_OutOfRange(ResItemData, EV);

    // Checks timers/counters coherence
    if ((ReqItemPar->Area==S7AreaTM) ^ (ReqItemPar->TransportSize==S7WLTimer))
        return RA_OutOfRange(ResItemData, EV);

    if ((ReqItemPar->Area==S7AreaCT) ^ (ReqItemPar->TransportSize==S7WLCounter))
        return RA_OutOfRange(ResItemData, EV);

    // Calcs size
	Elements = SwapWord(ReqItemPar->Length);
	Size=Multiplier*Elements;
	EV.EvSize=Size;

    // The sum of the items must not exceed the PDU size negotiated
    if (PDURemainder-Size<=0)
        return RA_SizeOverPDU(ResItemData, EV);
    else
        PDURemainder-=Size;

    // More then 1 bit is not supported by S7 CPU
    if ((ReqItemPar->TransportSize==S7WLBit) && (Size>1))
        return RA_OutOfRange(ResItemData, EV);

	// Calcs the start point
    PAdd=(longword*)(&ReqItemPar->Area);   // points to area since we need 4 bytes for a pointer
    Start=SwapDWord(*PAdd & 0xFFFFFF00);

    // Checks if the address is not multiple of 8 when transport size is neither bit nor timer nor counter
    if (
		(ReqItemPar->TransportSize!=S7WLBit) &&
		(ReqItemPar->TransportSize!=S7WLTimer) &&
		(ReqItemPar->TransportSize!=S7WLCounter) &&
		((Start % 8) !=0)
	   )
		return RA_OutOfRange(ResItemData, EV);

    // AStart is only for callback
	if ((ReqItemPar->TransportSize != S7WLBit) && (ReqItemPar->TransportSize != S7WLCounter) && (ReqItemPar->TransportSize != S7WLTimer))
		AStart = Start >> 3;
	else
		AStart = Start;

	if ((ReqItemPar->TransportSize == S7WLCounter) || (ReqItemPar->TransportSize == S7WLTimer))
	{
		Start = Start >> 1;   // 1 Timer or Counter = 2 bytes
	}
	else
	{
		BitIndex  =Start & 0x07; // start bit
		Start     =Start >> 3;   // start byte
	}

	EV.EvStart=Start;

	// Checks bounds
	if (!FServer->ResourceLess)
	{
		ASize = P->Size; // Area size
		if (Start + Size > ASize)
			return RA_OutOfRange(ResItemData, EV);
		Source = P->PData + Start;
	}

	// Read Event (before copy data)
    DoReadEvent(evcDataRead,0,EV.EvArea,EV.EvIndex,EV.EvStart,EV.EvSize);

	if (FServer->ResourceLess)
	{
		memset(&ResItemData->Data, 0, IsoPayload_Size - 17);
		if (!FServer->DoReadArea(ClientHandle, EV.EvArea, EV.EvIndex, AStart, Elements, ReqItemPar->TransportSize, &ResItemData->Data))
			return RA_NotFound(ResItemData, EV);
	}
	else
	{
		// Lock the area
		pcs = P->cs;
		pcs->Enter();
		// Get Data
		memcpy(&ResItemData->Data, Source, Size);
		// Unlock the area
		pcs->Leave();
	}

    ResItemData->ReturnCode=0xFF;
    // Set Result transport size and, for bit, performs the mask
    switch (ReqItemPar->TransportSize)
    {
      case S7WLBit:
        {
          ByteVal=ResItemData->Data[0];

          if ((ByteVal & BitMask[BitIndex])!=0)
              ResItemData->Data[0]=0x01;
          else
              ResItemData->Data[0]=0x00;

          ResItemData->TransportSize=TS_ResBit;
          ResItemData->DataLength=SwapWord(Size);
        };break;
      case S7WLByte:
	  case S7WLWord:
	  case S7WLDWord:
        {
          ResItemData->TransportSize=TS_ResByte;
          ResItemData->DataLength=SwapWord(Size*8);
        };break;
	  case S7WLInt:
	  case S7WLDInt:
        {
          ResItemData->TransportSize=TS_ResInt;
          ResItemData->DataLength=SwapWord(Size*8);
        };break;
      case S7WLReal:
        {
          ResItemData->TransportSize=TS_ResReal;
          ResItemData->DataLength=SwapWord(Size);
        };break;
      case S7WLChar:
      case S7WLTimer:
      case S7WLCounter:
        {
          ResItemData->TransportSize=TS_ResOctet;
          ResItemData->DataLength=SwapWord(Size);
        };break;
      default :
        {
          ResItemData->TransportSize=TS_ResByte;
          ResItemData->DataLength=SwapWord(Size*8);
        };break;
    }
    EV.EvRetCode=evrNoError;
    return Size;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformFunctionRead()
{
    PReqFunReadParams ReqParams;
    PResFunReadParams ResParams;
    TResFunReadData   ResData;
    TS7Answer23       Answer;
    uintptr_t         Offset;
    word ItemSize;
    int ItemsCount, c,
    TotalSize,
    PDURemainder;
    TEv EV;

	PDURemainder=FPDULength;
    // Stage 1 : Setup pointers and initial check
	ReqParams=PReqFunReadParams(pbyte(PDUH_in)+sizeof(TS7ReqHeader));
    ResParams=PResFunReadParams(pbyte(&Answer)+ResHeaderSize23);        // Params after the header

    // trunk to 20 max items.
    if (ReqParams->ItemsCount>MaxVars)
        ReqParams->ItemsCount=MaxVars;

    ItemsCount=ReqParams->ItemsCount;

    // Stage 2 : gather data
    Offset=sizeof(TResFunReadParams);      // = 2

    for (c = 0; c < ItemsCount; c++)
	{
		ResData[c]=PResFunReadItem(pbyte(ResParams)+Offset);
		ItemSize=ReadArea(ResData[c],&ReqParams->Items[c],PDURemainder, EV);

        // S7 doesn't xfer odd byte amount
        if ((c<ItemsCount-1) && (ItemSize % 2 != 0))
	      ItemSize++;

        Offset+=(ItemSize+4);
        // For multiple items we have to create multiple events
        if (ItemsCount>1)
            DoEvent(evcDataRead,EV.EvRetCode,EV.EvArea,EV.EvIndex,EV.EvStart,EV.EvSize);
    }
    // Stage 3 : finalize the answer and send the packet
    Answer.Header.P=0x32;
    Answer.Header.PDUType=0x03;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen=SwapWord(sizeof(TResFunReadParams));
    Answer.Header.Error=0x0000; // this is zero, we will find the error in ResData.ReturnCode
    Answer.Header.DataLen=SwapWord(word(Offset)-2);

    ResParams->FunRead  =ReqParams->FunRead;
    ResParams->ItemCount=ReqParams->ItemsCount;

    TotalSize=ResHeaderSize23+int(Offset);
    isoSendBuffer(&Answer, TotalSize);

    // For single item (most likely case) it's better to work with the event after
    // we sent the answer
    if (ItemsCount==1)
        DoEvent(evcDataRead,EV.EvRetCode,EV.EvArea,EV.EvIndex,EV.EvStart,EV.EvSize);

    return true;
}
//==============================================================================
// FUNCTION WRITE
//==============================================================================
byte TS7Worker::WA_NotFound(TEv &EV)
{
	EV.EvRetCode=evrErrAreaNotFound;
    return Code7ResItemNotAvailable;
}
//------------------------------------------------------------------------------
byte TS7Worker::WA_InvalidTransportSize(TEv &EV)
{
    EV.EvRetCode=evrErrTransportSize;
    return Code7InvalidTransportSize;
}
//------------------------------------------------------------------------------
byte TS7Worker::WA_OutOfRange(TEv &EV)
{
    EV.EvRetCode=evrErrOutOfRange;
    return Code7AddressOutOfRange;
}
//------------------------------------------------------------------------------
byte TS7Worker::WA_DataSizeMismatch(TEv &EV)
{
    EV.EvRetCode=evrDataSizeMismatch;
    return Code7WriteDataSizeMismatch;
}
//------------------------------------------------------------------------------
byte TS7Worker::WriteArea(PReqFunWriteDataItem ReqItemData, PReqFunWriteItem ReqItemPar,
     TEv &EV)
{
	int Multiplier;
    PS7Area P = NULL;
	word DBNum, Elements;
    longword *PAdd;
	PSnapCriticalSection pcs;
	longword Start, Size, ASize, DataLen, AStart;
	pbyte Target;
	byte BitIndex;

    EV.EvStart   =0;
	EV.EvSize    =0;
    EV.EvRetCode =evrNoError;
    EV.EvIndex   =0;

    EV.EvArea=ReqItemPar->Area;
    // Get Pointer to selected Area
	if (ReqItemPar->Area==S7AreaDB)
	{
		DBNum=SwapWord(ReqItemPar->DBNumber);
		EV.EvIndex=DBNum;
	};

	if (!FServer->ResourceLess)
	{
		P=GetArea(ReqItemPar->Area, DBNum);
		if (P==NULL)
			return WA_NotFound(EV);
	}

    // Calcs the amount
	Multiplier = DataSizeByte(ReqItemPar->TransportSize);
	if (Multiplier==0)
		return WA_InvalidTransportSize(EV);

    // Checks timers/counters coherence
    if ((ReqItemPar->Area==S7AreaTM) ^ (ReqItemPar->TransportSize==S7WLTimer))
        return WA_OutOfRange(EV);

	if ((ReqItemPar->Area==S7AreaCT) ^ (ReqItemPar->TransportSize==S7WLCounter))
        return WA_OutOfRange(EV);

	// Calcs size
	Elements = SwapWord(ReqItemPar->Length);
	Size = Multiplier*Elements;
    EV.EvSize=Size;

    // More) 1 bit is not supported by S7 CPU
    if ((ReqItemPar->TransportSize==S7WLBit) && (Size>1))
        return WA_OutOfRange(EV);

    // Calcs the start point ??
    PAdd=(longword*)&ReqItemPar->Area;   // points to area since we need 4 bytes for a pointer
    Start=SwapDWord(*PAdd & 0xFFFFFF00);

    // Checks if the address is not multiple of 8 when transport size is neither bit nor timer nor counter
    if (
		(ReqItemPar->TransportSize!=S7WLBit) &&
		(ReqItemPar->TransportSize!=S7WLTimer) &&
		(ReqItemPar->TransportSize!=S7WLCounter) &&
		((Start % 8) !=0)
	   )
		return WA_OutOfRange(EV);

	// AStart is only for callback
	if ((ReqItemPar->TransportSize != S7WLBit) && (ReqItemPar->TransportSize != S7WLCounter) && (ReqItemPar->TransportSize != S7WLTimer))
		AStart = Start >> 3;
	else
		AStart = Start;

	if ((ReqItemPar->TransportSize == S7WLCounter) || (ReqItemPar->TransportSize == S7WLTimer))
	{
		Start = Start >> 1;   // 1 Timer or Counter = 2 bytes
	}
	else
	{
		BitIndex = Start & 0x07; // start bit
		Start = Start >> 3;   // start byte
	}
	EV.EvStart =Start;

	if (!FServer->ResourceLess)
	{
		// Checks bounds
		ASize = P->Size; // Area size
		if (Start + Size > ASize)
			return WA_OutOfRange(EV);
		Target = pbyte(P->PData + Start);
	}
    // Checks data size coherence
    DataLen=SwapWord(ReqItemData->DataLength);

	if ((ReqItemData->TransportSize!=TS_ResOctet) && (ReqItemData->TransportSize!=TS_ResReal) && (ReqItemData->TransportSize!=TS_ResBit))
		DataLen=DataLen / 8;

	if (DataLen!=Size)
        return WA_DataSizeMismatch(EV);

	if (FServer->ResourceLess)
	{
		if (!FServer->DoWriteArea(ClientHandle, EV.EvArea, EV.EvIndex, AStart, Elements, ReqItemPar->TransportSize, &ReqItemData->Data[0]))
			return WA_NotFound(EV);
	}
	else
	{
		if (ReqItemPar->TransportSize==S7WLBit)
		{
		  if ((ReqItemData->Data[0] & 0x01) != 0)   // bit set
			  *Target=*Target | BitMask[BitIndex];
		  else                                      // bit reset
			  *Target=*Target & (~BitMask[BitIndex]);
		}
		else {
		  // Lock the area
			pcs = P->cs;
			pcs->Enter();
			// Write Data
			memcpy(Target, &ReqItemData->Data[0], Size);
			pcs->Leave();
		};
	}

	return 0xFF;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformFunctionWrite()
{
    PReqFunWriteParams ReqParams;
    TReqFunWriteData ReqData;
    PResFunWrite ResData;
    TS7Answer23 Answer;
	int L;

	uintptr_t StartData;
	int c, ItemsCount;
	int ResDSize;
	TEv EV;

	// Stage 1 : Setup pointers and initial check
	ReqParams=PReqFunWriteParams(pbyte(PDUH_in)+sizeof(TS7ReqHeader));
	ResData  =PResFunWrite(pbyte(&Answer)+ResHeaderSize23);

	StartData=sizeof(TS7ReqHeader)+SwapWord(PDUH_in->ParLen);

	ItemsCount=ReqParams->ItemsCount;
	ResDSize  =ResHeaderSize23+2+ItemsCount;
	for (c = 0; c < ItemsCount; c++)
	{
		ReqData[c]=PReqFunWriteDataItem(pbyte(PDUH_in)+StartData);

		if ((ReqParams->Items[c].TransportSize == S7WLTimer) || (ReqParams->Items[c].TransportSize == S7WLCounter) || (ReqParams->Items[c].TransportSize == S7WLBit))
			L = SwapWord(ReqData[c]->DataLength);
		else
			L = (SwapWord(ReqData[c]->DataLength) / 8);

		StartData+=L+4;
		// the datalength is always even
		if ( L % 2 != 0) StartData++;
	}

	ResData->FunWrite =pduFuncWrite;
	ResData->ItemCount=ReqParams->ItemsCount;

	// Stage 2 : Write data
	for (c = 0; c < ItemsCount; c++)
	{
	  ResData->Data[c]=WriteArea(ReqData[c],&ReqParams->Items[c], EV);
      // For multiple items we have to create multiple events
      if (ItemsCount>1)
           DoEvent(evcDataWrite,EV.EvRetCode,EV.EvArea,EV.EvIndex,EV.EvStart,EV.EvSize);
    }

    // Stage 3 : finalize the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=0x03;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen=SwapWord(0x02);
    Answer.Header.Error=0x0000; // this is zero, we will find the error in ResData.ReturnCode if any
    Answer.Header.DataLen=SwapWord(ItemsCount);

    isoSendBuffer(&Answer,ResDSize);
    // For single item (most likely case) it's better to fire the event after
    // we sent the answer
    if (ItemsCount==1)
        DoEvent(evcDataWrite,EV.EvRetCode,EV.EvArea,EV.EvIndex,EV.EvStart,EV.EvSize);
    return true;
}
//==============================================================================
// FUNCTION NEGOTIATE
//==============================================================================
bool TS7Worker::PerformFunctionNegotiate()
{
	PReqFunNegotiateParams ReqParams;
	PResFunNegotiateParams ResParams;
	word ReqLen;
	TS7Answer23 Answer;
	int Size;

	// Setup pointers
	ReqParams=PReqFunNegotiateParams(pbyte(PDUH_in)+sizeof(TS7ReqHeader));
	ResParams=PResFunNegotiateParams(pbyte(&Answer)+sizeof(TS7ResHeader23));
	// Prepares the answer
	Answer.Header.P=0x32;
	Answer.Header.PDUType=0x03;
	Answer.Header.AB_EX=0x0000;
	Answer.Header.Sequence=PDUH_in->Sequence;
	Answer.Header.ParLen=SwapWord(sizeof(TResFunNegotiateParams));
	Answer.Header.DataLen=0x0000;
	Answer.Header.Error=0x0000;
	// Params point at the end of the header
	ResParams->FunNegotiate=pduNegotiate;
	ResParams->Unknown=0x0;
	// We offer the same
	ResParams->ParallelJobs_1=ReqParams->ParallelJobs_1;
	ResParams->ParallelJobs_2=ReqParams->ParallelJobs_2;

	if (FServer->ForcePDU == 0)
	{
		ReqLen = SwapWord(ReqParams->PDULength);
		if (ReqLen<MinPduSize)
			ResParams->PDULength = SwapWord(MinPduSize);
		else
			if (ReqLen>IsoPayload_Size)
				ResParams->PDULength = SwapWord(IsoPayload_Size);
			else
				ResParams->PDULength = ReqParams->PDULength;
	}
	else
		ResParams->PDULength = SwapWord(FServer->ForcePDU);

	FPDULength=SwapWord(ResParams->PDULength); // Stores the value
	// Sends the answer
	Size=sizeof(TS7ResHeader23) + sizeof(TResFunNegotiateParams);
	isoSendBuffer(&Answer, Size);
	// Store the event
	DoEvent(evcNegotiatePDU, evrNoError, FPDULength, 0, 0, 0);
	return true;
}
//==============================================================================
// FUNCTION CONTROL
//==============================================================================
bool TS7Worker::PerformFunctionControl(byte PduFun)
{
    TS7Answer23 Answer;
    PResFunCtrl ResParams;
    word ParLen;
    word CtrlCode;

    // Setup pointer
    ResParams=PResFunCtrl(pbyte(&Answer)+sizeof(TS7ResHeader23));
    // Prepares the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=0x03;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen=SwapWord(0x0001); // We send only Res fun without para
    Answer.Header.DataLen=0x0000;
    Answer.Header.Error=0x0000;
    ResParams->ResFun=PduFun;
    ResParams->para  =0x00;

    ParLen=SwapWord(PDUH_in->ParLen);
    if (PduFun==pduStop)
      CtrlCode=CodeControlStop;
    else
    {
      switch (ParLen)
      {
        case 16 : CtrlCode=CodeControlCompress;  break;
        case 18 : CtrlCode=CodeControlCpyRamRom; break;
        case 20 : CtrlCode=CodeControlWarmStart; break;
        case 22 : CtrlCode=CodeControlColdStart; break;
        case 26 : CtrlCode=CodeControlInsDel;    break;
        default : CtrlCode=CodeControlUnknown;
      }
    }
    // Sends the answer
    isoSendBuffer(&Answer,sizeof(TS7ResHeader23)+1);
    // Stores the event
    DoEvent(evcControl,0,CtrlCode,0,0,0);

    if ((CtrlCode==CodeControlWarmStart) || (CtrlCode==CodeControlColdStart))
        FServer->CpuStatus=S7CpuStatusRun;

    if (CtrlCode==CodeControlStop)
        FServer->CpuStatus=S7CpuStatusStop;

    return true;
}
//==============================================================================
// FUNCTION UPLOAD
//==============================================================================
// TODO need proper error handling
bool TS7Worker::PerformFunctionUpload()
{
    TS7Answer23 Answer;
    PReqFunStartUploadParams ReqStartParams;
    PResFunStartUploadParams ResStartParams;
    PReqFunUploadParams ReqParams;
    PResFunUploadParams ResParams;
    PResFunEndUploadParams ResEndParams;
    byte AsciiBlk[5];
    byte BlkType;
    word BlkNum;
    word RetCode;
    // XXX despite we negotiate 480 byte PDUs, TIA seems not to accept them for upload... 240 works
    //size_t maxDataSize = FPDULength - sizeof(TS7ResHeader23) - sizeof(TResFunUploadParams) - 4;
    size_t maxDataSize = 240 - sizeof(TS7ResHeader23) - sizeof(TResFunUploadParams) - 4;
    PS7Area area;


    ReqStartParams = PReqFunStartUploadParams(pbyte(PDUH_in) + sizeof(TS7ReqHeader));
    memcpy(AsciiBlk,ReqStartParams->AsciiBlk,sizeof(AsciiBlk));
    BlkType = ReqStartParams->BlkType;
    BlkNum = AsciiToNum(AsciiBlk, sizeof(AsciiBlk));

    DoEvent(evcUpload,0,BlkType,BlkNum,0,0);
    area = FServer->getArea(BlkType)->Find(BlkNum);

    if (!area) {
        // TODO reply with proper error
        return false;
    }


    Answer.Header.P=0x32;
    Answer.Header.PDUType =PduType_response;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen=SwapWord(sizeof(TResFunStartUploadParams));
    Answer.Header.DataLen=0;
    Answer.Header.Error=0;
    ResStartParams= PResFunStartUploadParams(Answer.ResData);
    ResStartParams->FunSUpld= pduStartUpload;
    memset(ResStartParams->Data_1, 0, sizeof(ResStartParams->Data_1));
    ResStartParams->Data_1[1]= 0x01;
    ResStartParams->Upload_ID = 0x07;
    ResStartParams->Uk[0]= 0x07;
    ResStartParams->Uk[1]= 0x30;
    ResStartParams->Uk[2]= 0x30;


    NumToAscii(ResStartParams->LenLoad, area->Size, sizeof(ResStartParams->LenLoad));

    isoSendBuffer(&Answer,sizeof(TS7ResHeader23)+sizeof(TResFunStartUploadParams));


    Answer.Header.ParLen= SwapWord(sizeof(TResFunUploadParams));
    ResParams= PResFunUploadParams(Answer.ResData);
    ResParams->FunUpld= pduUpload;
    ResParams->EoU = 0x01;

    Answer.ResData[2] = 0x00;
    Answer.ResData[3] = 0xDE;
    Answer.ResData[4] = 0x00;
    Answer.ResData[5] = 0xFB;

    size_t read = 0;
    size_t toSend = area->Size;
    while (toSend > 0) {
        int chunkSize = toSend < maxDataSize ? toSend : maxDataSize;

        isoRecvPDU(&PDU);

        ReqParams= PReqFunUploadParams(pbyte(PDUH_in) + sizeof(TS7ReqHeader));

        if (ReqParams->FunUpld != pduUpload || pbyte(PDUH_in)[sizeof(TS7ReqHeader)+sizeof(TReqFunUploadParams)-1] != 0x07)
            break;

        Answer.Header.Sequence= PDUH_in->Sequence;
        Answer.Header.DataLen= SwapWord(chunkSize + 4);

        memcpy(&Answer.ResData[sizeof(TResFunUploadParams) + 4], area->PData + read, chunkSize);

        read += chunkSize;
        toSend -= chunkSize;
        if (toSend <= 0) {
            ResParams->EoU = 0x00;
            Answer.ResData[3] = 0xCA;
        }

        isoSendBuffer(&Answer,sizeof(TS7ResHeader23)+sizeof(TResFunUploadParams) + chunkSize + 4);
    }

    isoRecvPDU(&PDU); // end upload

    ResEndParams= PResFunEndUploadParams(Answer.ResData);
    Answer.Header.Sequence= PDUH_in->Sequence;
    Answer.Header.ParLen= SwapWord(sizeof(TResFunEndUploadParams));
    Answer.Header.DataLen= 0;
    ResEndParams->FunEUpld= pduEndUpload;

    isoSendBuffer(&Answer,sizeof(TS7ResHeader23)+sizeof(TResFunEndUploadParams));

    if (toSend == 0) {
        RetCode = evrNoError;
    } else {
        RetCode = evrDataSizeMismatch;
    }

    DoEvent(evcUpload,RetCode,BlkType,BlkNum,0,0);
    return true;
}
//==============================================================================
// FUNCTION DOWNLOAD
//==============================================================================
// TODO need proper error handling
bool TS7Worker::PerformFunctionDownload()
{
    PReqStartDownloadParams ReqStartParams;
    PReqDownloadParams ReqParams;
    TS7Answer17 Answer17;
    TS7Answer23 Answer23;
    PS7ResHeader23 ResHeader;
    byte AsciiBlk[5];
    longword BlkLen = 0;
    longword BlkNum;
    byte BlkType;
    word RetCode;

    ReqStartParams = PReqStartDownloadParams(pbyte(PDUH_in) + sizeof(TS7ReqHeader));

    // save type, No and length
    memcpy(AsciiBlk,ReqStartParams->AsciiBlk,sizeof(AsciiBlk));
    BlkNum = AsciiToNum(AsciiBlk, sizeof(AsciiBlk));
    BlkType = ReqStartParams->BlkType;
    BlkLen = AsciiToNum(ReqStartParams->AsciiLoad, sizeof(ReqStartParams->AsciiLoad));

    pbyte buffer = new byte[BlkLen];

    // ack request
    Answer23.Header.P=0x32;
    Answer23.Header.PDUType=PduType_response;
    Answer23.Header.AB_EX=0x0000;
    Answer23.Header.Sequence=PDUH_in->Sequence;
    Answer23.Header.Error=0;
    Answer23.Header.ParLen=0x0100;
    Answer23.Header.DataLen=0;
    Answer23.ResData[0]= pduReqDownload;

    isoSendBuffer(&Answer23,sizeof(TS7ResHeader23)+1);

    // request download block
    ReqParams = PReqDownloadParams(Answer17.ResData);
    Answer17.Header.P=0x32;
    Answer17.Header.PDUType=PduType_request;
    Answer17.Header.AB_EX=0x0000;
    Answer17.Header.Sequence=0x0100;
    Answer17.Header.ParLen=SwapWord(sizeof(TReqDownloadParams));
    Answer17.Header.DataLen=0;
    ReqParams->Fun= pduDownload;
    memset(ReqParams->Uk7,0,sizeof(ReqParams->Uk7));
    ReqParams->Len_1= 0x09;
    ReqParams->Prefix= 0x5F;
    ReqParams->BlkPrfx= 0x30;
    ReqParams->BlkType = BlkType;
    memcpy(ReqParams->AsciiBlk, AsciiBlk, sizeof(ReqParams->AsciiBlk));
    ReqParams->P= 0x50;

    // receive blocks
    bool last_packet = false;
    word DataLen = 0;
    size_t written = 0;
    while(!last_packet && written < BlkLen) {
        isoSendBuffer(&Answer17,sizeof(TS7ResHeader17)+sizeof(TReqDownloadParams));
        isoRecvPDU(&PDU);
        ResHeader = PS7ResHeader23(pbyte(PDUH_in));
        DataLen = SwapWord(ResHeader->DataLen) - 4;
        memcpy(buffer + written, &pbyte(PDUH_in)[sizeof(TS7ResHeader23) + 6], DataLen);
        last_packet = !(bool)(pbyte(PDUH_in)[sizeof(TS7ResHeader23) + 1]);
        written += DataLen;
    }

    // download ended
    ReqParams = PReqDownloadParams(Answer17.ResData);
    Answer17.Header.Sequence=0x0200;
    ReqParams->Fun= pduDownloadEnded;

    isoSendBuffer(&Answer17,sizeof(TS7ResHeader17)+sizeof(TReqDownloadParams));

    isoRecvPDU(&PDU); // download ended ack

    if (last_packet && written == BlkLen) {
        // success
        if (FServer->getArea(BlkType)->Find(BlkNum) != NULL) {
            // unregister old block to overwrite it
            FServer->getArea(BlkType)->Unregister(BlkNum);
        }
        FServer->getArea(BlkType)->Register(BlkNum, buffer, BlkLen);
        RetCode = evrNoError;
    } else {
        delete[] buffer;
        RetCode = evrDataSizeMismatch;
    }

    DoEvent(evcDownload,RetCode, BlkType, BlkNum, BlkLen,0);
    return true;
}
//==============================================================================
// FUNCTIONS PROGRAMMER AND CYCLIC DATA (PARTIALLY IMPLEMENTED...yet)
//==============================================================================
bool TS7Worker::PerformGroupProgrammer()
{
    // this is a static answer to TIA's GP request (only seen this response yet).
    // there is a second kind of GP, a LED blink request w. subfunc 0x16,
    // might implement this when I get a PLC supporting it.
    PGPReqParams ReqParams;
    PGPReqData ReqData;
    PGPResParams ResParams;
    PGPResData ResData;
    TS7Answer17 Answer;
    int TotalSize;
    word evs, param2 = 0, param3 = 0, param4 = 0;
    int dlen;
    byte job_id = 0;

    ReqParams=PGPReqParams(pbyte(PDUH_in)+ReqHeaderSize);
    ReqData  =PGPReqData(pbyte(PDUH_in)+ReqHeaderSize+sizeof(TGPReqParams));
    ResParams=PGPResParams(pbyte(&Answer)+ResHeaderSize17);
    ResData  =PGPResData(pbyte(ResParams)+sizeof(TGPResParams));

    // Prepares the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=PduType_userdata;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen =SwapWord(sizeof(TGPResParams));
    Answer.Header.DataLen=SwapWord(0x0010);
    // Params
    ResParams->Head[0]=ReqParams->Head[0];
    ResParams->Head[1]=ReqParams->Head[1];
    ResParams->Head[2]=ReqParams->Head[2];
    ResParams->Plen  =0x08;
    ResParams->Uk    =0x12;
    ResParams->Tg    =0x81; // Type response, group programmer
    ResParams->SubFun=ReqParams->SubFun;
    ResParams->Seq   =ReqParams->Seq + 1;
    ResParams->resvd =0x0000;
    ResParams->Err   =0x0000;

    // vartable
    if (ReqParams->SubFun == SFun_VarTab) {
        // TODO validate count!!!!!!
        word item_count = SwapWord(*((word*)&ReqData->Data[24]));
        VarTabItem* items = (VarTabItem*) &ReqData->Data[26];

        //printf("C: %d I1: r: %d d: %d s: %d\n", item_count, items[0].repetition_factor, items[0].db_number, items[0].start_address);

        // ACK request
        ResData->FF = 0x0A;
        ResData->TRSize = 0;
        ResData->DataLength = 0;
        Answer.Header.DataLen=0x0400;
        dlen = 8;

        TotalSize = 10 + sizeof(PGPResParams) + dlen;
        isoSendBuffer(&Answer,TotalSize);

        // send follow packet with requested values
        ResParams->Tg = 0x01; // follow
        ResData->FF = 0xFF;
        ResData->TRSize = TS_ResOctet;

        // - type response
        ResData->Data[0] = 0x00;
        ResData->Data[1] = 0x04;
        // - unknown bytes
        ResData->Data[4] = 0x01;
        ResData->Data[5] = 0x00;
        ResData->Data[6] = 0x00;
        ResData->Data[7] = 0x01;

        // number of items
        *((word*)&ResData->Data[8]) = SwapWord(item_count);
        // populate items
        size_t offset = 10;
        for (word i = 0; i < item_count; i++) {
            //printf("i: %d o: %d\n", i, offset);
            VarTabItem item = items[i];
            item.start_address = SwapWord(item.start_address);
            byte dt_width = item.getDataTypeLength();
            byte data_length = dt_width * item.repetition_factor;
            PS7Area memory_area;
            pbyte memory;
            word memory_size;

            //printf("dtw: %d dlen: %d\n", dt_width, data_length);

            switch (item.getMemoryArea()) {
                case VT_M:
                    memory_area = FServer->HA[srvAreaMK];
                    break;
                case VT_E:
                    memory_area = FServer->HA[srvAreaPE];
                    break;
                case VT_A:
                    memory_area = FServer->HA[srvAreaPA];
                    break;
                case VT_DB:
                    memory_area = FServer->DBArea->Find(item.db_number);
                    break;

            }

            // validate memory presence and valid access
            if (!memory_area || (item.start_address + dt_width) > memory_area->Size) {
                // object does not exist
                ResData->Data[offset++] = 0x0a;
                // no transport size
                ResData->Data[offset++] = 0x00;
                // no data
                ResData->Data[offset++] = 0x00;
                continue;
            } else {
                memory = memory_area->PData;
                memory_size = memory_area->Size;
            }
            // success
            ResData->Data[offset++] = 0xFF;
            // TRSize
            ResData->Data[offset++] = TS_ResOctet;

            // data length
            *((word*)&ResData->Data[offset]) = SwapWord(data_length);
            offset += 2;

            memcpy(ResData->Data + offset, memory + item.start_address, data_length);
            offset += data_length;

            //if (dt_width == 2) {
            //    printf("AS: %p %p %p %d %d\n", memory, memory + item.start_address, &memory[2], memory[3], item.start_address);
            //}

            if (dt_width == 1) {
                // add fill byte
                ResData->Data[offset++] = 0;
            }

        }
        Answer.Header.DataLen= SwapWord(offset + 4);
        ResData->DataLength = SwapWord(offset);
        // item length...
        *((word*)&ResData->Data[2]) = SwapWord(offset - 8);
        //printf("L: %d\n", offset - 8);

        dlen = offset + 9;
    }
    // Request Diag Data Type 2
    if (ReqParams->SubFun == SFun_ReqDiagT2
            || ReqParams->SubFun == SFun_ReadDiag
            || ReqParams->SubFun == SFun_RemoveDiag) {
        // ACK request
        ResData->FF = 0x0A;
        ResData->TRSize = 0;
        ResData->DataLength = 0;
        Answer.Header.DataLen=0x0400;

        dlen = 8;

        param2 = *((word*)&ClientHandle);
        param3 = *(((word*)&ClientHandle) + 1);

        if (ReqParams->SubFun == SFun_ReqDiagT2) {
            evs = evsGPRequestDiag;

            byte block_type = ReqData->Data[25];
            word blockno = SwapWord(*((word*)(ReqData->Data + 26)));
            word start_address = SwapWord(*((word*)(ReqData->Data + 28)));
            word saz = SwapWord(*((word*)(ReqData->Data + 30)));
            byte lines = ReqData->Data[33];
            byte registers = ReqData->Data[35];


            RequestDiag rd;
            rd.block_type = block_type;
            rd.block_no = blockno;
            rd.start_address = start_address;
            rd.saz = saz;
            rd.lines = lines;
            rd.initial_registers = registers;

            for (int i = 0; i < lines; i++) {
                rd.line_registers[*((word*)&ReqData->Data[37 + i * 4])] = ReqData->Data[39 + i * 4];
            }

            job_id = FServer->AddDiagRequest(ClientHandle, rd);
            ResParams->Seq = job_id;
            param4 = job_id;
        }
        if (ReqParams->SubFun == SFun_ReadDiag) {
            job_id = ReqData->Data[25];
            param4 = job_id;
            evs = evsGPReadDiag;
            DiagID diag_id = std::make_pair(ClientHandle, job_id);
            if (!FServer->diag_responses.count(diag_id)
                    || !FServer->diag_requests.count(diag_id))
                goto send_gp;

            ResponseDiag* diag_response = FServer->diag_responses[diag_id];
            RequestDiag* diag_request = FServer->diag_requests[diag_id];

            // ACK read request
            TotalSize = 10 + sizeof(PGPResParams) + dlen;
            isoSendBuffer(&Answer,TotalSize);

            // and send follow packet
            ResParams->SubFun= SFun_ReqDiagT2;

            ResParams->Tg = 0x01; // follow

            ResData->FF = 0xFF;

            // expecting caller to block here until response was recorded
            DoEvent(evcGroupProgrammer,evrNoError,evs,param2,param3,param4);

            // cancel if response was not populated
            // XXX TIA crashes when response contains only zeroes
            if (!diag_response->ready) {
                return true;
            } else {
                diag_response->ready = false;
            }

            ResponseDiagData* resp_d = (ResponseDiagData*) &ResData->Data;

            resp_d->uk1_0 = 0;
            resp_d->uk2_4 = 4;
            resp_d->uk3_1 = 1;
            resp_d->uk4_0 = 0;
            resp_d->uk5_0 = 0;
            resp_d->uk6_1 = 1;
            resp_d->uk7_0 = 0;
            resp_d->uk8_0 = 0;


            pbyte first_byte = &resp_d->diag_lines;
            size_t offset = 0;

            offset = copyDiagDataLine(first_byte, diag_request->initial_registers, false, &diag_response->initial);

            for (std::map<word, DiagDataLine>::iterator it =
                    diag_response->lines.begin();
                    it != diag_response->lines.end(); it++) {
                offset += copyDiagDataLine(first_byte + offset,
                        diag_request->line_registers[it->first], true,
                        &it->second);
            }

            ResData->TRSize = TS_ResOctet;

            dlen = sizeof(ResponseDiagData) - 1 + offset + 8;
            resp_d->answer_length = SwapWord(dlen - 16);
            ResData->DataLength = SwapWord(dlen - 8);
            Answer.Header.DataLen=SwapWord(dlen - 4);
            Answer.Header.Sequence=0;
            ResParams->Seq   = job_id;
        }
        if (ReqParams->SubFun == SFun_RemoveDiag) {
            job_id = ReqData->Data[27];
            param4 = job_id;
            evs = evsGPRemoveDiag;
            FServer->RemoveDiagRequest(ClientHandle, job_id);
        }
    }
    if (ReqParams->SubFun == SFun_Forces || ReqParams->SubFun == SFun_Blink) {
        // Data
        ResData->FF      =0xFF;
        ResData->TRSize  =TS_ResOctet;
        ResData->DataLength=SwapWord(0x000C);
        ResData->Data[0]  = 0x00;
        ResData->Data[1]  = 0x04;
        ResData->Data[2]  = 0x00;
        ResData->Data[3]  = 0x04;
        ResData->Data[4]  = 0x01;
        ResData->Data[5]  = 0x00;
        ResData->Data[6]  = 0x00;
        ResData->Data[7]  = 0x01;
        ResData->Data[8]  = 0x10;
        ResData->Data[9]  = 0x01;
        ResData->Data[10] = 0x00;
        ResData->Data[11] = 0x00;

        dlen = 20;
        evs = ReqParams->SubFun == SFun_Blink ? evsGPBlink : evsGPStatic;
    }

    // TODO what was that????
    if (false && ReqParams->SubFun == 0x02) {
        Answer.Header.DataLen=SwapWord(4);
        ResData->FF = 0x0a;
        ResData->TRSize = 0x00;
        ResData->DataLength = 0x00;

        isoSendBuffer(&Answer,10 + sizeof(PGPResParams) + 8);

        // 4 bytes shorter OR PDURef 0 crashes TIA

        Answer.Header.Sequence = PDUH_in->Sequence;
        Answer.Header.DataLen = SwapWord(20);

        ResParams->Tg = 0x01;
        ResParams->Seq = 1;

        ResData->FF      =0xFF;
        ResData->TRSize  =TS_ResOctet;
        ResData->DataLength=SwapWord(16);

        ResData->Data[0]  = 0x00;
        ResData->Data[1]  = 0x04;
        ResData->Data[2]  = 0x00;
        ResData->Data[3]  = 0x0A;
        ResData->Data[4]  = 0x01;
        ResData->Data[5]  = 0x00;
        ResData->Data[6]  = 0x00;
        ResData->Data[7]  = 0x01;
        ResData->Data[8]  = 0x00;
        ResData->Data[9]  = 0x01;
        ResData->Data[10] = 0xFF;
        ResData->Data[11] = 0x09;
        ResData->Data[12] = 0x00;
        ResData->Data[13] = 0x04;
        ResData->Data[14] = 0x00;

        dlen = 24;
    }

    send_gp:
    TotalSize = 10 + 12 + dlen;
    isoSendBuffer(&Answer,TotalSize);

    if (evs != evsGPReadDiag)
        DoEvent(evcGroupProgrammer,evrNoError,evs,param2,param3,param4);

    if (evs == evsGPRemoveDiag)
        FServer->RemoveDiagRequest(ClientHandle, job_id);

    return true;
}
//------------------------------------------------------------------------------
size_t TS7Worker::copyDiagDataLine(pbyte to, byte registers, bool add_offset, DiagDataLine* ddl) {
    size_t offset = 0;

    if (add_offset) {
        *((word*)(to + offset)) = ddl->offset;
        offset += 2;
    }

    if (registers & DIAG_REGISTER_STATUS) {
        *((word*)(to + offset)) = ddl->status_word;
        offset += 2;
    }
    if (registers & DIAG_REGISTER_AKKU1) {
        *((longword*)(to + offset)) = ddl->akku1;
        offset += 4;
    }
    if (registers & DIAG_REGISTER_AKKU2) {
        *((longword*)(to + offset)) = ddl->akku2;
        offset += 4;
    }
    if (registers & DIAG_REGISTER_AREG1) {
        *((longword*)(to + offset)) = ddl->areg1;
        offset += 4;
    }
    if (registers & DIAG_REGISTER_AREG2) {
        *((longword*)(to + offset)) = ddl->areg2;
        offset += 4;
    }
    if (registers & DIAG_REGISTER_DB) {
        // TODO this field has an unknown value
        *((word*)(to + offset)) = 0;
        offset += 2;
        *((word*)(to + offset)) = SwapWord(ddl->db_no);
        offset += 2;
        *((word*)(to + offset)) = 0;
        offset += 2;
    }
    if (registers & DIAG_REGISTER_DI) {
        // TODO this field has an unknown value
        *((word*)(to + offset)) = 0;
        offset += 2;
        *((word*)(to + offset)) = SwapWord(ddl->di_no);
        offset += 2;
        *((word*)(to + offset)) = 0;
        offset += 2;
    }

    return offset;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformGroupCyclicData()
{
    /*
     * We will be answering requests regarding the PROFINET interface of the
     * PLC asked by TIA when looking at "online and diagnostics" tab. Everything
     * else will not get an answer for now
     *
     * We will also want to answer "Message Service" like requests, as they
     * might be useful in letting TIA think we are a REAL plc and not just a
     * fake knock off software pretending ;)
     */

    // Use some variables to handle request and result packages more comfortably
    PGCRequestParams    RequestParams;
    PGCRequestData      RequestData;
    PGCAnswerParams     AnswerParams;
    PGCAnswerData       AnswerData;

    // Answer packet type for these kind of requests
    TS7Answer17         Answer;

    // total size of the answer package
    int TotalSize = 0;

    word evs, param2 = 0, param3 = 0, param4 = 0;

    RequestParams    = PGCRequestParams(pbyte(PDUH_in)+ReqHeaderSize);
    RequestData      = PGCRequestData(pbyte(PDUH_in)+ReqHeaderSize+sizeof(TGCRequestParams));
    AnswerParams     = PGCAnswerParams(pbyte(&Answer)+ResHeaderSize17);
    AnswerData       = PGCAnswerData(pbyte(AnswerParams)+sizeof(TGCAnswerParams));

    // Fill header of the answer packet with known values
    Answer.Header.P         =0x32;
    Answer.Header.PDUType   =PduType_userdata;
    Answer.Header.AB_EX     =0x0000;
    Answer.Header.Sequence  =PDUH_in->Sequence;
    Answer.Header.ParLen    =SwapWord(sizeof(TGCAnswerParams));
    Answer.Header.DataLen   =SwapWord(0x0010); // gets set later if bigger

    // Fill parameters of answer packet with known values
    AnswerParams->Head[0]=RequestParams->Head[0];
    AnswerParams->Head[1]=RequestParams->Head[1];
    AnswerParams->Head[2]=RequestParams->Head[2];
    AnswerParams->Plen  =0x08;
    AnswerParams->Uk    =0x12;
    AnswerParams->Tg    =0x82; // Type response, group cyclic data
    AnswerParams->SubFun=RequestParams->SubFun;
    AnswerParams->Seq   =RequestParams->Seq + 2; //Seems to be always 2 (0 + 2)

    // The field AnswerParams->resvd actually has 2 parts:
    // The first 2 bytes:
    //      The Data Unit Reference (DUR) which references to which Data Unit a
    //      packet belongs to if the Data Unit has been split into multiple
    //      packages
    // The last 2 bytes:
    //      The Last Data Unit (LDU) indicator, showing if this was the last
    //      packet of a data unit split into multiple packages
    AnswerParams->resvd =0x0000;
    AnswerParams->Err   =0x0000; // All Zero for all correct


    // Check request and send appropriate answer

    if (RequestParams->SubFun == SFun_Profinet) {
        evs = evsGCRequestData;
        AnswerData->ReturnCode      = ReturnCode_Success;
        // Set transport size of Data to OCTET:
        AnswerData->TransportSize   = TS_ResOctet;

        // Size = 92
        unsigned char ResponseData[] = { /* Answer String for Cyclic Request*/
        0x00, 0x01, 0xff, 0x09, 0x00, 0x00, 0x00,
        0x54, 0x04, 0x00, 0x00, 0x50, 0x01, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x81,
        0x00, 0x02, 0x11, 0x00, 0x24, 0x01, 0x00, 0x00,
        0x00, 0xc3, 0xd6, 0x87, 0xfe, 0x78, 0x9e, 0x03,
        0xa1, 0xac, 0xdb, 0xe5, 0xbf, 0xcb, 0xbc, 0x27,
        0xb6, 0x00, 0x00, 0x00, 0x00, 0x0b, 0x6d, 0x72,
        0x70, 0x64, 0x6f, 0x6d, 0x61, 0x69, 0x6e, 0x2d,
        0x31, 0x02, 0x13, 0x00, 0x18, 0x01, 0x00, 0x00,
        0x00, 0xc3, 0xd6, 0x87, 0xfe, 0x78, 0x9e, 0x03,
        0xa1, 0xac, 0xdb, 0xe5, 0xbf, 0xcb, 0xbc, 0x27,
        0xb6, 0x00, 0x00, 0x00, 0x00 };

        // Fill Answer with Response Data
        for (size_t i = 0; i < sizeof(ResponseData); i++) {
            AnswerData->Data[i] = ResponseData[i];
        }

        // Set answer data size in header (+4 Bytes for redundant length field,
        // return code and transport size)
        Answer.Header.DataLen       = SwapWord(sizeof(ResponseData) + 4);
        // Now set it again in actual data segment of the packet
        AnswerData->DataLength      = SwapWord(sizeof(ResponseData));

        // Calculate size
        // 4 extra for parameter head and 4 extra for return code and
        // transport size of response data
        TotalSize = sizeof(Answer.Header)
                    + sizeof(PGCAnswerParams) + 4
                    + sizeof(ResponseData) + 4;

        //Send
        isoSendBuffer(&Answer, TotalSize);
    }

    // TODO sent correct events
    DoEvent(evcGroupCyclicData,evrNoError,evs,0,0,0);
    return true;
}
//==============================================================================
// BLOCK(S) INFO FUNCTIONS
//==============================================================================
void TS7Worker::BLK_ListAll(TCB &CB)
{
    PDataFunListAll Data;
    int TotalSize;

    TotalSize = ResHeaderSize17+sizeof(TResFunGetBlockInfo)+sizeof(TDataFunListAll);
    // Prepares the answer
    CB.Answer.Header.P=0x32;
    CB.Answer.Header.PDUType=PduType_userdata;
    CB.Answer.Header.AB_EX=0x0000;
    CB.Answer.Header.Sequence=PDUH_in->Sequence;
    CB.Answer.Header.ParLen =SwapWord(sizeof(TResFunGetBlockInfo));
    CB.Answer.Header.DataLen=SwapWord(sizeof(TDataFunListAll));

    CB.ResParams->Head[0]=CB.ReqParams->Head[0];
    CB.ResParams->Head[1]=CB.ReqParams->Head[1];
    CB.ResParams->Head[2]=CB.ReqParams->Head[2];
    CB.ResParams->Plen  =0x08;
    CB.ResParams->Uk    =0x12;
    CB.ResParams->Tg    =0x83; // Type response, group functions info
    CB.ResParams->SubFun=SFun_ListAll;

    CB.ResParams->Seq   =CB.ReqParams->Seq;
    CB.ResParams->Rsvd  =0x0000;
    CB.ResParams->ErrNo =0x0000;

    Data=PDataFunListAll(pbyte(&CB.Answer)+ResHeaderSize17+sizeof(TResFunGetBlockInfo));
    Data->RetVal=0xFF;
    Data->TRSize=TS_ResOctet;
    Data->Length=SwapWord(28); // 28 = Size of TDataFunListAll.Blocks
    // Fill elements, only DB will have a valid number
    Data->Blocks[0].Zero=0x30;
    Data->Blocks[0].BType=Block_OB;
    Data->Blocks[0].BCount=SwapWord(FServer->getArea(srvAreaOB)->count);
    Data->Blocks[1].Zero=0x30;
    Data->Blocks[1].BType=Block_FB;
    Data->Blocks[1].BCount=SwapWord(FServer->getArea(srvAreaFB)->count);
    Data->Blocks[2].Zero=0x30;
    Data->Blocks[2].BType=Block_FC;
    Data->Blocks[2].BCount=SwapWord(FServer->getArea(srvAreaFC)->count);
    Data->Blocks[3].Zero=0x30;
    Data->Blocks[3].BType=Block_DB;
    Data->Blocks[3].BCount=SwapWord(FServer->getArea(srvAreaDB)->count);
    Data->Blocks[4].Zero=0x30;
    Data->Blocks[4].BType=Block_SDB;
    Data->Blocks[4].BCount=SwapWord(FServer->getArea(srvAreaSDB)->count);
    Data->Blocks[5].Zero=0x30;
    Data->Blocks[5].BType=Block_SFC;
    // TODO add real numbers here
    Data->Blocks[5].BCount=0;
    Data->Blocks[6].Zero=0x30;
    Data->Blocks[6].BType=Block_SFB;
    Data->Blocks[6].BCount=0;
    // Sends
    isoSendBuffer(&CB.Answer,TotalSize);
    DoEvent(evcDirectory, 0, evsGetBlockList, 0, 0, 0);
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_NoResource_ListBoT(PDataFunGetBot Data, TCB &CB)
{
    CB.DataLength    =4;
    DBCnt            =0; // Reset counter
    CB.Answer.Header.DataLen=SwapWord(CB.DataLength);
    CB.ResParams->ErrNo =0x0ED2; // function in error
    Data->RetVal     =0x0A;   // No resource available
    Data->TSize      =0x00;   // No transport size;
    Data->DataLen    =0x0000; // No data;
    CB.evError       =evrResNotFound;
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_ListBoT(byte BlockType, bool Start, TCB &CB)
{
    PDataFunGetBot Data;
    int MaxItems, TotalSize, cnt;
    int HiBound = FServer->DBArea->limit+1;

    CB.evError=0;
    MaxItems=(FPDULength - 32) / 4;
    // Prepares the answer
    CB.Answer.Header.P=0x32;
    CB.Answer.Header.PDUType=PduType_userdata;
    CB.Answer.Header.AB_EX=0x0000;
    CB.Answer.Header.Sequence=PDUH_in->Sequence;
    CB.Answer.Header.ParLen =SwapWord(sizeof(TResFunGetBlockInfo));

    CB.ResParams->Head[0]=CB.ReqParams->Head[0];
    CB.ResParams->Head[1]=CB.ReqParams->Head[1];
    CB.ResParams->Head[2]=CB.ReqParams->Head[2];
    CB.ResParams->Plen  =0x08;
    CB.ResParams->Uk    =0x12;
    CB.ResParams->Tg    =0x83; // Type response, group functions info
    CB.ResParams->SubFun=SFun_ListBoT;
    CB.ResParams->Seq   =CB.ReqParams->Seq;
    CB.ResParams->Rsvd  =0x0000;
    Data=PDataFunGetBot(pbyte(&CB.Answer)+ResHeaderSize17+sizeof(TResFunGetBlockInfo));

    int area;
    uint i = 0, j = 0;
    byte uk, blockLang;
    size_t listLen;
    switch (BlockType) {
        case Block_OB:
        case Block_FB:
        case Block_FC:  uk = 0x22; blockLang = BlockLangAWL; break;
        case Block_DB:  uk = 0x12; blockLang = BlockLangDB;  break;
        case Block_SDB: uk = 0x22; blockLang = BlockLangSDB; break;
        case Block_SFB:
        case Block_SFC: uk = 0x42; blockLang = BlockLangAWL; break;
    }
    // TODO use lang in block header
    if ((listLen = FServer->getArea(BlockType)->count) > 0) {
        PS7Area* area = FServer->getArea(BlockType)->get();
        Data->RetVal=0xFF;
        Data->TSize =TS_ResOctet;
        CB.DataLength=4+(listLen*word(sizeof(TDataFunGetBotItem)));
        CB.Answer.Header.DataLen=SwapWord(CB.DataLength);
        Data->DataLen=SwapWord(CB.DataLength-4);
        while (j != listLen) {
            PS7Area item = area[i++];
            if (item == NULL)
                continue;
            Data->Items[j].BlockNum=SwapWord(item->Number);
            Data->Items[j].Unknown  =uk;
            Data->Items[j].BlockLang=blockLang;
            j++;
        };
    }
    else
        BLK_NoResource_ListBoT(Data, CB);

    TotalSize = ResHeaderSize17+sizeof(TResFunGetBlockInfo)+CB.DataLength;
    isoSendBuffer(&CB.Answer,TotalSize);

    if (Start)
        DoEvent(evcDirectory, CB.evError, evsStartListBoT, BlockType, 0, 0);
    else
        DoEvent(evcDirectory, CB.evError, evsListBoT, BlockType, 0, 0);
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_NoResource_GetBlkInfo(PResDataBlockInfo Data, TCB &CB)
{
    CB.DataLength  =4;
    CB.Answer.Header.DataLen=SwapWord(CB.DataLength);
    CB.ResParams->ErrNo =0x09D2; // function in error
    Data->RetVal        =0x0A;   // No resource available
    Data->TSize         =0x00;   // No transport size;
    Data->Length        =0x0000; // No data;
    CB.evError          =evrResNotFound;
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_GetBlockNum_GetBlkInfo(int &BlkNum, PReqDataBlockInfo ReqData)
{
    BlkNum = (ReqData->AsciiBlk[4] - 0x30) +
             (ReqData->AsciiBlk[3] - 0x30) * 10 +
             (ReqData->AsciiBlk[2] - 0x30) * 100 +
             (ReqData->AsciiBlk[1] - 0x30) * 1000 +
             (ReqData->AsciiBlk[0] - 0x30) * 10000;

    if (BlkNum>65535)
      BlkNum=-1;
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_DoBlockInfo_GetBlkInfo(PS7Area DB, PResDataBlockInfo Data, TCB &CB)
{
    CB.DataLength =sizeof(TResDataBlockInfo);
    CB.Answer.Header.DataLen=SwapWord(CB.DataLength);
    CB.ResParams->ErrNo =0x0000;

    Data->RetVal       =0xFF;
    Data->TSize        =TS_ResOctet;
    Data->Length       =SwapWord(78); // this struct - RetValData->Tsize and length
    Data->Cst_b        =0x01;
    Data->BlkType      =0x00;
    Data->Cst_w1       =0x4A00;
    Data->Cst_w2       =0x0022;
    Data->Cst_pp       =0x7070;
    Data->Unknown_1    =0x01;
    Data->BlkFlags     =0x01;
    Data->BlkLang      =BlockLangDB;
    Data->SubBlkType   =0x0A;
    Data->CodeTime_dy  =SwapWord(5800);// Nov/18/1999 my princess's birthdate
    Data->IntfTime_dy  =Data->CodeTime_dy;
    Data->LocDataLen   =0x0000;
    Data->BlkNumber    =SwapWord(DB->Number);
    Data->SbbLen       =0x1400;
    Data->AddLen       =0x0000;
    Data->MC7Len       =SwapWord(DB->Size);
    Data->LenLoadMem   =SwapDWord(DB->Size+92);
    Data->Version      =0x01;
    Data->Unknown_2    =0x00;
    Data->BlkChksum    =0x0000;
}
//------------------------------------------------------------------------------
void TS7Worker::BLK_GetBlkInfo(TCB &CB)
{
    PReqDataBlockInfo ReqData;
    PResDataBlockInfo Data;
    int BlkNum;
    PS7Area BlkDB;
    byte BlkTypeInfo;
    int TotalSize;
    PS7Area block;

    CB.evError=0;
    Data   =PResDataBlockInfo(pbyte(&CB.Answer)+ResHeaderSize17+sizeof(TResFunGetBlockInfo));
    ReqData=PReqDataBlockInfo(pbyte(PDUH_in)+ReqHeaderSize+sizeof(TReqFunGetBlockInfo));
    memset(Data,0,sizeof(TResDataBlockInfo)); // many fields are 0

    // Prepares the answer
    CB.Answer.Header.P=0x32;
    CB.Answer.Header.PDUType=PduType_userdata;
    CB.Answer.Header.AB_EX=0x0000;
    CB.Answer.Header.Sequence=PDUH_in->Sequence;
    CB.Answer.Header.ParLen =SwapWord(sizeof(TResFunGetBlockInfo));
    CB.Answer.Header.DataLen =SwapWord(82);

    CB.ResParams->Head[0]=CB.ReqParams->Head[0];
    CB.ResParams->Head[1]=CB.ReqParams->Head[1];
    CB.ResParams->Head[2]=CB.ReqParams->Head[2];
    CB.ResParams->Plen  =0x08;
    CB.ResParams->Uk    =0x12;
    CB.ResParams->Tg    =0x83; // Type response, group functions info
    CB.ResParams->SubFun=SFun_BlkInfo;
    CB.ResParams->Seq   =CB.ReqParams->Seq;
    CB.ResParams->Rsvd  =0x0000;
    CB.ResParams->ErrNo =0x0;

    BLK_GetBlockNum_GetBlkInfo(BlkNum, ReqData);
    BlkTypeInfo=ReqData->BlkType;

    block = FServer->getArea(ReqData->BlkType)->Find(AsciiToNum(ReqData->AsciiBlk,sizeof(ReqData->AsciiBlk)));
    if (block != NULL)
    {
        memcpy(&Data->Cst_pp, block->PData, sizeof(TS7CompactBlockInfo));
        memcpy(&Data->Author, block->PData + block->Size - 36, 36);
        Data->BlkType      =0x00;         // XXX a 314C zeroes the type...
        Data->RetVal       =0xFF;
        Data->TSize        =TS_ResOctet;
        Data->Length       =SwapWord(78); // this struct - RetValData->Tsize and length
        Data->Cst_b        =0x01;
        Data->BlkType      =ReqData->BlkType;
        Data->Cst_w1       =0x4A00;
        Data->Cst_w2       =0x0022;
    }
    else
        BLK_NoResource_GetBlkInfo(Data, CB);

    TotalSize = ResHeaderSize17+sizeof(TResFunGetBlockInfo)+4+SwapWord(Data->Length);
    isoSendBuffer(&CB.Answer, TotalSize);
    DoEvent(evcDirectory,CB.evError,evsGetBlockInfo,BlkTypeInfo,BlkNum,0);
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformGroupBlockInfo()
{
    TCB CB;
    pbyte BlockType;

    // Setup pointers
    CB.ReqParams=PReqFunGetBlockInfo(pbyte(PDUH_in)+ReqHeaderSize);
    CB.ResParams=PResFunGetBlockInfo(pbyte(&CB.Answer)+ResHeaderSize17);
    BlockType   =pbyte(PDUH_in)+23;

    switch (CB.ReqParams->SubFun)
    {
      case SFun_ListAll : BLK_ListAll(CB); break;            // List all blocks
      case SFun_ListBoT :
      {
          if (CB.ReqParams->Plen==4)
          {
              LastBlk=*BlockType;
              BLK_ListBoT(*BlockType, true, CB); // start sequence from beginning
          }
          else
              BLK_ListBoT(LastBlk, false, CB);  // Continue sequence
      }; break;
      case SFun_BlkInfo : BLK_GetBlkInfo(CB); // Get Block info
    }
    return true;
}
//==============================================================================
// FUNCTION SZL
//==============================================================================
void TS7Worker::SZLNotAvailable()
{
    SZL.Answer.Header.DataLen=SwapWord(sizeof(SZLNotAvail));
	SZL.ResParams->Err = 0x02D4;
    memcpy(SZL.ResData, &SZLNotAvail, sizeof(SZLNotAvail));
    isoSendBuffer(&SZL.Answer,26);
    SZL.SZLDone=false;
}
void TS7Worker::SZLSystemState()
{
    SZL.Answer.Header.DataLen=SwapWord(sizeof(SZLSysState));
    SZL.ResParams->Err =0x0000;
    memcpy(SZL.ResData,&SZLSysState,sizeof(SZLSysState));
    isoSendBuffer(&SZL.Answer,28);
    SZL.SZLDone=true;

}

/*
 * Prepares various fields for an SZL answer and returns the actual length of
 * the whole buffer that has to be send.
 *
 * bool first: True if this packet is the first one for this SZL-answer
 * bool last : True if this packet is the last  one for this SZL-answer
 * uint dataSize: The size of the remaining data following the SZL header.
 *
 *
 * Result: The full buffer length of the S7-PDU with all headers included.
 */
uint16_t TS7Worker::SZLPrepareAnswerHeader(bool first, bool last, uint16_t dataSize){

    /*
     * This is the minimum amount of data that needs to be send.
     *
     * Size of buffer + 22 for Hdr + 4 for small version of DataHdr
     */
    uint16_t result = dataSize + 22 + 4;

    // Set SequenceNr.
    SZL.ResParams->Seq = FServer->GetCurrentSeqNr();

    // Set Errorcode
    SZL.ResParams->Err   = 0x0000; // no error

    // Set Success Code and Transport Size
    SZL.ResData[0] = ReturnCode_Success;
    SZL.ResData[1] = 0x09;


    // Set some things depending on which part of the answer we're preparing
    if (first){

        // Set SZL-ID and SZL-Index for response
        SZL.ResData[4] = (SZL.ID >> 8) & 0xFF;
        SZL.ResData[5] = SZL.ID & 0xFF;
        SZL.ResData[6] = (SZL.Index >> 8) & 0xFF;
        SZL.ResData[7] = SZL.Index & 0xFF;

        // Compute the remaining data length for the SZL packet and save
        // in Big Endian format
        SZL.ResData[2] = ((dataSize + 4)>>8) & 0xFF;
        SZL.ResData[3] = (dataSize  + 4) & 0xFF;

        // Adjust header data len (+ 8 for "DataHdr")
        SZL.Answer.Header.DataLen = SwapWord(dataSize + 8);

        // Add 4 to complete result length, as Data-Header is longer in this
        // case
        result += 4;

    } else {

        // Compute the remaining data length for the SZL packet and save
        // in Big Endian format
        SZL.ResData[2] = ((dataSize)>>8) & 0xFF;
        SZL.ResData[3] = (dataSize) & 0xFF;

        // Adjust header data len (+ 4 for "DataHdr")
        SZL.Answer.Header.DataLen = SwapWord(dataSize + 4);

    }
    if (last) {

        // Decrease Sequence Number
        FServer->DecrSeqNr();

    }

    // Set DURN correctly
    if (first && last)
        SZL.ResParams->resvd = 0x0000;
    if (first && not last)
        SZL.ResParams->resvd = ( 0x01 << 8 ) | ((FServer->GetNextDURN() & 0xFF) );
    if (not first && not last)
        SZL.ResParams->resvd = ( 0x01 << 8 ) | ((FServer->GetCurrentDURN() & 0xFF) );
    if (not first && last)
        SZL.ResParams->resvd = ( 0x00 << 8 ) | ((FServer->GetCurrentDURN() & 0xFF) );

    return result;
}

/*
 * This sends a continuation packet if an SZL had to be split into multiple
 * fragments.
 */
void TS7Worker::SZLSendContinuation(const byte sequence){

    bool is_last = true;

    if (FragmentMap.count(sequence) > 0 ) {

        std::list<std::vector<byte>> &fragments = FragmentMap[sequence];
        // get the current fragment
        std::vector<byte> &fragment             = fragments.front();

        if (fragments.size() > 1){
            is_last = false;
        }

        // No additional sizecheck! we are expecting here that the construction
        // of the fragments was done properly!
        // We start filling from the 5th byte, as the data-header fills up the
        // first 4 bytes
        memcpy(&SZL.ResData[4], fragment.data(), sizeof(byte) * fragment.size());

        uint16_t size = SZLPrepareAnswerHeader(false, is_last, fragment.size());
        isoSendBuffer(&SZL.Answer, size);

        // Delete fragment. If it was the last one, free the seq-nr
        fragments.pop_front();

        if (is_last){
            FragmentMap.erase(sequence);
        }
        // TODO generate different events for SZL-fragments
        SZL.SZLDone = true;

    } else {
        // TODO find out what actually happens when wrong seqNr is called for
        SZLNotAvailable();
    }
}

/*
 * Sends the answer packet to an SZL request.
 * Split something that is too long into multiple packets and set the sequence
 * number and data unit reference number accordingly.
 *
 * The buffer that is given to this function is expected to hold the SZL data
 * as if it would be send in a continuous packet, starting at the SZL partial
 * list length in byte.
 */
void TS7Worker::SZLSendAnswer(const pbyte buffer, const uint16_t buflen){
    // maximum size the result data can have without overflowing our buffer
    // PDULength - (Header + Paramheader(22 Bytes)) - Data-Headersize (12 Bytes)
    const word headerSize      = 22;
	const word firstPacketLen  = FPDULength - headerSize - 8;
    const word followPacketLen = FPDULength - headerSize - 4;
    const byte sequence        = FServer->GetNextSeqNr();
    word datalen;
    bool is_last;

    if (buflen > firstPacketLen){
        // Need splitting

        is_last = false;
        datalen = firstPacketLen;

        // Copy the pure data that can be send into the first packet.
        memcpy(&SZL.ResData[8] , buffer, (sizeof(byte) * firstPacketLen));

        // Prepare data for later packets and store them in fragment map
        // Now, while we still have more data than can be send in 1 PDU, copy it
        // into a buffer for the fragment list and decrease the amount of data until
        // it fits
        std::list<std::vector<byte>> fragments;

        int leftover        = buflen - firstPacketLen;
        uint16_t currentPos = firstPacketLen;

        // Copy rest of buffer into vectors for later
        // This only includes the pure data, headers have to be build on packet-send
        do  {

            std::vector<byte> fragment;

            if (leftover < followPacketLen){

                fragment.insert(fragment.end(), &buffer[currentPos], &buffer[currentPos+leftover]);

                // Adjust how much we already handled
                currentPos += leftover;
            } else {

                fragment.insert(fragment.end(), &buffer[currentPos], &buffer[currentPos+followPacketLen]);

                // Adjust how much we already handled
                currentPos += followPacketLen;
            }

            fragments.emplace_back(fragment);
            leftover   = buflen - currentPos;

        } while (leftover > 0);

        FragmentMap[sequence] = fragments;

    } else {

        is_last = true;
        datalen = buflen;

        // One packet is enough to send all data, this is the easy part
        memcpy(&SZL.ResData[8], buffer, (sizeof(byte) * (buflen)));

    }
    // Send first packet
    uint16_t complete_length = SZLPrepareAnswerHeader(true, is_last, datalen);
    isoSendBuffer(&SZL.Answer, complete_length);
    SZL.SZLDone=true;
}

void TS7Worker::SZLDataFromCache(const std::vector<byte>& buffer){
    SZLSendAnswer( pbyte(buffer.data()), buffer.size());
}

void TS7Worker::SZLData(void *P, int len)
{
	int MaxSzl=FPDULength-22;

	if (len>MaxSzl) {
        // TODO this should be everything we need, check if we can delete the
        // if clause completely
        pbyte p = pbyte(P);
        SZLSendAnswer((p+8), (len-8));
        return;
	}

	SZL.Answer.Header.DataLen=SwapWord(word(len));
	SZL.ResParams->Err  =0x0000;
	SZL.ResParams->resvd=0x0000; // this is the end, no more packets
	memcpy(SZL.ResData, P, len);

	SZL.ResData[2]=((len-4)>>8) & 0xFF;
	SZL.ResData[3]=(len-4) & 0xFF;

	isoSendBuffer(&SZL.Answer,22+len);
	SZL.SZLDone=true;
}
void TS7Worker::SZLCData(int SZLID, void *P, int len)
{
    TCSZL szl = FServer->SZLs[SZLID];
    if (szl.Len >= 0) {
        SZLData(szl.Val, szl.Len);
    } else {
        SZLData(P, len);
    }
}
// dynamic diagnostic buffer
void TS7Worker::SZL_ID0A0()
{
    uint items = FServer->GetDiagItemCount();
    size_t bufferSize = items * DiagItemLength;
    byte buffer[MaxDiagBufferItems * DiagItemLength];
    PS7ResSZLDataFirst ResData = PS7ResSZLDataFirst(SZL.ResData);
    FServer->CopyDiagBuffer(buffer);
    SZL.Answer.Header.DataLen=SwapWord(bufferSize+10);
    SZL.ResParams->Err  =0x0000;
    ResData->Ret = 0xFF;
    ResData->TS = TS_ResOctet;
    ResData->DLen = SwapWord(uint(bufferSize + 8));
    ResData->ID = 0xA000;
    ResData->Index = 0x0000;
    ResData->ListLen = SwapWord(DiagItemLength);
    ResData->ListCount = SwapWord(items);
    memcpy(&SZL.ResData[12], buffer, bufferSize);

    SZL.SZLDone = true;
    isoSendBuffer(&SZL.Answer,22+bufferSize+12);
}
// this block is dynamic (cpu status and date/time of last mode change)
void TS7Worker::SZL_ID124()
{
    PS7Time PTime;
    pbyte PStatus;

    SZL.Answer.Header.DataLen=SwapWord(sizeof(SZL_ID_0124_IDX_XXXX));
    SZL.ResParams->Err  =0x0000;
    PTime=PS7Time(pbyte(SZL.ResData)+24);
    PStatus =pbyte(SZL.ResData)+15;
    memcpy(SZL.ResData,&SZL_ID_0124_IDX_XXXX,sizeof(SZL_ID_0124_IDX_XXXX));

    if (FServer->CpuStatus == S7CpuStatusRun)
        memcpy(&SZL.ResData[12],&SZL_DIAG_CPU_RUN,sizeof(SZL_DIAG_CPU_RUN));
    else
        memcpy(&SZL.ResData[12],&SZL_DIAG_CPU_STOP,sizeof(SZL_DIAG_CPU_STOP));

    memcpy(PTime,&FServer->LastCPUStateChange,sizeof(TS7Time));

    SZL.SZLDone=true;
    isoSendBuffer(&SZL.Answer,22+sizeof(SZL_ID_0124_IDX_XXXX));
}
// this block is dynamic (contains date/time and cpu status)
void TS7Worker::SZL_ID424()
{
	PS7Time PTime;
	pbyte PStatus;

	SZL.Answer.Header.DataLen=SwapWord(sizeof(SZL_ID_0424_IDX_XXXX));
	SZL.ResParams->Err  =0x0000;
	PTime=PS7Time(pbyte(SZL.ResData)+24);
	PStatus =pbyte(SZL.ResData)+15;
	memcpy(SZL.ResData,&SZL_ID_0424_IDX_XXXX,sizeof(SZL_ID_0424_IDX_XXXX));
	FillTime(PTime);
	*PStatus=FServer->CpuStatus;
	SZL.SZLDone=true;
	isoSendBuffer(&SZL.Answer,22+sizeof(SZL_ID_0424_IDX_XXXX));
}

void TS7Worker::SZL_ID131_IDX003()
{
	size_t len = sizeof(SZL_ID_0131_IDX_0003);
	SZL.Answer.Header.DataLen=SwapWord(len);
	SZL.ResParams->Err  =0x0000;
	SZL.ResParams->resvd=0x0000; // this is the end, no more packets
	memcpy(SZL.ResData, &SZL_ID_0131_IDX_0003, len);
    // Set the max consistent data window to PDU size
	SZL.ResData[18]=((FPDULength)>>8) & 0xFF;
	SZL.ResData[19]=(FPDULength) & 0xFF;

	isoSendBuffer(&SZL.Answer,22+len);
	SZL.SZLDone=true;
}

/*
 * All we do here is update the timestamp to the current time
 */
void TS7Worker::SZL_ID0132_IDX0008()
{
	PS7Time PTime;
	size_t len = sizeof(SZL_ID_0132_IDX_0008);

	SZL.Answer.Header.DataLen=SwapWord(len);
	SZL.ResParams->Err  =0x0000;
    PTime=PS7Time(pbyte(SZL.ResData)+34);
	SZL.ResParams->resvd=0x0000; // this is the end, no more packets
	memcpy(SZL.ResData, &SZL_ID_0132_IDX_0008, len);
    // Update Timestamp
    FillTime(PTime);

	isoSendBuffer(&SZL.Answer,22+len);
	SZL.SZLDone=true;
}

void TS7Worker::SZLSetup(){
  SZL.SZLDone                = false;
  // Setup pointers
  SZL.ReqParams              = PReqFunReadSZLFirst(pbyte(PDUH_in)+ReqHeaderSize);
  SZL.ResParams              = PS7ResParams7(pbyte(&SZL.Answer)+ResHeaderSize17);
  SZL.ResData                = pbyte(&SZL.Answer)+ResHeaderSize17+sizeof(TS7Params7);
  // Prepare Answer header
  SZL.Answer.Header.P        = 0x32;
  SZL.Answer.Header.PDUType  = PduType_userdata;
  SZL.Answer.Header.AB_EX    = 0x0000;
  SZL.Answer.Header.Sequence = PDUH_in->Sequence;
  SZL.Answer.Header.ParLen   = SwapWord(sizeof(TS7Params7));

  SZL.ResParams->Head[0]     = SZL.ReqParams->Head[0];
  SZL.ResParams->Head[1]     = SZL.ReqParams->Head[1];
  SZL.ResParams->Head[2]     = SZL.ReqParams->Head[2];
  SZL.ResParams->Plen        = 0x08;
  SZL.ResParams->Uk          = 0x12;
  SZL.ResParams->Tg          = 0x84; // Type response + group szl
  SZL.ResParams->SubFun      = SZL.ReqParams->SubFun;
  SZL.ResParams->Seq         = SZL.ReqParams->Seq;
  SZL.ResParams->Err         = 0x0000; // If any errors occur, they will be set
  SZL.ResParams->resvd       = 0x0000; // this is the end, no more packets
}

bool TS7Worker::SZLSubFuncRead() {
  // only two subfunction are defined : 0x01 read, 0x02 system state
  if (SZL.ResParams->SubFun==0x02)   // 0x02 = subfunction system state
  {
      SZLSystemState();
      return false;
  };
  if (SZL.ResParams->SubFun!=0x01)
  {
      SZLNotAvailable();
      return false;
  };
}

void TS7Worker::SZLUseCacheFile() {
   /*
    * To answer to SZL queries, we have dumped the answers of a real Siemens
    * S7-300 PLC and saved them in our filesystem. These are saved in a hashmap
    * that has to be initialized from the outside.
    * Since we answer some SZL entries dynamically, we'll look for them first
    * and only if the SZL entry is not answered dynamically will we use the
    * cache to answer
    */

    TSZLKey szl_key;

    // Answer dynamically if implemented
    switch (SZL.ID)
    {
      case 0x0011 :
          SZLCData(SZL_ID_0011,&SZL_ID_0011_IDX_XXXX,sizeof(SZL_ID_0011_IDX_XXXX));
          break;
      case 0x001C :
          SZLCData(SZL_ID_001C,&SZL_ID_001C_IDX_XXXX,sizeof(SZL_ID_001C_IDX_XXXX));
          break;
      case 0x00A0 : SZL_ID0A0();break;
      case 0x0124 : SZL_ID124();break;
      case 0x0424 : SZL_ID424();break;

      // These static SZLs are needed for online diagnosis to work
      case 0x001A : SZLData(&SZL_ID_001A_IDX_XXXX,sizeof(SZL_ID_001A_IDX_XXXX));break;
      case 0x0132 : switch(SZL.Index){
                      // Dynamic Timestamp
                      case 0x0008 : SZL_ID0132_IDX0008();break;
      }
      case 0x0222 : switch(SZL.Index){
                      case 0x0001 : SZLData(&SZL_ID_0222_IDX_0001,sizeof(SZL_ID_0222_IDX_0001));break;
                      case 0x0050 : SZLData(&SZL_ID_0222_IDX_0050,sizeof(SZL_ID_0222_IDX_0050));break;

                    };break;
      default : break;
    }
    if (SZL.SZLDone){
        //We've answered dynamically, return from this method
        return;
    }

    // Set ID and Index for SZL request
    szl_key = ( SZL.ID << 16 ) | SZL.Index;

    if (FServer->cache.count(szl_key) > 0){

        std::vector<byte> &SZLAnswer = FServer->cache[szl_key];
        SZLDataFromCache(SZLAnswer);

    } else if (FServer->cache.count(toHeader(szl_key)) > 0) {

        std::vector<byte> &SZLAnswer = FServer->cache[toHeader(szl_key)];
        SZLDataFromCache(SZLAnswer);

    } else {

        SZLNotAvailable();

    }
}

//------------------------------------------------------------------------------
//Transforms the SZL key into a magic value for the cache to search for cases
//where indices are irrelevant and only the SZL ID counts
TSZLKey TS7Worker::toHeader(TSZLKey szl_key){
    return ((szl_key >> 16) | 0xFFFF0000);
}

void TS7Worker::SZLUseSnap7SZLs(){
  SZL.ReqData=PS7ReqSZLData(pbyte(PDUH_in)+ReqHeaderSize+sizeof(TReqFunReadSZLFirst));// Data after params

  SZL.ID=SwapWord(SZL.ReqData->ID);
  SZL.Index=SwapWord(SZL.ReqData->Index);

  // Switch prebuilt Data Bank (they come from a physical CPU)
  switch (SZL.ID)
  {
    case 0x0000 : SZLData(&SZL_ID_0000_IDX_XXXX,sizeof(SZL_ID_0000_IDX_XXXX));break;
    case 0x0F00 : SZLData(&SZL_ID_0F00_IDX_XXXX,sizeof(SZL_ID_0F00_IDX_XXXX));break;
    case 0x0002 : SZLData(&SZL_ID_0002_IDX_XXXX,sizeof(SZL_ID_0002_IDX_XXXX));break;
    case 0x0011 : SZLCData(SZL_ID_0011,&SZL_ID_0011_IDX_XXXX,sizeof(SZL_ID_0011_IDX_XXXX));break;
    case 0x0012 : SZLData(&SZL_ID_0012_IDX_XXXX,sizeof(SZL_ID_0012_IDX_XXXX));break;
    case 0x0013 : SZLData(&SZL_ID_0013_IDX_XXXX,sizeof(SZL_ID_0013_IDX_XXXX));break;
    case 0x0014 : SZLData(&SZL_ID_0014_IDX_XXXX,sizeof(SZL_ID_0014_IDX_XXXX));break;
    case 0x0015 : SZLData(&SZL_ID_0015_IDX_XXXX,sizeof(SZL_ID_0015_IDX_XXXX));break;
    case 0x0F14 : SZLData(&SZL_ID_0F14_IDX_XXXX,sizeof(SZL_ID_0F14_IDX_XXXX));break;
    case 0x0019 : SZLData(&SZL_ID_0019_IDX_XXXX,sizeof(SZL_ID_0019_IDX_XXXX));break;
    case 0x0F19 : SZLData(&SZL_ID_0F19_IDX_XXXX,sizeof(SZL_ID_0F19_IDX_XXXX));break;
    case 0x001C : SZLCData(SZL_ID_001C,&SZL_ID_001C_IDX_XXXX,sizeof(SZL_ID_001C_IDX_XXXX));break;
    case 0x0F1C : SZLData(&SZL_ID_0F1C_IDX_XXXX,sizeof(SZL_ID_0F1C_IDX_XXXX));break;
    case 0x0036 : SZLData(&SZL_ID_0036_IDX_XXXX,sizeof(SZL_ID_0036_IDX_XXXX));break;
    case 0x0F36 : SZLData(&SZL_ID_0F36_IDX_XXXX,sizeof(SZL_ID_0F36_IDX_XXXX));break;
    case 0x0025 : SZLData(&SZL_ID_0025_IDX_XXXX,sizeof(SZL_ID_0025_IDX_XXXX));break;
    case 0x0F25 : SZLData(&SZL_ID_0F25_IDX_XXXX,sizeof(SZL_ID_0F25_IDX_XXXX));break;
    case 0x0037 : SZLData(&SZL_ID_0037_IDX_XXXX,sizeof(SZL_ID_0037_IDX_XXXX));break;
    case 0x0F37 : SZLData(&SZL_ID_0F37_IDX_XXXX,sizeof(SZL_ID_0F37_IDX_XXXX));break;
    case 0x0074 : SZLData(&SZL_ID_0074_IDX_XXXX,sizeof(SZL_ID_0074_IDX_XXXX));break;
    case 0x0F74 : SZLData(&SZL_ID_0F74_IDX_XXXX,sizeof(SZL_ID_0F74_IDX_XXXX));break;
    case 0x0591 : SZLData(&SZL_ID_0591_IDX_XXXX,sizeof(SZL_ID_0591_IDX_XXXX));break;
    case 0x0A91 : SZLData(&SZL_ID_0A91_IDX_XXXX,sizeof(SZL_ID_0A91_IDX_XXXX));break;
    case 0x0F92 : SZLData(&SZL_ID_0F92_IDX_XXXX,sizeof(SZL_ID_0F92_IDX_XXXX));break;
    case 0x0294 : SZLData(&SZL_ID_0294_IDX_XXXX,sizeof(SZL_ID_0294_IDX_XXXX));break;
    case 0x0794 : SZLData(&SZL_ID_0794_IDX_XXXX,sizeof(SZL_ID_0794_IDX_XXXX));break;
    case 0x0F94 : SZLData(&SZL_ID_0F94_IDX_XXXX,sizeof(SZL_ID_0F94_IDX_XXXX));break;
    case 0x0095 : SZLData(&SZL_ID_0095_IDX_XXXX,sizeof(SZL_ID_0095_IDX_XXXX));break;
    case 0x0F95 : SZLData(&SZL_ID_0F95_IDX_XXXX,sizeof(SZL_ID_0F95_IDX_XXXX));break;
    case 0x00A0 : SZL_ID0A0();break;
    case 0x0FA0 : SZLData(&SZL_ID_0FA0_IDX_XXXX,sizeof(SZL_ID_0FA0_IDX_XXXX));break;
	case 0x0017 : SZLData(&SZL_ID_0017_IDX_XXXX,sizeof(SZL_ID_0017_IDX_XXXX));break;
    case 0x0F17 : SZLData(&SZL_ID_0F17_IDX_XXXX,sizeof(SZL_ID_0F17_IDX_XXXX));break;
    case 0x0018 : SZLData(&SZL_ID_0018_IDX_XXXX,sizeof(SZL_ID_0018_IDX_XXXX));break;
    case 0x0F18 : SZLData(&SZL_ID_0F18_IDX_XXXX,sizeof(SZL_ID_0F18_IDX_XXXX));break;
    case 0x001A : SZLData(&SZL_ID_001A_IDX_XXXX,sizeof(SZL_ID_001A_IDX_XXXX));break;
    case 0x0F1A : SZLData(&SZL_ID_0F1A_IDX_XXXX,sizeof(SZL_ID_0F1A_IDX_XXXX));break;
    case 0x001B : SZLData(&SZL_ID_001B_IDX_XXXX,sizeof(SZL_ID_001B_IDX_XXXX));break;
    case 0x0F1B : SZLData(&SZL_ID_0F1B_IDX_XXXX,sizeof(SZL_ID_0F1B_IDX_XXXX));break;
    case 0x0021 : SZLData(&SZL_ID_0021_IDX_XXXX,sizeof(SZL_ID_0021_IDX_XXXX));break;
    case 0x0A21 : SZLData(&SZL_ID_0A21_IDX_XXXX,sizeof(SZL_ID_0A21_IDX_XXXX));break;
    case 0x0F21 : SZLData(&SZL_ID_0F21_IDX_XXXX,sizeof(SZL_ID_0F21_IDX_XXXX));break;
    case 0x0023 : SZLData(&SZL_ID_0023_IDX_XXXX,sizeof(SZL_ID_0023_IDX_XXXX));break;
    case 0x0F23 : SZLData(&SZL_ID_0F23_IDX_XXXX,sizeof(SZL_ID_0F23_IDX_XXXX));break;
    case 0x0024 : SZLData(&SZL_ID_0024_IDX_XXXX,sizeof(SZL_ID_0024_IDX_XXXX));break;
    case 0x0124 : SZL_ID124();break;
    case 0x0424 : SZL_ID424();break;
    case 0x0038 : SZLData(&SZL_ID_0038_IDX_XXXX,sizeof(SZL_ID_0038_IDX_XXXX));break;
    case 0x0F38 : SZLData(&SZL_ID_0F38_IDX_XXXX,sizeof(SZL_ID_0F38_IDX_XXXX));break;
    case 0x003A : SZLData(&SZL_ID_003A_IDX_XXXX,sizeof(SZL_ID_003A_IDX_XXXX));break;
    case 0x0F3A : SZLData(&SZL_ID_0F3A_IDX_XXXX,sizeof(SZL_ID_0F3A_IDX_XXXX));break;
    case 0x0F9A : SZLData(&SZL_ID_0F9A_IDX_XXXX,sizeof(SZL_ID_0F9A_IDX_XXXX));break;
    case 0x0D91 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0D91_IDX_0000,sizeof(SZL_ID_0D91_IDX_0000));break;
                    default: SZLNotAvailable();break;
                  };
                  break;
    case 0x0092 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0092_IDX_0000,sizeof(SZL_ID_0092_IDX_0000));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0292 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0292_IDX_0000,sizeof(SZL_ID_0292_IDX_0000));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0692 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0692_IDX_0000,sizeof(SZL_ID_0692_IDX_0000));break;
                    default     : SZLNotAvailable();break;
                  };break;
	case 0x0094 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0094_IDX_0000,sizeof(SZL_ID_0094_IDX_0000));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0D97 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0D97_IDX_0000,sizeof(SZL_ID_0D97_IDX_0000));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0111 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0111_IDX_0001,sizeof(SZL_ID_0111_IDX_0001));break;
                    case 0x0006 : SZLData(&SZL_ID_0111_IDX_0006,sizeof(SZL_ID_0111_IDX_0006));break;
                    case 0x0007 : SZLData(&SZL_ID_0111_IDX_0007,sizeof(SZL_ID_0111_IDX_0007));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0F11 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0F11_IDX_0001,sizeof(SZL_ID_0F11_IDX_0001));break;
                    case 0x0006 : SZLData(&SZL_ID_0F11_IDX_0006,sizeof(SZL_ID_0F11_IDX_0006));break;
                    case 0x0007 : SZLData(&SZL_ID_0F11_IDX_0007,sizeof(SZL_ID_0F11_IDX_0007));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0112 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0112_IDX_0000,sizeof(SZL_ID_0112_IDX_0000));break;
                    case 0x0100 : SZLData(&SZL_ID_0112_IDX_0100,sizeof(SZL_ID_0112_IDX_0100));break;
                    case 0x0200 : SZLData(&SZL_ID_0112_IDX_0200,sizeof(SZL_ID_0112_IDX_0200));break;
                    case 0x0400 : SZLData(&SZL_ID_0112_IDX_0400,sizeof(SZL_ID_0112_IDX_0400));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0F12 : switch(SZL.Index){
                   case 0x0000 : SZLData(&SZL_ID_0F12_IDX_0000,sizeof(SZL_ID_0F12_IDX_0000));break;
                   case 0x0100 : SZLData(&SZL_ID_0F12_IDX_0100,sizeof(SZL_ID_0F12_IDX_0100));break;
                   case 0x0200 : SZLData(&SZL_ID_0F12_IDX_0200,sizeof(SZL_ID_0F12_IDX_0200));break;
                   case 0x0400 : SZLData(&SZL_ID_0F12_IDX_0400,sizeof(SZL_ID_0F12_IDX_0400));break;
                   default     : SZLNotAvailable();break;
                  };break;
    case 0x0113 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0113_IDX_0001,sizeof(SZL_ID_0113_IDX_0001));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0115 : switch(SZL.Index){
                    case 0x0800 : SZLData(&SZL_ID_0115_IDX_0800,sizeof(SZL_ID_0115_IDX_0800));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x011C : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_011C_IDX_0001,sizeof(SZL_ID_011C_IDX_0001));break;
                    case 0x0002 : SZLData(&SZL_ID_011C_IDX_0002,sizeof(SZL_ID_011C_IDX_0002));break;
                    case 0x0003 : SZLData(&SZL_ID_011C_IDX_0003,sizeof(SZL_ID_011C_IDX_0003));break;
                    case 0x0004 : SZLData(&SZL_ID_011C_IDX_0004,sizeof(SZL_ID_011C_IDX_0004));break;
                    case 0x0005 : SZLData(&SZL_ID_011C_IDX_0005,sizeof(SZL_ID_011C_IDX_0005));break;
                    case 0x0007 : SZLData(&SZL_ID_011C_IDX_0007,sizeof(SZL_ID_011C_IDX_0007));break;
                    case 0x0008 : SZLData(&SZL_ID_011C_IDX_0008,sizeof(SZL_ID_011C_IDX_0008));break;
                    case 0x0009 : SZLData(&SZL_ID_011C_IDX_0009,sizeof(SZL_ID_011C_IDX_0009));break;
                    case 0x000A : SZLData(&SZL_ID_011C_IDX_000A,sizeof(SZL_ID_011C_IDX_000A));break;
                    case 0x000B : SZLData(&SZL_ID_011C_IDX_000B,sizeof(SZL_ID_011C_IDX_000B));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0222 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0222_IDX_0001,sizeof(SZL_ID_0222_IDX_0001));break;
                    case 0x000A : SZLData(&SZL_ID_0222_IDX_000A,sizeof(SZL_ID_0222_IDX_000A));break;
                    case 0x0014 : SZLData(&SZL_ID_0222_IDX_0014,sizeof(SZL_ID_0222_IDX_0014));break;
                    case 0x0028 : SZLData(&SZL_ID_0222_IDX_0028,sizeof(SZL_ID_0222_IDX_0028));break;
                    case 0x0050 : SZLData(&SZL_ID_0222_IDX_0050,sizeof(SZL_ID_0222_IDX_0050));break;
                    case 0x0064 : SZLData(&SZL_ID_0222_IDX_0064,sizeof(SZL_ID_0222_IDX_0064));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0125 : switch(SZL.Index){
                    case 0x0000 : SZLData(&SZL_ID_0125_IDX_0000,sizeof(SZL_ID_0125_IDX_0000));break;
                    case 0x0001 : SZLData(&SZL_ID_0125_IDX_0001,sizeof(SZL_ID_0125_IDX_0001));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0225 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0225_IDX_0001,sizeof(SZL_ID_0225_IDX_0001));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0131 : switch(SZL.Index){
					case 0x0001 : SZLData(&SZL_ID_0131_IDX_0001,sizeof(SZL_ID_0131_IDX_0001));break;
					case 0x0002 : SZLData(&SZL_ID_0131_IDX_0002,sizeof(SZL_ID_0131_IDX_0002));break;
					case 0x0003 : SZL_ID131_IDX003();break;
                    case 0x0004 : SZLData(&SZL_ID_0131_IDX_0004,sizeof(SZL_ID_0131_IDX_0004));break;
                    case 0x0005 : SZLData(&SZL_ID_0131_IDX_0005,sizeof(SZL_ID_0131_IDX_0005));break;
                    case 0x0006 : SZLData(&SZL_ID_0131_IDX_0006,sizeof(SZL_ID_0131_IDX_0006));break;
                    case 0x0007 : SZLData(&SZL_ID_0131_IDX_0007,sizeof(SZL_ID_0131_IDX_0007));break;
                    case 0x0008 : SZLData(&SZL_ID_0131_IDX_0008,sizeof(SZL_ID_0131_IDX_0008));break;
                    case 0x0009 : SZLData(&SZL_ID_0131_IDX_0009,sizeof(SZL_ID_0131_IDX_0009));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0117 : switch(SZL.Index){
                     case 0x0000 : SZLData(&SZL_ID_0117_IDX_0000,sizeof(SZL_ID_0117_IDX_0000));break;
                     case 0x0001 : SZLData(&SZL_ID_0117_IDX_0001,sizeof(SZL_ID_0117_IDX_0001));break;
                     case 0x0002 : SZLData(&SZL_ID_0117_IDX_0002,sizeof(SZL_ID_0117_IDX_0002));break;
                     case 0x0003 : SZLData(&SZL_ID_0117_IDX_0003,sizeof(SZL_ID_0117_IDX_0003));break;
                     case 0x0004 : SZLData(&SZL_ID_0117_IDX_0004,sizeof(SZL_ID_0117_IDX_0004));break;
                     default     : SZLNotAvailable();break;
                   };break;
    case 0x0118 : switch(SZL.Index){
                     case 0x0000 : SZLData(&SZL_ID_0118_IDX_0000,sizeof(SZL_ID_0118_IDX_0000));break;
                     case 0x0001 : SZLData(&SZL_ID_0118_IDX_0001,sizeof(SZL_ID_0118_IDX_0001));break;
                     case 0x0002 : SZLData(&SZL_ID_0118_IDX_0002,sizeof(SZL_ID_0118_IDX_0002));break;
                     case 0x0003 : SZLData(&SZL_ID_0118_IDX_0003,sizeof(SZL_ID_0118_IDX_0003));break;
                     default     : SZLNotAvailable();break;
                   };break;
    case 0x0132 : switch(SZL.Index){
                     case 0x0001 : SZLData(&SZL_ID_0132_IDX_0001,sizeof(SZL_ID_0132_IDX_0001));break;
                     case 0x0002 : SZLData(&SZL_ID_0132_IDX_0002,sizeof(SZL_ID_0132_IDX_0002));break;
                     case 0x0003 : SZLData(&SZL_ID_0132_IDX_0003,sizeof(SZL_ID_0132_IDX_0003));break;
                     case 0x0004 : SZLData(&SZL_ID_0132_IDX_0004,sizeof(SZL_ID_0132_IDX_0004));break;
                     case 0x0005 : SZLData(&SZL_ID_0132_IDX_0005,sizeof(SZL_ID_0132_IDX_0005));break;
                     case 0x0006 : SZLData(&SZL_ID_0132_IDX_0006,sizeof(SZL_ID_0132_IDX_0006));break;
                     case 0x0007 : SZLData(&SZL_ID_0132_IDX_0007,sizeof(SZL_ID_0132_IDX_0007));break;
                     case 0x0008 : SZLData(&SZL_ID_0132_IDX_0008,sizeof(SZL_ID_0132_IDX_0008));break;
                     case 0x0009 : SZLData(&SZL_ID_0132_IDX_0009,sizeof(SZL_ID_0132_IDX_0009));break;
                     case 0x000A : SZLData(&SZL_ID_0132_IDX_000A,sizeof(SZL_ID_0132_IDX_000A));break;
                     case 0x000B : SZLData(&SZL_ID_0132_IDX_000B,sizeof(SZL_ID_0132_IDX_000B));break;
                     case 0x000C : SZLData(&SZL_ID_0132_IDX_000C,sizeof(SZL_ID_0132_IDX_000C));break;
                     default     : SZLNotAvailable();break;
                   };break;
    case 0x0137 : switch(SZL.Index){
                    case 0x07FE : SZLData(&SZL_ID_0137_IDX_07FE,sizeof(SZL_ID_0137_IDX_07FE));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x01A0 : switch(SZL.Index){
                     case 0x0000 : SZLData(&SZL_ID_01A0_IDX_0000,sizeof(SZL_ID_01A0_IDX_0000));break;
                     case 0x0001 : SZLData(&SZL_ID_01A0_IDX_0001,sizeof(SZL_ID_01A0_IDX_0001));break;
                     case 0x0002 : SZLData(&SZL_ID_01A0_IDX_0002,sizeof(SZL_ID_01A0_IDX_0002));break;
                     case 0x0003 : SZLData(&SZL_ID_01A0_IDX_0003,sizeof(SZL_ID_01A0_IDX_0003));break;
                     case 0x0004 : SZLData(&SZL_ID_01A0_IDX_0004,sizeof(SZL_ID_01A0_IDX_0004));break;
                     case 0x0005 : SZLData(&SZL_ID_01A0_IDX_0005,sizeof(SZL_ID_01A0_IDX_0005));break;
                     case 0x0006 : SZLData(&SZL_ID_01A0_IDX_0006,sizeof(SZL_ID_01A0_IDX_0006));break;
                     case 0x0007 : SZLData(&SZL_ID_01A0_IDX_0007,sizeof(SZL_ID_01A0_IDX_0007));break;
                     case 0x0008 : SZLData(&SZL_ID_01A0_IDX_0008,sizeof(SZL_ID_01A0_IDX_0008));break;
                     case 0x0009 : SZLData(&SZL_ID_01A0_IDX_0009,sizeof(SZL_ID_01A0_IDX_0009));break;
                     case 0x000A : SZLData(&SZL_ID_01A0_IDX_000A,sizeof(SZL_ID_01A0_IDX_000A));break;
                     case 0x000B : SZLData(&SZL_ID_01A0_IDX_000B,sizeof(SZL_ID_01A0_IDX_000B));break;
                     case 0x000C : SZLData(&SZL_ID_01A0_IDX_000C,sizeof(SZL_ID_01A0_IDX_000C));break;
                     case 0x000D : SZLData(&SZL_ID_01A0_IDX_000D,sizeof(SZL_ID_01A0_IDX_000D));break;
                     case 0x000E : SZLData(&SZL_ID_01A0_IDX_000E,sizeof(SZL_ID_01A0_IDX_000E));break;
                     case 0x000F : SZLData(&SZL_ID_01A0_IDX_000F,sizeof(SZL_ID_01A0_IDX_000F));break;
                     case 0x0010 : SZLData(&SZL_ID_01A0_IDX_0010,sizeof(SZL_ID_01A0_IDX_0010));break;
                     case 0x0011 : SZLData(&SZL_ID_01A0_IDX_0011,sizeof(SZL_ID_01A0_IDX_0011));break;
                     case 0x0012 : SZLData(&SZL_ID_01A0_IDX_0012,sizeof(SZL_ID_01A0_IDX_0012));break;
                     case 0x0013 : SZLData(&SZL_ID_01A0_IDX_0013,sizeof(SZL_ID_01A0_IDX_0013));break;
                     case 0x0014 : SZLData(&SZL_ID_01A0_IDX_0014,sizeof(SZL_ID_01A0_IDX_0014));break;
                     case 0x0015 : SZLData(&SZL_ID_01A0_IDX_0015,sizeof(SZL_ID_01A0_IDX_0015));break;
                     default     : SZLNotAvailable();break;
                   };break;
    case 0x0174 : switch(SZL.Index){
                    case 0x0001 : SZLData(&SZL_ID_0174_IDX_0001,sizeof(SZL_ID_0174_IDX_0001));break;
                    case 0x0004 : SZLData(&SZL_ID_0174_IDX_0004,sizeof(SZL_ID_0174_IDX_0004));break;
                    case 0x0005 : SZLData(&SZL_ID_0174_IDX_0005,sizeof(SZL_ID_0174_IDX_0005));break;
                    case 0x0006 : SZLData(&SZL_ID_0174_IDX_0006,sizeof(SZL_ID_0174_IDX_0006));break;
                    case 0x000B : SZLData(&SZL_ID_0174_IDX_000B,sizeof(SZL_ID_0174_IDX_000B));break;
                    case 0x000C : SZLData(&SZL_ID_0174_IDX_000C,sizeof(SZL_ID_0174_IDX_000C));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0194 : switch(SZL.Index){
                    case 0x0064 : SZLData(&SZL_ID_0194_IDX_0064,sizeof(SZL_ID_0194_IDX_0064));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0694 : switch(SZL.Index){
                    case 0x0064 : SZLData(&SZL_ID_0694_IDX_0064,sizeof(SZL_ID_0694_IDX_0064));break;
                    default     : SZLNotAvailable();break;
                  };break;
    case 0x0232 : switch(SZL.Index){
                     case 0x0001 : SZLData(&SZL_ID_0232_IDX_0001,sizeof(SZL_ID_0232_IDX_0001));break;
                     case 0x0004 : SZLData(&SZL_ID_0232_IDX_0004,sizeof(SZL_ID_0232_IDX_0004));break;
                     default     : SZLNotAvailable();break;
                   };break;
    case 0x0C91 : switch(SZL.Index){
                    case 0x07FE : SZLData(&SZL_ID_0C91_IDX_07FE,sizeof(SZL_ID_0C91_IDX_07FE));break;
                    default     : SZLNotAvailable();break;
                  };break;
    default : SZLNotAvailable();break;
  }
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformGroupSZL()
{
  SZLSetup();

  if (not SZLSubFuncRead()) {
    return true;
  }


  if (SZL.ReqParams->Seq == 0x00 && SZL.ReqParams->Plen == 0x04){
    // This seems to be a new SZL request
    SZL.ReqData=PS7ReqSZLData(pbyte(PDUH_in)+ReqHeaderSize+sizeof(TReqFunReadSZLFirst));// Data after params
    SZL.ID=SwapWord(SZL.ReqData->ID);
    SZL.Index=SwapWord(SZL.ReqData->Index);

    // Prepare all needed packets to answer this SZL request and send the first
    // one
    if( FServer->useSZLCache ) {
        SZLUseCacheFile();
    } else {
        SZLUseSnap7SZLs();
    }

  } else if (SZL.ReqParams->Seq > 0 && SZL.ReqParams->Plen == 0x08){
    // We are receiving a packet that asks for continuation of a former SZL
    // request. In this case, the data after the parameters is irrelevant, we
    // send out what has been saved for this sequence number.
    SZLSendContinuation(SZL.ReqParams->Seq);
  }


  // Event
  if (SZL.SZLDone)
      DoEvent(evcReadSZL,evrNoError,SZL.ID,SZL.Index,0,0);
  else
      DoEvent(evcReadSZL,evrInvalidSZL,SZL.ID,SZL.Index,0,0);
  return true;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformGroupSecurity()
{
    PReqFunSecurity ReqParams;
    PResParamsSecurity ResParams;
    PResDataSecurity ResData;
    TS7Answer17 Answer;
    int TotalSize;

    ReqParams=PReqFunSecurity(pbyte(PDUH_in)+ReqHeaderSize);
    ResParams=PResParamsSecurity(pbyte(&Answer)+ResHeaderSize17);
    ResData  =PResDataSecurity(pbyte(ResParams)+sizeof(TResParamsSecurity));

    // Prepares the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=PduType_userdata;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen =SwapWord(sizeof(TResParamsSecurity));
    Answer.Header.DataLen=SwapWord(0x0004);
    // Params
    ResParams->Head[0]=ReqParams->Head[0];
    ResParams->Head[1]=ReqParams->Head[1];
    ResParams->Head[2]=ReqParams->Head[2];
    ResParams->Plen  =0x08;
    ResParams->Uk    =0x12;
    ResParams->Tg    =0x85; // Type response, group functions info
    ResParams->SubFun=ReqParams->SubFun;
    ResParams->Seq   =ReqParams->Seq;
    ResParams->resvd =0x0000;
    ResParams->Err   =0x0000;
    // Data
    ResData->Ret =0x0A;
    ResData->TS  =0x00;
    ResData->DLen=0x0000;

    TotalSize=26;
    isoSendBuffer(&Answer,TotalSize);

    switch (ReqParams->SubFun)
    {
      case SFun_EnterPwd  : DoEvent(evcSecurity,evrNoError,evsSetPassword,0,0,0); break;
      case SFun_CancelPwd : DoEvent(evcSecurity,evrNoError,evsClrPassword,0,0,0); break;
      default             : DoEvent(evcSecurity,evrNoError,evsUnknown,0,0,0);
    };

    return true;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformGetClock()
{
    PS7ReqParams7 ReqParams;
    PS7ResParams7 ResParams;
    TS7Answer17 Answer;
    PResDataGetTime Data;
    PS7Time PTime;
    int TotalSize;

    ReqParams=PS7ReqParams7(pbyte(PDUH_in)+ReqHeaderSize);
    ResParams=PS7ResParams7(pbyte(&Answer)+ResHeaderSize17);
    Data     =PResDataGetTime(pbyte(&Answer)+ResHeaderSize17+sizeof(TS7Params7));
    PTime    =PS7Time(pbyte(Data)+6);

    // Prepares the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=PduType_userdata;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen =SwapWord(sizeof(TS7Params7));
    Answer.Header.DataLen=SwapWord(sizeof(TResDataGetTime));

    ResParams->Head[0]=ReqParams->Head[0];
    ResParams->Head[1]=ReqParams->Head[1];
    ResParams->Head[2]=ReqParams->Head[2];
    ResParams->Plen  =0x08;
    ResParams->Uk    =0x12;
    ResParams->Tg    =0x87; // Type response, group functions info
    ResParams->SubFun=ReqParams->SubFun;
    ResParams->Seq   =ReqParams->Seq;
    ResParams->resvd =0x0000;
    ResParams->Err   =0x0000;

    Data->RetVal     =0xFF;
    Data->TSize      =TS_ResOctet;
    Data->Length     =SwapWord(10);
    Data->Rsvd       =0x00;
    Data->HiYear     =0x20; // Year 2000 +
    FillTime(PTime);

    TotalSize=36;
    isoSendBuffer(&Answer,TotalSize);
    DoEvent(evcClock,evrNoError,evsGetClock,0,0,0);
    return true;
}
//------------------------------------------------------------------------------
bool TS7Worker::PerformSetClock()
{
    PS7ReqParams7 ReqParams;
    PS7ResParams7 ResParams;
    PResDataSetTime Data;
    TS7Answer17 Answer;
    int TotalSize;

    ReqParams=PS7ReqParams7(pbyte(PDUH_in)+ReqHeaderSize);
    ResParams=PS7ResParams7(pbyte(&Answer)+ResHeaderSize17);
    Data     =PResDataSetTime(pbyte(&Answer)+ResHeaderSize17+sizeof(TS7Params7));

    // Prepares the answer
    Answer.Header.P=0x32;
    Answer.Header.PDUType=PduType_userdata;
    Answer.Header.AB_EX=0x0000;
    Answer.Header.Sequence=PDUH_in->Sequence;
    Answer.Header.ParLen =SwapWord(sizeof(TS7Params7));
    Answer.Header.DataLen=SwapWord(sizeof(TResDataSetTime));

    ResParams->Head[0]=ReqParams->Head[0];
    ResParams->Head[1]=ReqParams->Head[1];
    ResParams->Head[2]=ReqParams->Head[2];
    ResParams->Plen  =0x08;
    ResParams->Uk    =0x12;
    ResParams->Tg    =0x87; // Type response, group functions info
    ResParams->SubFun=ReqParams->SubFun;
    ResParams->Seq   =ReqParams->Seq;
    ResParams->resvd =0x0000;
    ResParams->Err   =0x0000;

    Data->RetVal     =0x0A;
    Data->TSize      =0x00;
    Data->Length     =0x0000;

    TotalSize=26;
    isoSendBuffer(&Answer,TotalSize);
    DoEvent(evcClock,evrNoError,evsSetClock,0,0,0);
    return true;
}
//------------------------------------------------------------------------------
// S7 SERVER CLASS
//------------------------------------------------------------------------------
TSnap7Server::TSnap7Server()
{
    OnReadEvent=NULL;
    AddedDiagItemCount=0;
    CSDiag = new TSnapCriticalSection();
    CSRWHook = new TSnapCriticalSection();
    AddDiagItem(SZL_DIAG_START);
    memset(&HA,0,sizeof(HA));
    DBArea = new PS7AreaContainer(MaxDB-1);
    OB = new PS7AreaContainer(MaxDB-1);
    FB = new PS7AreaContainer(MaxDB-1);
    FC = new PS7AreaContainer(MaxDB-1);
    SDB = new PS7AreaContainer(MaxDB-1);
    ForcePDU = 0;
    ResourceLess = false;
    LocalPort=isoTcpPort;
    WorkInterval=100;
    for (int i = 0; i < CustomSZL; i++) {
        SZLs[i].Len = -1;
    }
    SetCpuStatus(S7CpuStatusRun);
}
//------------------------------------------------------------------------------
TSnap7Server::~TSnap7Server()
{
    DisposeAll();
	delete CSRWHook;
}
//------------------------------------------------------------------------------
PWorkerSocket TSnap7Server::CreateWorkerSocket(socket_t Sock)
{
    PWorkerSocket Result;
    Result = new TS7Worker();
    Result->SetSocket(Sock);
    PS7Worker(Result)->FServer=this;
    return Result;
}
//------------------------------------------------------------------------------
// Item must be DiagItemLength bytes long!
void TSnap7Server::AddDiagItem(pbyte Item)
{
    // add item in reverse order (start at bottom)
    int i = pmod(MaxDiagBufferItems - AddedDiagItemCount - 1, MaxDiagBufferItems);

    memcpy(&DiagBuffer[i][0], Item, DiagItemLength);
    FillTime(PS7Time(&DiagBuffer[i][12]));

    AddedDiagItemCount++;
}
//------------------------------------------------------------------------------
uint TSnap7Server::GetDiagItemCount() {
    return AddedDiagItemCount > MaxDiagBufferItems ? MaxDiagBufferItems : AddedDiagItemCount;
}
//------------------------------------------------------------------------------
byte TSnap7Server::GetNextSeqNr() {
    if (++sequence_nr == 0xFF){
        sequence_nr = 0x00;
        return 0xFF;
    }
    return sequence_nr;
}
//------------------------------------------------------------------------------
byte TSnap7Server::GetCurrentSeqNr() {
    return sequence_nr;
}
//------------------------------------------------------------------------------
void TSnap7Server::DecrSeqNr(){
    if (sequence_nr != 0x00){
        sequence_nr--;
    }
}
//------------------------------------------------------------------------------
byte TSnap7Server::GetNextDURN(){
    if (++DURN == 0xFF){
        DURN = 0x00;
        return 0xFF;
    }
    return DURN;
}
//------------------------------------------------------------------------------
byte TSnap7Server::GetCurrentDURN(){
    return DURN;
}
//------------------------------------------------------------------------------
// target memory has at least (GetDiagItemCount() * MaxDiagBufferItems) bytes
void TSnap7Server::CopyDiagBuffer(pbyte to)
{
    int start = pmod(MaxDiagBufferItems - AddedDiagItemCount, MaxDiagBufferItems);
    int end = pmod(start + GetDiagItemCount() - 1, MaxDiagBufferItems);

    if (start <= end)
        memcpy(to, &DiagBuffer[start][0], (end - start + 1) * DiagItemLength);
    else
    {
        const int copied = (MaxDiagBufferItems - start) * DiagItemLength;
        memcpy(to, &DiagBuffer[start][0], copied);
        memcpy(&to[copied], &DiagBuffer[0][0], (end + 1) * DiagItemLength);
    }
}
//------------------------------------------------------------------------------
byte TSnap7Server::freeDiagJobID(longword client_id) {
    byte job_id = DIAG_JOB_OFFSET;
    CSDiag->Enter();
    while(diag_requests.count(std::make_pair(client_id, job_id))) {
        job_id++;
    }
    CSDiag->Leave();
    return job_id;
}
//------------------------------------------------------------------------------
byte TSnap7Server::AddDiagRequest(longword id, RequestDiag &rd) {
    byte job_id = freeDiagJobID(id);
    CSDiag->Enter();
    RequestDiag* rdc = new RequestDiag(rd);

    diag_requests[std::make_pair(id, job_id)] = rdc;

    CSDiag->Leave();

    return job_id;
}
//------------------------------------------------------------------------------
void TSnap7Server::RemoveDiagRequest(longword client_id, byte job_id) {
    RequestDiag *rd;
    DiagID diag_id = std::make_pair(client_id, job_id);
    CSDiag->Enter();
    if (diag_requests.count(diag_id)) {
        rd = diag_requests[diag_id];
        delete rd;
        diag_requests.erase(diag_id);
    }
    CSDiag->Leave();
}
//------------------------------------------------------------------------------
RequestDiag* TSnap7Server::GetDiagRequest(longword client_id, byte job_id) {
    RequestDiag* rd;
    DiagID diag_id = std::make_pair(client_id, job_id);
    CSDiag->Enter();
    rd = diag_requests.count(diag_id) ? diag_requests[diag_id] : NULL;
    CSDiag->Leave();
    return rd;
}
//------------------------------------------------------------------------------
int TSnap7Server::AddDiagResponse(longword client_id, byte job_id, ResponseDiag* rd) {
    CSDiag->Enter();
    diag_responses[std::make_pair(client_id, job_id)] = rd;
    CSDiag->Leave();
    return 0;
}
//------------------------------------------------------------------------------
void TSnap7Server::DisposeAll()
{
    delete DBArea;
    delete OB;
    delete FB;
    delete FC;
    delete SDB;
    delete CSDiag;
    for (DiagRequestMap::iterator it = diag_requests.begin(); it != diag_requests.end(); it ++) {
        delete it->second;
    }
    // Unregister other
    for (int c = srvAreaPE; c < srvAreaDB; c++)
        UnregisterSys(c);
}
//------------------------------------------------------------------------------
int TSnap7Server::RegisterSys(int AreaCode, void *pUsrData, word Size)
{
    PS7Area TheArea;

    if (pUsrData==0)
        return errSrvDBNullPointer;

    if ((AreaCode<srvAreaPE) || (AreaCode>srvAreaTM))
        return errSrvUnknownArea;

    if (HA[AreaCode]==0)
    {
    TheArea=new TS7Area;
    TheArea->cs=new TSnapCriticalSection();
    TheArea->PData=pbyte(pUsrData);
    TheArea->Size=Size;
    HA[AreaCode]=TheArea;
    return 0;
    }
    else
        return errSrvAreaAlreadyExists;
}
//------------------------------------------------------------------------------
int TSnap7Server::UnregisterSys(int AreaCode)
{
    PS7Area TheArea;
    if (HA[AreaCode]!=NULL)
    {
        // Unregister should be done with the server in stop mode
        // however we can minimize the risk...
        TheArea=HA[AreaCode];
        HA[AreaCode]=NULL;
        if (TheArea->cs!=NULL)
             delete TheArea->cs;
        delete TheArea;
    }
    return 0;
}
//------------------------------------------------------------------------------
int TSnap7Server::StartTo(const char *Address)
{
    return TCustomMsgServer::StartTo(Address, LocalPort);
}
//------------------------------------------------------------------------------
int TSnap7Server::GetParam(int ParamNumber, void *pValue)
{
    switch (ParamNumber)
    {
    case p_u16_LocalPort:
            *Puint16_t(pValue)=LocalPort;
        break;
    case p_i32_WorkInterval:
        *Pint32_t(pValue)=WorkInterval;
        break;
    case p_i32_MaxClients:
        *Pint32_t(pValue)=MaxClients;
        break;
	case p_i32_PDURequest:
		*Pint32_t(pValue) = ForcePDU;
		break;
	default: return errSrvInvalidParamNumber;
    }
    return 0;
}
//------------------------------------------------------------------------------
int TSnap7Server::SetParam(int ParamNumber, void *pValue)
{
	switch (ParamNumber)
	{
	case p_u16_LocalPort:
		if (Status == SrvStopped)
			LocalPort = *Puint16_t(pValue);
		else
			return errSrvCannotChangeParam;
		break;
	case p_i32_PDURequest:
		if (Status == SrvStopped)
		{
			int PDU = *Pint32_t(pValue);
			if (PDU == 0)
				ForcePDU = 0; // ForcePDU=0 --> The server accepts the client's proposal
			else
				{
					if ((PDU < MinPduSize) || (PDU>IsoPayload_Size))
						return errSrvInvalidParams; // Wrong value
					else
						ForcePDU = PDU; // The server imposes ForcePDU as PDU size
				}
	    }
		else
            return errSrvCannotChangeParam;
		break;
	case p_i32_WorkInterval:
         WorkInterval=*Pint32_t(pValue);
	     break;
	case p_i32_MaxClients:
	     if (ClientsCount==0 && Status==SrvStopped)
	         MaxClients=*Pint32_t(pValue);
         else
	         return errSrvCannotChangeParam;
         break;
	default: return errSrvInvalidParamNumber;
    }
    return 0;
}
//------------------------------------------------------------------------------
void TSnap7Server::UnsetUseSZLCache(){
    useSZLCache = false;
}
//------------------------------------------------------------------------------
void TSnap7Server::SetUseSZLCache(const SZLAnswerMap &cacheRef){
    cache = cacheRef;
    useSZLCache = true;
}
//------------------------------------------------------------------------------
void TSnap7Server::SetSZL(int SZLID, pbyte Val, int Len)
{
    SZLs[SZLID].Val = Val;
    SZLs[SZLID].Len = Len;
}
//------------------------------------------------------------------------------
int TSnap7Server::SetForcePDU(word size)
{
    if (size < MinPduSize) {
        return 1; // Error
    }

    ForcePDU = size;
    return 0; // Success
}
//------------------------------------------------------------------------------
void TSnap7Server::SetCpuStatus(byte State)
{
    if (CpuStatus != State)
    {
        CpuStatus = State;
        FillTime(&LastCPUStateChange);
    }
}
//------------------------------------------------------------------------------
// TODO support SFC, SFB???
int TSnap7Server::AddBlock(void *pBinary, int Size) {
    PS7CompactBlockInfo blockHead = (PS7CompactBlockInfo) pBinary;
    if ((Size < sizeof(TS7CompactBlockInfo))
            || (blockHead->Cst_pp != 0x7070)
            || (SwapDWord(blockHead->LenLoadMem) != Size)
            || ((SwapWord(blockHead->MC7Len) + sizeof(TS7CompactBlockInfo)) >= Size)) {
        return errInvalidBlock;
    }
    int srvArea = -1;
    switch (blockHead->SubBlkType) {
        case SubBlk_OB:
            srvArea = srvAreaOB;
            break;
        case SubBlk_FB:
            srvArea = srvAreaFB;
            break;
        case SubBlk_FC:
            srvArea = srvAreaFC;
            break;
        case SubBlk_DB:
            srvArea = srvAreaDB;
            break;
        case SubBlk_SDB:
            srvArea = srvAreaSDB;
            break;
        default:
            return errInvalidBlock;
    }

    return getArea(srvArea)->Register(SwapWord(blockHead->BlkNum), pBinary, Size);
}
//------------------------------------------------------------------------------
pbyte TSnap7Server::GetBlock(byte BlkType, word BlkNum) {
    PS7AreaContainer *areaContainer = getArea(BlkType);
    if (!areaContainer)
        return NULL;
    PS7Area area = areaContainer->Find(BlkNum);
    return area ? area->PData : NULL;
}
//------------------------------------------------------------------------------
PS7AreaContainer* TSnap7Server::getArea(int srvArea) {
    switch (srvArea) {
        case srvAreaDB:
            return DBArea;
        case srvAreaOB:
            return OB;
        case srvAreaFB:
            return FB;
        case srvAreaFC:
            return FC;
        case srvAreaSDB:
            return SDB;
    }
    return NULL;
}
//------------------------------------------------------------------------------
PS7AreaContainer* TSnap7Server::getArea(byte blkType) {
    switch (blkType) {
        case Block_DB:
            return DBArea;
        case Block_OB:
            return OB;
        case Block_FB:
            return FB;
        case Block_FC:
            return FC;
        case Block_SDB:
            return SDB;
    }
    return NULL;
}
//------------------------------------------------------------------------------
int TSnap7Server::RegisterArea(int AreaCode, word Index, void *pUsrData, word Size)
{
    if (AreaCode==srvAreaDB)
        return DBArea->Register(Index, pUsrData, Size);
    else
        return RegisterSys(AreaCode,pUsrData, Size);
}
//------------------------------------------------------------------------------
int TSnap7Server::UnregisterArea(int AreaCode, word Index)
{
    if (AreaCode==srvAreaDB)
        return DBArea->Unregister(Index);
    else
        if ((AreaCode>=srvAreaPE) && (AreaCode<=srvAreaTM))
            return UnregisterSys(AreaCode);
    else
        return errSrvInvalidParams;
}
//------------------------------------------------------------------------------
int TSnap7Server::LockArea(int AreaCode, word DBNumber)
{
  int index;

  if ((AreaCode>=srvAreaPE) && (AreaCode<=srvAreaTM))
  {
      if (HA[AreaCode]!=0)
      {
          HA[AreaCode]->cs->Enter();
          return 0;
      }
      else
          return errSrvInvalidParams;
  }
  else
      if (AreaCode==srvAreaDB)
      {
          index=DBArea->IndexOf(DBNumber);
          if (index!=-1)
      {
          DBArea->get()[index]->cs->Enter();
          return 0;
      }
      else
          return errSrvInvalidParams;
      }
      else
          return errSrvInvalidParams;
}
//------------------------------------------------------------------------------
int TSnap7Server::UnlockArea(int AreaCode, word DBNumber)
{
  int index;

  if ((AreaCode>=srvAreaPE) && (AreaCode<=srvAreaTM))
  {
      if (HA[AreaCode]!=0)
      {
          HA[AreaCode]->cs->Leave();
          return 0;
      }
      else
          return errSrvInvalidParams;
  }
  else
      if (AreaCode==srvAreaDB)
      {
          index=DBArea->IndexOf(DBNumber);
          if (index!=-1)
      {
          DBArea->get()[index]->cs->Leave();
          return 0;
      }
      else
          return errSrvInvalidParams;
      }
      else
          return errSrvInvalidParams;
}
//------------------------------------------------------------------------------
int TSnap7Server::SetReadEventsCallBack(pfn_SrvCallBack PCallBack, void *UsrPtr)
{
    OnReadEvent = PCallBack;
    FReadUsrPtr = UsrPtr;
    return 0;
}
//---------------------------------------------------------------------------
int TSnap7Server::SetRWAreaCallBack(pfn_RWAreaCallBack PCallBack, void *UsrPtr)
{
	OnRWArea = PCallBack;
	FRWAreaUsrPtr = UsrPtr;
	ResourceLess = OnRWArea != NULL;
	return 0;
}
//---------------------------------------------------------------------------
void TSnap7Server::DoReadEvent(int Sender, longword Code, word RetCode, word Param1,
  word Param2, word Param3, word Param4)
{
    TSrvEvent SrvReadEvent;
    if (!Destroying && (OnReadEvent != NULL))
    {
        CSEvent->Enter();

        time(&SrvReadEvent.EvtTime);
        SrvReadEvent.EvtSender = Sender;
        SrvReadEvent.EvtCode = Code;
        SrvReadEvent.EvtRetCode = RetCode;
        SrvReadEvent.EvtParam1 = Param1;
        SrvReadEvent.EvtParam2 = Param2;
        SrvReadEvent.EvtParam3 = Param3;
        SrvReadEvent.EvtParam4 = Param4;

        try
        { // callback is outside here, we have to shield it
            OnReadEvent(FReadUsrPtr, &SrvReadEvent, sizeof (TSrvEvent));
        } catch (...)
        {
        };
        CSEvent->Leave();
    };
}
//---------------------------------------------------------------------------
bool TSnap7Server::DoReadArea(int Sender, int Area, int DBNumber, int Start, int Size, int WordLen, void *pUsrData)
{
	TS7Tag Tag;
	bool Result = false;
	if (!Destroying && (OnRWArea != NULL))
	{
		CSRWHook->Enter();
		try
		{
			Tag.Area = Area;
			Tag.DBNumber = DBNumber;
			Tag.Start = Start;
			Tag.Size = Size;
			Tag.WordLen = WordLen;
			// callback is outside here, we have to shield it
			Result = OnRWArea(FRWAreaUsrPtr, Sender, OperationRead, &Tag, pUsrData) == 0;
		}
		catch (...)
		{
			Result = false;
		};
		CSRWHook->Leave();
	}
	return Result;
}
//---------------------------------------------------------------------------
bool TSnap7Server::DoWriteArea(int Sender, int Area, int DBNumber, int Start, int Size, int WordLen, void *pUsrData)
{
	TS7Tag Tag;
	bool Result = false;
	if (!Destroying && (OnRWArea != NULL))
	{
		CSRWHook->Enter();
		try
		{
			Tag.Area = Area;
			Tag.DBNumber = DBNumber;
			Tag.Start = Start;
			Tag.Size = Size;
			Tag.WordLen = WordLen;
			// callback is outside here, we have to shield it
			Result = OnRWArea(FRWAreaUsrPtr, Sender, OperationWrite, &Tag, pUsrData) == 0;
		}
		catch (...)
		{
			Result = false;
		};
		CSRWHook->Leave();
	}
	return Result;
}


