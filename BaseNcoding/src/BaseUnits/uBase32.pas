unit uBase32;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  uBase,
  uUtils;

type
  IBase32 = interface
    ['{194EDF16-63BB-47AB-BF6A-F0E72B450F30}']

    function Encode(data: TArray<Byte>): String;
    function Decode(const data: String): TArray<Byte>;
    function EncodeString(const data: String): String;
    function DecodeToString(const data: String): String;
    function GetBitsPerChars: Double;
    property BitsPerChars: Double read GetBitsPerChars;
    function GetCharsCount: UInt32;
    property CharsCount: UInt32 read GetCharsCount;
    function GetBlockBitsCount: Integer;
    property BlockBitsCount: Integer read GetBlockBitsCount;
    function GetBlockCharsCount: Integer;
    property BlockCharsCount: Integer read GetBlockCharsCount;
    function GetAlphabet: String;
    property Alphabet: String read GetAlphabet;
    function GetSpecial: Char;
    property Special: Char read GetSpecial;
    function GetHaveSpecial: Boolean;
    property HaveSpecial: Boolean read GetHaveSpecial;
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
    property Encoding: TEncoding read GetEncoding write SetEncoding;

  end;

  TBase32 = class(TBase, IBase32)

  public

    const

    DefaultAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    DefaultSpecial = '=';

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TBase32.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

begin

  Inherited Create(32, _Alphabet, _Special, _textEncoding);
  FHaveSpecial := True;

end;

function TBase32.Encode(data: TArray<Byte>): String;
var
  dataLength, i, length5, tempInt: Integer;
  tempResult: TStringBuilder;
  x1, x2: Byte;
begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);
  tempResult := TStringBuilder.Create;
  try

    length5 := (dataLength div 5) * 5;
    i := 0;
    while i < length5 do
    begin
      x1 := data[i];
      tempResult.Append(Alphabet[x1 shr 3]);

      x2 := data[i + 1];
      tempResult.Append(Alphabet[((x1 shl 2) and $1C) or (x2 shr 6)]);
      tempResult.Append(Alphabet[(x2 shr 1) and $1F]);

      x1 := data[i + 2];
      tempResult.Append(Alphabet[((x2 shl 4) and $10) or (x1 shr 4)]);

      x2 := data[i + 3];
      tempResult.Append(Alphabet[((x1 shl 1) and $1E) or (x2 shr 7)]);
      tempResult.Append(Alphabet[(x2 shr 2) and $1F]);

      x1 := data[i + 4];
      tempResult.Append(Alphabet[((x2 shl 3) and $18) or (x1 shr 5)]);
      tempResult.Append(Alphabet[x1 and $1F]);
      Inc(i, 5);

    end;

    tempInt := dataLength - length5;

    Case tempInt of
      1:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 3]);
          tempResult.Append(Alphabet[(x1 shl 2) and $1C]);

          tempResult.Append(Special, 4);

        end;

      2:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 3]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 2) and $1C) or (x2 shr 6)]);
          tempResult.Append(Alphabet[(x2 shr 1) and $1F]);
          tempResult.Append(Alphabet[(x2 shl 4) and $10]);

          tempResult.Append(Special, 3);

        end;
      3:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 3]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 2) and $1C) or (x2 shr 6)]);
          tempResult.Append(Alphabet[(x2 shr 1) and $1F]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 4) and $10) or (x1 shr 4)]);
          tempResult.Append(Alphabet[(x1 shl 1) and $1E]);

          tempResult.Append(Special, 2);

        end;
      4:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 3]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 2) and $1C) or (x2 shr 6)]);
          tempResult.Append(Alphabet[(x2 shr 1) and $1F]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 4) and $10) or (x1 shr 4)]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[((x1 shl 1) and $1E) or (x2 shr 7)]);
          tempResult.Append(Alphabet[(x2 shr 2) and $1F]);
          tempResult.Append(Alphabet[(x2 shl 3) and $18]);

          tempResult.Append(Special);

        end;
    end;
    result := tempResult.ToString;
  finally
    tempResult.Free;
  end;

end;

function TBase32.Decode(const data: String): TArray<Byte>;
var
  lastSpecialInd, tailLength, length5, i, srcInd, x1, x2, x3, x4, x5, x6, x7,
    x8: Integer;

begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;
  lastSpecialInd := Length(data);
  while (data[lastSpecialInd - 1] = Special) do
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
    x1 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x2 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x3 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x4 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x5 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x6 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x7 := FInvAlphabet[Ord(data[srcInd])];
    Inc(srcInd);
    x8 := FInvAlphabet[Ord(data[srcInd])];
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
        x1 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
      end;
    3:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[srcInd])];

        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
        result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
          ((x4 shr 4) and $01));
      end;
    2:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x5 := FInvAlphabet[Ord(data[srcInd])];

        result[i] := Byte((x1 shl 3) or ((x2 shr 2) and $07));
        result[i + 1] := Byte((x2 shl 6) or ((x3 shl 1) and $3E) or
          ((x4 shr 4) and $01));
        result[i + 2] := Byte((x4 shl 4) or ((x5 shr 1) and $F));
      end;
    1:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x3 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x4 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x5 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x6 := FInvAlphabet[Ord(data[srcInd])];
        Inc(srcInd);
        x7 := FInvAlphabet[Ord(data[srcInd])];

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
