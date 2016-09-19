unit uBase85;

{$I ..\Include\BaseNcoding.inc}

interface

uses
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Classes
{$ELSE}
    SysUtils,
  Classes
{$ENDIF}
{$IFDEF FPC}
    , fgl
{$ENDIF}
    , uBase,
  uIBaseInterfaces,
  uBaseNcodingTypes,
  uUtils;

resourcestring

  SInvalidBlock = 'The last block of ASCII85 data cannot be a single byte.';
  SInvalidData =
    'ASCII85 encoded data should begin with "%s" and end with "%s"';

type

  TBase85 = class sealed(TBase, IBase85)

  strict private

    FPrefixPostfix: Boolean;

    function GetPrefixPostfix: Boolean;
    procedure SetPrefixPostfix(value: Boolean);

    procedure EncodeBlock(count: Integer; var sb:
{$IFDEF FPC} TFPGList<TBaseNcodingString>
{$ELSE} TStringBuilder
{$ENDIF}; encodedBlock: TBytes; tuple: UInt32);
    procedure DecodeBlock(bytes: Integer; decodedBlock: TBytes; tuple: UInt32);

  public

    const

    DefaultAlphabet: array [0 .. 84] of TBaseNcodingChar = ('!', '"', '#', '$',
      '%', '&', '''', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2',
      '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A',
      'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
      'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\', ']', '^', '_',
      '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
      'o', 'p', 'q', 'r', 's', 't', 'u');

    DefaultSpecial = TBaseNcodingChar(0);

    Pow85: array [0 .. 4] of UInt32 = (85 * 85 * 85 * 85, 85 * 85 * 85,
      85 * 85, 85, 1);

    Prefix = TBaseNcodingString('<~');
    Postfix = TBaseNcodingString('~>');

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _prefixPostfix: Boolean = False; _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;
    property PrefixPostfix: Boolean read GetPrefixPostfix
      write SetPrefixPostfix;

  end;

implementation

constructor TBase85.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _prefixPostfix: Boolean = False;
  _textEncoding: TEncoding = Nil);
begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(85, _Alphabet, _Special, _textEncoding);
  PrefixPostfix := _prefixPostfix;
  BlockBitsCount := 32;
  BlockCharsCount := 5;

end;

function TBase85.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TBase85.GetPrefixPostfix: Boolean;
begin
  result := FPrefixPostfix;
end;

procedure TBase85.SetPrefixPostfix(value: Boolean);
begin
  FPrefixPostfix := value;
end;

{$OVERFLOWCHECKS OFF}

function TBase85.Encode(data: TBytes): TBaseNcodingString;

var
  encodedBlock: TBytes;
  decodedBlockLength, count, resultLength: Integer;
{$IFNDEF FPC}
  sb: TStringBuilder;
{$ELSE}
  sb: TFPGList<TBaseNcodingString>;
  uS: TBaseNcodingString;
{$ENDIF}
  tuple: UInt32;
  b: Byte;
  temp: Double;

begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    result := ('');
    Exit;
  end;

  SetLength(encodedBlock, 5);
  decodedBlockLength := 4;
  temp := Length(data) * (Length(encodedBlock) / decodedBlockLength);
  resultLength := Trunc(temp);
  if (PrefixPostfix) then
    resultLength := resultLength + Length(Prefix) + Length(Postfix);

{$IFDEF FPC}
  sb := TFPGList<TBaseNcodingString>.Create;
  sb.Capacity := resultLength;
{$ELSE}
  sb := TStringBuilder.Create(resultLength);
{$ENDIF}
  try
    if (PrefixPostfix) then
    begin
{$IFDEF FPC}
      sb.Add(Prefix);
{$ELSE}
      sb.Append(Prefix);
{$ENDIF}
    end;
    count := 0;
    tuple := 0;
    for b in data do
    begin
      if (count >= (decodedBlockLength - 1)) then
      begin
        tuple := tuple or b;
        if (tuple = 0) then
        begin
{$IFDEF FPC}
          sb.Add('z')
{$ELSE}
          sb.Append('z')
{$ENDIF}
        end
        else
        begin
          EncodeBlock(Length(encodedBlock), sb, encodedBlock, tuple);
          tuple := 0;
          count := 0;
        end;
      end

      else
      begin

        tuple := tuple or (UInt32(b shl (24 - (count * 8))));
        Inc(count);

      end;

    end;
    if (count > 0) then
    begin
      EncodeBlock(count + 1, sb, encodedBlock, tuple);
    end;
    if (PrefixPostfix) then
    begin
{$IFDEF FPC}
      sb.Add(Postfix);
{$ELSE}
      sb.Append(Postfix);
{$ENDIF}
    end;
{$IFDEF FPC}
    result := '';
    for uS in sb do
    begin
      result := result + uS;
    end;
{$ELSE}
    result := sb.ToString;
{$ENDIF}
  finally
    sb.Free;
  end;

end;

{$OVERFLOWCHECKS OFF}

function TBase85.Decode(const data: TBaseNcodingString): TBytes;
var
  dataWithoutPrefixPostfix: TBaseNcodingString;
  ms: TMemoryStream;
  count, encodedBlockLength, i, Idx: Integer;
  processChar: Boolean;
  tuple: UInt32;
  decodedBlock: TBytes;
  c: TBaseNcodingChar;

begin

  if TUtils.IsNullOrEmpty(data) then

  begin

    result := Nil;
    Exit;
  end;
  dataWithoutPrefixPostfix := data;
  if (PrefixPostfix) then
  begin
    if not(TUtils.StartsWith(dataWithoutPrefixPostfix, Prefix) or
      TUtils.EndsWith(dataWithoutPrefixPostfix, Postfix)) then
    begin
      raise Exception.CreateResFmt(@SInvalidData, [Prefix, Postfix]);
    end;

    dataWithoutPrefixPostfix := Copy(dataWithoutPrefixPostfix,
      Length(Prefix) + 1, Length(dataWithoutPrefixPostfix) - Length(Prefix) -
      Length(Postfix));

  end;
  ms := TMemoryStream.Create;
  try
    count := 0;

    tuple := UInt32(0);
    encodedBlockLength := 5;
    SetLength(decodedBlock, 4);

    // NOTE to Self and other Developers who care to poke at the Source.
    // "for in loop" for "strings" in FPC 3.0 and Lazarus 1.6 is broken
    // if "{$ZEROBASEDSTRINGS ON}" is enabled so I decided to use the
    // "good old fashioned" "for" loop because who knows, something else might be broken :)

    for Idx := 1 to Length(dataWithoutPrefixPostfix) do

    begin
      c := dataWithoutPrefixPostfix[Idx];

      Case c of

        'z':
          begin
            if (count <> 0) then
            begin
              raise Exception.Create
                ('The character ''z'' is invalid inside an ASCII85 block.');
            end;
            decodedBlock[0] := 0;
            decodedBlock[1] := 0;
            decodedBlock[2] := 0;
            decodedBlock[3] := 0;

            ms.Write(decodedBlock[0], Length(decodedBlock));

            processChar := False;
          end

      else
        begin
          processChar := True;
        end;
      end;
      if (processChar) then
      begin

        tuple := tuple + UInt32(FInvAlphabet[Ord(c)]) * Pow85[count];
        Inc(count);
        if (count = encodedBlockLength) then
        begin
          DecodeBlock(Length(decodedBlock), decodedBlock, tuple);

          ms.Write(decodedBlock[0], Length(decodedBlock));

          tuple := 0;
          count := 0;
        end;
      end;
    end;

    if (count <> 0) then
    begin

      if (count = 1) then
      begin
        raise Exception.CreateRes(@SInvalidBlock);
      end;
      dec(count);
      tuple := tuple + Pow85[count];
      DecodeBlock(count, decodedBlock, tuple);
      for i := 0 to Pred(count) do
      begin

        ms.Write(decodedBlock[i], 1);
      end;

    end;

    ms.Position := 0;
    SetLength(result, ms.Size);
    ms.Read(result[0], ms.Size);
  finally
    ms.Free;
  end;

end;

{$OVERFLOWCHECKS OFF}

procedure TBase85.EncodeBlock(count: Integer; var sb:
{$IFDEF FPC} TFPGList<TBaseNcodingString>
{$ELSE} TStringBuilder
{$ENDIF}; encodedBlock: TBytes; tuple: UInt32);
var
  i: Integer;

begin

  i := Pred(Length(encodedBlock));
  while i >= 0 do
  begin

    encodedBlock[i] := Byte(tuple mod 85);
    tuple := tuple div 85;
    dec(i);

  end;

  i := 0;

  while i < count do
  begin
{$IFDEF FPC}
    sb.Add(Alphabet[(encodedBlock[i]) + 1]);
{$ELSE}
    sb.Append(Alphabet[(encodedBlock[i]) + 1]);
{$ENDIF}
    Inc(i);
  end;

end;

procedure TBase85.DecodeBlock(bytes: Integer; decodedBlock: TBytes;
  tuple: UInt32);
var
  i: Integer;

begin
  for i := 0 to Pred(bytes) do
  begin

    decodedBlock[i] := Byte(tuple shr (24 - (i * 8)));
  end;
end;

end.
