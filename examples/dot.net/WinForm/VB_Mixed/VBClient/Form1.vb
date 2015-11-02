Imports System
Imports Snap7

Public Class MainForm

    Dim Buffer(65536) As Byte ' Buffer  
    Dim Client As Snap7.S7Client ' Client Object

    Private Sub ShowResult(ByVal Result As Integer)
        ' This function returns a textual explaination of the error code
        TextError.Text = Client.ErrorText(Result)
    End Sub

    Public Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.
        Client = New S7Client

        If IntPtr.Size = 4 Then
            Text = Text + " - Running 32 bit Code"
        Else
            Text = Text + " - Running 64 bit Code"
        End If

    End Sub

    Private Sub ConnectBtn_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ConnectBtn.Click
        Dim Result As Integer
        Dim Rack As Integer = System.Convert.ToInt32(TxtRack.Text)
        Dim Slot As Integer = System.Convert.ToInt32(TxtSlot.Text)
        Result = Client.ConnectTo(TxtIP.Text, Rack, Slot)
        ShowResult(Result)
        If Result = 0 Then
            TxtIP.Enabled = False
            TxtRack.Enabled = False
            TxtSlot.Enabled = False
            ConnectBtn.Enabled = False
            DisconnectBtn.Enabled = True
            TxtDB.Enabled = True
            TxtSize.Enabled = True
            ReadBtn.Enabled = True
            TxtDump.Enabled = True
        End If
    End Sub

    Private Sub DisconnectBtn_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DisconnectBtn.Click
        Client.Disconnect()
        TxtIP.Enabled = True
        TxtRack.Enabled = True
        TxtSlot.Enabled = True
        ConnectBtn.Enabled = True
        DisconnectBtn.Enabled = False
        TxtDB.Enabled = False
        TxtSize.Enabled = False
        ReadBtn.Enabled = False
        TxtDump.Enabled = False
    End Sub

    Private Sub ReadBtn_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ReadBtn.Click
        ' Declaration separated from the code for readability
        Dim DBNumber As Integer
        Dim Size As Integer
        Dim Result As Integer
        Dim c, y As Integer
        Dim s As String
        '
        TxtDump.Text = ""
        DBNumber = System.Convert.ToInt32(TxtDB.Text)
        Size = System.Convert.ToInt32(TxtSize.Text)
        ' Read "Size" bytes from the DB "DBNumber" starting from 0 and puts them into Buffer.
        Result = Client.DBRead(DBNumber, 0, Size, Buffer)
        ShowResult(Result)
        ' If OK dumps the data (quick and dirty)
        If Result = 0 Then
            y = 0
            For c = 0 To Size - 1
                s = Hex$(Buffer(c))
                If s.Length = 1 Then
                    s = "0" + s
                End If
                TxtDump.Text = TxtDump.Text + "0x" + s + " "
                y = y + 1
                If y = 8 Then
                    y = 0
                    TxtDump.Text = TxtDump.Text + Chr(13) + Chr(10)
                End If
            Next
        End If
    End Sub
End Class
