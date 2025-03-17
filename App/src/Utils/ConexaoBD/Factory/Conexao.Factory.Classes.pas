unit Conexao.Factory.Classes;

interface

uses
  Conexao.Interfaces;

type
  TConexaoBDFactory = class
  public
    class function CriarConexao: IConexao;
  end;

implementation

uses
  ConexaoMySql.Classes, ConfiguracaoBancoDados.Classes, SysUtils;

{ TConexaoBDFactory }

class function TConexaoBDFactory.CriarConexao: IConexao;
var
  LDadosConexao: TInformacoesConexao;
begin
  LDadosConexao := TConfigBancoDados.CarregarConfiguracoes;

  if not LDadosConexao.SGBD.Trim.ToUpper.Equals('MYSQL') then
    raise Exception.Create('A Aplicação não oferece suporte ao banco de dados informado no arquivo de configuração. Informe "MySQL"');

  Result := TConexaoMysql.New;
end;

end.
