object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'BaseNcoder'
  ClientHeight = 687
  ClientWidth = 768
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Comic Sans MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    768
    687)
  PixelsPerInch = 96
  TextHeight = 15
  object label1: TLabel
    Left = 595
    Top = 19
    Width = 38
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Method'
  end
  object label2: TLabel
    Left = 596
    Top = 60
    Width = 24
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Base'
  end
  object label3: TLabel
    Left = 596
    Top = 91
    Width = 85
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Max Line Length'
  end
  object label4: TLabel
    Left = 597
    Top = 121
    Width = 66
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Special Char'
  end
  object label5: TLabel
    Left = 591
    Top = 150
    Width = 78
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Max Bits Count'
  end
  object label6: TLabel
    Left = 595
    Top = 181
    Width = 45
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Alphabet'
  end
  object label7: TLabel
    Left = 591
    Top = 359
    Width = 67
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Bits Per Char'
  end
  object label8: TLabel
    Left = 593
    Top = 380
    Width = 27
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Ratio'
  end
  object label9: TLabel
    Left = 686
    Top = 465
    Width = 74
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Text Encoding'
  end
  object label10: TLabel
    Left = 583
    Top = 580
    Width = 65
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Input Length'
  end
  object label11: TLabel
    Left = 583
    Top = 606
    Width = 72
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Output Length'
  end
  object label12: TLabel
    Left = 583
    Top = 632
    Width = 101
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Output Size (Bytes)'
  end
  object label13: TLabel
    Left = 583
    Top = 658
    Width = 25
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Time'
  end
  object label14: TLabel
    Left = 8
    Top = 360
    Width = 41
    Height = 18
    Caption = 'Output'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
  end
  object label15: TLabel
    Left = 8
    Top = 17
    Width = 33
    Height = 18
    Caption = 'Input'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
  end
  object label16: TLabel
    Left = 292
    Top = 9
    Width = 56
    Height = 15
    Anchors = [akTop, akRight]
    Caption = 'Char Count'
  end
  object cmbMethod: TComboBox
    Left = 658
    Top = 16
    Width = 101
    Height = 23
    Style = csDropDownList
    Anchors = [akTop, akRight]
    TabOrder = 0
    OnChange = cmbMethodSelect
  end
  object speAlphabetLength: TSpinEdit
    Left = 687
    Top = 58
    Width = 72
    Height = 24
    Anchors = [akTop, akRight]
    MaxValue = 8192
    MinValue = 2
    TabOrder = 1
    Value = 2
  end
  object speLineLength: TSpinEdit
    Left = 688
    Top = 88
    Width = 72
    Height = 24
    Anchors = [akTop, akRight]
    AutoSelect = False
    MaxValue = 100
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object tbSpecialChar: TEdit
    Left = 688
    Top = 118
    Width = 72
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    TabOrder = 3
    Text = '='
  end
  object speMaxBitsCount: TSpinEdit
    Left = 689
    Top = 147
    Width = 72
    Height = 24
    Anchors = [akTop, akRight]
    AutoSelect = False
    MaxValue = 10000
    MinValue = 0
    TabOrder = 4
    Value = 64
  end
  object btnGenerateAlphabet: TButton
    Left = 689
    Top = 177
    Width = 72
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Generate'
    TabOrder = 5
    OnClick = btnGenerateAlphabetClick
  end
  object mAlphabet: TMemo
    Left = 589
    Top = 208
    Width = 171
    Height = 137
    Anchors = [akTop, akRight]
    Lines.Strings = (
      'ABCDEFGHIJKLMNOPQR'
      'STUVWXYZabcdefghijklm'
      'nopqrstuvwxyz012345678'
      '9+/'
      '')
    ScrollBars = ssVertical
    TabOrder = 6
    OnKeyPress = mAlphabetKeyPress
  end
  object tbBitsPerChars: TEdit
    Left = 688
    Top = 351
    Width = 72
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 7
  end
  object tbRatio: TEdit
    Left = 688
    Top = 377
    Width = 72
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 8
  end
  object cbPrefixPostfix: TCheckBox
    Left = 583
    Top = 401
    Width = 97
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'PrefixPostfix'
    TabOrder = 9
  end
  object cbReverseOrder: TCheckBox
    Left = 583
    Top = 423
    Width = 178
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Reverse Order (for BaseN only)'
    TabOrder = 10
  end
  object cmbTextEncoding: TComboBox
    Left = 583
    Top = 486
    Width = 178
    Height = 23
    Style = csDropDownList
    Anchors = [akTop, akRight]
    TabOrder = 11
  end
  object btnEncode: TButton
    Left = 658
    Top = 515
    Width = 102
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Encode'
    TabOrder = 12
    OnClick = btnEncodeClick
  end
  object btnDecode: TButton
    Left = 658
    Top = 546
    Width = 102
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Decode'
    TabOrder = 13
    OnClick = btnDecodeClick
  end
  object btnSwapInputOutput: TButton
    Left = 583
    Top = 531
    Width = 69
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #8593#8595
    TabOrder = 14
    OnClick = btnSwapInputOutputClick
  end
  object tbInputLength: TEdit
    Left = 687
    Top = 577
    Width = 72
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 15
  end
  object tbOutputLength: TEdit
    Left = 688
    Top = 603
    Width = 71
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 16
  end
  object tbOutputSize: TEdit
    Left = 687
    Top = 629
    Width = 72
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 17
  end
  object tbTime: TEdit
    Left = 624
    Top = 655
    Width = 135
    Height = 23
    Anchors = [akTop, akRight]
    AutoSelect = False
    ReadOnly = True
    TabOrder = 18
  end
  object mInput: TMemo
    Left = 6
    Top = 57
    Width = 571
    Height = 272
    Anchors = [akLeft, akRight]
    ScrollBars = ssVertical
    TabOrder = 19
    OnChange = mInputChange
    OnKeyPress = mInputKeyPress
  end
  object mOutput: TMemo
    Left = 6
    Top = 383
    Width = 571
    Height = 272
    Anchors = [akLeft, akRight]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 20
    OnKeyPress = mOutputKeyPress
  end
  object cmbSample: TComboBox
    Left = 59
    Top = 16
    Width = 134
    Height = 23
    Style = csDropDownList
    TabOrder = 21
    OnChange = cmbSampleChange
    OnSelect = cmbSampleSelect
  end
  object speGeneratingTextCharCount: TSpinEdit
    Left = 361
    Top = 6
    Width = 72
    Height = 24
    Anchors = [akTop, akRight]
    MaxValue = 10000000
    MinValue = 0
    TabOrder = 22
    Value = 3000
  end
  object btnGenerateInputText: TButton
    Left = 439
    Top = 30
    Width = 122
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Generate Input Text'
    TabOrder = 23
    OnClick = btnGenerateInputTextClick
  end
  object cbOnlyLettersAndDigits: TCheckBox
    Left = 292
    Top = 36
    Width = 141
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Only Letters and Digits'
    Checked = True
    State = cbChecked
    TabOrder = 24
  end
  object cbMaxCompression: TCheckBox
    Left = 583
    Top = 446
    Width = 146
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Max Compression'
    TabOrder = 25
  end
  object cbParallel: TCheckBox
    Left = 583
    Top = 463
    Width = 57
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Parallel'
    TabOrder = 26
  end
end
