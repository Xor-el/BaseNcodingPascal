unit uBase128;

{$I ..\Include\BaseNcoding.inc}

interface

uses

  uBaseNcodingTypes,
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  uBase,
  uUtils
{$IFDEF FPC}
    , fgl
{$ENDIF};

type

  IBase128 = interface
    ['{15410119-518E-4E56-A9AC-0093564B517F}']

    function Encode(data: TBytes): TBaseNcodingString;
    function Decode(const data: TBaseNcodingString): TBytes;
    function EncodeString(const data: TBaseNcodingString): TBaseNcodingString;
    function DecodeToString(const data: TBaseNcodingString): TBaseNcodingString;
    function GetBitsPerChars: Double;
    property BitsPerChars: Double read GetBitsPerChars;
    function GetCharsCount: UInt32;
    property CharsCount: UInt32 read GetCharsCount;
    function GetBlockBitsCount: Integer;
    property BlockBitsCount: Integer read GetBlockBitsCount;
    function GetBlockCharsCount: Integer;
    property BlockCharsCount: Integer read GetBlockCharsCount;
    function GetAlphabet: TBaseNcodingString;
    property Alphabet: TBaseNcodingString read GetAlphabet;
    function GetSpecial: TBaseNcodingChar;
    property Special: TBaseNcodingChar read GetSpecial;
    function GetHaveSpecial: Boolean;
    property HaveSpecial: Boolean read GetHaveSpecial;
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
    property Encoding: TEncoding read GetEncoding write SetEncoding;

  end;

  TBase128 = class(TBase, IBase128)

  public

    const

    DefaultAlphabet: Array [0 .. 127] of TBaseNcodingChar = ('!', '#', '$', '%',
      '(', ')', '*', ',', '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      ':', ';', '-', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
      'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      '[', ']', '^', '_', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
      'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      '{', '|', '}', '~', '¡', '¢', '£', '¤', '¥', '¦', '§', '¨', '©', 'ª', '«',
      '¬', '®', '¯', '°', '±', '²', '³', '´', 'µ', '¶', '·', '¸', '¹', 'º', '»',
      '¼', '½', '¾', '¿', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê',
      'Ë', 'Ì', 'Í', 'Î');
    DefaultSpecial = '=';

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TBase128.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(128, _Alphabet, _Special, _textEncoding);
end;

function TBase128.GetHaveSpecial: Boolean;
begin
  result := True;
end;

function TBase128.Encode(data: TBytes): TBaseNcodingString;
var
  dataLength, i, length7, tempInt: Integer;
{$IFNDEF FPC}
  tempResult: TStringBuilder;
{$ELSE}
  tempResult: TFPGList<TBaseNcodingString>;
  uS: TBaseNcodingString;
{$ENDIF}
  x1, x2: Byte;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);
{$IFDEF FPC}
  tempResult := TFPGList<TBaseNcodingString>.Create;
  tempResult.Capacity := (dataLength + 6) div 7 * 8;
{$ELSE}
  tempResult := TStringBuilder.Create((dataLength + 6) div 7 * 8);
{$ENDIF}
  try

    length7 := (dataLength div 7) * 7;

    i := 0;
    while i < length7 do
    begin

{$IFDEF FPC}
      x1 := data[i];
      tempResult.Add(Alphabet[(x1 shr 1) + 1]);

      x2 := data[i + 1];
      tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);

      x1 := data[i + 2];
      tempResult.Add(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);

      x2 := data[i + 3];
      tempResult.Add(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);

      x1 := data[i + 4];
      tempResult.Add(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);

      x2 := data[i + 5];
      tempResult.Add(Alphabet[(((x1 shl 2) and $7C) or (x2 shr 6)) + 1]);

      x1 := data[i + 6];
      tempResult.Add(Alphabet[(((x2 shl 1) and $7E) or (x1 shr 7)) + 1]);
      tempResult.Add(Alphabet[(x1 and $7F) + 1]);
      inc(i, 7);
{$ELSE}
      x1 := data[i];
      tempResult.Append(Alphabet[(x1 shr 1) + 1]);

      x2 := data[i + 1];
      tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);

      x1 := data[i + 2];
      tempResult.Append(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);

      x2 := data[i + 3];
      tempResult.Append(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);

      x1 := data[i + 4];
      tempResult.Append(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);

      x2 := data[i + 5];
      tempResult.Append(Alphabet[(((x1 shl 2) and $7C) or (x2 shr 6)) + 1]);

      x1 := data[i + 6];
      tempResult.Append(Alphabet[(((x2 shl 1) and $7E) or (x1 shr 7)) + 1]);
      tempResult.Append(Alphabet[(x1 and $7F) + 1]);
      inc(i, 7);
{$ENDIF}
    end;
    tempInt := dataLength - length7;

    Case tempInt of

      1:
        begin

{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          tempResult.Add(Alphabet[((x1 shl 6) and $40) + 1]);

          tempResult.Add(StringOfChar(Special, 6));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          tempResult.Append(Alphabet[((x1 shl 6) and $40) + 1]);

          tempResult.Append(Special, 6);
{$ENDIF}
        end;
      2:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          tempResult.Add(Alphabet[(((x2 shl 5) and $60)) + 1]);

          tempResult.Add(StringOfChar(Special, 5));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          tempResult.Append(Alphabet[(((x2 shl 5) and $60)) + 1]);

          tempResult.Append(Special, 5);
{$ENDIF}
        end;
      3:
        begin

{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          tempResult.Add(Alphabet[((x1 shl 4) and $70) + 1]);

          tempResult.Add(StringOfChar(Special, 4));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          tempResult.Append(Alphabet[((x1 shl 4) and $70) + 1]);

          tempResult.Append(Special, 4);
{$ENDIF}
        end;
      4:
        begin
{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Add(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          tempResult.Add(Alphabet[((x2 shl 3) and $78) + 1]);

          tempResult.Add(StringOfChar(Special, 3));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          tempResult.Append(Alphabet[((x2 shl 3) and $78) + 1]);

          tempResult.Append(Special, 3);
{$ENDIF}
        end;
      5:
        begin

{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Add(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          x1 := data[i + 4];
          tempResult.Add(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);
          tempResult.Add(Alphabet[((x1 shl 2) and $7C) + 1]);

          tempResult.Add(StringOfChar(Special, 2));
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          x1 := data[i + 4];
          tempResult.Append(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);
          tempResult.Append(Alphabet[((x1 shl 2) and $7C) + 1]);

          tempResult.Append(Special, 2);
{$ENDIF}
        end;
      6:
        begin

{$IFDEF FPC}
          x1 := data[i];
          tempResult.Add(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Add(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Add(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Add(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          x1 := data[i + 4];
          tempResult.Add(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);
          x2 := data[i + 5];
          tempResult.Add(Alphabet[(((x1 shl 2) and $7C) or (x2 shr 6)) + 1]);
          tempResult.Add(Alphabet[((x2 shl 1) and $7E) + 1]);

          tempResult.Add(Special);
{$ELSE}
          x1 := data[i];
          tempResult.Append(Alphabet[(x1 shr 1) + 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[(((x1 shl 6) and $40) or (x2 shr 2)) + 1]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[(((x2 shl 5) and $60) or (x1 shr 3)) + 1]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[(((x1 shl 4) and $70) or (x2 shr 4)) + 1]);
          x1 := data[i + 4];
          tempResult.Append(Alphabet[(((x2 shl 3) and $78) or (x1 shr 5)) + 1]);
          x2 := data[i + 5];
          tempResult.Append(Alphabet[(((x1 shl 2) and $7C) or (x2 shr 6)) + 1]);
          tempResult.Append(Alphabet[((x2 shl 1) and $7E) + 1]);

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

{$OVERFLOWCHECKS OFF}

function TBase128.Decode(const data: TBaseNcodingString): TBytes;
var
  lastSpecialInd, tailLength, x1, x2, length7, i, srcInd: Integer;
begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;
  lastSpecialInd := Length(data);
  while (data[(lastSpecialInd - 1) + 1] = Special) do
  begin
    dec(lastSpecialInd);
  end;
  tailLength := Length(data) - lastSpecialInd;
  SetLength(result, (Length(data) + 7) div 8 * 7 - tailLength);
  length7 := Length(result) div 7 * 7;
  i := 0;
  srcInd := 0;
  while i < length7 do
  begin

    x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);

    result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));

    x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);

    result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));

    x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));

    x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));

    x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));

    x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    result[i + 5] := Byte((x2 shl 6) or ((x1 shr 1) and $3F));

    x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
    inc(srcInd);
    result[i + 6] := Byte((x1 shl 7) or (x2 and $7F));
    inc(i, 7);
  end;
  case tailLength of
    6:
      begin

        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
      end;
    5:
      begin

        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));

        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
      end;
    4:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
      end;
    3:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
      end;
    2:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));
      end;
    1:
      begin
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
        x2 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        inc(srcInd);
        result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        result[i + 5] := Byte((x2 shl 6) or ((x1 shr 1) and $3F));
      end;
  end;
end;

end.
