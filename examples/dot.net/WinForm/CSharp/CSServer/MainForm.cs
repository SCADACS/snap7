using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Snap7;

namespace CSServer
{
    public partial class MainForm : Form
    {
        private S7Server Server;
        S7Server.USrvEvent Event;

        byte[] DB1 = new byte[256];
        byte[] DB2 = new byte[256];
        byte[] DB3 = new byte[256];

        public MainForm()
        {
            InitializeComponent();
            Server = new S7Server();
            Event = new S7Server.USrvEvent();
            // Share some resources with our virtual PLC
            Server.RegisterArea(S7Server.srvAreaTM,  // We are registering a DB
                    1,                   // Its number is 1 (DB1)
                    ref DB1,             // Our buffer for DB1
                    DB1.Length);         // Its size
            // Do the same for DB2 and DB3
            Server.RegisterArea(S7Server.srvAreaDB, 2, ref DB2, DB2.Length);
            Server.RegisterArea(S7Server.srvAreaDB, 3, ref DB3, DB3.Length);

            HexDump(DB1_Box, DB1, DB1.Length);
            HexDump(DB2_Box, DB2, DB2.Length);
            HexDump(DB3_Box, DB3, DB3.Length);
            LogTimer.Enabled = true;
        }

        private void StartBtn_Click(object sender, EventArgs e)
        {
            if (Server.StartTo(TxtIP.Text)==0)
            {
                StartBtn.Enabled = false;
                TxtIP.Enabled = false;
                StopBtn.Enabled = true;
            }
        }

        private void HexDump(TextBox Box, byte[] bytes, int Size)
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

            Box.Clear();

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
            Box.Text = result.ToString();
        }

        private void LogTimer_Tick(object sender, EventArgs e)
        {
            // For event logging this method (a timer and PickEvent) is better than
            // the events callback used into the Server console demo.
            // Here we are using the internal Server message queue without
            // disturbing the client handshake.
            while (Server.PickEvent(ref Event))
            {
                if (EventsLog.Lines.Count() > 256)
                    EventsLog.Clear();                    
                EventsLog.AppendText(Server.EventText(ref Event)+"\n");

                // Example of how use the parameters inside the event struct.
                // Here we check if our DB were changed and, if yes, update the 
                // related textbox.


//                if ((Event.EvtCode == S7Server.evcDataWrite) &&   // write event               
 //                   (Event.EvtRetCode == 0) &&                    // succesfully
//                    (Event.EvtParam1 == S7Server.S7AreaDB))       // it's a DB
  
                if ((Event.EvtCode == S7Server.evcDataWrite) &&   // write event               
                        (Event.EvtRetCode == 0))
                    {
                    switch(Event.EvtParam2)
                    {
                        case 1: HexDump(DB1_Box, DB1, DB1.Length);
                            break;
                        case 2: HexDump(DB2_Box, DB2, DB2.Length);
                            break;
                        case 3: HexDump(DB3_Box, DB3, DB3.Length);
                            break;
                    }
                }
            }
        }

        private void StopBtn_Click(object sender, EventArgs e)
        {
            // Stops the server, all the clients are disconnected.
            Server.Stop();
            StopBtn.Enabled = false;
            StartBtn.Enabled = true;
            TxtIP.Enabled = true;
        }

        private void MaskChanged(object sender, EventArgs e)
        {
            // Only 3 options for simplicity.
            // Look at the documentation for the events bitmask list.           
            if (rbAll.Checked)
                Server.LogMask = 0xFFFFFFFF;
            else
                if (rbReadWrite.Checked)
                    Server.LogMask = 0x000603FF;
                else
                    if (rbConn.Checked)
                        Server.LogMask = 0x000003FF;
        }

        private void ClearBtn_Click(object sender, EventArgs e)
        {
            // Simply clears the Log RichTextBox
            EventsLog.Clear();
        }

        private void FlushBtn_Click(object sender, EventArgs e)
        {
            // Flushs the internal Server Events Queue
            Server.ClearEvents();
        }
    }
}
