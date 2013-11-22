program clientdemo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  mainclient,
  sc_info;
  { you can add units after this }

{$R *.res}

begin
//  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFormClient, FormClient);
  Application.CreateForm(TSmartConnectInfo, SmartConnectInfo);
  Application.Run;
end.
