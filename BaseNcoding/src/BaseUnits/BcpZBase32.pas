unit BcpZBase32;

{$I ..\Include\BaseNcoding.inc}

interface

uses
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Math
{$ELSE}
    SysUtils,
  Math
{$ENDIF}
{$IFDEF FPC}
    , fgl
{$ELSE}
{$IFDEF SCOPEDUNITNAMES}
    , System.Generics.Collections
{$ELSE}
    , Generics.Collections
{$ENDIF}
{$ENDIF}
    , BcpBase,
  BcpIBaseInterfaces,
  BcpBaseNcodingTypes,
  BcpUtils;

type

  TZBase32 = class sealed(TBase, IZBase32)

  strict private

    function CreateIndexByOctetAndMovePosition(const data: TBaseNcodingString;
      currentPosition: Integer; var index: TBaseNcodingIntegerArray): Integer;

  public

    const

    DefaultAlphabet: array [0 .. 31] of TBaseNcodingChar = ('y', 'b', 'n', 'd',
      'r', 'f', 'g', '8', 'e', 'j', 'k', 'm', 'c', 'p', 'q', 'x', 'o', 't', '1',
      'u', 'w', 'i', 's', 'z', 'a', '3', '4', '5', 'h', '7', '6', '9');

    DefaultSpecial = TBaseNcodingChar(0);

    /// <summary>
    /// From: <seealso href="https://github.com/denxc/ZBase32Encoder/blob/master/ZBase32Encoder/ZBase32Encoder/ZBase32Encoder.cs">[ZBase32Encoder in CSharp]</seealso>
    /// </summary>

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TZBase32.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(32, _Alphabet, _Special, _textEncoding);
end;

function TZBase32.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TZBase32.CreateIndexByOctetAndMovePosition
  (const data: TBaseNcodingString; currentPosition: Integer;
  var index: TBaseNcodingIntegerArray): Integer;
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

    if (FInvAlphabet[Ord(data[(currentPosition) + 1])] = -1) then
    begin
      inc(currentPosition);
      continue;
    end;

    index[j] := Ord(data[(currentPosition) + 1]);
    inc(j);

    inc(currentPosition);
  end;

  result := currentPosition;

end;

{$OVERFLOWCHECKS OFF}

function TZBase32.Encode(data: TBytes): TBaseNcodingString;
var
{$IFNDEF FPC}
  encodedResult: TStringBuilder;
{$ELSE}
  encodedResult: TFPGList<TBaseNcodingChar>;
  uC: TBaseNcodingChar;
{$ENDIF}
  i, j, byteCount, bitCount, dataLength, index: Integer;
  buffer: UInt64;
  temp: Double;
begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    result := ('');
    Exit;
  end;

  dataLength := Length(data);
  temp := dataLength * 8.0 / 5.0;
{$IFDEF FPC}
  encodedResult := TFPGList<TBaseNcodingChar>.Create;
  encodedResult.Capacity := (Ceil(temp));
{$ELSE}
  encodedResult := TStringBuilder.Create((Ceil(temp)));
{$ENDIF}
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
{$IFDEF FPC}
        encodedResult.Add(DefaultAlphabet[index]);
{$ELSE}
        encodedResult.Append(DefaultAlphabet[index]);
{$ENDIF}
        dec(bitCount, 5);
      end;

      inc(i, 5);
    end;
{$IFDEF FPC}
    result := '';
    for uC in encodedResult do
    begin
      result := result + uC;
    end;
{$ELSE}
    result := encodedResult.ToString;
{$ENDIF}
  finally
    encodedResult.Free;
  end;
end;

function TZBase32.Decode(const data: TBaseNcodingString): TBytes;
var
  index: TBaseNcodingIntegerArray;
  i, j, k, shortByteCount, bitCount: Integer;
  b: Byte;
  buffer: UInt64;
  temp: Double;
{$IFDEF FPC}
  tempResult: TFPGList<Byte>
{$ELSE}
  tempResult: TList<Byte>
{$ENDIF};
begin
  if TUtils.IsNullOrEmpty(data) then

  begin

    result := Nil;
    Exit;
  end;

{$IFDEF FPC}
  tempResult := TFPGList<Byte>.Create;
{$ELSE}
  tempResult := TList<Byte>.Create;
{$ENDIF};
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

    SetLength(result, tempResult.Count);
    k := 0;
    for b in tempResult do
    begin
      result[k] := b;
      inc(k);
    end;
  finally
    tempResult.Free;

  end;

end;

end.
