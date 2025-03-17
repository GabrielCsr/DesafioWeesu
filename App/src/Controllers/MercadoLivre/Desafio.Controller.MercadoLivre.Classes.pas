unit Desafio.Controller.MercadoLivre.Classes;

interface

uses
  Desafio.Model.MercadoLivre.Classes, FMX.Grid, FMX.Types,
  System.Generics.Collections, FMX.Graphics, FMX.ImgList, Desafio.View.Loading;

type
  IControllerMercadoLivre = interface
    ['{B2EA85D7-A10D-4BFC-893A-233241D64A06}']
    procedure Buscar(APalavraChave: String);
    function Imagens: TList<TBitMap>;
    procedure SalvarAlteracao(ALinha: Integer);
  end;

  TControllerMercadoLivre = class(TInterfacedObject, IControllerMercadoLivre)
  private
    FModel: IMercadoLivre;
    FGrid: TStringGrid;
    FImagens: TList<TBitMap>;
    procedure CarregarProdutos(ALoading: TFrmLoading);
    procedure AdicionarImagem(APosicao: Integer);
  public
    constructor Create(AGrid: TStringGrid);
    destructor Destroy; override;
    class function New(AGrid: TStringGrid): IControllerMercadoLivre;
    procedure Buscar(APalavraChave: String);
    function Imagens: TList<TBitMap>;
    procedure SalvarAlteracao(ALinha: Integer);
  end;

implementation

uses
  Desafio.Model.Entity.MercadoLivre.Produto.Classes, SysUtils, System.Classes,
  FMX.Dialogs;

{ TControllerMercadoLivre }

procedure TControllerMercadoLivre.Buscar(APalavraChave: String);
var
  LLoading: TFrmLoading;
begin
  LLoading := TFrmLoading.Create(nil);

  TThread.CreateAnonymousThread(procedure
  begin
    try
      if FModel.Buscar(APalavraChave) then
      begin
        TThread.Synchronize(nil, procedure
        begin
          CarregarProdutos(LLoading);
        end);
      end;
    finally
      TThread.Synchronize(nil, procedure
      begin
        LLoading.HideLoading;
      end);
    end;
  end).Start;

  LLoading.AlterarTexto('Buscando Produtos');
  LLoading.ShowLoading;
  FreeAndNil(LLoading);
end;

procedure TControllerMercadoLivre.CarregarProdutos(ALoading: TFrmLoading);
var
  LFeitos: Integer;
begin
  try
    FGrid.RowCount := 0;
    FGrid.RowCount := FModel.Produtos.Count;
    FGrid.Images.Source.Clear;
    FGrid.Images.Destination.Clear;
    LFeitos := 0;

    for var I := 0 to Pred(FModel.Produtos.Count) do
    begin
      AdicionarImagem(I);
      FGrid.Cells[0, I] := I.ToString;
      FGrid.Cells[1, I] := FModel.Produtos[I].Id;
      FGrid.Cells[2, I] := FModel.Produtos[I].Nome;
      FGrid.Cells[3, I] := FormatFloat('R$ ###,##0.00', FModel.Produtos[I].Preco);
      Inc(LFeitos);
      ALoading.AlterarTexto('Listando Produtos ' + FloatToStr(Trunc((LFeitos * 100)/FModel.Produtos.Count)) + '%');
    end;
  except
    On E: Exception do
      raise Exception.Create('Ocorreram problemas ao carregar os produtos no grid. ' + E.Message);
  end;
end;

procedure TControllerMercadoLivre.AdicionarImagem(APosicao: Integer);
begin
  FGrid.Images.Source.Add;
  FGrid.Images.Source[APosicao].MultiResBitmap.Add;

  FGrid.Images.Destination.Add;
  FGrid.Images.Destination[APosicao].Layers.Add;

  if Assigned(FModel.Produtos[APosicao].Imagem) then
  begin
    FGrid.Images.Source[APosicao].MultiResBitmap[0].Bitmap.LoadFromStream(FModel.Produtos[APosicao].Imagem);

    FGrid.Images.Destination[APosicao].Layers[0].Name := FGrid.Images.Source[APosicao].Name;

    FGrid.Images.Destination[APosicao].Layers[0].SourceRect.Rect :=
      FGrid.Images.Source[APosicao].MultiResBitmap[0].Bitmap.Bounds;
  end;
end;

constructor TControllerMercadoLivre.Create(AGrid: TStringGrid);
begin
  FGrid := AGrid;
  FModel := TMercadoLivre.New;
  FImagens := TList<TBitMap>.Create;
end;

destructor TControllerMercadoLivre.Destroy;
begin
  FreeAndNil(FImagens);
  inherited;
end;

function TControllerMercadoLivre.Imagens: TList<TBitMap>;
begin
  Result := FImagens;
end;

class function TControllerMercadoLivre.New(AGrid: TStringGrid): IControllerMercadoLivre;
begin
  Result := Self.Create(AGrid);
end;

procedure TControllerMercadoLivre.SalvarAlteracao(ALinha: Integer);
var
  LPreco: Double;
  LPrecoFormatado: String;
begin
  LPrecoFormatado := StringReplace(FGrid.Cells[3, ALinha], 'R$ ', '', [rfReplaceAll]);

  if not (TryStrToFloat(LPrecoFormatado, LPreco)) then
  begin
    ShowMessage('Informe um preço valido!');
    Exit;
  end;

  FModel.Produtos[ALinha].Nome  := FGrid.Cells[2, ALinha];
  FModel.Produtos[ALinha].Preco := StrToFloat(FormatFloat('0.00', LPreco));
  FModel.SalvarProduto(FModel.Produtos[ALinha]);
end;

end.
