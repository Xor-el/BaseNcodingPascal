unit Base91Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase91;

type

  IBase91Tests = interface
    ['{4DBB563D-97C9-48EB-BC47-6C7415AF2A2A}']

  end;

  [TestFixture]
  TBase91Tests = class(TBaseNcodingTests, IBase91Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase91Tests.Setup;
begin
  FConverter := TBase91.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase91Tests);

end.
