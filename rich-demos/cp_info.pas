unit cp_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Arrow,
  StdCtrls;

type

  { TParamsConnectInfo }

  TParamsConnectInfo = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ParamsConnectInfo: TParamsConnectInfo;

implementation

{$R *.lfm}

{ TParamsConnectInfo }

procedure TParamsConnectInfo.Memo1Change(Sender: TObject);
begin

end;

end.

