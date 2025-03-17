unit Desafio.Model.Entity.MercadoLivre.Produto.Classes;

interface

uses
  System.Generics.Collections, System.JSON, Rest.Json, SysUtils, FMX.Graphics,
  System.Classes;

type
  TProdutoMercadoLivre = class
  private
    FImagem: TMemoryStream;
    FId: string;
    FNome: string;
    FPreco: Double;
    FImagemURL: string;
  public
    destructor Destroy; override;
    property Imagem: TMemoryStream read FImagem write FImagem;
    property Id: string read FId write FId;
    property Nome: string read FNome write FNome;
    property Preco: Double read FPreco write FPreco;
    property ImagemURL: string read FImagemURL write FImagemURL;
    function ToJSON: TJSONObject;
  end;

  TListaProdutos = class
  private
    FProdutos: TList<TProdutoMercadoLivre>;
  public
    constructor Create;
    destructor Destroy; override;
    property Produtos: TList<TProdutoMercadoLivre> read FProdutos write FProdutos;
    procedure FromJSON(const AJson: string);
    procedure LiberarLista;
  end;

implementation

{ TListaProdutos }

procedure TListaProdutos.FromJSON(const AJson: string);
var
  LJSON: TJSONObject;
  LResults: TJSONArray;
begin
  LJSON := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  try
    if Assigned(LJSON) and LJSON.TryGetValue<TJSONArray>('results', LResults) then
    begin
      for var I := 0 to Pred(LResults.Count) do
      begin
        FProdutos.Add(TProdutoMercadoLivre.Create);
        FProdutos.Last.Id        := LResults.Items[I].GetValue<string>('id', '');
        FProdutos.Last.Nome      := LResults.Items[I].GetValue<string>('title', '');
        FProdutos.Last.Preco     := LResults.Items[I].GetValue<Double>('price', 0);
        FProdutos.Last.ImagemURL := LResults.Items[I].GetValue<string>('thumbnail', '');
      end;
    end;
  finally
    FreeAndNil(LJSON);
  end;
end;

constructor TListaProdutos.Create;
begin
  FProdutos := TList<TProdutoMercadoLivre>.Create;
end;

destructor TListaProdutos.Destroy;
begin
  LiberarLista;
  inherited;
end;

procedure TListaProdutos.LiberarLista;
var
  LItem: TProdutoMercadoLivre;
begin
  if Assigned(FProdutos) then
  begin
    for LItem in FProdutos do
      LItem.Free;

    FProdutos.Clear;
    FreeAndNil(FProdutos);
  end;
end;

{ TProdutoMercadoLivre }

destructor TProdutoMercadoLivre.Destroy;
begin
  if Assigned(FImagem) then
    FImagem.Free;
  inherited;
end;

function TProdutoMercadoLivre.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FId);
  Result.AddPair('nome', FNome);
  Result.AddPair('preco', FPreco);
  Result.AddPair('url_imagem', FImagemURL);
end;

end.
