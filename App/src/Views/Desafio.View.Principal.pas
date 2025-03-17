unit Desafio.View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.Skia, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Intf, FireDAC.Comp.UI;

type
  TfrmPrincipal = class(TForm)
    layBackGround: TLayout;
    recBackGround: TRectangle;
    layBarraLateral: TLayout;
    recBarraLateral: TRectangle;
    layLogo: TLayout;
    SkSvg1: TSkSvg;
    layRotinas: TLayout;
    layRotinaMercadoLivre: TLayout;
    SkSvg2: TSkSvg;
    SkLabel1: TSkLabel;
    btnRotinaMercadoLivre: TSpeedButton;
    layConfiguracoes: TLayout;
    btnConfiguracoes: TSpeedButton;
    SkLabel2: TSkLabel;
    SkSvg3: TSkSvg;
    layForms: TLayout;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure btnRotinaMercadoLivreClick(Sender: TObject);
  private
    procedure RemoverFormulario;
    procedure AbrirConfiguracoes;
    procedure AbrirMercadoLivre;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses Desafio.View.Configuracoes, Desafio.View.MercadoLivre,
  Desafio.View.Loading;

procedure TfrmPrincipal.AbrirConfiguracoes;
begin
  RemoverFormulario;
  TfrmConfiguracoes.IniciarConfiguracoes(Self, layForms);
end;

procedure TfrmPrincipal.AbrirMercadoLivre;
begin
  RemoverFormulario;
  TFrmMercadoLivre.IniciarMercadoLivre(Self, layForms);
end;

procedure TfrmPrincipal.btnConfiguracoesClick(Sender: TObject);
begin
  AbrirConfiguracoes;
end;

procedure TfrmPrincipal.btnRotinaMercadoLivreClick(Sender: TObject);
begin
  AbrirMercadoLivre;
end;

procedure TfrmPrincipal.RemoverFormulario;
begin
  for var I := layForms.ChildrenCount - 1 downto 0 do
  begin
    layForms.Children[i].Free;
  end;
end;



end.
