unit Base85Tests;

interface

uses
  System.SysUtils, DUnitX.TestFramework, BaseTests, uBase85;

type

  IBase85Tests = interface
    ['{52244BAF-1FBB-45EE-B950-1620A1BE346B}']

  end;

  [TestFixture]
  TBase85Tests = class(TBaseNcodingTests, IBase85Tests)
  public

    [Setup]
    procedure Setup;

    [TestCase('Base64SampleStringTestPrefixPostfix',
      TBaseNcodingTests.Base64SampleString)]
    [TestCase('RusStringSampleStringTestPrefixPostfix',
      TBaseNcodingTests.RusString)]
    [TestCase('GreekStringSampleStringTestPrefixPostfix',
      TBaseNcodingTests.GreekString)]
    procedure PrefixPostfixTest(const str: String);

  end;

implementation

procedure TBase85Tests.Setup;
begin
  FConverter := TBase85.Create();
end;

procedure TBase85Tests.PrefixPostfixTest(const str: String);
var
  _Converter: IBase85;
  encoded, decoded: String;
begin
  _Converter := FConverter as IBase85;
  _Converter.PrefixPostfix := True;
  encoded := _Converter.EncodeString(str);

  Assert.IsTrue((encoded.Contains(TBase85.Prefix)) and
    (encoded.Contains(TBase85.Postfix)));
  decoded := _Converter.DecodeToString(encoded);
  Assert.AreEqual(str, decoded);
  _Converter.PrefixPostfix := False;
end;

initialization

TDUnitX.RegisterTestFixture(TBase85Tests);

end.
