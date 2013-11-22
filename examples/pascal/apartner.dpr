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
|  Active Partner Example                                                      |
|                                                                              |
|=============================================================================*)
Program apartner;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
Uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils, Snap7;

Const
  size = 256;
Var
	cnt : integer = 0;
	Buffer : packed array[0..size-1] of byte;
	Partner : TS7Partner;

//------------------------------------------------------------------------------
// Usage syntax
//------------------------------------------------------------------------------
procedure Usage;
begin
    writeln('Usage');
    writeln('  APartner <PassiveIP>');
    writeln('Where');
    writeln('  <PassiveIP> is the address of the passive partner that we want to connect.');
    writeln('Note');
    writeln('- Local Address is meaningless');
    writeln('- Both Local TSAP and Remote TSAP are set to $1002');
    writeln('- You can create multiple active partner in the same');
    writeln('  program or across different programs.');
end;
//------------------------------------------------------------------------------
// Simply fills the buffer with a progressive number
//------------------------------------------------------------------------------
procedure PrepareBuffer;
Var
  i : integer;
begin
   inc(cnt);
   for i := 0 to size-1 do
     Buffer[i] := cnt;
end;
//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
Var
  Error    : integer;
  SndError : integer;
begin
    // Get Progran args
    if (ParamCount<>1) then
    begin
      Usage;
      halt(1);
    end;;
    // Create the ACTIVE partner
    Partner := TS7Partner.Create(true);
    // Start
    // Local Address for an active partner is meaningless, leave
    // it always set to '0.0.0.0'
    Error:=Partner.StartTo('0.0.0.0', AnsiString(ParamStr(1)), $1002, $1002);
    if (Error <> 0) then
    begin
      writeln(ParErrorText(Error));
      halt(1);
    end;
    // Endless loop : Exit with Ctrl-C
    while (true) do
    begin
        while not Partner.Linked do
        begin
            writeln('Connecting to ',ParamStr(1),' ...');
            Sleep(500);
        end;
        repeat
          PrepareBuffer;
          SndError := Partner.BSend($00000001, @Buffer, size);
          if (SndError = 0) then
              writeln('Succesfully sent ',size,' bytes')
          else
              writeln(ParErrorText(SndError));
          Sleep(500);
        until SndError <> 0;
    end;
end.
