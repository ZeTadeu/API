program Api;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse, Horse.Jhonson, Horse.BasicAuthentication, System.JSON, System.SysUtils;

var
  App : THorse;
  Users: TJSONArray;

begin
  App := THorse.Create(9000);

  App.Use(Jhonson);

  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('ze') and APassword.Equals('123');
    end));

  Users := TJSONArray.Create;

  App.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

  App.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      User : TJSONObject;
    begin
      User := Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.Created);
    end);

  App.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      id: Integer;
    begin
      id := Req.Params.Items['id'].ToInteger;
      Users.Remove(Pred(id)).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);

  App.Start;
end.
