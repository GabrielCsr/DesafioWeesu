unit Desafio.View.MercadoLivre;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, System.Skia, System.Math.Vectors, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, FMX.Edit, FMX.Skia, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Controls3D, FMX.Layers3D,
  Desafio.Controller.MercadoLivre.Classes, System.ImageList, FMX.ImgList;

type
  TfrmMercadoLivre = class(TForm)
    layConteudo: TLayout;
    Rectangle1: TRectangle;
    layHeader: TLayout;
    SkLabel1: TSkLabel;
    Layout3D1: TLayout3D;
    Layout1: TLayout;
    layPesquisa: TLayout;
    SkLabel2: TSkLabel;
    layLabel: TLayout;
    layBusca: TLayout;
    recPalavraChave: TRectangle;
    edtPalavraChave: TEdit;
    layButtonBuscar: TLayout;
    recBuscar: TRectangle;
    lblBuscar: TSkLabel;
    gridProdutos: TStringGrid;
    Layout3: TLayout;
    Layout5: TLayout;
    btnFechar: TSpeedButton;
    imgFechar: TSkSvg;
    StyleBook1: TStyleBook;
    ImageList: TImageList;
    colImagem: TGlyphColumn;
    colSKU: TStringColumn;
    colNome: TStringColumn;
    colPreco: TStringColumn;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure recBuscarClick(Sender: TObject);
    procedure gridProdutosEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure gridProdutosCellClick(const Column: TColumn; const Row: Integer);
    procedure gridProdutosSelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    FController: IControllerMercadoLivre;
    procedure Fechar;
  public
    class procedure IniciarMercadoLivre(AOwner: TComponent;
                                        AParent: TFMXObject;
                                        AAlign: TAlignLayout = TAlignLayout.Client);
  end;

var
  frmMercadoLivre: TfrmMercadoLivre;

implementation

{$R *.fmx}

{ TForm1 }

procedure TfrmMercadoLivre.btnFecharClick(Sender: TObject);
begin
  Fechar;
end;

procedure TfrmMercadoLivre.Fechar;
begin
  layConteudo.parent := nil;
  Self.Close;
end;

procedure TfrmMercadoLivre.FormCreate(Sender: TObject);
begin
  FController := TControllerMercadoLivre.New(gridProdutos);
end;

procedure TfrmMercadoLivre.gridProdutosCellClick(const Column: TColumn;
  const Row: Integer);
begin
  if Column.Index in [0, 1] then
    Exit;

  inherited;
end;

procedure TfrmMercadoLivre.gridProdutosEditingDone(Sender: TObject; const ACol,
  ARow: Integer);
begin
  FController.SalvarAlteracao(ARow);
end;

procedure TfrmMercadoLivre.gridProdutosSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ACol in [0,1] then
    CanSelect := False
  else
    CanSelect := True;
end;

class procedure TfrmMercadoLivre.IniciarMercadoLivre(AOwner: TComponent;
  AParent: TFMXObject; AAlign: TAlignLayout);
var
  LRotina: TFrmMercadoLivre;
begin
  LRotina := TFrmMercadoLivre.Create(AOwner);
  LRotina.layConteudo.Parent := AParent;
  LRotina.layConteudo.Align := AAlign;
end;

procedure TfrmMercadoLivre.recBuscarClick(Sender: TObject);
begin
  FController.Buscar(edtPalavraChave.Text);
end;

end.
