unit MS_MercadoLivre.Model.MercadoLivre.Classes;

interface

uses
  MS_MercadoLivre.Model.MercadoLivre.Interfaces,
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces,
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Classes;

type
  TMercadoLivre = class(TInterfacedObject, IMercadoLivre)
    private
    public
      constructor Create;
      class function New: IMercadoLivre;
      function Produtos(AIniciarConsumoFila: Boolean = False): IProdutosMercadoLivre;
    end;

implementation

{ TMercadoLivre }

constructor TMercadoLivre.Create;
begin

end;

class function TMercadoLivre.New: IMercadoLivre;
begin
  Result := Self.Create;
end;

function TMercadoLivre.Produtos(AIniciarConsumoFila: Boolean = False): IProdutosMercadoLivre;
begin
  Result := TProdutosMercadoLivre.New(AIniciarConsumoFila);
end;

end.
