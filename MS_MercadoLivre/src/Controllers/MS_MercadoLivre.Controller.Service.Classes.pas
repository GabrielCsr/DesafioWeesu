unit MS_MercadoLivre.Controller.Service.Classes;

interface

uses
  Horse,
  SysUtils,
  StrUtils,
  Classes,
  MS_MercadoLivre.Model.MercadoLivre.Classes,
  System.JSON,
  Horse.Jhonson;

type
  TServiceController = class
    class procedure Registry;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TServiceController }

class procedure TServiceController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LStatus: TJSONObject;
  LConsumindoFila: Boolean;
begin
  try
    LConsumindoFila := TMercadoLivre
                         .New
                         .Produtos
                         .ConsumindoFila;

    LStatus := TJSONObject.Create;
    LStatus.AddPair('status', 'rodando');
    LStatus.AddPair('mensagem', IfThen(LConsumindoFila, 'Consumindo ', 'Não consumindo ') + 'fila de produtos');
    Res.Status(200).Send<TJSONObject>(LStatus);
  except
    on E: Exception do
    begin
      WriteLn(E.Message);
      Res.Status(500).Send<TJSONObject>(TJSONObject.Create(TJSONPair.Create('mensagem', 'erro interno')));
    end;
  end;
end;
class procedure TServiceController.Registry;
begin
  THorse.Get('service/status', Get);
end;

end.
