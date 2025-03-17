unit RabbitMQ.Stomp.Classes;

interface

uses
  RabbitMQ.Interfaces, StompClient, System.Threading, System.Classes,
  System.SysUtils;

type
  TThreadReceiver = class(TThread)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FOnReceiveMessage: TNotify;
    procedure SetStompClient(const Value: IStompClient);
  protected
    procedure Execute; override;
  public
    procedure OnMessageReceive(AProcedure: TNotify);
    constructor Create(CreateSuspended: Boolean); overload;
    constructor Create; overload;
    property StompClient: IStompClient read FStompClient write SetStompClient;
  end;

  TRabbitMQStomp = class(TInterfacedObject, IRabbitMQ)
  private
    FStompClient: IStompClient;
    FStompFrame: IStompFrame;
    FThReceiver: TThreadReceiver;
    FOnReceiveMessage: TNotify;
    FFila: String;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IRabbitMQ;
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

{ TRabbitMQStomp }

function TRabbitMQStomp.Bind: IRabbitMQ;
begin

end;

function TRabbitMQStomp.ConsumindoFila: Boolean;
begin
  Result := (Assigned(FThReceiver) and FThReceiver.Started);
end;

function TRabbitMQStomp.ConsumirFila: String;
begin

end;

procedure TRabbitMQStomp.ConsumirFilaThread(AProcedureNotify: TNotify);
begin
  if not FStompClient.Connected then
    raise Exception.Create('StompClient não conectado - ' + DateTimeToStr(Now));


  if FFila.Trim.IsEmpty then
    Exit;

  if not Assigned(FThReceiver) then
  begin
    FStompClient.Subscribe(FFila, TAckMode.amAuto);
    FThReceiver := TThreadReceiver.Create(True);
    FThReceiver.FreeOnTerminate := True;
    FThReceiver.StompClient := FStompClient;
  end;

  FThReceiver.OnMessageReceive(AProcedureNotify);

  if not (FThReceiver.Started) then
  begin
    FThReceiver.Start;
  end;
end;

constructor TRabbitMQStomp.Create;
begin
  FStompClient := StompUtils.StompClient;
  try
    FStompClient.Connect;
  except
    on e: Exception do
    begin
      raise Exception.Create
        ('Erro ao se conectar com o stomp. verifique se o plugin foi inciado e reinicie a aplicação! - ' + DateTimeToStr(Now));
    end;
  end;
  FStompFrame := StompUtils.NewFrame();
end;

function TRabbitMQStomp.CriarExchange: IRabbitMQ;
begin

end;

function TRabbitMQStomp.CriarFila: IRabbitMQ;
begin

end;

destructor TRabbitMQStomp.Destroy;
begin
  if Assigned(FThReceiver) then
  begin
    FreeAndNil(FThReceiver);
  end;
  inherited;
end;

function TRabbitMQStomp.EnviarMensagem: IRabbitMQ;
begin

end;

function TRabbitMQStomp.EnviarMensagemAssincrona: IRabbitMQ;
begin

end;

function TRabbitMQStomp.Exchange: String;
begin

end;

function TRabbitMQStomp.Exchange(ANomeExchange: String): IRabbitMQ;
begin

end;

function TRabbitMQStomp.Fila(ANomeFila: String): IRabbitMQ;
begin
  Result := Self;
  FFila := ANomeFila;
end;

function TRabbitMQStomp.Fila: String;
begin
  Result := FFila;
end;

procedure TRabbitMQStomp.InterromperConsumoFila;
begin
  if Assigned(FThReceiver) and FThReceiver.Started then
  begin
    FreeAndNil(FThReceiver);
    FStompClient.Unsubscribe(FFila);
    WriteLn('Solicitado a interrupção do consumo da fila de produtos. - ' + DateTimeToStr(Now))
  end;
end;

function TRabbitMQStomp.Mensagem(AMensagem: String): IRabbitMQ;
begin

end;

function TRabbitMQStomp.Mensagem: String;
begin

end;

class function TRabbitMQStomp.New: IRabbitMQ;
begin
  Result := Self.Create;
end;

function TRabbitMQStomp.OnReceiveMessage(AProcedureNotify: TNotify): IRabbitMQ;
begin
  Result := Self;
  FOnReceiveMessage := AProcedureNotify;
end;

function TRabbitMQStomp.RoutingKey: String;
begin

end;

function TRabbitMQStomp.RoutingKey(ARoutingKey: String): IRabbitMQ;
begin

end;

{ TThreadReceiver }

constructor TThreadReceiver.Create(CreateSuspended: Boolean);
begin
  FStompFrame := StompUtils.CreateFrame;
  inherited Create(CreateSuspended);
end;

constructor TThreadReceiver.Create;
begin
  FStompFrame := StompUtils.CreateFrame;
  inherited Create;
end;

procedure TThreadReceiver.Execute;
begin
  NameThreadForDebugging('ThreadReceiver');
  WriteLn('Consumo inciado! - ' + DateTimeToStr(Now));

  while not (Terminated) do
  begin
    if FStompClient.Receive(FStompFrame, 2000) then
    begin
      FOnReceiveMessage(FStompFrame.Body);
    end;
  end;

  WriteLn('Consumo Interrompido! - ' + DateTimeToStr(Now));
end;

procedure TThreadReceiver.OnMessageReceive(AProcedure: TNotify);
begin
  if Assigned(FOnReceiveMessage) then
    Exit;

  FOnReceiveMessage := AProcedure;
end;

procedure TThreadReceiver.SetStompClient(const Value: IStompClient);
begin
  FStompClient := Value;
end;

end.
