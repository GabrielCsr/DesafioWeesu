unit Desafio.Model.MercadoLivre.Classes;

interface

uses
  System.Generics.Collections, SysUtils,
  Desafio.Model.Entity.Configuracao.Classes,
  Desafio.Service.MercadoLivre.Classes,
  Desafio.Model.Entity.Token.Classes,
  Desafio.Model.Entity.MercadoLivre.Produto.Classes,
  System.Threading, System.Classes;

type
  IMercadoLivre = Interface
    procedure GerarCode;
    function DadosDeAcessoValidos: Boolean;
    function Buscar(APalavraChave: String): Boolean;
    function Produtos: TList<TProdutoMercadoLivre>;
    function IDAplicacao:  String; overload;
    function IDAplicacao(AValue: String):  IMercadoLivre; overload;
    function URIRedirect:  String; overload;
    function URIRedirect(AValue: String):  IMercadoLivre; overload;
    procedure SalvarProduto(AProduto: TProdutoMercadoLivre);
  End;

  TMercadoLivre = class(TInterfacedObject, IMercadoLivre)
  const
    URL_GERAR_CODE  = 'https://auth.mercadolivre.com.br/authorization?response_type=code' +
                      '&client_id=[APPID]&redirect_uri=[URI]';

    FILA_PRODUTOS = 'queue_mlb_produtos';
    EXCHANGE = 'desafio';
  private
    FIDAplicacao: String;
    FURIRedirect: String;
    FService: IServiceMercadoLivre;
    FListaProdutos: TListaProdutos;
    function UrlGeracaoCode: String;
    function AcessToken: String;
    function TokenVencido(AToken: TToken): Boolean;
    procedure RefreshToken(var AToken: TToken);
    procedure GerarToken(var AToken: TToken);
    function TentativaRefreshToken: String;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IMercadoLivre;
    procedure GerarCode;
    function DadosDeAcessoValidos: Boolean;
    function Buscar(APalavraChave: String): Boolean;
    function Produtos: TList<TProdutoMercadoLivre>;
    function IDAplicacao:  String; overload;
    function IDAplicacao(AValue: String):  IMercadoLivre; overload;
    function URIRedirect:  String; overload;
    function URIRedirect(AValue: String):  IMercadoLivre; overload;
    procedure SalvarProduto(AProduto: TProdutoMercadoLivre);
  end;

implementation

uses
  System.StrUtils, FMX.Dialogs, Desafio.Model.Exception.ValidaCampo.Classes, Desafio.Utils;

{ TMercadoLivre }

function TMercadoLivre.AcessToken: String;
var
  LToken: TToken;
begin
  Result := '';
  LToken := nil;
  try
    try
      if FService.TokenExiste(LToken) then
      begin
        if TokenVencido(LToken) then
          RefreshToken(LToken);
      end
      else
      begin
        GerarToken(LToken);
      end;

      if Assigned(LToken) and (not LToken.AccessToken.Trim.IsEmpty) then
        Result := LToken.AccessToken;
    except
      On E: Exception do
      raise Exception.Create(E.Message);
    end;
  finally
    if Assigned(LToken) then
      LToken.Free;
  end;
end;

function TMercadoLivre.Buscar(APalavraChave: String): Boolean;
var
  LTentativasRefresh: Integer;
  LAccesToken: String;
begin
  Result := False;
  LTentativasRefresh := 0;

  if not DadosDeAcessoValidos then
  begin
    TThread.Synchronize(nil, procedure
    begin
      ShowMessage('Algumas das configurações necessárias para buscar os produtos no Mercado Livre não foram parametrizadas. ' +
                'Acesse a rotina "Configurações" e preencha todos os campos.');
    end);

    Exit;
  end;

  try
    LAccesToken := AcessToken;

    if LAccesToken.Trim.IsEmpty then
      Exit;

    while LTentativasRefresh <= 4 do
    begin
      try
        if Assigned(FListaProdutos) then
          FListaProdutos.Free;

        FListaProdutos := FService.BuscarProdutos(APalavraChave, LAccesToken);
        FService.CarregarImagens(FListaProdutos);
        Exit(True);
      except
        On E: Exception do
        begin
          if LTentativasRefresh < 4 then
          begin
            try
              LAccesToken := TentativaRefreshToken;
              Inc(LTentativasRefresh);
            except
              On E: Exception do
              begin
                raise Exception.Create('Erro ao tentar renovar o access token: ' + E.Message);
              end;
            end;
          end
          else
          begin
            raise Exception.Create('Ocorreram problemas ao buscar os produtos na API do Mercado Livre. ' +
                                   'Verifique os dados de autorização e tente novamente!');
          end;
        end;
      end;
    end;

    if LTentativasRefresh > 4 then
      raise Exception.Create('Falha na autenticação após múltiplas tentativas de renovação do token.');
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TMercadoLivre.TentativaRefreshToken: String;
var
  LToken: TToken;
begin
  Result := '';
  try
    try

      if FService.TokenExiste(LToken) then
      begin
        RefreshToken(LToken);
      end
      else
      begin
        GerarToken(LToken);
      end;

      if Assigned(LToken) and (not LToken.AccessToken.Trim.IsEmpty) then
        Result := LToken.AccessToken
      else
        raise Exception.Create('Não foi possivel buscar o token de acesso a API. ' +
                               'Verifique os dados de autorização nas configurações.');
    except
      On E: Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    if Assigned(LToken) then
      LToken.Free;
  end;
end;

constructor TMercadoLivre.Create;
begin
  FService := TServiceMercadoLivre.New;
end;

function TMercadoLivre.DadosDeAcessoValidos: Boolean;
begin
  Result := not MatchStr('', [ValorConfiguracao('APP_ID'),
                              ValorConfiguracao('SECRET'),
                              ValorConfiguracao('CODECH'),
                              ValorConfiguracao('REDIRE')]);
end;

destructor TMercadoLivre.Destroy;
begin
  if Assigned(FListaProdutos) then
    FListaProdutos.Free;
  inherited;
end;

procedure TMercadoLivre.GerarCode;
begin
  if FIDAplicacao.IsEmpty or
     FURIRedirect.IsEmpty then
  begin
    ShowMessage('Os campos ID da Aplicação e Uri Redirect devem ser preenchidos para geração do code!');
    Exit;
  end;


  ShowMessage('Será aberto o site do mercado livre em seu navegador. ' +
                'Conclua o processo de verificação, e ao finalizar será redirecionado ao URI Redirect informado. ' +
                'Copie o code gerado na URL e cole no campo "Code".');

  ShowMessage('Se não for encaminhado ao site, verifique se os dados informados nas configurações ' +
              'estão corretos, ajuste-os e tente novamente.');

  FService.GerarCode(UrlGeracaoCode);
end;

procedure TMercadoLivre.GerarToken(var AToken: TToken);
begin
  try
    AToken := FService.GerarToken(taCode,
                                  ValorConfiguracao('APP_ID'),
                                  ValorConfiguracao('SECRET'),
                                  ValorConfiguracao('CODECH'),
                                  '',
                                  ValorConfiguracao('REDIRE'));

    if Assigned(AToken) and (not AToken.AccessToken.Trim.IsEmpty) then
      FService.SalvarToken(AToken)
  except
    On E: Exception do
    begin
      if E.Message.Contains('"invalid_grant"') then
        ShowMessage('Os dados de autorização são invalidos ou o code está expirado. ' +
                    'Valide os dados de autorização e gere um novo code através da rotina "Configurações". ' +
                    'Após ajustes, tente novamente!')
      else
        raise Exception.Create(E.Message);
    end;
  end;
end;

function TMercadoLivre.IDAplicacao: String;
begin
  Result := FIDAplicacao;
end;

function TMercadoLivre.IDAplicacao(AValue: String): IMercadoLivre;
begin
  Result := Self;
  FIDAplicacao := AValue;
end;

class function TMercadoLivre.New: IMercadoLivre;
begin
  Result := Self.Create;
end;

function TMercadoLivre.Produtos: TList<TProdutoMercadoLivre>;
begin
  Result := FListaProdutos.Produtos;
end;

procedure TMercadoLivre.RefreshToken(var AToken: TToken);
var
  LRefresh: String;
begin
  try
    LRefresh := AToken.RefreshToken;
    FreeAndNil(AToken);

    AToken := FService.GerarToken(taRefresh,
                                  ValorConfiguracao('APP_ID'),
                                  ValorConfiguracao('SECRET'),
                                  '',
                                  LRefresh);

    if Assigned(AToken) and (not AToken.AccessToken.Trim.IsEmpty) then
      FService.SalvarToken(AToken)
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TMercadoLivre.SalvarProduto(AProduto: TProdutoMercadoLivre);
begin
  FService.EnviarMensagemProduto(EXCHANGE, FILA_PRODUTOS, AProduto);
end;

function TMercadoLivre.TokenVencido(AToken: TToken): Boolean;
var
  LExpiracao: TDateTime;
begin
  if (AToken.ExpiraEm <= 0) or (AToken.AtualizadoEm = 0) then
    Exit(True);

  LExpiracao := AToken.AtualizadoEm + (AToken.ExpiraEm / 86400);

  Result := Now >= LExpiracao;
end;
function TMercadoLivre.URIRedirect: String;
begin
  Result := FURIRedirect;
end;

function TMercadoLivre.URIRedirect(AValue: String): IMercadoLivre;
begin
  Result := Self;
  FURIRedirect := AVAlue;
end;

function TMercadoLivre.UrlGeracaoCode: String;
var
  LUrl: String;
begin
  LUrl := URL_GERAR_CODE;
  LUrl := LUrl.Replace('[APPID]', FIDAplicacao);
  LUrl := LUrl.Replace('[URI]',   FURIRedirect);
  Result := LUrl;
end;

end.
