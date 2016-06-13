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
#ifndef s7_server_h
#define s7_server_h
//---------------------------------------------------------------------------
#include "snap_tcpsrvr.h"
#include "s7_types.h"
#include "s7_isotcp.h"

#include <memory>

#include <map>
#include <unordered_map>
#include <vector>
#include <list>
//---------------------------------------------------------------------------

// Maximum number of DB, change it to increase/decrease the limit.
// The DB table size is 12*MaxDB bytes

#define MaxDB 2048    // Like a S7 318

// Number of custom SZLs
#define CustomSZL 4

#define MaxDiagBufferItems 99
#define DiagItemLength 20

#define DIAG_JOB_OFFSET 2

// a modulo which is always positive
#define pmod(X,Y)     (X%Y+Y)%Y

#define MinPduSize 240
#define CPU315PduSize 240
//---------------------------------------------------------------------------
// Server Interface errors
const longword errSrvDBNullPointer      = 0x00200000; // Pssed null as PData
const longword errSrvAreaAlreadyExists  = 0x00300000; // Area Re-registration
const longword errSrvUnknownArea        = 0x00400000; // Unknown area
const longword errSrvInvalidParams      = 0x00500000; // Invalid param(s) supplied
const longword errSrvTooManyDB          = 0x00600000; // Cannot register DB
const longword errSrvInvalidParamNumber = 0x00700000; // Invalid param (srv_get/set_param)
const longword errSrvCannotChangeParam  = 0x00800000; // Cannot change because running
const longword errInvalidBlock          = 0x00900000; // Block is not valid

// Server Area ID  (use with Register/unregister - Lock/unlock Area)
const int srvAreaPE = 0;
const int srvAreaPA = 1;
const int srvAreaMK = 2;
const int srvAreaCT = 3;
const int srvAreaTM = 4;
const int srvAreaDB = 5;
const int srvAreaOB = 6;
const int srvAreaFB = 7;
const int srvAreaFC = 8;
const int srvAreaSDB = 9;


typedef struct{
	word   Number; // Number (only for DB)
	word   Size;   // Area size (in bytes)
	pbyte  PData;  // Pointer to area
	PSnapCriticalSection cs;
}TS7Area, *PS7Area;

class PS7AreaContainer {
public:
    PS7Area *area;
    size_t count;
    size_t limit;
    size_t size;
    PS7AreaContainer(size_t size);
    ~PS7AreaContainer();
    PS7Area Find(word Number);
    int FindFirstFree();
    int IndexOf(word Number);
    PS7Area* get(); // TODO remove!
    int Register(word Number, void *pUsrData, word Size);
    int Unregister(word Number);
    void Dispose();
};

//------------------------------------------------------------------------------
// ISOTCP WORKER CLASS
//------------------------------------------------------------------------------
class TIsoTcpWorker : public TIsoTcpSocket
{
protected:
	virtual bool IsoPerformCommand(int &Size);
	virtual bool ExecuteSend();
	virtual bool ExecuteRecv();
public:
	TIsoTcpWorker(){};
	~TIsoTcpWorker(){};
	// Worker execution
	bool Execute();
};
//------------------------------------------------------------------------------
// S7 WORKER CLASS
//------------------------------------------------------------------------------

// Keeps SZL continuation data if SZL has to be send over multiple packets
// because of PDU size
typedef std::unordered_map
    <byte, std::list<std::vector<byte>>> TSZLFragmentMap;

// SZL frame
typedef struct{
    TS7Answer17         Answer;
    PReqFunReadSZLFirst ReqParams;
    PS7ReqSZLData       ReqData;
    PS7ResParams7       ResParams;
    pbyte               ResData;
    int                 ID;
    int                 Index;
    bool                SZLDone;
}TSZL;

// Current Event Info
typedef struct{
    word EvRetCode;
    word EvArea;
    word EvIndex;
    word EvStart;
    word EvSize;
}TEv;

// Current Block info
typedef struct{
  PReqFunGetBlockInfo ReqParams;
  PResFunGetBlockInfo ResParams;
  TS7Answer17         Answer;
  word                evError;
  word                DataLength;
}TCB;

/// custom SZL entry
typedef struct {
	pbyte Val;
	int Len;
}TCSZL;

// Identifier used to find SZLs in a hashmap
typedef uint32_t TSZLKey;

// Map used to save loaded SZL answers
typedef std::unordered_map
        <TSZLKey, std::vector<byte> > SZLAnswerMap;

typedef enum : byte {
    // TODO add other types
    VT_M  = 0x0,
    VT_E  = 0x1,
    VT_A  = 0x2,
    VT_DB = 0x7
} VarTabMemoryArea;

typedef struct {
    VarTabMemoryArea memory_area_and_dt_width;
    byte repetition_factor;
    word db_number;
    word start_address;
    VarTabMemoryArea getMemoryArea() {
        return (VarTabMemoryArea) (memory_area_and_dt_width >> 4);
    }
    byte getDataTypeLength() {
        return memory_area_and_dt_width & 0x0F;
    }
} VarTabItem;

class TSnap7Server; // forward declaration

class TS7Worker : public TIsoTcpWorker
{
private:
    PS7ReqHeader PDUH_in;
	int DBCnt;
    byte LastBlk;
    TSZL SZL;
    TSZLFragmentMap FragmentMap;
    byte BCD(word Value);
    // Checks the consistence of the incoming PDU
    bool CheckPDU_in(int PayloadSize);
    size_t copyDiagDataLine(pbyte to, byte registers, bool add_offset, DiagDataLine* ddl);
    void FillTime(PS7Time PTime);
protected:
    int DataSizeByte(int WordLength);
    bool ExecuteRecv();
    void DoEvent(longword Code, word RetCode, word Param1, word Param2,
      word Param3, word Param4);
    void DoReadEvent(longword Code, word RetCode, word Param1, word Param2,
      word Param3, word Param4);
    void FragmentSkipped(int Size);
    // Entry parse
    bool IsoPerformCommand(int &Size);
    // First stage parse
    bool PerformPDUAck(int &Size);
    bool PerformPDURequest(int &Size);
    bool PerformPDUUsrData(int &Size);
    // Second stage parse : PDU Request
    PS7Area GetArea(byte S7Code, word index);
    // Group Read Area
    bool PerformFunctionRead();
    // Subfunctions Read Data
    word ReadArea(PResFunReadItem ResItemData, PReqFunReadItem ReqItemPar,
    int &PDURemainder,TEv &EV);
    word RA_NotFound(PResFunReadItem ResItem, TEv &EV);
    word RA_OutOfRange(PResFunReadItem ResItem, TEv &EV);
    word RA_SizeOverPDU(PResFunReadItem ResItem, TEv &EV);
    // Group Write Area
    bool PerformFunctionWrite();
    // Subfunctions Write Data
    byte WriteArea(PReqFunWriteDataItem ReqItemData, PReqFunWriteItem ReqItemPar,
         TEv &EV);
    byte WA_NotFound(TEv &EV);
    byte WA_InvalidTransportSize(TEv &EV);
    byte WA_OutOfRange(TEv &EV);
    byte WA_DataSizeMismatch(TEv &EV);
    // Negotiate PDU Length
    bool PerformFunctionNegotiate();
    // Control
    bool PerformFunctionControl(byte PduFun);
    // Up/Download
	bool PerformFunctionUpload();
    bool PerformFunctionDownload();
    // Second stage parse : PDU User data
    bool PerformGroupProgrammer();
    bool PerformGroupCyclicData();
    bool PerformGroupSecurity();
    // Group Block(s) Info
    bool PerformGroupBlockInfo();
    // Subfunctions Block info
    void BLK_ListAll(TCB &CB);
    void BLK_ListBoT(byte BlockType, bool Start, TCB &CB);
    void BLK_NoResource_ListBoT(PDataFunGetBot Data, TCB &CB);
    void BLK_GetBlkInfo(TCB &CB);
    void BLK_NoResource_GetBlkInfo(PResDataBlockInfo Data, TCB &CB);
    void BLK_GetBlockNum_GetBlkInfo(int &BlkNum, PReqDataBlockInfo ReqData);
    void BLK_DoBlockInfo_GetBlkInfo(PS7Area DB, PResDataBlockInfo Data, TCB &CB);
    // Clock Group
    bool PerformGetClock();
    bool PerformSetClock();
    // SZL Group
    bool PerformGroupSZL();
    // Subfunctions (called by PerformGroupSZL)
    //
    /*
     * Set up some fields needed for the SZL answer
     */
    void SZLSetup(void);
    /* Returns true if the subfunction for an SZL request is for "read SZL" */
    bool SZLSubFuncRead(void);
    /*
     * Handles an SZL request using an external Cache file for answers
     */
    void SZLUseCacheFile();
    /*
     * Handles an SZL request using the SNAP7 SZL entries for answers
     */
    void SZLUseSnap7SZLs();
    /*
     * Prepares the header for our SZL answer.
     *
     * Parameters:
     *
     *      bool is_first       : Is this the first packet for an SZL answer?
     *      bool is_last        : Is this the last  packet for an SZL answer?
     *      word dataSize       : The size of all the SZL data that is to be
     *                            send in this packet.
     *
     * Returns:
     *
     *      uint16_t             : Complete size of the full S7-Com PDU for the
     *                            SZL-answer packet.
     */
    uint16_t SZLPrepareAnswerHeader(bool is_first, bool is_last, uint16_t dataSize);
    /*
     * Sends the first packet of an Answer to an SZL request and prepares all
     * other needed parts so they can be sent using SZLSendContinuation
     */
    void SZLSendAnswer(const pbyte buffer, const uint16_t buflen);
    void SZLSendContinuation(const byte sequence_nr);
    void SZLNotAvailable();
    void SZLSystemState();
    void SZLData(void *P, int len);
    void SZLDataFromCache(const std::vector<byte> &dataptr);
    void SZLCData(int SZLID, void *P, int len);
    void SZL_ID0A0();
    void SZL_ID124();
    void SZL_ID424();
	void SZL_ID131_IDX003();
	void SZL_ID0132_IDX0008();
    /*
     * Takes an SZL key  ( A 32bit int representing <ID><Index> ) and transforms
     * it into ( <0xFFFF><ID>)
     *
     */
    TSZLKey toHeader(TSZLKey toTransform);
public:
    TSnap7Server *FServer;
    int FPDULength;
    TS7Worker();
    ~TS7Worker(){};
};

typedef TS7Worker *PS7Worker;
//------------------------------------------------------------------------------
// S7 SERVER CLASS
//------------------------------------------------------------------------------
typedef std::pair<longword, byte> DiagID;
typedef std::map<DiagID, RequestDiag*> DiagRequestMap;
typedef std::map<DiagID, ResponseDiag*> DiagResponseMap;

extern "C"
{
	typedef int (S7API *pfn_RWAreaCallBack)(void *usrPtr, int Sender, int Operation, PS7Tag PTag, void *pUsrData);
}
const int OperationRead  = 0;
const int OperationWrite = 1;

class TSnap7Server : public TCustomMsgServer
{
private:
    // Read Callback related
    pfn_SrvCallBack OnReadEvent;
    pfn_RWAreaCallBack OnRWArea;
    // Critical section to lock Read/Write Hook Area
    PSnapCriticalSection CSRWHook;
    void *FReadUsrPtr;
    void *FRWAreaUsrPtr;
    void DisposeAll();
    // ring buffer for diagnostic messages
    byte DiagBuffer[MaxDiagBufferItems][DiagItemLength];
    uint AddedDiagItemCount;
    PSnapCriticalSection CSDiag;
    DiagRequestMap diag_requests;
    DiagResponseMap diag_responses;
    uint GetDiagItemCount();
    byte freeDiagJobID(longword client_id);
    // An unordered map with SZL answers keyed by ID and INDEX
    SZLAnswerMap cache;
    bool useSZLCache = false;
    byte sequence_nr      = 0;
    byte DURN             = 0;
    // methods to get/free sequence numbers and get DUR numbers
    // TODO right now, get/free seqnr is very primitive and does not account
    // for multiple parallel sequence nr. in use, as well as freeing a seqnr
    // "out of order". If this is needed, these methods need to be modified to
    // account for that.
    byte GetNextSeqNr();
    byte GetCurrentSeqNr();
    // Decrease Sequence nr by 1
    void DecrSeqNr();
    // TODO right now, get DURN methods are very primitive and don't account
    // for having to manage multiple DURNs in parallel. If this is needed, these
    // methods need to be adjusted for that.
    // Increase DURN and return value
    byte GetNextDURN();
    // Return current DURN
    byte GetCurrentDURN();
protected:
    PS7AreaContainer *DBArea;
    PS7AreaContainer *OB, *FB, *FC, *SDB;
    // TODO replace HA with container
    PS7Area HA[5];     // MK,PE,PA,TM,CT
    TCSZL SZLs[CustomSZL];
    TS7Time LastCPUStateChange;
    PWorkerSocket CreateWorkerSocket(socket_t Sock);
    int RegisterSys(int AreaCode, void *pUsrData, word Size);
    int UnregisterSys(int AreaCode);
    byte AddDiagRequest(longword id, RequestDiag &rd);
    void RemoveDiagRequest(longword client_id, byte job_id);
    // The Read event
    void DoReadEvent(int Sender, longword Code, word RetCode, word Param1,
      word Param2, word Param3, word Param4);
    bool ResourceLess;
    word ForcePDU;
    bool DoReadArea(int Sender, int Area, int DBNumber, int Start, int Size, int WordLen, void *pUsrData);
    bool DoWriteArea(int Sender, int Area, int DBNumber, int Start, int Size, int WordLen, void *pUsrData);
public:
    int WorkInterval;
    byte CpuStatus;
    TSnap7Server();
    ~TSnap7Server();
    int StartTo(const char *Address);
    int GetParam(int ParamNumber, void *pValue);
    int SetParam(int ParamNumber, void *pValue);
    void SetSZL(int SZLID, pbyte val, int len);
    /*
     * Sets the PDU-size that should be forced from this server in PDU
     * negotiation. This means this server will always use this PDU size for its
     * packets.
     * In case the PDU size can't be set to size (i.e. size is smaller than the
     * minimum allowed PDU size) nothing is changed.
     *
     * Returns:
     *          0 on Success
     *          1 on Failure
     */
    int SetForcePDU(word size);
    // If set, this will use the new SZL cache for answering SZL-queries
    // Needs to be supplied a cache to use.
    void SetUseSZLCache(const SZLAnswerMap& cache);
    // Unsets the use of the SZLCache, falling back to default snap7 behaviour.
    void UnsetUseSZLCache();
    void SetCpuStatus(byte State);
    int AddBlock(void *pBinary, int Size);
    void AddDiagItem(pbyte Item);
    pbyte GetBlock(byte BlkType, word BlkNum);
    PS7AreaContainer* getArea(int srvArea);
    PS7AreaContainer* getArea(byte blkType);
    int RegisterArea(int AreaCode, word Index, void *pUsrData, word Size);
    int UnregisterArea(int AreaCode, word Index);
    int LockArea(int AreaCode, word DBNumber);
    int UnlockArea(int AreaCode, word DBNumber);
    void CopyDiagBuffer(pbyte to);
    // Sets Event callback
    int SetReadEventsCallBack(pfn_SrvCallBack PCallBack, void *UsrPtr);
    RequestDiag* GetDiagRequest(longword client_id, byte job_id);
    int AddDiagResponse(longword client_id, byte job_id, ResponseDiag* rd);
    int SetRWAreaCallBack(pfn_RWAreaCallBack PCallBack, void *UsrPtr);
    friend class TS7Worker;
};
typedef TSnap7Server *PSnap7Server;

#endif // s7_server_h

