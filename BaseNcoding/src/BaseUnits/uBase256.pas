unit uBase256;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  uBase,
  uUtils;

type

  IBase256 = interface
    ['{66F55DDE-FC44-4BDC-93C7-94956212B66B}']

    function Encode(data: TArray<Byte>): String;
    function Decode(const data: String): TArray<Byte>;
    function EncodeString(const data: String): String;
    function DecodeToString(const data: String): String;
    function GetBitsPerChars: Double;
    property BitsPerChars: Double read GetBitsPerChars;
    function GetCharsCount: UInt32;
    property CharsCount: UInt32 read GetCharsCount;
    function GetBlockBitsCount: Integer;
    property BlockBitsCount: Integer read GetBlockBitsCount;
    function GetBlockCharsCount: Integer;
    property BlockCharsCount: Integer read GetBlockCharsCount;
    function GetAlphabet: String;
    property Alphabet: String read GetAlphabet;
    function GetSpecial: Char;
    property Special: Char read GetSpecial;
    function GetHaveSpecial: Boolean;
    property HaveSpecial: Boolean read GetHaveSpecial;
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
    property Encoding: TEncoding read GetEncoding write SetEncoding;

  end;

  TBase256 = class(TBase, IBase256)

  public

    const

    DefaultAlphabet = '!' +
      '#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁł';

    DefaultSpecial = Char(0);

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TBase256.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  Inherited Create(256, _Alphabet, _Special, _textEncoding);
end;

function TBase256.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TBase256.Encode(data: TArray<Byte>): string;
var
  i, dataLength: Integer;
  tempResult: TStringBuilder;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  tempResult := TStringBuilder.Create(Length(data));

  dataLength := Length(data);
  try

    for i := 0 to Pred(dataLength) do

    begin

      tempResult.Append(Alphabet[data[i]]);

    end;
    result := tempResult.ToString;
  finally
    tempResult.Free;
  end;
end;

function TBase256.Decode(const data: String): TArray<Byte>;
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
    result[i] := Byte(FInvAlphabet[Ord(data[i])]);
  end;

end;

end.
