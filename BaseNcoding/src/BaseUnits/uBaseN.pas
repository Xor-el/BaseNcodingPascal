unit uBaseN;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  System.Math,
  uBase,
  uUtils;

type

  IBaseN = interface
    ['{5D0520CF-2A5A-4B3F-9263-7C2F1F822E8B}']

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

  end;

  TBaseN = class(TBase, IBaseN)

  strict private
    procedure EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
      beginInd, endInd: Integer);
    procedure DecodeBlock(const src: String; dst: TArray<Byte>;
      beginInd, endInd: Integer);
    procedure BitsToChars(chars: TArray<Char>; ind, count: Integer;
      block: UInt64);
    function CharsToBits(const data: String; ind, count: Integer): UInt64;
    function GetBits64(data: TArray<Byte>; bitPos, bitsCount: Integer): UInt64;
    procedure AddBits64(data: TArray<Byte>; value: UInt64;
      bitPos, bitsCount: Integer);
    function GetBlockMaxBitsCount: UInt32;
    procedure SetBlockMaxBitsCount(value: UInt32);
    function GetReverseOrder: Boolean;
    procedure SetReverseOrder(value: Boolean);

  protected

  class var
    FBlockMaxBitsCount: UInt32;
    FReverseOrder: Boolean;
    F_powN: TArray<UInt64>;

  public

    constructor Create(const _Alphabet: String; _blockMaxBitsCount: UInt32 = 32;
      _Encoding: TEncoding = Nil; _reverseOrder: Boolean = False);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount
      write SetBlockMaxBitsCount;
    property ReverseOrder: Boolean read GetReverseOrder write SetReverseOrder;

  end;

implementation

constructor TBaseN.Create(const _Alphabet: String;
  _blockMaxBitsCount: UInt32 = 32; _Encoding: TEncoding = Nil;
  _reverseOrder: Boolean = False);
var
  charsCountInBits: LongWord;
  pow: UInt64;
  i: Integer;
begin
  Inherited Create(UInt32(Length(_Alphabet)), _Alphabet, Char(0), _Encoding);
  FHaveSpecial := False;
  BlockMaxBitsCount := _blockMaxBitsCount;

  BlockBitsCount := GetOptimalBitsCount(CharsCount, charsCountInBits,
    _blockMaxBitsCount);
  BlockCharsCount := Integer(charsCountInBits);

  SetLength(F_powN, BlockCharsCount);
  pow := UInt64(1);
  i := 0;
  while (i < (BlockCharsCount - 1)) do
  begin
    F_powN[BlockCharsCount - 1 - i] := pow;
    pow := pow * CharsCount;
    Inc(i);
  end;

  F_powN[0] := pow;
  ReverseOrder := _reverseOrder;
end;

function TBaseN.Encode(data: TArray<Byte>): String;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    globalCharsCount, iterationCount: Integer;
  bits: UInt64;
  tempResult: TArray<Char>;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  mainBitsLength := (Length(data) * 8 div BlockBitsCount) * BlockBitsCount;
  tailBitsLength := Length(data) * 8 - mainBitsLength;
  mainCharsCount := mainBitsLength * BlockCharsCount div BlockBitsCount;
  tailCharsCount := (tailBitsLength * BlockCharsCount + BlockBitsCount - 1)
    div BlockBitsCount;
  globalCharsCount := mainCharsCount + tailCharsCount;
  iterationCount := mainCharsCount div BlockCharsCount;

  SetLength(tempResult, globalCharsCount);
  EncodeBlock(data, tempResult, 0, iterationCount);
  if (tailBitsLength <> 0) then
  begin
    bits := GetBits64(data, mainBitsLength, tailBitsLength);
    BitsToChars(tempResult, mainCharsCount, tailCharsCount, bits);
  end;
  SetString(result, PChar(tempResult), Length(tempResult));

end;

function TBaseN.Decode(const data: String): TArray<Byte>;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    iterationCount, globalBitsLength: Integer;
  bits, tailBits: UInt64;
  tempResult: TArray<Byte>;

begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;
  globalBitsLength := ((Length(data) - 1) * BlockBitsCount div BlockCharsCount +
    8) div 8 * 8;
  mainBitsLength := globalBitsLength div BlockBitsCount * BlockBitsCount;
  tailBitsLength := globalBitsLength - mainBitsLength;
  mainCharsCount := mainBitsLength * BlockCharsCount div BlockBitsCount;
  tailCharsCount := (tailBitsLength * BlockCharsCount + BlockBitsCount - 1)
    div BlockBitsCount;
  tailBits := CharsToBits(data, mainCharsCount, tailCharsCount);
  if ((tailBits shr tailBitsLength) <> 0) then
  begin
    globalBitsLength := globalBitsLength + 8;
    mainBitsLength := globalBitsLength div BlockBitsCount * BlockBitsCount;
    tailBitsLength := globalBitsLength - mainBitsLength;
    mainCharsCount := mainBitsLength * BlockCharsCount div BlockBitsCount;
    tailCharsCount := (tailBitsLength * BlockCharsCount + BlockBitsCount - 1)
      div BlockBitsCount;

  end;

  iterationCount := mainCharsCount div BlockCharsCount;

  SetLength(tempResult, globalBitsLength div 8);
  DecodeBlock(data, tempResult, 0, iterationCount);

  if (tailCharsCount <> 0) then
  begin

    bits := CharsToBits(data, mainCharsCount, tailCharsCount);
    AddBits64(tempResult, bits, mainBitsLength, tailBitsLength);
  end;
  result := tempResult;

end;

procedure TBaseN.EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
  beginInd, endInd: Integer);

var
  ind, charInd, bitInd: Integer;
  bits: UInt64;

begin
  for ind := beginInd to Pred(endInd) do
  begin
    charInd := ind * Integer(BlockCharsCount);
    bitInd := ind * BlockBitsCount;
    bits := GetBits64(src, bitInd, BlockBitsCount);
    BitsToChars(dst, charInd, Integer(BlockCharsCount), bits);
  end;
end;

procedure TBaseN.DecodeBlock(const src: String; dst: TArray<Byte>;
  beginInd, endInd: Integer);

var
  ind, charInd, bitInd: Integer;
  bits: UInt64;

begin
  for ind := beginInd to Pred(endInd) do
  begin
    charInd := ind * Integer(BlockCharsCount);
    bitInd := ind * BlockBitsCount;
    bits := CharsToBits(src, charInd, Integer(BlockCharsCount));
    AddBits64(dst, bits, bitInd, BlockBitsCount);
  end;
end;

procedure TBaseN.BitsToChars(chars: TArray<Char>; ind, count: Integer;
  block: UInt64);
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

function TBaseN.CharsToBits(const data: String; ind, count: Integer): UInt64;

var
  i: Integer;
begin
  result := UInt64(0);
  for i := 0 to Pred(count) do
  begin
    if not ReverseOrder then
    begin

      result := result + UInt64(FInvAlphabet[Ord(data[ind + i])] *
        F_powN[BlockCharsCount - 1 - i]);
    end
    else
    begin

      result := result + UInt64(FInvAlphabet[Ord(data[ind + (count - 1 - i)])] *
        F_powN[BlockCharsCount - 1 - i]);
    end;
  end;

end;

function TBaseN.GetBits64(data: TArray<Byte>;
  bitPos, bitsCount: Integer): UInt64;
var
  currentBytePos, currentBitInBytePos, xLength, x2Length: Integer;
  a: UInt64;

begin
  result := UInt64(0);
  currentBytePos := bitPos div 8;
  currentBitInBytePos := bitPos mod 8;
  xLength := Min(bitsCount, 8 - currentBitInBytePos);
  if (xLength <> 0) then
  begin
    a := UInt64(UInt64(data[currentBytePos]) shl (56 + currentBitInBytePos));

    result := (UInt64(a) shr (64 - xLength)) shl (bitsCount - xLength);
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

      result := result or (((UInt64(data[currentBytePos])) shr (8 - x2Length))
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

{$OVERFLOWCHECKS OFF}

procedure TBaseN.AddBits64(data: TArray<Byte>; value: UInt64;
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
    x1 := Byte(((value shl (64 - bitsCount)) shr (56 + currentBitInBytePos)));
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
      x2 := Byte((value shr (bitsCount - xLength)) shl (8 - x2Length));
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

function TBaseN.GetBlockMaxBitsCount: UInt32;
begin
  result := FBlockMaxBitsCount;
end;

procedure TBaseN.SetBlockMaxBitsCount(value: UInt32);
begin
  FBlockMaxBitsCount := value;
end;

function TBaseN.GetReverseOrder: Boolean;
begin
  result := FReverseOrder;
end;

procedure TBaseN.SetReverseOrder(value: Boolean);
begin
  FReverseOrder := value;
end;

end.
