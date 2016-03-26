unit Base1024Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase1024;

type

  IBase1024Tests = interface
    ['{66514946-9E5A-46A3-B7E4-473D77CEA1C7}']

  end;

  [TestFixture]
  TBase1024Tests = class(TBaseNcodingTests, IBase1024Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase1024Tests.Setup;

begin
  FConverter := TBase1024.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase1024Tests);

end.
