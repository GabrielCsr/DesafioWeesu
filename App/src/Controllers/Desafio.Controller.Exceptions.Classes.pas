unit Desafio.Controller.Exceptions.Classes;

interface

uses
  System.SysUtils, FMX.Forms, System.Classes, FMX.TabControl, FMX.Controls,
  FMX.Types, Desafio.Model.Exception.ValidaCampo.Classes,
  Desafio.Model.Exception.ValidaCampo.Foco.Classes;

type
  IControllerExceptions = interface
    ['{1C1038F6-8C36-4A38-B0B5-BDDBE9A855A6}']
  end;

  TControllerExceptions = class(TInterfacedObject, IControllerExceptions)
  private
    FForm: TForm;
    FFocoValidaCampo: IFocoValidaCampo;
    procedure Exceptions(Sender: TObject; E: Exception);
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    class function New(AForm: TForm): IControllerExceptions;
  end;

implementation

uses
  FMX.Dialogs;

{ TControllerExceptions }

constructor TControllerExceptions.Create(AForm: TForm);
begin
  FForm := AForm;
  FFocoValidaCampo := TFocoValidaCampo.New(FForm);
  Application.OnException := Exceptions;
end;

destructor TControllerExceptions.Destroy;
begin

  inherited;
end;

procedure TControllerExceptions.Exceptions(Sender: TObject; E: Exception);
begin
  if E.ClassName.Equals('TValidaCampo') then
  begin
    FFocoValidaCampo
      .FocarNoCampo(TValidaCampo(E).FCampo)
      .GerarCaixaDeDialogo(TValidaCampo(E).FMensagem);
  end
  else
    ShowMessage(E.Message);
end;

class function TControllerExceptions.New(AForm: TForm): IControllerExceptions;
begin
  Result := Self.Create(AForm);
end;

end.
