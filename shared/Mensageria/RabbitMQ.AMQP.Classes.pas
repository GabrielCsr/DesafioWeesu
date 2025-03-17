unit RabbitMQ.AMQP.Classes;

interface

uses
  RabbitMQ.Interfaces, AMQP.Connection, AMQP.Interfaces, AMQP.Classes,
  AMQP.Message, AMQP.StreamHelper, AMQP.Arguments, AMQP.IMessageProperties,
  AMQP.MessageProperties, AMQP.Types, SysUtils, System.Threading,
  System.Classes;

type
  TConsumerThread = Class(TThread)
  Strict Private
    FQueue: TAMQPMessageQueue;
    FOnMessageReceive: TNotify;
    FForcedInterrupt: Boolean;
  Protected
    procedure Execute; Override;
    constructor Create(AQueue: TAMQPMessageQueue; AProcedureNotify: TNotify); Reintroduce;
    procedure OnMessageReceive(AProcedureNotify: TNotify);
    procedure ForceInterrupt;
  End;

  TRabbitMQ = class(TInterfacedObject, IRabbitMQ)
  private
    FConnection: TAMQPConnection;
    FChannel: IAMQPChannel;
    FFila: String;
    FMensagem: String;
    FExchange: String;
    FRoutingKey: String;
    FThread: TConsumerThread;
    FOnReceiveMessage: TNotify;
    FInterromperConsumo: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IRabbitMQ;
    function Fila(ANomeFila: String): IRabbitMQ; overload;
    function Fila: String; overload;
    function Mensagem(AMensagem: String): IRabbitMQ; overload;
    function Mensagem: String; overload;
    function RoutingKey(ARoutingKey: String): IRabbitMQ; overload;
    function RoutingKey: String; overload;
    function Exchange(ANomeExchange: String): IRabbitMQ; overload;
    function Exchange: String; overload;
    function CriarFila: IRabbitMQ;
    function CriarExchange: IRabbitMQ;
    function Bind: IRabbitMQ;
    function EnviarMensagem: IRabbitMQ;
    function EnviarMensagemAssincrona: IRabbitMQ;
    function ConsumirFila: String;
    procedure ConsumirFilaThread(AProcedureNotify: TNotify);
    procedure InterromperConsumoFila;
    procedure Conectar;
    function OnReceiveMessage(AProcedureNotify: TNotify): IRabbitMQ;
    function ConsumindoFila: Boolean;
  end;


implementation

uses
  StrUtils;

{ TRabbitMQ }

function TRabbitMQ.Bind: IRabbitMQ;
begin
  Result := Self;

  FChannel.QueueBind(FFila, FExchange, FRoutingKey, []);
end;

function TRabbitMQ.ConsumindoFila: Boolean;
begin
  Result := False;
end;

function TRabbitMQ.ConsumirFila: String;
begin
  FInterromperConsumo := False;
  while not FInterromperConsumo do
  begin
    Conectar;
    FChannel.BasicConsume( procedure( Msg: TAMQPMessage; var SendAck: Boolean )
                           begin
                             FOnReceiveMessage(Msg.Body.AsString[ TEncoding.UTF8 ]);
                             SendAck := True;
                           end,
                           FFila, 'Consume' + FFila);
  end;
end;

procedure TRabbitMQ.ConsumirFilaThread(AProcedureNotify: TNotify);
var
  LQueue: TAMQPMessageQueue;
begin
  if Assigned(FThread) then
    FreeAndNil(FThread);

  LQueue := TAMQPMessageQueue.Create;
  FChannel.BasicConsume(LQueue, FFila, 'Consume' + FFila);
  FThread := TConsumerThread.Create(LQueue, AProcedureNotify);
end;

constructor TRabbitMQ.Create;
begin
  FConnection := TAMQPConnection.Create;
  FConnection.HeartbeatSecs := 120;
  FConnection.Timeout := 5000;
  FConnection.Host := 'localhost';
  FConnection.Port := 5672;
  FConnection.Username := 'guest';
  FConnection.Password := 'guest';
  FConnection.Connect;

  FChannel := FConnection.OpenChannel;
end;

function TRabbitMQ.CriarExchange: IRabbitMQ;
begin
  Result := Self;

  if FExchange.Trim.IsEmpty then
    Exit;

  FChannel.ExchangeDeclare(FExchange, etDirect , []);
end;

function TRabbitMQ.CriarFila: IRabbitMQ;
begin
  Result := Self;

  if FFila.Trim.IsEmpty then
    Exit;

  FChannel.QueueDeclare(FFila, []);
end;

destructor TRabbitMQ.Destroy;
begin
  if FConnection.IsOpen then
    FConnection.Disconnect;
  FConnection.Free;
  FChannel := nil;

  if Assigned(FThread) then
    FreeAndNil(FThread);

  inherited;
end;

function TRabbitMQ.EnviarMensagem: IRabbitMQ;
begin
  Result := Self;

  if MatchStr('', [FExchange, FFila])  then
    Exit;

  FChannel.BasicPublish(FExchange, FExchange + '.' + FFila, FMensagem);
end;

function TRabbitMQ.EnviarMensagemAssincrona: IRabbitMQ;
begin
  Result := Self;

  if MatchStr('', [FExchange, FFila])  then
    Exit;

  TTask.Run(procedure
  begin
    FChannel.BasicPublish(FExchange, FFila, FMensagem);
  end);
end;

function TRabbitMQ.Exchange(ANomeExchange: String): IRabbitMQ;
begin
  Result := Self;
  FExchange := ANomeExchange;
end;

function TRabbitMQ.Exchange: String;
begin
  Result := FExchange;
end;

function TRabbitMQ.Fila(ANomeFila: String): IRabbitMQ;
begin
  Result := Self;
  FFila := ANomeFila;
end;

function TRabbitMQ.Fila: String;
begin
  Result := FFila;
end;

procedure TRabbitMQ.InterromperConsumoFila;
begin
  FInterromperConsumo := True;
  if Assigned(FThread) then
    FThread.ForceInterrupt;
end;

function TRabbitMQ.Mensagem(AMensagem: String): IRabbitMQ;
begin
  Result := Self;
  FMensagem := AMensagem;
end;

function TRabbitMQ.Mensagem: String;
begin
  Result := FMensagem;
end;

class function TRabbitMQ.New: IRabbitMQ;
begin
  Result := Self.Create;
end;

function TRabbitMQ.OnReceiveMessage(AProcedureNotify: TNotify): IRabbitMQ;
begin
  Result := Self;
  FOnReceiveMessage := AProcedureNotify;
end;

function TRabbitMQ.RoutingKey: String;
begin
  Result := FRoutingKey;
end;

procedure TRabbitMQ.Conectar;
begin
  if not FConnection.IsOpen then
    FConnection.Connect;

  if FChannel.State = cOpen then
    Exit;

  FChannel.Close;
  FChannel := nil;
  FChannel := FConnection.OpenChannel;
end;

function TRabbitMQ.RoutingKey(ARoutingKey: String): IRabbitMQ;
begin
  Result := Self;
  FRoutingKey := ARoutingKey;
end;

{ TConsumerThread }

constructor TConsumerThread.Create(AQueue: TAMQPMessageQueue; AProcedureNotify: TNotify);
begin
  FQueue := AQueue;
  FForcedInterrupt := False;
  OnMessageReceive(AProcedureNotify);
  inherited Create;
end;

procedure TConsumerThread.Execute;
var
  LMensagem: TAMQPMessage;
begin
  WriteLn('Thread starting', False);
  NameThreadForDebugging('ConsumerThread');

  try
    while not Terminated do
    begin
      try
        LMensagem := FQueue.Get(500);

        if Assigned(LMensagem) then
        begin
          try
            if Assigned(FOnMessageReceive) then
              FOnMessageReceive(LMensagem.Body.AsString[TEncoding.UTF8]);

            LMensagem.Ack;
          finally
            LMensagem.Free;
          end;
        end
        else
        begin
          Sleep(500);
        end;

      except
        on E: Exception do
        begin
          WriteLn('Erro ao consumir mensagem: ' + E.Message, True);
          Sleep(500);
        end;
      end;
    end;

  finally
    FreeAndNil(FQueue);
    WriteLn('Thread stopped', True);
  end;
end;

procedure TConsumerThread.ForceInterrupt;
begin
  FForcedInterrupt := True;
end;

procedure TConsumerThread.OnMessageReceive(AProcedureNotify: TNotify);
begin
  FOnMessageReceive := AProcedureNotify;
end;

end.
