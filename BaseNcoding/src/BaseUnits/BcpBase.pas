unit BcpBase;

{$I ..\Include\BaseNcoding.inc}

interface

uses

{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Math
{$ELSE}
    SysUtils,
  Math
{$ENDIF}
    , BcpUtils,
  BcpIBaseInterfaces,
  BcpBaseNcodingTypes;

resourcestring

  SCharCount = 'Base string should contain %u chars';
  SDistinctChars = 'Base string should contain distinct chars';
  SSpecialChar = 'Base string should not contain special char';

type

  TBase = class abstract(TInterfacedObject, IBase)

  strict protected

    FCharsCount: UInt32;
    FBlockBitsCount, FBlockCharsCount: Integer;
    FAlphabet: TBaseNcodingString;
    FSpecial: TBaseNcodingChar;
    FHaveSpecial: Boolean;
    FEncoding: TEncoding;
    FInvAlphabet: TBaseNcodingIntegerArray;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    FParallel: Boolean;
{$ENDIF}
    function GetBitsPerChars: Double;
    function GetCharsCount: UInt32;
    procedure SetCharsCount(value: UInt32);
    function GetBlockBitsCount: Integer;
    procedure SetBlockBitsCount(value: Integer);
    function GetBlockCharsCount: Integer;
    procedure SetBlockCharsCount(value: Integer);
    function GetAlphabet: TBaseNcodingString;
    procedure SetAlphabet(const value: TBaseNcodingString);
    function GetSpecial: TBaseNcodingChar;
    procedure SetSpecial(value: TBaseNcodingChar);
    function GetHaveSpecial: Boolean; virtual; abstract;
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
{$ENDIF}
    function GetName: TBaseNcodingString; virtual;

  public

    constructor Create(_charsCount: UInt32; const _alphabet: TBaseNcodingString;
      const _special: TBaseNcodingChar;
      _encoding: TEncoding = Nil{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
      ; _parallel: Boolean = False
{$ENDIF});

    function EncodeString(const data: TBaseNcodingString)
      : TBaseNcodingString; virtual;
    function Encode(data: TBytes): TBaseNcodingString; virtual; abstract;
    function DecodeToString(const data: TBaseNcodingString)
      : TBaseNcodingString; virtual;
    function Decode(const data: TBaseNcodingString): TBytes; virtual; abstract;

    property BitsPerChars: Double read GetBitsPerChars;
    property CharsCount: UInt32 read GetCharsCount write SetCharsCount;
    property BlockBitsCount: Integer read GetBlockBitsCount
      write SetBlockBitsCount;
    property BlockCharsCount: Integer read GetBlockCharsCount
      write SetBlockCharsCount;
    property Alphabet: TBaseNcodingString read GetAlphabet write SetAlphabet;
    property Special: TBaseNcodingChar read GetSpecial write SetSpecial;
    property HaveSpecial: Boolean read GetHaveSpecial;
    property Encoding: TEncoding read GetEncoding write SetEncoding;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
    property Name: TBaseNcodingString read GetName;
  end;

implementation

constructor TBase.Create(_charsCount: UInt32;
  const _alphabet: TBaseNcodingString; const _special: TBaseNcodingChar;
  _encoding: TEncoding = Nil{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  ; _parallel: Boolean = False
{$ENDIF});
var
  i, j, alphabetMax, bitsPerChar: Integer;

begin
  Inherited Create;
  if ((UInt32(Length(_alphabet))) <> _charsCount) then

    raise EArgumentException.CreateResFmt(@SCharCount, [_charsCount]);

  for i := 1 to _charsCount do
  begin
    for j := Succ(i) to _charsCount do
    begin
      if (_alphabet[i] = _alphabet[j]) then
        raise EArgumentException.CreateRes(@SDistinctChars);

    end;

  end;

  if TUtils.CustomMatchStr(_special, _alphabet) then
    raise EArgumentException.CreateRes(@SSpecialChar);

  CharsCount := _charsCount;
  Alphabet := _alphabet;
  Special := _special;
  bitsPerChar := TUtils.LogBase2(_charsCount);
  BlockBitsCount := TUtils.LCM(bitsPerChar, 8);
  BlockCharsCount := BlockBitsCount div bitsPerChar;

  alphabetMax := TUtils.RetreiveMax(Alphabet);
  SetLength(FInvAlphabet, alphabetMax + 1);

  for i := 0 to Pred(Length(FInvAlphabet)) do
  begin
    FInvAlphabet[i] := -1;
  end;

  for i := 1 to _charsCount do
  begin
    FInvAlphabet[Ord(Alphabet[i])] := i - 1;
  end;

  if _encoding <> Nil then
    Encoding := _encoding
  else
    Encoding := TEncoding.UTF8;

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  Parallel := _parallel;
{$ENDIF}
end;

function TBase.GetBitsPerChars: Double;
var
  tempDouble: Double;
begin
  tempDouble := (BlockBitsCount * 1.0);
  result := tempDouble / BlockCharsCount;
end;

function TBase.GetCharsCount: UInt32;
begin
  result := FCharsCount;
end;

procedure TBase.SetCharsCount(value: UInt32);
begin
  FCharsCount := value;
end;

function TBase.GetBlockBitsCount: Integer;
begin
  result := FBlockBitsCount;
end;

procedure TBase.SetBlockBitsCount(value: Integer);
begin
  FBlockBitsCount := value;
end;

function TBase.GetBlockCharsCount: Integer;
begin
  result := FBlockCharsCount;
end;

procedure TBase.SetBlockCharsCount(value: Integer);
begin
  FBlockCharsCount := value;
end;

function TBase.GetAlphabet: TBaseNcodingString;
begin
  result := FAlphabet;
end;

procedure TBase.SetAlphabet(const value: TBaseNcodingString);
begin
  FAlphabet := value;
end;

function TBase.GetSpecial: TBaseNcodingChar;
begin
  result := FSpecial;
end;

procedure TBase.SetSpecial(value: TBaseNcodingChar);
begin
  FSpecial := value;
end;

function TBase.GetEncoding: TEncoding;
begin
  result := FEncoding;
end;

procedure TBase.SetEncoding(value: TEncoding);
begin
  FEncoding := value;
end;

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}

function TBase.GetParallel: Boolean;
begin
  result := FParallel;
end;

procedure TBase.SetParallel(value: Boolean);
begin
  FParallel := value;
end;

{$ENDIF}

function TBase.GetName: TBaseNcodingString;
begin
  result := Self.ClassName;
end;

function TBase.EncodeString(const data: TBaseNcodingString): TBaseNcodingString;

begin
  result := Encode(Encoding.GetBytes(data));
end;

function TBase.DecodeToString(const data: TBaseNcodingString)
  : TBaseNcodingString;
begin
  result := Encoding.GetString(Decode(StringReplace(data, sLineBreak, '',
    [rfReplaceAll])));
end;

end.
