unit Desafio.Utils;

interface

uses
  System.Generics.Collections, Desafio.Model.Entity.Configuracao.Classes, SysUtils,
  FireDAC.Comp.Client, FireDAC.Stan.Async, FireDAC.Stan.Param, System.Classes,
  FMX.Graphics;

function CriarCopiaListaConfiguracoes(ALista: TList<TConfiguracao>): TList<TConfiguracao>;
procedure LiberarLista(var ALista: TList<TConfiguracao>);
function ValorConfiguracao(ANomeConfiguracao: String): String;

implementation

uses
  Conexao.Utils.Classes;

function CriarCopiaListaConfiguracoes(ALista: TList<TConfiguracao>): TList<TConfiguracao>;
var
  LConfiguracao: TConfiguracao;
begin
  Result := TList<TConfiguracao>.Create;

  for LConfiguracao in ALista do
  begin
    Result.Add(TConfiguracao.Create(LConfiguracao.Nome, LConfiguracao.Valor));
  end;
end;

procedure LiberarLista(var ALista: TList<TConfiguracao>);
var
  LItem: TConfiguracao;
begin
  if Assigned(ALista) then
  begin
    for LItem in ALista do
      LItem.Free;

    ALista.Clear;
    FreeAndNil(ALista);
  end;
end;

function ValorConfiguracao(ANomeConfiguracao: String): String;
var
  LConexaoUtils: TConexaoUtils;
  LQuery: TFDQuery;
begin
  Result := '';
  LConexaoUtils := TConexaoUtils.Create;
  LQuery := LConexaoUtils.CriarQuery;
  try
    try
      LQuery.Open('select valor from configuracoes where nome = ' + QuotedStr('CFG_' + ANomeConfiguracao));
      Result := LQuery.Fields[0].AsString;
    except
      On E: Exception do
        raise Exception.Create('Ocorreram problemas ao buscar a configuração na base de dados. ' + E.Message);
    end;
  finally
    FreeAndNil(LConexaoUtils);
    FreeAndNil(LQuery);
  end;
end;

end.
