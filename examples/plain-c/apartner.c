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
|  Active Partner Example                                                      |
|                                                                              |
|=============================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "snap7.h"

#ifdef OS_WINDOWS
# define WIN32_LEAN_AND_MEAN
# include <windows.h>
#endif
#define size 256

    int cnt = 0;
	byte Buffer[size]; 
	S7Object Partner;

//------------------------------------------------------------------------------
// Usage syntax 
//------------------------------------------------------------------------------
static void Usage()
{
    printf("Usage\n");
    printf("  APartner <PassiveIP>\n");
    printf("Where\n");
    printf("  <PassiveIP> is the address of the passive partner that we want to connect.\n");
    printf("Note\n");
    printf("- Local Address is meaningless\n");
    printf("- Both Local TSAP and Remote TSAP are set to 0x1002\n");
    printf("- You can create multiple active partner in the same\n");
    printf("  program or across different programs.\n");
}
//------------------------------------------------------------------------------
// Simply fills the buffer with a progressive number
//------------------------------------------------------------------------------
void PrepareBuffer()
{
    int i;
	cnt++;
    for (i = 0; i < size; i++)
        Buffer[i] = cnt;
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
bool ParLinked()
{
	int ParStatus;
	Par_GetStatus(Partner, &ParStatus);
	return ParStatus==par_linked;
}
//------------------------------------------------------------------------------
void PrintError(int Error)
{
	char text[1024];
	Par_ErrorText(Partner, text, 1024);
	printf("%s\n",text);
}
//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
int main(int argc, char* argv[])
{
    int SndError = 0;
	int Error;
    // Get Progran args
    if (argc!=2)
    {
        Usage();
        return 1;
    };
    // Create the ACTIVE partner
    Partner = Par_Create(1);
    // Start
    // Local Address for an active partner is meaningless, leave
    // it always set to "0.0.0.0"
    Error=Par_StartTo(Partner, "0.0.0.0", argv[1], 0x1002, 0x1002);
    if (Error != 0)
    {
		PrintError(Error);
        return 1;
    }           
    // Endless loop : Exit with Ctrl-C       
    while (1)
    {
        while (!ParLinked())
        {
            printf("Connecting to %s ...\n",argv[1]);
            SysSleep(500);
        };
        do
        {
            PrepareBuffer();
            SndError = Par_BSend(Partner, 0x00000001, &Buffer, size);
            if (SndError == 0)
                printf("Succesfully sent %d bytes\n",size);
            else
                PrintError(SndError);
            SysSleep(500);
        } while (SndError == 0);
    }
}
