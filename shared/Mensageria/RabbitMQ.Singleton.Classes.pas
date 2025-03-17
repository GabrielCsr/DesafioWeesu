unit RabbitMQ.Singleton.Classes;

interface

uses
  RabbitMQ.Interfaces;

type
  TRabbitMQSingleton = class
  private
    class var FInstancia: IRabbitMQ;
  public
    class function Instancia: IRabbitMQ;
  end;

implementation

uses
  Conexao.Factory.Classes, SysUtils, RabbitMQ.Factory.Classes;

{ TConexaoSingleton }

class function TRabbitMQSingleton.Instancia: IRabbitMQ;
begin
  try
    if not Assigned(FInstancia) then
      FInstancia := TFactoryRabbitMQ.RabbitMQ(tpSTOMP);

    Result := FInstancia;
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

end.
