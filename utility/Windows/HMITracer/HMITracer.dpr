program HMITracer;

uses
  FastMM4,
  Vcl.Forms,
  frmMain in 'frmMain.pas' {SrvForm},
  frmReport in 'frmReport.pas' {ReportForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSrvForm, SrvForm);
  Application.Run;
end.
