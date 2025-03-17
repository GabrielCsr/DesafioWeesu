unit MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces;

interface

uses
  MS_MercadoLivre.Model.Entity.Produto.Classes;

type
  IProdutosMercadoLivre = interface
    procedure Salvar(AProduto: TProduto);
    procedure ConsumirFila;
    procedure InterromperConsumo;
    function ConsumindoFila: Boolean;
  end;

implementation

end.
