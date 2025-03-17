unit Conexao.Interfaces;

interface

uses
  FireDAC.Comp.Client;

type
  IConexao = interface
    ['{0C4DC86A-D207-4DF6-B5EB-230AF4FE5BB5}']
    function GetConnection: TFDConnection;
  end;

implementation

end.
