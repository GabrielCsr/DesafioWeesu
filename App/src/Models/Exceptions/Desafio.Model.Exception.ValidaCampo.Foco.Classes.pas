unit Desafio.Model.Exception.ValidaCampo.Foco.Classes;

interface

uses
  FMX.Forms, System.Classes;

type
  IFocoValidaCampo = interface
    ['{A5AA4CA6-EAF4-4BA3-AAB7-FA0EDC7F6C30}']
    function FocarNoCampo(ACampo: String): IFocoValidaCampo;
    function GerarCaixaDeDialogo(AMensagem: String): IFocoValidaCampo;
  end;

  TFocoValidaCampo = class(TInterfacedObject, IFocoValidaCampo)
  private
    FForm: TForm;
    function EncontraComponentePeloNome(ANome: String): TComponent;
  public
    constructor Create(AForm: TForm);
    class function New(AForm: TForm): IFocoValidaCampo;
    function FocarNoCampo(ACampo: String): IFocoValidaCampo;
    function GerarCaixaDeDialogo(AMensagem: String): IFocoValidaCampo;
  end;

implementation

uses
  FMX.Edit, FMX.Dialogs;

{ TFocoValidaCampo }

constructor TFocoValidaCampo.Create(AForm: TForm);
begin
  FForm := AForm;
end;

function TFocoValidaCampo.EncontraComponentePeloNome(ANome: String): TComponent;
begin
  Result := FForm.FindComponent('edt' + ANome);
end;

function TFocoValidaCampo.FocarNoCampo(ACampo: String): IFocoValidaCampo;
var
  LComponente: TComponent;
begin
  LComponente := EncontraComponentePeloNome(ACampo);
  if not Assigned(LComponente) then
    Exit;

  TEdit(LComponente).SetFocus;
end;

function TFocoValidaCampo.GerarCaixaDeDialogo(AMensagem: String): IFocoValidaCampo;
begin
  ShowMessage(AMensagem);
end;

class function TFocoValidaCampo.New(AForm: TForm): IFocoValidaCampo;
begin
  Result := Self.Create(AForm);
end;

end.
