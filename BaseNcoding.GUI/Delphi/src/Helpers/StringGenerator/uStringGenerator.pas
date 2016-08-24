unit uStringGenerator;

interface

uses

  SysUtils, Math;

type

  TStringGenerator = class(TObject)

  strict private
    class function IsWhiteSpace(const Ch: Char): Boolean; static;
    class function IsControl(const Ch: Char): Boolean; static;
  public
    class function GetAlphabet(charsCount: Integer): String; static;
    class function GetRandom(size: Integer; onlyLettersAndDigits: Boolean)
      : String; static;

  end;

implementation

// replicated from 'cUnicode.pas' in 'Fundamentals Library 4.0.0 v4.12' with some
// additions.

class function TStringGenerator.IsWhiteSpace(const Ch: Char): Boolean;
begin
  case Ch of
    #$0009 .. #$000D, // ASCII CONTROL
    #$0020, // SPACE
    #$0085, // <control>
    #$00A0, // NO-BREAK SPACE
    #$1680, // OGHAM SPACE MARK
    #$2000 .. #$200A, // EN QUAD..HAIR SPACE
    #$202F, // NO-BREAK SPACE
    #$2028, // LINE SEPARATOR
    #$2029, // PARAGRAPH SEPARATOR
    #$205F, // MATHEMATICAL SPACE
    #$3000: // IDEOGRAPHIC SPACE
      Result := True;
  else
    Result := False;
  end;
end;

// replicated from 'cUnicode.pas' in 'Fundamentals Library 4.0.0 v4.12' with additions.

class function TStringGenerator.IsControl(const Ch: Char): Boolean;
begin
  case Ch of
    #$0000 .. #$001F, #$007F .. #$009F:
      Result := True;
  else
    Result := False;
  end;
end;

class function TStringGenerator.GetAlphabet(charsCount: Integer): String;
var
  i, count: Integer;
  c: Char;
  tempResult: TStringBuilder;

begin
  tempResult := TStringBuilder.Create;
  tempResult.Clear;
  try
    i := 0;
    count := 0;

    while (count < charsCount) do
    begin

      c := Char(i);

      if (not IsControl(c)) and (not IsWhiteSpace(c)) then

      begin

        tempResult.Append(c);
        Inc(count);
      end;
      Inc(i);
    end;
    Result := tempResult.ToString;
  finally
    tempResult.Free;
  end;
end;

class function TStringGenerator.GetRandom(size: Integer;
  onlyLettersAndDigits: Boolean): String;
var
  i: Integer;
  lettersAndDigits: String;
  tempResult: TStringBuilder;
  data: TBytes;

begin
  Result := '';
  tempResult := TStringBuilder.Create(size);
  try
    Randomize;
    if (onlyLettersAndDigits) then
    begin
      lettersAndDigits :=
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      i := 0;
      while i < size do
      begin
        tempResult.Append(lettersAndDigits
          [Random(Length(lettersAndDigits)) + 1]);
        Inc(i);
      end;
      Result := tempResult.ToString;
    end
    else
    begin
      SetLength(data, size);
      i := 0;

      while i < (size) do

      begin
        data[i] := Byte(RandomRange(32, 127));
        Inc(i);
      end;
      Result := TEncoding.ASCII.GetString(data);
    end;

  finally
    tempResult.Free;

  end;

end;

end.
