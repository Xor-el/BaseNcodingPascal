unit Base4096Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase4096;

type

  IBase4096Tests = interface
    ['{15E7BF36-0716-4078-B6DF-E8EED03F5271}']

  end;

  [TestFixture]
  TBase4096Tests = class(TBaseNcodingTests, IBase4096Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase4096Tests.Setup;
begin
  FConverter := TBase4096.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase4096Tests);

end.
