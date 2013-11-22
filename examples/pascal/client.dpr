(*=============================================================================|
|  PROJECT SNAP7                                                         1.0.0 |
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
|  Client Example                                                              |
|                                                                              |
|  2013-09-05 : Fixed expression bug (thanks to Jean-Noel Voirol)              |
|=============================================================================*)
Program client;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
Uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils, Snap7;

Var

  Cli : TS7Client;

  Buffer : packed array [0..4095] of byte; // 4 K buffer
  SampleDBNum : integer = 1000;
  Address : AnsiString;
  Rack : integer =0;
  Slot : integer =2; // Default Rack and Slot

  ok   : integer = 0; // Number of test pass
  ko   : integer = 0; // Number of test failure

  JobDone   : boolean =false;
  JobResult : integer =0;

//------------------------------------------------------------------------------
//  Async completion callback
//------------------------------------------------------------------------------
// This is a simply text demo, we use callback only to set an internal flag...
procedure CliCompletion(usrPtr : pointer; opCode, opResult : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
begin
  JobResult:=opResult;
  JobDone := true;
end;
//------------------------------------------------------------------------------
//  Usage Syntax
//------------------------------------------------------------------------------
procedure Usage();
begin
    writeln('Usage');
    writeln('  client <IP> [Rack=0 Slot=2]');
    writeln('Example');
    writeln('  client 192.168.1.101 0 2');
    writeln('or');
    writeln('  client 192.168.1.101');
    readln;
end;
//------------------------------------------------------------------------------
// hexdump
//------------------------------------------------------------------------------
procedure hexdump(mem : pointer; count : integer);
Var
  P : PS7Buffer;
  SHex, SChr : string;
  Ch : AnsiChar;
  c, cnt : integer;
begin
  P:=PS7Buffer(mem);
  SHex:='';SChr:='';cnt:=0;
  for c := 0 to Count - 1 do
  begin
    SHex:=SHex+IntToHex(P^[c],2)+' ';
    Ch:=AnsiChar(P^[c]);
    if not (Ch in ['a'..'z','A'..'Z','0'..'9','_','$','-',#32]) then
      Ch:='.';
    SChr:=SChr+String(Ch);
    inc(cnt);
    if cnt=16 then
    begin
      Writeln(SHex+'  '+SChr);
      SHex:='';SChr:='';
      cnt:=0;
    end;
  end;
  // Dump remainder
  if cnt>0 then
  begin
    while Length(SHex)<48 do
      SHex:=SHex+' ';
    Writeln(SHex+'  '+SChr);
  end;
end;
//------------------------------------------------------------------------------
// Check error
//------------------------------------------------------------------------------
function Check(iResult : integer; sFunction : string) : boolean;
begin
    writeln('');
    writeln('+-----------------------------------------------------');
    writeln('| '+Sfunction);
    writeln('+-----------------------------------------------------');
    if (iResult=0) then
    begin
        writeln('| Result         : OK');
        writeln('| Execution time : '+IntToStr(Cli.Time)+' ms');
        writeln('+-----------------------------------------------------');
        inc(ok);
    end
    else begin
        writeln('| ERROR !!! ');
        if (iResult<0) then
            writeln('| Library Error (-1)')
        else
            writeln('| '+CliErrorText(iResult));
        writeln('+-----------------------------------------------------');
        inc(ko);
    end;
    Result:=iResult=0;
end;
//------------------------------------------------------------------------------
// Multi Read
//------------------------------------------------------------------------------
procedure MultiRead();
Var
     // Multiread buffers
     MB : array [0..15] of byte; // 16 Merker bytes
     EB : array [0..15] of byte; // 16 Digital Input bytes
     AB : array [0..15] of byte; // 16 Digital Output bytes
     TM : array [0..7] of word;  // 8 timers
     CT : array [0..7] of word;  // 8 counters

     // Prepare struct
     Items : packed array[0..4] of TS7DataItem;
     res   : integer;
     // NOTE : *AMOUNT IS NOT SIZE* , it's the number of items

begin
     // Merkers
     Items[0].Area     :=S7AreaMK;
     Items[0].WordLen  :=S7WLByte;
     Items[0].DBNumber :=0;        // Don't need DB
     Items[0].Start    :=0;        // Starting from 0
     Items[0].Amount   :=16;       // 16 Items (bytes)
     Items[0].pdata    :=@MB;
     // Digital Input bytes
     Items[1].Area     :=S7AreaPE;
     Items[1].WordLen  :=S7WLByte;
     Items[1].DBNumber :=0;        // Don't need DB
     Items[1].Start    :=0;        // Starting from 0
     Items[1].Amount   :=16;       // 16 Items (bytes)
     Items[1].pdata    :=@EB;
     // Digital Output bytes
     Items[2].Area     :=S7AreaPA;
     Items[2].WordLen  :=S7WLByte;
     Items[2].DBNumber :=0;        // Don't need DB
     Items[2].Start    :=0;        // Starting from 0
     Items[2].Amount   :=16;       // 16 Items (bytes)
     Items[2].pdata    :=@AB;
     // Timers
     Items[3].Area     :=S7AreaTM;
     Items[3].WordLen  :=S7WLTimer;
     Items[3].DBNumber :=0;        // Don't need DB
     Items[3].Start    :=0;        // Starting from 0
     Items[3].Amount   :=8;        // 8 Timers
     Items[3].pdata    :=@TM;
     // Counters
     Items[4].Area     :=S7AreaCT;
     Items[4].WordLen  :=S7WLCounter;
     Items[4].DBNumber :=0;        // Don't need DB
     Items[4].Start    :=0;        // Starting from 0
     Items[4].Amount   :=8;        // 8 Counters
     Items[4].pdata    :=@CT;

     res:=Cli.ReadMultiVars(@Items[0],5);
     if (Check(res,'Multiread Vars')) then
     begin
        // Result of Cli.ReadMultivars is the 'global result' of
        // the function, it's OK if something was exchanged.

        // But we need to check single Var results.
        // Let shall suppose that we ask for 5 vars, 4 of them are ok but
        // the 5th is inexistent, we will have 4 results ok and 1 not ok.

        writeln('Dump MB0..MB15 - Var Result : ',Items[0].Result);
        if (Items[0].Result=0) then
            hexdump(@MB,16);
        writeln('Dump EB0..EB15 - Var Result : ',Items[1].Result);
        if (Items[1].Result=0) then
            hexdump(@EB,16);
        writeln('Dump AB0..AB15 - Var Result : ',Items[2].Result);
        if (Items[2].Result=0) then
            hexdump(@AB,16);
        writeln('Dump T0..T7 - Var Result : ',Items[3].Result);
        if (Items[3].Result=0) then
            hexdump(@TM,16);         // 8 Timers . 16 bytes
        writeln('Dump Z0..Z7 - Var Result : ',Items[4].Result);
        if (Items[4].Result=0) then
            hexdump(@CT,16);         // 8 Counters . 16 bytes
     end;
end;
//------------------------------------------------------------------------------
// List blocks in AG
//------------------------------------------------------------------------------
procedure ListBlocks();
Var
    List : TS7BlocksList;
    res  : integer;
begin
    res:=Cli.ListBlocks(@List);
    if (Check(res,'List Blocks in AG')) then
    begin
      writeln('  OBCount  : ',List.OBCount);
	    writeln('  FBCount  : ',List.FBCount);
   		writeln('  FCCount  : ',List.FCCount);
   		writeln('  SFBCount : ',List.SFBCount);
   		writeln('  SFCCount : ',List.SFCCount);
   		writeln('  DBCount  : ',List.DBCount);
   		writeln('  SDBCount : ',List.SDBCount);
    end;
end;
//------------------------------------------------------------------------------
// CPU Info : catalog
//------------------------------------------------------------------------------
procedure OrderCode;
Var
  Info : TS7OrderCode;
  res  : integer;
begin
     res:=Cli.GetOrderCode(@Info);
     if (Check(res,'Catalog')) then
     begin
       writeln('  Order Code : ',Info.Code);
       writeln('  Version    : '+IntToStr(Info.V1)+'.'+IntToStr(Info.V2)+'.'+IntToStr(Info.V3));
     end;
end;
//------------------------------------------------------------------------------
// CPU Info : unit info
//------------------------------------------------------------------------------
procedure CpuInfo;
Var
  Info : TS7CpuInfo;
  res  : integer;
begin
    res:=Cli.GetCpuInfo(@Info);
    if (Check(res,'Unit Info')) then
    begin
      writeln('  Module Type Name : ',Info.ModuleTypeName);
      writeln('  Serial Number    : ',Info.SerialNumber);
      writeln('  AS Name          : ',Info.ASName);
      writeln('  Module Name      : ',Info.ModuleName);
    end;
end;
//------------------------------------------------------------------------------
// CP Info
//------------------------------------------------------------------------------
procedure CpInfo;
Var
  Info : TS7CpInfo;
  res  : integer;
begin
     res:=Cli.GetCpInfo(@Info);
     if (Check(res,'Communication processor Info')) then
     begin
          writeln('  Max PDU Length   :  ',Info.MaxPduLengt,' bytes');
          writeln('  Max Connections  :  ',Info.MaxConnections);
          writeln('  Max MPI Rate     :  ',Info.MaxMpiRate,' bps');
          writeln('  Max Bus Rate     :  ',Info.MaxBusRate,' bps');
     end;
end;
//------------------------------------------------------------------------------
// PLC Status
//------------------------------------------------------------------------------
procedure UnitStatus;
Var
  Status : integer;
  res    : integer;
begin
     res:=Cli.GetPlcStatus(Status);
     if (Check(res,'CPU Status')) then
     begin
          case Status of
            S7CpuStatusRun : writeln('  RUN');
            S7CpuStatusStop: writeln('  STOP');
          else
            writeln('  UNKNOWN');
          end
     end;
end;
//------------------------------------------------------------------------------
// Upload DB0 (surely exists in AG)
//------------------------------------------------------------------------------
procedure UploadDB0;
Var
  Size : integer;
  res  : integer;
begin
     Size := sizeof(Buffer); // Size is IN/OUT par
                             // In input it tells the client the size available
                             // In output it tells us how many bytes were uploaded.
     res:=Cli.Upload(Block_SDB, 0, @Buffer, Size);
     if (Check(res,'Block Upload (SDB 0)')) then
     begin
        writeln('Dump : '+IntToStr(Size)+' bytes');
        hexdump(@Buffer,Size);
     end
end;
//------------------------------------------------------------------------------
// Async Upload DB0 (using callback as completion trigger)
//------------------------------------------------------------------------------
procedure AsCBUploadDB0;
Var
  Size : integer;
  res  : integer;
begin
     Size := sizeof(Buffer); // Size is IN/OUT par
                             // In input it tells the client the size available
                             // In output it tells us how many bytes were uploaded.
     JobDone:=false;
     res:=Cli.AsUpload(Block_SDB, 0, @Buffer, Size);

     if (res=0) then
     begin
         while not JobDone do
             Sleep(100);
         res:=JobResult;
     end;

     if (Check(res,'Async (callback) Block Upload (SDB 0)')) then
     begin
        writeln('Dump : '+IntToStr(Size)+' bytes');
        hexdump(@Buffer,Size);
     end;
end;
//------------------------------------------------------------------------------
// Async Upload DB0 (using event wait as completion trigger)
//------------------------------------------------------------------------------
procedure AsEWUploadDB0;
Var
  Size : integer;
  res  : integer;
begin
     Size := sizeof(Buffer); // Size is IN/OUT par
                             // In input it tells the client the size available
                             // In output it tells us how many bytes were uploaded.
     JobDone:=false;
     res:=Cli.AsUpload(Block_SDB, 0, @Buffer, Size);

     if (res=0) then
       res:=Cli.WaitAsCompletion(3000);

     if (Check(res,'Async (Wait event) Block Upload (SDB 0)')) then
     begin
        writeln('Dump : '+IntToStr(Size)+' bytes');
        hexdump(@Buffer,Size);
     end;
end;
//------------------------------------------------------------------------------
// Async Upload DB0 (using polling as completion trigger)
//------------------------------------------------------------------------------
procedure AsPOUploadDB0;
Var
  Size : integer;
  res  : integer;
begin
     Size := sizeof(Buffer); // Size is IN/OUT par
                             // In input it tells the client the size available
                             // In output it tells us how many bytes were uploaded.
     JobDone:=false;
     res:=Cli.AsUpload(Block_SDB, 0, @Buffer, Size);

     if (res=0) then
     begin
         while not Cli.CheckAsCompletion(res) do
           Sleep(100);
     end;

     if (Check(res,'Async (polling) Block Upload (SDB 0)')) then
     begin
        writeln('Dump : '+IntToStr(Size)+' bytes');
        hexdump(@Buffer,Size);
     end;
end;
//------------------------------------------------------------------------------
// Read a sample SZL Block
//------------------------------------------------------------------------------
procedure ReadSzl_0011_0000;
Var
  Size : integer;
  res  : integer;
  SZL  : PS7SZL;
begin
     SZL  := PS7SZL(@Buffer);  // use our buffer casted as TS7SZL
     Size := sizeof(Buffer);
     // Block ID $0011 IDX $0000 normally exists in every CPU
     res:=Cli.ReadSZL($0011, $0000, SZL, Size);
     if (Check(res,'Read SZL - ID : $0011, IDX $0000')) then
     begin
        writeln('  LENTHDR : '+IntToStr(SZL.Header.LENTHDR));
        writeln('  N_DR    : '+IntToStr(SZL.Header.N_DR));
        writeln('Dump : '+IntToStr(Size)+' bytes');
        hexdump(@Buffer,Size);
     end;
end;
//------------------------------------------------------------------------------
// Unit Connection
//------------------------------------------------------------------------------
function CliConnect : boolean;
Var
  res  : integer;
begin
    res := Cli.ConnectTo(Address,Rack,Slot);
    if (Check(res,'UNIT Connection')) then
    begin
      writeln('  Connected to   : ',Address,' (Rack=',IntToStr(Rack),', Slot=',IntToStr(Slot),')');
      writeln('  PDU Requested  : ',IntToStr(Cli.PDURequested));
      writeln('  PDU Negotiated : ',Cli.PDULength());
    end;
    Result:=res=0;
end;
//------------------------------------------------------------------------------
// Unit Disconnection
//------------------------------------------------------------------------------
procedure CliDisconnect;
begin
   Cli.Disconnect()
end;
//------------------------------------------------------------------------------
// Perform readonly tests, no cpu status modification
//------------------------------------------------------------------------------
procedure PerformTests;
begin
     OrderCode;
     CpuInfo;
     CpInfo;
     UnitStatus;
     ReadSzl_0011_0000;
     UploadDB0;
     AsCBUploadDB0;
     AsEWUploadDB0;
     AsPOUploadDB0;
     MultiRead;
end;
//------------------------------------------------------------------------------
// Tests Summary
//------------------------------------------------------------------------------
procedure Summary;
begin
    writeln('');
    writeln('+-----------------------------------------------------');
    writeln('| Test Summary ');
    writeln('+-----------------------------------------------------');
    writeln('| Performed : ',(ok+ko));
    writeln('| Passed    : ',ok);
    writeln('| Failed    : ',ko);
    writeln('+----------------------------------------[press a key]');
    readln;;
end;
//------------------------------------------------------------------------------
function GetArgs : boolean;
Var
  code : integer;
begin
  Result:=false;
  writeln(ParamCount);
  if (ParamCount<>1) AND (ParamCount<>3) then
    exit;
  Address:=AnsiString(ParamStr(1));
  if ParamCount=3 then
  begin
    Val(ParamStr(2),Rack,code);
    if code<>0 then
      exit;
    Val(ParamStr(3),Slot,code);
    if code<>0 then
      exit;
  end;
  Result:=true;
end;
//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
begin
// Get Progran args (we need the client address and optionally Rack and Slot)
   if not GetArgs then
   begin
      Usage();
      exit;
   end;
// Client Creation
    Cli:=TS7Client.Create;
    Cli.SetAsCallback(@CliCompletion,nil);
// Connection
    if CliConnect then
    begin
      PerformTests;
      CliDisconnect;
    end;
// Deletion
    Cli.Free;
    Summary;
end.

