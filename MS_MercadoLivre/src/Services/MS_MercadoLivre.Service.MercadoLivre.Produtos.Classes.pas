unit MS_MercadoLivre.Service.MercadoLivre.Produtos.Classes;

interface

uses
  MS_MercadoLivre.Model.Entity.Produto.Classes, Conexao.Singleton.Classes,
  System.Threading, FireDAC.Stan.Async, FireDAC.Stan.Param, System.Classes;

type
  TServiceProdutos = class
  public
    class procedure Salvar(AProduto: TProduto);
  end;

implementation

uses
  SysUtils, FireDAC.Comp.Client, Conexao.Utils.Classes;

{ TServiceProdutos }

class procedure TServiceProdutos.Salvar(AProduto: TProduto);
var
  LQuery: TFDQuery;
  LConexaoUtils: TConexaoUtils;
begin
  LConexaoUtils := TConexaoUtils.Create;
  try
    LQuery := LConexaoUtils.CriarQuery;
    LQuery.SQL.Add('REPLACE INTO produtos (sku, nome, preco, url_imagem) VALUES (:sku, :nome, :preco, :url_imagem)');
    LQuery.Params[0].AsString := AProduto.SKU;
    LQuery.Params[1].AsString := AProduto.Nome;
    LQuery.Params[2].AsFloat  := AProduto.Preco;
    LQuery.Params[3].AsString := AProduto.URLImagem;
    LQuery.ExecSQL;
  finally
    FreeAndNil(LConexaoUtils);
    FreeAndNil(LQuery);
  end;
end;

end.
