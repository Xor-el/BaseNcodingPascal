program BaseNcoding.GUI;

uses
  Vcl.Forms,
  frmMain in 'src\Main\frmMain.pas' {Form1} ,
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
  uStringGenerator in 'src\Helpers\StringGenerator\uStringGenerator.pas',
  uBaseBigN in '..\BaseNcoding\src\BaseUnits\uBaseBigN.pas',
  IntegerX in '..\BaseNcoding\src\UtilityUnits\IntegerX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
