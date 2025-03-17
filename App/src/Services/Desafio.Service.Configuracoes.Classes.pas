unit Desafio.Service.Configuracoes.Classes;

interface

uses
  System.Generics.Collections, System.Classes, SysUtils,
  Desafio.Model.Entity.Configuracao.Classes, Conexao.Singleton.Classes,
  Conexao.Interfaces, FireDAC.Comp.Client, Conexao.Utils.Classes,
  FireDAC.Stan.Async, FireDAC.Stan.Param;

type
  IServiceConfiguracoes = interface
    ['{1BF402D5-35A2-4E57-9942-48A5D4A036DC}']
    procedure SalvarConfiguracoes(AConfiguracoes: TList<TConfiguracao>);
    function ListarConfiguracoes: TList<TConfiguracao>;
    function ValorConfiguracao(ANome: String): String;
  end;

  TServiceConfiguracoes = class(TInterfacedObject, IServiceConfiguracoes)
  private
    FQuery: TFDQuery;
    FConexaoUtils: TConexaoUtils;
    function ConfiguracaoExiste(ANome: String): Boolean;
    procedure IncluirConfiguracao(ANome, AValor: String);
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IServiceConfiguracoes;
    procedure SalvarConfiguracoes(AConfiguracoes: TList<TConfiguracao>);
    function ListarConfiguracoes: TList<TConfiguracao>;
    function ValorConfiguracao(ANome: String): String;
  end;

implementation

uses
  ShellAPI, Windows, Desafio.Utils;

{ TServiceConfiguracoes }

function TServiceConfiguracoes.ConfiguracaoExiste(ANome: String): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := FConexaoUtils.CriarQuery;
  try
    LQuery.SQL.Clear;
    LQuery.Close;
    LQuery.Open('select 1 from configuracoes where nome = ' + QuotedStr(ANome));
    Result := LQuery.RecordCount > 0;
  finally
    FreeAndNil(LQuery);
  end;
end;

constructor TServiceConfiguracoes.Create;
begin
  FConexaoUtils := TConexaoUtils.Create;
  FQuery := FConexaoUtils.CriarQuery;
end;

destructor TServiceConfiguracoes.Destroy;
begin
  FreeAndNil(FConexaoUtils);
  FreeAndNil(FQuery);
  inherited;
end;


procedure TServiceConfiguracoes.IncluirConfiguracao(ANome, AValor: String);
begin
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.Open('select * from configuracoes where false');
  FQuery.Insert;
  FQuery.FieldByName('nome').AsString := ANome;
  FQuery.FieldByName('valor').AsString := AValor;
  FQuery.Post;
end;

function TServiceConfiguracoes.ListarConfiguracoes: TList<TConfiguracao>;
begin
  Result := TList<TConfiguracao>.Create;
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.Open('select nome, valor from configuracoes');

    FQuery.First;
    while not FQuery.Eof do
    begin
      Result.Add(
                  TConfiguracao.Create(FQuery.Fields[0].AsString,
                                       FQuery.Fields[1].AsString)
               );
      FQuery.Next;
    end;
  except
    On E: Exception do
    begin
      LiberarLista(Result);
      raise Exception.Create('Ocorreram problemas ao listar as configurações. ' + E.Message);
    end;
  end;
end;

class function TServiceConfiguracoes.New: IServiceConfiguracoes;
begin
  Result := Self.Create;
end;

procedure TServiceConfiguracoes.SalvarConfiguracoes(
  AConfiguracoes: TList<TConfiguracao>);
var
  LConfiguracao: TConfiguracao;
begin
  for LConfiguracao in AConfiguracoes do
  begin
    if not ConfiguracaoExiste(LConfiguracao.Nome) then
    begin
      IncluirConfiguracao(LConfiguracao.Nome, LConfiguracao.Valor);
      Continue;
    end;

    FQuery.SQL.Clear;
    FQuery.Close;
    FQuery.SQL.Add('update           ' +
                   '  configuracoes  ' +
                   'set              ' +
                   '  valor = :valor ' +
                   'where            ' +
                   '  nome = :nome   ');

    FQuery.ParamByName('nome').AsString  := LConfiguracao.Nome;
    FQuery.ParamByName('valor').AsString := LConfiguracao.Valor;

    FQuery.ExecSQL;
  end;
end;

function TServiceConfiguracoes.ValorConfiguracao(ANome: String): String;
begin
  Result := '';
  try
    FQuery.SQL.Clear;
    FQuery.Close;
    FQuery.Open('select valor from configuracoes where nome = ' + QuotedStr('CFG_' + ANome));
    Result := FQuery.Fields[0].AsString;
    FQuery.Close;
  except
    On E: Exception do
      raise Exception.Create('Ocorreram problemas ao buscar a configuração ' + ANome + '. ' + E.Message);
  end;
end;

end.
