unit Desafio.Controller.Configuracoes.Classes;

interface

uses
  Desafio.Model.Configuracoes.Classes, System.Generics.Collections,
  Desafio.Model.Entity.Configuracao.Classes, SysUtils, FMX.Forms;

type
  IControllerConfiguracoes = interface
    ['{4BC6CA95-48DE-41E7-B434-97467BE369E5}']
    function SalvarConfiguracoes: Boolean;
    procedure GerarCode;
    procedure ConsultarConfiguracoes;
    function IDAplicacao:  String; overload;
    function ChaveSecreta: String; overload;
    function URIRedirect:  String; overload;
    function Code:         String; overload;
    function IDAplicacao(AValue: String):  IControllerConfiguracoes; overload;
    function ChaveSecreta(AValue: String): IControllerConfiguracoes; overload;
    function URIRedirect(AValue: String):  IControllerConfiguracoes; overload;
    function Code(AValue: String):         IControllerConfiguracoes; overload;
  end;

  TControllerConfiguracoes = class(TInterfacedObject, IControllerConfiguracoes)
  private
    FIDAplicacao:  String;
    FChaveSecreta: String;
    FURIRedirect:  String;
    FCode:         String;
    FModel: IModelConfiguracoes;
    procedure PreencherConfiguracoes;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    class function New(AForm: TForm): IControllerConfiguracoes;
    function SalvarConfiguracoes: Boolean;
    procedure GerarCode;
    procedure ConsultarConfiguracoes;
    function IDAplicacao:  String; overload;
    function ChaveSecreta: String; overload;
    function URIRedirect:  String; overload;
    function Code:         String; overload;
    function IDAplicacao(AValue: String):  IControllerConfiguracoes; overload;
    function ChaveSecreta(AValue: String): IControllerConfiguracoes; overload;
    function URIRedirect(AValue: String):  IControllerConfiguracoes; overload;
    function Code(AValue: String):         IControllerConfiguracoes; overload;
  end;

implementation

uses
  Desafio.Model.Exception.ValidaCampo.Classes, Desafio.Utils;

{ TControllerConfiguracoes }

function TControllerConfiguracoes.ChaveSecreta: String;
begin
  Result := FChaveSecreta;
end;

function TControllerConfiguracoes.ChaveSecreta(
  AValue: String): IControllerConfiguracoes;
begin
  Result := Self;
  FChaveSecreta := AValue;
end;

function TControllerConfiguracoes.Code: String;
begin
  Result := FCode;
end;

function TControllerConfiguracoes.Code(
  AValue: String): IControllerConfiguracoes;
begin
  Result := Self;
  FCode := AValue;
end;

procedure TControllerConfiguracoes.ConsultarConfiguracoes;
begin
  FModel.ConsultarConfiguracoes;
  FIDAplicacao  := FModel.IDAplicacao;
  FChaveSecreta := FModel.ChaveSecreta;
  FCode         := FModel.Code;
  FURIRedirect  := FModel.URIRedirect;
end;

constructor TControllerConfiguracoes.Create(AForm: TForm);
begin
  FModel := TModelConfiguracoes.New(AForm);
end;

destructor TControllerConfiguracoes.Destroy;
begin

  inherited;
end;

procedure TControllerConfiguracoes.GerarCode;
begin
  PreencherConfiguracoes;
  FModel.GerarCode;
end;

function TControllerConfiguracoes.IDAplicacao: String;
begin
  Result := FIDAplicacao;
end;

function TControllerConfiguracoes.IDAplicacao(
  AValue: String): IControllerConfiguracoes;
begin
  Result := Self;
  FIDAplicacao := AValue;
end;

class function TControllerConfiguracoes.New(AForm: TForm): IControllerConfiguracoes;
begin
  Result := Self.Create(AForm);
end;

procedure TControllerConfiguracoes.PreencherConfiguracoes;
begin
  FModel
    .IDAplicacao(FIDAplicacao)
    .ChaveSecreta(FChaveSecreta)
    .URIRedirect(FURIRedirect)
    .Code(FCode);
end;

function TControllerConfiguracoes.SalvarConfiguracoes: Boolean;
begin
  PreencherConfiguracoes;
  Result := FModel.SalvarConfiguracoes;
end;

function TControllerConfiguracoes.URIRedirect: String;
begin
  Result := FURIRedirect;
end;

function TControllerConfiguracoes.URIRedirect(
  AValue: String): IControllerConfiguracoes;
begin
  Result := Self;
  FURIRedirect := AValue;
end;

end.
