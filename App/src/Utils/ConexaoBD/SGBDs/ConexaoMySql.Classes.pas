unit ConexaoMySql.Classes;

interface

uses
  FireDAC.Comp.Client, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.DApt, FireDAC.Stan.Def, Conexao.Interfaces, SysUtils;

type
  TConexaoMySql = class(TInterfacedObject, IConexao)
  private
    FConexao: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IConexao;
    function GetConnection: TFDConnection;
  end;

implementation

uses
  ConfiguracaoBancoDados.Classes;

{ TConexaoMySql }

constructor TConexaoMySql.Create;
var
  LDadosConexao: TInformacoesConexao;
begin
  FConexao := TFDConnection.Create(nil);
  try
    LDadosConexao := TConfigBancoDados.CarregarConfiguracoes;

    FConexao.DriverName := LDadosConexao.SGBD;
    FConexao.Params.Add('Server='    + LDadosConexao.Servidor);
    FConexao.Params.Add('User_Name=' + LDadosConexao.Usuario);
    FConexao.Params.Add('Password='  + LDadosConexao.Senha);
    FConexao.Params.Add('Database='  + LDadosConexao.BancoDados);
    FConexao.Params.Add('CharacterSet=utf8');
    FConexao.LoginPrompt := False;
    FConexao.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Problemas ao se conectar com o banco de dados: ' + E.Message);
  end;
end;

destructor TConexaoMySql.Destroy;
begin
  FreeAndNil(FConexao);
  inherited;
end;

function TConexaoMySql.GetConnection: TFDConnection;
begin
  Result := FConexao;
end;

class function TConexaoMySql.New: IConexao;
begin
  Result := Self.Create;
end;

end.
