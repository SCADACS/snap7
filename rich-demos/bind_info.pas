unit bind_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Arrow,
  StdCtrls;

type

  { TBindErrortInfo }

  TBindErrortInfo = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  BindErrortInfo: TBindErrortInfo;

implementation

{$R *.lfm}

{ TBindErrortInfo }

procedure TBindErrortInfo.Memo1Change(Sender: TObject);
begin

end;

end.

