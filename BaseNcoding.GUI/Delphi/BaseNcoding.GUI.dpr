program BaseNcoding.GUI;

uses
  Forms,
  frmMain in 'src\Main\frmMain.pas' {Form1} ,
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
  BcpIntegerX in '..\..\BaseNcoding\src\UtilityUnits\BcpIntegerX.pas',
  BcpBaseNcodingTypes
    in '..\..\BaseNcoding\src\UtilityUnits\BcpBaseNcodingTypes.pas',
  BcpUtils in '..\..\BaseNcoding\src\UtilityUnits\BcpUtils.pas',
  BcpIBaseInterfaces
    in '..\..\BaseNcoding\src\BaseInterfaces\BcpIBaseInterfaces.pas',
  uStringGenerator in 'src\Helpers\StringGenerator\uStringGenerator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
