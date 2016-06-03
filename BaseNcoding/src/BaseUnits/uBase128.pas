unit uBase128;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  uBase,
  uUtils;

type

  IBase128 = interface
    ['{15410119-518E-4E56-A9AC-0093564B517F}']

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

  TBase128 = class(TBase, IBase128)

  public

    const

    DefaultAlphabet =
      '!#$%()*,.0123456789:;-@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎ';

    DefaultSpecial = '=';

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TBase128.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  Inherited Create(128, _Alphabet, _Special, _textEncoding);
end;

function TBase128.GetHaveSpecial: Boolean;
begin
  result := True;
end;

function TBase128.Encode(data: TArray<Byte>): String;
var
  dataLength, i, length7, tempInt: Integer;
  tempResult: TStringBuilder;
  x1, x2: Byte;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);
  tempResult := TStringBuilder.Create((dataLength + 6) div 7 * 8);

  try

    length7 := (dataLength div 7) * 7;

    i := 0;
    while i < length7 do
    begin

      x1 := data[i];
      tempResult.Append(Alphabet[x1 shr 1]);

      x2 := data[i + 1];
      tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);

      x1 := data[i + 2];
      tempResult.Append(Alphabet[((x2 shl 5) and $60) or (x1 shr 3)]);

      x2 := data[i + 3];
      tempResult.Append(Alphabet[((x1 shl 4) and $70) or (x2 shr 4)]);

      x1 := data[i + 4];
      tempResult.Append(Alphabet[((x2 shl 3) and $78) or (x1 shr 5)]);

      x2 := data[i + 5];
      tempResult.Append(Alphabet[((x1 shl 2) and $7C) or (x2 shr 6)]);

      x1 := data[i + 6];
      tempResult.Append(Alphabet[((x2 shl 1) and $7E) or (x1 shr 7)]);
      tempResult.Append(Alphabet[x1 and $7F]);
      inc(i, 7);
    end;

    tempInt := dataLength - length7;

    Case tempInt of

      1:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          tempResult.Append(Alphabet[(x1 shl 6) and $40]);

          tempResult.Append(Special, 6);

        end;
      2:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);
          tempResult.Append(Alphabet[((x2 shl 5) and $60)]);

          tempResult.Append(Special, 5);

        end;
      3:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 5) and $60) or (x1 shr 3)]);
          tempResult.Append(Alphabet[(x1 shl 4) and $70]);

          tempResult.Append(Special, 4);

        end;
      4:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 5) and $60) or (x1 shr 3)]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[((x1 shl 4) and $70) or (x2 shr 4)]);
          tempResult.Append(Alphabet[(x2 shl 3) and $78]);

          tempResult.Append(Special, 3);

        end;
      5:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 5) and $60) or (x1 shr 3)]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[((x1 shl 4) and $70) or (x2 shr 4)]);
          x1 := data[i + 4];
          tempResult.Append(Alphabet[((x2 shl 3) and $78) or (x1 shr 5)]);
          tempResult.Append(Alphabet[(x1 shl 2) and $7C]);

          tempResult.Append(Special, 2);

        end;
      6:
        begin
          x1 := data[i];
          tempResult.Append(Alphabet[x1 shr 1]);
          x2 := data[i + 1];
          tempResult.Append(Alphabet[((x1 shl 6) and $40) or (x2 shr 2)]);
          x1 := data[i + 2];
          tempResult.Append(Alphabet[((x2 shl 5) and $60) or (x1 shr 3)]);
          x2 := data[i + 3];
          tempResult.Append(Alphabet[((x1 shl 4) and $70) or (x2 shr 4)]);
          x1 := data[i + 4];
          tempResult.Append(Alphabet[((x2 shl 3) and $78) or (x1 shr 5)]);
          x2 := data[i + 5];
          tempResult.Append(Alphabet[((x1 shl 2) and $7C) or (x2 shr 6)]);
          tempResult.Append(Alphabet[(x2 shl 1) and $7E]);

          tempResult.Append(Special);

        end;

    end;
    result := tempResult.ToString;

  finally
    tempResult.Free;
  end;

end;

{$OVERFLOWCHECKS OFF}

function TBase128.Decode(const data: String): TArray<Byte>;
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
  while (data[lastSpecialInd - 1] = Special) do
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

    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);

    result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));

    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);

    result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));

    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));

    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));

    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));

    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    result[i + 5] := Byte((x2 shl 6) or ((x1 shr 1) and $3F));

    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    result[i + 6] := Byte((x1 shl 7) or (x2 and $7F));
    inc(i, 7);
  end;
  case tailLength of
    6:
      begin

        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
      end;
    5:
      begin

        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));

        x1 := FInvAlphabet[Ord(data[srcInd])];
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
      end;
    4:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
      end;
    3:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
      end;
    2:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));
      end;
    1:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i] := Byte((x1 shl 1) or ((x2 shr 6) and $01));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 1] := Byte((x2 shl 2) or ((x1 shr 5) and $03));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 2] := Byte((x1 shl 3) or ((x2 shr 4) and $07));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 3] := Byte((x2 shl 4) or ((x1 shr 3) and $0F));
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        result[i + 4] := Byte((x1 shl 5) or ((x2 shr 2) and $1F));
        x1 := FInvAlphabet[Ord(data[srcInd])];
        result[i + 5] := Byte((x2 shl 6) or ((x1 shr 1) and $3F));
      end;
  end;
end;

end.
