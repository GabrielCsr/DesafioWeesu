unit MS_MercadoLivre.Model.MercadoLivre.Produtos.Classes;

interface

uses
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces,
  MS_MercadoLivre.Model.Entity.Produto.Classes, RabbitMQ.Interfaces;

type
  TProdutosMercadoLivre = class(TInterfacedObject, IProdutosMercadoLivre)
  const
    FILA     = 'queue_mlb_produtos';
    EXCHANGE = 'desafio';
  var
    FRabbitMQ: IRabbitMQ;
  private
    procedure MensagemConsumida(AMensagem: String);
    procedure Configurar;
  public
    constructor Create(AIniciarConsumoFila: Boolean = False);
    class function New(AIniciarConsumoFila: Boolean = False): IProdutosMercadoLivre;
    procedure Salvar(AProduto: TProduto);
    procedure ConsumirFila;
    procedure InterromperConsumo;
    function ConsumindoFila: Boolean;
  end;

implementation

uses
  RabbitMQ.AMQP.Classes,
  MS_MercadoLivre.Service.MercadoLivre.Produtos.Classes,
  RabbitMQ.Stomp.Classes, RabbitMQ.Singleton.Classes;

{ TProdutosMercadoLivre }

procedure TProdutosMercadoLivre.Configurar;
begin
  TRabbitMQ
    .New
    .Fila(FILA)
    .Exchange(EXCHANGE)
    .RoutingKey(EXCHANGE + '.' + FILA)
    .CriarFila
    .CriarExchange
    .Bind;
end;

function TProdutosMercadoLivre.ConsumindoFila: Boolean;
begin
  Result := FRabbitMQ.ConsumindoFila;
end;

procedure TProdutosMercadoLivre.ConsumirFila;
begin
  FRabbitMQ
  .Fila(FILA)
  .ConsumirFilaThread(MensagemConsumida);
end;

constructor TProdutosMercadoLivre.Create(AIniciarConsumoFila: Boolean = False);
begin
  FRabbitMQ := TRabbitMQSingleton.Instancia;
  if AIniciarConsumoFila then
    FRabbitMQ.Fila(FILA).ConsumirFilaThread(MensagemConsumida);
  Configurar;
end;

procedure TProdutosMercadoLivre.InterromperConsumo;
begin
  FRabbitMQ.InterromperConsumoFila;
end;

procedure TProdutosMercadoLivre.MensagemConsumida(AMensagem: String);
begin
  Salvar(TProduto.FromJSON(AMensagem));
end;

class function TProdutosMercadoLivre.New(AIniciarConsumoFila: Boolean = False): IProdutosMercadoLivre;
begin
  Result := Self.Create(AIniciarConsumoFila);
end;

procedure TProdutosMercadoLivre.Salvar(AProduto: TProduto);
begin
  TServiceProdutos.Salvar(AProduto);
end;

end.
