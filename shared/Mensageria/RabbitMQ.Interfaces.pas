unit RabbitMQ.Interfaces;

interface

type
  TNotify = procedure(AMensagem: String) of Object;

  IRabbitMQ = interface
      ['{7F42C007-2087-493D-87BF-B27A4971CBA9}']
      function Fila(ANomeFila: String): IRabbitMQ; overload;
      function Fila: String; overload;
      function Mensagem(AMensagem: String): IRabbitMQ; overload;
      function Mensagem: String; overload;
      function Exchange(ANomeExchange: String): IRabbitMQ; overload;
      function Exchange: String; overload;
      function RoutingKey(ARoutingKey: String): IRabbitMQ; overload;
      function RoutingKey: String; overload;
      function CriarFila: IRabbitMQ;
      function CriarExchange: IRabbitMQ;
      function Bind: IRabbitMQ;
      function EnviarMensagem: IRabbitMQ;
      function EnviarMensagemAssincrona: IRabbitMQ;
      function ConsumirFila: String;
      procedure ConsumirFilaThread(AProcedureNotify: TNotify);
      procedure InterromperConsumoFila;
      function OnReceiveMessage(AProcedureNotify: TNotify): IRabbitMQ;
      function ConsumindoFila: Boolean;
    end;

implementation

end.
