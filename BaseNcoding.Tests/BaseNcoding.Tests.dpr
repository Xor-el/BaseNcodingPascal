program BaseNcoding.Tests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}

uses
  SysUtils,
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
{$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  BaseTests in 'src\BaseTests.pas',
  uBase in '..\BaseNcoding\src\BaseUnits\uBase.pas',
  uBase32 in '..\BaseNcoding\src\BaseUnits\uBase32.pas',
  uBase64 in '..\BaseNcoding\src\BaseUnits\uBase64.pas',
  uBase85 in '..\BaseNcoding\src\BaseUnits\uBase85.pas',
  uBase91 in '..\BaseNcoding\src\BaseUnits\uBase91.pas',
  uBase128 in '..\BaseNcoding\src\BaseUnits\uBase128.pas',
  uBase256 in '..\BaseNcoding\src\BaseUnits\uBase256.pas',
  uBase1024 in '..\BaseNcoding\src\BaseUnits\uBase1024.pas',
  uBase4096 in '..\BaseNcoding\src\BaseUnits\uBase4096.pas',
  uBaseN in '..\BaseNcoding\src\BaseUnits\uBaseN.pas',
  uZBase32 in '..\BaseNcoding\src\BaseUnits\uZBase32.pas',
  uUtils in '..\BaseNcoding\src\UtilityUnits\uUtils.pas',
  Base32Tests in 'src\Base32Tests.pas',
  Base64Tests in 'src\Base64Tests.pas',
  Base85Tests in 'src\Base85Tests.pas',
  Base91Tests in 'src\Base91Tests.pas',
  Base128Tests in 'src\Base128Tests.pas',
  Base256Tests in 'src\Base256Tests.pas',
  Base1024Tests in 'src\Base1024Tests.pas',
  Base4096Tests in 'src\Base4096Tests.pas',
  BaseNTests in 'src\BaseNTests.pas',
  uStringGenerator
    in '..\BaseNcoding.GUI\src\Helpers\StringGenerator\uStringGenerator.pas',
  IntegerX in '..\BaseNcoding\src\UtilityUnits\IntegerX.pas',
  uBaseBigN in '..\BaseNcoding\src\BaseUnits\uBaseBigN.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger: ITestLogger;

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    // Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    // Create the test runner
    runner := TDUnitX.CreateRunner;
    // Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    // tell the runner how we will log things
    // Log to the console window
    logger := TDUnitXConsoleLogger.Create(True);
    runner.AddLogger(logger);
    // Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create
      (TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False;
    // When true, Assertions must be made during tests;

    // Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

{$IFNDEF CI}
    // We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
{$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;

end.
