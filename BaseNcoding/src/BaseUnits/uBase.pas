unit uBase;

{$ZEROBASEDSTRINGS ON}
{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$ENDIF}

interface

uses

  System.SysUtils,
  System.Math,
  IntegerX,
  uUtils;

type

  IBase = interface
    ['{105A4B0A-69E8-41D1-9954-5D1CED996326}']

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
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
  end;

  TBase = class abstract(TInterfacedObject, IBase)

  strict private

    function GetBitsPerChars: Double;
    function GetCharsCount: UInt32;
    procedure SetCharsCount(value: UInt32);
    function GetBlockBitsCount: Integer;
    procedure SetBlockBitsCount(value: Integer);
    function GetBlockCharsCount: Integer;
    procedure SetBlockCharsCount(value: Integer);
    function GetAlphabet: String;
    procedure SetAlphabet(const value: String);
    function GetSpecial: Char;
    procedure SetSpecial(value: Char);
    function GetEncoding: TEncoding;
    procedure SetEncoding(value: TEncoding);
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
{$ENDIF}
  protected

  class var
    FCharsCount: UInt32;
    FBlockBitsCount, FBlockCharsCount: Integer;
    FAlphabet: String;
    FSpecial: Char;
    FHaveSpecial: Boolean;
    FEncoding: TEncoding;
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    FParallel: Boolean;
{$ENDIF}
  public

    constructor Create(_charsCount: LongWord; const _alphabet: String;
      const _special: Char;
      _encoding: TEncoding = Nil{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
      ; _parallel: Boolean = False
{$ENDIF});
    function GetHaveSpecial: Boolean; virtual; abstract;
    function EncodeString(const data: String): String; virtual;
    function Encode(data: TArray<Byte>): String; virtual; abstract;
    function DecodeToString(const data: String): String; virtual;
    function Decode(const data: String): TArray<Byte>; virtual; abstract;

    /// <summary>
    /// From: http://stackoverflow.com/a/600306/1046374
    /// </summary>
    /// <param name="x"></param>
    /// <returns></returns>

    class function IsPowerOf2(x: LongWord): Boolean; static;

    /// <summary>
    /// From: http://stackoverflow.com/a/13569863/1046374
    /// </summary>

    class function LCM(a, b: Integer): Integer; static;
    class function NextPowOf2(x: LongWord): LongWord; static;
    class function IntPow(x: UInt64; exp: Integer): UInt64; static;
    class function BigIntPow(x: TIntegerX; exp: Integer): TIntegerX; static;
    class function LogBase2(x: LongWord): Integer; overload; static;
    class function LogBase2(x: UInt64): Integer; overload; static;
    class function LogBaseN(x, n: LongWord): Integer; overload; static;
    class function LogBaseN(x: UInt64; n: LongWord): Integer; overload; static;
    class function GetOptimalBitsCount(CharsCount: LongWord;
      out charsCountInBits: LongWord; maxBitsCount: LongWord = 64;
      radix: LongWord = 2): Integer; static;
    class function GetOptimalBitsCount2(CharsCount: LongWord;
      out charsCountInBits: LongWord; maxBitsCount: LongWord = 64;
      base2BitsCount: Boolean = False): Integer; static;

    property BitsPerChars: Double read GetBitsPerChars;
    property CharsCount: UInt32 read GetCharsCount write SetCharsCount;
    property BlockBitsCount: Integer read GetBlockBitsCount
      write SetBlockBitsCount;
    property BlockCharsCount: Integer read GetBlockCharsCount
      write SetBlockCharsCount;
    property Alphabet: String read GetAlphabet write SetAlphabet;
    property Special: Char read GetSpecial write SetSpecial;
    property HaveSpecial: Boolean read GetHaveSpecial;
    property Encoding: TEncoding read GetEncoding write SetEncoding;
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
  protected

    FInvAlphabet: TArray<Integer>;

  end;

implementation

constructor TBase.Create(_charsCount: LongWord; const _alphabet: String;
  const _special: Char;
  _encoding: TEncoding = Nil{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  ; _parallel: Boolean = False
{$ENDIF});
var
  i, j, alphabetMax, bitsPerChar: Integer;

begin
  Inherited Create;
  if ((UInt32(Length(_alphabet))) <> _charsCount) then

    raise EArgumentException.Create
      (Format('Base string should contain %u chars', [_charsCount]));

  for i := 0 to Pred(_charsCount) do
  begin
    for j := Succ(i) to Pred(_charsCount) do
    begin
      if (_alphabet[i] = _alphabet[j]) then
        raise EArgumentException.Create
          ('Base string should contain distinct chars');

    end;

  end;

  if TUtils.CustomMatchStr(_special, _alphabet) then
    raise EArgumentException.Create
      ('Base string should not contain special char');

  CharsCount := _charsCount;
  Alphabet := _alphabet;
  Special := _special;
  bitsPerChar := LogBase2(_charsCount);
  BlockBitsCount := LCM(bitsPerChar, 8);
  BlockCharsCount := BlockBitsCount div bitsPerChar;

  alphabetMax := TUtils.RetreiveMax(Alphabet);
  SetLength(FInvAlphabet, alphabetMax + 1);

  for i := 0 to Pred(Length(FInvAlphabet)) do
  begin
    FInvAlphabet[i] := -1;
  end;

  for i := 0 to Pred(_charsCount) do
  begin
    FInvAlphabet[Ord(Alphabet[i])] := i;
  end;

  if _encoding <> Nil then
    Encoding := _encoding
  else
    Encoding := TEncoding.UTF8;

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
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

function TBase.GetAlphabet: String;
begin
  result := FAlphabet;
end;

procedure TBase.SetAlphabet(const value: String);
begin
  FAlphabet := value;
end;

function TBase.GetSpecial: Char;
begin
  result := FSpecial;
end;

procedure TBase.SetSpecial(value: Char);
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

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}

function TBase.GetParallel: Boolean;
begin
  result := FParallel;
end;

procedure TBase.SetParallel(value: Boolean);
begin
  FParallel := value;
end;

{$ENDIF}

function TBase.EncodeString(const data: String): String;

begin
  result := Encode(Encoding.GetBytes(data));
end;

function TBase.DecodeToString(const data: String): String;
begin
  result := Encoding.GetString(Decode(StringReplace(data, sLineBreak, '',
    [rfReplaceAll])));
end;

class function TBase.IsPowerOf2(x: LongWord): Boolean;
var
  xint: LongWord;
begin
  xint := LongWord(x);

  if (x - xint <> 0) then

    result := False
  else

    result := (xint and (xint - 1)) = 0;
end;

class function TBase.LCM(a, b: Integer): Integer;
var
  num1, num2, i: Integer;

begin

  if (a > b) then
  begin
    num1 := a;
    num2 := b;
  end

  else
  begin
    num1 := b;
    num2 := a;
  end;

  for i := 1 to (num2) do

  begin
    if ((num1 * i) mod num2 = 0) then
    begin
      result := i * num1;
      Exit;
    end;

  end;
  result := num2;

end;

class function TBase.NextPowOf2(x: LongWord): LongWord;

begin
  dec(x);
  x := x or (x shr 1);
  x := x or (x shr 2);
  x := x or (x shr 4);
  x := x or (x shr 8);
  x := x or (x shr 16);
  inc(x);
  result := x;

end;

class function TBase.IntPow(x: UInt64; exp: Integer): UInt64;
var
  tempResult: UInt64;
  i: Integer;
begin
  tempResult := 1;
  i := 0;

  while i < exp do
  begin
    tempResult := tempResult * x;
    inc(i);
  end;

  result := tempResult;

end;

class function TBase.BigIntPow(x: TIntegerX; exp: Integer): TIntegerX;
var
  tempResult: TIntegerX;
  i: Integer;
begin
  tempResult := 1;
  i := 0;

  while i < exp do
  begin
    tempResult := tempResult * x;
    inc(i);
  end;

  result := tempResult;

end;

class function TBase.LogBase2(x: LongWord): Integer;
var
  r: Integer;
begin
  r := 0;
  x := x shr 1;
  while ((x) <> 0) do
  begin
    inc(r);
    x := x shr 1;
  end;
  result := r;

end;

class function TBase.LogBase2(x: UInt64): Integer;
var
  r: Integer;
begin
  r := 0;
  x := x shr 1;
  while ((x) <> 0) do
  begin
    inc(r);
    x := x shr 1;
  end;
  result := r;

end;

class function TBase.LogBaseN(x, n: LongWord): Integer;
var
  r: Integer;
begin
  r := 0;
  x := x div n;
  while ((x) <> 0) do
  begin
    inc(r);
    x := x div n;
  end;
  result := r;
end;

class function TBase.LogBaseN(x: UInt64; n: LongWord): Integer;
var
  r: Integer;
begin
  r := 0;
  x := x div n;
  while ((x) <> 0) do
  begin
    inc(r);
    x := x div n;
  end;
  result := r;
end;

class function TBase.GetOptimalBitsCount(CharsCount: LongWord;
  out charsCountInBits: LongWord; maxBitsCount: LongWord = 64;
  radix: LongWord = 2): Integer;
var
  maxRatio, ratio, charsCountLog, temp, dCharsCount, dradix, multemp: Double;
  n, n1: Integer;
  l1: LongWord;

begin
  result := 0;
  charsCountInBits := 0;
  n1 := LogBaseN(CharsCount, radix);
  dCharsCount := (CharsCount * 1.0);
  dradix := (radix * 1.0);
  charsCountLog := LogN(dCharsCount, dradix);
  maxRatio := 0;

  n := n1;
  while (UInt32(n) <= maxBitsCount) do
  begin
    temp := n * charsCountLog;
    l1 := UInt32(Ceil(temp));
    multemp := (n * 1.0);
    ratio := multemp / l1;
    if (ratio > maxRatio) then
    begin
      maxRatio := ratio;
      result := n;
      charsCountInBits := l1;
    end;
    inc(n);
  end;

end;

class function TBase.GetOptimalBitsCount2(CharsCount: LongWord;
  out charsCountInBits: LongWord; maxBitsCount: LongWord = 64;
  base2BitsCount: Boolean = False): Integer;

var
  n, n1: Integer;
  charsCountLog, ratio, maxRatio, temp, multemp, dCharsCount, d2: Double;
  l1: LongWord;
begin
  result := 0;
  charsCountInBits := 0;
  n1 := LogBase2(CharsCount);
  dCharsCount := (CharsCount * 1.0);
  d2 := (2 * 1.0);
  charsCountLog := LogN(dCharsCount, d2);
  maxRatio := 0;

  for n := n1 to maxBitsCount do

  begin

    if ((Ord(base2BitsCount) and (n mod 8)) <> 0) then
      continue;
    temp := n * charsCountLog;
    l1 := UInt32(Ceil(temp));

    multemp := (n * 1.0);

    ratio := multemp / l1;

    if (ratio > maxRatio) then
    begin
      maxRatio := ratio;
      result := n;
      charsCountInBits := l1;
    end;

  end;

end;

end.
