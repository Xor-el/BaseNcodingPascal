unit uBase91;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  uBase,
  uUtils;

type

  IBase91 = interface
    ['{5BB3F4C5-0806-4E89-ACA0-84EDB0C8F959}']

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

  TBase91 = class(TBase, IBase91)

  public

    const

    DefaultAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~"';

    DefaultSpecial = Char(0);

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TBase91.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin

  Inherited Create(91, _Alphabet, _Special, _textEncoding);
  FHaveSpecial := False;
  BlockBitsCount := 13;
  BlockCharsCount := 2;

end;

function TBase91.Encode(data: TArray<Byte>): String;
var
  ebq, en, ev, i, dataLength: Integer;
  tempResult: TStringBuilder;
begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);

  tempResult := TStringBuilder.Create(dataLength);

  try
    ebq := 0;
    en := 0;
    for i := 0 to Pred(dataLength) do
    begin
      ebq := ebq or ((data[i] and 255) shl en);
      en := en + 8;
      if (en > 13) then
      begin
        ev := ebq and 8191;
        if (ev > 88) then
        begin
          ebq := ebq shr 13;
          en := en - 13;
        end
        else

        begin
          ev := ebq and 16383;
          ebq := ebq shr 14;
          en := en - 14;
        end;
        tempResult.Append(Alphabet[ev mod 91]);
        tempResult.Append(Alphabet[ev div 91]);

      end

    end;

    if (en > 0) then
    begin
      tempResult.Append(Alphabet[ebq mod 91]);
      if ((en > 7) or (ebq > 90)) then

      begin
        tempResult.Append(Alphabet[ebq div 91]);
      end;
    end;
    result := tempResult.ToString;
  finally
    tempResult.Free;
  end;
end;

function TBase91.Decode(const data: String): TArray<Byte>;
var
  dbq, dn, dv, i: Integer;
  tempResult: TList<Byte>;
begin

  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;

  dbq := 0;
  dn := 0;
  dv := -1;

  tempResult := TList<Byte>.Create;
  tempResult.Capacity := Length(data);

  try
    for i := 0 to Pred(Length(data)) do

    begin

      if (FInvAlphabet[Ord(data[i])] = -1) then
        continue;

      if (dv = -1) then
        dv := FInvAlphabet[Ord(data[i])]

      else
      begin

        dv := dv + FInvAlphabet[Ord(data[i])] * 91;
        dbq := dbq or dv shl dn;

        if (dv and 8191) > 88 then
        begin
          dn := dn + 13;
        end
        else
        begin
          dn := dn + 14;
        end;

        while (dn > 7) do
        begin
          tempResult.Add(Byte(dbq));
          dbq := dbq shr 8;
          dn := dn - 8;
        end;
        dv := -1;

      end;

    end;

    if (dv <> -1) then
    begin
      tempResult.Add(Byte(dbq or dv shl dn));
    end;
    result := tempResult.ToArray;
  finally
    tempResult.Free;
  end;

end;

end.
