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
#include "s7_text.h"
//---------------------------------------------------------------------------
#ifndef OS_WINDOWS
static char* itoa(int value, char* result, int base) {
	// check that the base if valid
	if (base < 2 || base > 36){
		*result = '\0'; return result;

	}
	char* ptr = result, *ptr1 = result, tmp_char;
	int tmp_value;

	do {
		tmp_value = value;
		value /= base;
		*ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
	} while ( value );

	// Apply negative sign
	if (tmp_value < 0) *ptr++ = '-';
	*ptr-- = '\0';
	while(ptr1 < ptr) {
		tmp_char = *ptr;
		*ptr--= *ptr1;
		*ptr1++ = tmp_char;
	}
	return result;
}
#endif
//---------------------------------------------------------------------------
BaseString NumToString(int Value, int Base, unsigned int Len)
{
	char CNumber[50];
	BaseString result;
	itoa(Value,CNumber,Base);
	result.assign(CNumber);
	if (Len>0)
	{
		while (result.length()<Len)
            result="0"+result;
	}
	return result;
}
//---------------------------------------------------------------------------
BaseString IntToString(int Value)
{
	return NumToString(Value, 10, 0);
}
//---------------------------------------------------------------------------
BaseString TimeToString(time_t dt)
{
    char dts[50];
    BaseString Result;
    struct tm * DateTime = localtime (&dt);
    if (DateTime!=NULL) {
        strftime(dts,50,"%Y-%m-%d %H:%M:%S",DateTime);
        Result.assign(dts);
        return Result;
    }
    else
        return "";
}
//---------------------------------------------------------------------------
BaseString IpAddressToString(int IP)
{
    in_addr Addr;
    BaseString Result;
    Addr.s_addr=IP;
    Result.assign(inet_ntoa(Addr));
    return Result;
}
//---------------------------------------------------------------------------
#define WSAEINVALIDADDRESS   12001

static BaseString TcpTextOf(int Error)
{
    switch (Error)
    {
	case 0:                   return "";
	case WSAEINTR:            return " TCP : Interrupted system call";
	case WSAEBADF:            return " TCP : Bad file number";
	case WSAEACCES:           return " TCP : Permission denied";
	case WSAEFAULT:           return " TCP : Bad address";
	case WSAEINVAL:           return " TCP : Invalid argument";
	case WSAEMFILE:           return " TCP : Too many open files";
	case WSAEWOULDBLOCK:      return " TCP : Operation would block";
	case WSAEINPROGRESS:      return " TCP : Operation now in progress";
	case WSAEALREADY:         return " TCP : Operation already in progress";
	case WSAENOTSOCK:         return " TCP : Socket operation on non socket";
	case WSAEDESTADDRREQ:     return " TCP : Destination address required";
	case WSAEMSGSIZE:         return " TCP : Message too long";
	case WSAEPROTOTYPE:       return " TCP : Protocol wrong type for Socket";
	case WSAENOPROTOOPT:      return " TCP : Protocol not available";
	case WSAEPROTONOSUPPORT:  return " TCP : Protocol not supported";
	case WSAESOCKTNOSUPPORT:  return " TCP : Socket not supported";
	case WSAEOPNOTSUPP:       return " TCP : Operation not supported on Socket";
	case WSAEPFNOSUPPORT:     return " TCP : Protocol family not supported";
	case WSAEAFNOSUPPORT:     return " TCP : Address family not supported";
	case WSAEADDRINUSE:       return " TCP : Address already in use";
	case WSAEADDRNOTAVAIL:    return " TCP : Can't assign requested address";
	case WSAENETDOWN:         return " TCP : Network is down";
	case WSAENETUNREACH:      return " TCP : Network is unreachable";
	case WSAENETRESET:        return " TCP : Network dropped connection on reset";
	case WSAECONNABORTED:     return " TCP : Software caused connection abort";
	case WSAECONNRESET:       return " TCP : Connection reset by peer";
	case WSAENOBUFS:          return " TCP : No Buffer space available";
	case WSAEISCONN:          return " TCP : Socket is already connected";
	case WSAENOTCONN:         return " TCP : Socket is not connected";
	case WSAESHUTDOWN:        return " TCP : Can't send after Socket shutdown";
	case WSAETOOMANYREFS:     return " TCP : Too many references:can't splice";
	case WSAETIMEDOUT:        return " TCP : Connection timed out";
	case WSAECONNREFUSED:     return " TCP : Connection refused";
	case WSAELOOP:            return " TCP : Too many levels of symbolic links";
	case WSAENAMETOOLONG:     return " TCP : File name is too long";
	case WSAEHOSTDOWN:        return " TCP : Host is down";
	case WSAEHOSTUNREACH:     return " TCP : Unreachable peer";
	case WSAENOTEMPTY:        return " TCP : Directory is not empty";
	case WSAEUSERS:           return " TCP : Too many users";
	case WSAEDQUOT:           return " TCP : Disk quota exceeded";
	case WSAESTALE:           return " TCP : Stale NFS file handle";
	case WSAEREMOTE:          return " TCP : Too many levels of remote in path";
	#ifdef OS_WINDOWS
	case WSAEPROCLIM:         return " TCP : Too many processes";
	case WSASYSNOTREADY:      return " TCP : Network subsystem is unusable";
	case WSAVERNOTSUPPORTED:  return " TCP : Winsock DLL cannot support this application";
	case WSANOTINITIALISED:   return " TCP : Winsock not initialized";
	case WSAEDISCON:          return " TCP : Disconnect";
	case WSAHOST_NOT_FOUND:   return " TCP : Host not found";
	case WSATRY_AGAIN:        return " TCP : Non authoritative - host not found";
	case WSANO_RECOVERY:      return " TCP : Non recoverable error";
	case WSANO_DATA:          return " TCP : Valid name, no data record of requested type";
	#endif
	case WSAEINVALIDADDRESS:  return " TCP : Invalid address";
	default:                  return " TCP : Other Socket error ("+IntToString(Error)+")";
    }
}
//---------------------------------------------------------------------------
static BaseString IsoTextOf(int Error)
{
    switch (Error)
    {
        case 0 :                     return "";
        case errIsoConnect:          return " ISO : Connection error";
        case errIsoDisconnect:       return " ISO : Disconnect error";
        case errIsoInvalidPDU:       return " ISO : Bad PDU format";
        case errIsoInvalidDataSize:  return " ISO : Datasize passed to send/recv buffer is invalid";
        case errIsoNullPointer:      return " ISO : Null passed as pointer";
        case errIsoShortPacket:      return " ISO : A short packet received";
        case errIsoTooManyFragments: return " ISO : Too many packets without EoT flag";
        case errIsoPduOverflow:      return " ISO : The sum of fragments data exceded maximum packet size";
        case errIsoSendPacket:       return " ISO : An error occurred during send";
        case errIsoRecvPacket:       return " ISO : An error occurred during recv";
        case errIsoInvalidParams:    return " ISO : Invalid connection params (wrong TSAPs)";
        default:                     return " ISO : Unknown error (0x"+NumToString(Error, 16, 8)+")";
    }
}
//---------------------------------------------------------------------------
static BaseString CliTextOf(int Error)
{
    switch (Error)
    {
      case 0 :                            return "";
      case errNegotiatingPDU            : return "CPU : Error in PDU negotiation";
      case errCliInvalidParams          : return "CLI : invalid param(s) supplied";
      case errCliJobPending             : return "CLI : Job pending";
      case errCliTooManyItems           : return "CLI : too may items (>20) in multi read/write";
      case errCliInvalidWordLen         : return "CLI : invalid WordLength";
      case errCliPartialDataWritten     : return "CLI : Partial data written";
      case errCliSizeOverPDU            : return "CPU : total data exceeds the PDU size";
      case errCliInvalidPlcAnswer       : return "CLI : invalid CPU answer";
      case errCliAddressOutOfRange      : return "CPU : Address out of range";
      case errCliInvalidTransportSize   : return "CPU : Invalid Transport size";
      case errCliWriteDataSizeMismatch  : return "CPU : Data size mismatch";
      case errCliItemNotAvailable       : return "CPU : Item not available";
      case errCliInvalidValue           : return "CPU : Invalid value supplied";
      case errCliCannotStartPLC         : return "CPU : Cannot start PLC";
      case errCliAlreadyRun             : return "CPU : PLC already RUN";
      case errCliCannotStopPLC          : return "CPU : Cannot stop PLC";
      case errCliCannotCopyRamToRom     : return "CPU : Cannot copy RAM to ROM";
      case errCliCannotCompress         : return "CPU : Cannot compress";
      case errCliAlreadyStop            : return "CPU : PLC already STOP";
      case errCliFunNotAvailable        : return "CPU : Function not available";
      case errCliUploadSequenceFailed   : return "CPU : Upload sequence failed";
      case errCliInvalidDataSizeRecvd   : return "CLI : Invalid data size received";
      case errCliInvalidBlockType       : return "CLI : Invalid block type";
      case errCliInvalidBlockNumber     : return "CLI : Invalid block number";
      case errCliInvalidBlockSize       : return "CLI : Invalid block size";
      case errCliDownloadSequenceFailed : return "CPU : Download sequence failed";
      case errCliInsertRefused          : return "CPU : block insert refused";
      case errCliDeleteRefused          : return "CPU : block delete refused";
      case errCliNeedPassword           : return "CPU : Function not authorized for current protection level";
      case errCliInvalidPassword        : return "CPU : Invalid password";
      case errCliNoPasswordToSetOrClear : return "CPU : No password to set or clear";
      case errCliJobTimeout             : return "CLI : Job Timeout";
      case errCliFunctionRefused        : return "CLI : function refused by CPU (Unknown error)";
      case errCliPartialDataRead        : return "CLI : Partial data read";
      case errCliBufferTooSmall         : return "CLI : The buffer supplied is too small to accomplish the operation";
      case errCliDestroying             : return "CLI : Cannot perform (destroying)";
      case errCliInvalidParamNumber     : return "CLI : Invalid Param Number";
      case errCliCannotChangeParam      : return "CLI : Cannot change this param now";
	  default                           : return "CLI : Unknown error (0x"+NumToString(Error, 16, 8)+")";
    };
}
//---------------------------------------------------------------------------
static BaseString SrvTextOf(int Error)
{
    switch (Error)
    {
        case 0 :                       return "";
        case errSrvCannotStart       : return "SRV : Server cannot start";
        case errSrvDBNullPointer     : return "SRV : Null passed as area pointer";
        case errSrvAreaAlreadyExists : return "SRV : Cannot register area since already exists";
        case errSrvUnknownArea       : return "SRV : Unknown Area code";
        case errSrvInvalidParams     : return "SRV : Invalid param(s) supplied";
        case errSrvTooManyDB         : return "SRV : DB Limit reached";
        case errSrvInvalidParamNumber: return "SRV : Invalid Param Number";
        case errSrvCannotChangeParam : return "SRV : Cannot change this param now";
        default : return "SRV : Unknown error (0x"+NumToString(Error,16,8)+")";
    };
}
//---------------------------------------------------------------------------
static BaseString ParTextOf(int Error)
{
    switch(Error)
    {
        case 0 :                       return "";
        case errParAddressInUse      : return "PAR : Local address already in use";
        case errParNoRoom            : return "PAR : No more partners available";
        case errServerNoRoom         : return "PAR : No more servers available";
        case errParInvalidParams     : return "PAR : Invalid parameter supplied";
        case errParNotLinked         : return "PAR : Cannot perform, Partner not linked";
        case errParBusy              : return "PAR : Cannot perform, Partner Busy";
        case errParFrameTimeout      : return "PAR : Frame timeout";
        case errParInvalidPDU        : return "PAR : Invalid PDU received";
        case errParSendTimeout       : return "PAR : Send timeout";
        case errParRecvTimeout       : return "PAR : Recv timeout";
        case errParSendRefused       : return "PAR : Send refused by peer";
        case errParNegotiatingPDU    : return "PAR : Error negotiating PDU";
        case errParSendingBlock      : return "PAR : Error Sending Block";
        case errParRecvingBlock      : return "PAR : Error Receiving Block";
        case errParBindError         : return "PAR : Error Binding";
        case errParDestroying        : return "PAR : Cannot perform (destroying)";
        case errParInvalidParamNumber: return "PAR : Invalid Param Number";
        case errParCannotChangeParam : return "PAR : Cannot change this param now";
        case errParBufferTooSmall    : return "PAR : The buffer supplied is too small to accomplish the operation";
        default : return "PAR : Unknown error (0x"+NumToString(Error,16,8)+")";
    }

}
//---------------------------------------------------------------------------
BaseString ErrCliText(int Error)
{
    if (Error!=0)
    {
	switch (Error)
	{
	    case errLibInvalidParam  : return "LIB : Invalid param supplied";
	    case errLibInvalidObject : return "LIB : Invalid object supplied";
	    default :
		    return CliTextOf(Error & ErrS7Mask)+IsoTextOf(Error & ErrIsoMask)+TcpTextOf(Error & ErrTcpMask);
	}
    }
    else
        return "OK";
}
//---------------------------------------------------------------------------
BaseString ErrSrvText(int Error)
{
    if (Error!=0)
    {
	switch (Error)
	{
	    case errLibInvalidParam  : return "LIB : Invalid param supplied";
	    case errLibInvalidObject : return "LIB : Invalid object supplied";
	    default :
		    return SrvTextOf(Error & ErrS7Mask)+IsoTextOf(Error & ErrIsoMask)+TcpTextOf(Error & ErrTcpMask);
	}
    }
    else
        return "OK";
}
//---------------------------------------------------------------------------
BaseString ErrParText(int Error)
{
    if (Error!=0)
    {
	switch (Error)
	{
	    case errLibInvalidParam  : return "LIB : Invalid param supplied";
	    case errLibInvalidObject : return "LIB : Invalid object supplied";
	    default :
		    return ParTextOf(Error & ErrS7Mask)+IsoTextOf(Error &ErrIsoMask)+TcpTextOf(Error &ErrTcpMask);
	}
    }
    else
        return "OK";
}
//---------------------------------------------------------------------------
//                               SERVER EVENTS TEXT
//---------------------------------------------------------------------------
static BaseString SenderText(TSrvEvent &Event)
{
  if (Event.EvtSender!=0)
    return TimeToString(Event.EvtTime)+" ["+IpAddressToString(Event.EvtSender)+"] ";
  else
    return TimeToString(Event.EvtTime)+" Server ";
}
//---------------------------------------------------------------------------
static BaseString TcpServerEventText(TSrvEvent &Event)
{
    BaseString S;
    switch (Event.EvtCode)
    {
      case evcServerStarted       : S="started";break;
      case evcServerStopped       : S="stopped";break;
      case evcListenerCannotStart : S="Cannot start listener - Socket Error : "+TcpTextOf(Event.EvtRetCode);break;
      case evcClientAdded         : S="Client added";break;
      case evcClientRejected      : S="Client refused";break;
      case evcClientNoRoom        : S="A client was refused due to maximum connections number";break;
      case evcClientException     : S="Client exception";break;
      case evcClientDisconnected  : S="Client disconnected by peer";break;
      case evcClientTerminated    : S="Client terminated";break;
      case evcClientsDropped      : S=IntToString(Event.EvtParam1)+" clients have been dropped bacause unresponsive";break;
      default :                     S="Unknown event ("+IntToString(Event.EvtCode)+")";break;
    };
    return SenderText(Event)+S;
}
//---------------------------------------------------------------------------
static BaseString PDUText(TSrvEvent &Event)
{
    switch (Event.EvtRetCode)
    {
      case evrFragmentRejected : return "Fragment of "+IntToString(Event.EvtParam1)+" bytes rejected";
      case evrMalformedPDU     : return "Malformed PDU of "+IntToString(Event.EvtParam1)+" bytes rejected";
      case evrSparseBytes      : return "Message of sparse "+IntToString(Event.EvtParam1)+" bytes rejected";
      case evrCannotHandlePDU  : return "Cannot handle this PDU";
      case evrNotImplemented   : {
                                   switch (Event.EvtParam1)
                                   {
                                     case grCyclicData : return "Function group cyclic data not yet implemented";
                                   }; // <- no break needed here
                                 }
      default : return "Unknown Return code ("+IntToString(Event.EvtRetCode)+")";
    }
}
//---------------------------------------------------------------------------
static BaseString TxtArea(TSrvEvent &Event)
{
    switch (Event.EvtParam1)
    {
        case S7AreaPE : return "Area : PE, ";
        case S7AreaPA : return "Area : PA, ";
        case S7AreaMK : return "Area : MK, ";
        case S7AreaCT : return "Area : CT, ";
        case S7AreaTM : return "Area : TM, ";
        case S7AreaDB : return "Area : DB"+IntToString(Event.EvtParam2)+", ";
        default : return "Unknown area ("+IntToString(Event.EvtParam2)+")";
    }
}
//---------------------------------------------------------------------------
static BaseString TxtStartSize(TSrvEvent &Event)
{
    return "Start : "+IntToString(Event.EvtParam3)+", Size : "+IntToString(Event.EvtParam4);
}
//---------------------------------------------------------------------------
static BaseString TxtDataResult(TSrvEvent &Event)
{
    switch (Event.EvtRetCode)
    {
        case evrNoError          : return " --> OK";
        case evrErrException     : return " --> Exception error";
        case evrErrAreaNotFound  : return " --> Area not found";
        case evrErrOutOfRange    : return " --> Out of range";
        case evrErrOverPDU       : return " --> Data size exceeds PDU size";
        case evrErrTransportSize : return " --> Invalid transport size";
        case evrDataSizeMismatch : return " --> Data size mismatch";
        default : return " --> Unknown error code ("+IntToString(Event.EvtRetCode)+")";
    };
}
//---------------------------------------------------------------------------
static BaseString ControlText(word Code)
{
    BaseString Result="CPU Control request : ";
    switch (Code)
    {
        case CodeControlUnknown   : return Result+"Unknown";
        case CodeControlColdStart : return Result+"Cold START --> OK";
        case CodeControlWarmStart : return Result+"Warm START --> OK";
        case CodeControlStop      : return Result+"STOP --> OK";
        case CodeControlCompress  : return Result+"Memory compress --> OK";
        case CodeControlCpyRamRom : return Result+"Copy Ram to Rom --> OK";
        case CodeControlInsDel    : return Result+"Block Insert or Delete --> OK";
        default : return Result+"Unknown control code ("+IntToString(Code)+")";
    }
}
//---------------------------------------------------------------------------
static BaseString ClockText(word Code)
{
    if (Code==evsGetClock)
        return "System clock read requested";
    else
        return "System clock write requested";
}
//---------------------------------------------------------------------------
static BaseString ReadSZLText(TSrvEvent &Event)
{
    BaseString Result="Read SZL request, ID:0x"+NumToString(Event.EvtParam1,16,4)+" INDEX:0x"+NumToString(Event.EvtParam2,16,4);
    if (Event.EvtRetCode == evrNoError)
        return Result+" --> OK";
    else
        return Result+" --> NOT AVAILABLE";
}
//---------------------------------------------------------------------------
static BaseString StrBlockType(word Code)
{
    switch (Code)
    {
        case Block_OB   : return "OB";
        case Block_DB   : return "DB";
        case Block_SDB  : return "SDB";
        case Block_FC   : return "FC";
        case Block_SFC  : return "SFC";
        case Block_FB   : return "FB";
        case Block_SFB  : return "SFB";
        default : return "[Unknown 0x"+NumToString(Code,16,4)+"]";
    };
}
//---------------------------------------------------------------------------
static BaseString UploadText(TSrvEvent &Event)
{
    BaseString Result="Upload " + StrBlockType(Event.EvtParam1) + IntToString(Event.EvtParam2) + ": ";
    switch (Event.EvtRetCode) {
        case evrNoError:
            Result += "Successful";
            break;
        case evrDataSizeMismatch:
            Result += "Data size does not match";
            break;
        default:
            Result += "Unknown";
    }
   return Result;
}
//---------------------------------------------------------------------------
static BaseString DownloadText(TSrvEvent &Event)
{
    BaseString Result="Download " + StrBlockType(Event.EvtParam1) + IntToString(Event.EvtParam2) + ": ";
    switch (Event.EvtRetCode) {
        case evrNoError:
            Result += "Successful";
            break;
        case evrDataSizeMismatch:
            Result += "Data size does not match";
            break;
        default:
            Result += "Unknown";
    }
   return Result;
}

//---------------------------------------------------------------------------
static BaseString BlockInfoText(TSrvEvent &Event)
{
    BaseString Result;
    switch (Event.EvtParam1)
    {
        case evsGetBlockList : Result = "Block list requested";break;
        case evsStartListBoT : Result = "Block of type "+StrBlockType(Event.EvtParam2)+" list requested (start sequence)";break;
        case evsListBoT      : Result = "Block of type "+StrBlockType(Event.EvtParam2)+" list requested (next part)";break;
        case evsGetBlockInfo : Result = "Block info requested "+StrBlockType(Event.EvtParam2)+" "+IntToString(Event.EvtParam3);break;
    };
    if (Event.EvtRetCode == evrNoError)
        return Result+" --> OK";
    else
        return Result+" --> NOT AVAILABLE";
}
//---------------------------------------------------------------------------
static BaseString SecurityText(TSrvEvent &Event)
{
    switch (Event.EvtParam1)
    {
        case evsSetPassword : return "Security request : Set session password --> OK";
        case evsClrPassword : return "Security request : Clear session password --> OK";
        default : return "Security request : Unknown Subfunction";
    };
}
//---------------------------------------------------------------------------
static BaseString GroupProgrammerText(TSrvEvent &Event)
{
    switch (Event.EvtParam1)
    {
        case evsGPStatic      : return "Group Programmer : Standard request (forces) --> OK";
        case evsGPBlink       : return "Group Programmer : Blink LED --> NOT IMPLEMENTED (sending default response)";
        case evsGPRequestDiag : return "Group Programmer : Request diag mode (Job " + IntToString(Event.EvtParam4) + ") --> OK";
        case evsGPReadDiag    : return "Group Programmer : Read diagnotic data (Job " + IntToString(Event.EvtParam4) + ") --> OK";
        case evsGPRemoveDiag  : return "Group Programmer : Stop diag mode (Job " + IntToString(Event.EvtParam4) + ") --> OK";
        default               : return "Group Programmer : Unknown Subfunction";
    };
}
//---------------------------------------------------------------------------
static BaseString GroupCyclicDataText(TSrvEvent &Event)
{
    switch (Event.EvtParam1)
    {
        case evsGCRequestData : return "Group Cyclic Data: Request Cyclic Data";
        default               : return "Group Cyclic Data: Unknown Subfunction";
    };
}
//---------------------------------------------------------------------------
BaseString EvtSrvText(TSrvEvent &Event)
{
    BaseString S;

    if (Event.EvtCode > evcSnap7Base)
    {
        switch (Event.EvtCode)
        {
            case evcPDUincoming    : S="PDU incoming : "+PDUText(Event);break;
            case evcDataRead       : S="Read request, "+TxtArea(Event)+TxtStartSize(Event)+TxtDataResult(Event);break;
            case evcDataWrite      : S="Write request, "+TxtArea(Event)+TxtStartSize(Event)+TxtDataResult(Event);break;
            case evcNegotiatePDU   : S="The client requires a PDU size of "+IntToString(Event.EvtParam1)+" bytes";break;
            case evcControl        : S=ControlText(Event.EvtParam1);break;
            case evcReadSZL        : S=ReadSZLText(Event);break;
            case evcClock          : S=ClockText(Event.EvtParam1);break;
            case evcUpload         : S=UploadText(Event);break;
            case evcDownload       : S=DownloadText(Event);break;
            case evcDirectory      : S=BlockInfoText(Event);break;
            case evcSecurity       : S=SecurityText(Event);break;
            case evcGroupProgrammer: S=GroupProgrammerText(Event);break;
            case evcGroupCyclicData: S=GroupCyclicDataText(Event);break;
            default:               S="Unknown event ("+IntToString(Event.EvtCode)+")";break;
        }
        return SenderText(Event)+S;
    }
    else
        return TcpServerEventText(Event);
}

