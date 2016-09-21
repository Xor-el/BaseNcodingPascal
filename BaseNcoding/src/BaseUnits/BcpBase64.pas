unit BcpBase64;

{$I ..\Include\BaseNcoding.inc}

interface

uses

{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils
{$ELSE}
    SysUtils
{$ENDIF}
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    , System.Classes,
  System.Threading,
  System.Math
{$ENDIF}
    , BcpBase,
  BcpIBaseInterfaces,
  BcpBaseNcodingTypes,
  BcpUtils;

type

  TBase64 = class sealed(TBase, IBase64)

  strict private

    procedure EncodeBlock(src: TBytes; dst: TBaseNcodingCharArray;
      beginInd, endInd: Integer);
    procedure DecodeBlock(const src: TBaseNcodingString; dst: TBytes;
      beginInd, endInd: Integer);

  public

    const

    DefaultAlphabet: array [0 .. 63] of TBaseNcodingChar = ('A', 'B', 'C', 'D',
      'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
      'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
      'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
      'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      '+', '/');

    DefaultSpecial = TBaseNcodingChar('=');

    constructor Create(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = DefaultSpecial;
      _textEncoding: TEncoding = Nil
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}; _parallel: Boolean = False
{$ENDIF});

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TBytes): TBaseNcodingString; override;
    function Decode(const data: TBaseNcodingString): TBytes; override;

  end;

implementation

constructor TBase64.Create(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = DefaultSpecial;
  _textEncoding: TEncoding = Nil{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  ; _parallel: Boolean = False {$ENDIF});

begin
  if _Alphabet = '' then
  begin
    SetString(_Alphabet, PBaseNcodingChar(@DefaultAlphabet[0]),
      Length(DefaultAlphabet));
  end;
  Inherited Create(64, _Alphabet, _Special,
    _textEncoding{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, _parallel{$ENDIF});
end;

function TBase64.GetHaveSpecial: Boolean;
begin
  result := True;
end;

function TBase64.Encode(data: TBytes): TBaseNcodingString;
var
  resultLength, dataLength, tempInt, length3, ind, x1, x2, srcInd,
    dstInd{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, processorCount, beginInd,
    endInd {$ENDIF}: Integer;
  tempResult: TBaseNcodingCharArray;

begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    result := ('');
    Exit;
  end;

  dataLength := Length(data);
  resultLength := (dataLength + 2) div 3 * 4;
  SetLength(tempResult, resultLength);
  length3 := Length(data) div 3;

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  if (not Parallel) then
  begin
    EncodeBlock(data, tempResult, 0, length3)
  end
  else
  begin
    processorCount := Min(length3, TThread.processorCount);
    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin
        beginInd := idx * length3 div processorCount;
        endInd := (idx + 1) * length3 div processorCount;
        EncodeBlock(data, tempResult, beginInd, endInd);
      end);
  end;

{$ELSE}
  EncodeBlock(data, tempResult, 0, length3);
{$ENDIF}
  tempInt := (dataLength - length3 * 3);

  case tempInt of
    1:
      begin
        ind := length3;
        srcInd := ind * 3;
        dstInd := ind * 4;
        x1 := data[srcInd];
        tempResult[dstInd] := Alphabet[(x1 shr 2) + 1];
        tempResult[dstInd + 1] := Alphabet[((x1 shl 4) and $30) + 1];
        tempResult[dstInd + 2] := Special;
        tempResult[dstInd + 3] := Special;

      end;
    2:
      begin
        ind := length3;
        srcInd := ind * 3;
        dstInd := ind * 4;
        x1 := data[srcInd];
        x2 := data[srcInd + 1];
        tempResult[dstInd] := Alphabet[(x1 shr 2) + 1];
        tempResult[dstInd + 1] :=
          Alphabet[(((x1 shl 4) and $30) or (x2 shr 4)) + 1];
        tempResult[dstInd + 2] := Alphabet[((x2 shl 2) and $3C) + 1];
        tempResult[dstInd + 3] := Special;

      end;
  end;
  result := TUtils.ArraytoString(tempResult);

end;

procedure TBase64.EncodeBlock(src: TBytes; dst: TBaseNcodingCharArray;
beginInd, endInd: Integer);
var
  ind, srcInd, dstInd: Integer;
  x1, x2, x3: Byte;

begin
  for ind := beginInd to Pred(endInd) do
  begin
    srcInd := ind * 3;
    dstInd := ind * 4;
    x1 := src[srcInd];
    x2 := src[srcInd + 1];
    x3 := src[srcInd + 2];

    dst[dstInd] := Alphabet[(x1 shr 2) + 1];
    dst[dstInd + 1] := Alphabet[(((x1 shl 4) and $30) or (x2 shr 4)) + 1];
    dst[dstInd + 2] := Alphabet[(((x2 shl 2) and $3C) or (x3 shr 6)) + 1];
    dst[dstInd + 3] := Alphabet[(x3 and $3F) + 1];
  end;
end;

function TBase64.Decode(const data: TBaseNcodingString): TBytes;
var
  lastSpecialInd, tailLength, resultLength, length4, ind, x1, x2, x3, srcInd,
    dstInd{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, processorCount, beginInd,
    endInd {$ENDIF}: Integer;
  tempResult: TBytes;

begin
  if TUtils.IsNullOrEmpty(data) then

  begin

    result := Nil;
    Exit;
  end;
  lastSpecialInd := Length(data);

  while (data[(lastSpecialInd)] = Special) do
  begin
    dec(lastSpecialInd);
  end;
  tailLength := Length(data) - lastSpecialInd;
  resultLength := (Length(data) + 3) div 4 * 3 - tailLength;
  SetLength(tempResult, resultLength);
  length4 := (Length(data) - tailLength) div 4;

{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  if (not Parallel) then
  begin
    DecodeBlock(data, tempResult, 0, length4);
  end
  else
  begin
    processorCount := Min(length4, TThread.processorCount);
    TParallel.&For(0, processorCount - 1,
      procedure(idx: Integer)
      begin
        beginInd := idx * length4 div processorCount;
        endInd := (idx + 1) * length4 div processorCount;
        DecodeBlock(data, tempResult, beginInd, endInd);
      end);
  end;

{$ELSE}
  DecodeBlock(data, tempResult, 0, length4);
{$ENDIF}
  Case tailLength of
    2:
      begin
        ind := length4;
        srcInd := ind * 4;
        dstInd := ind * 3;
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        x2 := FInvAlphabet[Ord(data[(srcInd + 1) + 1])];
        tempResult[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
      end;
    1:
      begin
        ind := length4;
        srcInd := ind * 4;
        dstInd := ind * 3;
        x1 := FInvAlphabet[Ord(data[(srcInd) + 1])];
        x2 := FInvAlphabet[Ord(data[(srcInd + 1) + 1])];
        x3 := FInvAlphabet[Ord(data[(srcInd + 2) + 1])];
        tempResult[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
        tempResult[dstInd + 1] := Byte((x2 shl 4) or ((x3 shr 2) and $F));
      end;
  end;
  result := tempResult;

end;

{$OVERFLOWCHECKS OFF}

procedure TBase64.DecodeBlock(const src: TBaseNcodingString; dst: TBytes;
beginInd, endInd: Integer);
var
  ind, srcInd, dstInd, x1, x2, x3, x4: Integer;

begin

  for ind := beginInd to Pred(endInd) do

  begin
    srcInd := ind * 4;
    dstInd := ind * 3;

    x1 := FInvAlphabet[Ord(src[(srcInd) + 1])];
    x2 := FInvAlphabet[Ord(src[(srcInd + 1) + 1])];
    x3 := FInvAlphabet[Ord(src[(srcInd + 2) + 1])];
    x4 := FInvAlphabet[Ord(src[(srcInd + 3) + 1])];

    dst[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
    dst[dstInd + 1] := Byte((x2 shl 4) or ((x3 shr 2) and $F));
    dst[dstInd + 2] := Byte((x3 shl 6) or (x4 and $3F));

  end;
end;

end.
