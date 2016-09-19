unit uBaseN;

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
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    , System.Classes,
  System.Threading
{$ENDIF}
    , uBase,
  uIBaseInterfaces,
  uBaseNcodingTypes,
  uUtils;

type

  TBaseN = class sealed(TBase, IBaseN)

  strict private
    FBlockMaxBitsCount: UInt32;
    FReverseOrder: Boolean;
    F_powN: TBaseNcodingUInt64Array;

    procedure EncodeBlock(src: TBytes; dst: TBaseNcodingCharArray;
      beginInd, endInd: Integer);
    procedure DecodeBlock(const src: TBaseNcodingString; dst: TBytes;
      beginInd, endInd: Integer);

    procedure BitsToChars(chars: TBaseNcodingCharArray; ind, count: Integer;
      block: UInt64);
    function CharsToBits(const data: TBaseNcodingString;
      ind, count: Integer): UInt64;
    function GetBits64(data: TBytes; bitPos, bitsCount: Integer): UInt64;
    procedure AddBits64(data: TBytes; value: UInt64;
      bitPos, bitsCount: Integer);
    function GetBlockMaxBitsCount: UInt32;
    procedure SetBlockMaxBitsCount(value: UInt32);
    function GetReverseOrder: Boolean;
    procedure SetReverseOrder(value: Boolean);

  public

    constructor Create(const _Alphabet: TBaseNcodingString;
      _blockMaxBitsCount: UInt32 = 32; _Encoding: TEncoding = Nil;
      _reverseOrder: Boolean = False{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
      ; _parallel: Boolean = False
{$ENDIF});

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount
      write SetBlockMaxBitsCount;
    property ReverseOrder: Boolean read GetReverseOrder write SetReverseOrder;

  end;

implementation

constructor TBaseN.Create(const _Alphabet: TBaseNcodingString;
  _blockMaxBitsCount: UInt32 = 32; _Encoding: TEncoding = Nil;
  _reverseOrder: Boolean = False{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  ; _parallel: Boolean = False
{$ENDIF});
var
  charsCountInBits: UInt32;
  pow: UInt64;
  i: Integer;
begin
  Inherited Create(UInt32(Length(_Alphabet)), _Alphabet, TBaseNcodingChar(0),
    _Encoding{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, _parallel{$ENDIF});

  BlockMaxBitsCount := _blockMaxBitsCount;

  BlockBitsCount := TUtils.GetOptimalBitsCount(CharsCount, charsCountInBits,
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

function TBaseN.GetHaveSpecial: Boolean;
begin
  result := False;
end;

function TBaseN.Encode(data: TBytes): TBaseNcodingString;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    globalCharsCount, iterationCount{$IFDEF SUPPORT_PARALLEL_PROGRAMMING},
    processorCount, beginInd, endInd
{$ENDIF}: Integer;
  bits: UInt64;
  tempResult: TBaseNcodingCharArray;

begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    result := ('');
    Exit;
  end;

  mainBitsLength := (Length(data) * 8 div BlockBitsCount) * BlockBitsCount;
  tailBitsLength := Length(data) * 8 - mainBitsLength;
  mainCharsCount := mainBitsLength * BlockCharsCount div BlockBitsCount;
  tailCharsCount := (tailBitsLength * BlockCharsCount + BlockBitsCount - 1)
    div BlockBitsCount;
  globalCharsCount := mainCharsCount + tailCharsCount;
  iterationCount := mainCharsCount div BlockCharsCount;

  SetLength(tempResult, globalCharsCount);

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  if (not Parallel) then
  begin
    EncodeBlock(data, tempResult, 0, iterationCount);
  end
  else
  begin
    processorCount := Min(iterationCount, TThread.processorCount);

    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin

        beginInd := idx * iterationCount div processorCount;
        endInd := (idx + 1) * iterationCount div processorCount;

        EncodeBlock(data, tempResult, beginInd, endInd);
      end);

  end;

{$ELSE}
  EncodeBlock(data, tempResult, 0, iterationCount);
{$ENDIF}
  if (tailBitsLength <> 0) then
  begin
    bits := GetBits64(data, mainBitsLength, tailBitsLength);
    BitsToChars(tempResult, mainCharsCount, tailCharsCount, bits);
  end;
  SetString(result, PBaseNcodingChar(@tempResult[0]), Length(tempResult));

end;

function TBaseN.Decode(const data: TBaseNcodingString): TBytes;
var
  mainBitsLength, tailBitsLength, mainCharsCount, tailCharsCount,
    iterationCount, globalBitsLength{$IFDEF SUPPORT_PARALLEL_PROGRAMMING},
    processorCount, beginInd, endInd
{$ENDIF}: Integer;
  bits, tailBits: UInt64;
  tempResult: TBytes;

begin
  if TUtils.IsNullOrEmpty(data) then

  begin

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

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  if (not Parallel) then
  begin
    DecodeBlock(data, tempResult, 0, iterationCount);
  end
  else
  begin
    processorCount := Min(iterationCount, TThread.processorCount);
    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin
        beginInd := idx * iterationCount div processorCount;
        endInd := (idx + 1) * iterationCount div processorCount;
        DecodeBlock(data, tempResult, beginInd, endInd);
      end);
  end;

{$ELSE}
  DecodeBlock(data, tempResult, 0, iterationCount);
{$IFEND}
  if (tailCharsCount <> 0) then
  begin

    bits := CharsToBits(data, mainCharsCount, tailCharsCount);
    AddBits64(tempResult, bits, mainBitsLength, tailBitsLength);
  end;
  result := tempResult;

end;

procedure TBaseN.EncodeBlock(src: TBytes; dst: TBaseNcodingCharArray;
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

procedure TBaseN.DecodeBlock(const src: TBaseNcodingString; dst: TBytes;
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

procedure TBaseN.BitsToChars(chars: TBaseNcodingCharArray; ind, count: Integer;
block: UInt64);
var
  i: Integer;
begin

  for i := 0 to Pred(count) do
  begin
    if not ReverseOrder then
    begin
      chars[ind + i] := (Alphabet[(Integer(block mod CharsCount)) + 1]);
    end
    else
    begin
      chars[ind + (count - 1 - i)] :=
        (Alphabet[(Integer(block mod CharsCount)) + 1]);
    end;
    block := block div CharsCount;
  end;

end;

function TBaseN.CharsToBits(const data: TBaseNcodingString;
ind, count: Integer): UInt64;

var
  i: Integer;
begin
  result := UInt64(0);
  for i := 0 to Pred(count) do
  begin
    if not ReverseOrder then
    begin

      result := result + UInt64(FInvAlphabet[Ord(data[(ind + i) + 1])] *
        F_powN[BlockCharsCount - 1 - i]);
    end
    else
    begin

      result := result +
        UInt64(FInvAlphabet[Ord(data[(ind + (count - 1 - i)) + 1])] *
        F_powN[BlockCharsCount - 1 - i]);
    end;
  end;

end;

function TBaseN.GetBits64(data: TBytes; bitPos, bitsCount: Integer): UInt64;
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

procedure TBaseN.AddBits64(data: TBytes; value: UInt64;
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
