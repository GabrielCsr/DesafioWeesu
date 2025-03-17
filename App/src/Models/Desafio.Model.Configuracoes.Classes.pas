unit Desafio.Model.Configuracoes.Classes;

interface

uses
  System.Generics.Collections, System.Classes, SysUtils,
  Desafio.Model.Entity.Configuracao.Classes,
  Desafio.Model.MercadoLivre.Classes, Desafio.Controller.Exceptions.Classes,
  FMX.Forms, Desafio.Service.Configuracoes.Classes;

type
  IModelConfiguracoes = interface
    ['{74EE7633-50CF-4C6B-82C9-E457ECD46A6A}']
    function DadosValidos: Boolean;
    function SalvarConfiguracoes: Boolean;
    procedure GerarCode;
    procedure ConsultarConfiguracoes;
    function IDAplicacao:  String; overload;
    function ChaveSecreta: String; overload;
    function URIRedirect:  String; overload;
    function Code:         String; overload;
    function IDAplicacao(AValue: String):  IModelConfiguracoes; overload;
    function ChaveSecreta(AValue: String): IModelConfiguracoes; overload;
    function URIRedirect(AValue: String):  IModelConfiguracoes; overload;
    function Code(AValue: String):         IModelConfiguracoes; overload;
  end;

  TModelConfiguracoes = class(TInterfacedObject, IModelConfiguracoes)
  private
    FIDAplicacao:  String;
    FChaveSecreta: String;
    FURIRedirect:  String;
    FCode:         String;
    FService: IServiceConfiguracoes;
    FException: IControllerExceptions;
    function ListaEntidades: TList<TConfiguracao>;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    class function New(AForm: TForm): IModelConfiguracoes;
    function DadosValidos: Boolean;
    function SalvarConfiguracoes: Boolean;
    procedure GerarCode;
    procedure ConsultarConfiguracoes;
    function IDAplicacao:  String; overload;
    function ChaveSecreta: String; overload;
    function URIRedirect:  String; overload;
    function Code:         String; overload;
    function IDAplicacao(AValue: String):  IModelConfiguracoes; overload;
    function ChaveSecreta(AValue: String): IModelConfiguracoes; overload;
    function URIRedirect(AValue: String):  IModelConfiguracoes; overload;
    function Code(AValue: String):         IModelConfiguracoes; overload;
  end;

implementation

{ TModelConfiguracoes }

uses Desafio.Utils, System.StrUtils, FMX.Dialogs;

function TModelConfiguracoes.ChaveSecreta(AValue: String): IModelConfiguracoes;
begin
  Result := Self;
  FChaveSecreta := AValue;
end;

function TModelConfiguracoes.ChaveSecreta: String;
begin
  Result := FChaveSecreta
end;

function TModelConfiguracoes.Code: String;
begin
  Result := FCode;
end;

function TModelConfiguracoes.Code(AValue: String): IModelConfiguracoes;
begin
  Result := Self;
  FCode := AValue;
end;

procedure TModelConfiguracoes.ConsultarConfiguracoes;
begin
  FIDAplicacao  := FService.ValorConfiguracao('APP_ID');
  FChaveSecreta := FService.ValorConfiguracao('SECRET');
  FCode         := FService.ValorConfiguracao('CODECH');
  FURIRedirect  := FService.ValorConfiguracao('REDIRE');
end;

constructor TModelConfiguracoes.Create(AForm: TForm);
begin
  FService   := TServiceConfiguracoes.New;
  FException := TControllerExceptions.New(AForm);
end;

function TModelConfiguracoes.DadosValidos: Boolean;
begin
  Result := True;
  if MatchStr('', [FIDAplicacao, FChaveSecreta, FURIRedirect, FCode]) then
    Result := False;
end;

destructor TModelConfiguracoes.Destroy;
begin
  inherited;
end;

procedure TModelConfiguracoes.GerarCode;
begin
  TMercadoLivre
    .New
    .IDAplicacao(FIDAplicacao)
    .URIRedirect(FURIRedirect)
    .GerarCode;
end;

function TModelConfiguracoes.IDAplicacao: String;
begin
  Result := FIDAplicacao;
end;

function TModelConfiguracoes.IDAplicacao(AValue: String): IModelConfiguracoes;
begin
  Result := Self;
  FIDAplicacao := AValue;
end;

function TModelConfiguracoes.ListaEntidades: TList<TConfiguracao>;
begin
  Result := TList<TConfiguracao>.Create;
  try
    Result.Add(TConfiguracao.Create('CFG_APP_ID', FIDAplicacao));
    Result.Add(TConfiguracao.Create('CFG_SECRET', FChaveSecreta));
    Result.Add(TConfiguracao.Create('CFG_REDIRE', FURIRedirect));
    Result.Add(TConfiguracao.Create('CFG_CODECH', FCode));
  except
    On E: Exception do
    begin
      LiberarLista(Result);
      raise Exception.Create(E.Message);
    end;
  end;
end;

class function TModelConfiguracoes.New(AForm: TForm): IModelConfiguracoes;
begin
  Result := Self.Create(AForm);
end;

function TModelConfiguracoes.SalvarConfiguracoes: Boolean;
var
  LConfiguracoes: TList<TConfiguracao>;
begin
  Result := False;
  if not DadosValidos then
  begin
    ShowMessage('Para salvar as configurações é necessário que todos os campos estejam preenchidos!');
    Exit;
  end;

  LConfiguracoes := ListaEntidades;
  try
    try
      FService.SalvarConfiguracoes(LConfiguracoes);
      Result := True;
      ShowMessage('Configurações salvas com sucesso!');
    except
      On E: Exception do
        raise Exception.Create('Problemas ao salvar as configurações. ' + E.Message);
    end;
  finally
    LiberarLista(LConfiguracoes);
  end;
end;

function TModelConfiguracoes.URIRedirect: String;
begin
  Result := FURIRedirect;
end;

function TModelConfiguracoes.URIRedirect(AValue: String): IModelConfiguracoes;
begin
  Result := Self;
  FURIRedirect := AValue;
end;

end.
