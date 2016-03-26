program BaseNcodingDelphi;

uses
  Vcl.Forms,
  uBase in 'src\BaseUnits\uBase.pas',
  uBase32 in 'src\BaseUnits\uBase32.pas',
  uBase64 in 'src\BaseUnits\uBase64.pas',
  uBase85 in 'src\BaseUnits\uBase85.pas',
  uBase91 in 'src\BaseUnits\uBase91.pas',
  uBase128 in 'src\BaseUnits\uBase128.pas',
  uBase256 in 'src\BaseUnits\uBase256.pas',
  uBase1024 in 'src\BaseUnits\uBase1024.pas',
  uBase4096 in 'src\BaseUnits\uBase4096.pas',
  uBaseN in 'src\BaseUnits\uBaseN.pas',
  uZBase32 in 'src\BaseUnits\uZBase32.pas',
  uUtils in 'src\UtilityUnits\uUtils.pas',
  IntegerX in 'src\UtilityUnits\IntegerX.pas',
  uBaseBigN in 'src\BaseUnits\uBaseBigN.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;

end.
