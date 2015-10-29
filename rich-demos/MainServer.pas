unit MainServer;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls, StdCtrls, CheckLst, ExtCtrls,
  Snap7;

Const
  DBSize = 2048;

type

  { TFrmServer }

  TFrmServer = class(TForm)
    Log: TMemo;
    SB: TStatusBar;
    Panel1: TPanel;
    PC: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    StartBtn: TButton;
    EdIP: TEdit;
    Label1: TLabel;
    StopBtn: TButton;
    List: TCheckListBox;
    TabSheet4: TTabSheet;
    Label2: TLabel;
    lblMask: TLabel;
    MemoDB1: TMemo;
    MemoDB2: TMemo;
    MemoDB3: TMemo;
    EvtTimer: TTimer;
    Splitter1: TSplitter;
    LogTimer: TTimer;
    procedure ListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LogTimerTimer(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure EvtTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Server : TS7Server;
    FMask : longword;
    TIM : packed array[0..DBSize-1] of byte;
    DB1 : packed array[0..DBSize-1] of byte;
    DB2 : packed array[0..DBSize-1] of byte;
    DB3 : packed array[0..DBSize-1] of byte;
    FServerStatus: integer;
    FClientsCount: integer;
    procedure UpdateMask;
    procedure MaskToForm;
    procedure MaskToLabel;
    procedure SetFMask(const Value: longword);
    procedure DumpData(P : PS7Buffer; Memo : TMemo; Count : integer);
    procedure SetFServerStatus(const Value: integer);
    procedure SetFClientsCount(const Value: integer);
  public
    { Public declarations }
    DB1_changed : boolean;
    DB2_changed : boolean;
    DB3_changed : boolean;
    property LogMask : longword read FMask write SetFMask;
    property ServerStatus : integer read FServerStatus write SetFServerStatus;
    property ClientsCount : integer read FClientsCount write SetFClientsCount;
  end;

var
  FrmServer: TFrmServer;

implementation

{$R *.lfm}

procedure ServerCallback(usrPtr : pointer; PEvent : PSrvEvent; Size : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
begin
  // Checks if we are interested in this event.
  // We need to update DB Memo contents only if our DB changed.

  // To avoid this check, an alternative way could be to mask
  // the Server.EventsMask property.

  if (PEvent^.EvtCode=evcDataWrite) and  // write event
     (PEvent^.EvtRetCode=0) and          // succesfully
     (PEvent^.EvtParam1=S7AreaDB) then   // it's a DB
  begin
    case PEvent^.EvtParam2 of
      1 : TFrmServer(usrPtr).DB1_changed:=true;
      2 : TFrmServer(usrPtr).DB2_changed:=true;
      3 : TFrmServer(usrPtr).DB3_changed:=true;
    end;
  end;
end;

{ TFrmServer }

procedure TFrmServer.DumpData(P: PS7Buffer; Memo: TMemo; Count: integer);
Var
  SHex, SChr, SOfs : string;
  Ch : AnsiChar;
  c, cnt, ofs : integer;
begin
  Memo.Lines.Clear;
  Memo.Lines.BeginUpdate;
  SHex:='';SChr:='';cnt:=0;ofs:=0;
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
        SOfs:=IntToHex(ofs,4);
        Memo.Lines.Add(SOfs+' - '+SHex+'  '+SChr);
        SHex:='';SChr:='';
        cnt:=0;
        ofs:=ofs+16;
      end;
    end;
    // Dump remainder
    if cnt>0 then
    begin
      while Length(SHex)<48 do
        SHex:=SHex+' ';
      SOfs:=IntToHex(ofs,4);
      Memo.Lines.Add(SOfs+' - '+SHex+'  '+SChr);
    end;
  finally
    Memo.Lines.EndUpdate;
  end;
end;

procedure TFrmServer.EvtTimerTimer(Sender: TObject);
begin
  if DB1_changed then
  begin
    DumpData(@DB1,MemoDB1, SizeOf(DB1));
    DB1_changed :=false;
  end;
  if DB2_changed then
  begin
    DumpData(@DB2,MemoDB2, SizeOf(DB2));
    DB2_changed :=false;
  end;
  if DB3_changed then
  begin
    DumpData(@DB3,MemoDB3, SizeOf(DB3));
    DB3_changed :=false;
  end;
end;

procedure TFrmServer.FormCreate(Sender: TObject);
var
  ThePlatform : string;
  Wide : string;
begin
  // Cosmetics
  // Infamous trick to get the platform size
  // Maybe it could not work ever, but we need only a form caption....
  case SizeOf(NativeUint) of
     4 : Wide := ' [32 bit]';
     8 : Wide := ' [64 bit]';
    else Wide := ' [?? bit]';
  end;
  {$IFDEF MSWINDOWS}
     ThePlatform:='Windows platform';
  {$ELSE}
     Platform:='Unix platform';
  {$ENDIF}
  Caption:='Snap7 Server Demo - '+ThePlatform+Wide+
  {$IFDEF FPC}
    ' [Lazarus]';
  {$ELSE}
    ' [Delphi/RAD studio]';
  {$ENDIF}

  PC.ActivePageIndex:=0;
  DumpData(@DB1,MemoDB1,SizeOf(DB1));
  DumpData(@DB2,MemoDB2,SizeOf(DB2));
  DumpData(@DB3,MemoDB3,SizeOf(DB3));
  StopBtn.Enabled:=false;
  FServerStatus:=-1; // to force update on start
  FClientsCount:=-1;

  // Server creation
  Server:=TS7Server.Create;
  // Add some shared resources
  Server.RegisterArea(srvAreaDB,      // it's DB
                      1,              // Number 1 (DB1)
                      @DB1,           // Its address
                      SizeOf(DB1));   // Its size
  Server.RegisterArea(srvAreaDB,2,@DB2,SizeOf(DB2)); // same as above
  Server.RegisterArea(srvAreaDB,3,@DB3,SizeOf(DB3)); // same as above
  Server.RegisterArea(srvAreaTM,0,@TIM,SizeOf(TIM));
  // Setup the callback
  Server.SetEventsCallback(@ServerCallback, self);
  // Note
  //   Set the callback and set Events/Log mask are optional,
  //   we call them only if we need.
  //   Also Register area is optional, but a server without shared areas is
  //   not very useful :-) however it works and it's recognized by simatic manager.

  LogMask:=Server.LogMask; // Get the current mask, always $FFFFFFFF on startup
end;

procedure TFrmServer.LogTimerTimer(Sender: TObject);
Var
  Event : TSrvEvent;
begin
  // Update Log memo
  if Server.PickEvent(Event) then
  begin
    if Log.Lines.Count>1024 then  // In case you want to run this demo for several hours....
      Log.Lines.Clear;
    Log.Lines.Append(SrvEventText(Event));
  end;
  // Update other Infos
  ServerStatus:=Server.ServerStatus;
  ClientsCount:=Server.ClientsCount;
end;

procedure TFrmServer.FormDestroy(Sender: TObject);
begin
  Server.Free;
end;

procedure TFrmServer.UpdateMask;
Var
  c: Integer;
  BitMask : longword;
begin
  BitMask:=$00000001;
  for c := 0 to 31 do
  begin
    if List.Checked[c] then
      FMask:=FMask or BitMask
    else
      FMask:=FMask and not BitMask;
    BitMask:=BitMask shl 1;
  end;
  Server.LogMask:=FMask;
end;

procedure TFrmServer.ListClick(Sender: TObject);
begin
  UpdateMask;
  MaskToLabel;
end;

procedure TFrmServer.MaskToForm;
Var
  c: Integer;
  BitMask : longword;
begin
  BitMask:=$00000001;
  for c := 0 to 31 do
  begin
    List.Checked[c]:=(FMask and BitMask)<>0;
    BitMask:=BitMask shl 1;
  end;
end;

procedure TFrmServer.MaskToLabel;
begin
  lblMask.Caption:='$'+IntToHex(FMask,8);
end;

procedure TFrmServer.SetFClientsCount(const Value: integer);
begin
  if FClientsCount <> Value then
  begin
    FClientsCount := Value;
    SB.Panels[1].Text:='Clients : '+IntToStr(FClientsCount);
  end;
end;

procedure TFrmServer.SetFMask(const Value: longword);
begin
  if FMask <> Value then
  begin
    FMask := Value;
    MaskToForm;
    MaskToLabel;
  end;
end;

procedure TFrmServer.SetFServerStatus(const Value: integer);
begin
  if FServerStatus <> Value then
  begin
    FServerStatus := Value;
    case FServerStatus of
      SrvStopped : SB.Panels[0].Text:='Stopped';
      SrvRunning : SB.Panels[0].Text:='Running';
      SrvError   : SB.Panels[0].Text:='Error';
    end;
  end;
end;

procedure TFrmServer.StartBtnClick(Sender: TObject);
Var
  res : integer;
begin
  res :=Server.StartTo(EdIP.Text);
  if res=0 then
  begin
    StartBtn.Enabled:=false;
    EdIP.Enabled:=false;
    StopBtn.Enabled:=true;
  end
  else
    SB.Panels[2].Text:=SrvErrorText(res);
end;

procedure TFrmServer.StopBtnClick(Sender: TObject);
begin
  Server.Stop;
  StopBtn.Enabled:=false;
  StartBtn.Enabled:=true;
  EdIP.Enabled:=true;
end;

end.
