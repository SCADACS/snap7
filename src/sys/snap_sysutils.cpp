/*=============================================================================|
|  PROJECT SNAP7                                                         1.1.0 |
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
|=============================================================================*/

#include "snap_sysutils.h"
//---------------------------------------------------------------------------
longword SysGetTick()
{
#ifdef OS_WINDOWS
    return timeGetTime();
#else
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (longword) (ts.tv_sec * 1000) + (ts.tv_nsec / 1000000);
#endif
}
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
longword DeltaTime(longword &Elapsed)
{
    longword TheTime;
    TheTime=SysGetTick();
    // Checks for rollover
    if (TheTime<Elapsed)
        Elapsed=0;
    return TheTime-Elapsed;
}
//---------------------------------------------------------------------------
word SwapWord(word Value)
{
    return  ((Value >> 8) & 0xFF) | ((Value << 8) & 0xFF00);
}
//---------------------------------------------------------------------------
longword SwapDWord(longword Value)
{
    #pragma pack(1)
    typedef struct {
        union {
            struct {
                byte b1, b2, b3, b4;
            }bb; // to be ISO C++ compliant we cannot have unnamed struct
            longword Value;
        };
    } lw;
    #pragma pack()

    lw Result;
    byte tmp;

    Result.Value=Value;
    tmp=Result.bb.b4;
    Result.bb.b4=Result.bb.b1;
    Result.bb.b1=tmp;
    tmp=Result.bb.b3;
    Result.bb.b3=Result.bb.b2;
    Result.bb.b2=tmp;
    return Result.Value;
}
