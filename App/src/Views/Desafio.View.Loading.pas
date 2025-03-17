unit Desafio.View.Loading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.Skia, FMX.Objects, FMX.Layouts;

type
  TfrmLoading = class(TForm)
    Rectangle1: TRectangle;
    SkAnimatedImage1: TSkAnimatedImage;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    lblTexto: TSkLabel;
    SkAnimatedImage2: TSkAnimatedImage;
    Layout4: TLayout;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FPodeFechar: Boolean;
  public
    procedure ShowLoading;
    procedure HideLoading;
    procedure AlterarTexto(ATexto: String);
  end;

var
  frmLoading: TfrmLoading;

implementation

{$R *.fmx}

procedure TfrmLoading.ShowLoading;
var
  LParentForm: TForm;
begin
  LParentForm := TForm(Application.MainForm);

  Self.Width := LParentForm.Width;
  Self.Height := LParentForm.Height;
  Self.Left := LParentForm.Left;
  Self.Top := LParentForm.Top;
  Self.SetBounds(LParentForm.Bounds.Left + 8, LParentForm.Bounds.Top + 1, LParentForm.Width - 16, LParentForm.Height - 8);


  Self.ShowModal;
  Self.BringToFront;
end;

procedure TfrmLoading.AlterarTexto(ATexto: String);
begin
  lblTexto.Text := ATexto;
  Application.ProcessMessages;
end;

procedure TfrmLoading.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FPodeFechar;
end;

procedure TfrmLoading.FormCreate(Sender: TObject);
begin
  FPodeFechar := False;
end;

procedure TFrmLoading.HideLoading;
begin
  FPodeFechar := True;
  Self.Close;
end;

end.
