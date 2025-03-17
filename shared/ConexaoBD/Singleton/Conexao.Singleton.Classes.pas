unit Conexao.Singleton.Classes;

interface

uses
  Conexao.Interfaces;

type
  TConexaoSingleton = class
  private
    class var FInstancia: IConexao;
  public
    class function Instancia: IConexao;
  end;

implementation

uses
  Conexao.Factory.Classes, SysUtils;

{ TConexaoSingleton }

class function TConexaoSingleton.Instancia: IConexao;
begin
  try
    if not Assigned(FInstancia) then
      FInstancia := TConexaoBDFactory.CriarConexao;

    Result := FInstancia;
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

end.
