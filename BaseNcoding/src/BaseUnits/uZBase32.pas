unit uZBase32;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  System.Math,
  System.Generics.Collections,
  uBase,
  uUtils;

type

  IZBase32 = interface
    ['{96264326-C333-4642-A9C6-BDEA183E6597}']

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

  TZBase32 = class(TBase, IZBase32)

  strict private

    function CreateIndexByOctetAndMovePosition(data: String;
      currentPosition: Integer; var index: TArray<Integer>): Integer;

  public

    const

    DefaultAlphabet = 'ybndrfg8ejkmcpqxot1uwisza345h769';
    DefaultSpecial = Char(0);

    /// <summary>
    /// From: https://github.com/denxc/ZBase32Encoder/blob/master/ZBase32Encoder/ZBase32Encoder/ZBase32Encoder.cs
    /// </summary>

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TZBase32.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  Inherited Create(32, _Alphabet, _Special, _textEncoding);
  FHaveSpecial := False;
end;

{$IFNDEF _FIXINSIGHT_}  // tells FixInsight to Ignore this Function

function TZBase32.CreateIndexByOctetAndMovePosition(data: String;
  currentPosition: Integer; var index: TArray<Integer>): Integer;
var
  j: Integer;

begin

  j := 0;
  while (j < 8) do
  begin
    if (currentPosition >= (Length(data))) then
    begin
      index[j] := -1;
      inc(j);

      continue;
    end;

    if (FInvAlphabet[Ord(data[currentPosition])] = -1) then
    begin
      inc(currentPosition);
      continue;
    end;

    index[j] := Ord(data[currentPosition]);
    inc(j);

    inc(currentPosition);
  end;

  result := currentPosition;

end;

{$ENDIF}
{$OVERFLOWCHECKS OFF}

function TZBase32.Encode(data: TArray<Byte>): String;
var
  encodedResult: TStringBuilder;
  i, j, byteCount, bitCount, dataLength, index: Integer;
  buffer: UInt64;
  temp: Double;
begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);

  temp := Length(data) * 8.0 / 5.0;
  encodedResult := TStringBuilder.Create((Ceil(temp)));
  try
    i := 0;
    while i < dataLength do
    begin
      byteCount := Min(5, dataLength - i);
      buffer := 0;
      j := 0;
      while j < byteCount do
      begin
        buffer := (buffer shl 8) or data[i + j];
        inc(j);
      end;
      bitCount := byteCount * 8;
      while (bitCount > 0) do

      begin
        if bitCount >= 5 then
        begin

          index := Integer(buffer shr (bitCount - 5)) and $1F;
        end
        else
        begin

          index := Integer(buffer) and UInt64($1F shr (5 - bitCount))
            shl (5 - bitCount);

        end;
        encodedResult.Append(DefaultAlphabet[index]);

        dec(bitCount, 5);
      end;

      inc(i, 5);
    end;
    result := encodedResult.ToString;
  finally
    encodedResult.Free;
  end;
end;

function TZBase32.Decode(const data: String): TArray<Byte>;
var
  index: TArray<Integer>;
  i, j, shortByteCount, bitCount: Integer;
  buffer: UInt64;
  temp: Double;
  tempResult: TList<Byte>;
begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;

  tempResult := TList<Byte>.Create;
  temp := (Length(data)) * 5.0 / 8.0;
  tempResult.Capacity := Integer(Ceil(temp));
  try
    SetLength(index, 8);
    i := 0;

    while i < (Length(data)) do

    begin
      i := CreateIndexByOctetAndMovePosition(data, i, index);

      shortByteCount := 0;

      buffer := 0;
      j := 0;

      while (j < 8) and (index[j] <> -1) do
      begin

        buffer := (buffer shl 5) or UInt64(FInvAlphabet[index[j]] and $1F);

        inc(shortByteCount);

        inc(j);

      end;

      bitCount := shortByteCount * 5;
      while (bitCount >= 8) do
      begin
        tempResult.Add(Byte((buffer shr (bitCount - 8)) and $FF));
        bitCount := bitCount - 8;
      end;

    end;

    result := tempResult.ToArray;
  finally
    tempResult.Free;

  end;

end;

end.
