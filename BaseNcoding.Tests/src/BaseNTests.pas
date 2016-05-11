unit BaseNTests;

{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$ENDIF}

interface

uses
  System.Generics.Collections, System.Math, System.SysUtils,
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  System.Diagnostics,
  System.NetEncoding,
  System.Threading,
  System.TimeSpan,
{$ELSE}
  System.Classes,
  Soap.EncdDecd,
{$ENDIF}
  DUnitX.TestFramework,
  BaseTests, uBase64,
  uBaseN, uBaseBigN, uStringGenerator;

type

  IBaseNTests = interface
    ['{97E58C5C-BED5-49EC-9476-4AEC6DE7FE9C}']

  end;

  [TestFixture]
  TBaseNTests = class(TInterfacedObject, IBaseNTests)
  strict private
    class function Helper(const InString: String): String; static;
  public
    [Test]
    procedure BaseNCompareToBase64();
    [Test]
    procedure ReverseOrder();
    [Test]
    procedure GetOptimalBitsCount();
    [Test]
    procedure EncodeDecodeBaseN();
    [Test]
    procedure EncodeDecodeBaseBigN();
    [Test]
    procedure EncodeDecodeBaseBigNMaxCompression();
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    [Test]
    procedure EncodeDecodeParallel();
{$ENDIF}
  end;

implementation

procedure TBaseNTests.BaseNCompareToBase64();
var
  s, encoded, base64standard: String;
  _converter: IBaseN;
begin
  s := 'aaa';
  _converter := TBaseN.Create(TBase64.DefaultAlphabet);
  encoded := _converter.EncodeString(s);
  base64standard := Helper(s);
  Assert.AreEqual(base64standard, encoded);
end;

class function TBaseNTests.Helper(const InString: String): String;
var
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  temp: TArray<Byte>;
{$ELSE} temp: TStringStream; {$ENDIF}
begin
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  temp := TEncoding.UTF8.GetBytes(InString);
{$ELSE}
  temp := TStringStream.Create(InString, TEncoding.UTF8);
{$ENDIF}
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)} result := StringReplace(TNetEncoding.Base64.EncodeBytesToString(temp), sLineBreak, '', [rfReplaceAll]); {$ELSE}
  try
    result := StringReplace(String(EncodeBase64(temp.Memory, temp.Size)),
      sLineBreak, '', [rfReplaceAll]);
  finally
    temp.Free;
  end;

{$ENDIF}
end;

procedure TBaseNTests.ReverseOrder();
var
  _converter: IBaseN;
  original, encoded, decoded: String;
begin
  _converter := TBaseN.Create(TStringGenerator.GetAlphabet(54), 32, Nil, True);
  original := 'sdfrewwekjthkjh';
  encoded := _converter.EncodeString(original);
  decoded := _converter.DecodeToString(encoded);
  Assert.AreEqual(original, decoded);
end;

procedure TBaseNTests.GetOptimalBitsCount();
var
  charsCountInBits: UInt32;
  builder: TStringBuilder;
  i, bits: Integer;
  ratio, tempDouble: Double;
  str: String;

begin
  Assert.AreEqual(5, TBaseN.GetOptimalBitsCount2(32, charsCountInBits));
  Assert.AreEqual(6, TBaseN.GetOptimalBitsCount2(64, charsCountInBits));
  Assert.AreEqual(32, TBaseN.GetOptimalBitsCount2(85, charsCountInBits));
  Assert.AreEqual(13, TBaseN.GetOptimalBitsCount2(91, charsCountInBits));

  builder := TStringBuilder.Create;
  try
    for i := 2 to 256 do
    begin
      bits := TBaseBigN.GetOptimalBitsCount2(UInt32(i), charsCountInBits, 512);
      tempDouble := (bits * 1.0);
      ratio := tempDouble / charsCountInBits;

      builder.AppendLine(IntToStr(bits) + '	' + UIntToStr(charsCountInBits) +
        '	' + FormatFloat('0.0000000', ratio));
    end;

    str := builder.ToString();
  finally
    builder.Free;
  end;

end;

procedure TBaseNTests.EncodeDecodeBaseN();
var
  bytes: TList<Byte>;
  testByte: Byte;
  radix: UInt32;
  baseN: IBaseN;
  testBytesCount, i: Integer;
  _array, decoded: TArray<Byte>;
  encoded: String;

begin
  testByte := 157;
  bytes := TList<Byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin
      baseN := TBaseN.Create(TStringGenerator.GetAlphabet(Integer(radix)), 64);
      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin
        _array := bytes.ToArray();
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        Assert.AreEqualMemory(Pointer(_array), Pointer(decoded),
          Length(_array));
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
  bytes: TList<Byte>;
  testByte: Byte;
  radix: UInt32;
  baseN: IBaseBigN;
  testBytesCount, i: Integer;
  _array, decoded: TArray<Byte>;
  encoded: String;

begin
  testByte := 157;
  bytes := TList<Byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin
      baseN := TBaseBigN.Create
        (TStringGenerator.GetAlphabet(Integer(radix)), 256);
      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin
        _array := bytes.ToArray();
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        Assert.AreEqualMemory(Pointer(_array), Pointer(decoded),
          Length(_array));
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
  bytes: TList<Byte>;
  testByte: Byte;
  radix: UInt32;
  baseN: IBaseBigN;
  testBytesCount, i: Integer;
  _array, decoded: TArray<Byte>;
  encoded: String;

begin
  testByte := 157;
  bytes := TList<Byte>.Create;
  try

    for radix := 2 to Pred(1000) do
    begin
      baseN := TBaseBigN.Create(TStringGenerator.GetAlphabet(Integer(radix)),
        256, Nil, False, {$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)} False,
{$ENDIF} True);
      testBytesCount := Max((baseN.BlockBitsCount + 7) div 8,
        (baseN.BlockCharsCount));
      bytes.Clear;
      i := 0;
      while i <= (testBytesCount + 1) do
      begin
        _array := bytes.ToArray();
        encoded := baseN.Encode(_array);
        decoded := baseN.Decode(encoded);
        Assert.AreEqualMemory(Pointer(_array), Pointer(decoded),
          Length(_array));
        bytes.Add(testByte);
        Inc(i);
      end;
    end;

  finally
    bytes.Free;
  end;
end;

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}

procedure TBaseNTests.EncodeDecodeParallel();
var
  randomString, Alpha, baseNEncoded, baseNEncodedParallel, baseNDecoded,
    baseNDecodedParallel: String;
  baseN: IBaseN;
  stopwatch: TStopWatch;
  baseNTime, baseNParallelTime: TTimeSpan;

begin

  randomString := TStringGenerator.GetRandom(10000000, True);
  Alpha := TStringGenerator.GetAlphabet(85);
  baseN := TBaseN.Create(Alpha);

  // Encoding Part

  stopwatch := TStopWatch.Create;
  stopwatch.Start;
  baseNEncoded := baseN.EncodeString(randomString);
  stopwatch.Stop;
  baseNTime := stopwatch.Elapsed;

  stopwatch := TStopWatch.Create;
  stopwatch.Start;
  baseN.Parallel := True;
  baseNEncodedParallel := baseN.EncodeString(randomString);
  stopwatch.Stop;
  baseNParallelTime := stopwatch.Elapsed;
  Assert.AreEqual(baseNEncoded, baseNEncodedParallel);
  Assert.IsTrue(baseNParallelTime < baseNTime);

  // Decoding Part

  stopwatch := TStopWatch.Create;
  stopwatch.Start;
  baseN.Parallel := False;
  baseNDecoded := baseN.DecodeToString(baseNEncoded);
  stopwatch.Stop;
  baseNTime := stopwatch.Elapsed;

  stopwatch := TStopWatch.Create;
  stopwatch.Start;
  baseN.Parallel := True;
  baseNDecodedParallel := baseN.DecodeToString(baseNEncodedParallel);
  stopwatch.Stop;
  baseNParallelTime := stopwatch.Elapsed;
  Assert.AreEqual(baseNDecoded, baseNDecodedParallel);
  Assert.IsTrue(baseNParallelTime < baseNTime);

end;

{$ENDIF}

initialization

TDUnitX.RegisterTestFixture(TBaseNTests);

end.
