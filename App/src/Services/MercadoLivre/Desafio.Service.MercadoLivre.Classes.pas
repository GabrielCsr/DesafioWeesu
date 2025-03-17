unit Desafio.Service.MercadoLivre.Classes;

interface

uses
  System.Generics.Collections, SysUtils,
  Desafio.Model.Entity.Configuracao.Classes, ShellApi, Windows,
  Desafio.Model.Entity.Token.Classes, FireDAC.Comp.Client, FireDAC.Stan.Async, FireDAC.Stan.Param,
  Conexao.Utils.Classes, Desafio.Model.Entity.MercadoLivre.Produto.Classes,
  System.JSON, Rest.Json, FMX.Graphics, System.Classes, RabbitMQ.Interfaces;

type
  TTipoAcessToken = (taCode, taRefresh);

  IServiceMercadoLivre = interface
    procedure GerarCode(AUrl: String);
    function GerarToken(ATipoAcessToken: TTipoAcessToken;
                        AIDAplicacao,
                        AChaveSecreta: String;
                        ACode: String= '';
                        ARefresh: String = '';
                        ARedirect: String = ''): TToken;
    function TokenExiste(out AToken: TToken): Boolean;
    procedure SalvarToken(AToken: TToken);
    function BuscarProdutos(APalavraChave, AAccessToken: String): TListaProdutos;
    procedure CarregarImagens(AListaProdutos: TListaProdutos);
    procedure EnviarMensagemProduto(AExchange, AFila: String; AProduto: TProdutoMercadoLivre);
  end;

  TServiceMercadoLivre = class(TInterfacedObject, IServiceMercadoLivre)
  const
    URL_ACESS_TOKEN    = 'https://api.mercadolibre.com/oauth/token';
    URL_BUSCA_PRODUTOS = 'https://api.mercadolibre.com/sites/MLB/search?q=%s&limit=50&offset=%d';
  private
    FQuery: TFDQuery;
    FConexaoUtils: TConexaoUtils;
    procedure AbrirUrl(AUrl: String);
    function FormatarUrlBuscaProdutos(APalavraChave: String; AOffSet: Integer): String;
    function TotalRegistros(AJSON: String): Integer;
    function BuscarImagem(AURLImagem: String): TMemoryStream;
    procedure ProcessarImagem(AProduto: TProdutoMercadoLivre);
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IServiceMercadoLivre;
    procedure GerarCode(AUrl: String);
    function GerarToken(ATipoAcessToken: TTipoAcessToken;
                        AIDAplicacao,
                        AChaveSecreta: String;
                        ACode: String= '';
                        ARefresh: String = '';
                        ARedirect: String = ''): TToken;

    function TokenExiste(out AToken: TToken): Boolean;
    procedure SalvarToken(AToken: TToken);
    function BuscarProdutos(APalavraChave, AAccessToken: String): TListaProdutos;
    procedure CarregarImagens(AListaProdutos: TListaProdutos);
    procedure EnviarMensagemProduto(AExchange, AFila: String; AProduto: TProdutoMercadoLivre);
  end;

implementation

uses
  System.StrUtils, RESTRequest4D, System.NetEncoding, System.Threading,
  RabbitMQ.AMQP.Classes;

{ TServiceMercadoLivre }

procedure TServiceMercadoLivre.AbrirUrl(AUrl: String);
begin
  ShellExecute(0, 'open', PChar(AURL), nil, nil, SW_SHOWNORMAL);
end;

function TServiceMercadoLivre.GerarToken(ATipoAcessToken: TTipoAcessToken;
                                         AIDAplicacao,
                                         AChaveSecreta: String;
                                         ACode: String= '';
                                         ARefresh: String = '';
                                         ARedirect: String = ''): TToken;
var
  LResponse: IResponse;
  LRequest: IRequest;
begin
  try
    LRequest := TRequest
                   .New
                   .BaseURL(URL_ACESS_TOKEN)
                   .Accept('application/json')
                   .AddHeader('content-type', 'application/x-www-form-urlencoded')
                   .AddParam('client_id', AIDAplicacao)
                   .AddParam('client_secret', AChaveSecreta);

    if ATipoAcessToken = taCode then
    begin
      LRequest
        .AddParam('grant_type', 'authorization_code')
        .AddParam('code', ACode)
        .AddParam('redirect_uri', ARedirect);
    end
    else
    begin
      LRequest
        .AddParam('grant_type', 'refresh_token')
        .AddParam('refresh_token', ARefresh);
    end;

    LResponse := LRequest.Post;

    if not MatchStr(LResponse.StatusCode.ToString,  ['200', '201']) then
      raise Exception.Create(LResponse.Content);

    Result := TToken.FromJSON(LResponse.Content);
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TServiceMercadoLivre.BuscarProdutos(APalavraChave, AAccessToken: String): TListaProdutos;
const
  LIMITE_PRODUTOS_PUBLIC_USER = 1000;
  LIMITE_PRODUTOS_PAGINA = 50;
var
  LResponse: IResponse;
  LTotalProdutos,
  LOffSet: Integer;
begin
  Result := TListaProdutos.Create;
  LTotalProdutos := 1;
  LOffSet := 0;
  try
    while (LOffSet < LIMITE_PRODUTOS_PUBLIC_USER) and (LOffSet < LTotalProdutos) do
    begin
      LResponse := TRequest
                     .New
                     .BaseURL(FormatarUrlBuscaProdutos(APalavraChave, LOffSet))
                     .Accept('application/json')
                     .TokenBearer(AAccessToken)
                     .Get;

      if not MatchStr(LResponse.StatusCode.ToString,  ['200', '201']) then
        raise Exception.Create(LResponse.Content);

      Result.FromJSON(LResponse.Content);

      Inc(LOffSet, LIMITE_PRODUTOS_PAGINA);
      if LTotalProdutos = 1 then
        LTotalProdutos := TotalRegistros(LResponse.Content);
    end;
  except
    On E: Exception do
    begin
      Result.Free;
      raise Exception.Create(E.Message);
    end;
  end;
 end;

function TServiceMercadoLivre.BuscarImagem(AURLImagem: String): TMemoryStream;
var
  LResponse: IResponse;
begin
  Result := nil;
  try
    LResponse := TRequest
                   .New
                   .BaseURL(AURLImagem)
                   .Get;

    if not MatchStr(LResponse.StatusCode.ToString,  ['200', '201']) then
        raise Exception.Create(LResponse.Content);

    Result := TMemoryStream.Create;
    Result.LoadFromStream(LResponse.ContentStream);
    Result.Position := 0;
  except
    On E: Exception do
    begin
      if Assigned(Result) then
        FreeAndNil(Result);

      raise Exception.Create(E.Message);
    end;
  end;
end;

procedure TServiceMercadoLivre.CarregarImagens(AListaProdutos: TListaProdutos);
var
  LIndexMeioLista: Integer;
  LTask1, LTask2: ITask;
begin
  if (not Assigned(AListaProdutos)) or (AListaProdutos.Produtos.IsEmpty) then
    Exit;

  LIndexMeioLista := AListaProdutos.Produtos.Count div 2;

  LTask1 := TTask.Run(procedure
  begin
    for var I := 0 to Pred(LIndexMeioLista) do
    begin
      ProcessarImagem(AListaProdutos.Produtos[I]);
    end;
  end);

  LTask2 := TTask.Run(procedure
  begin
    for var J := LIndexMeioLista to Pred(AListaProdutos.Produtos.Count) do
    begin
      ProcessarImagem(AListaProdutos.Produtos[J]);
    end;
  end);

  TTask.WaitForAll([LTask1, LTask2]);
end;

procedure TServiceMercadoLivre.ProcessarImagem(AProduto: TProdutoMercadoLivre);
begin
  try
    AProduto.Imagem := BuscarImagem(AProduto.ImagemURL);
  except
    On E: Exception do
    begin
      if Assigned(AProduto.Imagem) then
      begin
        FreeAndNil(AProduto.Imagem);
      end;
    end;
  end;
end;

constructor TServiceMercadoLivre.Create;
begin
  FConexaoUtils := TConexaoUtils.Create;
  FQuery := FConexaoUtils.CriarQuery;
end;

destructor TServiceMercadoLivre.Destroy;
begin
  FreeAndNil(FConexaoUtils);
  FreeAndNil(FQuery);
  inherited;
end;

procedure TServiceMercadoLivre.EnviarMensagemProduto(AExchange, AFila: String;
  AProduto: TProdutoMercadoLivre);
begin
  TTask.Run(procedure
            var
              LProdutoJson: TJSONObject;
            begin
              LProdutoJson := AProduto.ToJSON;
              try
                TRabbitMQ
                  .New
                  .Exchange(AExchange)
                  .Fila(AFila)
                  .Mensagem(LProdutoJson.ToString)
                  .EnviarMensagem;
              finally
                FreeAndNil(LProdutoJson);
              end;
            end);
end;

function TServiceMercadoLivre.FormatarUrlBuscaProdutos(APalavraChave: String; AOffSet: Integer): String;
begin
  Result := Format(URL_BUSCA_PRODUTOS, [TNetEncoding.URL.Encode(APalavraChave), AOffSet]);
end;

procedure TServiceMercadoLivre.GerarCode(AUrl: String);
begin
  AbrirUrl(AUrl);
end;

class function TServiceMercadoLivre.New: IServiceMercadoLivre;
begin
  Result := Self.Create;
end;

procedure TServiceMercadoLivre.SalvarToken(AToken: TToken);
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Text := 'REPLACE INTO tokens ' +
                       '(id_usuario, access_token, refresh_token, expira_em, criado_em, atualizado_em) VALUES ' +
                       '(:id_usuario, :acess_token, :refresh_token, :expira_em, :criado_em, :atualizado_em)';

    FQuery.ParamByName('id_usuario').AsInteger     := AToken.IdUsuario;
    FQuery.ParamByName('acess_token').AsString     := AToken.AccessToken;
    FQuery.ParamByName('refresh_token').AsString   := AToken.RefreshToken;
    FQuery.ParamByName('expira_em').AsInteger      := AToken.ExpiraEm;
    FQuery.ParamByName('criado_em').AsDateTime     := AToken.CriadoEm;
    FQuery.ParamByName('atualizado_em').AsDateTime := AToken.AtualizadoEm;
    FQuery.ExecSQL;
  except
    On E: Exception do
      raise Exception.Create('Problemas ao salvar token. ' + E.Message);
  end;
end;

function TServiceMercadoLivre.TokenExiste(out AToken: TToken): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := FConexaoUtils.CriarQuery;
  try
    try
      LQuery.Close;
      LQuery.SQL.Clear;
      LQuery.Open('select * from tokens where id_usuario = "1" limit 1');

      Result := LQuery.RecordCount > 0;
      if not Result then
        Exit;

      AToken := TToken.Create(LQuery.FieldByName('access_token').AsString,
                              LQuery.FieldByName('refresh_token').AsString,
                              LQuery.FieldByName('expira_em').AsInteger,
                              LQuery.FieldByName('criado_em').AsDateTime,
                              LQuery.FieldByName('atualizado_em').AsDateTime);

      LQuery.Close;
    except
      On E: Exception do
        raise Exception.Create('Problemas ao verificar se o token existe. ' + E.Message);
    end;
  finally
    FreeAndNil(LQuery);
  end;
end;

function TServiceMercadoLivre.TotalRegistros(AJSON: String): Integer;
var
  LJSON,
  LJSONPaging: TJSONObject;
begin
  Result := 0;
  try
    try
      LJSON := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
      if Assigned(LJSON) and LJSON.TryGetValue<TJSONObject>('paging', LJSONPaging) then
      begin
        Result := LJSONPaging.GetValue<Integer>('total', 0);
      end;
    except
      On E: Exception do
        raise Exception.Create('Ocorreram problemas ao extrair o total de produtos. ' + E.Message);
    end;
  finally
    FreeAndNil(LJSON);
  end;
end;

end.
