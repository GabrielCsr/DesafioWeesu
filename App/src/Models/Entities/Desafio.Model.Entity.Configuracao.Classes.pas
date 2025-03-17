unit Desafio.Model.Entity.Configuracao.Classes;

interface

type
  TConfiguracao = class
  private
    FNome:  String;
    FValor: String;
    function GetNome: String;
    procedure SetNome(const Value: String);
    function GetValor: String;
    procedure SetValor(const Value: String);
  public
    constructor Create(ANome: String = ''; AValor: String = '');
    property Nome: String read GetNome write SetNome;
    property Valor: String read GetValor write SetValor;
  end;

implementation

uses
  SysUtils;

{ TConfiguracao }

constructor TConfiguracao.Create(ANome, AValor: String);
begin
  FNome := ANome;
  FValor := AValor;
end;

function TConfiguracao.GetNome: String;
begin
  Result := FNome;
end;

function TConfiguracao.GetValor: String;
begin
  Result := FValor;
end;

procedure TConfiguracao.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TConfiguracao.SetValor(const Value: String);
begin
  FValor := Value;
end;

end.
