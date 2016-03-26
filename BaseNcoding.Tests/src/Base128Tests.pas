unit Base128Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase128;

type

  IBase128Tests = interface
    ['{4A39FB74-DFB6-40F7-863A-D843C518527D}']

  end;

  [TestFixture]
  TBase128Tests = class(TBaseNcodingTests, IBase128Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase128Tests.Setup;
begin
  FConverter := TBase128.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase128Tests);

end.
