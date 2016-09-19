unit uBase32;

{$I ..\Include\BaseNcoding.inc}

interface

uses

{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils
{$ELSE}
    SysUtils
{$ENDIF}
{$IFDEF FPC}
    , fgl
{$ENDIF}
    , uBase,
  uIBaseInterfaces,
  uBaseNcodingTypes,
  uUtils;

type

  TBase32 = class sealed(TBase, IBase32)

  public

    const

    DefaultAlphabet: array [0 .. 31] of TBaseNcodingChar = ('A', 'B', 'C', 'D',
      'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
      'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '2', '3', '4', '5', '6', '7');

    DefaultSpecial = TBaseNcodingChar('=');

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TBase32.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _textEncoding: TEncoding = Nil);

begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(32, _Alphabet, _Special, _textEncoding);
end;

function TBase32.GetHaveSpecial: Boolean;
begin
  result := True;
end;

function TBase32.Encode(data: TBytes): TBaseNcodingString;
var
  dataLength, i, length5, tempInt: Integer;
{$IFNDEF FPC}
  tempResult: TStringBuilder;
{$ELSE}
  tempResult: TFPGList<TBaseNcodingString>;
  uS: TBaseNcodingString;
{$ENDIF}
  x1, x2: Byte;
begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    result := ('');
    Exit;
  end;

  dataLength := Length(data);
{$IFDEF FPC}
  tempResult := TFPGList<TBaseNcodingString>.Create;
{$ELSE}
  tempResult := TStringBuilder.Create;
{$ENDIF}
  try

    length5 := (dataLength div 5) * 5;
    i := 0;
    while i < length5 do
    begin
{$IFDEF FPC}
      x1 := data[i];
      tempResult.Add(Alphabet[(x1 shr 3) + 1]);

      x2 := data[i + 1];
      tempResult.Add(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
      tempResult.Add(Alphabet[((x2 shr 1) and $1F) + 1]);

      x1 := data[i + 2];
      tempResult.Add(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);

      x2 := data[i + 3];
      tempResult.Add(Alphabet[(((x1 shl 1) and $1E) or (x2 shr 7)) + 1]);
      tempResult.Add(Alphabet[((x2 shr 2) and $1F) + 1]);

      x1 := data[i + 4];
      tempResult.Add(Alphabet[(((x2 shl 3) and $18) or (x1 shr 5)) + 1]);
      tempResult.Add(Alphabet[(x1 and $1F) + 1]);
      Inc(i, 5);

{$ELSE}
      x1 := data[i];
      tempResult.Append(Alphabet[(x1 shr 3) + 1]);

      x2 := data[i + 1];
      tempResult.Append(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
      tempResult.Append(Alphabet[((x2 shr 1) and $1F) + 1]);

      x1 := data[i + 2];
      tempResult.Append(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);

      x2 := data[i + 3];
      tempResult.Append(Alphabet[(((x1 shl 1) and $1E) or (x2 shr 7)) + 1]);
      tempResult.Append(Alphabet[((x2 shr 2) and $1F) + 1]);

      x1 := data[i + 4];
      tempResult.Append(Alphabet[(((x2 shl 3) and $18) or (x1 shr 5)) + 1]);
      tempResult.Append(Alphabet[(x1 and $1F) + 1]);
      Inc(i, 5);

{$ENDIF}
    end;

    tempInt := dataLength - length5;

    Case tempInt of
      1:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 3) + 1]);
          tempResult.Add(Alphabet[((x1 shl 2) and $1C) + 1]);

          tempResult.Add(StringOfChar(Special, 4));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 3) + 1]);
          tempResult.Append(Alphabet[((x1 shl 2) and $1C) + 1]);

          tempResult.Append(Special, 4);
{$ENDIF}
        end;

      2:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Add(Alphabet[((x2 shr 1) and $1F) + 1]);
          tempResult.Add(Alphabet[((x2 shl 4) and $10) + 1]);

          tempResult.Add(StringOfChar(Special, 3));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Append(Alphabet[((x2 shr 1) and $1F) + 1]);
          tempResult.Append(Alphabet[((x2 shl 4) and $10) + 1]);

          tempResult.Append(Special, 3);
{$ENDIF}
        end;
      3:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Add(Alphabet[((x2 shr 1) and $1F) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);
          tempResult.Add(Alphabet[((x1 shl 1) and $1E) + 1]);

          tempResult.Add(StringOfChar(Special, 2));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Append(Alphabet[((x2 shr 1) and $1F) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);
          tempResult.Append(Alphabet[((x1 shl 1) and $1E) + 1]);

          tempResult.Append(Special, 2);
{$ENDIF}
        end;
      4:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Add(Alphabet[((x2 shr 1) and $1F) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);
          x2 := data[i + 3];
          tempResult.Add(Alphabet[(((x1 shl 1) and $1E) or (x2 shr 7)) + 1]);
          tempResult.Add(Alphabet[((x2 shr 2) and $1F) + 1]);
          tempResult.Add(Alphabet[((x2 shl 3) and $18) + 1]);

          tempResult.Add(Special);
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 3) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 2) and $1C) or (x2 shr 6)) + 1]);
          tempResult.Append(Alphabet[((x2 shr 1) and $1F) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 4) and $10) or (x1 shr 4)) + 1]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[(((x1 shl 1) and $1E) or (x2 shr 7)) + 1]);
          tempResult.Append(Alphabet[((x2 shr 2) and $1F) + 1]);
          tempResult.Append(Alphabet[((x2 shl 3) and $18) + 1]);

          tempResult.Append(Special);
{$ENDIF}
        end;
    end;
{$IFDEF FPC}
    result := '';
    for uS in tempResult do
    begin
      result := result + uS;
    end;
{$ELSE}
    result := tempResult.ToString;
{$ENDIF}
  finally
    tempResult.Free;
  end;

end;

function TBase32.Decode(const data: TBaseNcodingString): TBytes;
var
  lastSpecialInd, tailLength, length5, i, srcInd, x1, x2, x3, x4, x5, x6, x7,
    x8: Integer;

begin
  if TUtils.IsNullOrEmpty(data) then

  begin

    result := Nil;
    Exit;
  end;
  lastSpecialInd := Length(data);
  while (data[(lastSpecialInd - 1) + 1] = Special) do
  begin
    dec(lastSpecialInd);
  end;
  tailLength := Length(data) - lastSpecialInd;
  SetLength(result, (((Length(data)) + 7) div 8 * 5 - tailLength));
  length5 := Length(result) div 5 * 5;
  i := 0;
  srcInd := 0;

  while i < length5 do
  begin
    x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x3 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x4 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x5 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x6 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x7 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);
    x8 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    Inc(srcInd);

    result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
    result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
      ((x4 shr 4) and $01));
    result[i + 2] := Byte((x4 shl 4) or ((x5 shr 1) and $F));
    result[i + 3] := Byte((x5 shl 7) or ((x6 shl 2) and $7C) or
      ((x7 shr 3) and $03));
    result[i + 4] := Byte((x7 shl 5) or (x8 and $1F));
    Inc(i, 5);
  end;

  case tailLength of
    4:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
      end;
    3:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[(srcInd) + 1])];

        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
        result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
          ((x4 shr 4) and $01));
      end;
    2:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x5 := FInvAlphabet[Ord(data[(srcInd) + 1])];

        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
        result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
          ((x4 shr 4) and $01));
        result[i + 2] := Byte((x4 shl 4) or ((x5 shr 1) and $F));
      end;
    1:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x5 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x6 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        Inc(srcInd);
        x7 := FInvAlphabet[Ord(data[(srcInd) + 1])];

        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
        result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
          ((x4 shr 4) and $01));
        result[i + 2] := Byte((x4 shl 4) or ((x5 shr 1) and $F));
        result[i + 3] := Byte((x5 shl 7) or ((x6 shl 2) and $7C) or
          ((x7 shr 3) and $03));
      end;
  end;

end;

end.
