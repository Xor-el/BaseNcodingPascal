unit frmMain;

{$IF CompilerVersion >= 24}  // XE3 and Above
{$LEGACYIFEND ON}
{$ZEROBASEDSTRINGS OFF}
{$IFEND}
//
{$IF CompilerVersion >= 21}  // 2010 and Above
{$DEFINE DELPHI2010_UP}
{$IFEND}
//
{$IF CompilerVersion >= 22} // XE and Above
{$DEFINE DELPHIXE_UP}
{$IFEND}
//
{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$IFEND}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
{$IFDEF DELPHI2010_UP}
  Diagnostics,
{$ENDIF}
  IniFiles,
  StrUtils,
  RTTI,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Spin,
  BcpBase,
  BcpBase32,
  BcpBase64,
  BcpBase85,
  BcpBase91,
  BcpBase128,
  BcpBase256,
  BcpBase1024,
  BcpBase4096,
  BcpZBase32,
  BcpBaseN,
  BcpBaseBigN,
  BcpIBaseInterfaces,
  uStringGenerator,
  BcpUtils;

type

  TForm1 = class(TForm)
    cmbMethod: TComboBox;
    label1: TLabel;
    speAlphabetLength: TSpinEdit;
    label2: TLabel;
    speLineLength: TSpinEdit;
    label3: TLabel;
    tbSpecialChar: TEdit;
    label4: TLabel;
    label5: TLabel;
    speMaxBitsCount: TSpinEdit;
    btnGenerateAlphabet: TButton;
    label6: TLabel;
    mAlphabet: TMemo;
    tbBitsPerChars: TEdit;
    label7: TLabel;
    label8: TLabel;
    tbRatio: TEdit;
    cbPrefixPostfix: TCheckBox;
    cbReverseOrder: TCheckBox;
    cmbTextEncoding: TComboBox;
    label9: TLabel;
    btnEncode: TButton;
    btnDecode: TButton;
    btnSwapInputOutput: TButton;
    label10: TLabel;
    tbInputLength: TEdit;
    label11: TLabel;
    tbOutputLength: TEdit;
    label12: TLabel;
    tbOutputSize: TEdit;
    label13: TLabel;
    tbTime: TEdit;
    mInput: TMemo;
    mOutput: TMemo;
    label14: TLabel;
    cmbSample: TComboBox;
    label15: TLabel;
    label16: TLabel;
    speGeneratingTextCharCount: TSpinEdit;
    btnGenerateInputText: TButton;
    cbOnlyLettersAndDigits: TCheckBox;
    cbMaxCompression: TCheckBox;
    cbParallel: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cmbSampleSelect(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbMethodSelect(Sender: TObject);
    procedure btnSwapInputOutputClick(Sender: TObject);
    procedure mInputChange(Sender: TObject);
    procedure btnGenerateInputTextClick(Sender: TObject);
    procedure btnGenerateAlphabetClick(Sender: TObject);
    procedure mInputKeyPress(Sender: TObject; var Key: Char);
    procedure mOutputKeyPress(Sender: TObject; var Key: Char);
    procedure cmbSampleChange(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure btnDecodeClick(Sender: TObject);
    procedure mAlphabetKeyPress(Sender: TObject; var Key: Char);

  protected
  class var
    FSamplePairs, FMethodPairs, FEncodingPairs: TStringList;
    FtextEncoding: TEncoding;
    FSettings: TIniFile;
  private
    { Private declarations }
    function GetMethod(): IBase;
    procedure EncodeDecode(_Tag: Integer);
  public
    { Public declarations }
  end;

  TValueObject = class(TObject)

  strict private
    FValue: TValue;

  public
    constructor Create(const aValue: TValue);
    property Value: TValue read FValue;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

constructor TValueObject.Create(const aValue: TValue);
begin
  FValue := aValue;
end;

function TForm1.GetMethod(): IBase;
var
  method: IBase;
  alphabet, tempStr, EncodingStr: String;
  tempInt, tempInt2: Integer;
  tempDouble: Double;
  special: Char;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  parallel: Boolean;
{$ENDIF}
begin
  method := Nil;
  alphabet := mAlphabet.Text;
  if (Length(tbSpecialChar.Text) > 1) then
    raise EArgumentException.Create('Special char should contains one symbol');
  if TUtils.IsNullOrEmpty(tbSpecialChar.Text) then
    special := Char(0)
  else
    special := tbSpecialChar.Text[1];
  if cmbTextEncoding.ItemIndex <> -1 then
  begin

    EncodingStr := TValueObject(cmbTextEncoding.Items.Objects
      [cmbTextEncoding.ItemIndex]).Value.AsString;

    // pretty dumb way of parsing the Encoding but hey it works :)
    tempInt2 := AnsiIndexStr(EncodingStr, ['TEncoding.UTF8', 'TEncoding.ASCII',
      'TEncoding.BigEndianUnicode', 'TEncoding.Default', 'TEncoding.Unicode',
      'TEncoding.UTF7']);

    Case tempInt2 of

      0:
        begin
          FtextEncoding := TEncoding.UTF8;
        end;

      1:
        begin
          FtextEncoding := TEncoding.ASCII;
        end;

      2:
        begin
          FtextEncoding := TEncoding.BigEndianUnicode;
        end;

      3:
        begin
          FtextEncoding := TEncoding.Default;
        end;

      4:
        begin
          FtextEncoding := TEncoding.Unicode;
        end;

      5:
        begin
          FtextEncoding := TEncoding.UTF7;
        end;

    end;

  end

  else
    FtextEncoding := Nil;

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  parallel := cbParallel.Checked;
{$ENDIF}
  tempStr := cmbMethod.Items[cmbMethod.ItemIndex];
  tempInt := AnsiIndexStr(tempStr, ['Base32', 'Base64', 'Base128', 'Base256',
    'Base1024', 'Base4096', 'ZBase32', 'Base85', 'Base91', 'BaseN',
    'BaseBigN']);

  Case tempInt of

    0:
      begin
        method := TBase32.Create(alphabet, special, FtextEncoding);
      end;

    1:
      begin
        method := TBase64.Create(alphabet, special,
          FtextEncoding{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, parallel{$ENDIF});
      end;

    2:
      begin
        method := TBase128.Create(alphabet, special, FtextEncoding);
      end;

    3:
      begin
        method := TBase256.Create(alphabet, special, FtextEncoding);
      end;

    4:
      begin
        method := TBase1024.Create(alphabet, special, FtextEncoding);
      end;

    5:
      begin
        method := TBase4096.Create(alphabet, special, FtextEncoding);
      end;

    6:
      begin
        method := TZBase32.Create(alphabet, special, FtextEncoding);
      end;

    7:
      begin
        method := TBase85.Create(alphabet, special, cbPrefixPostfix.Checked,
          FtextEncoding);
      end;

    8:
      begin
        method := TBase91.Create(alphabet, special, FtextEncoding);
      end;

    9:
      begin
        method := TBaseN.Create(alphabet, UInt32(speMaxBitsCount.Value),
          FtextEncoding,
          cbReverseOrder.Checked{$IFDEF SUPPORT_PARALLEL_PROGRAMMING},
          parallel{$ENDIF});
      end;

    10:
      begin
        method := TBaseBigN.Create(alphabet, UInt32(speMaxBitsCount.Value),
          FtextEncoding, cbReverseOrder.Checked,
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
          parallel, {$ENDIF} cbMaxCompression.Checked);
      end;

  end;

  tbBitsPerChars.Text := IntToStr(method.BlockBitsCount) + '/' +
    IntToStr(method.BlockCharsCount);
  tempDouble := method.BlockBitsCount / method.BlockCharsCount;
  tbRatio.Text := FormatFloat('0.000000', tempDouble);
  speAlphabetLength.Value := method.CharsCount;
  result := method;
end;

procedure TForm1.EncodeDecode(_Tag: Integer);
var
  method: IBase;
  encode: Boolean;
  tempRes: String;
{$IFDEF DELPHI2010_UP}
  stopwatch: TStopWatch;
{$ELSE}
  C1, C2: UInt32;
{$ENDIF}
begin

  method := GetMethod();
  try

    if _Tag = 0 then
      encode := True
    else if _Tag = 1 then
      encode := false
    else
      raise Exception.Create('Invalid Params');

{$IFDEF DELPHI2010_UP}
    stopwatch := TStopWatch.Create;
    stopwatch.Start;
{$ELSE}
    C1 := GetTickCount;
{$ENDIF}
    if encode then
      tempRes := method.EncodeString(mInput.Text)

    else
      tempRes := method.DecodeToString(mInput.Text);

{$IFDEF DELPHI2010_UP}
    stopwatch.Stop;
{$ELSE}
    C2 := GetTickCount;
{$ENDIF}
    mOutput.Text := tempRes;

{$IFDEF DELPHI2010_UP}
    tbTime.Text := stopwatch.Elapsed;
{$ELSE}
    tbTime.Text := UIntToStr(C2 - C1) + ' MS (Milliseconds)';
{$ENDIF}
    tbOutputLength.Text := IntToStr(Length(tempRes));
    tbOutputSize.Text := IntToStr(method.Encoding.GetByteCount(tempRes));

  except
    ShowMessage('Error');
  end;

end;

procedure TForm1.mAlphabetKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
    mAlphabet.SelectAll;
end;

procedure TForm1.mInputChange(Sender: TObject);
begin
  tbInputLength.Text := IntToStr(Length(mInput.Lines.Text));
end;

procedure TForm1.mInputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
    mInput.SelectAll;
end;

procedure TForm1.mOutputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
    mOutput.SelectAll;
end;

procedure TForm1.btnDecodeClick(Sender: TObject);
begin
  EncodeDecode(1);
end;

procedure TForm1.btnEncodeClick(Sender: TObject);
begin
  EncodeDecode(0);
end;

procedure TForm1.btnGenerateAlphabetClick(Sender: TObject);
begin
  mAlphabet.Text := TStringGenerator.GetAlphabet
    (Integer(speAlphabetLength.Value));
  GetMethod();
end;

procedure TForm1.btnGenerateInputTextClick(Sender: TObject);
begin
  mInput.Text := TStringGenerator.GetRandom
    (Integer(speGeneratingTextCharCount.Value), cbOnlyLettersAndDigits.Checked);
  mOutput.Clear();
  tbOutputLength.Text := '0';
  tbOutputSize.Text := '0';
end;

procedure TForm1.btnSwapInputOutputClick(Sender: TObject);
var
  t: String;
begin
  t := mInput.Text;
  mInput.Text := mOutput.Text;
  mOutput.Text := t;
end;

procedure TForm1.cmbMethodSelect(Sender: TObject);
var
  tempStr: String;
  tempInt: Integer;
  encoder: IBase;

begin
  cbPrefixPostfix.Enabled := false;
  if cmbMethod.ItemIndex <> 7 then
  begin
    cbPrefixPostfix.Checked := false;
  end;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  cbParallel.Enabled := false;
  if (not(cmbMethod.ItemIndex in [1, 9, 10])) then
  begin
    cbParallel.Checked := false;
  end;
{$ENDIF}
  speAlphabetLength.Enabled := false;
  speMaxBitsCount.Enabled := false;
  tempStr := cmbMethod.Items[cmbMethod.ItemIndex];
  tempInt := AnsiIndexStr(tempStr, ['Base32', 'Base64', 'Base128', 'Base256',
    'Base1024', 'Base4096', 'ZBase32', 'Base85', 'Base91', 'BaseN',
    'BaseBigN']);

  Case tempInt of

    0:
      begin
        mAlphabet.Text := TBase32.DefaultAlphabet;
        tbSpecialChar.Text := TBase32.DefaultSpecial;
      end;

    1:
      begin
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
        cbParallel.Enabled := True;
{$ENDIF}
        mAlphabet.Text := TBase64.DefaultAlphabet;
        tbSpecialChar.Text := TBase64.DefaultSpecial;
      end;

    2:
      begin
        mAlphabet.Text := TBase128.DefaultAlphabet;
        tbSpecialChar.Text := TBase128.DefaultSpecial;
      end;

    3:
      begin
        mAlphabet.Text := TBase256.DefaultAlphabet;
        tbSpecialChar.Text := TBase256.DefaultSpecial;
      end;

    4:
      begin
        mAlphabet.Text := TBase1024.DefaultAlphabet;
        tbSpecialChar.Text := TBase1024.DefaultSpecial;
      end;

    5:
      begin
        mAlphabet.Text := TBase4096.DefaultAlphabet;
        tbSpecialChar.Text := TBase4096.DefaultSpecial;
      end;

    6:
      begin
        mAlphabet.Text := TZBase32.DefaultAlphabet;
        tbSpecialChar.Text := TZBase32.DefaultSpecial;
      end;

    7:
      begin
        cbPrefixPostfix.Enabled := True;
        mAlphabet.Text := TBase85.DefaultAlphabet;
        tbSpecialChar.Text := TBase85.DefaultSpecial;
      end;

    8:
      begin
        mAlphabet.Text := TBase91.DefaultAlphabet;
        tbSpecialChar.Text := TBase91.DefaultSpecial;
      end;

    9 .. 10:
      begin
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
        cbParallel.Enabled := True;
{$ENDIF}
        mAlphabet.Text := TStringGenerator.GetAlphabet
          (Integer(speAlphabetLength.Value));
        tbSpecialChar.Text := '';
        speAlphabetLength.Enabled := True;
        speMaxBitsCount.Enabled := True;
      end;

  end;

  encoder := GetMethod();
end;

procedure TForm1.cmbSampleChange(Sender: TObject);
var
  b: String;
begin
  if (cmbSample.ItemIndex <> -1) then
  begin

    b := TValueObject(cmbSample.Items.Objects[cmbSample.ItemIndex])
      .Value.AsString;
    mInput.Text := b;
    tbInputLength.Text := IntToStr(Length(mInput.Lines.Text));
    mOutput.Clear();
    tbOutputLength.Text := '0';
    tbOutputSize.Text := '0';
  end;
end;

procedure TForm1.cmbSampleSelect(Sender: TObject);

begin
  mInput.Text := TValueObject(cmbSample.Items.Objects[cmbSample.ItemIndex])
    .Value.AsString;
  mOutput.Clear();
  tbOutputLength.Text := '0';
  tbOutputSize.Text := '0';

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  idx: Integer;

begin
{$IF NOT DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  cbParallel.Visible := false;
{$IFEND}
  Form1.mInput.Lines.Text :=
    'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and '
    + 'indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.';

  FSamplePairs := TStringList.Create(True);
  FSamplePairs.Add
    ('Base64SampleString =Man is distinguished, not only by his reason, but by this singular passion from '
    + 'other animals, which is a lust of the mind, that by a perseverance of delight '
    + 'in the continued and indefatigable generation of knowledge, exceeds the short '
    + 'vehemence of any carnal pleasure.');

  FSamplePairs.Add
    ('RusString =Зарегистрируйтесь сейчас на Десятую Международную Конференцию по '
    + 'Unicode, которая состоится 10-12 марта 1997 года в Майнце в Германии. ' +
    'Конференция соберет широкий круг экспертов по  вопросам глобального ' +
    'Интернета и Unicode, локализации и интернационализации, воплощению и ' +
    'применению Unicode в различных операционных системах и программных ' +
    'приложениях, шрифтах, верстке и многоязычных компьютерных системах.');

  FSamplePairs.Add('GreekString =Σὲ γνωρίζω ἀπὸ τὴν κόψη ' +
    'τοῦ σπαθιοῦ τὴν τρομερή, ' + 'σὲ γνωρίζω ἀπὸ τὴν ὄψη ' +
    'ποὺ μὲ βία μετράει τὴ γῆ. ' + '᾿Απ᾿ τὰ κόκκαλα βγαλμένη ' +
    'τῶν ῾Ελλήνων τὰ ἱερά ' + 'καὶ σὰν πρῶτα ἀνδρειωμένη ' +
    'χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!');

  for idx := 0 to FSamplePairs.Count - 1 do

  begin
    FSamplePairs.Objects[idx] := TValueObject.Create
      (FSamplePairs.ValueFromIndex[idx]);

    FSamplePairs.Strings[idx] := FSamplePairs.Names[idx];

  end;

  cmbSample.Items := FSamplePairs;

  FMethodPairs := TStringList.Create(True);

  FMethodPairs.Add('Base32=Base32');
  FMethodPairs.Add('Base64=Base64');
  FMethodPairs.Add('Base128=Base128');
  FMethodPairs.Add('Base256=Base256');
  FMethodPairs.Add('Base1024=Base1024');
  FMethodPairs.Add('Base4096=Base4096');
  FMethodPairs.Add('ZBase32=ZBase32');
  FMethodPairs.Add('Base85=Base85');
  FMethodPairs.Add('Base91=Base91');
  FMethodPairs.Add('BaseN=BaseN');
  FMethodPairs.Add('BaseBigN=BaseBigN');

  for idx := 0 to FMethodPairs.Count - 1 do

  begin
    FMethodPairs.Objects[idx] := TValueObject.Create
      (FMethodPairs.ValueFromIndex[idx]);

    FMethodPairs.Strings[idx] := FMethodPairs.Names[idx];
  end;

  cmbMethod.Items := FMethodPairs;

  FEncodingPairs := TStringList.Create(True);
{$IFDEF DELPHIXE_UP}
  FEncodingPairs.Add(TEncoding.UTF8.EncodingName + '=TEncoding.UTF8');
  FEncodingPairs.Add(TEncoding.ASCII.EncodingName + '=TEncoding.ASCII');
  FEncodingPairs.Add(TEncoding.BigEndianUnicode.EncodingName +
    '=TEncoding.BigEndianUnicode');
  FEncodingPairs.Add(TEncoding.Default.EncodingName + '=TEncoding.Default');
  FEncodingPairs.Add(TEncoding.Unicode.EncodingName + '=TEncoding.Unicode');
  FEncodingPairs.Add(TEncoding.UTF7.EncodingName + '=TEncoding.UTF7');
{$ELSE}
  FEncodingPairs.Add(TEncoding.UTF8.ClassName + '=TEncoding.UTF8');
  FEncodingPairs.Add(TEncoding.ASCII.ClassName + '=TEncoding.ASCII');
  FEncodingPairs.Add(TEncoding.BigEndianUnicode.ClassName +
    '=TEncoding.BigEndianUnicode');
  FEncodingPairs.Add(TEncoding.Unicode.ClassName + '=TEncoding.Unicode');
  FEncodingPairs.Add(TEncoding.UTF7.ClassName + '=TEncoding.UTF7');
{$ENDIF}
  for idx := 0 to FEncodingPairs.Count - 1 do

  begin
    FEncodingPairs.Objects[idx] :=
      TValueObject.Create(FEncodingPairs.ValueFromIndex[idx]);

    FEncodingPairs.Strings[idx] := FEncodingPairs.Names[idx];
  end;

  cmbTextEncoding.Items := FEncodingPairs;

  FSettings := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try

    cmbMethod.ItemIndex := FSettings.ReadInteger('Settings',
      'DefaultMethod', 1);
    tbSpecialChar.Text := FSettings.ReadString('Settings',
      'DefaultSpecialChar', '=');
    mAlphabet.Text := FSettings.ReadString('Settings', 'DefaultAlphabet',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
    cbPrefixPostfix.Checked := FSettings.ReadBool('Settings',
      'DefaultPrefixPostfix', false);
    speLineLength.Value := FSettings.ReadInteger('Settings',
      'DefaultMaxLineLength', 0);
    cmbTextEncoding.ItemIndex := FSettings.ReadInteger('Settings',
      'DefaultTextEncoding', 0);
    cmbSample.ItemIndex := FSettings.ReadInteger('Settings',
      'DefaultSample', 0);
    mInput.Text := FSettings.ReadString('Settings', 'DefaultInputText',
      TValueObject(cmbSample.Items.Objects[0]).Value.AsString);
    speGeneratingTextCharCount.Value := FSettings.ReadInteger('Settings',
      'DefaultGeneratingTextCharCount', 3000);
    cbOnlyLettersAndDigits.Checked := FSettings.ReadBool('Settings',
      'DefaultGenerateOnlyLettersAndDigits', True);
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    cbParallel.Checked := FSettings.ReadBool('Settings',
      'DefaultParallel', false);
{$ENDIF}
    speMaxBitsCount.Value := FSettings.ReadInteger('Settings',
      'DefaultMaxBitsCount', 64);
    cbReverseOrder.Checked := FSettings.ReadBool('Settings',
      'DefaultReverseOrder', false);
    cbMaxCompression.Checked := FSettings.ReadBool('Settings',
      'DefaultMaxCompression', false);

  finally
    FSettings.Free;
  end;

  cmbMethod.OnChange(cmbMethod);
  tbOutputLength.Text := '0';
  tbOutputSize.Text := '0';

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FSettings := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try

    FSettings.WriteInteger('Settings', 'DefaultMethod', cmbMethod.ItemIndex);
    FSettings.WriteInteger('Settings', 'DefaultMaxLineLength',
      Integer(speLineLength.Value));
    if TUtils.IsNullOrEmpty(tbSpecialChar.Text) then
    begin
      FSettings.WriteString('Settings', 'DefaultSpecialChar', Char(0))
    end
    else
    begin
      FSettings.WriteString('Settings', 'DefaultSpecialChar',
        tbSpecialChar.Text[1]);
    end;
    FSettings.WriteString('Settings', 'DefaultAlphabet', mAlphabet.Text);
    FSettings.WriteBool('Settings', 'DefaultPrefixPostfix',
      cbPrefixPostfix.Checked);
    FSettings.WriteInteger('Settings', 'DefaultTextEncoding',
      cmbTextEncoding.ItemIndex);
    FSettings.WriteInteger('Settings', 'DefaultSample', cmbSample.ItemIndex);
    FSettings.WriteString('Settings', 'DefaultInputText', mInput.Text);
    FSettings.WriteInteger('Settings', 'DefaultGeneratingTextCharCount',
      Integer(speGeneratingTextCharCount.Value));
    FSettings.WriteBool('Settings', 'DefaultGenerateOnlyLettersAndDigits',
      cbOnlyLettersAndDigits.Checked);
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    FSettings.WriteBool('Settings', 'DefaultParallel', cbParallel.Checked);
{$ENDIF}
    FSettings.WriteInteger('Settings', 'DefaultMaxBitsCount',
      Integer(speMaxBitsCount.Value));
    FSettings.WriteBool('Settings', 'DefaultReverseOrder',
      cbReverseOrder.Checked);
    FSettings.WriteBool('Settings', 'DefaultMaxCompression',
      cbMaxCompression.Checked);

  finally
    FSettings.Free;
  end;

  cmbSample.Clear;
  cmbMethod.Clear;
  cmbTextEncoding.Clear;
  FSamplePairs.Free;
  FMethodPairs.Free;
  FEncodingPairs.Free;

end;

end.
