unit uBase91;

{$I ..\Include\BaseNcoding.inc}

interface

uses

  uBaseNcodingTypes,
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Classes,
{$ELSE}
  SysUtils,
  Classes,
{$ENDIF}
{$IFDEF FPC}
  fgl,
{$ELSE}
{$IFDEF SCOPEDUNITNAMES}
  System.Generics.Collections,
{$ELSE}
  Generics.Collections,
{$ENDIF}
{$ENDIF}
  uBase,
  uUtils;

type

  IBase91 = interface
    ['{5BB3F4C5-0806-4E89-ACA0-84EDB0C8F959}']

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

  TBase91 = class(TBase, IBase91)

  public

    const

    DefaultAlphabet: Array [0 .. 90] of TBaseNcodingChar = ('A', 'B', 'C', 'D',
      'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
      'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
      'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
      'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '#',
      '$', '%', '&', '(', ')', '*', '+', ',', '.', '/', ':', ';', '<', '=', '>',
      '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '"');

    DefaultSpecial = TBaseNcodingChar(0);

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil);

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TBase91.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(91, _Alphabet, _Special, _textEncoding);
  BlockBitsCount := 13;
  BlockCharsCount := 2;

end;

function TBase91.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TBase91.Encode(data: TBytes): TBaseNcodingString;
var
  ebq, en, ev, i, dataLength: Integer;
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

  dataLength := Length(data);

{$IFDEF FPC}
  tempResult := TFPGList<TBaseNcodingChar>.Create;
{$ELSE}
  tempResult := TStringBuilder.Create(dataLength);
{$ENDIF}
  try
    ebq := 0;
    en := 0;
    for i := 0 to Pred(dataLength) do
    begin
      ebq := ebq or ((Integer(data[i]) and 255) shl en);
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
{$IFDEF FPC}
        tempResult.Add(Alphabet[(ev mod 91) + 1]);
        tempResult.Add(Alphabet[(ev div 91) + 1]);

{$ELSE}
        tempResult.Append(Alphabet[(ev mod 91) + 1]);
        tempResult.Append(Alphabet[(ev div 91) + 1]);

{$ENDIF}
      end

    end;

    if (en > 0) then
    begin
{$IFDEF FPC}
      tempResult.Add(Alphabet[(ebq mod 91) + 1]);

{$ELSE}
      tempResult.Append(Alphabet[(ebq mod 91) + 1]);

{$ENDIF}
      if ((en > 7) or (ebq > 90)) then

      begin
{$IFDEF FPC}
        tempResult.Add(Alphabet[(ebq div 91) + 1]);

{$ELSE}
        tempResult.Append(Alphabet[(ebq div 91) + 1]);

{$ENDIF}
      end;
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

function TBase91.Decode(const data: TBaseNcodingString): TBytes;
var
  dbq, dn, dv, i, j: Integer;
  b: Byte;
{$IFDEF FPC}
  tempResult: TFPGList<Byte>
{$ELSE}
  tempResult: TList<Byte>
{$ENDIF};
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

{$IFDEF FPC}
  tempResult := TFPGList<Byte>.Create;
{$ELSE}
  tempResult := TList<Byte>.Create;
{$ENDIF};
  tempResult.Capacity := Length(data);

  try
    for i := 0 to Pred(Length(data)) do

    begin

      if (FInvAlphabet[Ord(data[(i) + 1])] = -1) then
        continue;

      if (dv = -1) then
        dv := FInvAlphabet[Ord(data[(i) + 1])]

      else
      begin

        dv := dv + FInvAlphabet[Ord(data[(i) + 1])] * 91;
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

    SetLength(result, tempResult.Count);
    j := 0;
    for b in tempResult do
    begin
      result[j] := b;
      Inc(j);
    end;

  finally
    tempResult.Free;
  end;

end;

end.
