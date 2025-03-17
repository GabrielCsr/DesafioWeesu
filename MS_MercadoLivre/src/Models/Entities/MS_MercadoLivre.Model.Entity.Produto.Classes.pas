unit MS_MercadoLivre.Model.Entity.Produto.Classes;

interface

type
  TProduto = class
  private
    FSKU: String;
    FNome: String;
    FPreco: Double;
    FURLImagem: String;
  public
    constructor Create;
    property SKU: String read FSKU write FSKU;
    property Nome: String read FNome write FNome;
    property Preco: Double read FPreco write FPreco;
    property UrlImagem: String read FURLImagem write FURLImagem;
    class function FromJSON(AJSON: String): TProduto;
  end;

implementation

uses
  SysUtils, JSON;

{ TProduto }

constructor TProduto.Create;
begin
  FSKU   := EmptyStr;
  FNome  := EmptyStr;
  FPreco := 0.00;
end;

class function TProduto.FromJSON(AJSON: String): TProduto;
begin
  Result := TProduto.Create;
  var LJSONProduto := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
  try
    try
      if Assigned(LJSONProduto) then
      begin
        Result.SKU        := LJSONProduto.GetValue<string>('id', '');
        Result.Nome       := LJSONProduto.GetValue<string>('nome', '');
        Result.Preco      := LJSONProduto.GetValue<Double>('preco', 0.00);
        Result.UrlImagem  := LJSONProduto.GetValue<string>('url_imagem', '');
      end;
    except
      On E: Exception do
        raise Exception.Create(E.Message);
    end;
  finally
    if Assigned(LJSONProduto) then
      FreeAndNil(LJSONProduto);
  end;
end;

end.
