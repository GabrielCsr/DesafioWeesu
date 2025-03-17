program MS_MercadoLivre;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.SysUtils,
  MS_MercadoLivre.Controller.Produtos.Classes in 'src\Controllers\MS_MercadoLivre.Controller.Produtos.Classes.pas',
  MS_MercadoLivre.Model.MercadoLivre.Interfaces in 'src\Models\MS_MercadoLivre.Model.MercadoLivre.Interfaces.pas',
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces in 'src\Models\Produtos\MS_MercadoLivre.Model.MercadoLivre.Produtos.Interfaces.pas',
  MS_MercadoLivre.Model.Entity.Produto.Classes in 'src\Models\Entities\MS_MercadoLivre.Model.Entity.Produto.Classes.pas',
  MS_MercadoLivre.Model.MercadoLivre.Classes in 'src\Models\MS_MercadoLivre.Model.MercadoLivre.Classes.pas',
  MS_MercadoLivre.Model.MercadoLivre.Produtos.Classes in 'src\Models\Produtos\MS_MercadoLivre.Model.MercadoLivre.Produtos.Classes.pas',
  MS_MercadoLivre.Service.MercadoLivre.Produtos.Classes in 'src\Services\MS_MercadoLivre.Service.MercadoLivre.Produtos.Classes.pas',
  MS_MercadoLivre.Controller.Service.Classes in 'src\Controllers\MS_MercadoLivre.Controller.Service.Classes.pas',
  RabbitMQ.AMQP.Classes in '..\shared\Mensageria\RabbitMQ.AMQP.Classes.pas',
  RabbitMQ.Factory.Classes in '..\shared\Mensageria\RabbitMQ.Factory.Classes.pas',
  RabbitMQ.Interfaces in '..\shared\Mensageria\RabbitMQ.Interfaces.pas',
  RabbitMQ.Singleton.Classes in '..\shared\Mensageria\RabbitMQ.Singleton.Classes.pas',
  RabbitMQ.Stomp.Classes in '..\shared\Mensageria\RabbitMQ.Stomp.Classes.pas',
  Conexao.Interfaces in '..\shared\ConexaoBD\Conexao.Interfaces.pas',
  Conexao.Utils.Classes in '..\shared\ConexaoBD\Conexao.Utils.Classes.pas',
  ConfiguracaoBancoDados.Classes in '..\shared\ConexaoBD\Configuracao\ConfiguracaoBancoDados.Classes.pas',
  ConexaoMySql.Classes in '..\shared\ConexaoBD\SGBDs\ConexaoMySql.Classes.pas',
  Conexao.Factory.Classes in '..\shared\ConexaoBD\Factory\Conexao.Factory.Classes.pas',
  Conexao.Singleton.Classes in '..\shared\ConexaoBD\Singleton\Conexao.Singleton.Classes.pas';

begin
  try
    TConexaoSingleton.Instancia;
  except
    On E: Exception do
      WriteLn('Problemas ao se conectar com o banco de dados. ' + E.message);
  end;

  try
    TRabbitMQSingleton.Instancia;
  except
    On E: Exception do
      WriteLn('Problemas ao se conectar com o RabbitMQ. ' + E.message);
  end;

  try
    TMercadoLivre
      .New
      .Produtos(True);
  except
    On E: Exception do
      WriteLn('Problemas ao inciar o consumo da fila de produtos. ' + E.message);
  end;

  THorse.Use(Jhonson);

  TProdutosController.Registry;
  TServiceController.Registry;

  THorse.Listen(3333, procedure
  begin
    WriteLn('Servidor iniciado na porta ' + THorse.Port.ToString);
  end);
end.
