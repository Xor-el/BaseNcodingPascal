unit Base64Tests;

interface

uses
  System.NetEncoding, System.SysUtils, DunitX.TestFramework, BaseTests, uBase64;

type

  IBase64Tests = interface
    ['{0CCE92C0-A9CD-46B3-8181-40FF57149B36}']

  end;

  [TestFixture]
  TBase64Tests = class(TBaseNcodingTests, IBase64Tests)
  strict private
    class function Helper(const InString: String): String; static;
  public
    [TestCase('Base64SampleStringTestCalcAgainstDefault',
      TBaseNcodingTests.Base64SampleString)]
    [TestCase('RusStringSampleStringTestCalcAgainstDefault',
      TBaseNcodingTests.RusString)]
    [TestCase('GreekStringSampleStringTestCalcAgainstDefault',
      TBaseNcodingTests.GreekString)]
    procedure Base64CompareToStandard(const str: String);

    [Setup]
    procedure Setup;

  end;

implementation

procedure TBase64Tests.Setup;
begin
  FConverter := TBase64.Create();

end;

procedure TBase64Tests.Base64CompareToStandard(const str: String);
var
  encoded, base64standard: String;
begin
  encoded := FConverter.EncodeString(str);
  base64standard := Helper(str);
  base64standard := StringReplace(base64standard, sLineBreak, '',
    [rfReplaceAll]);
  Assert.AreEqual(base64standard, encoded);
end;

class function TBase64Tests.Helper(const InString: String): String;
var
  temp: TArray<Byte>;
begin
  temp := TEncoding.UTF8.GetBytes(InString);
  result := TNetEncoding.Base64.EncodeBytesToString(temp);
end;

initialization

TDUnitX.RegisterTestFixture(TBase64Tests);

end.
