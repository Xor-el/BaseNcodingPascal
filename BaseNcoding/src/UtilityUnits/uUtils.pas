unit uUtils;

interface

uses

  System.SysUtils,
  System.Math,
  IntegerX;

type
  TUtils = class(TObject)

  public

    class function CustomMatchStr(InChar: Char; const InString: String)
      : Boolean; static;
    class function IsNullOrEmpty(const InValue: string): Boolean; static;
    class function StartsWith(const InStringOne, InStringTwo: String)
      : Boolean; static;
    class function EndsWith(const InStringOne, InStringTwo: String)
      : Boolean; static;
    class function RetreiveMax(const InString: String): Integer; static;
    class function ArraytoString(const InArray: TArray<Char>): String; static;

  end;

implementation

class function TUtils.CustomMatchStr(InChar: Char;
  const InString: String): Boolean;
var
  i: Integer;

begin
  result := False;
  for i := Low(InString) to High(InString) do

  begin
    if InString[i] = InChar then
    begin
      result := True;
      Exit;
    end;
  end;

end;

class function TUtils.IsNullOrEmpty(const InValue: string): Boolean;

const
  Empty = '';

begin
  result := InValue = Empty;
end;

class function TUtils.StartsWith(const InStringOne,
  InStringTwo: String): Boolean;
var
  tempStr: String;
begin

  tempStr := Copy(InStringOne, Low(InStringOne), 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.EndsWith(const InStringOne, InStringTwo: String): Boolean;
var
  tempStr: string;
begin

  tempStr := Copy(InStringOne, Length(InStringOne) - 1, 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.RetreiveMax(const InString: String): Integer;
var
  i, MaxOrdinal, TempValue: Integer;
begin
  MaxOrdinal := -1;
  for i := Low(InString) to High(InString) do
  begin
    TempValue := Ord(InString[i]);
    MaxOrdinal := Max(MaxOrdinal, TempValue);
  end;
  if MaxOrdinal = -1 then
  begin
    raise Exception.Create('A Strange Error Occurred');
  end
  else
    result := MaxOrdinal;
end;

class function TUtils.ArraytoString(const InArray: TArray<Char>): String;

begin

  SetString(result, PChar(@InArray[0]), Length(InArray));

end;

end.
