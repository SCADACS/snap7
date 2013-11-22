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
|  Server Example                                                              |
|                                                                              |
|=============================================================================*)
program server;
{$APPTYPE CONSOLE}
uses Snap7;

Var
  Srv : TS7Server;

  DB1 : packed array[0..511] of byte; // Our DB1
  DB2 : packed array[0..511] of byte; // Our DB1
  DB3 : packed array[0..511] of byte; // Our DB1

// Here we use the callback to show the log, this is not the best choice since
// the callback is synchronous with the client access, i.e. the server cannot
// handle futher request from that client until the callback is complete.
// The right choice is to use the log queue via the method PickEvent (see
// serverdemo)
procedure EventCallBack(usrPtr : pointer; PEvent : PSrvEvent ; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
begin
    // print the event
    writeln(SrvEventText(PEvent^));
end;

Var
  Error : integer;
begin
    Srv:=TS7Server.Create;

    // Share some resources with our virtual PLC
    Srv.RegisterArea(srvAreaDB,     // We are registering a DB
                        1,             // Its number is 1 (DB1)
                        @DB1,          // Our buffer for DB1
                        sizeof(DB1));  // Its size
    // Do the same for DB2 and DB3
    Srv.RegisterArea(srvAreaDB, 2, @DB2, sizeof(DB2));
    Srv.RegisterArea(srvAreaDB, 3, @DB3, sizeof(DB3));

    // Set the event callback to show something : it's not strictly needed.
    // If you comment next line the server still works fine.
    Srv.SetEventsCallback(@EventCallBack, nil);

    // Start the server onto the default adapter.
    // To select an adapter we have to use Server->StartTo("192.168.x.y").
    // Start() is the same of StartTo("0.0.0.0");
    Error:=Srv.Start();
    if (Error=0) then
    begin
        // Now the server is running ... wait a key to terminate
        readln;
    end
    else
        writeln(SrvErrorText(Error));

    // If you got a start error:
    // Windows - most likely you ar running the server in a pc on wich is
    //           installed step 7 : open a command prompt and type
    //             "net stop s7oiehsx"    (Win32) or
    //             "net stop s7oiehsx64"  (Win64)
    //           And after this test :
    //             "net start s7oiehsx"   (Win32) or
    //             "net start s7oiehsx64" (Win64)
    // Unix - you need root rights :-( because the isotcp port (102) is
    //        low and so it's considered "privileged".

    Srv.Stop(); // <- not strictly needed, every server is stopped on deletion
                   //    and every client is gracefully disconnected.
    Srv.Free;

// Finally, this is a very minimalist (but working) server :
(*
Var
  Srv : TS7Server;
begin
  Srv:=TS7Server.Create;
  Srv.Start;
  Readln;
  Srv.Free;
end.
*)

end.

