/*=============================================================================|
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
|=============================================================================*/
using System;
using System.Text;
using Snap7;

class ServerDemo
{
    static S7Server Server;
    static private byte[] DB1 = new byte[512];  // Our DB1
    static private byte[] DB2 = new byte[1028]; // Our DB2
    static private byte[] DB3 = new byte[1024]; // Our DB3
    private static S7Server.TSrvCallback TheEventCallBack; // <== Static var containig the callback
    private static S7Server.TSrvCallback TheReadCallBack; // <== Static var containig the callback

// Here we use the callback to show the log, this is not the best choice since
// the callback is synchronous with the client access, i.e. the server cannot
// handle futher request from that client until the callback is complete.
// The right choice is to use the log queue via the method PickEvent.

    static void EventCallback(IntPtr usrPtr, ref S7Server.USrvEvent Event, int Size)
    {    
        Console.WriteLine(Server.EventText(ref Event));
    }

    static void ReadEventCallback(IntPtr usrPtr, ref S7Server.USrvEvent Event, int Size)
    {
        Console.WriteLine(Server.EventText(ref Event));
    }

    static void Main(string[] args)
    {
        Server = new S7Server();
        // Share some resources with our virtual PLC
        Server.RegisterArea(S7Server.srvAreaDB,  // We are registering a DB
                            1,                   // Its number is 1 (DB1)
                            ref DB1,             // Our buffer for DB1
                            DB1.Length);         // Its size
        // Do the same for DB2 and DB3
        Server.RegisterArea(S7Server.srvAreaDB, 2, ref DB2, DB2.Length);
        Server.RegisterArea(S7Server.srvAreaDB, 3, ref DB3, DB3.Length);
        
        // Exclude read event to avoid the double report
        // Set the callbacks (using the static var to avoid the garbage collect)
        TheEventCallBack = new S7Server.TSrvCallback(EventCallback);
        TheReadCallBack = new S7Server.TSrvCallback(ReadEventCallback);
        
        Server.EventMask = ~S7Server.evcDataRead;
        Server.SetEventsCallBack(TheEventCallBack, IntPtr.Zero);
        Server.SetReadEventsCallBack(TheReadCallBack, IntPtr.Zero);

        // Uncomment next line if you don't want to see wrapped messages 
        // (Note : Doesn't work in Mono 2.10)

        // Console.SetBufferSize(100, Int16.MaxValue - 1);

        // Start the server onto the default adapter.
        // To select an adapter we have to use Server->StartTo("192.168.x.y").
        // Start() is the same of StartTo("0.0.0.0");       
        int Error=Server.Start();
        if (Error == 0)
        {
            // Now the server is running ... wait a key to terminate
            Console.ReadKey();
            Server.Stop();
        }
        else
            Console.WriteLine(Server.ErrorText(Error));
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

    }
}
