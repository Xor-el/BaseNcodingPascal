unit Base85Tests;

{$mode delphiunicode}

interface

uses
  Classes,
  SysUtils,
  fpcunit,
  testregistry,
  BaseTests,
  uBase85,
  uUtils,
  uIBaseInterfaces;

type

  TBase85Tests = class(TTestCase)

  strict private
    class var
    F_btInstance: TBaseNcodingTests;

  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure EncodeDecodeTest(const str: string);
    procedure EncodeDecodeTestDefaultTextEncoding(const str: string);
    procedure EncodeDecodeTestUnicodeTextEncoding(const str: string);
    procedure PrefixPostfixTest(const str: string);
  published
    procedure CallEncodeDecodeTest();
    procedure CallEncodeDecodeTestDefaultTextEncoding();
    procedure CallEncodeDecodeTestUnicodeTextEncoding();
    procedure TailTests;
    procedure CallPrefixPostfixTest();
  end;

implementation

procedure TBase85Tests.SetUp;
begin
  F_btInstance := TBaseNcodingTests.Create();
  F_btInstance.FConverter := TBase85.Create();
end;

procedure TBase85Tests.TearDown;
begin
  F_btInstance.Free;
end;

procedure TBase85Tests.CallEncodeDecodeTest();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    EncodeDecodeTest(F_btInstance.sArray[i]);
  end;
end;

procedure TBase85Tests.EncodeDecodeTest(const str: string);
var
  encoded, decoded: string;
begin
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase85Tests.CallEncodeDecodeTestDefaultTextEncoding();

begin
    EncodeDecodeTestDefaultTextEncoding(F_btInstance.sArray[0]);
end;

procedure TBase85Tests.EncodeDecodeTestDefaultTextEncoding(const str: string);
var
  encoded, decoded: string;
begin
  F_btInstance.FConverter.Encoding := TEncoding.Default;
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase85Tests.CallEncodeDecodeTestUnicodeTextEncoding();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    EncodeDecodeTestUnicodeTextEncoding(F_btInstance.sArray[i]);
  end;
end;

procedure TBase85Tests.EncodeDecodeTestUnicodeTextEncoding(const str: string);
var
  encoded, decoded: string;
begin
  F_btInstance.FConverter.Encoding := TEncoding.Default;
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase85Tests.TailTests;
var
  testChar: char;
  strBuilder: string;
  bitsPerChar, bitsPerByte, charByteBitsLcm, maxTailLength, Count, i: integer;
  str, encoded: string;
  c: char;
begin
  testChar := 'a';
  strBuilder := '';
  if ((F_btInstance.FConverter.HaveSpecial) and
    (Trunc(F_btInstance.FConverter.BitsPerChars) mod 1 = 0) and
    (TUtils.IsPowerOf2(UInt32(Trunc(F_btInstance.FConverter.BitsPerChars))))) then
  begin
    bitsPerChar := Trunc(F_btInstance.FConverter.BitsPerChars);
    bitsPerByte := 8;
    charByteBitsLcm := TUtils.LCM(bitsPerByte, bitsPerChar);
    maxTailLength := charByteBitsLcm div bitsPerByte - 1;

    for i := 0 to (maxTailLength + 2) do
    begin
      str := strBuilder;
      encoded := F_btInstance.FConverter.EncodeString(str);
      Count := 0;
      for c in encoded do
      begin
        if c = F_btInstance.FConverter.Special then
          Inc(Count);
      end;

      if i = 0 then
        CheckEquals(0, Count)
      else
        CheckEquals
        ((maxTailLength - (i - 1) mod (maxTailLength + 1)), Count);

      CheckEquals(str, F_btInstance.FConverter.DecodeToString(encoded));
      strBuilder := strBuilder + (testChar);
    end;
  end;
end;

procedure TBase85Tests.CallPrefixPostfixTest();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    PrefixPostfixTest(F_btInstance.sArray[i]);
  end;
end;


procedure TBase85Tests.PrefixPostfixTest(const str: string);
var
  _Converter: IBase85;
  encoded, decoded: string;
begin
  _Converter := F_btInstance.FConverter as IBase85;
  _Converter.PrefixPostfix := True;
  encoded := _Converter.EncodeString(str);

  AssertTrue((Pos(TBase85.Prefix, encoded) > 0) and
    (Pos(TBase85.Postfix, encoded) > 0));
  decoded := _Converter.DecodeToString(encoded);
  CheckEquals(str, decoded);
  _Converter.PrefixPostfix := False;
end;

initialization

  RegisterTest(TBase85Tests);
end.
