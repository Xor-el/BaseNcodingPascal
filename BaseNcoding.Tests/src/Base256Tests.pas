unit Base256Tests;

interface

uses
  DUnitX.TestFramework, BaseTests, uBase256;

type

  IBase256Tests = interface
    ['{3D913BE0-F8F1-46BC-815D-06CC6D752B44}']

  end;

  [TestFixture]
  TBase256Tests = class(TBaseNcodingTests, IBase256Tests)
  public
    [Setup]
    procedure Setup;
  end;

implementation

procedure TBase256Tests.Setup;
begin
  FConverter := TBase256.Create();

end;

initialization

TDUnitX.RegisterTestFixture(TBase256Tests);

end.
