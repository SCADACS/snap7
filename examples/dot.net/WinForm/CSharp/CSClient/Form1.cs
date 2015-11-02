using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Snap7;

namespace CSClient
{

    public partial class MainForm : Form
    {
        private S7Client Client;
        private byte[] Buffer = new byte[65536];

        private void ShowResult(int Result)
        {
            // This function returns a textual explaination of the error code
            TextError.Text = Client.ErrorText(Result);
        }

        public MainForm()
        {
            InitializeComponent();
            Client = new S7Client();
            if (IntPtr.Size == 4)
                this.Text = this.Text + " - Running 32 bit Code";
            else
                this.Text = this.Text + " - Running 64 bit Code";

            CBType.SelectedIndex = 0;
        }

        private void ConnectBtn_Click(object sender, EventArgs e)
        {
            int Result;
            int Rack = System.Convert.ToInt32(TxtRack.Text);
            int Slot = System.Convert.ToInt32(TxtSlot.Text);
            Result = Client.ConnectTo(TxtIP.Text, Rack, Slot);
            ShowResult(Result);
            if (Result == 0)
            {
                TxtIP.Enabled = false;
                TxtRack.Enabled = false;
                TxtSlot.Enabled = false;
                ConnectBtn.Enabled = false;
                DisconnectBtn.Enabled = true;
                TxtDB.Enabled = true;
                TxtSize.Enabled = true;
                ReadBtn.Enabled = true;
                TxtDump.Enabled = true;
            }
        }

        private void DisconnectBtn_Click(object sender, EventArgs e)
        {
            Client.Disconnect();
            TxtIP.Enabled = true;
            TxtRack.Enabled = true;
            TxtSlot.Enabled = true;
            ConnectBtn.Enabled = true;
            DisconnectBtn.Enabled = false;
            TxtDB.Enabled = false;
            TxtSize.Enabled = false;
            ReadBtn.Enabled = false;
            TxtDump.Enabled = false;
        }

        private void HexDump(byte[] bytes, int Size)
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
            }
            TxtDump.Text=result.ToString();
        }

        private void PlcDBRead()
        {
            // Declaration separated from the code for readability
            int DBNumber;
            int Size;
            int Result;

            DBNumber = System.Convert.ToInt32(TxtDB.Text);
            Size = System.Convert.ToInt32(TxtSize.Text);
            Result = Client.DBRead(DBNumber, 0, Size, Buffer);
            ShowResult(Result);
            if (Result == 0)
                HexDump(Buffer, Size);            
        }

        private void PlcDBWrite()
        {
            // Declaration separated from the code for readability
            int DBNumber;
            int Size;
            int Result;

            DBNumber = System.Convert.ToInt32(TxtDB.Text);
            Size = System.Convert.ToInt32(TxtSize.Text);
            Result = Client.DBWrite(DBNumber, 0, Size, Buffer);
            ShowResult(Result);
        }

        private void ReadBtn_Click(object sender, EventArgs e)
        {
            PlcDBRead();
        }

        private void FieldBtn_Click(object sender, EventArgs e)
        {
/*
          0 Byte    8 Bit Word                     (All)
          1 Word   16 Bit Word                     (All)
          2 DWord  32 Bit Word                     (All)
          3 LWord  64 Bit Word                     (S71500)
          4 USint   8 Bit Unsigned Integer         (S71200/1500)
          5 UInt   16 Bit Unsigned Integer         (S71200/1500)
          6 UDInt  32 Bit Unsigned Integer         (S71200/1500)
          7 ULint  64 Bit Unsigned Integer         (S71500)
          8 Sint    8 Bit Signed Integer           (S71200/1500)
          9 Int    16 Bit Signed Integer           (All)
         10 DInt   32 Bit Signed Integer           (S71200/1500)
         11 LInt   64 Bit Signed Integer           (S71500)
         12 Real   32 Bit Floating point           (All)
         13 LReal  64 Bit Floating point           (S71200/1500)
         14 Time   32 Bit Time elapsed ms          (All)
         15 LTime  64 Bit Time Elapsed ns          (S71500)
         16 Date   16 Bit days from 1990/1/1       (All)
         17 TOD    32 Bit ms elapsed from midnight (All)
         18 DT      8 Byte Date and Time           (All)
         19 LTOD   64 Bit time of day (ns)         (S71500)
         20 DTL    12 Byte Date and Time Long      (S71200/1500)
         21 LDT    64 Bit ns elapsed from 1970/1/1 (S71500)
*/
            int Pos = System.Convert.ToInt32(TxtOffset.Text);
            switch(CBType.SelectedIndex)
            {
                case 0:
                    {
                        TxtValue.Text = "16#" + System.Convert.ToString(Buffer[Pos], 16).ToUpper();
                        break;
                    }
                case 1:
                    {
                        UInt16 Word = S7.GetWordAt(Buffer, Pos);
                        TxtValue.Text = "16#" + System.Convert.ToString(Word, 16).ToUpper();
                        break;
                    }
                case 2:
                    {
                        UInt32 DWord = S7.GetDWordAt(Buffer, Pos);
                        TxtValue.Text = "16#" + System.Convert.ToString(DWord, 16).ToUpper();
                        break;
                    }
                case 3:
                    {
                        UInt64 LWord = S7.GetLWordAt(Buffer, Pos);
                        TxtValue.Text = "16#" + System.Convert.ToString((Int64)LWord, 16).ToUpper(); // <-- Convert.ToString does not handle UInt64
                        break;
                    }
                case 4:
                    {
                        UInt16 USInt = S7.GetUSIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(USInt);
                        break;
                    }
                case 5:
                    {
                        UInt16 UInt = S7.GetUIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(UInt);
                        break;
                    }
                case 6:
                    {
                        UInt32 UDInt = S7.GetDWordAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(UDInt);
                        break;
                    }
                case 7:
                    {
                        UInt64 ULInt = S7.GetLWordAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(ULInt);
                        break;
                    }
                case 8:
                    {
                        int SInt = S7.GetSIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(SInt);
                        break;
                    }
                case 9:
                    {
                        int S7Int = S7.GetIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(S7Int);
                        break;
                    }
                case 10:
                    {
                        int DInt = S7.GetDIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(DInt);
                        break;
                    }
                case 11:
                    {
                        Int64 LInt = S7.GetLIntAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(LInt);
                        break;
                    }
                case 12:
                    {
                        Single S7Real = S7.GetRealAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(S7Real);
                        break;
                    }
                case 13:
                    {
                        Double S7LReal = S7.GetLRealAt(Buffer, Pos);
                        TxtValue.Text = System.Convert.ToString(S7LReal);
                        break;
                    }
                case 14:
                    {
                        Int32 TimeElapsed = S7.GetDIntAt(Buffer, Pos);
                        // TIME type is a 32 signed number of ms elapsed
                        // Can be added to a DateTime or used as Value.
                        TxtValue.Text = "T#" + System.Convert.ToString(TimeElapsed) + "MS";
                        break;
                    }
                case 15:
                    {
                        Int64 TimeElapsed = S7.GetLIntAt(Buffer, Pos);
                        // LTIME type is a 64 signed number of ns elapsed
                        // Can be added (after a conversion) to a DateTime or used as Value.
                        TxtValue.Text = "LT#" + System.Convert.ToString(TimeElapsed) + "NS";
                        break;
                    }
                case 16:
                    {
                        DateTime DATE = S7.GetDateAt(Buffer, Pos);
                        TxtValue.Text = DATE.ToString("D#yyyy-MM-dd");
                        break;
                    }
                case 17:
                    {
                        DateTime TOD = S7.GetTODAt(Buffer, Pos);
                        TxtValue.Text = TOD.ToString("TOD#HH:mm:ss.fff");
                        break;
                    }
                case 18:
                    {
                        DateTime DT = S7.GetDateTimeAt(Buffer, Pos);
                        TxtValue.Text = DT.ToString("DT#yyyy-MM-dd-HH:mm:ss.fff");
                        break;
                    }
                case 19:
                    {
                        DateTime LTOD = S7.GetLTODAt(Buffer, Pos);
                        TxtValue.Text = LTOD.ToString("LTOD#HH:mm:ss.fffffff");
                        break;
                    }
                case 20:
                    {
                        DateTime DTL = S7.GetDTLAt(Buffer, Pos);
                        TxtValue.Text = DTL.ToString("DTL#yyyy-MM-dd-HH:mm:ss.fffffff");
                        break;
                    }
                case 21:
                    {
                        DateTime LDT = S7.GetLDTAt(Buffer, Pos);
                        TxtValue.Text = LDT.ToString("LDT#yyyy-MM-dd-HH:mm:ss.fffffff");
                        break;
                    }

            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            // These are tests done on my DB
            
            DateTime DT = DateTime.Now;
            S7.SetSIntAt(Buffer, 40, -125);
            S7.SetIntAt(Buffer, 42, 32501);
            S7.SetDIntAt(Buffer, 44, -332501);
            S7.SetLIntAt(Buffer, 48, -99832501);
            S7.SetRealAt(Buffer, 56, (float)98.778);
            S7.SetLRealAt(Buffer, 60, 123000000000.778);
            S7.SetUSIntAt(Buffer, 24, 125);
            S7.SetUIntAt(Buffer, 26, 32501);
            S7.SetUDIntAt(Buffer, 28, 332501);
            S7.SetULintAt(Buffer, 32, 99832501);
            S7.SetDateAt(Buffer, 80, DT);
            S7.SetTODAt(Buffer, 82, DT);
            S7.SetDTLAt(Buffer, 112, DT);
            S7.SetLTODAt(Buffer, 86, DT);
            S7.SetLDTAt(Buffer, 94, DT);
            PlcDBWrite();
        }

    }
}


