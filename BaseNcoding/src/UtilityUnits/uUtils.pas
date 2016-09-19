unit uUtils;

{$I ..\Include\BaseNcoding.inc}

interface

uses

  uBaseNcodingTypes,
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils,
  System.Math;
{$ELSE}
SysUtils,
  Math;
{$ENDIF}

resourcestring

  SMaxValueError = 'Maximum value not found';

type

  TUtils = class sealed(TObject)

  public

    class function CustomMatchStr(InChar: TBaseNcodingChar;
      const InString: TBaseNcodingString): Boolean; static;
    class function IsNullOrEmpty(const InValue: TBaseNcodingString): Boolean;
      static; inline;
    class function StartsWith(const InStringOne, InStringTwo
      : TBaseNcodingString): Boolean; static; inline;
    class function EndsWith(const InStringOne, InStringTwo: TBaseNcodingString)
      : Boolean; static; inline;
    class function RetreiveMax(const InString: TBaseNcodingString)
      : Integer; static;
    class function ArraytoString(const InArray: TBaseNcodingCharArray)
      : TBaseNcodingString; static; inline;
    class function LogBase2(x: UInt32): Integer; static;
    class function LogBaseN(x, n: UInt32): Integer; static;

    /// <summary>
    /// From: http://stackoverflow.com/a/600306/1046374
    /// </summary>
    /// <param name="x"></param>
    /// <returns></returns>

    class function IsPowerOf2(x: UInt32): Boolean; static;

    /// <summary>
    /// From: http://stackoverflow.com/a/13569863/1046374
    /// </summary>

    class function LCM(a, b: Integer): Integer; static;

    class function GetOptimalBitsCount(CharsCount: UInt32;
      out charsCountInBits: UInt32; maxBitsCount: UInt32 = 64;
      radix: UInt32 = 2): Integer; static;

    class function GetOptimalBitsCount2(CharsCount: UInt32;
      out charsCountInBits: UInt32; maxBitsCount: UInt32 = 64;
      base2BitsCount: Boolean = False): Integer; static;

  end;

implementation

class function TUtils.CustomMatchStr(InChar: TBaseNcodingChar;
  const InString: TBaseNcodingString): Boolean;
var
  i: Integer;

begin
  result := False;
  for i := 1 to Length(InString) do

  begin
    if InString[i] = InChar then
    begin
      result := True;
      Exit;
    end;
  end;

end;

class function TUtils.IsNullOrEmpty(const InValue: TBaseNcodingString): Boolean;

const
  Empty = '';

begin
  result := InValue = Empty;
end;

class function TUtils.StartsWith(const InStringOne,
  InStringTwo: TBaseNcodingString): Boolean;
var
  tempStr: TBaseNcodingString;
begin

  tempStr := Copy(InStringOne, 1, 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.EndsWith(const InStringOne,
  InStringTwo: TBaseNcodingString): Boolean;
var
  tempStr: TBaseNcodingString;
begin

  tempStr := Copy(InStringOne, Length(InStringOne) - 1, 2);

  result := AnsiSameText(tempStr, InStringTwo);

end;

class function TUtils.RetreiveMax(const InString: TBaseNcodingString): Integer;
var
  i, MaxOrdinal, TempValue: Integer;
begin
  MaxOrdinal := -1;
  for i := 1 to Length(InString) do
  begin
    TempValue := Ord(InString[i]);
    MaxOrdinal := Max(MaxOrdinal, TempValue);
  end;
  if MaxOrdinal = -1 then
  begin
    raise Exception.CreateRes(@SMaxValueError);
  end
  else
    result := MaxOrdinal;
end;

class function TUtils.ArraytoString(const InArray: TBaseNcodingCharArray)
  : TBaseNcodingString;

begin

  SetString(result, PBaseNcodingChar(@InArray[0]), Length(InArray));

end;

class function TUtils.LogBase2(x: UInt32): Integer;
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

class function TUtils.LogBaseN(x, n: UInt32): Integer;
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

class function TUtils.IsPowerOf2(x: UInt32): Boolean;
var
  xint: UInt32;
begin
  xint := UInt32(x);

  if (x - xint <> 0) then

    result := False
  else

    result := (xint and (xint - 1)) = 0;
end;

class function TUtils.LCM(a, b: Integer): Integer;
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

class function TUtils.GetOptimalBitsCount(CharsCount: UInt32;
  out charsCountInBits: UInt32; maxBitsCount: UInt32 = 64;
  radix: UInt32 = 2): Integer;
var
  maxRatio, ratio, charsCountLog, temp, dCharsCount, dradix, multemp: Double;
  n, n1: Integer;
  l1: UInt32;

begin
  result := 0;
  charsCountInBits := 0;
  n1 := TUtils.LogBaseN(CharsCount, radix);
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

class function TUtils.GetOptimalBitsCount2(CharsCount: UInt32;
  out charsCountInBits: UInt32; maxBitsCount: UInt32 = 64;
  base2BitsCount: Boolean = False): Integer;

var
  n, n1: Integer;
  charsCountLog, ratio, maxRatio, temp, multemp, dCharsCount, d2: Double;
  l1: UInt32;
begin
  result := 0;
  charsCountInBits := 0;
  n1 := TUtils.LogBase2(CharsCount);
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
