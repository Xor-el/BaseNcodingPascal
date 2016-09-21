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
  BaseTests in 'src\BaseTests.pas',
  Base32Tests in 'src\Base32Tests.pas',
  Base64Tests in 'src\Base64Tests.pas',
  Base85Tests in 'src\Base85Tests.pas',
  Base91Tests in 'src\Base91Tests.pas',
  Base128Tests in 'src\Base128Tests.pas',
  Base256Tests in 'src\Base256Tests.pas',
  Base1024Tests in 'src\Base1024Tests.pas',
  Base4096Tests in 'src\Base4096Tests.pas',
  BaseNTests in 'src\BaseNTests.pas',
  uStringGenerator in 'src\uStringGenerator.pas',
  BcpBase in '..\..\BaseNcoding\src\BaseUnits\BcpBase.pas',
  BcpBase32 in '..\..\BaseNcoding\src\BaseUnits\BcpBase32.pas',
  BcpBase64 in '..\..\BaseNcoding\src\BaseUnits\BcpBase64.pas',
  BcpBase85 in '..\..\BaseNcoding\src\BaseUnits\BcpBase85.pas',
  BcpBase91 in '..\..\BaseNcoding\src\BaseUnits\BcpBase91.pas',
  BcpBase128 in '..\..\BaseNcoding\src\BaseUnits\BcpBase128.pas',
  BcpBase256 in '..\..\BaseNcoding\src\BaseUnits\BcpBase256.pas',
  BcpBase1024 in '..\..\BaseNcoding\src\BaseUnits\BcpBase1024.pas',
  BcpBase4096 in '..\..\BaseNcoding\src\BaseUnits\BcpBase4096.pas',
  BcpBaseBigN in '..\..\BaseNcoding\src\BaseUnits\BcpBaseBigN.pas',
  BcpBaseN in '..\..\BaseNcoding\src\BaseUnits\BcpBaseN.pas',
  BcpZBase32 in '..\..\BaseNcoding\src\BaseUnits\BcpZBase32.pas',
  BcpBaseFactory in '..\..\BaseNcoding\src\BaseUnits\BcpBaseFactory.pas',
  BcpIBaseInterfaces
    in '..\..\BaseNcoding\src\BaseInterfaces\BcpIBaseInterfaces.pas',
  BcpUtils in '..\..\BaseNcoding\src\UtilityUnits\BcpUtils.pas',
  BcpBaseNcodingTypes
    in '..\..\BaseNcoding\src\UtilityUnits\BcpBaseNcodingTypes.pas',
  BcpIntegerX in '..\..\BaseNcoding\src\UtilityUnits\BcpIntegerX.pas';

begin

  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;

end.
