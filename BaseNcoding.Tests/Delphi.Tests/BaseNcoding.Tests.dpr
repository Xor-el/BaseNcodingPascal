program BaseNcoding.Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Base32Tests in 'src\Base32Tests.pas',
  Base64Tests in 'src\Base64Tests.pas',
  Base85Tests in 'src\Base85Tests.pas',
  Base91Tests in 'src\Base91Tests.pas',
  Base128Tests in 'src\Base128Tests.pas',
  Base256Tests in 'src\Base256Tests.pas',
  Base1024Tests in 'src\Base1024Tests.pas',
  Base4096Tests in 'src\Base4096Tests.pas',
  uBase in '..\..\BaseNcoding\src\BaseUnits\uBase.pas',
  uBase32 in '..\..\BaseNcoding\src\BaseUnits\uBase32.pas',
  uBase64 in '..\..\BaseNcoding\src\BaseUnits\uBase64.pas',
  uBase85 in '..\..\BaseNcoding\src\BaseUnits\uBase85.pas',
  uBase91 in '..\..\BaseNcoding\src\BaseUnits\uBase91.pas',
  uBase128 in '..\..\BaseNcoding\src\BaseUnits\uBase128.pas',
  uBase256 in '..\..\BaseNcoding\src\BaseUnits\uBase256.pas',
  uBase1024 in '..\..\BaseNcoding\src\BaseUnits\uBase1024.pas',
  uBase4096 in '..\..\BaseNcoding\src\BaseUnits\uBase4096.pas',
  uBaseBigN in '..\..\BaseNcoding\src\BaseUnits\uBaseBigN.pas',
  uBaseN in '..\..\BaseNcoding\src\BaseUnits\uBaseN.pas',
  uZBase32 in '..\..\BaseNcoding\src\BaseUnits\uZBase32.pas',
  uUtils in '..\..\BaseNcoding\src\UtilityUnits\uUtils.pas',
  uBaseNcodingTypes
    in '..\..\BaseNcoding\src\UtilityUnits\uBaseNcodingTypes.pas',
  IntegerX in '..\..\BaseNcoding\src\UtilityUnits\IntegerX.pas',
  BaseTests in 'src\BaseTests.pas',
  uStringGenerator in 'src\uStringGenerator.pas',
  BaseNTests in 'src\BaseNTests.pas';

begin

  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;

end.
