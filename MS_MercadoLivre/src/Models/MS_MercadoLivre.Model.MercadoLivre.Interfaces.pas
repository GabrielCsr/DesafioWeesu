unit MS_MercadoLivre.Model.MercadoLivre.Interfaces;

interface

uses
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces;

type
  IMercadoLivre = interface
    function Produtos(AIniciarConsumoFila: Boolean = False): IProdutosMercadoLivre;
  end;

implementation

end.
