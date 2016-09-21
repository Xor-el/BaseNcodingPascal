unit BaseNTests;

{$mode delphiunicode}
{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  Classes,
  SysUtils,
  Math,
  fpcunit,
  testregistry,
  fgl,
  Base64,
  BaseTests,
  BcpBase64,
  BcpBaseN,
  BcpBaseBigN,
  BcpUtils,
  BcpIBaseInterfaces,
  uStringGenerator;

type

  TBaseNTests = class(TTestCase)

  strict private
    class function Helper(const InString: string): string; static;

  published
    procedure BaseNCompareToBase64();
    procedure ReverseOrder();
    procedure GetOptimalBitsCount();
    procedure EncodeDecodeBaseN();
    procedure EncodeDecodeBaseBigN();
    procedure EncodeDecodeBaseBigNMaxCompression();
  end;

implementation

class function TBaseNTests.Helper(const InString: string): string;
begin
  Result := EncodeStringBase64(InString);
end;

procedure TBaseNTests.BaseNCompareToBase64();
var
  s, encoded, base64standard: string;
  _converter: IBaseN;
begin
  s := 'aaa';
  _converter := TBaseN.Create(TBase64.DefaultAlphabet);
  encoded := _converter.EncodeString(s);
  base64standard := Helper(s);
  CheckEquals(base64standard, encoded);
end;

procedure TBaseNTests.ReverseOrder();
var
  _converter: IBaseN;
  original, encoded, decoded: string;
begin
  _converter := TBaseN.Create(TStringGenerator.GetAlphabet(54), 32, nil, True);
  original := 'sdfrewwekjthkjh';
  encoded := _converter.EncodeString(original);
  decoded := _converter.DecodeToString(encoded);
  CheckEquals(original, decoded);
end;

procedure TBaseNTests.GetOptimalBitsCount();
var
  charsCountInBits: UInt32;
  i, bits: integer;
  ratio, tempDouble: double;
  builder: string;

begin
  CheckEquals(5, TUtils.GetOptimalBitsCount2(32, charsCountInBits));
  CheckEquals(6, TUtils.GetOptimalBitsCount2(64, charsCountInBits));
  CheckEquals(32, TUtils.GetOptimalBitsCount2(85, charsCountInBits));
  CheckEquals(13, TUtils.GetOptimalBitsCount2(91, charsCountInBits));


  builder := '';
  for i := 2 to 256 do
  begin
    bits := TUtils.GetOptimalBitsCount2(UInt32(i), charsCountInBits, 512);
    tempDouble := (bits * 1.0);
    ratio := tempDouble / charsCountInBits;

    builder := builder + (IntToStr(bits) + ' ' + IntToStr(charsCountInBits) +
      ' ' + FormatFloat('0.0000000', ratio));
    builder := builder + sLineBreak;
  end;

end;

procedure TBaseNTests.EncodeDecodeBaseN();
var
  bytes: TFPGList<byte>;
  testByte, b: byte;
  radix: UInt32;
  baseN: IBaseN;
  testBytesCount, i, j: integer;
  _array, decoded: array of byte;
  encoded: string;

begin
  testByte := 157;
  bytes := TFPGList<byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin
      baseN := TBaseN.Create(TStringGenerator.GetAlphabet(integer(radix)), 64);
      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin
        SetLength(_array, bytes.Count);
        j := 0;
        for b in bytes do
        begin
          _array[j] := b;
          Inc(j);
        end;
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        CheckEquals(CompareMem(Pointer(_array), Pointer(decoded), Length(_array) * SizeOf(Byte)), True);
        bytes.Add(testByte);
        Inc(i);
      end;
    end;

  finally
    bytes.Free;
  end;
end;

procedure TBaseNTests.EncodeDecodeBaseBigN();
var
  bytes: TFPGList<byte>;
  testByte, b: byte;
  radix: UInt32;
  baseN: IBaseBigN;
  testBytesCount, i, j: integer;
  _array, decoded: array of byte;
  encoded: string;

begin
  testByte := 157;
  bytes := TFPGList<byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin
      baseN := TBaseBigN.Create(TStringGenerator.GetAlphabet(
        integer(radix)), 256);
      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin

        SetLength(_array, bytes.Count);
        j := 0;
        for b in bytes do
        begin
          _array[j] := b;
          Inc(j);
        end;
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        CheckEquals(CompareMem(Pointer(_array), Pointer(decoded), Length(_array) * SizeOf(Byte)), True);
        bytes.Add(testByte);
        bytes.Add(testByte);
        Inc(i);
      end;
    end;

  finally
    bytes.Free;
  end;
end;

procedure TBaseNTests.EncodeDecodeBaseBigNMaxCompression();
var
  bytes: TFPGList<byte>;
  testByte, b: byte;
  radix: UInt32;
  baseN: IBaseBigN;
  testBytesCount, i, j: integer;
  _array, decoded: array of byte;
  encoded: string;

begin
  testByte := 157;
  bytes := TFPGList<byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin

      baseN := TBaseBigN.Create(TStringGenerator.GetAlphabet(integer(radix)),
        256, nil, False, True);

      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin
        SetLength(_array, bytes.Count);
        j := 0;
        for b in bytes do
        begin
          _array[j] := b;
          Inc(j);
        end;
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        CheckEquals(True, CompareMem(Pointer(_array), Pointer(decoded), Length(_array) * SizeOf(Byte)));
        bytes.Add(testByte);
        bytes.Add(testByte);
        Inc(i);
      end;
    end;

  finally
    bytes.Free;
  end;
end;

initialization

  RegisterTest(TBaseNTests);

end.
