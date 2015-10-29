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
|  Passive Partner Example                                                     |
|                                                                              |
|=============================================================================*/
using System;
using System.Text;
using System.Runtime.InteropServices;
using Snap7;

class PassivePartnerDemo
{
    static S7Partner Partner;
    
    private static S7Partner.S7ParRecvCallback CallBack; // <== Static var containig the callback
    //------------------------------------------------------------------------------
    // Delegate called on data ready
    //------------------------------------------------------------------------------
    static void RecvCallback(IntPtr usrPtr, int opResult, uint R_ID, IntPtr pData, int Size)
    {
        // Here we cast the generic pointer with a simply byte array.
        // For a specific struct (MyStruct) you can do:
        // MyStruct Buffer = (MyStruct)Marshal.PtrToStructure(pData, typeof(MyStruct));
        S7Partner.S7Buffer Buffer = (S7Partner.S7Buffer)Marshal.PtrToStructure(pData, typeof(S7Partner.S7Buffer));
        Console.Clear();
        Console.WriteLine("R_ID : " + R_ID.ToString());
        Console.WriteLine("Size : " + Size.ToString());
        HexDump(Buffer.Data, Size);
    }
    //------------------------------------------------------------------------------
    // Usage syntax
    //------------------------------------------------------------------------------
    static void Usage()
    {
        Console.WriteLine("Usage");
        Console.WriteLine("  PPartner <ActiveIP>");
        Console.WriteLine("Where");
        Console.WriteLine("  <ActiveIP> is the address of the active partner that we are waiting for.");
        Console.WriteLine("Note");
        Console.WriteLine("- Local Address is set to 0.0.0.0 (the default adapter)");
        Console.WriteLine("- Both Local TSAP and Remote TSAP are set to 0x1002");
        Console.WriteLine("- You can create multiple passive partners bound to the same");
        Console.WriteLine("  local address in the same program, but you cannot execute");
        Console.WriteLine("  multiple instance of this program.");
        Console.ReadKey();
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
    // Main                                                
    //------------------------------------------------------------------------------
    static void Main(string[] args)
    {
        // Get Progran args
        if (args.Length != 1)
        {
            Usage();
            return;
        }
        // Create the PASSIVE partner
        Partner = new S7Partner(0);
        
        // Set the BRecv callback (using the static var to avoid the garbage collect)
        CallBack = new S7Partner.S7ParRecvCallback(RecvCallback);
        Partner.SetRecvCallback(CallBack, IntPtr.Zero);
        
        // Start
        int Error=Partner.StartTo("0.0.0.0", args[0], 0x1002, 0x1002);
        if (Error == 0)
            Console.WriteLine("Passive partner started");
        else
            Console.WriteLine(Partner.ErrorText(Error));
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
        Console.ReadKey();
        Partner.Stop(); 
    }
}
