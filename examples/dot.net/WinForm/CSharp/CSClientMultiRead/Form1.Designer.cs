namespace CSClientMultiRead
{
    partial class Form1
    {
        /// <summary>
        /// Variabile di progettazione necessaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Pulire le risorse in uso.
        /// </summary>
        /// <param name="disposing">ha valore true se le risorse gestite devono essere eliminate, false in caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Codice generato da Progettazione Windows Form

        /// <summary>
        /// Metodo necessario per il supporto della finestra di progettazione. Non modificare
        /// il contenuto del metodo con l'editor di codice.
        /// </summary>
        private void InitializeComponent()
        {
            this.Label11 = new System.Windows.Forms.Label();
            this.Label10 = new System.Windows.Forms.Label();
            this.Label9 = new System.Windows.Forms.Label();
            this.Label8 = new System.Windows.Forms.Label();
            this.Label5 = new System.Windows.Forms.Label();
            this.Label4 = new System.Windows.Forms.Label();
            this.DisconnectBtn = new System.Windows.Forms.Button();
            this.ConnectBtn = new System.Windows.Forms.Button();
            this.Label3 = new System.Windows.Forms.Label();
            this.TxtSlot = new System.Windows.Forms.TextBox();
            this.Label2 = new System.Windows.Forms.Label();
            this.TxtRack = new System.Windows.Forms.TextBox();
            this.Label1 = new System.Windows.Forms.Label();
            this.TxtIP = new System.Windows.Forms.TextBox();
            this.btnMultiRead = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.TxtDump_A = new System.Windows.Forms.TextBox();
            this.TextError = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.label12 = new System.Windows.Forms.Label();
            this.TxtDump_B = new System.Windows.Forms.TextBox();
            this.label13 = new System.Windows.Forms.Label();
            this.TxtDump_C = new System.Windows.Forms.TextBox();
            this.TxtRes_A = new System.Windows.Forms.TextBox();
            this.label14 = new System.Windows.Forms.Label();
            this.label15 = new System.Windows.Forms.Label();
            this.TxtRes_B = new System.Windows.Forms.TextBox();
            this.label16 = new System.Windows.Forms.Label();
            this.TxtRes_C = new System.Windows.Forms.TextBox();
            this.TxtDB_A = new System.Windows.Forms.TextBox();
            this.TxtDB_B = new System.Windows.Forms.TextBox();
            this.TxtDB_C = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // Label11
            // 
            this.Label11.AutoSize = true;
            this.Label11.Location = new System.Drawing.Point(312, 41);
            this.Label11.Name = "Label11";
            this.Label11.Size = new System.Drawing.Size(81, 13);
            this.Label11.TabIndex = 59;
            this.Label11.Text = "Rack=0, Slot=0";
            // 
            // Label10
            // 
            this.Label10.AutoSize = true;
            this.Label10.Location = new System.Drawing.Point(312, 28);
            this.Label10.Name = "Label10";
            this.Label10.Size = new System.Drawing.Size(81, 13);
            this.Label10.TabIndex = 58;
            this.Label10.Text = "See HW Config";
            // 
            // Label9
            // 
            this.Label9.AutoSize = true;
            this.Label9.Location = new System.Drawing.Point(312, 15);
            this.Label9.Name = "Label9";
            this.Label9.Size = new System.Drawing.Size(81, 13);
            this.Label9.TabIndex = 57;
            this.Label9.Text = "Rack=0, Slot=2";
            // 
            // Label8
            // 
            this.Label8.AutoSize = true;
            this.Label8.Location = new System.Drawing.Point(230, 28);
            this.Label8.Name = "Label8";
            this.Label8.Size = new System.Drawing.Size(76, 13);
            this.Label8.TabIndex = 56;
            this.Label8.Text = "S7400/WinAC";
            // 
            // Label5
            // 
            this.Label5.AutoSize = true;
            this.Label5.Location = new System.Drawing.Point(230, 41);
            this.Label5.Name = "Label5";
            this.Label5.Size = new System.Drawing.Size(73, 13);
            this.Label5.TabIndex = 55;
            this.Label5.Text = "S71200/1500";
            // 
            // Label4
            // 
            this.Label4.AutoSize = true;
            this.Label4.Location = new System.Drawing.Point(230, 15);
            this.Label4.Name = "Label4";
            this.Label4.Size = new System.Drawing.Size(38, 13);
            this.Label4.TabIndex = 54;
            this.Label4.Text = "S7300";
            // 
            // DisconnectBtn
            // 
            this.DisconnectBtn.Enabled = false;
            this.DisconnectBtn.Location = new System.Drawing.Point(120, 68);
            this.DisconnectBtn.Name = "DisconnectBtn";
            this.DisconnectBtn.Size = new System.Drawing.Size(100, 23);
            this.DisconnectBtn.TabIndex = 53;
            this.DisconnectBtn.Text = "Disconnect";
            this.DisconnectBtn.UseVisualStyleBackColor = true;
            this.DisconnectBtn.Click += new System.EventHandler(this.DisconnectBtn_Click);
            // 
            // ConnectBtn
            // 
            this.ConnectBtn.Location = new System.Drawing.Point(10, 68);
            this.ConnectBtn.Name = "ConnectBtn";
            this.ConnectBtn.Size = new System.Drawing.Size(100, 23);
            this.ConnectBtn.TabIndex = 50;
            this.ConnectBtn.Text = "Connect";
            this.ConnectBtn.UseVisualStyleBackColor = true;
            this.ConnectBtn.Click += new System.EventHandler(this.ConnectBtn_Click);
            // 
            // Label3
            // 
            this.Label3.AutoSize = true;
            this.Label3.Location = new System.Drawing.Point(176, 8);
            this.Label3.Name = "Label3";
            this.Label3.Size = new System.Drawing.Size(25, 13);
            this.Label3.TabIndex = 52;
            this.Label3.Text = "Slot";
            // 
            // TxtSlot
            // 
            this.TxtSlot.Location = new System.Drawing.Point(176, 26);
            this.TxtSlot.Name = "TxtSlot";
            this.TxtSlot.Size = new System.Drawing.Size(44, 20);
            this.TxtSlot.TabIndex = 49;
            this.TxtSlot.Text = "2";
            // 
            // Label2
            // 
            this.Label2.AutoSize = true;
            this.Label2.Location = new System.Drawing.Point(120, 8);
            this.Label2.Name = "Label2";
            this.Label2.Size = new System.Drawing.Size(33, 13);
            this.Label2.TabIndex = 51;
            this.Label2.Text = "Rack";
            // 
            // TxtRack
            // 
            this.TxtRack.Location = new System.Drawing.Point(120, 26);
            this.TxtRack.Name = "TxtRack";
            this.TxtRack.Size = new System.Drawing.Size(44, 20);
            this.TxtRack.TabIndex = 47;
            this.TxtRack.Text = "0";
            // 
            // Label1
            // 
            this.Label1.AutoSize = true;
            this.Label1.Location = new System.Drawing.Point(10, 8);
            this.Label1.Name = "Label1";
            this.Label1.Size = new System.Drawing.Size(58, 13);
            this.Label1.TabIndex = 48;
            this.Label1.Text = "IP Address";
            // 
            // TxtIP
            // 
            this.TxtIP.Location = new System.Drawing.Point(10, 26);
            this.TxtIP.Name = "TxtIP";
            this.TxtIP.Size = new System.Drawing.Size(100, 20);
            this.TxtIP.TabIndex = 46;
            this.TxtIP.Text = "192.168.0.72";
            // 
            // btnMultiRead
            // 
            this.btnMultiRead.Enabled = false;
            this.btnMultiRead.Location = new System.Drawing.Point(10, 112);
            this.btnMultiRead.Name = "btnMultiRead";
            this.btnMultiRead.Size = new System.Drawing.Size(100, 23);
            this.btnMultiRead.TabIndex = 61;
            this.btnMultiRead.Text = "MultiRead";
            this.btnMultiRead.UseVisualStyleBackColor = true;
            this.btnMultiRead.Click += new System.EventHandler(this.btnMultiRead_Click);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(123, 117);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(103, 13);
            this.label6.TabIndex = 62;
            this.label6.Text = "MultiReads 16 bytes";
            // 
            // TxtDump_A
            // 
            this.TxtDump_A.BackColor = System.Drawing.Color.White;
            this.TxtDump_A.Enabled = false;
            this.TxtDump_A.Font = new System.Drawing.Font("Courier New", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtDump_A.ForeColor = System.Drawing.Color.Black;
            this.TxtDump_A.Location = new System.Drawing.Point(120, 148);
            this.TxtDump_A.Multiline = true;
            this.TxtDump_A.Name = "TxtDump_A";
            this.TxtDump_A.ReadOnly = true;
            this.TxtDump_A.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.TxtDump_A.Size = new System.Drawing.Size(302, 74);
            this.TxtDump_A.TabIndex = 63;
            // 
            // TextError
            // 
            this.TextError.BackColor = System.Drawing.Color.White;
            this.TextError.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.TextError.ForeColor = System.Drawing.Color.Black;
            this.TextError.Location = new System.Drawing.Point(0, 482);
            this.TextError.Name = "TextError";
            this.TextError.ReadOnly = true;
            this.TextError.Size = new System.Drawing.Size(441, 20);
            this.TextError.TabIndex = 64;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(24, 152);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(44, 13);
            this.label7.TabIndex = 65;
            this.label7.Text = "1St. DB";
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(24, 260);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(48, 13);
            this.label12.TabIndex = 67;
            this.label12.Text = "2Nd. DB";
            // 
            // TxtDump_B
            // 
            this.TxtDump_B.BackColor = System.Drawing.Color.White;
            this.TxtDump_B.Enabled = false;
            this.TxtDump_B.Font = new System.Drawing.Font("Courier New", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtDump_B.ForeColor = System.Drawing.Color.Black;
            this.TxtDump_B.Location = new System.Drawing.Point(120, 256);
            this.TxtDump_B.Multiline = true;
            this.TxtDump_B.Name = "TxtDump_B";
            this.TxtDump_B.ReadOnly = true;
            this.TxtDump_B.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.TxtDump_B.Size = new System.Drawing.Size(302, 74);
            this.TxtDump_B.TabIndex = 66;
            // 
            // label13
            // 
            this.label13.AutoSize = true;
            this.label13.Location = new System.Drawing.Point(24, 368);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(47, 13);
            this.label13.TabIndex = 69;
            this.label13.Text = "3Th. DB";
            // 
            // TxtDump_C
            // 
            this.TxtDump_C.BackColor = System.Drawing.Color.White;
            this.TxtDump_C.Enabled = false;
            this.TxtDump_C.Font = new System.Drawing.Font("Courier New", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtDump_C.ForeColor = System.Drawing.Color.Black;
            this.TxtDump_C.Location = new System.Drawing.Point(120, 364);
            this.TxtDump_C.Multiline = true;
            this.TxtDump_C.Name = "TxtDump_C";
            this.TxtDump_C.ReadOnly = true;
            this.TxtDump_C.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.TxtDump_C.Size = new System.Drawing.Size(302, 74);
            this.TxtDump_C.TabIndex = 68;
            // 
            // TxtRes_A
            // 
            this.TxtRes_A.Location = new System.Drawing.Point(120, 228);
            this.TxtRes_A.Name = "TxtRes_A";
            this.TxtRes_A.ReadOnly = true;
            this.TxtRes_A.Size = new System.Drawing.Size(302, 20);
            this.TxtRes_A.TabIndex = 70;
            // 
            // label14
            // 
            this.label14.AutoSize = true;
            this.label14.Location = new System.Drawing.Point(55, 231);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(59, 13);
            this.label14.TabIndex = 71;
            this.label14.Text = "1St. Result";
            // 
            // label15
            // 
            this.label15.AutoSize = true;
            this.label15.Location = new System.Drawing.Point(55, 340);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(63, 13);
            this.label15.TabIndex = 73;
            this.label15.Text = "2Nd. Result";
            // 
            // TxtRes_B
            // 
            this.TxtRes_B.Location = new System.Drawing.Point(121, 337);
            this.TxtRes_B.Name = "TxtRes_B";
            this.TxtRes_B.ReadOnly = true;
            this.TxtRes_B.Size = new System.Drawing.Size(302, 20);
            this.TxtRes_B.TabIndex = 72;
            // 
            // label16
            // 
            this.label16.AutoSize = true;
            this.label16.Location = new System.Drawing.Point(56, 447);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(62, 13);
            this.label16.TabIndex = 75;
            this.label16.Text = "3Th. Result";
            // 
            // TxtRes_C
            // 
            this.TxtRes_C.Location = new System.Drawing.Point(121, 444);
            this.TxtRes_C.Name = "TxtRes_C";
            this.TxtRes_C.ReadOnly = true;
            this.TxtRes_C.Size = new System.Drawing.Size(302, 20);
            this.TxtRes_C.TabIndex = 74;
            // 
            // TxtDB_A
            // 
            this.TxtDB_A.Enabled = false;
            this.TxtDB_A.Location = new System.Drawing.Point(27, 168);
            this.TxtDB_A.Name = "TxtDB_A";
            this.TxtDB_A.Size = new System.Drawing.Size(45, 20);
            this.TxtDB_A.TabIndex = 76;
            this.TxtDB_A.Text = "1";
            // 
            // TxtDB_B
            // 
            this.TxtDB_B.Enabled = false;
            this.TxtDB_B.Location = new System.Drawing.Point(27, 276);
            this.TxtDB_B.Name = "TxtDB_B";
            this.TxtDB_B.Size = new System.Drawing.Size(45, 20);
            this.TxtDB_B.TabIndex = 77;
            this.TxtDB_B.Text = "2";
            // 
            // TxtDB_C
            // 
            this.TxtDB_C.Enabled = false;
            this.TxtDB_C.Location = new System.Drawing.Point(27, 384);
            this.TxtDB_C.Name = "TxtDB_C";
            this.TxtDB_C.Size = new System.Drawing.Size(45, 20);
            this.TxtDB_C.TabIndex = 78;
            this.TxtDB_C.Text = "3";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(441, 502);
            this.Controls.Add(this.TxtDB_C);
            this.Controls.Add(this.TxtDB_B);
            this.Controls.Add(this.TxtDB_A);
            this.Controls.Add(this.label16);
            this.Controls.Add(this.TxtRes_C);
            this.Controls.Add(this.label15);
            this.Controls.Add(this.TxtRes_B);
            this.Controls.Add(this.label14);
            this.Controls.Add(this.TxtRes_A);
            this.Controls.Add(this.label13);
            this.Controls.Add(this.TxtDump_C);
            this.Controls.Add(this.label12);
            this.Controls.Add(this.TxtDump_B);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.TextError);
            this.Controls.Add(this.TxtDump_A);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.btnMultiRead);
            this.Controls.Add(this.Label11);
            this.Controls.Add(this.Label10);
            this.Controls.Add(this.Label9);
            this.Controls.Add(this.Label8);
            this.Controls.Add(this.Label5);
            this.Controls.Add(this.Label4);
            this.Controls.Add(this.DisconnectBtn);
            this.Controls.Add(this.ConnectBtn);
            this.Controls.Add(this.Label3);
            this.Controls.Add(this.TxtSlot);
            this.Controls.Add(this.Label2);
            this.Controls.Add(this.TxtRack);
            this.Controls.Add(this.Label1);
            this.Controls.Add(this.TxtIP);
            this.Name = "Form1";
            this.Text = "C# Simple MultiRead Demo";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        internal System.Windows.Forms.Label Label11;
        internal System.Windows.Forms.Label Label10;
        internal System.Windows.Forms.Label Label9;
        internal System.Windows.Forms.Label Label8;
        internal System.Windows.Forms.Label Label5;
        internal System.Windows.Forms.Label Label4;
        internal System.Windows.Forms.Button DisconnectBtn;
        internal System.Windows.Forms.Button ConnectBtn;
        internal System.Windows.Forms.Label Label3;
        internal System.Windows.Forms.TextBox TxtSlot;
        internal System.Windows.Forms.Label Label2;
        internal System.Windows.Forms.TextBox TxtRack;
        internal System.Windows.Forms.Label Label1;
        internal System.Windows.Forms.TextBox TxtIP;
        private System.Windows.Forms.Button btnMultiRead;
        internal System.Windows.Forms.Label label6;
        internal System.Windows.Forms.TextBox TxtDump_A;
        internal System.Windows.Forms.TextBox TextError;
        internal System.Windows.Forms.Label label7;
        internal System.Windows.Forms.Label label12;
        internal System.Windows.Forms.TextBox TxtDump_B;
        internal System.Windows.Forms.Label label13;
        internal System.Windows.Forms.TextBox TxtDump_C;
        private System.Windows.Forms.TextBox TxtRes_A;
        private System.Windows.Forms.Label label14;
        private System.Windows.Forms.Label label15;
        private System.Windows.Forms.TextBox TxtRes_B;
        private System.Windows.Forms.Label label16;
        private System.Windows.Forms.TextBox TxtRes_C;
        internal System.Windows.Forms.TextBox TxtDB_A;
        internal System.Windows.Forms.TextBox TxtDB_B;
        internal System.Windows.Forms.TextBox TxtDB_C;
    }
}

