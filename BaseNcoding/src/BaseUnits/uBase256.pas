unit uBase256;

{$I ..\Include\BaseNcoding.inc}

interface

uses

  uBaseNcodingTypes,
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  uBase,
  uUtils
{$IFDEF FPC}
    , fgl
{$ENDIF};

type
  IBase256 = interface
    ['{66F55DDE-FC44-4BDC-93C7-94956212B66B}']

    function Encode(data: TBytes): TBaseNcodingString;
    function Decode(const data: TBaseNcodingString): TBytes;
    function EncodeString(const data: TBaseNcodingString): TBaseNcodingString;
    function DecodeToString(const data: TBaseNcodingString): TBaseNcodingString;
    function GetBitsPerChars: Double;
    property BitsPerChars: Double read GetBitsPerChars;
    function GetCharsCount: UInt32;
    property CharsCount: UInt32 read GetCharsCount;
    function GetBlockBitsCount: Integer;
    property BlockBitsCount: Integer read GetBlockBitsCount;
    function GetBlockCharsCount: Integer;
    property BlockCharsCount: Integer read GetBlockCharsCount;
    function GetAlphabet: TBaseNcodingString;
    property Alphabet: TBaseNcodingString read GetAlphabet;
    function GetSpecial: TBaseNcodingChar;
    property Special: TBaseNcodingChar read GetSpecial;
    function GetHaveSpecial: Boolean;
    property HaveSpecial: Boolean read GetHaveSpecial;
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
    property Encoding: TEncoding read GetEncoding write SetEncoding;

  end;

  TBase256 = class(TBase, IBase256)

  public

    const

    DefaultAlphabet: Array [0 .. 255] of TBaseNcodingChar = ('!', '#', '$', '%',
      '&', '''', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3',
      '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', 'B',
      'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
      'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\', ']', '^', '_', '`',
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
      'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~',
      ' ', '¡', '¢', '£', '¤', '¥', '¦', '§', '¨', '©', 'ª', '«', '¬', '­', '®',
      '¯', '°', '±', '²', '³', '´', 'µ', '¶', '·', '¸', '¹', 'º', '»', '¼', '½',
      '¾', '¿', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì',
      'Í', 'Î', 'Ï', 'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', '×', 'Ø', 'Ù', 'Ú', 'Û',
      'Ü', 'Ý', 'Þ', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê',
      'ë', 'ì', 'í', 'î', 'ï', 'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù',
      'ú', 'û', 'ü', 'ý', 'þ', 'ÿ', 'Ā', 'ā', 'Ă', 'ă', 'Ą', 'ą', 'Ć', 'ć', 'Ĉ',
      'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ď', 'ď', 'Đ', 'đ', 'Ē', 'ē', 'Ĕ', 'ĕ', 'Ė', 'ė',
      'Ę', 'ę', 'Ě', 'ě', 'Ĝ', 'ĝ', 'Ğ', 'ğ', 'Ġ', 'ġ', 'Ģ', 'ģ', 'Ĥ', 'ĥ', 'Ħ',
      'ħ', 'Ĩ', 'ĩ', 'Ī', 'ī', 'Ĭ', 'ĭ', 'Į', 'į', 'İ', 'ı', 'Ĳ', 'ĳ', 'Ĵ', 'ĵ',
      'Ķ', 'ķ', 'ĸ', 'Ĺ', 'ĺ', 'Ļ', 'ļ', 'Ľ', 'ľ', 'Ŀ', 'ŀ', 'Ł', 'ł');

    DefaultSpecial = TBaseNcodingChar(0);

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TBase256.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(256, _Alphabet, _Special, _textEncoding);
end;

function TBase256.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TBase256.Encode(data: TBytes): TBaseNcodingString;
var
  i, dataLength: Integer;
{$IFNDEF FPC}
  tempResult: TStringBuilder;
{$ELSE}
  tempResult: TFPGList<TBaseNcodingChar>;
  uC: TBaseNcodingChar;
{$ENDIF}
begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

{$IFDEF FPC}
  tempResult := TFPGList<TBaseNcodingChar>.Create;
  tempResult.Capacity := Length(data);
{$ELSE}
  tempResult := TStringBuilder.Create(Length(data));
{$ENDIF}
  dataLength := Length(data);
  try

    for i := 0 to Pred(dataLength) do

    begin

{$IFDEF FPC}
      tempResult.Add(Alphabet[(data[i]) + 1]);
{$ELSE}
      tempResult.Append(Alphabet[(data[i]) + 1]);
{$ENDIF}
    end;
{$IFDEF FPC}
    result := '';
    for uC in tempResult do
    begin
      result := result + uC;
    end;
{$ELSE}
    result := tempResult.ToString;
{$ENDIF}
  finally
    tempResult.Free;
  end;
end;

function TBase256.Decode(const data: TBaseNcodingString): TBytes;
var
  i: Integer;
begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;

  SetLength(result, Length(data));
  for i := 0 to Pred(Length(data)) do
  begin
    result[i] := Byte(FInvAlphabet[Ord(data[(i) + 1])]);
  end;

end;

end.
