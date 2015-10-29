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
|  New Server Example (1.1.0)                                                  |
|  Here we set ReadEventCallback to get in advance which area the client needs |
|  then we fill this area with a counter.                                      |
|  The purpose is to show how to modify an area before it be trasferred to the |
|  client                                                                      |
|                                                                              |
|=============================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <cstring>
#include "snap7.h"

     TS7Server *Server;
     unsigned char DB21[512];  // Our DB1
     unsigned char DB103[1280];  // Our DB2
     unsigned char DB3[1024]; // Our DB3
	 byte cnt = 0;

// Here we use the callback to show the log, this is not the best choice since
// the callback is synchronous with the client access, i.e. the server cannot
// handle futher request from that client until the callback is complete.
// The right choice is to use the log queue via the method PickEvent.

void S7API EventCallBack(void *usrPtr, PSrvEvent PEvent, int Size)
{
    // print the event
    printf("%s\n",SrvEventText(PEvent).c_str());
};

// The read event callback is called multiple times in presence of multiread var request
void S7API ReadEventCallBack(void *usrPtr, PSrvEvent PEvent, int Size)
{
    // print the read event
    printf("%s\n",SrvEventText(PEvent).c_str());
	if (PEvent->EvtParam1==S7AreaDB)
	{
                // As example the DB requested is filled before transferred
                // EvtParam1 contains the DB number.
		switch (PEvent->EvtParam2)
		{
		case 1 : memset(&DB21, ++cnt, sizeof(DB21));break;
		case 2 : memset(&DB103, ++cnt, sizeof(DB103));break;
		case 3 : memset(&DB3, ++cnt, sizeof(DB3));break;
		}
	}
};

int main(int argc, char* argv[])
{
    int Error;
    Server = new TS7Server;

    // Share some resources with our virtual PLC
    Server->RegisterArea(srvAreaDB,     // We are registering a DB
                         21,             // Its number is 1 (DB1)
                         &DB21,          // Our buffer for DB1
                         sizeof(DB21));  // Its size
    // Do the same for DB2 and DB3
    Server->RegisterArea(srvAreaDB, 103, &DB103, sizeof(DB103));
    Server->RegisterArea(srvAreaDB, 3, &DB3, sizeof(DB3));

    // We mask the read event to avoid the double trigger for the same event                  
    Server->SetEventsMask(~evcDataRead);
    Server->SetEventsCallback(EventCallBack, NULL);
    // Set the Read Callback
    Server->SetReadEventsCallback(ReadEventCallBack, NULL);
    // Start the server onto the default adapter.
    // To select an adapter we have to use Server->StartTo("192.168.x.y").
    // Start() is the same of StartTo("0.0.0.0");
    Error=Server->Start();
    if (Error==0)
    {
	// Now the server is running ... wait a key to terminate
        getchar();
    }
    else
        printf("%s\n",SrvErrorText(Error).c_str());

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

    Server->Stop(); // <- not strictly needed, every server is stopped on deletion
                    //    and every client is gracefully disconnected.
    delete Server;
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
