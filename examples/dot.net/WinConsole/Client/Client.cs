/*=============================================================================|
|  PROJECT SNAP7                                                         1.4.0 |
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
|  Client Example                                                              |
|                                                                              |
|=============================================================================*/
using System;
using System.Runtime.InteropServices;
using System.Text;
using Snap7;

class ClientDemo
{
    static S7Client Client;
    static int ok = 0, ko = 0;
    static int SampleDB = -1;
    static int SampleDBSize = 0;
    static int AsyncResult;
    static bool AsyncDone;
    private static S7Client.S7CliCompletion Completion; // <== Static var containig the callback

    // Async completion is called when an async operation was complete
    // For this simply text demo we only set a flag....
    static void CompletionProc(IntPtr usrPtr, int opCode, int opResult)
    {
        AsyncResult = opResult;
        AsyncDone = true;
    }

    #region [Utility]

    //------------------------------------------------------------------------------
    // Usage syntax 
    //------------------------------------------------------------------------------
    static void Usage()
    {
        Console.WriteLine("Usage");
        Console.WriteLine("  client <IP> [Rack=0 Slot=2]");
        Console.WriteLine("Example");
        Console.WriteLine("  client 192.168.1.101 0 2");
        Console.WriteLine("or");
        Console.WriteLine("  client 192.168.1.101");
        Console.ReadKey();
    }
    //-------------------------------------------------------------------------  
    // Summary
    //-------------------------------------------------------------------------  
    static void Summary()
    {
        Console.WriteLine();
        Console.WriteLine("+-----------------------------------------------------");
        Console.WriteLine("| Test Summary");
        Console.WriteLine("+-----------------------------------------------------");
        Console.WriteLine("| Performed : " + (ok + ko).ToString());
        Console.WriteLine("| Passed    : " + ok.ToString());
        Console.WriteLine("| Failed    : " + ko.ToString());
        Console.WriteLine("+----------------------------------------[press a key]");
    }
    //------------------------------------------------------------------------------
    // HexDump, a very nice function, it's not mine.
    // I found it on the net somewhere some time ago... thanks to the author ;-)
    //------------------------------------------------------------------------------
    static void HexDump(byte[] bytes, int Size)
    {
        if (bytes == null)
            return;
        int bytesLength = Size;
        int bytesPerLine = 16;

        char[] HexChars = "0123456789ABCDEF".ToCharArray();

        int firstHexColumn =
              8                   // 8 characters for the address
            + 3;                  // 3 spaces

        int firstCharColumn = firstHexColumn
            + bytesPerLine * 3       // - 2 digit for the hexadecimal value and 1 space
            + (bytesPerLine - 1) / 8 // - 1 extra space every 8 characters from the 9th
            + 2;                  // 2 spaces 

        int lineLength = firstCharColumn
            + bytesPerLine           // - characters to show the ascii value
            + Environment.NewLine.Length; // Carriage return and line feed (should normally be 2)

        char[] line = (new String(' ', lineLength - 2) + Environment.NewLine).ToCharArray();
        int expectedLines = (bytesLength + bytesPerLine - 1) / bytesPerLine;
        StringBuilder result = new StringBuilder(expectedLines * lineLength);

        for (int i = 0; i < bytesLength; i += bytesPerLine)
        {
            line[0] = HexChars[(i >> 28) & 0xF];
            line[1] = HexChars[(i >> 24) & 0xF];
            line[2] = HexChars[(i >> 20) & 0xF];
            line[3] = HexChars[(i >> 16) & 0xF];
            line[4] = HexChars[(i >> 12) & 0xF];
            line[5] = HexChars[(i >> 8) & 0xF];
            line[6] = HexChars[(i >> 4) & 0xF];
            line[7] = HexChars[(i >> 0) & 0xF];

            int hexColumn = firstHexColumn;
            int charColumn = firstCharColumn;

            for (int j = 0; j < bytesPerLine; j++)
            {
                if (j > 0 && (j & 7) == 0) hexColumn++;
                if (i + j >= bytesLength)
                {
                    line[hexColumn] = ' ';
                    line[hexColumn + 1] = ' ';
                    line[charColumn] = ' ';
                }
                else
                {
                    byte b = bytes[i + j];
                    line[hexColumn] = HexChars[(b >> 4) & 0xF];
                    line[hexColumn + 1] = HexChars[b & 0xF];
                    line[charColumn] = (b < 32 ? '·' : (char)b);
                }
                hexColumn += 3;
                charColumn++;
            }
            result.Append(line);
#if __MonoCS__
            result.Append('\n');
#endif
        }
        Console.WriteLine(result.ToString());
    }
    //------------------------------------------------------------------------------
    // Check error (simply writes an header)
    //------------------------------------------------------------------------------
    static bool Check(int Result, string FunctionPerformed)
    {
        Console.WriteLine();
        Console.WriteLine("+-----------------------------------------------------");
        Console.WriteLine("| " + FunctionPerformed);
        Console.WriteLine("+-----------------------------------------------------");
        if (Result == 0)
        {
            int ExecTime = Client.ExecTime();
            Console.WriteLine("| Result         : OK");
            Console.WriteLine("| Execution time : " + ExecTime.ToString() + " ms"); //+ Client.getex->ExecTime());
            Console.WriteLine("+-----------------------------------------------------");
            ok++; // one more test passed
        }
        else
        {
            Console.WriteLine("| ERROR !!! \n");
            if (Result < 0)
                Console.WriteLine("| Library Error (-1)\n");
            else
                Console.WriteLine("| " + Client.ErrorText(Result));
            Console.WriteLine("+-----------------------------------------------------\n");
            ko++;
        }
        return Result == 0;
    }
    #endregion

    #region [Info]
    //------------------------------------------------------------------------------
    // CPU Info : unit info
    //------------------------------------------------------------------------------
    static void CpuInfo()
    {
        S7Client.S7CpuInfo Info = new S7Client.S7CpuInfo();
        int res = Client.GetCpuInfo(ref Info);
        if (Check(res, "Unit Info"))
        {
            Console.WriteLine("  Module Type Name : " + Info.ModuleTypeName);
            Console.WriteLine("  Serial Number    : " + Info.SerialNumber);
            Console.WriteLine("  AS Name          : " + Info.ASName);
            Console.WriteLine("  Module Name      : " + Info.ModuleName);
        };
    }
    //------------------------------------------------------------------------------
    // List blocks in AG and chose a DB for next tests
    //------------------------------------------------------------------------------
    static void ListBlocks()
    {
        S7Client.S7BlocksList List = new S7Client.S7BlocksList();
        ushort[] DBList = new ushort[0x4000];
        int ItemsCount = DBList.Length;

        int res = Client.ListBlocks(ref List);
        if (Check(res, "List Blocks in AG"))
        {
            Console.WriteLine("  OBCount  : " + List.OBCount.ToString());
            Console.WriteLine("  FBCount  : " + List.FBCount.ToString());
            Console.WriteLine("  FCCount  : " + List.FCCount.ToString());
            Console.WriteLine("  SFBCount : " + List.SFBCount.ToString());
            Console.WriteLine("  SFCCount : " + List.SFCCount.ToString());
            Console.WriteLine("  DBCount  : " + List.DBCount.ToString());
            Console.WriteLine("  SDBCount : " + List.SDBCount.ToString());
        }
        else
            return;
        // List Blocks of Type (DB)
        // Note about ItemsCount: 
        //   on input must contain the buffer items count available 
        //   on output it contains the number of the items found
        //   
        res = Client.ListBlocksOfType(S7Client.Block_DB, DBList, ref ItemsCount);
        if (Check(res, "DB List in AG"))
        {
            if (ItemsCount > 0)
            {
                for (int i = 0; i < ItemsCount; i++)
                    Console.WriteLine("  DB " + DBList[i].ToString());
                SampleDB = DBList[0]; // Choose the 1st DB as Sample
                Console.WriteLine();
                Console.WriteLine("  DB " + SampleDB.ToString() + " was chosen to make some tests..");
            }
            else
                Console.WriteLine("NO DB found, please load at least 1 DB to perform some tests...");
        }
    }
    //-------------------------------------------------------------------------  
    // Read a SZL block : ID 0x0011 IDX 0x0000
    //-------------------------------------------------------------------------  
    static void ReadSZL_0011_0000()
    {
        S7Client.S7SZL SZL = new S7Client.S7SZL();
        int Size = 0x8000;
        int res = Client.ReadSZL(0x0011, 0x000, ref SZL, ref Size);
        if (Check(res, "Read SZL - ID : 0x0011, IDX 0x0000"))
        {
            Console.WriteLine("  LENTHDR : " + SZL.Header.LENTHDR.ToString());
            Console.WriteLine("  N_DR    : " + SZL.Header.N_DR.ToString());
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            HexDump(SZL.Data, Size);
        }
    }
    #endregion

    //------------------------------------------------------------------------------
    // DB Dump using DB Get                            
    //------------------------------------------------------------------------------
    static void DBGetAndDump()
    {
        if (SampleDB == -1)
            return; // we didn't find any DB in AG

        byte[] Buffer = new byte[0x10000]; // 64k buffer (max size allowed for a DB in S7400)
        // Note about Size: 
        //   on input must contain the buffer size (in bytes) available 
        //   on output it contains the bytes read 
        int Size = Buffer.Length;
        int res = Client.DBGet(SampleDB, Buffer, ref Size);
        if (Check(res, "DB Get (DB " + SampleDB.ToString() + ")"))
        {
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            SampleDBSize = Size; // Store it for next test ;-)
            HexDump(Buffer, Size);
        }
    }
    //------------------------------------------------------------------------------
    // DB Dump using DB Read                            
    //------------------------------------------------------------------------------
    static void DBReadAndDump()
    {
        if ((SampleDB == -1) || (SampleDBSize == 0))
            return; // we didn't find any DB in AG

        byte[] Buffer = new byte[SampleDBSize]; // 64k buffer (max size allowed for a DB in S7400)
        int res = Client.DBRead(SampleDB, 0, SampleDBSize, Buffer);
        if (Check(res, "DB Read (DB = " + SampleDB.ToString() + ", Start = 0, Size = " + SampleDBSize.ToString() + ", Buffer)"))
        {
            Console.WriteLine("Dump : " + SampleDBSize.ToString() + " bytes");
            HexDump(Buffer, SampleDBSize);
        }
    }
    //------------------------------------------------------------------------------
    // Sync Upload SDB0 
    //------------------------------------------------------------------------------
    static void UploadSDB0()
    {
        byte[] Buffer = new byte[0x10000]; // 64k buffer (max size allowed for a DB in S7400)
        int Size = Buffer.Length;
        // Note about Size: 
        //   on input must contain the buffer size (in bytes) available 
        //   on output it contains the bytes read 
        int res = Client.Upload(S7Client.Block_SDB, 0, Buffer, ref Size);
        if (Check(res, "Block Upload (SDB 0)"))
        {
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            HexDump(Buffer, Size);
        }
    }
    //------------------------------------------------------------------------------
    // Async Upload SDB0 using callback as "done" trigger 
    //------------------------------------------------------------------------------
    static void AsyncUploadCB_SDB0()
    {
        byte[] Buffer = new byte[0x10000]; // 64k buffer (max size allowed for a DB in S7400)
        int Size = Buffer.Length;
        AsyncDone = false;
        int res = Client.AsUpload(S7Client.Block_SDB, 0, Buffer, ref Size);
        if (res == 0) // this res refers only to the async job start
        {
            // this is a simply text mode demo : use callback to set a flag
            while (!AsyncDone)
            {
                System.Threading.Thread.Sleep(50);
            }
            res = AsyncResult; // this is the operation result
        };
        if (Check(res, "Async Block Upload (CallBack) (SDB 0)"))
        {
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            HexDump(Buffer, Size);
        }
    }
    //------------------------------------------------------------------------------
    // Async Upload SDB0 using Wait completion with timeout 
    //------------------------------------------------------------------------------
    static void AsyncUploadWC_SDB0()
    {
        byte[] Buffer = new byte[0x10000]; // 64k buffer (max size allowed for a DB in S7400)
        int Size = Buffer.Length;
        int res = Client.AsUpload(S7Client.Block_SDB, 0, Buffer, ref Size);
        if (res == 0) // this res refers only to the async job start
        {
            res = Client.WaitAsCompletion(3000);
        };
        if (Check(res, "Async Block Upload (Wait completion) (SDB 0)"))
        {
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            HexDump(Buffer, Size);
        }
    }
    //------------------------------------------------------------------------------
    // Async Upload SDB0 using Check completion (polling)    
    //------------------------------------------------------------------------------
    static void AsyncUploadCC_SDB0()
    {
        byte[] Buffer = new byte[0x10000]; // 64k buffer (max size allowed for a DB in S7400)
        int Size = Buffer.Length;
        int res = Client.AsUpload(S7Client.Block_SDB, 0, Buffer, ref Size);
        if (res == 0) // this res refers only to the async job start
        {
            while (!Client.CheckAsCompletion(ref res))
            {
                System.Threading.Thread.Sleep(50);
            }
        };
        if (Check(res, "Async Block Upload (Polling) (SDB 0)"))
        {
            Console.WriteLine("Dump : " + Size.ToString() + " bytes");
            HexDump(Buffer, Size);
        }
    }

    //-------------------------------------------------------------------------  
    // PLC connection
    //-------------------------------------------------------------------------  
    static bool PlcConnect(string Address, int Rack, int Slot)
    {
        int res = Client.ConnectTo(Address, Rack, Slot);
        if (Check(res, "UNIT Connection"))
        {
            int Requested = Client.RequestedPduLength();
            int Negotiated = Client.NegotiatedPduLength();
            Console.WriteLine("  Connected to   : " + Address + " (Rack=" + Rack.ToString() + ", Slot=" + Slot.ToString() + ")");
            Console.WriteLine("  PDU Requested  : " + Requested.ToString());
            Console.WriteLine("  PDU Negotiated : " + Negotiated.ToString());
        }
        return res == 0;
    }

    //-------------------------------------------------------------------------  
    // PLC Stop/Run
    //-------------------------------------------------------------------------  
    static void StopRun()
    {
        int res = Client.PlcStop();
        Check(res, "PLC Stop");
        if (res==0)
        {
            Console.WriteLine();
            Console.WriteLine(" Waiting 2000 ms ....");
            System.Threading.Thread.Sleep(2000);
            Check(Client.PlcColdStart(), "PLC Cold Start");
        }
    }

    //-------------------------------------------------------------------------  
    // Perform some safe (readonly) tests
    //-------------------------------------------------------------------------  
    static void PerformTests()
    {
        CpuInfo();
        ListBlocks();
        DBGetAndDump();
        DBReadAndDump();
        UploadSDB0();
        ReadSZL_0011_0000();
        // Async functions
        AsyncUploadCB_SDB0();
        AsyncUploadWC_SDB0();
        AsyncUploadCC_SDB0();
        StopRun();
    }
    //-------------------------------------------------------------------------  
    // Main                                  
    //-------------------------------------------------------------------------  
    public static void Main(string[] args)
    {
        int Rack = 0, Slot = 2; // default for S7300

        // Uncomment next line if you are not able to see
        // the entire test text. (Note : Doesn't work in Mono 2.10)

        // Console.SetBufferSize(80, Int16.MaxValue-1);

        // Get Progran args
        if ((args.Length != 1) && (args.Length != 3))
        {
            Usage();
            return;
        }
        if (args.Length == 3) // only address without rack and slot
        {
            Rack = Convert.ToInt32(args[1]);
            Slot = Convert.ToInt32(args[2]);
        }
        // Client creation
        Client = new S7Client();
        // Set Async Completion Callback (without usrPtr, we don't need here).
        // You need this only if you use async functions and if you plan to 
        // use a callback as done trigger.
        // In this demo we will use all 3 completion strategies.

        // Set the callbacks (using the static var to avoid the garbage collect)
        Completion = new S7Client.S7CliCompletion(CompletionProc);
        Client.SetAsCallBack(Completion, IntPtr.Zero);
        // Try Connection
        if (PlcConnect(args[0], Rack, Slot))
        {
            PerformTests();
            Client.Disconnect();
        }
        // Prints a short summary
        Summary();
        Console.ReadKey();
    }
}
