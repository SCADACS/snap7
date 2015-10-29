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
|  Active Partner Example                                                      |
|                                                                              |
|=============================================================================*/
using System;
using System.Text;
using Snap7;

class ActivePartnerDemo
{
    const int size = 256;
    static S7Partner Partner;
    static byte[] Buffer = new byte[size];
    static byte cnt = 0;
    //------------------------------------------------------------------------------
    // Usage syntax 
    //------------------------------------------------------------------------------
    static void Usage()
    {
        Console.WriteLine("Usage");
        Console.WriteLine("  APartner <PassiveIP>");
        Console.WriteLine("Where");
        Console.WriteLine("  <PassiveIP> is the address of the passive partner that we want to connect.");
        Console.WriteLine("Note");
        Console.WriteLine("- Local Address is meaningless");
        Console.WriteLine("- Both Local TSAP and Remote TSAP are set to 0x1002");
        Console.WriteLine("- You can create multiple active partner in the same");
        Console.WriteLine("  program or across different programs.");
        Console.ReadKey();
    }
    //------------------------------------------------------------------------------
    // Simply fills the buffer with a progressive number
    //------------------------------------------------------------------------------
    static void PrepareBuffer()
    {
        cnt++;
        for (int i = 0; i < size; i++)
            Buffer[i] = cnt;
    }
    //------------------------------------------------------------------------------
    // Main                                                
    //------------------------------------------------------------------------------
    static void Main(string[] args)
    {
        int SndError = 0;
        // Get Progran args
        if (args.Length != 1)
        {
            Usage();
            return;
        }
        // Create the ACTIVE partner
        Partner = new S7Partner(1);
        // Start
        // Local Address for an active partner is meaningless, leave
        // it always set to "0.0.0.0"
        int Error=Partner.StartTo("0.0.0.0", args[0], 0x1002, 0x1002);
        if (Error != 0)
        {
            Console.WriteLine(Partner.ErrorText(Error));
            return;
        }           
        // Endless loop : Exit with Ctrl-C       
        while (true)
        {
            while (!Partner.Linked)
            {
                Console.WriteLine("Connecting to " + args[0] + "...");
                System.Threading.Thread.Sleep(500);
            };
            do
            {
                PrepareBuffer();
                SndError = Partner.BSend(0x00000001, Buffer, size);
                if (SndError == 0)
                    Console.WriteLine("Succesfully sent "+size.ToString()+" bytes");
                else
                    Console.WriteLine(Partner.ErrorText(SndError));
                System.Threading.Thread.Sleep(300);
            } while (SndError == 0);
        }
    }
}
