unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls, StdCtrls, VirtualTrees, Snap7,
  ImgList, WinSock2, ExtCtrls, Menus, mORMotReport;

type

  TClientTag = record
    Client : integer;
    OpRw   : integer;
    HMITag : TS7Tag;
  end;

  TLogLevel = (llBasic, llDetailed, llDebug);

  TNodeType = (ntRoot, ntClient, ntTag, ntResRoot, ntDB);

  TObjectNode = class(TObject)
  protected
    FCaption: string;
    FSize: string;
    FNodeType: TNodeType;
    FImageIndex: integer;
    FChanged: boolean;
  public
    constructor Create(NodeType : TNodeType);
    property ImageIndex : integer read FImageIndex;
    property NodeType : TNodeType read FNodeType;
    property Caption : string read FCaption write FCaption;
    property Size : string read FSize write FSize;
    property Changed : boolean read FChanged;
  end;

  TTagNode = class(TObjectNode)
  private
    FTagType: string;
    FElements: string;
    FAddress: string;
    FAccess: string;
    FUID: int64;
    FOperation: integer;
    FTag: TS7Tag;
    FTagLimit: integer;
    procedure SetFOperation(const Value: integer);
    procedure SetFTag(const Value: TS7Tag);
  public
    property Access : string read FAccess write FAccess;
    property Address : string read FAddress write FAddress;
    property TagType : string read FTagType write FTagType;
    property Elements : string read FElements write FElements;
    property Operation : integer read FOperation write SetFOperation;
    property UID : int64 read FUID write FUID;
    property TagLimit : integer read FTagLimit;
    property Tag : TS7Tag read FTag write SetFTag;
  end;

  PTagTreeData = ^TTagTreeData;
  TTagTreeData = record
    Obj : TTagNode;
  end;

  TResNode = class(TObjectNode)
  private
    FSizeNeeded: integer;
    procedure SetFSizeNeeded(const Value: integer);
  public
    property SizeNeeded : integer read FSizeNeeded write SetFSizeNeeded;
  end;

  PResTreeData = ^TResTreeData;
  TResTreeData = record
    Obj : TResNode;
  end;

  TObjectsList = class(TList)
  private
    function GetObj(index: integer): TTagNode;
  public
    function Find(UID : int64) : TTagNode;
    property Obj[index : integer] : TTagNode read GetObj; default;
  end;

  TTagQueue = class(TObject)
  private
    IndexIn    : integer;   // <-- insert index
    IndexOut   : integer;   // --> extract index
    Max        : integer;   // Buffer upper bound [0..Max]
    FCapacity  : integer;   // Queue capacity
    Buffer     : PByteArray;
    FBlockSize : integer;
  public
    constructor Create(const Capacity, BlockSize : integer);
    destructor Destroy; override;
    procedure Flush;
    procedure Insert(lpdata : pointer);
    function Extract(lpdata : pointer) : boolean;
    function Empty : boolean;
  end;

  TSrvForm = class(TForm)
    VT: TVirtualStringTree;
    Images: TImageList;
    RT: TVirtualStringTree;
    SB: TStatusBar;
    Log: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    TimLog: TTimer;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Log1: TMenuItem;
    Detail1: TMenuItem;
    BasicMItem: TMenuItem;
    DetailedMItem: TMenuItem;
    DebugMItem: TMenuItem;
    Clear1: TMenuItem;
    N1: TMenuItem;
    FreezeMItem: TMenuItem;
    FlushServerwueue1: TMenuItem;
    N2: TMenuItem;
    SettingMItem: TMenuItem;
    TimTag: TTimer;
    N3: TMenuItem;
    StartMItem: TMenuItem;
    Report1: TMenuItem;
    ReportMItem: TMenuItem;
    procedure VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TimLogTimer(Sender: TObject);
    procedure FreezeMItemClick(Sender: TObject);
    procedure TimTagTimer(Sender: TObject);
    procedure BasicMItemClick(Sender: TObject);
    procedure DetailedMItemClick(Sender: TObject);
    procedure DebugMItemClick(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure StartMItemClick(Sender: TObject);
    procedure SettingMItemClick(Sender: TObject);
    procedure RTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure RTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure RTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure Exit1Click(Sender: TObject);
    procedure ReportMItemClick(Sender: TObject);
    procedure VTEdited(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
  private
    { Private declarations }
    Server : TS7Server;
    Tags : TObjectsList;
    TagRoot : PVirtualNode;
    ResRoot : PVirtualNode;
    DBList : TStringList;
    Queue : TTagQueue;
    Running : boolean;
    FServerStatus: integer;
    FClientsCount: integer;
    FLogLevel: TLogLevel;
    LocalAddress : string;
    TagCount : integer;
    function TagUID(Tag : TS7Tag) : int64;
    function GetTagObject(Node : PVirtualNode) : TTagNode;
    function GetResObject(Node : PVirtualNode) : TResNode;
    function FindClientNode(IP : string) : PVirtualNode;
    function NewTagName : string;
    function ClientIP(Address : integer) : string;
    procedure NewTag(CliTag : TClientTag);
    procedure InitTagTree;
    procedure InitResTree;
    procedure Clear;
    procedure RunStop;
    procedure UpdateDBList(Obj : TTagNode);
    procedure SetFClientsCount(const Value: integer);
    procedure SetFServerStatus(const Value: integer);
    procedure SetFLogLevel(const Value: TLogLevel);
    procedure CreateReport;
  public
    { Public declarations }
    procedure TagIncoming(Client, Operation : integer; PTag : PS7Tag);
    property ServerStatus : integer read FServerStatus write SetFServerStatus;
    property ClientsCount : integer read FClientsCount write SetFClientsCount;
    property LogLevel : TLogLevel read FLogLevel write SetFLogLevel;
  end;

var
  SrvForm: TSrvForm;

implementation
Uses
  frmReport;
{$R *.dfm}

function RWAreaCallback(usrPtr : pointer; Sender, Operation : integer; PTag : PS7Tag; pUsrData : pointer) : integer; stdcall;
begin
  try
    TSrvForm(usrPtr).TagIncoming(Sender, Operation, PTag);
  except
  end;
  Result:=0;
end;

{ TEventQueue }

constructor TTagQueue.Create(const Capacity, BlockSize : integer);
begin
  inherited Create;
  FCapacity:=Capacity;
  Max :=FCapacity-1;
  FBlockSize:=BlockSize;
  GetMem(Buffer,FCapacity*FBlockSize);
end;

destructor TTagQueue.Destroy;
begin
  FreeMem(Buffer,FCapacity*FBlockSize);
  inherited;
end;

function TTagQueue.Empty: boolean;
begin
  Result:=IndexIn=IndexOut;
end;

function TTagQueue.Extract(lpdata : pointer): boolean;
Var
  Offset : integer;
  IdxOut : integer;
begin
  Result:=not Empty;
  if Result then
  begin
    // Calc offset
    IdxOut:=indexOut;
    if IdxOut<Max then inc(IdxOut) else IdxOut:=0;
    Offset:=IdxOut*FBlockSize;
    // moves data
    move(Buffer^[Offset],lpData^,FBlockSize);
    // Updates IndexOut
    IndexOut:=IdxOut;
  end;
end;

procedure TTagQueue.Flush;
begin
  IndexIn :=0;
  IndexOut:=0;
end;

procedure TTagQueue.Insert(lpdata : pointer);
Var
  idxOut : integer;
  Offset : integer;
begin
  idxOut:=IndexOut; // To avoid that indexout may change during next line
  if not ((IdxOut=IndexIn+1) or ((IndexIn=Max) and (IdxOut=0))) then // if not full
  begin
    // Calc offset
    if IndexIn<Max then inc(IndexIn) else IndexIn:=0;
    Offset:=IndexIn*FBlockSize;
    move(lpData^,Buffer^[Offset],FBlockSize);
  end;
end;

{ TObjectsList }

function TObjectsList.Find(UID : int64): TTagNode;
var
  c: Integer;
begin
  for c := 0 to Count-1 do
  begin
    if Obj[c].UID=UID then
    begin
      Result:=Obj[c];
      exit;
    end;
  end;
  Result:=nil;
end;

function TObjectsList.GetObj(index: integer): TTagNode;
begin
  Result:=TTagNode(Items[index]);
end;


{ TObjectNode }

constructor TObjectNode.Create(NodeType: TNodeType);
begin
  inherited Create;
  FNodeType := NodeType;
  case FNodeType of
    ntRoot   : FImageIndex:=0;
    ntClient : FImageIndex:=1;
    ntTag    : FImageIndex:=2;
    ntResRoot: FImageIndex:=3;
    ntDB     : FImageIndex:=4;
  end;
  FChanged:=true;
end;

{ TResNode }

procedure TResNode.SetFSizeNeeded(const Value: integer);
begin
  FSizeNeeded := Value;
  FSize:=IntToStr(FSizeNeeded);
  FChanged:=true;
end;

{ TTagNode }

procedure TTagNode.SetFOperation(const Value: integer);
Var
  TheAccess : string;
begin
  if Value=OperationRead then
    FOperation:=FOperation OR $01
  else
    FOperation:=FOperation OR $02;

  case FOperation of
    $01 : TheAccess:='R';
    $02 : TheAccess:='W';
    $03 : TheAccess:='R/W';
  end;
  FChanged:=THeAccess<>FAccess;
  FAccess:=THeAccess;
end;

procedure TTagNode.SetFTag(const Value: TS7Tag);
Var
  WPrefix : string;
  APrefix : string;
  Offset  : string;
begin
  FTag := Value;

  case FTag.Area of
    S7AreaPE : APrefix:='E';
    S7AreaPA : APrefix:='A';
    S7AreaMK : APrefix:='M';
    S7AreaDB : APrefix:='DB '+IntToStr(Tag.DBNumber)+' DB';
    S7AreaCT : APrefix:='Z';
    S7AreaTM : APrefix:='T';
    else
      APrefix:='(0x'+IntToHex(FTag.Area,4)+')';
  end;

  case FTag.WordLen of
    S7WLBit:
      begin
        if FTag.Area=S7AreaDB then
          WPrefix:='X';
        FTagType:='Bool';
        Offset:=IntToStr(Tag.Start div 8)+'.'+IntToStr(Tag.Start mod 8);
        FElements:=IntToStr(Tag.Elements);
        FSize:=IntToStr(Tag.Elements);
        FTagLimit:=Tag.Start div 8;
        if FTagLimit mod 2 <>0 then
          FTagLimit:=FTagLimit+1;
        if FTagLimit=0 then
          FTagLimit:=2;

      end;
    S7WLByte:
      begin
        WPrefix:='B';
        FTagType:='Byte';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements);
        FTagLimit:=Tag.Start+Tag.Elements;
      end;
    S7WLChar:
      begin
        WPrefix:='B';
        FTagType:='Char';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements);
        FTagLimit:=Tag.Start+Tag.Elements;
      end;
    S7WLWord:
      begin
        WPrefix:='W';
        FTagType:='Word';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*2);
        FTagLimit:=Tag.Start+Tag.Elements*2;
      end;
    S7WLInt:
      begin
        WPrefix:='W';
        FTagType:='Int';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*2);
        FTagLimit:=Tag.Start+Tag.Elements*2;
      end;
    S7WLDWord:
      begin
        WPrefix:='D';
        FTagType:='DWord';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*4);
        FTagLimit:=Tag.Start+Tag.Elements*4;
      end;
    S7WLDInt:
      begin
        WPrefix:='D';
        FTagType:='DInt';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*4);
        FTagLimit:=Tag.Start+Tag.Elements*4;
      end;
    S7WLReal:
      begin
        WPrefix:='D';
        FTagType:='Real';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*4);
        FTagLimit:=Tag.Start+Tag.Elements*4;
      end;
    S7WLCounter:
      begin
        FTagType:='Counter';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*2);
      end;
    S7WLTimer:
      begin
        FTagType:='Timer';
        FElements:=IntToStr(Tag.Elements);
        Offset:=IntToStr(Tag.Start);
        FSize:=IntToStr(Tag.Elements*2);
      end;
    else begin
      FTagType:='0x'+IntToHex(Tag.WordLen,4);
      WPrefix :=FTagType;
      Offset:='('+IntToStr(Tag.Start)+')';
    end;
  end;

  FAddress:=APrefix+WPrefix+' '+Offset;

  if Odd(FTagLimit) then
    FTagLimit:=FTagLimit+1;
end;

{ TSrvForm }

procedure TSrvForm.TagIncoming(Client, Operation : integer; PTag : PS7Tag);
Var
  CliTag : TClientTag;
begin
  CliTag.Client:=Client;
  CliTag.OpRw  :=Operation;
  CliTag.HMITag:=PTag^;
  Queue.Insert(@CliTag);
end;

procedure TSrvForm.BasicMItemClick(Sender: TObject);
begin
  BasicMItem.Checked:=true;
  LogLevel:=llBasic;
end;

procedure TSrvForm.Clear;
begin
  VT.Clear;
  RT.Clear;
  Tags.Clear;
  DBList.Clear;
end;

procedure TSrvForm.Clear1Click(Sender: TObject);
begin
  Log.Clear;
end;

function TSrvForm.ClientIP(Address: integer): string;
Var
  Addr : in_addr;
begin
  Addr.s_addr:=Address;
  Result:=String(inet_ntoa(Addr));
end;

procedure TSrvForm.CreateReport;
Var
  GDIPages : TGDIPages;
  LastClient : string;
  c: TGDIPages;

  procedure CreateHeader;
  Var
    Family : string;
  begin
    Family:='';
    with GDIPages do
    begin
      // Footer
      SaveLayout;
      Font.Style := [];
      TextAlign := taRight;
      AddLineToFooter(false);
      AddPagesToFooterAt('Page %d/%d',RightMarginPos);
      RestoreSavedLayout;
      // Header
      DrawLine;
      Font.Size := 12;
      Font.Style:=[fsBold];
      AddColumns([20,80]);
      DrawTextAcrossCols(['Server',LocalAddress]);
      DrawTextAcrossCols(['Session',DateTimeToStr(Now)]);
      DrawLine;
    end;
  end;

  procedure ShowPreview(Pages : TGDIPages);
  Var
    ReportForm : TReportForm;
    OldParent : TWinControl;
  begin
    ReportForm:=TReportForm.Create(nil);
    ReportForm.Position := poScreenCenter;
    ReportForm.Height := Screen.Height-64;
    ReportForm.Pages:=Pages;
    OldParent:=Pages.Parent;
    Pages.Parent:=ReportForm;
    Pages.Align := alClient;
    Pages.Zoom := PAGE_FIT;
    Pages.ExportPDFEmbeddedTTF:=true;
    try
      ReportForm.ShowModal;
    finally
      Pages.Parent:=OldParent;
      ReportForm.Free;
    end;
  end;

  procedure CreatePage(PageName : string);
  begin
    GDIPages.Font.Style:=[fsBold];
    GDIPages.Font.Size := 13;
    GDIPages.AddColumns([100]);
    GDIPages.DrawTextAcrossCols([' '+PageName],$00050EAB);
  end;

  procedure CreateClient(ClientName : string);
  begin
    GDIPages.NewHalfLine;
    GDIPages.Font.Style:=[fsBold];
    GDIPages.Font.Size := 12;
    GDIPages.AddColumns([100]);
    GDIPages.DrawTextAcrossCols([ClientName]);
    GDIPages.DrawLine;
    GDIPages.AddColumns([2,25,8,27,13,15,15]);
    GDIPages.Font.Style:=[];
    GDIPages.Font.Size := 11;
  end;

  procedure CreateDBGroup;
  begin
    GDIPages.AddColumns([2,25,73]);
    GDIPages.Font.Style:=[];
    GDIPages.Font.Size := 11;
    GDIPages.NewHalfLine;
  end;

  procedure AddTag(Obj : TTagNode);
  begin
    if Assigned(Obj) then
      GDIPages.DrawTextAcrossCols(['',obj.Caption,Obj.Access,Obj.Address,Obj.FTagType,Obj.Elements,Obj.Size]);
  end;

  procedure AddDB(Obj : TResNode);
  begin
    if Assigned(Obj) then
      GDIPages.DrawTextAcrossCols(['',obj.Caption,Obj.Size]);
  end;

Var
  ClientNode : PVirtualNode;
  TagNode : PVirtualNode;
  DBNode : PVirtualNode;
  Obj : TTagNode;
  DB  : TResNode;
begin
  LastClient:='';
  GDIPages:=TGDIPages.Create(self);
  with GDIPages do
  try
    BeginDoc;
    Font.Name := 'Tahoma';
    CreateHeader;
    CreatePage('Tag List');
    if Assigned(VT.RootNode.FirstChild) then
      ClientNode:=VT.RootNode.FirstChild.FirstChild
    else
      ClientNode:=nil;

    while ClientNode<>nil do
    begin
      Obj:=GetTagObject(ClientNode);
      CreateClient(Obj.Caption);
      TagNode:=ClientNode.FirstChild;
      while TagNode<>nil do
      begin
        AddTag(GetTagObject(TagNode));
        TagNode:=TagNode.NextSibling;
      end;
      ClientNode:=ClientNode.NextSibling;
    end;

    GDIPages.NewLine;
    CreatePage('DB List');
    CreateDBGroup;

    if Assigned(RT.RootNode.FirstChild) then
      DBNode:=RT.RootNode.FirstChild.FirstChild
    else
      DBNode:=nil;

    while DBNode<>nil do
    begin
      AddDB(GetResObject(DBNode));
      DBNode:=DBNode.NextSibling;
    end;




    EndDoc;
    ShowPreview(GDIPages);
  finally
    Free;
  end;

end;

procedure TSrvForm.DebugMItemClick(Sender: TObject);
begin
  DebugMItem.Checked:=true;
  LogLevel:=llDebug;
end;

procedure TSrvForm.DetailedMItemClick(Sender: TObject);
begin
  DetailedMItem.Checked:=true;
  LogLevel:=llDetailed;
end;

procedure TSrvForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

function TSrvForm.FindClientNode(IP: string): PVirtualNode;
Var
  aNode : PVirtualNode;
  Obj : TTagNode;
begin
  Result:=nil;
  aNode:=TagRoot.FirstChild;
  while aNode<>nil do
  begin
    Obj:=GetTagObject(aNode);
    if Assigned(Obj) and SameText(Obj.Caption,IP) then
    begin
      Result:=aNode;
      exit;
    end;
    aNode:=aNode.NextSibling;
  end;
end;

procedure TSrvForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Server.Free;
  Queue.Free;
  DBList.Free;
  Tags.Free;
  VT.Clear;
end;

procedure TSrvForm.FormCreate(Sender: TObject);
begin
  Server := TS7Server.Create;
  Server.SetRWAreaCallback(@RWAreaCallback,Self);
  Queue := TTagQueue.Create(1024,SizeOf(TClientTag));
  Tags:= TObjectsList.Create;
  DBList :=TStringList.Create;
  DBList.Sorted:=true;
  Running := false;
  LocalAddress :='0.0.0.0';
  LogLevel:=llBasic;
  TimLog.Enabled:=true;
  InitTagTree;
  InitResTree;
end;

procedure TSrvForm.FreezeMItemClick(Sender: TObject);
begin
  if TimLog.Enabled then
  begin
    TimLog.Enabled:=false;
    FreezeMItem.Caption:='Run';
  end
  else begin
    TimLog.Enabled:=true;
    FreezeMItem.Caption:='Freeze';
  end;
end;

function TSrvForm.GetResObject(Node: PVirtualNode): TResNode;
Var
  Data : PResTreeData;
begin
  Data:=RT.GetNodeData(Node);
  if Assigned(Data) then
    Result:=Data^.Obj
  else
    Result:=nil;
end;

function TSrvForm.GetTagObject(Node: PVirtualNode): TTagNode;
Var
  Data : PTagTreeData;
begin
  Data:=VT.GetNodeData(Node);
  if Assigned(Data) then
    Result:=Data^.Obj
  else
    Result:=nil;
end;

procedure TSrvForm.InitResTree;

  procedure CreateRoot;
  Var
    Data    : PResTreeData;
  begin
    ResRoot:=RT.AddChild(nil);
    Data:=RT.GetNodeData(ResRoot);
    if Assigned(Data) then
    begin
      Data.Obj:=TResNode.Create(ntResRoot);
      Data.Obj.Caption:='Memory';
    end;
  end;

begin
  RT.NodeDataSize:=SizeOf(TResTreeData);
  CreateRoot;
  RT.FullExpand();
end;

procedure TSrvForm.InitTagTree;

  procedure CreateRoot;
  Var
    Data    : PTagTreeData;
  begin
    TagRoot:=VT.AddChild(nil);
    Data:=VT.GetNodeData(TagRoot);
    if Assigned(Data) then
    begin
      Data.Obj:=TTagNode.Create(ntRoot);
      Data.Obj.Caption:='S7Server';
    end;
  end;

begin
  VT.NodeDataSize:=SizeOf(TTagTreeData);
  CreateRoot;
  VT.FullExpand();
end;

procedure TSrvForm.NewTag(CliTag: TClientTag);
Var
  UID : int64;
  IP  : string;
  Obj : TTagNode;
  CliNode : PVirtualNode;
  TagNode : PVirtualNode;

  function CreateNode : TTagNode;
  begin
    Result:=TTagNode.Create(ntTag);
    Result.UID:=UID;
    Result.Caption:=NewTagName;
    Result.Tag:=CliTag.HMITag;
  end;

  function CreateClient : PVirtualNode;
  Var
    Obj  : TTagNode;
  begin
    Obj:=TTagNode.Create(ntClient);
    Obj.Caption:=IP;
    Result:=VT.AddChild(TagRoot);
    PTagTreeData(VT.GetNodeData(Result)).Obj:=Obj;
  end;

begin
  UID:=TagUID(CliTag.HMITag);
  Obj:=Tags.Find(UID);
  if not Assigned(Obj) then
  begin
    // Get Client
    IP:=ClientIP(CliTag.Client);
    CliNode:=FindClientNode(IP);
    if not Assigned(CliNode) then
      CliNode:=CreateClient;
    // Create New Node Tag
    Obj:=CreateNode;
    TagNode:=VT.AddChild(CliNode);
    PTagTreeData(VT.GetNodeData(TagNode)).Obj:=Obj;
    Tags.Add(Obj);
    UpdateDBList(Obj);
  end;
  Obj.Operation:=CliTag.OpRw; // Tag exists : only access (R or W) update
  if Obj.Changed then
    VT.FullExpand;
end;

function TSrvForm.NewTagName: string;
begin
  inc(TagCount);
  Result:='Tag_'+IntToStr(TagCount);
end;

procedure TSrvForm.ReportMItemClick(Sender: TObject);
begin
  CreateReport;
end;

procedure TSrvForm.RTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
Var
  Obj : TResNode;
begin
  Obj:=GetResObject(Node);
  if Assigned(Obj) then
    Obj.Free;
end;

procedure TSrvForm.RTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var ImageIndex: Integer);
Var
  Obj : TResNode;
begin
  if (Column=0) and (Kind<>ikOverlay) then
  begin
    Obj:=GetResObject(Node);
    if Assigned(Obj) then
      ImageIndex:=Obj.ImageIndex;
  end;
  if Kind=ikOverlay then
    ImageIndex:=0;
end;

procedure TSrvForm.RTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
Var
  Obj : TResNode;
begin
  CellText :='';
  Obj:=GetResObject(Node);
  if Assigned(Obj) then
  begin
    if Column>0 then
    begin
      case Column of
        1 : CellText:=Obj.Size;
      end;
    end
    else
      CellText:=Obj.Caption;
  end;
end;

procedure TSrvForm.RunStop;

  procedure DoStart;
  begin
    if Server.StartTo(LocalAddress)=0 then
    begin
      Clear;
      InitTagTree;
      InitResTree;
      TagCount :=0;
      TimTag.Enabled:=true;
      StartMItem.Caption:='Stop';
      SettingMItem.Enabled:=false;
      Running:=true;
    end;
  end;

  procedure DoStop;
  begin
    Server.Stop;
    StartMItem.Caption:='Start';
    Running:=false;
    TimTag.Enabled:=false;
    SettingMItem.Enabled:=true;
    Queue.Flush;
  end;

begin
  if Running then
    DoStop
  else
    DoStart;
end;

procedure TSrvForm.SetFClientsCount(const Value: integer);
begin
  if FClientsCount <> Value then
  begin
    FClientsCount := Value;
    SB.Panels[1].Text:='Clients connected: '+IntToStr(FClientsCount);
  end;
end;

procedure TSrvForm.SetFLogLevel(const Value: TLogLevel);
begin
  FLogLevel := Value;
  case FLogLevel of
    llBasic   : Server.LogMask:=$000003FF;
    llDetailed: Server.LogMask:=$000603FF;
    llDebug   : Server.LogMask:=$FFFFFFFF;
  end;
end;

procedure TSrvForm.SetFServerStatus(const Value: integer);
begin
  if FServerStatus <> Value then
  begin
    FServerStatus := Value;
    case FServerStatus of
      SrvStopped : SB.Panels[0].Text:='Stopped';
      SrvRunning : SB.Panels[0].Text:='Running on '+LocalAddress;
      SrvError   : SB.Panels[0].Text:='Error';
    end;
  end;
end;

procedure TSrvForm.SettingMItemClick(Sender: TObject);
begin
  LocalAddress:=InputBox('Server settings','IP Listen Address',LocalAddress);
end;

procedure TSrvForm.StartMItemClick(Sender: TObject);
begin
  RunStop;
end;

function TSrvForm.TagUID(Tag: TS7Tag): int64;
Type
  TUID = packed record
    uAddress_wla  : longword; // wlength-area-address
    uDBNumber     : word;
    uElements     : word;
  end;
Var
  UID : TUID absolute Result;
  IAW : longword;
begin
  IAW :=$7F;
  case Tag.Area of
    S7AreaPE : IAW := $10000000;
    S7AreaPA : IAW := $20000000;
    S7AreaMK : IAW := $30000000;
    S7AreaDB : IAW := $40000000;
    S7AreaCT : IAW := $50000000;
    S7AreaTM : IAW := $60000000;
  end;
  case Tag.WordLen of
    S7WLBit      : IAW:=IAW OR $01000000;
    S7WLByte     : IAW:=IAW OR $02000000;
    S7WLChar     : IAW:=IAW OR $03000000;
    S7WLWord     : IAW:=IAW OR $04000000;
    S7WLInt      : IAW:=IAW OR $05000000;
    S7WLDWord    : IAW:=IAW OR $06000000;
    S7WLDInt     : IAW:=IAW OR $07000000;
    S7WLReal     : IAW:=IAW OR $08000000;
    S7WLCounter  : IAW:=IAW OR $09000000;
    S7WLTimer    : IAW:=IAW OR $0A000000;
  end;
  UID.uAddress_wla:=IAW OR Longword(Tag.Start);
  UID.uDBNumber   :=Tag.DBNumber;
  UID.uElements   :=Tag.Elements;
end;

procedure TSrvForm.VTEdited(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);
begin
  Caption:=VT.Text[Node,Column];
end;

procedure TSrvForm.VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed:=Column=0;
end;

procedure TSrvForm.VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
Var
  Obj : TTagNode;
begin
  Obj:=GetTagObject(Node);
  if Assigned(Obj) then
    Obj.Free;
end;

procedure TSrvForm.VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var ImageIndex: Integer);
Var
  Obj : TTagNode;
begin
  if (Column=0) and (Kind<>ikOverlay) then
  begin
    Obj:=GetTagObject(Node);
    if Assigned(Obj) then
      ImageIndex:=Obj.ImageIndex;
  end;
  if Kind=ikOverlay then
    ImageIndex:=0;
end;

procedure TSrvForm.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
Var
  Obj : TTagNode;
begin
  CellText :='';
  Obj:=GetTagObject(Node);
  if Assigned(Obj) then
  begin
    if Column>0 then
    begin
      case Column of
        1 : CellText:=Obj.Access;
        2 : CellText:=Obj.Address;
        3 : CellText:=Obj.TagType;
        4 : CellText:=Obj.Elements;
        5 : CellText:=Obj.Size;
      end;
    end
    else
      CellText:=Obj.Caption;
  end;
end;

procedure TSrvForm.VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; NewText: string);
Var
  Obj : TTagNode;
begin
  Obj:=GetTagObject(Node);
  NewText:=Trim(NewText);
  if Length(NewText)>20 then
    NewText:=Copy(NewText,1,20);
  if (NewText<>'') and Assigned(Obj) and (Obj.NodeType<>ntRoot) then
    Obj.Caption:=NewText;
end;

procedure TSrvForm.TimLogTimer(Sender: TObject);
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

procedure TSrvForm.TimTagTimer(Sender: TObject);
Var
  CliTag : TClientTag;
begin
  while not Queue.Empty do
  begin
    Queue.Extract(@CliTag);
    NewTag(CliTag);
  end;
end;

procedure TSrvForm.UpdateDBList(Obj : TTagNode);
Var
  DBName : string;
  DBIdx  : integer;
  DB     : TResNode;
  DBNode : PVirtualNode;

  procedure NewDB;
  begin
    DB:=TResNode.Create(ntDB);
    DB.Caption:=DBName;
    DB.SizeNeeded:=Obj.TagLimit;
    DBNode:=RT.AddChild(ResRoot);
    PResTreeData(RT.GetNodeData(DBNode)).Obj:=DB;
    DBList.AddObject(DBName,DB);
  end;

begin
  if Obj.Tag.Area=S7AreaDB then
  begin
    DBName:='DB '+IntToStr(Obj.Tag.DBNumber);
    DBIdx:=DBList.IndexOf(DBName);
    if DBIdx>=0 then
    begin
      DB:=TResNode(DBList.Objects[DBIdx]);
      if DB.SizeNeeded<Obj.TagLimit then
        DB.SizeNeeded:=Obj.TagLimit;
    end
    else
      NewDB;
    if DB.Changed then
      RT.FullExpand;
  end;
end;

end.

