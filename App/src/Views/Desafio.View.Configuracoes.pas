unit Desafio.View.Configuracoes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Skia, FMX.Objects,
  FMX.Layouts, Desafio.Controller.Configuracoes.Classes, System.Generics.Collections,
  System.Math.Vectors, FMX.Controls3D, FMX.Layers3D;

type
  TfrmConfiguracoes = class(TForm)
    layConteudo: TLayout;
    layHeader: TLayout;
    recBackGround: TRectangle;
    SkLabel1: TSkLabel;
    layConfiguracoes: TLayout;
    Rectangle1: TRectangle;
    layCampos: TLayout;
    Layout1: TLayout;
    Rectangle2: TRectangle;
    edtIdAplicacao: TEdit;
    lblIdAplicacao: TSkLabel;
    Layout2: TLayout;
    Rectangle3: TRectangle;
    edtChaveSecreta: TEdit;
    lblChaveSecreta: TSkLabel;
    Layout3: TLayout;
    Rectangle4: TRectangle;
    edtUriRedirect: TEdit;
    lblUriRedirect: TSkLabel;
    Layout4: TLayout;
    Rectangle5: TRectangle;
    edtCode: TEdit;
    lblCode: TSkLabel;
    layButtons: TLayout;
    btnGerarCode: TSpeedButton;
    Rectangle6: TRectangle;
    SkLabel6: TSkLabel;
    btnSalvar: TSpeedButton;
    Rectangle7: TRectangle;
    SkLabel7: TSkLabel;
    Layout3D1: TLayout3D;
    Layout5: TLayout;
    Layout6: TLayout;
    btnFechar: TSpeedButton;
    imgFechar: TSkSvg;
    Layout7: TLayout;
    SkLabel2: TSkLabel;
    btnPassoAPasso: TSkSvg;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnGerarCodeClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPassoAPassoClick(Sender: TObject);
  private
    { Private declarations }
    FController: IControllerConfiguracoes;
    procedure GerarCode;
    procedure Salvar;
    procedure FecharRotina;
    procedure PreencherConfiguracoes;
    procedure CarregarValores;
  public
    class procedure IniciarConfiguracoes(AOwner: TComponent;
                                         AParent: TFMXObject;
                                         AAlign: TAlignLayout = TAlignLayout.Client);
  end;

var
  frmConfiguracoes: TfrmConfiguracoes;

implementation

uses
  Desafio.Controller.Exceptions.Classes, Winapi.ShellAPI, Winapi.Windows;

{$R *.fmx}

{ TfrmConfiguracoes }

procedure TfrmConfiguracoes.btnFecharClick(Sender: TObject);
begin
  FecharRotina;
end;

procedure TfrmConfiguracoes.btnGerarCodeClick(Sender: TObject);
begin
  GerarCode;
end;

procedure TfrmConfiguracoes.btnPassoAPassoClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://developers.mercadolivre.com.br/pt_br/crie-uma-aplicacao-no-mercado-livre'), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmConfiguracoes.btnSalvarClick(Sender: TObject);
begin
  Salvar;
end;

procedure TfrmConfiguracoes.CarregarValores;
begin
  FController.ConsultarConfiguracoes;
  edtIdAplicacao.Text  := FController.IDAplicacao;
  edtChaveSecreta.Text := FController.ChaveSecreta;
  edtUriRedirect.Text  := FController.URIRedirect;
  edtCode.Text         := FController.Code;
end;

procedure TfrmConfiguracoes.PreencherConfiguracoes;
begin
  FController
    .IDAplicacao(edtIdAplicacao.Text)
    .ChaveSecreta(edtChaveSecreta.Text)
    .URIRedirect(edtUriRedirect.Text)
    .Code(edtCode.Text);
end;
procedure TfrmConfiguracoes.FecharRotina;
begin
  layConteudo.parent := nil;
  Self.Close;
end;

procedure TfrmConfiguracoes.FormCreate(Sender: TObject);
begin
  FController := TControllerConfiguracoes.New(Self);
  CarregarValores;
end;

procedure TfrmConfiguracoes.FormShow(Sender: TObject);
begin
  CarregarValores;
end;

procedure TfrmConfiguracoes.GerarCode;
begin
  PreencherConfiguracoes;
  FController.GerarCode;
end;

class procedure TfrmConfiguracoes.IniciarConfiguracoes(AOwner: TComponent;
  AParent: TFMXObject; AAlign: TAlignLayout);
var
  LRotina: TfrmConfiguracoes;
begin
  LRotina := TfrmConfiguracoes.Create(AOwner);
  LRotina.layConteudo.Parent := AParent;
  LRotina.layConteudo.Align := AAlign;
end;

procedure TfrmConfiguracoes.Salvar;
begin
  PreencherConfiguracoes;
  if FController.SalvarConfiguracoes then
    FecharRotina;
end;

end.
