unit Base64Tests;

{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$ENDIF}

interface

uses
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)} System.NetEncoding, {$ELSE} System.Classes, Soap.EncdDecd, {$ENDIF}
  System.SysUtils, DunitX.TestFramework, BaseTests, uBase64;

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
  Assert.AreEqual(base64standard, encoded);
end;

class function TBase64Tests.Helper(const InString: String): String;
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
    result := StringReplace(String(EncodeBase64(temp.Memory, temp.Size)), sLineBreak, '', [rfReplaceAll]);
  finally
    temp.Free;
  end;

{$ENDIF}
end;

initialization

TDUnitX.RegisterTestFixture(TBase64Tests);

end.
