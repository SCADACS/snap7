/*=============================================================================|
|  PROJECT SNAP7                                                         1.4.0 |
|==============================================================================|
|  Copyright (C) 2013, 2014 Davide Nardella                                    |
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
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "snap7.h"

S7Object Server;
unsigned char DB1[512];  // Our DB1
unsigned char DB2[128];  // Our DB2
unsigned char DB3[1024]; // Our DB3

// binary SZL for component identification
byte SZLC_ID_001C_IDX_XXXX[352] = {
		// success
		0xFF,
		// transport size
		0x09,
		// length = 348
		0x01, 0x5C,
		// SZL ID
		0x00, 0x1C,
		// ?
		0x00, 0x00, 0x00, 0x22, 0x00, 0x0A,
		// index 1
		0x00, 0x01,
		// Name of the PLC: SNAP7-SERVER                  	(534e4150372d5345525645520000000000000000000000000000000000000000)
		// 0x53,0x4E,0x41,0x50,0x37,0x2D,0x53,0x45,0x52,0x56,0x45,0x52,
		0x46, 0x61, 0x6b, 0x65, 0x20, 0x50, 0x4c, 0x43, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 2
		0x00, 0x02,
		// Name of the module: CPU 315-2 PN/DP               	(435055203331352d3220504e2f44500000000000000000000000000000000000)
		0x43, 0x50, 0x55, 0x20, 0x33, 0x31, 0x35, 0x2D, 0x32, 0x20, 0x50, 0x4E,
		0x2F, 0x44, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 3
		0x00, 0x03,
		// Plant identification:                               	(0000000000000000000000000000000000000000000000000000000000000000)
		0x53, 0x43, 0x41, 0x44, 0x41, 0x43, 0x53, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 4
		0x00, 0x04,
		// Copyright: Original Siemens Equipment    	(4f726967696e616c205369656d656e732045717569706d656e74000000000000)
		//0x4F,0x72,0x69,0x67,0x69,0x6E,0x61,0x6C,0x20,0x53,0x69,0x65,0x6D,0x65,0x6E,0x73,0x20,0x45,0x71,
		//0x75,0x69,0x70,0x6D,0x65,0x6E,0x74,0x00,0x00,0x00,0x00,0x00,0x00,
		0x4c, 0x47, 0x50, 0x4c, 0x76, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 5
		0x00, 0x05,
		// Serial number of module: S C-C2UR28922012              	(5320432d43325552323839323230313200000000000000000000000000000000)
		0x53, 0x20, 0x43, 0x2D, 0x43, 0x32, 0x55, 0x52, 0x32, 0x38, 0x39, 0x32,
		0x32, 0x30, 0x31, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 6 missing (Reserved for operating system)
		// index 7
		0x00, 0x07,
		// Module type name: CPU 315-2 PN/DP               	(435055203331352d3220504e2f44500000000000000000000000000000000000)
		0x43, 0x50, 0x55, 0x20, 0x33, 0x31, 0x35, 0x2D, 0x32, 0x20, 0x50, 0x4E,
		0x2F, 0x44, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 8
		0x00, 0x08,
		// Serial number of memory card: MMC 267FF11F                  	(4d4d432032363746463131460000000000000000000000000000000000000000)
		0x4D, 0x4D, 0x43, 0x20, 0x32, 0x36, 0x37, 0x46, 0x46, 0x31, 0x31, 0x46,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 9
		0x00, 0x09,
		// Manufacturer and profile of a CPU module:  *                              	(002af60000010000000000000000000000000000000000000000000000000000)
		0x00, 0x2A, 0xF6, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 10
		0x00, 0x0A,
		// OEM ID of a module:                                 	(0000000000000000000000000000000000000000000000000000000000000000)
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// index 11
		0x00, 0x0B,
		// Location designation of a module:                                 	(0000000000000000000000000000000000000000000000000000000000000000)
		0x4c, 0x61, 0x62, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

// Here we use the callback to show the log, this is not the best choice since
// the callback is synchronous with the client access, i.e. the server cannot
// handle futher request from that client until the callback is complete.
// The right choice is to use the log queue via the method PickEvent.

void S7API EventCallBack(void *usrPtr, PSrvEvent PEvent, int Size)
{
    // print the event
	char text[1024];
	Srv_EventText(PEvent, text, 1024);
    printf("%s\n",text);
};

int main(int argc, char* argv[])
{
    int Error;
	char text[1024];

	Server = Srv_Create();

    // Share some resources with our virtual PLC
    Srv_RegisterArea(Server,
		     srvAreaDB,     // We are registering a DB
                     1,             // Its number is 1 (DB1)
                     &DB1,          // Our buffer for DB1
                     sizeof(DB1));  // Its size
    // Do the same for DB2 and DB3
    Srv_RegisterArea(Server, srvAreaDB, 2, &DB2, sizeof(DB2));
    Srv_RegisterArea(Server, srvAreaDB, 3, &DB3, sizeof(DB3));

    // change component identification
    Srv_SetSZL(Server, SZL_ID_001C, SZLC_ID_001C_IDX_XXXX,
    			sizeof(SZLC_ID_001C_IDX_XXXX));

    // Set the event callback to show something : it's not strictly needed.
    // If you comment next line the server still works fine.
    Srv_SetEventsCallback(Server, EventCallBack, NULL);

    // Start the server onto the default adapter.
    // To select an adapter we have to use Srv_StartTo(Server, "192.168.x.y").
    // Start() is the same of StartTo("0.0.0.0");
    Error=Srv_Start(Server);
    if (Error==0)
    {
	// Now the server is running ... wait a key to terminate
        getchar();
    }
    else
	{
        Srv_ErrorText(Error, text, 1024);
        printf("%s\n", text);
	}

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

    Srv_Stop(Server); // <- not strictly needed, every server is stopped on deletion
                    //    and every client is gracefully disconnected.
	Srv_Destroy(&Server);
	return 0;
}

// Finally, this is a very minimalist (but working) server :
/*
int main(int argc, char* argv[])
{
   TS7Server *Server = new TS7Server;
   Server->Start();
   getchar();
   delete Server;
}
*/
