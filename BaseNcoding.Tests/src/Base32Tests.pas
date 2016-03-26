unit Base32Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase32;

type

  IBase32Tests = interface
    ['{11FCD331-13DC-457D-B10E-15930051ECEB}']

  end;

  [TestFixture]
  TBase32Tests = class(TBaseNcodingTests, IBase32Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase32Tests.Setup;
begin
  FConverter := TBase32.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase32Tests);

end.
