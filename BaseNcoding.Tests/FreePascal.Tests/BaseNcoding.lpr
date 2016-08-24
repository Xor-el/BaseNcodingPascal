program BaseNcoding.Tests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, fpcunittestrunner, Base32Tests, Base64Tests, Base85Tests,
  Base91Tests, Base128Tests, Base256Tests, Base1024Tests, Base4096Tests,
BaseNTests;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

