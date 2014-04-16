/*=============================================================================|
|  PROJECT SNAP7                                                         1.2.0 |
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
|  Passive Partner Example                                                     |
|                                                                              |
|=============================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include "snap7.h"

#ifdef OS_WINDOWS
# define WIN32_LEAN_AND_MEAN
# include <windows.h>
#endif

	TS7Partner *Partner;
	byte Buffer[65536]; // 64 K buffer

//------------------------------------------------------------------------------
// Usage syntax
//------------------------------------------------------------------------------
void Usage()
{
	printf("Usage\n");
	printf("  PPartner <ActiveIP>\n");
	printf("Where\n");
	printf("  <ActiveIP> is the address of the active partner that we are waiting for.\n");
	printf("Note\n");
	printf("- Local Address is set to 0.0.0.0 (the default adapter)\n");
	printf("- Both Local TSAP and Remote TSAP are set to 0x1002\n");
	printf("- You can create multiple passive partners bound to the same\n");
	printf("  local address in the same program, but you cannot execute\n");
	printf("  multiple instance of this program.\n");
	getchar();
}
//------------------------------------------------------------------------------
// SysSleep (copied from snap_sysutils.cpp)
//------------------------------------------------------------------------------
void SysSleep(longword Delay_ms)
{
#ifdef OS_WINDOWS
    Sleep(Delay_ms);
#else
    struct timespec ts;
    ts.tv_sec = (time_t)(Delay_ms / 1000);
    ts.tv_nsec =(long)((Delay_ms - ts.tv_sec) * 1000000);
    nanosleep(&ts, (struct timespec *)0);
#endif
}
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

	for(i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++)
	{
			/* print offset */
			if(i % HEXDUMP_COLS == 0)
			{
				printf("0x%04x: ", i);
			}
			/* print hex data */
			if(i < len)
			{
				printf("%02x ", 0xFF & ((char*)mem)[i]);
			}
			else /* end of block, just aligning for ASCII dump */
			{
				printf("   ");
			}
			/* print ASCII dump */
			if(i % HEXDUMP_COLS == (HEXDUMP_COLS - 1))
			{
				for(j = i - (HEXDUMP_COLS - 1); j <= i; j++)
				{
					if(j >= len) /* end of block, not really printing */
					{
						putchar(' ');
					}
					else if(isprint((((char*)mem)[j] & 0x7F))) /* printable char */
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
// Callback on data ready
//------------------------------------------------------------------------------
void S7API RecvCallback(void * usrPtr, int opResult, longword R_ID, void *pdata, int Size)
{
	printf("R_ID : %d\n",R_ID);
	printf("Size : %d\n",Size);
	hexdump(pdata, Size);
}
//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
int main(int argc, char* argv[])
{
        // Get Progran args
		if (argc != 2)
		{
			Usage();
			return 1;
		}
		// Create the PASSIVE partner
		Partner = new TS7Partner(false);
		// Set the BRecv callback
		Partner->SetRecvCallback(RecvCallback, NULL);
		// Start
		int Error=Partner->StartTo("0.0.0.0", argv[1], 0x1002, 0x1002);
		if (Error == 0)
		    printf("Passive partner started\n");
		else
		    printf("%s\n",ParErrorText(Error).c_str());
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
		getchar();
		Partner->Stop();
		delete Partner;
}
