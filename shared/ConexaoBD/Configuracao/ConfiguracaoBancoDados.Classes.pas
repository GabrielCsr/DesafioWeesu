unit ConfiguracaoBancoDados.Classes;

interface

type
  TInformacoesConexao = record
    SGBD,
    Servidor,
    Usuario,
    Senha,
    BancoDados: String;
  end;

  TConfigBancoDados = class
  private
    class procedure CriarArquivo;
  public
    class function CarregarConfiguracoes(const ANomeArquivo: String = 'config.ini'): TInformacoesConexao;
  end;

implementation

uses
  System.IniFiles, System.SysUtils, System.StrUtils;

{ TConfigBancoDados }

class function TConfigBancoDados.CarregarConfiguracoes(
  const ANomeArquivo: String): TInformacoesConexao;
var
  LArquivo: TIniFile;
  LCaminhoArquivo: String;
  LInformacoes: TInformacoesConexao;
begin
  Result := LInformacoes;
  LCaminhoArquivo := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + ANomeArquivo;
  LArquivo := nil;
  try
    try
      if not FileExists(LCaminhoArquivo) then
        CriarArquivo;

      LArquivo := TIniFile.Create(LCaminhoArquivo);

      LInformacoes.SGBD       := LArquivo.ReadString('Database', 'SGBD', '');
      LInformacoes.Servidor   := LArquivo.ReadString('Database', 'Servidor', '');
      LInformacoes.Usuario    := LArquivo.ReadString('Database', 'Usuario', '');
      LInformacoes.Senha      := LArquivo.ReadString('Database', 'Senha', '');
      LInformacoes.BancoDados := LArquivo.ReadString('Database', 'Database', '');

      if MatchStr(EmptyStr, [LInformacoes.Servidor, LInformacoes.Usuario, LInformacoes.Senha, LInformacoes.BancoDados]) then
        raise Exception.Create('Algumas configurações necessárias para conexão com o banco de dados ' +
                                'não estão preenchidas no arquivo "config.ini". ' +
                                'Preencher corretamente e reiniciar a aplicação ');

      Result := LInformacoes;
    except
      On E: Exception do
        raise Exception.Create('Problemas ao carregar as configurações do sistema. ' + E.Message);
    end;
  finally
    if Assigned(LArquivo) then
      LArquivo.Free;
  end;
end;

class procedure TConfigBancoDados.CriarArquivo;
var
  LArquivo: TIniFile;
begin
  LArquivo := TIniFile.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'config.ini');
  try
    LArquivo.WriteString('Database', 'SGBD', 'MySQL');
    LArquivo.WriteString('Database', 'Servidor', 'localhost');
    LArquivo.WriteString('Database', 'Usuario', 'root');
    LArquivo.WriteString('Database', 'Senha', 'desafio123');
    LArquivo.WriteString('Database', 'Database', 'desafio');
  finally
    LArquivo.Free;
  end;
end;

end.
