unit MS_MercadoLivre.Controller.Produtos.Classes;

interface

uses
  Horse,
  SysUtils,
  Classes, MS_MercadoLivre.Model.MercadoLivre.Classes;

type
  TProdutosController = class
    class procedure Registry;
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TProdutosController }

class procedure TProdutosController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    TThread.CreateAnonymousThread(
      procedure
      begin
        try
          TMercadoLivre
            .New
            .Produtos
            .InterromperConsumo;
        except
          on E: Exception do
          begin
            WriteLn(E.Message);
            raise Exception.Create(E.Message);
          end;
        end;
      end
    ).Start;

    Res.Status(200).Send('Consumo da fila interrompido com sucesso!');
  except
    on E: Exception do
      Res.Status(500).Send('Ocorreram problemas ao interromper o consumo da fila de produtos. ' + E.Message);
  end;
end;

class procedure TProdutosController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    TThread.CreateAnonymousThread(
      procedure
      begin
        try
          TMercadoLivre
            .New
            .Produtos
            .ConsumirFila;
        except
          on E: Exception do
          begin
            WriteLn(E.Message);
            raise Exception.Create(E.Message);
          end;
        end;
      end
    ).Start;

    Res.Status(200).Send('Consumo da fila de produtos iniciado com sucesso!');
  except
    on E: Exception do
      Res.Status(500).Send('Ocorreram problemas ao iniciar o consumo da fila de produtos. ' + E.Message);
  end;
end;

class procedure TProdutosController.Registry;
begin
  THorse.Post(  'produtos/fila/consumir', Post)
        .Delete('produtos/fila/consumir', Delete);
end;

end.
