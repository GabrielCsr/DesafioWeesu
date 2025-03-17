unit Desafio.Model.Entity.Token.Classes;

interface

uses
  System.JSON, System.SysUtils, System.Classes;

type
  TToken = class
  private
    FAccessToken: string;
    FTokenType: string;
    FRefreshToken: string;
    FIdToken: Int64;
    FIdUsuario: Int64;
    FExpiraEm: Integer;
    FCriadoEm: TDateTime;
    FAtualizadoEm: TDateTime;
  public
    property IdToken: Int64 read FIdToken write FIdToken;
    property IdUsuario: Int64 read FIdUsuario write FIdUsuario;
    property AccessToken: string read FAccessToken write FAccessToken;
    property TokenType: string read FTokenType write FTokenType;
    property ExpiraEm: Integer read FExpiraEm write FExpiraEm;
    property RefreshToken: string read FRefreshToken write FRefreshToken;
    property CriadoEm: TDateTime read FCriadoEm write FCriadoEm;
    property AtualizadoEm: TDateTime read FAtualizadoEm write FAtualizadoEm;

    constructor Create(); overload;
    constructor Create(AAccessToken,
                       ARefreshToken: String;
                       AExpiraEm: Integer;
                       ACriadoEm,
                       AAtualizadoEm: TDateTime); overload;

    class function FromJSON(AJSON: string): TToken;
  end;

implementation

{ TToken }

constructor TToken.Create;
begin

end;

constructor TToken.Create(AAccessToken,
                          ARefreshToken: String;
                          AExpiraEm: Integer;
                          ACriadoEm,
                          AAtualizadoEm: TDateTime);
begin
  FIdUsuario    := 000000000001;
  FAccessToken  := AAccessToken;
  FRefreshToken := ARefreshToken;
  FExpiraEm     := AExpiraEm;
  FCriadoEm     := ACriadoEm;
  FAtualizadoEm := AAtualizadoEm;
end;

class function TToken.FromJSON(AJSON: string): TToken;
var
  JSONObject: TJSONObject;
  LData: TDateTime;
begin
  Result := TToken.Create;
  JSONObject := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
  try
    if Assigned(JSONObject) then
    begin
      LData := Now;

      Result.IdUsuario    := 000000000001;
      Result.AccessToken  := JSONObject.GetValue<string>('access_token');
      Result.TokenType    := JSONObject.GetValue<string>('token_type');
      Result.ExpiraEm     := JSONObject.GetValue<Integer>('expires_in');
      Result.RefreshToken := JSONObject.GetValue<string>('refresh_token');
      Result.CriadoEm     := LData;
      Result.AtualizadoEm := LData;
    end;
  finally
    JSONObject.Free;
  end;
end;

end.
