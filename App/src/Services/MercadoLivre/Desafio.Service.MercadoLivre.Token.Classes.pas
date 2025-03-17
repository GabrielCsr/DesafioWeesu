unit Desafio.Service.MercadoLivre.Token.Classes;

interface

uses
  Desafio.Model.Entity.Token.Classes;

type
  TTokenMercadoLivre = class
    class function AcessToken: String;
  end;

implementation

{ TTokenMercadoLivre }

class function TTokenMercadoLivre.AcessToken: String;
var
  LToken: TToken;
begin
  if ExisteToken() then
end;

end.
