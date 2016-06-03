unit uBase64;

{$ZEROBASEDSTRINGS ON}
{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$ENDIF}

interface

uses

  System.SysUtils,
{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  System.Classes,
  System.Threading,
  System.Math,
{$ENDIF}
  uBase,
  uUtils;

type

  IBase64 = interface
    ['{E57BB251-9048-4287-9782-F22B12602B12}']

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

  TBase64 = class(TBase, IBase64)

  public

    const

    DefaultAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    DefaultSpecial = '=';

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial;
      _textEncoding: TEncoding = Nil{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
      ; _parallel: Boolean = False
{$ENDIF});

    function GetHaveSpecial: Boolean; override;
    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  strict private

    procedure EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
      beginInd, endInd: Integer);
    procedure DecodeBlock(const src: String; dst: TArray<Byte>;
      beginInd, endInd: Integer);

  end;

implementation

constructor TBase64.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial;
  _textEncoding: TEncoding = Nil{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
  ; _parallel: Boolean = False
{$ENDIF});

begin

  Inherited Create(64, _Alphabet, _Special,
    _textEncoding{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)},
    _parallel{$ENDIF});

end;

function TBase64.GetHaveSpecial: Boolean;
begin
  result := True;
end;

function TBase64.Encode(data: TArray<Byte>): String;
var
  resultLength, dataLength, tempInt, length3, ind, x1, x2, srcInd,
    dstInd{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}, processorCount,
    beginInd, endInd
{$ENDIF}: Integer;
  tempResult: TArray<Char>;

begin
  if ((data = Nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);
  resultLength := (dataLength + 2) div 3 * 4;
  SetLength(tempResult, resultLength);
  length3 := Length(data) div 3;

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
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
        tempResult[dstInd] := Alphabet[x1 shr 2];
        tempResult[dstInd + 1] := Alphabet[(x1 shl 4) and $30];
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
        tempResult[dstInd] := Alphabet[x1 shr 2];
        tempResult[dstInd + 1] := Alphabet[((x1 shl 4) and $30) or (x2 shr 4)];
        tempResult[dstInd + 2] := Alphabet[(x2 shl 2) and $3C];
        tempResult[dstInd + 3] := Special;

      end;
  end;
  result := TUtils.ArraytoString(tempResult);

end;

procedure TBase64.EncodeBlock(src: TArray<Byte>; dst: TArray<Char>;
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

    dst[dstInd] := Alphabet[x1 shr 2];
    dst[dstInd + 1] := Alphabet[((x1 shl 4) and $30) or (x2 shr 4)];
    dst[dstInd + 2] := Alphabet[((x2 shl 2) and $3C) or (x3 shr 6)];
    dst[dstInd + 3] := Alphabet[x3 and $3F];
  end;
end;

function TBase64.Decode(const data: String): TArray<Byte>;
var
  lastSpecialInd, tailLength, resultLength, length4, ind, x1, x2, x3, srcInd,
    dstInd{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}, processorCount,
    beginInd, endInd
{$ENDIF}: Integer;
  tempResult: TArray<Byte>;

begin
  if TUtils.isNullOrEmpty(data) then

  begin
    SetLength(result, 1);
    result := Nil;
    Exit;
  end;
  lastSpecialInd := Length(data);

  while (data[lastSpecialInd - 1] = Special) do
  begin
    dec(lastSpecialInd);
  end;
  tailLength := Length(data) - lastSpecialInd;
  resultLength := (Length(data) + 3) div 4 * 3 - tailLength;
  SetLength(tempResult, resultLength);
  length4 := (Length(data) - tailLength) div 4;

{$IF DEFINED (SUPPORT_PARALLEL_PROGRAMMING)}
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
        x1 := FInvAlphabet[Ord(data[srcInd])];
        x2 := FInvAlphabet[Ord(data[srcInd + 1])];
        tempResult[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
      end;
    1:
      begin
        ind := length4;
        srcInd := ind * 4;
        dstInd := ind * 3;
        x1 := FInvAlphabet[Ord(data[srcInd])];
        x2 := FInvAlphabet[Ord(data[srcInd + 1])];
        x3 := FInvAlphabet[Ord(data[srcInd + 2])];
        tempResult[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
        tempResult[dstInd + 1] := Byte((x2 shl 4) or ((x3 shr 2) and $F));
      end;
  end;
  result := tempResult;

end;

{$OVERFLOWCHECKS OFF}

procedure TBase64.DecodeBlock(const src: String; dst: TArray<Byte>;
beginInd, endInd: Integer);
var
  ind, srcInd, dstInd, x1, x2, x3, x4: Integer;

begin

  for ind := beginInd to Pred(endInd) do

  begin
    srcInd := ind * 4;
    dstInd := ind * 3;

    x1 := FInvAlphabet[Ord(src[srcInd])];
    x2 := FInvAlphabet[Ord(src[srcInd + 1])];
    x3 := FInvAlphabet[Ord(src[srcInd + 2])];
    x4 := FInvAlphabet[Ord(src[srcInd + 3])];

    dst[dstInd] := Byte((x1 shl 2) or ((x2 shr 4) and $3));
    dst[dstInd + 1] := Byte((x2 shl 4) or ((x3 shr 2) and $F));
    dst[dstInd + 2] := Byte((x3 shl 6) or (x4 and $3F));

  end;
end;

end.
