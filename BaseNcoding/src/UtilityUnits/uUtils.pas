unit uUtils;

{$I ..\Include\BaseNcoding.inc}

interface

uses

  uBaseNcodingTypes,
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Math;
{$ELSE}
SysUtils,
  Math;
{$ENDIF}

type

  TUtils = class(TObject)

  public

    class function CustomMatchStr(InChar: TBaseNcodingChar;
      const InString: TBaseNcodingString): Boolean; static;
    class function IsNullOrEmpty(const InValue: TBaseNcodingString)
      : Boolean; static;
    class function StartsWith(const InStringOne, InStringTwo
      : TBaseNcodingString): Boolean; static;
    class function EndsWith(const InStringOne, InStringTwo: TBaseNcodingString)
      : Boolean; static;
    class function RetreiveMax(const InString: TBaseNcodingString)
      : Integer; static;
    class function ArraytoString(const InArray: TBaseNcodingCharArray)
      : TBaseNcodingString; static;

  end;

implementation

class function TUtils.CustomMatchStr(InChar: TBaseNcodingChar;
  const InString: TBaseNcodingString): Boolean;
var
  i: Integer;

begin
  result := False;
  for i := 1 to Length(InString) do

  begin
    if InString[i] = InChar then
    begin
      result := True;
      Exit;
    end;
  end;

end;

class function TUtils.IsNullOrEmpty(const InValue: TBaseNcodingString): Boolean;

const
  Empty = '';

begin
  result := InValue = Empty;
end;

class function TUtils.StartsWith(const InStringOne,
  InStringTwo: TBaseNcodingString): Boolean;
var
  tempStr: TBaseNcodingString;
begin

  tempStr := Copy(InStringOne, 1, 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.EndsWith(const InStringOne,
  InStringTwo: TBaseNcodingString): Boolean;
var
  tempStr: TBaseNcodingString;
begin

  tempStr := Copy(InStringOne, Length(InStringOne) - 1, 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.RetreiveMax(const InString: TBaseNcodingString): Integer;
var
  i, MaxOrdinal, TempValue: Integer;
begin
  MaxOrdinal := -1;
  for i := 1 to Length(InString) do
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

class function TUtils.ArraytoString(const InArray: TBaseNcodingCharArray)
  : TBaseNcodingString;

begin

  SetString(result, PBaseNcodingChar(@InArray[0]), Length(InArray));

end;

end.
