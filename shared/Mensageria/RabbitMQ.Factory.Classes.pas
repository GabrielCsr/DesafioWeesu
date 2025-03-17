unit RabbitMQ.Factory.Classes;

interface

uses
  RabbitMQ.Interfaces;

type
  TProtocoloConexaoRabbitMQ = (tpAMQP, tpSTOMP);

  TFactoryRabbitMQ = class
    class function RabbitMQ(AProtocoloConexao: TProtocoloConexaoRabbitMQ): IRabbitMQ;
  end;

implementation

uses
  RabbitMQ.AMQP.Classes, RabbitMQ.Stomp.Classes;

{ TFactoryRabbitMQ }

class function TFactoryRabbitMQ.RabbitMQ(AProtocoloConexao: TProtocoloConexaoRabbitMQ): IRabbitMQ;
begin
  case AProtocoloConexao of
    tpAMQP:  Result := TRabbitMQ.New;
    tpSTOMP: Result := TRabbitMQStomp.New;
  end;
end;

end.
