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

namespace CSClientMultiRead
{
    public partial class Form1 : Form
    {
        private S7Client Client;
        
        private byte[] DB_A = new byte[256];
        private byte[] DB_B = new byte[256];
        private byte[] DB_C = new byte[256];

        private void ShowResult(int Result)
        {
            // This function returns a textual explaination of the error code
            TextError.Text = Client.ErrorText(Result);
        }

        private void Dump(TextBox Box, byte[] Buffer, int Size)
        {
            // Declaration separated from the code for readability
            int y;
            Box.Text = "";
            y = 0;
            for (int c = 0; c < Size; c++)
            {
                String S = Convert.ToString(Buffer[c], 16);
                if (S.Length == 1) S = "0" + S;
                Box.Text = Box.Text + "0x" + S + " ";
                y++;
                if (y == 8)
                {
                    y = 0;
                    Box.Text = Box.Text + (char)13 + (char)10;
                }
            }
        }

        public Form1()
        {
            InitializeComponent();
            Client = new S7Client();
            if (IntPtr.Size == 4)
                this.Text = this.Text + " - Running 32 bit Code";
            else
                this.Text = this.Text + " - Running 64 bit Code";
        }

        public void DBMultiRead()
        {
            // Reader Instance
            S7MultiVar Reader = new S7MultiVar(Client);

            TxtRes_A.Text = "";
            TxtRes_B.Text = "";
            TxtRes_C.Text = "";

            int DBNumber_A = System.Convert.ToInt32(TxtDB_A.Text);
            int DBNumber_B = System.Convert.ToInt32(TxtDB_B.Text);
            int DBNumber_C = System.Convert.ToInt32(TxtDB_C.Text);

            // Add Items def.
            Reader.Add(S7Client.S7AreaDB, S7Client.S7WLByte, DBNumber_A, 0, 16, ref DB_A);
            Reader.Add(S7Client.S7AreaDB, S7Client.S7WLByte, DBNumber_B, 0, 16, ref DB_B);
            Reader.Add(S7Client.S7AreaDB, S7Client.S7WLByte, DBNumber_C, 0, 16, ref DB_C);
            // Performs the Read
            int Result = Reader.Read();

            // Dumps the data and shows the results
            ShowResult(Result);

            
            TxtRes_A.Text = Client.ErrorText(Reader.Results[0]);
            if (Reader.Results[0] == 0)
                Dump(TxtDump_A, DB_A, 16);
            else
                TxtDump_A.Text = "< No Data Available >";

            TxtRes_B.Text = Client.ErrorText(Reader.Results[1]);
            if (Reader.Results[1] == 0)
                Dump(TxtDump_B, DB_B, 16);
            else
                TxtDump_B.Text = "< No Data Available >";

            TxtRes_C.Text = Client.ErrorText(Reader.Results[2]);
            if (Reader.Results[2] == 0)
                Dump(TxtDump_C, DB_C, 16);
            else
                TxtDump_C.Text = "< No Data Available >";
        }

        private void btnMultiRead_Click(object sender, EventArgs e)
        {
            DBMultiRead();
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
                btnMultiRead.Enabled = true;
                TxtDump_A.Enabled = true;
                TxtDump_B.Enabled = true;
                TxtDump_C.Enabled = true;
                TxtDB_A.Enabled = true;
                TxtDB_B.Enabled = true;
                TxtDB_C.Enabled = true;
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
            btnMultiRead.Enabled = false;
            TxtDump_A.Enabled = false;
            TxtDump_B.Enabled = false;
            TxtDump_C.Enabled = false;
            TxtDB_A.Enabled = false;
            TxtDB_B.Enabled = false;
            TxtDB_C.Enabled = false;
        }
    }
}
