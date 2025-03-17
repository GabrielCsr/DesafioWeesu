unit Desafio.Model.Exception.ValidaCampo.Classes;

interface

uses
  System.SysUtils;

type
  TValidaCampo = class(Exception)
  private
  public
    FCampo: String;
    FMensagem: String;
    constructor Create(ACampo: String; AMensagem: String);
  end;

implementation

{ TValidaCampo }

constructor TValidaCampo.Create(ACampo, AMensagem: String);
begin
  FCampo := ACampo;
  FMensagem := AMensagem;
end;

end.
