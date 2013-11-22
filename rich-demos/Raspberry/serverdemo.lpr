program serverdemo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  MainServer;
  { you can add units after this }

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmServer, FrmServer);
  Application.Run;
end.
