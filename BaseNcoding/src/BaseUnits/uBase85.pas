unit uBase85;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  System.Classes,
  System.StrUtils,
  uBase,
  uUtils;

type

  IBase85 = interface
    ['{A230687D-2037-482C-B207-E543683B5ED4}']

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
    function GetPrefixPostfix: Boolean;
    procedure SetPrefixPostfix(value: Boolean);
    property PrefixPostfix: Boolean read GetPrefixPostfix
      write SetPrefixPostfix;

  end;

  TBase85 = class(TBase, IBase85)

  strict private

    function GetPrefixPostfix: Boolean;
    procedure SetPrefixPostfix(value: Boolean);
    procedure EncodeBlock(count: Integer; sb: TStringBuilder;
      encodedBlock: TArray<Byte>; tuple: UInt32);
    procedure DecodeBlock(bytes: Integer; decodedBlock: TArray<Byte>;
      tuple: UInt32);

  protected

    class var

      FPrefixPostfix: Boolean;

  public

    const

    DefaultAlphabet =
      '!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstu';

    DefaultSpecial = Char(0);
    Pow85: Array [0 .. 4] of UInt32 = (85 * 85 * 85 * 85, 85 * 85 * 85,
      85 * 85, 85, 1);

    Prefix = '<~';
    Postfix = '~>';

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _prefixPostfix: Boolean = False;
      _textEncoding: TEncoding = Nil);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;
    property PrefixPostfix: Boolean read GetPrefixPostfix
      write SetPrefixPostfix;

  end;

implementation

constructor TBase85.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _prefixPostfix: Boolean = False;
  _textEncoding: TEncoding = Nil);
begin

  Inherited Create(85, _Alphabet, _Special, _textEncoding);
  FHaveSpecial := False;
  PrefixPostfix := _prefixPostfix;
  BlockBitsCount := 32;
  BlockCharsCount := 5;

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

function TBase85.Encode(data: TArray<Byte>): String;

var
  encodedBlock: TArray<Byte>;
  decodedBlockLength, count, resultLength: Integer;
  sb: TStringBuilder;
  tuple: UInt32;
  b: Byte;
  temp: Double;

begin
  SetLength(encodedBlock, 5);
  decodedBlockLength := 4;
  temp := Length(data) * (Length(encodedBlock) / decodedBlockLength);
  resultLength := Trunc(temp);
  if (PrefixPostfix) then
    resultLength := resultLength + Length(Prefix) + Length(Postfix);

  sb := TStringBuilder.Create(resultLength);

  try
    if (PrefixPostfix) then
    begin
      sb.Append(Prefix);
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
          sb.Append('z')
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
      sb.Append(Postfix);
    end;
    result := sb.ToString;
  finally
    sb.Free;
  end;

end;

{$OVERFLOWCHECKS OFF}

function TBase85.Decode(const data: String): TArray<Byte>;
var
  dataWithoutPrefixPostfix: String;
  ms: TMemoryStream;
  count, encodedBlockLength, i: Integer;
  processChar: Boolean;
  tuple: LongWord;
  decodedBlock: TArray<Byte>;
  c: Char;

begin

  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;
  dataWithoutPrefixPostfix := data;
  if (PrefixPostfix) then
  begin
    if not(TUtils.StartsWith(dataWithoutPrefixPostfix, Prefix) or
      TUtils.EndsWith(dataWithoutPrefixPostfix, Postfix)) then
    begin
      raise Exception.Create
        (Format('ASCII85 encoded data should begin with "%s" and end with "%s"',
        [Prefix, Postfix]));
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
    for c in dataWithoutPrefixPostfix do

    begin

      Case AnsiIndexStr(c, ['z']) of

        0:
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

            ms.Write(decodedBlock, 0, Length(decodedBlock));
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
          ms.Write(decodedBlock, 0, Length(decodedBlock));
          tuple := 0;
          count := 0;
        end;
      end;
    end;

    if (count <> 0) then
    begin

      if (count = 1) then
      begin
        raise Exception.Create
          ('The last block of ASCII85 data cannot be a single byte.');
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

procedure TBase85.EncodeBlock(count: Integer; sb: TStringBuilder;
  encodedBlock: TArray<Byte>; tuple: UInt32);
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
    sb.Append(DefaultAlphabet[encodedBlock[i]]);
    Inc(i);
  end;

end;

procedure TBase85.DecodeBlock(bytes: Integer; decodedBlock: TArray<Byte>;
  tuple: LongWord);
var
  i: Integer;

begin
  for i := 0 to Pred(bytes) do
  begin

    decodedBlock[i] := Byte(tuple shr (24 - (i * 8)));
  end;
end;

end.
