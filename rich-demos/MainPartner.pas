unit MainPartner;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Grids, frmPartner, Menus,
  Snap7;

type

  { TForm1 }

  TForm1 = class(TForm)
    NewActiveBtn: TButton;
    NewPassiveBtn: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure NewActiveBtnClick(Sender: TObject);
    procedure NewPassiveBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.Exit1Click(Sender: TObject);
begin
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

procedure TForm1.NewActiveBtnClick(Sender: TObject);
begin
  TPartnerForm.Create(Application).CreatePartner(_Active);
end;

procedure TForm1.NewPassiveBtnClick(Sender: TObject);
begin
  TPartnerForm.Create(Application).CreatePartner(_Passive);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var
  Count : integer;
begin
//Count:=Par_PartnersCount;
//  StatusBar.Panels[0].Text:='Partners : '+IntToStr(Count);
end;

end.