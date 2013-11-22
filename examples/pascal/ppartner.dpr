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
|  Passive Partner Example                                                     |
|                                                                              |
|=============================================================================*)
Program ppartner;
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
  Partner : TS7Partner;

//------------------------------------------------------------------------------
// Usage syntax
//------------------------------------------------------------------------------
procedure Usage;
begin
	writeln('Usage');
	writeln('  PPartner <ActiveIP>');
	writeln('Where');
	writeln('  <ActiveIP> is the address of the active partner that we are waiting for.');
	writeln('Note');
	writeln('- Local Address is set to 0.0.0.0 (the default adapter)');
	writeln('- Both Local TSAP and Remote TSAP are set to $1002');
	writeln('- You can create multiple passive partners bound to the same');
	writeln('  local address in the same program, but you cannot execute');
	writeln('  multiple instance of this program.');
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
// Callback on data ready
//------------------------------------------------------------------------------
procedure RecvCallback(usrPtr : Pointer; opResult : integer; R_ID : longword; pdata : Pointer; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
begin
	writeln('R_ID : ',IntToHex(R_ID,8));
	writeln('Size : ',Size,' bytes');
	hexdump(pdata, Size);
end;
//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
Var
  Error : integer;
begin
    // Get Progran args
		if (ParamCount <> 1) then
		begin
			Usage;
			Halt(1);
		end;
		// Create the PASSIVE partner
		Partner := TS7Partner.Create(false);
		// Set the BRecv callback
		Partner.SetRecvCallback(@RecvCallback, nil);
		// Start
		Error:=Partner.StartTo('0.0.0.0', AnsiString(ParamStr(1)), $1002, $1002);
		if (Error = 0) then
	    writeln('Passive partner started')
		else
	    writeln(ParErrorText(Error));
		// If you got a start error:
		// Windows - most likely you ar running the server in a pc on wich is
		//           installed step 7 : open a command prompt and type
		//             'net stop s7oiehsx'    (Win32) or
		//             'net stop s7oiehsx64'  (Win64)
		//           And after this test :
		//             'net start s7oiehsx'   (Win32) or
		//             'net start s7oiehsx64' (Win64)
		// Unix - you need root rights :-( because the isotcp port (102) is
		//        low and so it's considered 'privileged'.
		readln;
		Partner.Stop;
		Partner.Free;
end.
