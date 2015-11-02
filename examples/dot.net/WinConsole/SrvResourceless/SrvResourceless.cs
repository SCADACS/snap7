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
|  Resourceless Server example (1.4.0)                                         |
|  The Server ha not shared resources. On every Read/Write request a callback  |
|  is invoked.                                                                 |
|  To the callback are passed the Tag (Area, Start...) and a pointer to a data |
|  that you can read/write.                                                    |
|                                                                              |
|=============================================================================*/

using System;
using System.Runtime.InteropServices;
using System.Text;
using Snap7;

class ServerDemo
{
    static S7Server Server;
    private static S7Server.TSrvCallback TheEventCallBack; // <== Static var containig the callback
    private static S7Server.TSrvRWAreaCallback TheRWAreaCallBack; // <== Static var containig the callback
    private static byte cnt = 0;
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
    // HexDump, a very nice function, it's not mine.
    // I found it on the net somewhere some time ago... thanks to the author ;-)
    //------------------------------------------------------------------------------
    static void EventCallback(IntPtr usrPtr, ref S7Server.USrvEvent Event, int Size)
    {    
        Console.WriteLine(Server.EventText(ref Event));
    }

    static int SrvRWAreaCallback(IntPtr usrPtr, int Sender, int Operation, ref S7Consts.S7Tag Tag, ref S7Server.RWBuffer Buffer)
    {

        if (Operation == S7Server.OperationRead)
            Console.WriteLine("Read Request");
        else
            Console.WriteLine("Write Request");

        switch (Tag.Area)
        {
            case S7Server.S7AreaPE : Console.Write("Area : PE, ");
                break;
            case S7Server.S7AreaPA: Console.Write("Area : PA, ");
                break;
            case S7Server.S7AreaMK: Console.Write("Area : MK, ");
                break;
            case S7Server.S7AreaCT: Console.Write("Area : CT, ");
                break;
            case S7Server.S7AreaTM: Console.Write("Area : TM, ");
                break;
            case S7Server.S7AreaDB: Console.Write("Area : DB" + System.Convert.ToString(Tag.DBNumber)+" ");
                break;
            default: Console.Write("Unknown area "+System.Convert.ToString(Tag.Area));
                break;
        }

        Console.Write("Start : "+ System.Convert.ToString(Tag.Start)+", ");
        Console.WriteLine("Size : "+ System.Convert.ToString(Tag.Size));

        if (Operation == S7Server.OperationWrite)
            HexDump(Buffer.Data, Tag.Size);
        else
        { 
            for (int c = 0; c < 1024; c++ )
                Buffer.Data[c] = cnt;
            cnt++;
        }
        return 0;
    }


    static void Main(string[] args)
    {
        Server = new S7Server();

        // Set the callbacks (using the static var to avoid the garbage collect)
        TheEventCallBack = new S7Server.TSrvCallback(EventCallback);
        TheRWAreaCallBack = new S7Server.TSrvRWAreaCallback(SrvRWAreaCallback);


        // Filter a bit of noise
        Server.EventMask = 0x3ff;
        Server.SetEventsCallBack(TheEventCallBack, IntPtr.Zero);
        Server.SetRWAreaCallBack(TheRWAreaCallBack, IntPtr.Zero);

        // Uncomment next line if you don't want to see wrapped messages 
        // (Note : Doesn't work in Mono 2.10)

         Console.SetBufferSize(100, Int16.MaxValue - 1);

        // Start the server onto the default adapter.
        // To select an adapter we have to use Server->StartTo("192.168.x.y").
        // Start() is the same of StartTo("0.0.0.0");       
        int Error = Server.Start();
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
