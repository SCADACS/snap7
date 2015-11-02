unit frmReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ComCtrls, ToolWin,
  ImgList, ExtCtrls, mORMotReport;

type
  TReportForm = class(TForm)
    BtnImages: TImageList;
    ToolBar1: TToolBar;
    SaveBtn: TToolButton;
    PrintBtn: TToolButton;
    CancelBtn: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Pages : TGDIPages;
  end;

var
  ReportForm: TReportForm;

implementation

{$R *.dfm}

procedure TReportForm.CancelBtnClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TReportForm.FormShow(Sender: TObject);
begin
  Pages.Zoom:=PAGE_FIT;
end;

procedure TReportForm.PrintBtnClick(Sender: TObject);
begin
  if Assigned(Pages) then
  try
    Pages.PrintPages(-1,-1);
  except
  end;
  ModalResult:=mrOk;
end;

procedure TReportForm.SaveBtnClick(Sender: TObject);
begin
  if Assigned(Pages) then
  try
    Pages.ExportPDF('',true,true);
  except
  end;
end;

end.
