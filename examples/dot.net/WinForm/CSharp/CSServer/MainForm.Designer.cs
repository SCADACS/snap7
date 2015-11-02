namespace CSServer
{
    partial class MainForm
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.Label1 = new System.Windows.Forms.Label();
            this.TxtIP = new System.Windows.Forms.TextBox();
            this.StopBtn = new System.Windows.Forms.Button();
            this.StartBtn = new System.Windows.Forms.Button();
            this.LogTimer = new System.Windows.Forms.Timer(this.components);
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.EventsLog = new System.Windows.Forms.RichTextBox();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.DB1_Box = new System.Windows.Forms.TextBox();
            this.tabPage4 = new System.Windows.Forms.TabPage();
            this.DB2_Box = new System.Windows.Forms.TextBox();
            this.tabPage5 = new System.Windows.Forms.TabPage();
            this.DB3_Box = new System.Windows.Forms.TextBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.richTextBox1 = new System.Windows.Forms.RichTextBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rbConn = new System.Windows.Forms.RadioButton();
            this.rbReadWrite = new System.Windows.Forms.RadioButton();
            this.rbAll = new System.Windows.Forms.RadioButton();
            this.FlushBtn = new System.Windows.Forms.Button();
            this.ClearBtn = new System.Windows.Forms.Button();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage3.SuspendLayout();
            this.tabPage4.SuspendLayout();
            this.tabPage5.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // Label1
            // 
            this.Label1.AutoSize = true;
            this.Label1.Location = new System.Drawing.Point(12, 9);
            this.Label1.Name = "Label1";
            this.Label1.Size = new System.Drawing.Size(58, 13);
            this.Label1.TabIndex = 26;
            this.Label1.Text = "IP Address";
            // 
            // TxtIP
            // 
            this.TxtIP.Location = new System.Drawing.Point(12, 27);
            this.TxtIP.Name = "TxtIP";
            this.TxtIP.Size = new System.Drawing.Size(100, 20);
            this.TxtIP.TabIndex = 25;
            this.TxtIP.Text = "0.0.0.0";
            // 
            // StopBtn
            // 
            this.StopBtn.Enabled = false;
            this.StopBtn.Location = new System.Drawing.Point(125, 53);
            this.StopBtn.Name = "StopBtn";
            this.StopBtn.Size = new System.Drawing.Size(100, 23);
            this.StopBtn.TabIndex = 33;
            this.StopBtn.Text = "Stop";
            this.StopBtn.UseVisualStyleBackColor = true;
            this.StopBtn.Click += new System.EventHandler(this.StopBtn_Click);
            // 
            // StartBtn
            // 
            this.StartBtn.Location = new System.Drawing.Point(12, 52);
            this.StartBtn.Name = "StartBtn";
            this.StartBtn.Size = new System.Drawing.Size(100, 23);
            this.StartBtn.TabIndex = 32;
            this.StartBtn.Text = "Start";
            this.StartBtn.UseVisualStyleBackColor = true;
            this.StartBtn.Click += new System.EventHandler(this.StartBtn_Click);
            // 
            // LogTimer
            // 
            this.LogTimer.Tick += new System.EventHandler(this.LogTimer_Tick);
            // 
            // tabControl1
            // 
            this.tabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage3);
            this.tabControl1.Controls.Add(this.tabPage4);
            this.tabControl1.Controls.Add(this.tabPage5);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Location = new System.Drawing.Point(2, 96);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(795, 492);
            this.tabControl1.TabIndex = 35;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.EventsLog);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(787, 466);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Log";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // EventsLog
            // 
            this.EventsLog.Cursor = System.Windows.Forms.Cursors.Default;
            this.EventsLog.Dock = System.Windows.Forms.DockStyle.Fill;
            this.EventsLog.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.EventsLog.Location = new System.Drawing.Point(3, 3);
            this.EventsLog.Name = "EventsLog";
            this.EventsLog.Size = new System.Drawing.Size(781, 460);
            this.EventsLog.TabIndex = 1;
            this.EventsLog.Text = "";
            // 
            // tabPage3
            // 
            this.tabPage3.Controls.Add(this.DB1_Box);
            this.tabPage3.Location = new System.Drawing.Point(4, 22);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(787, 466);
            this.tabPage3.TabIndex = 2;
            this.tabPage3.Text = "DB 1";
            this.tabPage3.UseVisualStyleBackColor = true;
            // 
            // DB1_Box
            // 
            this.DB1_Box.BackColor = System.Drawing.SystemColors.Window;
            this.DB1_Box.Cursor = System.Windows.Forms.Cursors.Default;
            this.DB1_Box.Dock = System.Windows.Forms.DockStyle.Fill;
            this.DB1_Box.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.DB1_Box.ForeColor = System.Drawing.SystemColors.WindowText;
            this.DB1_Box.Location = new System.Drawing.Point(3, 3);
            this.DB1_Box.Multiline = true;
            this.DB1_Box.Name = "DB1_Box";
            this.DB1_Box.ReadOnly = true;
            this.DB1_Box.Size = new System.Drawing.Size(781, 460);
            this.DB1_Box.TabIndex = 0;
            // 
            // tabPage4
            // 
            this.tabPage4.Controls.Add(this.DB2_Box);
            this.tabPage4.Location = new System.Drawing.Point(4, 22);
            this.tabPage4.Name = "tabPage4";
            this.tabPage4.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage4.Size = new System.Drawing.Size(787, 466);
            this.tabPage4.TabIndex = 3;
            this.tabPage4.Text = "DB 2";
            this.tabPage4.UseVisualStyleBackColor = true;
            // 
            // DB2_Box
            // 
            this.DB2_Box.BackColor = System.Drawing.SystemColors.Window;
            this.DB2_Box.Cursor = System.Windows.Forms.Cursors.Default;
            this.DB2_Box.Dock = System.Windows.Forms.DockStyle.Fill;
            this.DB2_Box.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.DB2_Box.ForeColor = System.Drawing.SystemColors.WindowText;
            this.DB2_Box.Location = new System.Drawing.Point(3, 3);
            this.DB2_Box.Multiline = true;
            this.DB2_Box.Name = "DB2_Box";
            this.DB2_Box.ReadOnly = true;
            this.DB2_Box.Size = new System.Drawing.Size(781, 460);
            this.DB2_Box.TabIndex = 1;
            // 
            // tabPage5
            // 
            this.tabPage5.Controls.Add(this.DB3_Box);
            this.tabPage5.Location = new System.Drawing.Point(4, 22);
            this.tabPage5.Name = "tabPage5";
            this.tabPage5.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage5.Size = new System.Drawing.Size(787, 466);
            this.tabPage5.TabIndex = 4;
            this.tabPage5.Text = "DB 3";
            this.tabPage5.UseVisualStyleBackColor = true;
            // 
            // DB3_Box
            // 
            this.DB3_Box.BackColor = System.Drawing.SystemColors.Window;
            this.DB3_Box.Cursor = System.Windows.Forms.Cursors.Default;
            this.DB3_Box.Dock = System.Windows.Forms.DockStyle.Fill;
            this.DB3_Box.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.DB3_Box.ForeColor = System.Drawing.SystemColors.WindowText;
            this.DB3_Box.Location = new System.Drawing.Point(3, 3);
            this.DB3_Box.Multiline = true;
            this.DB3_Box.Name = "DB3_Box";
            this.DB3_Box.ReadOnly = true;
            this.DB3_Box.Size = new System.Drawing.Size(781, 460);
            this.DB3_Box.TabIndex = 1;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.richTextBox1);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(787, 466);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Why it doesn\'t work ??";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // richTextBox1
            // 
            this.richTextBox1.BackColor = System.Drawing.SystemColors.Info;
            this.richTextBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.richTextBox1.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.richTextBox1.ForeColor = System.Drawing.Color.Navy;
            this.richTextBox1.Location = new System.Drawing.Point(3, 3);
            this.richTextBox1.Name = "richTextBox1";
            this.richTextBox1.ReadOnly = true;
            this.richTextBox1.ShortcutsEnabled = false;
            this.richTextBox1.Size = new System.Drawing.Size(781, 460);
            this.richTextBox1.TabIndex = 0;
            this.richTextBox1.Text = resources.GetString("richTextBox1.Text");
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.ClearBtn);
            this.groupBox1.Controls.Add(this.FlushBtn);
            this.groupBox1.Controls.Add(this.rbConn);
            this.groupBox1.Controls.Add(this.rbReadWrite);
            this.groupBox1.Controls.Add(this.rbAll);
            this.groupBox1.Location = new System.Drawing.Point(257, 9);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(360, 81);
            this.groupBox1.TabIndex = 38;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Log filter";
            // 
            // rbConn
            // 
            this.rbConn.AutoSize = true;
            this.rbConn.Location = new System.Drawing.Point(15, 58);
            this.rbConn.Name = "rbConn";
            this.rbConn.Size = new System.Drawing.Size(170, 17);
            this.rbConn.TabIndex = 2;
            this.rbConn.Text = "Only the incoming connections";
            this.rbConn.UseVisualStyleBackColor = true;
            this.rbConn.CheckedChanged += new System.EventHandler(this.MaskChanged);
            // 
            // rbReadWrite
            // 
            this.rbReadWrite.AutoSize = true;
            this.rbReadWrite.Location = new System.Drawing.Point(15, 38);
            this.rbReadWrite.Name = "rbReadWrite";
            this.rbReadWrite.Size = new System.Drawing.Size(141, 17);
            this.rbReadWrite.TabIndex = 1;
            this.rbReadWrite.Text = "Only Read/Write Events";
            this.rbReadWrite.UseVisualStyleBackColor = true;
            this.rbReadWrite.CheckedChanged += new System.EventHandler(this.MaskChanged);
            // 
            // rbAll
            // 
            this.rbAll.AutoSize = true;
            this.rbAll.Checked = true;
            this.rbAll.Location = new System.Drawing.Point(15, 18);
            this.rbAll.Name = "rbAll";
            this.rbAll.Size = new System.Drawing.Size(119, 17);
            this.rbAll.TabIndex = 0;
            this.rbAll.TabStop = true;
            this.rbAll.Text = "Detailed (All events)";
            this.rbAll.UseVisualStyleBackColor = true;
            this.rbAll.CheckedChanged += new System.EventHandler(this.MaskChanged);
            // 
            // FlushBtn
            // 
            this.FlushBtn.Location = new System.Drawing.Point(222, 15);
            this.FlushBtn.Name = "FlushBtn";
            this.FlushBtn.Size = new System.Drawing.Size(122, 23);
            this.FlushBtn.TabIndex = 3;
            this.FlushBtn.Text = "Flush Server Queue";
            this.FlushBtn.UseVisualStyleBackColor = true;
            this.FlushBtn.Click += new System.EventHandler(this.FlushBtn_Click);
            // 
            // ClearBtn
            // 
            this.ClearBtn.Location = new System.Drawing.Point(222, 48);
            this.ClearBtn.Name = "ClearBtn";
            this.ClearBtn.Size = new System.Drawing.Size(122, 23);
            this.ClearBtn.TabIndex = 4;
            this.ClearBtn.Text = "Clear Log Box";
            this.ClearBtn.UseVisualStyleBackColor = true;
            this.ClearBtn.Click += new System.EventHandler(this.ClearBtn_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(797, 588);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.StopBtn);
            this.Controls.Add(this.StartBtn);
            this.Controls.Add(this.Label1);
            this.Controls.Add(this.TxtIP);
            this.MinimumSize = new System.Drawing.Size(810, 200);
            this.Name = "MainForm";
            this.Text = "C# Server Demo";
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage3.ResumeLayout(false);
            this.tabPage3.PerformLayout();
            this.tabPage4.ResumeLayout(false);
            this.tabPage4.PerformLayout();
            this.tabPage5.ResumeLayout(false);
            this.tabPage5.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        internal System.Windows.Forms.Label Label1;
        internal System.Windows.Forms.TextBox TxtIP;
        internal System.Windows.Forms.Button StopBtn;
        internal System.Windows.Forms.Button StartBtn;
        private System.Windows.Forms.Timer LogTimer;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.RichTextBox EventsLog;
        private System.Windows.Forms.TabPage tabPage2;
        private System.Windows.Forms.RichTextBox richTextBox1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton rbConn;
        private System.Windows.Forms.RadioButton rbReadWrite;
        private System.Windows.Forms.RadioButton rbAll;
        private System.Windows.Forms.TabPage tabPage3;
        private System.Windows.Forms.TextBox DB1_Box;
        private System.Windows.Forms.TabPage tabPage4;
        private System.Windows.Forms.TabPage tabPage5;
        private System.Windows.Forms.TextBox DB2_Box;
        private System.Windows.Forms.TextBox DB3_Box;
        private System.Windows.Forms.Button ClearBtn;
        private System.Windows.Forms.Button FlushBtn;
    }
}

