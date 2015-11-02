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
	 typedef byte TRWBuffer[1024];
	 typedef byte *PRWBuffer;
	 byte cnt = 0;

//------------------------------------------------------------------------------
// hexdump, a very nice function, it's not mine.
// I found it on the net somewhere some time ago... thanks to the author ;-)
//------------------------------------------------------------------------------
#ifndef HEXDUMP_COLS
#define HEXDUMP_COLS 16
#endif
	 void hexdump(void *mem, unsigned int len)
	 {
		 unsigned int i, j;

		 for (i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++)
		 {
			 /* print offset */
			 if (i % HEXDUMP_COLS == 0)
			 {
				 printf("0x%04x: ", i);
			 }
			 /* print hex data */
			 if (i < len)
			 {
				 printf("%02x ", 0xFF & ((char*)mem)[i]);
			 }
			 else /* end of block, just aligning for ASCII dump */
			 {
				 printf("   ");
			 }
			 /* print ASCII dump */
			 if (i % HEXDUMP_COLS == (HEXDUMP_COLS - 1))
			 {
				 for (j = i - (HEXDUMP_COLS - 1); j <= i; j++)
				 {
					 if (j >= len) /* end of block, not really printing */
					 {
						 putchar(' ');
					 }
					 else if (isprint((((char*)mem)[j] & 0x7F))) /* printable char */
					 {
						 putchar(0xFF & ((char*)mem)[j]);
					 }
					 else /* other char */
					 {
						 putchar('.');
					 }
				 }
				 putchar('\n');
			 }
		 }
	 }

 //------------------------------------------------------------------------------
 // Read/Write callback
 //------------------------------------------------------------------------------
	 int S7API RWAreaCallBack(void *usrPtr, int Sender, int Operation, PS7Tag PTag, void *pUsrData)
	 {
		 PRWBuffer PBuffer = (PRWBuffer)pUsrData;
		 int c;

		 if (Operation == OperationRead)
			 printf("Read Request\n");
		 else
			 printf("Write Request\n");

		 switch (PTag->Area)
		 {
         //case S7AreaPE: printf("Area : PE, ");
		 case 0x81: printf("Area : PE, ");
			 break;
		 case 0x82: printf("Area : PA, ");
			 break;
		 case 0x83: printf("Area : MK, ");
			 break;
		 case 0x1C: printf("Area : CT, ");
			 break;
		 case 0x1D: printf("Area : TM, ");
			 break;
		 case 0x84: printf("Area : DB%d, ", PTag->DBNumber);
			 break;
		 default: printf("Unknown area %d, ", PTag->Area);
		 }
		 printf("Start : %d, ", PTag->Start);
		 printf("Size : %d\n", PTag->Size);

		 if (Operation == OperationWrite)
			 hexdump(pUsrData, PTag->Size);
		 else
		 {
			 for (c = 0; c < 1024; c++)
				 PBuffer[c] = cnt;
			 cnt++;

		 }
		 printf("\n");
		 return 0;
	 };
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

	// Filter a bit of noise
	Srv_SetMask(Server, mkEvent, 0x3ff);
	// Set the Read/Write callback 
	Srv_SetRWAreaCallback(Server, RWAreaCallBack, NULL);
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
