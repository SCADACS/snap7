unit sc_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Arrow,
  StdCtrls;

type

  { TSmartConnectInfo }

  TSmartConnectInfo = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SmartConnectInfo: TSmartConnectInfo;

implementation

{$R *.lfm}

{ TSmartConnectInfo }

procedure TSmartConnectInfo.Memo1Change(Sender: TObject);
begin

end;

end.

