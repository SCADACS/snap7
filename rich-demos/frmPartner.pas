unit frmPartner;

{$MODE Delphi}

interface

uses
{$IFNDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, SyncObjs,
  StdCtrls, ExtCtrls,
  Snap7;

Const
  _Active  = true;   // <- the underscore to avoid conflicts with the Form property "Active"
  _Passive = false;

type

  TS7Buffer = packed array[0..$FFFF] of byte;

  TPartnerForm = class;

  TRecvThread = class(TThread)
  private
    FPartnerForm : TPartnerForm;
  public
    constructor Create(PartnerForm : TPartnerForm);
    procedure Execute; override;
  end;

  TPartnerForm = class(TForm)
    PageControl: TPageControl;
    TabBSend: TTabSheet;
    TabBRecv: TTabSheet;
    SB: TStatusBar;
    DataGrid: TStringGrid;
    GR_Remote: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    EdRemoteIP: TEdit;
    EdRemTsapHI: TEdit;
    EdRemTsapLO: TEdit;
    StartBtn: TButton;
    StopBtn: TButton;
    Label1: TLabel;
    Ed_R_ID: TEdit;
    Label4: TLabel;
    EdAmount: TEdit;
    BsendBtn: TButton;
    AsBsendBtn: TButton;
    lbldump: TLabel;
    RxMemo: TMemo;
    EdR_ID_In: TEdit;
    Label8: TLabel;
    GR_local: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    EdLocalIP: TEdit;
    EdLocTsapHI: TEdit;
    EdLocTsapLO: TEdit;
    DataLed: TStaticText;
    TLed: TTimer;
    TBsend: TTimer;
    ChkSend: TCheckBox;
    TStat: TTimer;
    TabStat: TTabSheet;
    EdSent: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    EdRecv: TEdit;
    RGMode: TRadioGroup;
    TBRecv: TTimer;
    EdTimeout: TEdit;
    Label13: TLabel;
    BRecvBtn: TButton;
    BRecvLbl: TLabel;
    ARGMode: TRadioGroup;
    procedure DataGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DataGridExit(Sender: TObject);
    procedure DataGridKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure TLedTimer(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure TStatTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChkSendClick(Sender: TObject);
    procedure TBsendTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BsendBtnClick(Sender: TObject);
    procedure AsBsendBtnClick(Sender: TObject);
    procedure RGModeClick(Sender: TObject);
    procedure TBRecvTimer(Sender: TObject);
    procedure ARGModeClick(Sender: TObject);
    procedure BRecvBtnClick(Sender: TObject);
  private
    { Private declarations }
    TxBuffer : TS7Buffer;
    FActive  : boolean;
    FRunning: boolean;
    RecvThread : TRecvThread;
    Cnt : byte;
    AsSendMode : integer;
    AsRecvMode : integer;
    FLastSendError: integer;
    FLastRecvError: integer;
    FLastStartError: integer;
    procedure ValidateGrid;
    procedure DataToGrid(Amount : integer);
    procedure GridToData(Amount : integer);
    procedure SetFRunning(const Value: boolean);
    procedure PartnerStart;
    procedure PartnerStop;
    procedure DumpData(P : PS7Buffer; Memo : TMemo; Count : integer);
    procedure BSend(Async : boolean; Const Cyclic : boolean = false);
    procedure SetFLastSendError(const Value: integer);
    procedure SetFLastRecvError(const Value: integer);
    procedure SetFLastStartError(const Value: integer);
    procedure WaitBSendCompletion;
    procedure BRecv(WithPolling : boolean);
    function ErrorText(ErrNo : integer) : String;
  public
    { Public declarations }
    Partner  : TS7Partner;
    RxBuffer : TS7Buffer;
    RxSize   : integer;
    RxR_ID   : cardinal;
    RxError  : integer;
    RxEvent  : TEvent;
    TxEvent  : TEvent;
    procedure DataIncoming;
    procedure CreatePartner(Mode : boolean);
    property Running : boolean read FRunning write SetFRunning;
    property LastStartError : integer read FLastStartError write SetFLastStartError;
    property LastSendError : integer read FLastSendError write SetFLastSendError;
    property LastRecvError : integer read FLastRecvError write SetFLastRecvError;
  end;

implementation
{$R *.lfm}

Const
   amPolling  = 0;
   amWait     = 1;
   amCallBack = 2;

Var
  CS : TCriticalSection;

procedure OnRecv(usrPtr : pointer; opResult : integer; R_ID : dword;
  pdata : pointer; size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
Var
  PF : TPartnerForm;
begin
  CS.Enter;
  try
    PF:=TPartnerForm(usrPtr);
    if Assigned(PF) then
    begin
      if opResult=0 then
      begin
        move(pdata^,PF.RxBuffer[0],Size);
        PF.RxSize:=Size;
        PF.RxR_ID:=R_ID;
      end;
      PF.RxError:=opResult;
      PF.RxEvent.SetEvent;
    end;
  finally
    CS.Leave;
  end;
end;

procedure OnSend(usrPtr : pointer; opResult : integer); stdcall;
var
  PF : TPartnerForm;
begin
  CS.Enter;
  try
    PF:=TPartnerForm(usrPtr);
    if Assigned(PF) then
      PF.TxEvent.SetEvent;
  finally
    CS.Leave;
  end;
end;


procedure TPartnerForm.ARGModeClick(Sender: TObject);
begin
  AsRecvMode:=ARGMode.ItemIndex; // 0 : amPolling
                                 // 1 : amEvent
                                 // 2 : amCallBack
  case AsRecvMode of
    amPolling,
    amWait    : begin
                  Partner.SetRecvCallback(nil,Self);  // <-- We don't want callback
                  BRecvBtn.Enabled:=true;
                end;
    amCallback: begin
                  Partner.SetRecvCallback(@OnRecv,Self);
                  BRecvBtn.Enabled:=false;           // <-- the recv is full async
                end;
  end;
  BRecvLbl.Enabled :=BRecvBtn.Enabled;
  EdTimeout.Enabled:=BRecvBtn.Enabled;
end;

procedure TPartnerForm.AsBsendBtnClick(Sender: TObject);
begin
  BSend(true,false);
end;

procedure TPartnerForm.BRecv(WithPolling: boolean);
Var
  Timeout : cardinal;
  Result : integer;
  Elapsed : cardinal;
  Done : boolean;
begin
  Timeout:=StrToIntDef(edTimeout.Text,0);
  edTimeout.Text:=IntToStr(Timeout);

  if WithPolling then
  begin
    Elapsed:=GetTickCount;
    repeat
       Application.ProcessMessages;
       Done:=Partner.CheckAsBRecvCompletion(Result,RxR_ID,@RxBuffer,RxSize);
    until Done or (GetTickCount-Elapsed>Timeout);
    if not Done then
      Result:=errParRecvTimeout;
  end
  else // Wait idle
    Result:=Partner.BRecv(Timeout,RxR_ID,@RxBuffer,RxSize);

  LastRecvError:=Result;
  if Result=0 then
  begin
    DumpData(@RxBuffer,RxMemo,RxSize);
    lbldump.Caption:='Data Dump : '+IntToStr(RxSize)+' bytes';
    EdR_ID_In.Text:='$'+IntToHex(RxR_ID,8);
  end;
end;

procedure TPartnerForm.BRecvBtnClick(Sender: TObject);
begin
  BRecv(ARGMode.ItemIndex=0);
end;

procedure TPartnerForm.BSend(Async: boolean; Const Cyclic : boolean = false);
Var
  Amount : integer;
  R_ID : cardinal;
  c: Integer;
  SendTime,RecvTime : cardinal;
begin
  // Amount
  Amount:=StrToIntDef(EdAmount.Text,0);
  if Amount>65536 then
    Amount:=65536;
  EdAmount.Text:=IntToStr(Amount);
  // R_ID
  R_ID:=StrToIntDef(Ed_R_ID.Text,0);
  Ed_R_ID.Text:='$'+IntToHex(R_ID,8);


  if Cyclic then
  begin
    TBSend.Enabled:=false;
    inc(Cnt);
    for c := 0 to Amount - 1 do
      TxBuffer[c]:=Cnt;
    DataToGrid(Amount);
  end
  else
    GridToData(Amount);

  if Async then
    FLastSendError:=Partner.AsBSend(R_ID,@TxBuffer,Amount)
  else
    LastSendError:=Partner.BSend(R_ID,@TxBuffer,Amount);

  if FLastSendError=0 then
  begin
    if ASync then
      WaitBSendCompletion;
  end;
  SB.Panels[1].Text:=IntToStr(Partner.SendTime)+' ms';

  if Cyclic then
    TBSend.Enabled:=true;
end;

procedure TPartnerForm.BsendBtnClick(Sender: TObject);
begin
  BSend(false,false);
end;

procedure TPartnerForm.ChkSendClick(Sender: TObject);
begin
  if ChkSend.Checked then
  begin
    BSendBtn.Enabled:=false;
    Ed_R_ID.Enabled:=false;
    EdAmount.Enabled:=false;
    AsBSendBtn.Enabled:=false;
    TBSend.Enabled:=true;
  end
  else begin
    TBSend.Enabled:=false;
    BSendBtn.Enabled:=true;
    AsBSendBtn.Enabled:=true;
    Ed_R_ID.Enabled:=true;
    EdAmount.Enabled:=true;
  end;
end;

procedure TPartnerForm.CreatePartner(Mode: boolean);
begin
  Partner:=TS7Partner.Create(Mode);

  FActive:=Mode;

  if FActive then
  begin
    Caption:='Active Partner';
    GR_Local.Caption:='Local Partner (Active)';
    GR_Remote.Caption:='Remote Partner (Passive)';
    EdLocalIP.Text:='';
    EdLocalIP.Color:=clBtnFace;
    EdLocalIP.Enabled:=false;
  end
  else begin
    Caption:='Passive Partner';
    GR_Local.Caption:='Local Partner (Passive)';
    GR_Remote.Caption:='Remote Partner (Active)';
  end;

  Partner.SetRecvCallback(@OnRecv,Self);
  BRecvBtn.Enabled:=false;             // <-- the recv is full async
  BRecvLbl.Enabled:=false;
  EdTimeout.Enabled:=false;
  ARgMode.ItemIndex:=2;

  Running:=false;
end;

procedure TPartnerForm.DataGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
Var
  aRect : TRect;
  aText : string;
  Style : TTextStyle;
begin
  with Sender as TStringGrid do
  begin
    ARect:=Rect;
    AText:=Cells[ACol,ARow];
    if (ACol=0) or (ARow=0) then
      Canvas.Brush.Color:=clbtnface
    else
      Canvas.Brush.Color:=clWhite;

    Canvas.FillRect(Rect);
    Style.Alignment:=taCenter;
    Style.Clipping:=true;
    Style.ExpandTabs:=false;
    Style.Layout:=tlCenter;
    Style.ShowPrefix:=false;
    Style.Wordbreak:=false;
    Style.SystemFont:=false;
    Style.RightToLeft:=false;

    Canvas.TextRect(ARect, 0,0, AText,Style);

    if gdfocused in State then
    begin
      Canvas.Brush.Color:=clRed;
      Canvas.FrameRect(ARect);
    end;
  end;
end;

procedure TPartnerForm.DataGridExit(Sender: TObject);
begin
  ValidateGrid;
end;

procedure TPartnerForm.DataGridKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    ValidateGrid;
end;

procedure TPartnerForm.DataIncoming;
begin
  if RxError=0 then
  begin
    DataLed.Color:=clLime;
    DumpData(@RxBuffer,RxMemo,RxSize);
    lbldump.Caption:='Data Dump : '+IntToStr(RxSize)+' bytes';
    EdR_ID_In.Text:='$'+IntToHex(RxR_ID,8);
    TLed.Enabled:=true;
  end;
  LastRecvError:=RxError;
end;

procedure TPartnerForm.DataToGrid(Amount: integer);
Var
 x, c, r : integer;
begin
  with DataGrid do
  begin
    c:=1;r:=1;
    for x := 0 to Amount - 1 do
    begin
      Cells[c,r]:='$'+IntToHex(TxBuffer[x],2);
      inc(c);
      if c=ColCount then
      begin
        c:=1;
        inc(r);
      end;
    end;
    Row:=1;
    Col:=1;
    if PageControl.ActivePage=TabBSend then
      SetFocus;
  end;
end;

procedure TPartnerForm.DumpData(P: PS7Buffer; Memo: TMemo; Count: integer);
Var
  SHex, SChr : string;
  Ch : AnsiChar;
  c, cnt : integer;
begin
  Memo.Lines.Clear;
  Memo.Lines.BeginUpdate;
  SHex:='';SChr:='';cnt:=0;
  try
    for c := 0 to Count - 1 do
    begin
      SHex:=SHex+IntToHex(P^[c],2)+' ';
      Ch:=AnsiChar(P^[c]);
      if not (Ch in ['a'..'z','A'..'Z','0'..'9','_','$','-',#32]) then
        Ch:='.';
      SChr:=SChr+String(Ch);
      inc(cnt);
      if cnt=16 then
      begin
        Memo.Lines.Add(SHex+'  '+SChr);
        SHex:='';SChr:='';
        cnt:=0;
      end;
    end;
    // Dump remainder
    if cnt>0 then
    begin
      while Length(SHex)<48 do
        SHex:=SHex+' ';
      Memo.Lines.Add(SHex+'  '+SChr);
    end;
  finally
    Memo.Lines.EndUpdate;
  end;
end;

function TPartnerForm.ErrorText(ErrNo: integer) : string;
begin
  Result:=String(ParErrorText(ErrNo));
end;

procedure TPartnerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TPartnerForm.FormCreate(Sender: TObject);
Var
  c : integer;
begin
  RxEvent:=TEvent.Create(nil,false,false,'');
  TxEvent:=TEvent.Create(nil,false,false,'');
  RecvThread := TRecvThread.Create(Self);
  RecvThread.Start;

  // Init Grid
  with DataGrid do
  begin
    DefaultColWidth:=32;
    ColWidths[0]:=48;
    DefaultRowHeight:=18;
    ColCount:=17;
    RowCount:=4097;
    for c := 1 to ColCount - 1 do
      Cells[c,0]:=inttohex(c-1,2);

    for c := 1 to RowCount - 1 do
      Cells[0,c]:=inttohex((c-1)*16,4);
  end;
  ValidateGrid;
end;

procedure TPartnerForm.FormDestroy(Sender: TObject);
begin
  Partner.Free;
  RecvThread.Terminate;
  RxEvent.SetEvent;
  TxEvent.SetEvent;
  RecvThread.Free;

  RxEvent.Free;;
  TxEvent.Free;
end;

procedure TPartnerForm.GridToData(Amount: integer);
Var
 x, c, r : integer;
begin
  ValidateGrid;
  with DataGrid do
  begin
    c:=1;r:=1;
    for x := 0 to Amount- 1 do
    begin
      TxBuffer[x]:=StrToIntDef(Cells[c,r],0);
      inc(c);
      if c=ColCount then
      begin
        c:=1;
        inc(r);
      end;
    end;
  end;
end;

procedure TPartnerForm.PartnerStart;
Var
  LocalAddress : AnsiString;
  RemoteAddress: AnsiString;
  LocalTsapHI  : integer;
  LocalTsapLO  : integer;
  RemoteTsapHI : integer;
  RemoteTsapLO : integer;
  LocalTsap    : integer;
  RemoteTsap   : integer;

  function GetChar(ED : TEdit) : integer;
  Var
    B : byte;
  begin
    B:=StrToIntDef('$'+Ed.Text,0);
    Ed.Text:=IntToHex(B,2);
    Result:=B;
  end;

begin
   LocalAddress :=EdLocalIP.Text;
   RemoteAddress:=EdRemoteIP.Text;
   LocalTsapHI  :=GetChar(EdLocTsapHI);
   LocalTsapLO  :=GetChar(EdLocTsapLO);
   RemoteTsapHI :=GetChar(EdRemTsapHI);
   RemoteTsapLO :=GetChar(EdRemTsapLO);

   LocalTsap    :=LocalTsapHI shl 8 + LocalTsapLO;
   RemoteTsap   :=RemoteTsapHI shl 8 + RemoteTsapLO;

   LastStartError:=Partner.StartTo(LocalAddress,
                                   RemoteAddress,
                                   LocalTsap,
                                   RemoteTsap);
   Running:=FLastStartError=0;
end;

procedure TPartnerForm.PartnerStop;
begin
  Partner.Stop;
  Running:=false;
  SB.Panels[2].Text:='';
end;

procedure TPartnerForm.RGModeClick(Sender: TObject);
begin
  AsSendMode:=RGMode.ItemIndex; // 0 : amPolling
                                // 1 : amEvent
                                // 2 : amCallBack

  case AsSendMode of
    amPolling,
    amWait    : Partner.SetSendCallback(nil,Self);
    amCallback: Partner.SetSendCallback(@OnSend,Self);
  end;
end;

procedure TPartnerForm.SetFLastRecvError(const Value: integer);
begin
  FLastRecvError := Value;
  if FLastRecvError=0 then
    SB.Panels[2].Text:='Last BRecv OK'
  else
    SB.Panels[2].Text:=ErrorText(FLastRecvError);
end;

procedure TPartnerForm.SetFLastSendError(const Value: integer);
begin

  FLastSendError := Value;
  if FLastSendError=0 then
    SB.Panels[2].Text:='Last BSend OK'
  else
    SB.Panels[2].Text:=ErrorText(FLastSendError);
end;

procedure TPartnerForm.SetFLastStartError(const Value: integer);
begin
  FLastStartError := Value;
  if FLastStartError=0 then
    SB.Panels[2].Text:='Last Start OK'
  else
    SB.Panels[2].Text:=ErrorText(FLastRecvError);
end;

procedure TPartnerForm.SetFRunning(const Value: boolean);
begin
  FRunning := Value;

  if FRunning then
  begin
    EdLocalIP.Enabled:=false;
    EdLocTsapHI.Enabled:=false;
    EdLocTsapLO.Enabled:=false;
    EdRemoteIP.Enabled:=false;
    EdRemTsapHI.Enabled:=false;
    EdRemTsapLO.Enabled:=false;
    StartBtn.Enabled:=false;
    StopBtn.Enabled:=true;
    BSendBtn.Enabled:=true;
    AsBSendBtn.Enabled:=true;
    Ed_R_ID.Enabled:=true;
    EdAmount.Enabled:=true;
  end
  else begin
    EdLocalIP.Enabled:=not FActive;
    EdLocTsapHI.Enabled:=true;
    EdLocTsapLO.Enabled:=true;
    EdRemoteIP.Enabled:=true;
    EdRemTsapHI.Enabled:=true;
    EdRemTsapLO.Enabled:=true;
    StartBtn.Enabled:=true;
    StopBtn.Enabled:=false;
    if FActive then
      EdLocalIP.Text:='';

    ChkSend.Checked:=false;
    BSendBtn.Enabled:=false;
    AsBSendBtn.Enabled:=false;
    Ed_R_ID.Enabled:=false;
    EdAmount.Enabled:=false;
    TBSend.Enabled:=false;
  end;
end;

procedure TPartnerForm.StartBtnClick(Sender: TObject);
begin
  if not FRunning then
    PartnerStart;
end;

procedure TPartnerForm.StopBtnClick(Sender: TObject);
begin
  if FRunning then
    PartnerStop;
end;

procedure TPartnerForm.TBRecvTimer(Sender: TObject);
begin
//
//  if Partner.AsBRecvCompletion()

end;

procedure TPartnerForm.TBsendTimer(Sender: TObject);
begin
  if not (csDestroying in ComponentState) and Partner.Linked then
    BSend(false,true);
end;

procedure TPartnerForm.TLedTimer(Sender: TObject);
begin
  DataLed.Color:=clBtnFace;
end;

procedure TPartnerForm.TStatTimer(Sender: TObject);
Var
  Status    : integer;
  BytesSent : cardinal;
  BytesRecv : cardinal;
  ErrSend   : cardinal;
  ErrRecv   : cardinal;
begin
   Status:=Partner.Status;

  case Status of
    par_stopped    : SB.Panels[0].Text:='Stopped';
    par_connecting : SB.Panels[0].Text:='Connecting';
    par_waiting    : SB.Panels[0].Text:='Waiting';
    par_linked     : SB.Panels[0].Text:='Connected';
    par_sending    : SB.Panels[0].Text:='Sending';
    par_receiving  : SB.Panels[0].Text:='Receiving';
    par_binderror  : SB.Panels[0].Text:='Bind Error';
  end;

  BytesSent:=Partner.BytesSent;
  BytesRecv:=Partner.BytesRecv;
  ErrSend  :=Partner.SendErrors;
  ErrRecv  :=Partner.RecvErrors;

  EdSent.Text:=IntToStr(BytesSent);
  EdRecv.Text:=IntToStr(BytesRecv);
end;

procedure TPartnerForm.ValidateGrid;
Var
  r,c : integer;

  function ValidateHexCell(S : string) : string;
  Var
    V : integer;
  begin
    if S='' then
      S:='0';

    V:=StrToIntDef(S,0);
    if V<0 then V:=0;
    if V>255 then V:=255;

    Result:='$'+IntToHex(V,2);
  end;

begin
  With DataGrid do
  for r:=1 to RowCount - 1 do
    for c := 1 to ColCount - 1 do
       Cells[c,r]:=ValidateHexCell(Cells[c,r])
end;

procedure TPartnerForm.WaitBSendCompletion;
Var
  Result : integer;
begin
  Application.ProcessMessages;
  if AsSendMode=amPolling then
  begin
    repeat
      Application.ProcessMessages;
    until Partner.CheckAsBSendCompletion(Result);
  end
  else
    Result:=Partner.WaitAsBSendCompletion(3000);
  LastSendError:=Result;
end;

{ TRecvThread }

constructor TRecvThread.Create(PartnerForm: TPartnerForm);
begin
  inherited Create(true);
  FreeOnTerminate:=false;
  FPartnerForm:=PartnerForm;
end;

procedure TRecvThread.Execute;
begin
  while not Terminated do
  begin
    FPartnerForm.RxEvent.WaitFor(infinite);
    if not Terminated then
      Synchronize(FPartnerForm.DataIncoming);
  end;
end;


initialization

  CS:=TCriticalSection.Create;

finalization

  CS.Free;;

end.