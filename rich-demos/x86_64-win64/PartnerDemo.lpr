program PartnerDemo;

{$MODE Delphi}

uses
  Forms, Interfaces,
  MainPartner in 'MainPartner.pas' {Form1},
  frmPartner in 'frmPartner.pas' {PartnerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
