unit mainclient;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses
{$IFNDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  SyncObjs, SysUtils, DateUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs,  StdCtrls, ComCtrls, Grids,
  ExtCtrls, Buttons, sc_info, cp_info,
  snap7;

const
  amPolling  = 0;
  amEvent    = 1;
  amCallBack = 2;

type

  { TFormClient }

  TFormClient = class(TForm)
    CBConnType: TComboBox;
    EdIp: TEdit;
    BtnConnect: TButton;
    EdLocTsapHI: TEdit;
    EdRemTsapHI: TEdit;
    EdLocTsapLO: TEdit;
    EdRemTsapLO: TEdit;
    EdRack: TEdit;
    EdSlot: TEdit;
    Label1: TLabel;
    BtnDisconnect: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    Label7: TLabel;
    EdPDUSize: TStaticText;
    PageControl: TPageControl;
    PCC: TPageControl;
    StatusBar: TStatusBar;
    TabSheet1: TTabSheet;
    Label4: TLabel;
    LblDBNum: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DataGrid: TStringGrid;
    CbArea: TComboBox;
    EdDBNum: TEdit;
    EdStart: TEdit;
    EdAmount: TEdit;
    BtnRead: TButton;
    BtnWrite: TButton;
    BtnAsyncRead: TButton;
    BtnAsyncWrite: TButton;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    ComboArea_1: TComboBox;
    EdDBNum_1: TEdit;
    EdStart_1: TEdit;
    EdAmount_1: TEdit;
    EdData_1: TEdit;
    ComboArea_2: TComboBox;
    EdDBNum_2: TEdit;
    EdStart_2: TEdit;
    EdAmount_2: TEdit;
    EdData_2: TEdit;
    ComboArea_3: TComboBox;
    EdDBNum_3: TEdit;
    EdStart_3: TEdit;
    EdAmount_3: TEdit;
    EdData_3: TEdit;
    ComboArea_4: TComboBox;
    EdDBNum_4: TEdit;
    EdStart_4: TEdit;
    EdAmount_4: TEdit;
    EdData_4: TEdit;
    ComboArea_5: TComboBox;
    EdDBNum_5: TEdit;
    EdStart_5: TEdit;
    EdAmount_5: TEdit;
    EdData_5: TEdit;
    MultiReadBtn: TButton;
    TabSheet4: TTabSheet;
    TabSheet8: TTabSheet;
    TabZSL: TTabSheet;
    TabClock: TTabSheet;
    TabSheet7: TTabSheet;
    TabSecurity: TTabSheet;
    TabControl: TTabSheet;
    RGMode: TRadioGroup;
    CbWLen: TComboBox;
    Label19: TLabel;
    LblArea: TLabel;
    MultiWriteBtn: TButton;
    Label20: TLabel;
    EdResult_1: TEdit;
    Label21: TLabel;
    EdResult_2: TEdit;
    Label22: TLabel;
    EdResult_3: TEdit;
    Label23: TLabel;
    EdResult_4: TEdit;
    Label24: TLabel;
    EdResult_5: TEdit;
    Label25: TLabel;
    GroupBox1: TGroupBox;
    Label26: TLabel;
    txtOB: TStaticText;
    Label28: TLabel;
    txtFB: TStaticText;
    Label29: TLabel;
    txtFC: TStaticText;
    Label30: TLabel;
    txtSFB: TStaticText;
    Label31: TLabel;
    txtSFC: TStaticText;
    Label32: TLabel;
    txtDB: TStaticText;
    Label27: TLabel;
    Label33: TLabel;
    txtSDB: TStaticText;
    BtnBlockList: TButton;
    GroupBox2: TGroupBox;
    cbBlock: TComboBox;
    EdBlkNum: TEdit;
    MemoBlk: TMemo;
    BlkInfoBtn: TButton;
    GroupBox3: TGroupBox;
    CbBot: TComboBox;
    BoTBtn: TButton;
    ReadSZLBtn: TButton;
    MemoSZL: TMemo;
    EdID: TEdit;
    Label34: TLabel;
    Label35: TLabel;
    EdIndex: TEdit;
    AsReadSZLBtn: TButton;
    lblSZLdump: TLabel;
    TimClock: TTimer;
    GrPGDateTime: TGroupBox;
    ChkGetDateTime: TCheckBox;
    grAGDateTime: TGroupBox;
    Button7: TButton;
    Label37: TLabel;
    EdDBNumGet: TEdit;
    LblDBDump: TLabel;
    MemoDB: TMemo;
    DBGetBtn: TButton;
    AsDBGetBtn: TButton;
    TabSheet6: TTabSheet;
    GroupBox5: TGroupBox;
    Label44: TLabel;
    EdPdu: TEdit;
    Label45: TLabel;
    EdConnections: TEdit;
    Label46: TLabel;
    EdMpiRate: TEdit;
    Label47: TLabel;
    EdBusRate: TEdit;
    GroupBox6: TGroupBox;
    Label41: TLabel;
    EdModuleTypeName: TEdit;
    Label42: TLabel;
    EdSerialNumber: TEdit;
    Label43: TLabel;
    EdCopyright: TEdit;
    GroupBox7: TGroupBox;
    Label40: TLabel;
    edOrderCode: TEdit;
    ListBot: TListBox;
    LblDblClick: TLabel;
    lbSZL: TListBox;
    lblSZLCount: TLabel;
    lblSZL: TLabel;
    Label49: TLabel;
    TimStatus: TTimer;
    Button12: TButton;
    Button13: TButton;
    TabSheet5: TTabSheet;
    cbBlkType: TComboBox;
    EdNum: TEdit;
    Label48: TLabel;
    Label50: TLabel;
    lblUpld: TLabel;
    MemoUpload: TMemo;
    UpBtn: TButton;
    AsUpBtn: TButton;
    ChkFull: TCheckBox;
    MemoBlkInfo: TMemo;
    lblNewNumber: TLabel;
    EdNewNumber: TEdit;
    DnBtn: TButton;
    AsDnBtn: TButton;
    BlkSaveBtn: TButton;
    SaveDialog: TSaveDialog;
    Button4: TButton;
    OpenDialog: TOpenDialog;
    Button14: TButton;
    GroupBox4: TGroupBox;
    lblStatus: TLabel;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    ChkStatusRefresh: TCheckBox;
    BtnStatus: TButton;
    EdVersion: TEdit;
    Label36: TLabel;
    Shape1: TShape;
    Label51: TLabel;
    EdASName: TEdit;
    Label52: TLabel;
    EdModuleName: TEdit;
    Button1: TButton;
    ChkSecurity: TCheckBox;
    GroupBox8: TGroupBox;
    EdPassword: TEdit;
    Button5: TButton;
    Button8: TButton;
    TimSecurity: TTimer;
    Panel1: TPanel;
    RG_sch_schal: TRadioGroup;
    RG_sch_par: TRadioGroup;
    RG_sch_rel: TRadioGroup;
    RG_bart_sch: TRadioGroup;
    RG_anl_sch: TRadioGroup;
    AsBotBtn: TButton;
    GroupBox9: TGroupBox;
    Label8: TLabel;
    EdTimeout: TEdit;
    Button3: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    ChEd_1: TEdit;
    Label53: TLabel;
    ChEd_2: TEdit;
    ChEd_3: TEdit;
    ChEd_4: TEdit;
    ChEd_5: TEdit;
    Label54: TLabel;
    Label55: TLabel;
    GroupBox10: TGroupBox;
    Label56: TLabel;
    Label57: TLabel;
    EdDBFill: TEdit;
    EdFill: TEdit;
    FillBtn: TButton;
    AsFillBtn: TButton;
    Label38: TLabel;
    Label39: TLabel;
    edPGDate: TEdit;
    edPGTime: TEdit;
    edAGDate: TEdit;
    edAGTime: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnConnectClick(Sender: TObject);
    procedure BtnDisconnectClick(Sender: TObject);
    procedure CbAreaChange(Sender: TObject);
    procedure DataGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure EdRackKeyPress(Sender: TObject; var Key: Char);
    procedure DataGridExit(Sender: TObject);
    procedure DataGridKeyPress(Sender: TObject; var Key: Char);
    procedure BtnReadClick(Sender: TObject);
    procedure BtnWriteClick(Sender: TObject);
    procedure BtnAsyncReadClick(Sender: TObject);
    procedure Label63Click(Sender: TObject);
    procedure Label64Click(Sender: TObject);
    procedure MultiReadBtnClick(Sender: TObject);
    procedure RGModeClick(Sender: TObject);
    procedure BtnAsyncWriteClick(Sender: TObject);
    procedure MultiWriteBtnClick(Sender: TObject);
    procedure BtnBlockListClick(Sender: TObject);
    procedure BlkInfoBtnClick(Sender: TObject);
    procedure ReadSZLBtnClick(Sender: TObject);
    procedure EdIDKeyPress(Sender: TObject; var Key: Char);
    procedure AsReadSZLBtnClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure TimClockTimer(Sender: TObject);
    procedure ChkGetDateTimeClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure DBGetBtnClick(Sender: TObject);
    procedure AsDBGetBtnClick(Sender: TObject);
    procedure BoTBtnClick(Sender: TObject);
    procedure ListBotDblClick(Sender: TObject);
    procedure CbBotCloseUp(Sender: TObject);
    procedure lbSZLDblClick(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure txtOBDblClick(Sender: TObject);
    procedure TimStatusTimer(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure UpBtnClick(Sender: TObject);
    procedure AsUpBtnClick(Sender: TObject);
    procedure ChkFullClick(Sender: TObject);
    procedure DnBtnClick(Sender: TObject);
    procedure AsDnBtnClick(Sender: TObject);
    procedure BlkSaveBtnClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure BtnStatusClick(Sender: TObject);
    procedure ChkStatusRefreshClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TimSecurityTimer(Sender: TObject);
    procedure ChkSecurityClick(Sender: TObject);
    procedure AsBotBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure FillBtnClick(Sender: TObject);
    procedure AsFillBtnClick(Sender: TObject);
    procedure MultiVarReadBtnClick(Sender: TObject);
    procedure MultiVarWriteBtnClick(Sender: TObject);
  private
    { Private declarations }
    Client : TS7Client;
    FConnected: boolean;
    FLastError: integer;
    FLastOP: string;
    Buffer : TS7Buffer;
    BlkBuffer  : TS7Buffer;
    BlkBufSize : integer;
    DataItems : TS7DataItems;
    BlocksList : TS7BlocksList;
    BlockInfo : TS7BlockInfo;
    AsMode : integer;
    AsOpResult : integer;
    function WordSize(Amount, WordLength : integer) : integer;
    procedure CheckArea;
    procedure SetFConnected(const Value: boolean);
    procedure SetFLastError(const Value: integer);
    procedure ValidateGrid;
    procedure ClientConnect;
    procedure ClientDisconnect;
    procedure FillBlockInfo(Memo : TMemo; Info : PS7BlockInfo);
    procedure DataToGrid(Amount : integer);
    procedure GridToData(Amount : integer);
    procedure DumpData(P : PS7Buffer; Memo : TMemo; Count : integer);
    procedure Read(Async : boolean);
    procedure Write(Async : boolean);
    procedure DBFill(ASync : boolean);
    procedure MultiRead;
    procedure MultiWrite;
    procedure DBGet(Async : boolean);
    procedure ListBlocks;
    procedure GetBlockInfo;
    procedure ListBlocksOfType(Async : boolean);
    procedure Upload(Full, Async : boolean);
    procedure GetSysInfo;
    procedure ReadSZL(Async : boolean);
    procedure ReadSZLList(Async : boolean);
    procedure SetFLastOP(const Value: string);
    procedure Elapse; overload;
    procedure Elapse(TotTime : cardinal); overload;
    procedure WaitCompletion(Const Timeout : integer = 1500);
    procedure ClearPages;
    procedure ClearSystemInfo;
    procedure ClearMultiReadWrite;
    procedure ClearDirectory;
    procedure ClearSZL;
    procedure ClearDBGet;
    procedure ClearUpDownload;
    procedure ClearProtection;
    procedure GetStatus;
    procedure GetProtection(const DoShowInfo : boolean = true);
    procedure SetPassword;
    procedure ClearPassword;
    procedure CopyRamToRom(Async : boolean);
    procedure Compress(Async : boolean);
    procedure FillBlkBuffer(p : pointer; Size : integer);
    procedure ClearBlkBuffer;
    procedure SaveToFile(Const FileName : string; P : pointer; Size : integer);
    procedure DeleteBlock;
    function LoadFromFile(Const FileName : string; P : pointer; var Size : integer) : boolean;
    function CliError(Error : integer) : string;
    function CliTime : cardinal;
    function CliPDULength : integer;
  public
    EvJob : TEvent;
    JobDone : boolean;
    { Public declarations }
    property Connected : boolean read FConnected write SetFConnected;
    property LastOP : string read FLastOP write SetFLastOP;
    property LastError : integer read FLastError write SetFLastError;
  end;

var
  FormClient: TFormClient;

implementation

{$R *.lfm}

// This procedure is called by client when AsyncMode = amCallBack
procedure ClientCompletion(usrPtr : pointer; opCode, opResult : integer);
{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
begin
  // in this demo we have nothing to do : set an event
  TFormClient(usrPtr).AsOpResult:=opResult;
end;

const
  AreaOf : array[0..5] of byte = (
    S7AreaDB, S7AreaPE, S7AreaPA, S7AreaMK, S7AreaTM, S7AreaCT
  );

  WLenOf : array[0..14] of integer = (
    S7WLBit,
    S7WLByte,
    S7WLChar,
    S7WLWord,
    S7WLInt,
    S7WLDWord,
    S7WLDInt,
    S7WLReal,
    S7WLDate,
    S7WLTOD,
    S7WLTime,
    S7WLS5Time,
    S7WLDT,
    S7WLCounter,
    S7WLTimer
  );

  SizeByte : array[0..14] of integer = (
    1, 1, 1, 2, 2, 4, 4, 4, 2, 4, 4, 2, 8, 2, 2
  );

  BlockOf : array[0..6] of integer = (
    Block_OB, Block_FB, Block_FC, Block_DB, Block_SFB, Block_SFC, Block_SDB
  );

function LangOf(Lang : integer) : string;
begin
  case Lang of
    BlockLangAWL   : Result:='AWL';
    BlockLangKOP   : Result:='KOP';
    BlockLangFUP   : Result:='FUP';
    BlockLangSCL   : Result:='SCL';
    BlockLangDB    : Result:='DB';
    BlockLangGRAPH : Result:='GRAPH';
  else
    Result:='Unknown';
  end;
end;

function SubBlkOf(SubBlk : integer) : string;
begin
  case SubBlk of
    SubBlk_OB  : Result:='OB';
    SubBlk_DB  : Result:='DB';
    SubBlk_SDB : Result:='SDB';
    SubBlk_FC  : Result:='FC';
    SubBlk_SFC : Result:='SFC';
    SubBlk_FB  : Result:='FB';
    SubBlk_SFB : Result:='SFB';
  else
    Result:='Unknown';
  end;
end;

procedure TFormClient.BtnConnectClick(Sender: TObject);
begin
  ClientConnect;
end;

procedure TFormClient.BtnDisconnectClick(Sender: TObject);
begin
  ClientDisconnect;
end;

procedure TFormClient.BtnReadClick(Sender: TObject);
begin
  Read(false);
end;

procedure TFormClient.BtnWriteClick(Sender: TObject);
begin
  Write(false);
end;

procedure TFormClient.AsReadSZLBtnClick(Sender: TObject);
begin
  ReadSZL(true);
end;

procedure TFormClient.Button10Click(Sender: TObject);
begin
  Client.PlcHotStart;
end;

procedure TFormClient.Button11Click(Sender: TObject);
begin
  Client.PlcColdStart;
end;

procedure TFormClient.Button12Click(Sender: TObject);
begin
  ReadSZLList(false);
end;

procedure TFormClient.Button13Click(Sender: TObject);
begin
  GetSysInfo;
end;

procedure TFormClient.Button14Click(Sender: TObject);
begin
  DeleteBlock;
end;

procedure TFormClient.Button15Click(Sender: TObject);
begin
  CopyRamToRom(true);
end;

procedure TFormClient.Button16Click(Sender: TObject);
begin
  Compress(false);
end;

procedure TFormClient.Button17Click(Sender: TObject);
begin
  Compress(true);
end;

procedure TFormClient.Button1Click(Sender: TObject);
begin
  GetProtection;
end;

procedure TFormClient.BtnStatusClick(Sender: TObject);
begin
  GetStatus;
end;

procedure TFormClient.ClearPages;
begin
  ClearSystemInfo;
  ClearMultiReadWrite;
  ClearDirectory;
  ClearSZL;
  ClearDBGet;
  ClearUpDownload;
  ClearProtection;
end;

procedure TFormClient.ClearPassword;
begin
  LastOp:='Clear Session password';
  LastError:=Client.ClearSessionPassword;
  Elapse;
end;

procedure TFormClient.ClearProtection;
begin
  RG_sch_schal.ItemIndex:=0;
  RG_sch_par.ItemIndex:=0;
  RG_sch_rel.ItemIndex:=0;
  RG_bart_sch.ItemIndex:=0;
  RG_anl_sch.ItemIndex:=0;
end;

procedure TFormClient.UpBtnClick(Sender: TObject);
begin
  Upload(ChkFull.Checked,false);
end;

procedure TFormClient.AsUpBtnClick(Sender: TObject);
begin
  Upload(ChkFull.Checked,true);
end;

procedure TFormClient.BtnBlockListClick(Sender: TObject);
begin
  ListBlocks;
end;

procedure TFormClient.Button3Click(Sender: TObject);
begin
  CopyRamToRom(false)
end;

procedure TFormClient.Button4Click(Sender: TObject);
Var
  Size : integer;
begin
  if OpenDialog.Execute then
  begin
    if LoadFromFile(OpenDialog.FileName,@BlkBuffer,Size) then
    begin
      FillBlkBuffer(@BlkBuffer,Size);
      Client.GetPgBlockInfo(@BlkBuffer,@BlockInfo,Size);
      FillBlockInfo(MemoBlkInfo,@BlockInfo);
      DumpData(@BlkBuffer,MemoUpload,Size);
      lblUpld.Caption:='Block Dump : '+IntToStr(Size)+' byte'
    end;
  end;
end;


procedure TFormClient.Button5Click(Sender: TObject);
begin
  SetPassword;
end;

procedure TFormClient.BlkSaveBtnClick(Sender: TObject);
begin
  if SaveDialog.Execute then
    SaveToFile(SaveDialog.FileName,@BlkBuffer,BlkBufSize);
end;

procedure TFormClient.Button7Click(Sender: TObject);
Var
  DT : TDateTime;
  AGDate : TDateTime;
  AGTime : TDateTime;
begin
  TimClock.Enabled:=false;
  LastOp:='Set PLC Date and Time';
  if not ChkGetDateTime.Checked then
  begin
    if TryStrToDate(edAGDate.Text,AGDate) and TryStrToTime(edAGTime.Text,AGTime) then
    begin
      DT:=AGDate+AGTime;
      LastError:=Client.SetPlcDateTime(DT);
    end
    else
      MessageDlg('Date and/or Time format error',mtError,[mbOk],0);
  end
  else
    LastError:=Client.SetPlcSystemDateTime;
  Elapse;
  ChkGetDateTime.Checked:=true;
  TimClock.Enabled:=true;
end;

procedure TFormClient.Button8Click(Sender: TObject);
begin
  ClearPassword;
end;

procedure TFormClient.ReadSZLBtnClick(Sender: TObject);
begin
  ReadSZL(false);
end;

procedure TFormClient.ReadSZLList(Async: boolean);
Var
  SZLList : TS7SZLList;
  Count : integer;
  c: Integer;
begin
  LastOp:='Read SZL List';
  lblSZL.Visible:=false;
  lbSZL.Items.Clear;
  Count:=SizeOf(SZLList);
  LastError:=Client.ReadSZLList(@SZLList,Count);
  if LastError=0 then
  begin
    for c := 0 to Count - 1 do
      lbSZL.Items.Add('$'+IntToHex(SZLList.List[c],4));
    lblSZL.Visible:=lbSZL.Items.Count>0;
  end;
  lblSZLCount.Caption:='List of All SZL IDs : '+inttostr(Count);
  Elapse;
end;

procedure TFormClient.Button9Click(Sender: TObject);
begin
  Client.PlcStop;
end;

procedure TFormClient.AsBotBtnClick(Sender: TObject);
begin
  ListBlocksOfType(true);
end;

procedure TFormClient.AsDBGetBtnClick(Sender: TObject);
begin
  DBGet(true);
end;

procedure TFormClient.AsDnBtnClick(Sender: TObject);
Var
  BlockNum : integer;
begin
  LastOp:='Async Download';
  BlockNum:=StrToIntDef(EdNewNumber.Text,0);EdNewNumber.Text:=IntToStr(BlockNum);
  LastError:=Client.AsDownload(BlockNum,@BlkBuffer,BlkBufSize);
  if LastError=0 then
    WaitCompletion;
  Elapse;
end;

procedure TFormClient.AsFillBtnClick(Sender: TObject);
begin
  DBFill(true);
end;

procedure TFormClient.GetBlockInfo;
Var
  BlockType : integer;
  BlockNum  : integer;

begin
  BlockType:=BlockOf[cbBlock.ItemIndex];
  BlockNum:=StrToIntDef(EdBlkNum.Text,0);
  fillchar(BlockInfo,SizeOf(TS7BlockInfo),#0);
  MemoBlk.Lines.Clear;
  LastOP:='Block Info';
  LastError:=Client.GetAgBlockInfo(BlockType,BlockNum,@BlockInfo);

  if LastError=0 then
  begin
    if LastError=0 then
      FillBlockInfo(MemoBlk,@BlockInfo);
  end;
  Elapse;
end;

procedure TFormClient.GetProtection(const DoShowInfo : boolean = true);
Var
  Info : TS7Protection;

  procedure SetRGValue(RG : TRadioGroup; Value : word);
  begin
    if Value>RG.Items.Count-1 then
      RG.ItemIndex:=0
    else
      RG.ItemIndex:=Value;
  end;

begin
  if DoShowInfo then
    LastOp:='Get Protection Info';

  LastError:=Client.GetProtection(@Info);
  if LastError=0 then
  begin
    SetRGValue(RG_sch_schal,Info.sch_schal);
    SetRGValue(RG_sch_par,Info.sch_par);
    SetRGValue(RG_sch_rel,Info.sch_rel);
    SetRGValue(RG_bart_sch,Info.bart_sch);
    SetRGValue(RG_anl_sch,Info.anl_sch);
  end;
  if DoShowInfo then
    Elapse;
end;

procedure TFormClient.GetStatus;
Var
  Status : integer;

  procedure Run;
  begin
    lblStatus.Font.Color:=clGreen;
    lblStatus.Caption:='RUN';
  end;

  procedure Stop;
  begin
    lblStatus.Font.Color:=clRed;
    lblStatus.Caption:='STOP';
  end;

  procedure Unknown;
  begin
    lblStatus.Font.Color:=clGray;
    lblStatus.Caption:='Unknown';
  end;

begin
  LastOp:='Get Plc Status';
  LastError:=Client.GetPlcStatus(Status);
  if LastError=0 then
  begin
    case Status of
      S7CpuStatusUnknown : Unknown;
      S7CpuStatusRun     : Run;
      S7CpuStatusStop    : Stop;
    end;
  end
  else
    Unknown;
  Elapse;
end;

procedure TFormClient.GetSysInfo;
Var
  OrderCode : TS7OrderCode;
  CpuInfo : TS7CpuInfo;
  CpInfo  : TS7CpInfo;
  TotTime : Cardinal;
begin
  LastOp:='Get System Info';
  ClearSystemInfo;
  TotTime:=0;

  LastError:=Client.GetOrderCode(@OrderCode);
  if LastError=0 then
  begin
    EdOrderCode.Text:=String(OrderCode.Code);
    EdVersion.Text:='V '+IntToStr(OrderCode.V1)+'.'+
                       IntToStr(OrderCode.V2)+'.'+
                       IntToStr(OrderCode.V3);
  end
  else begin
    EdOrderCode.Text:='NO INFO AVAILABLE';
    EdVersion.Text:='';
  end;

  Inc(TotTime,CliTime);

  LastError:=Client.GetCpuInfo(@CpuInfo);
  if LastError=0 then
  begin
    EdModuleTypeName.Text :=String(CpuInfo.ModuleTypeName);
    EdSerialNumber.Text   :=String(CpuInfo.SerialNumber);
    EdCopyright.Text      :=String(CpuInfo.Copyright);
    EdASName.Text         :=String(CpuInfo.ASName);
    EdModuleName.Text     :=String(CpuInfo.ModuleName);
  end;

  Inc(TotTime,CliTime);

  LastError:=Client.GetCPInfo(@CpInfo);
  if LastError=0 then
  begin
    EdPdu.Text:=IntToStr(CpInfo.MaxPduLengt);
    EdConnections.Text:=IntToStr(CpInfo.MaxConnections);
    EdMpiRate.Text:=IntToStr(CpInfo.MaxMpiRate);
    EdBusRate.Text:=IntToStr(CpInfo.MaxBusRate);
  end;

  Inc(TotTime,CliTime);
  Elapse(TotTime);
end;

procedure TFormClient.BlkInfoBtnClick(Sender: TObject);
begin
  GetBlockInfo;
end;

procedure TFormClient.BoTBtnClick(Sender: TObject);
begin
  ListBlocksOfType(false);
end;

procedure TFormClient.BtnAsyncReadClick(Sender: TObject);
begin
  Read(true);
end;

procedure TFormClient.Label63Click(Sender: TObject);
begin
  SmartConnectInfo.ShowModal;
end;

procedure TFormClient.Label64Click(Sender: TObject);
begin
  ParamsConnectInfo.ShowModal;
end;

procedure TFormClient.BtnAsyncWriteClick(Sender: TObject);
begin
  Write(true);
end;

procedure TFormClient.ClearBlkBuffer;
begin
  fillchar(BlkBuffer,SizeOf(BlkBuffer),#0);
  BlkBufSize:=0;
  DnBtn.Enabled:=false;
  AsDnBtn.Enabled:=false;
  BlkSaveBtn.Enabled:=false;
  EdNewNumber.Enabled:=false;
end;

procedure TFormClient.ClearDBGet;
begin
  EdDBNumGet.Text:='1';
  LblDBDump.Caption:='DB Dump : 0 bytes';
  MemoDB.Lines.Clear;
end;

procedure TFormClient.ClearDirectory;
begin
  txtOB.Caption:='0';
  txtFB.Caption:='0';
  txtFC.Caption:='0';
  txtDB.Caption:='0';
  txtSFB.Caption:='0';
  txtSFC.Caption:='0';
  txtSDB.Caption:='0';
  cbBot.ItemIndex:=0;
  cbBlock.ItemIndex:=0;
  EdBlkNum.Text:='1';
  ListBot.Items.Clear;
  MemoBlk.Lines.Clear;
end;

procedure TFormClient.ClearMultiReadWrite;
begin
  fillchar(DataItems,SizeOf(TS7DataItems),#0);
  EdData_1.Text:='';EDResult_1.Text:='';
  EdData_2.Text:='';EDResult_2.Text:='';
  EdData_3.Text:='';EDResult_3.Text:='';
  EdData_4.Text:='';EDResult_4.Text:='';
  EdData_5.Text:='';EDResult_5.Text:='';
end;

procedure TFormClient.ClearSystemInfo;
begin
  EdOrderCode.Text       :='INFO NOT AVAILABLE';
  EdVersion.Text         :='';
  EdModuleTypeName.Text  :='INFO NOT AVAILABLE';
  EdSerialNumber.Text    :='INFO NOT AVAILABLE';
  EdCopyright.Text       :='INFO NOT AVAILABLE';
  EdModuleName.Text      :='INFO NOT AVAILABLE';
  EdASName.Text          :='INFO NOT AVAILABLE';
  EdPdu.Text             :='INFO NOT AVAILABLE';
  EdConnections.Text     :='INFO NOT AVAILABLE';
  EdMpiRate.Text         :='INFO NOT AVAILABLE';
  EdBusRate.Text         :='INFO NOT AVAILABLE';
end;

procedure TFormClient.ClearSZL;
begin
  lbSZL.Items.Clear;
  MemoSZL.Lines.Clear;
  EdID.Text:='$0011';
  EdIndex.Text:='$0000';
end;

procedure TFormClient.ClearUpDownload;
begin
  cbBlkType.ItemIndex:=0;
  EdNum.Text:='1';
  lblUpld.Caption:='Block Dump : 0 byte';
  MemoUpload.Lines.Clear;
  MemoBlkInfo.Lines.Clear;
  EdNewNumber.Text:='1';
end;

procedure TFormClient.ClientConnect;
Var
  Rack, Slot : integer;
  ConnType   : word;
  RemoteAddress : AnsiString;
  LocalTsapHI  : integer;
  LocalTsapLO  : integer;
  RemoteTsapHI : integer;
  RemoteTsapLO : integer;
  LocalTsap    : word;
  RemoteTsap   : word;

  function GetChar(ED : TEdit) : integer;
  Var
    B : byte;
  begin
    B:=StrToIntDef('$'+Ed.Text,0);
    Ed.Text:=IntToHex(B,2);
    Result:=B;
  end;

begin
  LastOP:='Connection';
  RemoteAddress:=AnsiString(EdIp.Text);
  if PCC.PageIndex=0 then
  begin
    ConnType:=CBConnType.ItemIndex+1;
    Rack:=StrToIntDef(EdRack.Text,0);
    Slot:=StrToIntDef(EdSlot.Text,0);
    Client.SetConnectionType(ConnType);
    LastError:=Client.ConnectTo(RemoteAddress,Rack,Slot);
  end
  else begin
    LocalTsapHI  :=GetChar(EdLocTsapHI);
    LocalTsapLO  :=GetChar(EdLocTsapLO);
    RemoteTsapHI :=GetChar(EdRemTsapHI);
    RemoteTsapLO :=GetChar(EdRemTsapLO);
    LocalTsap    :=LocalTsapHI shl 8 + LocalTsapLO;
    RemoteTsap   :=RemoteTsapHI shl 8 + RemoteTsapLO;
    Client.SetConnectionParams(RemoteAddress, LocalTSAP, RemoteTSAP);
    LastError    :=Client.Connect;
  end;

  Elapse;
  Connected:=LastError=0;
  if Connected then
    EdPduSize.Caption:=' '+IntToStr(CliPDULength);
end;

procedure TFormClient.ClientDisconnect;
begin
  LastOP:='Disconnection';
  Client.Disconnect;
  Elapse;
  LastError:=0;
  Connected:=false;
  EdPduSize.Caption:=' 0';
end;

function TFormClient.CliPDULength: integer;
begin
  Result:=Client.PDULength;
end;

function TFormClient.CliTime: cardinal;
begin
  Result:=Client.Time;
end;

procedure TFormClient.Compress(Async: boolean);
Var
  Timeout : integer;
begin
  if ChkStatusRefresh.Checked then
  begin
    ShowMessage('First switch off the Status cyclic refresh');
    exit;
  end;

  Timeout:=StrToIntDef(EdTimeout.Text,0);EdTimeout.Text:=IntToStr(Timeout);
  if Timeout<1 then
  begin
    MessageDlg('Invalid Timeout value', mtError,[mbOk],0);
    exit;
  end;

  if ASync then
    LastOp:='Async Compress'
  else
    LastOp:='Compress';

  if ASync then
    LastError:=Client.AsCompress(Timeout)
  else
    LastError:=Client.Compress(Timeout);

  if ASync then
    WaitCompletion(Timeout);

  Elapse;
end;

procedure TFormClient.CopyRamToRom(Async: boolean);
Var
  Timeout : integer;
begin
  if ChkStatusRefresh.Checked then
  begin
    ShowMessage('First switch off the Status cyclic refresh');
    exit;
  end;

  ShowMessage('Remember that this function works only if the CPU is in STOP');

  Timeout:=StrToIntDef(EdTimeout.Text,0);EdTimeout.Text:=IntToStr(Timeout);
  if Timeout<1 then
  begin
    MessageDlg('Invalid Timeout value', mtError,[mbOk],0);
    exit;
  end;

  if ASync then
    LastOp:='Async Copy Ram to Rom'
  else
    LastOp:='Copy Ram to Rom';

  if ASync then
    LastError:=Client.AsCopyRamToRom(Timeout)
  else
    LastError:=Client.CopyRamToRom(Timeout);

  if ASync then
    WaitCompletion(Timeout);

  Elapse;
end;

procedure TFormClient.CbAreaChange(Sender: TObject);
Var
  Cb : TComboBox;
begin
  Cb:=TComboBox(Sender);

  if Cb=CbArea then
  begin
    LblDBNum.Visible:=Cb.ItemIndex=0;
    EdDBNum.Visible :=Cb.ItemIndex=0;
    CheckArea;
  end;

  if Cb=CbWLen then
    CheckArea;

  if Cb=ComboArea_1 then
    EdDBNum_1.Visible:=Cb.ItemIndex=0;
  if Cb=ComboArea_2 then
    EdDBNum_2.Visible:=Cb.ItemIndex=0;
  if Cb=ComboArea_3 then
    EdDBNum_3.Visible:=Cb.ItemIndex=0;
  if Cb=ComboArea_4 then
    EdDBNum_4.Visible:=Cb.ItemIndex=0;
  if Cb=ComboArea_5 then
    EdDBNum_5.Visible:=Cb.ItemIndex=0;
end;

procedure TFormClient.CbBotCloseUp(Sender: TObject);
begin
  ListBot.Items.Clear;
  LblDblClick.Visible:=false;
end;

procedure TFormClient.CheckArea;
begin
  LblArea.Visible:=((CbArea.ItemIndex=4) and (cbWLen.ItemIndex<>14)) or
                   ((CbArea.ItemIndex=5) and (cbWLen.ItemIndex<>13)) or
                   ((CbArea.ItemIndex<>4) and (cbWLen.ItemIndex=14)) or
                   ((CbArea.ItemIndex<>5) and (cbWLen.ItemIndex=13));
end;

procedure TFormClient.ChkFullClick(Sender: TObject);
begin
  DnBtn.Visible       :=ChkFull.Checked;
  AsDnBtn.Visible     :=ChkFull.Checked;
  EdNewNumber.Visible :=ChkFull.Checked;
  lblNewNumber.Visible:=ChkFull.Checked;
end;

procedure TFormClient.ChkGetDateTimeClick(Sender: TObject);
begin
  if ChkGetDateTime.Checked then
  begin
    edAGDate.Color:=clWindow;
    edAGTime.Color:=clWindow;
    grAGDateTime.Enabled:=false;
  end
  else begin
    edAGDate.Color:=clYellow;
    edAGTime.Color:=clYellow;
    grAGDateTime.Enabled:=true;
  end;
end;

procedure TFormClient.ChkSecurityClick(Sender: TObject);
begin
  TimSecurity.Enabled:=ChkSecurity.Checked;
end;

procedure TFormClient.ChkStatusRefreshClick(Sender: TObject);
begin
  BtnStatus.Enabled:=not ChkStatusRefresh.Checked;
end;

procedure TFormClient.DataGridDrawCell(Sender: TObject; ACol, ARow: Integer;
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

procedure TFormClient.DataGridExit(Sender: TObject);
begin
  ValidateGrid;
end;

procedure TFormClient.DataGridKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    ValidateGrid;
end;

procedure TFormClient.DataToGrid(Amount: integer);
Var
 x, c, r : integer;
begin
  with DataGrid do
  begin
    c:=1;r:=1;
    for x := 0 to Amount - 1 do
    begin
      Cells[c,r]:='$'+IntToHex(Buffer[x],2);
      inc(c);
      if c=ColCount then
      begin
        c:=1;
        inc(r);
      end;
    end;
    Row:=1;
    Col:=1;
    SetFocus;
  end;
end;

procedure TFormClient.DBFill(ASync: boolean);
Var
  B : byte;
  DBNum : integer;
begin
  if ASync then
    LastOp:='Async DB Fill'
  else
    LastOp:='DB Fill';

  B:=StrToIntDef(EdFill.Text,0);
  EdFill.Text:='$'+IntToHex(B,2);
  DBNum:=StrToIntDef(EdDBFill.Text,0);
  EdDBFill.Text:=IntToStr(DBNum);

  if ASync then
    LastError:=Client.AsDBFill(DBNum,B)
  else
    LastError:=Client.DBFill(DBNum,B);

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
  end;
  Elapse;
end;

procedure TFormClient.DBGet(Async: boolean);
Var
  DBNum : integer;
  Size : integer;
begin
  if ASync then
    LastOP:='Async DB Get'
  else
    LastOP:='DB Get';
  MemoDB.Lines.Clear;
  LblDBDump.Caption:='DB Dump : 0 bytes';
  DBNum:=StrToIntDef(EdDBNumGet.Text,0);EdDBNumGet.Text:=IntToStr(DBNum);
  Size:=SizeOf(Buffer);
  if Async then
    LastError:=Client.AsDBGet(DBNum,@Buffer,Size)
  else
    LastError:=Client.DBGet(DBNum,@Buffer,Size);

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
    if LastError=0 then
    begin
      LblDBDump.Caption:='DB Dump : '+IntToStr(Size)+' bytes';
      DumpData(@Buffer,MemoDB,Size);
    end;
    Elapse;
  end
  else
    Elapse;

end;

procedure TFormClient.DBGetBtnClick(Sender: TObject);
begin
  DBGet(false);
end;

procedure TFormClient.DeleteBlock;
Var
  BlockType, BlockNumber : integer;
begin
  if MessageDlg('Are you sure ?',mtWarning,[mbYes,mbNo],0)<>mrYes then
    exit;

  ClearBlkBuffer;
  LastOp :='Delete Block';

  MemoUpload.Lines.Clear;
  MemoBlkInfo.Lines.Clear;

  BlockType:=BlockOf[cbBlkType.ItemIndex];
  BlockNumber:=StrToIntDef(EdNum.Text,0);EdNum.Text:=IntToStr(BlockNumber);
  LastError:=Client.Delete(BlockType,BlockNumber);
  Elapse;
end;

procedure TFormClient.DnBtnClick(Sender: TObject);
Var
  BlockNum : integer;
begin
  LastOp:='Download';
  BlockNum:=StrToIntDef(EdNewNumber.Text,0);EdNewNumber.Text:=IntToStr(BlockNum);
  LastError:=Client.Download(BlockNum,@BlkBuffer,BlkBufSize);
  Elapse;
end;

procedure TFormClient.DumpData(P : PS7Buffer; Memo: TMemo; Count: integer);
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

procedure TFormClient.EdIDKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8,'0'..'9','$','A','a','B','b','C','c','D','d','E','e','F','f']) then
    Key:=#0;
end;

procedure TFormClient.EdRackKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8,'0'..'9']) then
     Key:=#0;
end;

procedure TFormClient.Elapse(TotTime: cardinal);
begin
  StatusBar.Panels[1].Text:=IntToStr(TotTime)+' ms';
end;

procedure TFormClient.Elapse;
begin
  Elapse(CliTime);
end;

function TFormClient.CliError(Error: integer): string;
begin
   Result:=CliErrorText(Error);
end;

procedure TFormClient.FillBlkBuffer(p: pointer; Size: integer);
begin
  move(P^,BlkBuffer,Size);
  BlkBufSize:=Size;
  DnBtn.Enabled:=true;
  AsDnBtn.Enabled:=true;
  EdNewNumber.Enabled:=true;
  BlkSaveBtn.Enabled:=true;
end;

procedure TFormClient.FillBlockInfo(Memo: TMemo; Info: PS7BlockInfo);

  function ByteToBin(B : Byte) : string;
  Const
    Mask : array[1..8] of byte = ($80,$40,$20,$10,$08,$04,$02,$01);
  var
    c: Integer;
  begin
    Result:='00000000';
    for c := 8 downto 1 do
      if (B and Mask[c])<>0 then
        Result[c]:='1';
  end;

begin
  with Memo.Lines do
  begin
    Clear;
    BeginUpdate;
    Add('Block Type   : '+SubBlkOf(Info^.BlkType));
    Add('Block Number : '+IntToStr(Info^.BlkNumber));
    Add('Block Lang   : '+LangOf(Info^.BlkLang));
    Add('Block Flags  : '+ByteToBin(Info^.BlkFlags));
    Add('MC7 Size     : '+IntToStr(Info^.MC7Size));
    Add('Load Size    : '+IntToStr(Info^.LoadSize));
    Add('Local Data   : '+IntToStr(Info^.LocalData));
    Add('SBB Length   : '+IntToStr(Info^.SBBLength));
    Add('CheckSum     : '+'$'+IntToHex(Info^.CheckSum,4));
    Add('Version      : '+IntToHex((Info^.Version and $F0) shr 4,1)+'.'+IntToHex((Info^.Version and $0F),1));
    Add('Code Date    : '+Info^.CodeDate);
    Add('Intf.Date    : '+Info^.IntfDate);
    Add('Author       : '+Info^.Author);
    Add('Family       : '+Info^.Family);
    Add('Header       : '+Info^.Header);
    EndUpdate;
  end;
end;

procedure TFormClient.FillBtnClick(Sender: TObject);
begin
  DBFill(False);
end;

procedure TFormClient.FormCreate(Sender: TObject);
var
  c: Integer;
  ThePlatform : string;
  Wide : string;
begin
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
     ThePlatform:='Unix platform';
  {$ENDIF}
  Caption:='Snap7 Client Demo - '+ThePlatform+Wide+
  {$IFDEF FPC}
    ' [Lazarus]';
  {$ELSE}
    ' [Delphi/RAD studio]';
  {$ENDIF}

  EvJob:=TEvent.Create(nil,false,false,'');
  Client := TS7Client.Create;
  RGMode.ItemIndex:=0;
  Connected:=false;
  ClearBlkBuffer;
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
  WindowState:=wsNormal;
end;

procedure TFormClient.Button2Click(Sender: TObject);
begin
end;


procedure TFormClient.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Client.Free;
  EvJob.Free;
end;

procedure TFormClient.FormDestroy(Sender: TObject);
begin
end;

procedure TFormClient.GridToData(Amount: integer);
Var
  c, r, x : integer;
begin
  ValidateGrid;
  with DataGrid do
  begin
    c:=1;r:=1;
    for x := 0 to Amount- 1 do
    begin
      Buffer[x]:=StrToIntDef(Cells[c,r],0);
      inc(c);
      if c=ColCount then
      begin
        c:=1;
        inc(r);
      end;
    end;
  end;
end;

procedure TFormClient.lbSZLDblClick(Sender: TObject);
begin
  if (lbSZL.Items.Count>0) and (lbSZL.ItemIndex>=0) then
  begin
    EdID.Text:=lbSZL.Items[lbSZL.ItemIndex];
    ReadSZL(false);
  end;
end;

procedure TFormClient.ListBlocks;

  procedure UpdateCount;
  begin
    with BlocksList do
    begin
      txtOB.Caption :=IntToStr(OBCount);
      txtFB.Caption :=IntToStr(FBCount);
      txtFC.Caption :=IntToStr(FCCount);
      txtSFB.Caption:=IntToStr(SFBCount);
      txtSFC.Caption:=IntToStr(SFCCount);
      txtDB.Caption :=IntToStr(DBCount);
      txtSDB.Caption:=IntToStr(SDBCount);
    end;
  end;

begin
  LastOP:='Blocks List';
  FillChar(BlocksList,SizeOf(BlocksList),#0);
  UpdateCount;
  LastError:=Client.ListBlocks(@BlocksList);
  if LastError=0 then
  begin
    Elapse;
    if LastError=0 then
      UpdateCount;
  end
  else
    Elapse;
end;

procedure TFormClient.ListBlocksOfType(Async: boolean);
Var
  List : TS7BlocksOfType;
  Count: integer;
  BlockType : integer;
  c: Integer;
begin
  if Async then
    LastOp:='Async List Blocks of type'
  else
    LastOp:='List Blocks of type';

  BlockType:=BlockOf[CbBot.ItemIndex];
  ListBot.Clear;

  Count:=SizeOf(List) div 2;

  if Async then
    LastError:=Client.AsListBlocksOfType(BlockType,@List,Count)
  else
    LastError:=Client.ListBlocksOfType(BlockType,@List,Count);

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
    if LastError=0 then
    begin
      ListBot.Items.BeginUpdate;
      try
        for c := 0 to Count - 1 do
          ListBot.Items.Add(IntToStr(List[c]));
      finally
        ListBot.Items.EndUpdate;
      end;
    end;
  end;
  Elapse;
end;

procedure TFormClient.ListBotDblClick(Sender: TObject);
begin
  if (ListBot.Items.Count>0) and (ListBot.ItemIndex>=0) then
  begin
    EdBlkNum.Text:=ListBot.Items[ListBot.ItemIndex];
    CbBlock.ItemIndex:=CbBot.ItemIndex;
    GetBlockInfo;
  end;
end;

function TFormClient.LoadFromFile(const FileName: string; P: pointer;
  var Size: integer) : boolean;
Var
  F : file of byte;
  FSize : integer;
  Read : integer;

  procedure Error;
  begin
    MessageDlg('An error occurred loading '+FileName,mtError,[mbOk],0);
  end;

begin
  AssignFile(F,FileName);
  {$I-}
  Reset(F);
  {$I+}
  Result:=IoResult=0;
  if not Result then
  begin
    Error;
    exit;
  end;
  {$I-}
  FSize:=FileSize(F);
  BlockRead(F,P^,FSize,Read);
  CloseFile(F);
  {$I+}
  Result:=(IoResult=0) and (Read=FSize);
  if not Result then
    Error
  else
    Size:=FSize;
end;

procedure TFormClient.MultiRead;

  procedure GetValues(CbArea : TComboBox; EdDB,EDStart,EDSize : TEdit; var PlcArea,DBNum,Start,Size : integer);
  begin
    DBNum:=StrToIntDef(EdDB.Text,0);
    EdDB.Text:=IntToStr(DBNum);
    Start:=StrToIntDef(EDStart.Text,0);
    EDStart.Text:=IntToStr(Start);
    Size:=StrToIntDef(EdSize.Text,0);
    EdSize.Text:=IntToStr(Size);
    PlcArea:=AreaOf[CbArea.ItemIndex];
  end;

  function HexString(ptr : pbyte; size : integer) : string;
  var
    c: Integer;
    P : PS7Buffer;
  begin
    Result:='';
    P:=PS7Buffer(Ptr);
    for c := 0 to Size - 1 do
      Result:=Result+'$'+IntToHex(P^[c],2)+' ';
  end;

var
  c: Integer;
begin
  LastOP:='Read MultiVars';

  ClearMultiReadWrite;
  // Items
  GetValues(ComboArea_1,EdDBNum_1,EdStart_1,EdAmount_1,DataItems[0].Area,DataItems[0].DBNumber,DataItems[0].Start,DataItems[0].Amount);
  GetValues(ComboArea_2,EdDBNum_2,EdStart_2,EdAmount_2,DataItems[1].Area,DataItems[1].DBNumber,DataItems[1].Start,DataItems[1].Amount);
  GetValues(ComboArea_3,EdDBNum_3,EdStart_3,EdAmount_3,DataItems[2].Area,DataItems[2].DBNumber,DataItems[2].Start,DataItems[2].Amount);
  GetValues(ComboArea_4,EdDBNum_4,EdStart_4,EdAmount_4,DataItems[3].Area,DataItems[3].DBNumber,DataItems[3].Start,DataItems[3].Amount);
  GetValues(ComboArea_5,EdDBNum_5,EdStart_5,EdAmount_5,DataItems[4].Area,DataItems[4].DBNumber,DataItems[4].Start,DataItems[4].Amount);

  if (DataItems[0].Amount=0) or
     (DataItems[1].Amount=0) or
     (DataItems[2].Amount=0) or
     (DataItems[3].Amount=0) or
     (DataItems[4].Amount=0) then
  begin
    MessageDlg('Size 0 not allowed',mtError,[mbOk],0);
    exit;
  end;

  // Note: for this demo we assume Wordlen=byte unless Area is Timer or counter.
  //       In real application see the documentation
  for c := 0 to 4 do
    if DataItems[c].Area=S7AreaCT then DataItems[c].WordLen:=S7WLCounter else
      if DataItems[c].Area=S7AreaTM then DataItems[c].WordLen:=S7WLTimer else
        DataItems[c].WordLen:=S7WLByte;

  // Calcs the size needed
  for c := 0 to 4 do
    GetMem(DataItems[c].pdata,WordSize(DataItems[c].Amount,DataItems[c].WordLen));

  LastError:=Client.ReadMultiVars(@DataItems,5);

  if LastError=0 then
  begin
    Elapse;
    if LastError=0 then
    begin
      if DataItems[0].Result=0 then
      begin
        EdData_1.Text:=HexString(DataItems[0].pdata,WordSize(DataItems[0].Amount,DataItems[0].WordLen));
        EdResult_1.Text:='OK';
      end
      else
        EdResult_1.Text:=CliError(DataItems[0].Result);

      if DataItems[1].Result=0 then
      begin
        EdData_2.Text:=HexString(DataItems[1].pdata,WordSize(DataItems[1].Amount,DataItems[1].WordLen));
        EdResult_2.Text:='OK';
      end
      else
        EdResult_2.Text:=CliError(DataItems[1].Result);

      if DataItems[2].Result=0 then
      begin
        EdData_3.Text:=HexString(DataItems[2].pdata,WordSize(DataItems[2].Amount,DataItems[2].WordLen));
        EdResult_3.Text:='OK';
      end
      else
        EdResult_3.Text:=CliError(DataItems[2].Result);

      if DataItems[3].Result=0 then
      begin
        EdData_4.Text:=HexString(DataItems[3].pdata,WordSize(DataItems[3].Amount,DataItems[3].WordLen));
        EdResult_4.Text:='OK';
      end
      else
        EdResult_4.Text:=CliError(DataItems[3].Result);

      if DataItems[4].Result=0 then
      begin
        EdData_5.Text:=HexString(DataItems[4].pdata,WordSize(DataItems[4].Amount,DataItems[4].WordLen));
        EdResult_5.Text:='OK';
      end
      else
        EdResult_5.Text:=CliError(DataItems[4].Result);
    end;
  end
  else
    Elapse;

  for c := 0 to 4 do
    FreeMem(DataItems[c].pdata,WordSize(DataItems[c].Amount,DataItems[c].WordLen));
end;

procedure TFormClient.MultiReadBtnClick(Sender: TObject);
begin
  MultiRead;
end;

procedure TFormClient.MultiVarReadBtnClick(Sender: TObject);
begin
end;

procedure TFormClient.MultiVarWriteBtnClick(Sender: TObject);
begin
end;

procedure TFormClient.MultiWrite;

  procedure GetValues(CbArea : TComboBox; EdDB,EDStart,EDSize : TEdit; var PlcArea,DBNum,Start,Size : integer);
  begin
    DBNum:=StrToIntDef(EdDB.Text,0);
    EdDB.Text:=IntToStr(DBNum);
    Start:=StrToIntDef(EDStart.Text,0);
    EDStart.Text:=IntToStr(Start);
    Size:=StrToIntDef(EdSize.Text,0);
    EdSize.Text:=IntToStr(Size);
    PlcArea:=AreaOf[CbArea.ItemIndex];
  end;

  procedure EditToBuffer(ChEd: TEdit; p: Pbyte);
  var
    c: Integer;
    pb : PS7Buffer;
    B : byte;
  begin
    B:=StrToIntDef(ChEd.Text,0);
    ChEd.Text:='$'+IntToHex(B,2);

    pb:=PS7Buffer(p);
    for c := 0 to 15 do
      pb^[c]:=B;
  end;

var
  c: Integer;
begin
  LastOP:='Write MultiVars';

  fillchar(DataItems,SizeOf(TS7DataItems),#0);
  // Items
  GetValues(ComboArea_1,EdDBNum_1,EdStart_1,EdAmount_1,DataItems[0].Area,DataItems[0].DBNumber,DataItems[0].Start,DataItems[0].Amount);
  GetValues(ComboArea_2,EdDBNum_2,EdStart_2,EdAmount_2,DataItems[1].Area,DataItems[1].DBNumber,DataItems[1].Start,DataItems[1].Amount);
  GetValues(ComboArea_3,EdDBNum_3,EdStart_3,EdAmount_3,DataItems[2].Area,DataItems[2].DBNumber,DataItems[2].Start,DataItems[2].Amount);
  GetValues(ComboArea_4,EdDBNum_4,EdStart_4,EdAmount_4,DataItems[3].Area,DataItems[3].DBNumber,DataItems[3].Start,DataItems[3].Amount);
  GetValues(ComboArea_5,EdDBNum_5,EdStart_5,EdAmount_5,DataItems[4].Area,DataItems[4].DBNumber,DataItems[4].Start,DataItems[4].Amount);

  if (DataItems[0].Amount=0) or
     (DataItems[1].Amount=0) or
     (DataItems[2].Amount=0) or
     (DataItems[3].Amount=0) or
     (DataItems[4].Amount=0) then
  begin
    MessageDlg('Size 0 not allowed',mtError,[mbOk],0);
    exit;
  end;

  // Note: for this demo we assume Wordlen=byte unless Area is Timer or counter.
  //       In real application see the documentation
  for c := 0 to 4 do
    if DataItems[c].Area=S7AreaCT then DataItems[c].WordLen:=S7WLCounter else
      if DataItems[c].Area=S7AreaTM then DataItems[c].WordLen:=S7WLTimer else
        DataItems[c].WordLen:=S7WLByte;

  // for simplicity we allocate 1k per item
  for c := 0 to 4 do
  begin
    GetMem(DataItems[c].pdata,1024);
    fillchar(DataItems[c].pdata^,1024,#0);
  end;

  EditToBuffer(ChEd_1,DataItems[0].pdata);
  EditToBuffer(ChEd_2,DataItems[1].pdata);
  EditToBuffer(ChEd_3,DataItems[2].pdata);
  EditToBuffer(ChEd_4,DataItems[3].pdata);
  EditToBuffer(ChEd_5,DataItems[4].pdata);

  LastError:=Client.WriteMultiVars(@DataItems,5);


  if LastError=0 then
  begin
    Elapse;
    if LastError=0 then
    begin
      if DataItems[0].Result=0 then
        EdResult_1.Text:='OK'
      else
        EdResult_1.Text:=CliError(DataItems[0].Result);

      if DataItems[1].Result=0 then
        EdResult_2.Text:='OK'
      else
        EdResult_2.Text:=CliError(DataItems[1].Result);

      if DataItems[2].Result=0 then
        EdResult_3.Text:='OK'
      else
        EdResult_3.Text:=CliError(DataItems[2].Result);

      if DataItems[3].Result=0 then
        EdResult_4.Text:='OK'
      else
        EdResult_4.Text:=CliError(DataItems[3].Result);

      if DataItems[4].Result=0 then
        EdResult_5.Text:='OK'
      else
        EdResult_5.Text:=CliError(DataItems[4].Result);
    end;
  end
  else
    Elapse;

  for c := 0 to 4 do
    FreeMem(DataItems[c].pdata,1024);

end;

procedure TFormClient.MultiWriteBtnClick(Sender: TObject);
begin
  MultiWrite;
end;

procedure TFormClient.PageControlChange(Sender: TObject);
begin
  TimClock.Enabled :=PageControl.ActivePage=TabClock;
  TimStatus.Enabled:=PageControl.ActivePage=TabControl;
  TimSecurity.Enabled:=Pagecontrol.ActivePage=TabSecurity;

  if Pagecontrol.ActivePage=TabSecurity then
    GetProtection;

  if PageControl.ActivePage=TabZSL then
    ReadSZLList(false);
end;

procedure TFormClient.Read(Async: boolean);
Var
  Area   : integer;
  DBNum  : integer;
  Start  : integer;
  Amount : integer;
  WLen   : integer;
begin
  if ASync then
    LastOP:='Async Read Data'
  else
    LastOP:='Read Data';

  Area  :=AreaOf[CbArea.ItemIndex];
  DBNum :=StrToIntDef(EdDbNum.Text,0);   EdDbNum.Text:=IntToStr(DBNum);
  Start :=StrToIntDef(EdStart.Text,0);  EdStart.Text:=IntToStr(Start);
  Amount:=StrToIntDef(EdAmount.Text,0); EdAmount.Text:=IntToStr(Amount);
  WLen  :=WLenOf[cbWLen.ItemIndex];

  if Async then
    LastError:=Client.AsReadArea(Area,DBNum,Start,Amount,WLen,@Buffer)
  else
    LastError:=Client.ReadArea(Area,DBNum,Start,Amount,WLen,@Buffer);

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
    Elapse;

    if LastError=0 then
      DataToGrid(WordSize(Amount,WLen));
  end
  else
    Elapse;
end;

procedure TFormClient.ReadSZL(Async: boolean);
Var
  ID, Index : integer;
  SZL : TS7SZL;
  Size : integer;
begin
  if ASync then
    LastOP:='Async Read SZL'
  else
    LastOP:='Read SZL';

  MemoSZL.Lines.Clear;
  lblSZLdump.Caption:='SZL Dump : 0 bytes';
  ID:=StrToIntDef(EdID.Text,0);EdID.Text:='$'+IntToHex(ID,4);
  Index:=StrToIntDef(EdIndex.Text,0);EdIndex.Text:='$'+IntToHex(Index,4);
  Size:=SizeOf(SZL);
  if ASync then
    LastError:=Client.AsReadSZL(ID,Index,@SZL, Size)
  else
    LastError:=Client.ReadSZL(ID,Index,@SZL, Size);

  if LastError=0 then
  begin
    if ASync then
      WaitCompletion;
    Elapse;
    if (LastError=0) then
    begin
      DumpData(@SZL,MemoSZL,Size);
      lblSZLdump.Caption:='SZL Dump : '+inttostr(Size)+' bytes';
    end;
  end
  else
    Elapse;
end;

procedure TFormClient.RGModeClick(Sender: TObject);
begin
  AsMode:=RGMode.ItemIndex; // 0 : amPolling
                            // 1 : amEvent
                            // 2 : amCallBack
  if AsMode =2 then
    Client.SetAsCallback(@ClientCompletion,Self)
  else
    Client.SetAsCallback(nil, nil);

end;

procedure TFormClient.SaveToFile(const FileName: string; P: pointer;
  Size: integer);
Var
  F : File of byte;
begin
  AssignFile(F, FileName);
  {$I-}
  Rewrite(F);
  BlockWrite(F,P^,Size);
  CloseFile(F);
  {$I+}
  if IoResult<>0 then
    MessageDlg('An error occurred saving '+FileName,mtError,[mbok],0);
end;

procedure TFormClient.SetFConnected(const Value: boolean);
begin
  FConnected := Value;

  if FConnected then
  begin
    BtnConnect.Enabled:=false;
    BtnDisconnect.Enabled:=true;
    PageControl.Enabled:=true;
    PCC.Enabled:=false;
    EdIp.Enabled:=false;
    EdRack.Enabled:=false;
    EdSlot.Enabled:=false;
    if PCC.ActivePageIndex=0 then
      GetSysInfo;
  end
  else begin
    ClearPages;
    BtnConnect.Enabled:=true;
    BtnDisconnect.Enabled:=false;
    PageControl.Enabled:=false;
    PageControl.ActivePageIndex:=0;
    PCC.Enabled:=true;
    EdIp.Enabled:=true;
    edRack.Enabled:=true;
    edSlot.Enabled:=true;
  end;
end;

procedure TFormClient.SetFLastError(const Value: integer);
begin
  FLastError := Value;
  if FLastError=0 then
    StatusBar.Panels[2].Text:='OK'
  else
    StatusBar.Panels[2].Text:=CliError(FLastError);
end;

procedure TFormClient.SetFLastOP(const Value: string);
begin
  FLastOP := Value;
  StatusBar.Panels[0].Text:=FLastOP;
end;

procedure TFormClient.SetPassword;
begin
  LastOp:='Set Session password';
  LastError:=Client.SetSessionPassword(AnsiString(EdPassword.Text));
  Elapse;
end;

procedure TFormClient.TimClockTimer(Sender: TObject);
Var
  DT : TDateTime;
Begin
  if ChkGetDateTime.Checked then
  begin
    LastOp:='Read PLC Date and Time';
    LastError:=Client.GetPlcDateTime(DT);
    if LastError=0 then
    begin
      edAGDate.Text:=DateToStr(DT);
      edAGTime.Text:=TimeToStr(DT);
    end;
    Elapse;
  end;
  edPGDate.Text:=DateToStr(Now);
  edPGTime.Text:=TimeToStr(Now);
end;

procedure TFormClient.TimSecurityTimer(Sender: TObject);
begin
  if ChkSecurity.Checked then
    GetProtection;
end;

procedure TFormClient.TimStatusTimer(Sender: TObject);
begin
  if ChkStatusRefresh.Checked then
    GetStatus;
end;

procedure TFormClient.txtOBDblClick(Sender: TObject);
Var
  ST : TStaticText;
begin
  ST:=TStaticText(Sender);
  if StrToIntDef(Trim(ST.Caption),0)=0 then
    exit;

  if ST=txtOB then
    CbBot.ItemIndex:=0;
  if ST=txtFB then
    CbBot.ItemIndex:=1;
  if ST=txtFC then
    CbBot.ItemIndex:=2;
  if ST=txtDB then
    CbBot.ItemIndex:=3;
  if ST=txtSFB then
    CbBot.ItemIndex:=4;
  if ST=txtSFC then
    CbBot.ItemIndex:=5;
  if ST=txtSDB then
    CbBot.ItemIndex:=6;

  ListBlocksOfType(false);
end;

procedure TFormClient.Upload(Full, Async: boolean);
Var
  BlockType, BlockNumber : integer;
  BlockSize : integer;
begin
  ClearBlkBuffer;
  if Async then
    LastOp :='Async Block Upload'
  else
    LastOp :='Block Upload';

  MemoUpload.Lines.Clear;
  MemoBlkInfo.Lines.Clear;

  BlockType:=BlockOf[cbBlkType.ItemIndex];
  BlockNumber:=StrToIntDef(EdNum.Text,0);EdNum.Text:=IntToStr(BlockNumber);
  BlockSize:=SizeOf(Buffer);

  if Full then
  begin
    if Async then
      LastError:=Client.AsFullUpload(BlockType,BlockNumber,@Buffer,BlockSize)
    else
      LastError:=Client.FullUpload(BlockType,BlockNumber,@Buffer,BlockSize);
  end
  else begin
    if Async then
      LastError:=Client.AsUpload(BlockType,BlockNumber,@Buffer,BlockSize)
    else
      LastError:=Client.Upload(BlockType,BlockNumber,@Buffer,BlockSize);
  end;

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
    if LastError=0 then
    begin
      DumpData(@Buffer,MemoUpload,BlockSize);
      if Full then
      begin
        Client.GetPgBlockInfo(@Buffer,@BlockInfo,BlockSize);
        FillBlockInfo(MemoBlkInfo,@BlockInfo);
        FillBlkBuffer(@Buffer,BlockSize);
      end
      else
        MemoBlkInfo.Lines.Add('INFO NOT AVAILABLE');
    end;
  end;
  Elapse;
  if LastError=0 then
    lblUpld.Caption:='Block Dump : '+IntToStr(BlockSize)+' byte'
  else
    lblUpld.Caption:='Block Dump : 0 byte';
end;

procedure TFormClient.ValidateGrid;
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

// Call this function when is expect data and size
procedure TFormClient.WaitCompletion(Const Timeout : integer = 1500);
Var
  Result : integer;
begin

  Application.ProcessMessages;
  case AsMode of
    amPolling,
    amCallBack:

      repeat
        Application.ProcessMessages;
      until Client.CheckAsCompletion(Result);

    amEvent : Result:=Client.WaitAsCompletion(Timeout);
    (*
    amCallBack : begin
      // in our callback we setted evJob
        if evJob.WaitFor(Timeout)=wrSignaled then
        Result:=AsOpResult
      else
        Result:=errCliJobTimeout;
      end;
      *)
  end;

  LastError:=Result;
end;

// Call this function when don't expect data and size
function TFormClient.WordSize(Amount, WordLength: integer): integer;
begin
  case WordLength of
    S7WLBit     : Result := Amount * 1;  // S7 sends 1 byte per bit
    S7WLByte    : Result := Amount * 1;
    S7WLWord    : Result := Amount * 2;
    S7WLDword   : Result := Amount * 4;
    S7WLReal    : Result := Amount * 4;
    S7WLCounter : Result := Amount * 2;
    S7WLTimer   : Result := Amount * 2;
  else
    Result:=0;
  end;
end;

procedure TFormClient.Write(Async: boolean);
Var
  Area   : integer;
  DBNum  : integer;
  Start  : integer;
  Amount : integer;
  WLen   : integer;
begin
  if ASync then
    LastOP:='Async Write Data'
  else
    LastOP:='Write Data';

  Area  :=AreaOf[CbArea.ItemIndex];
  DBNum :=StrToIntDef(EdDbNum.Text,0);
  Start :=StrToIntDef(EdStart.Text,0);
  Amount:=StrToIntDef(EdAmount.Text,0);
  WLen  :=WLenOf[cbWLen.ItemIndex];

  GridToData(Amount*SizeByte[cbWLen.ItemIndex]);

  if Async then
    LastError:=Client.AsWriteArea(Area,DBNum,Start,Amount,WLen,@Buffer)
  else
    LastError:=Client.WriteArea(Area,DBNum,Start,Amount,WLen,@Buffer);

  if LastError=0 then
  begin
    if Async then
      WaitCompletion;
    Elapse;
  end
  else
    Elapse;
end;

end.
