unit Conexao.Utils.Classes;

interface

uses
  FireDAC.Comp.Client, Conexao.Singleton.Classes, ConexaoMySql.Classes;

type
  TConexaoUtils = class
  private
  public
    class function CriarQuery: TFDQuery;
  end;


implementation

{ TConexaoUtils }

class function TConexaoUtils.CriarQuery: TFDQuery;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TConexaoMySQL(TConexaoSingleton.Instancia).GetConnection;
  LQuery.SQL.Clear;
  LQuery.Close;
  Result := LQuery;
end;

end.
