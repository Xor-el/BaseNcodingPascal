unit uBaseBigN;

{$ZEROBASEDSTRINGS ON}
{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$ENDIF}

interface

uses

  System.SysUtils,
  System.Math,
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  System.Classes,
  System.Threading,
{$ENDIF}
  IntegerX,
  uBase,
  uUtils;

type

  IBaseBigN = interface
    ['{CEA46191-74D3-4354-AC89-A312E0758035}']

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
    function GetBlockMaxBitsCount: UInt32;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount;
    function GetReverseOrder: Boolean;
    property ReverseOrder: Boolean read GetReverseOrder;
    function GetMaxCompression: Boolean;
    property MaxCompression: Boolean read GetMaxCompression;
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
  end;

  TBaseBigN = class(TBase, IBaseBigN)

  strict private
    procedure EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
      beginInd, endInd, _blockBitsCount, _blockCharsCount: Integer);
    procedure DecodeBlock(const src: String; dst: TArray<Byte>;
      beginInd, endInd, _blockBitsCount, _blockCharsCount: Integer);
    procedure BitsToChars(chars: TArray<Char>; ind, count: Integer;
      block: TIntegerX);
    function CharsToBits(const data: String; ind, count: Integer): TIntegerX;
    function GetBitsN(data: TArray<Byte>; bitPos, bitsCount: Integer)
      : TIntegerX;
    procedure AddBitsN(data: TArray<Byte>; value: TIntegerX;
      bitPos, bitsCount: Integer);
    procedure PreparePowN(_blockCharsCount: Integer);
    function GetBlockMaxBitsCount: UInt32;
    procedure SetBlockMaxBitsCount(value: UInt32);
    function GetReverseOrder: Boolean;
    procedure SetReverseOrder(value: Boolean);
    function GetMaxCompression: Boolean;
    procedure SetMaxCompression(value: Boolean);

  protected

  class var
    FBlockMaxBitsCount: UInt32;
    FReverseOrder, FMaxCompression: Boolean;
    F_powN: TArray<TIntegerX>;
    Ftwo_in_power_n: TArray<Byte>;

  public

    constructor Create(const _Alphabet: String; _blockMaxBitsCount: UInt32 = 64;
      _Encoding: TEncoding = Nil; _reverseOrder: Boolean = False;
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
      _parallel: Boolean = False; {$ENDIF}
      _maxCompression: Boolean = False);

    class constructor BaseBigN();

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount
      write SetBlockMaxBitsCount;
    property ReverseOrder: Boolean read GetReverseOrder write SetReverseOrder;
    property MaxCompression: Boolean read GetMaxCompression
      write SetMaxCompression;

  end;

implementation

constructor TBaseBigN.Create(const _Alphabet: String;
  _blockMaxBitsCount: UInt32 = 64; _Encoding: TEncoding = Nil;
  _reverseOrder: Boolean = False;
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  _parallel: Boolean = False; {$ENDIF}
  _maxCompression: Boolean = False);
var
  charsCountInBits: LongWord;

begin
  Inherited Create(UInt32(Length(_Alphabet)), _Alphabet, Char(0),
    _Encoding{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}, _parallel{$ENDIF});
  FHaveSpecial := False;
  BlockMaxBitsCount := _blockMaxBitsCount;

  BlockBitsCount := GetOptimalBitsCount(CharsCount, charsCountInBits,
    BlockMaxBitsCount, 2);
  BlockCharsCount := Integer(charsCountInBits);

  PreparePowN(BlockCharsCount);
  ReverseOrder := _reverseOrder;
  MaxCompression := _maxCompression;
end;

class constructor TBaseBigN.BaseBigN();
var
  a, i: Integer;

begin
  SetLength(Ftwo_in_power_n, 8);
  a := 2;
  for i := 0 to Pred(8) do
  begin
    Ftwo_in_power_n[i] := Byte(a - 1);
    a := a * 2;
  end;

end;

function TBaseBigN.Encode(data: TArray<Byte>): String;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    globalCharsCount, iterationCount, _blockBitsCount,
    _blockCharsCount{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)},
    processorCount, beginInd, endInd
{$ENDIF}: Integer;
  bits: TIntegerX;
  tempResult: TArray<Char>;
  dLengthAlphabet, d2, tempD: Double;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  if (not MaxCompression) then
  begin
    _blockBitsCount := BlockBitsCount;
    _blockCharsCount := BlockCharsCount;
  end
  else
  begin
    _blockBitsCount := Length(data) * 8;
    dLengthAlphabet := (Length(Alphabet) * 1.0);
    d2 := (2 * 1.0);
    tempD := LogN(dLengthAlphabet, d2);
    _blockCharsCount := Integer(Ceil(_blockBitsCount * tempD));
    PreparePowN(_blockCharsCount);
  end;

  mainBitsLength := (Length(data) * 8 div _blockBitsCount) * _blockBitsCount;
  tailBitsLength := Length(data) * 8 - mainBitsLength;
  mainCharsCount := mainBitsLength * _blockCharsCount div _blockBitsCount;
  tailCharsCount := (tailBitsLength * _blockCharsCount + _blockBitsCount - 1)
    div _blockBitsCount;
  globalCharsCount := mainCharsCount + tailCharsCount;
  iterationCount := mainCharsCount div _blockCharsCount;

  SetLength(tempResult, globalCharsCount);

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  if (not Parallel) then
  begin
    EncodeBlock(data, tempResult, 0, iterationCount, _blockBitsCount,
      _blockCharsCount);
  end
  else
  begin
    processorCount := Min(iterationCount, TThread.processorCount);
    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin
        beginInd := idx * iterationCount div processorCount;
        endInd := (idx + 1) * iterationCount div processorCount;
        EncodeBlock(data, tempResult, beginInd, endInd, _blockBitsCount,
          _blockCharsCount);
      end);
  end;

{$ELSE}
  EncodeBlock(data, tempResult, 0, iterationCount, _blockBitsCount,
    _blockCharsCount);
{$ENDIF}
  if (tailBitsLength <> 0) then
  begin
    bits := GetBitsN(data, mainBitsLength, tailBitsLength);
    BitsToChars(tempResult, mainCharsCount, tailCharsCount, bits);
  end;
  SetString(result, PChar(tempResult), Length(tempResult));

end;

function TBaseBigN.Decode(const data: String): TArray<Byte>;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    iterationCount, globalBitsLength, _blockBitsCount,
    _blockCharsCount{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)},
    processorCount, beginInd, endInd
{$ENDIF}: Integer;
  bits, tailBits: TIntegerX;
  tempResult: TArray<Byte>;
  dLengthAlphabet, d2, tempD, tempD2: Double;

begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;

  if (not MaxCompression) then
  begin
    _blockBitsCount := BlockBitsCount;
    _blockCharsCount := BlockCharsCount;
  end
  else
  begin
    _blockCharsCount := Length(data);
    dLengthAlphabet := (Length(Alphabet) * 1.0);
    d2 := (2 * 1.0);
    tempD := LogN(dLengthAlphabet, d2);
    tempD2 := _blockCharsCount / tempD;
    _blockBitsCount := Trunc(tempD2) div 8 * 8;
    PreparePowN(_blockCharsCount);
  end;

  globalBitsLength := ((Length(data) - 1) * _blockBitsCount div _blockCharsCount
    + 8) div 8 * 8;
  mainBitsLength := globalBitsLength div _blockBitsCount * _blockBitsCount;
  tailBitsLength := globalBitsLength - mainBitsLength;
  mainCharsCount := mainBitsLength * _blockCharsCount div _blockBitsCount;
  tailCharsCount := (tailBitsLength * _blockCharsCount + _blockBitsCount - 1)
    div _blockBitsCount;
  tailBits := CharsToBits(data, mainCharsCount, tailCharsCount);
  if ((tailBits shr tailBitsLength) <> 0) then
  begin
    globalBitsLength := globalBitsLength + 8;
    mainBitsLength := globalBitsLength div _blockBitsCount * _blockBitsCount;
    tailBitsLength := globalBitsLength - mainBitsLength;
    mainCharsCount := mainBitsLength * _blockCharsCount div _blockBitsCount;
    tailCharsCount := (tailBitsLength * _blockCharsCount + _blockBitsCount - 1)
      div _blockBitsCount;

  end;

  iterationCount := mainCharsCount div _blockCharsCount;

  SetLength(tempResult, globalBitsLength div 8);

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  if (not Parallel) then
  begin
    DecodeBlock(data, tempResult, 0, iterationCount, _blockBitsCount,
      _blockCharsCount);
  end
  else
  begin
    processorCount := Min(iterationCount, TThread.processorCount);
    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin
        beginInd := idx * iterationCount div processorCount;
        endInd := (idx + 1) * iterationCount div processorCount;
        DecodeBlock(data, tempResult, beginInd, endInd, _blockBitsCount,
          _blockCharsCount);
      end);
  end;

{$ELSE}
  DecodeBlock(data, tempResult, 0, iterationCount, _blockBitsCount,
    _blockCharsCount);
{$ENDIF}
  if (tailCharsCount <> 0) then
  begin

    bits := CharsToBits(data, mainCharsCount, tailCharsCount);
    AddBitsN(tempResult, bits, mainBitsLength, tailBitsLength);
  end;
  result := tempResult;

end;

procedure TBaseBigN.EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
beginInd, endInd, _blockBitsCount, _blockCharsCount: Integer);

var
  ind, charInd, bitInd: Integer;
  bits: TIntegerX;

begin
  for ind := beginInd to Pred(endInd) do
  begin
    charInd := ind * Integer(_blockCharsCount);
    bitInd := ind * _blockBitsCount;
    bits := GetBitsN(src, bitInd, _blockBitsCount);
    BitsToChars(dst, charInd, Integer(_blockCharsCount), bits);
  end;
end;

procedure TBaseBigN.DecodeBlock(const src: String; dst: TArray<Byte>;
beginInd, endInd, _blockBitsCount, _blockCharsCount: Integer);

var
  ind, charInd, bitInd: Integer;
  bits: TIntegerX;

begin
  for ind := beginInd to Pred(endInd) do
  begin
    charInd := ind * Integer(_blockCharsCount);
    bitInd := ind * _blockBitsCount;
    bits := CharsToBits(src, charInd, Integer(_blockCharsCount));
    AddBitsN(dst, bits, bitInd, _blockBitsCount);
  end;
end;

procedure TBaseBigN.BitsToChars(chars: TArray<Char>; ind, count: Integer;
block: TIntegerX);
var
  i: Integer;
begin

  for i := 0 to Pred(count) do
  begin
    if not ReverseOrder then
    begin
      chars[ind + i] := (Alphabet[Integer(block mod CharsCount)]);
    end
    else
    begin
      chars[ind + (count - 1 - i)] := (Alphabet[Integer(block mod CharsCount)]);
    end;
    block := block div CharsCount;
  end;

end;

function TBaseBigN.CharsToBits(const data: String; ind, count: Integer)
  : TIntegerX;

var
  i: Integer;
begin
  result := 0;
  for i := 0 to Pred(count) do
  begin
    if not ReverseOrder then
    begin

      result := result + FInvAlphabet[Ord(data[ind + i])] *
        F_powN[Length(F_powN) - 1 - i];
    end
    else
    begin

      result := result + FInvAlphabet[Ord(data[ind + (count - 1 - i)])] *
        F_powN[Length(F_powN) - 1 - i];
    end;
  end;

end;

function TBaseBigN.GetBitsN(data: TArray<Byte>; bitPos, bitsCount: Integer)
  : TIntegerX;
var
  currentBytePos, currentBitInBytePos, xLength, x2Length: Integer;

begin
  result := 0;
  currentBytePos := bitPos div 8;
  currentBitInBytePos := bitPos mod 8;
  xLength := Min(bitsCount, 8 - currentBitInBytePos);
  if (xLength <> 0) then
  begin

    result := ((TIntegerX(data[currentBytePos]) shr (8 - xLength -
      currentBitInBytePos)) and Ftwo_in_power_n[7 - currentBitInBytePos])
      shl (bitsCount - xLength);

    currentBytePos := currentBytePos + (currentBitInBytePos + xLength) div 8;
    currentBitInBytePos := (currentBitInBytePos + xLength) mod 8;
    x2Length := bitsCount - xLength;
    if (x2Length > 8) then
    begin
      x2Length := 8;
    end;
    while (x2Length > 0) do
    begin
      xLength := xLength + x2Length;
      result := result or (TIntegerX(data[currentBytePos] shr (8 - x2Length))
        shl (bitsCount - xLength));

      currentBytePos := currentBytePos + (currentBitInBytePos + x2Length) div 8;
      currentBitInBytePos := (currentBitInBytePos + x2Length) mod 8;

      x2Length := bitsCount - xLength;
      if (x2Length > 8) then
      begin
        x2Length := 8;
      end;
    end;

  end;
end;

procedure TBaseBigN.AddBitsN(data: TArray<Byte>; value: TIntegerX;
bitPos, bitsCount: Integer);
var
  currentBytePos, currentBitInBytePos, xLength, x2Length: Integer;
  x1, x2: Byte;
begin
  currentBytePos := bitPos div 8;
  currentBitInBytePos := bitPos mod 8;

  xLength := Min(bitsCount, 8 - currentBitInBytePos);
  if (xLength <> 0) then
  begin
    x1 := Byte((value shr (bitsCount + currentBitInBytePos - 8)) and
      Ftwo_in_power_n[7 - currentBitInBytePos]);

    data[currentBytePos] := data[currentBytePos] or x1;

    currentBytePos := currentBytePos + (currentBitInBytePos + xLength) div 8;
    currentBitInBytePos := (currentBitInBytePos + xLength) mod 8;

    x2Length := bitsCount - xLength;
    if (x2Length > 8) then
    begin
      x2Length := 8;
    end;

    while (x2Length > 0) do
    begin
      xLength := xLength + x2Length;

      x2 := Byte(((value shr (bitsCount - xLength)) shl (8 - x2Length))
        and $FF);

      data[currentBytePos] := data[currentBytePos] or x2;

      currentBytePos := currentBytePos + (currentBitInBytePos + x2Length) div 8;
      currentBitInBytePos := (currentBitInBytePos + x2Length) mod 8;

      x2Length := bitsCount - xLength;
      if (x2Length > 8) then
      begin
        x2Length := 8;
      end;
    end
  end;
end;

procedure TBaseBigN.PreparePowN(_blockCharsCount: Integer);
var
  i: Integer;
  pow: TIntegerX;
begin
  SetLength(F_powN, _blockCharsCount);
  pow := 1;
  i := 0;
  while (i < (_blockCharsCount - 1)) do
  begin
    F_powN[_blockCharsCount - 1 - i] := pow;
    pow := pow * CharsCount;
    Inc(i);
  end;

  if (_blockCharsCount > 0) then
    F_powN[0] := pow;

end;

function TBaseBigN.GetBlockMaxBitsCount: UInt32;
begin
  result := FBlockMaxBitsCount;
end;

procedure TBaseBigN.SetBlockMaxBitsCount(value: UInt32);
begin
  FBlockMaxBitsCount := value;
end;

function TBaseBigN.GetReverseOrder: Boolean;
begin
  result := FReverseOrder;
end;

procedure TBaseBigN.SetReverseOrder(value: Boolean);
begin
  FReverseOrder := value;
end;

function TBaseBigN.GetMaxCompression: Boolean;
begin
  result := FMaxCompression;
end;

procedure TBaseBigN.SetMaxCompression(value: Boolean);
begin
  FMaxCompression := value;
end;

end.
