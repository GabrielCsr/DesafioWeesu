program Desafio;

uses
  System.StartUpCopy,
  FMX.Forms,
  Desafio.View.Principal in 'src\Views\Desafio.View.Principal.pas' {frmPrincipal},
  System.SysUtils,
  FMX.Dialogs,
  Desafio.View.Configuracoes in 'src\Views\Desafio.View.Configuracoes.pas' {frmConfiguracoes},
  Desafio.Model.Entity.Configuracao.Classes in 'src\Models\Entities\Desafio.Model.Entity.Configuracao.Classes.pas',
  Desafio.Controller.Configuracoes.Classes in 'src\Controllers\Desafio.Controller.Configuracoes.Classes.pas',
  Desafio.Model.Exception.ValidaCampo.Classes in 'src\Models\Exceptions\Desafio.Model.Exception.ValidaCampo.Classes.pas',
  Desafio.Controller.Exceptions.Classes in 'src\Controllers\Desafio.Controller.Exceptions.Classes.pas',
  Desafio.Model.Exception.ValidaCampo.Foco.Classes in 'src\Models\Exceptions\Desafio.Model.Exception.ValidaCampo.Foco.Classes.pas',
  Desafio.Model.Configuracoes.Classes in 'src\Models\Desafio.Model.Configuracoes.Classes.pas',
  Desafio.Service.Configuracoes.Classes in 'src\Services\Desafio.Service.Configuracoes.Classes.pas',
  Desafio.Service.MercadoLivre.Classes in 'src\Services\MercadoLivre\Desafio.Service.MercadoLivre.Classes.pas',
  Desafio.Model.MercadoLivre.Classes in 'src\Models\MercadoLivre\Desafio.Model.MercadoLivre.Classes.pas',
  Desafio.Utils in 'src\Utils\Desafio.Utils.pas',
  Desafio.View.MercadoLivre in 'src\Views\Desafio.View.MercadoLivre.pas' {frmMercadoLivre},
  Desafio.Model.Entity.Token.Classes in 'src\Models\Entities\Desafio.Model.Entity.Token.Classes.pas',
  Desafio.Controller.MercadoLivre.Classes in 'src\Controllers\MercadoLivre\Desafio.Controller.MercadoLivre.Classes.pas',
  Desafio.Model.Entity.MercadoLivre.Produto.Classes in 'src\Models\Entities\MercadoLivre\Desafio.Model.Entity.MercadoLivre.Produto.Classes.pas',
  Desafio.View.Loading in 'src\Views\Desafio.View.Loading.pas' {frmLoading},
  RabbitMQ.AMQP.Classes in '..\shared\Mensageria\RabbitMQ.AMQP.Classes.pas',
  RabbitMQ.Factory.Classes in '..\shared\Mensageria\RabbitMQ.Factory.Classes.pas',
  RabbitMQ.Interfaces in '..\shared\Mensageria\RabbitMQ.Interfaces.pas',
  RabbitMQ.Singleton.Classes in '..\shared\Mensageria\RabbitMQ.Singleton.Classes.pas',
  RabbitMQ.Stomp.Classes in '..\shared\Mensageria\RabbitMQ.Stomp.Classes.pas',
  Conexao.Interfaces in '..\shared\ConexaoBD\Conexao.Interfaces.pas',
  Conexao.Utils.Classes in '..\shared\ConexaoBD\Conexao.Utils.Classes.pas',
  Conexao.Singleton.Classes in '..\shared\ConexaoBD\Singleton\Conexao.Singleton.Classes.pas',
  ConexaoMySql.Classes in '..\shared\ConexaoBD\SGBDs\ConexaoMySql.Classes.pas',
  Conexao.Factory.Classes in '..\shared\ConexaoBD\Factory\Conexao.Factory.Classes.pas',
  ConfiguracaoBancoDados.Classes in '..\shared\ConexaoBD\Configuracao\ConfiguracaoBancoDados.Classes.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLoading, frmLoading);
  try
    TConexaoSingleton.Instancia;
  except
    On E: Exception do
    begin
      ShowMessage(E.Message);
      Application.Terminate;
      Exit;
    end;
  end;
  Application.Run;
end.
