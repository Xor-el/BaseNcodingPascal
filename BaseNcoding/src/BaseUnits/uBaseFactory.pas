unit uBaseFactory;

{$I ..\Include\BaseNcoding.inc}

interface

uses

{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils
{$ELSE}
    SysUtils
{$ENDIF}
    , uBase32,
  uBase64,
  uBase85,
  uBase91,
  uBase128,
  uBase256,
  uBase1024,
  uBase4096,
  uZBase32,
  uBaseN,
  uBaseBigN,
  uIBaseInterfaces,
  uBaseNcodingTypes;

type
  TBaseFactory = class sealed(TObject)

  public

    class function CreateBase32(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase32.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase32;

    class function CreateBase64(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase64.DefaultSpecial;
      _textEncoding: TEncoding = Nil
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}; _parallel: Boolean = False
{$ENDIF}): IBase64;

    class function CreateBase85(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase85.DefaultSpecial;
      _prefixPostfix: Boolean = False; _textEncoding: TEncoding = Nil): IBase85;

    class function CreateBase91(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase91.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase91;

    class function CreateBase128(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase128.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase128;

    class function CreateBase256(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase256.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase256;

    class function CreateBase1024(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase1024.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase1024;

    class function CreateBase4096(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TBase4096.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IBase4096;

    class function CreateZBase32(_Alphabet: TBaseNcodingString = '';
      _Special: TBaseNcodingChar = TZBase32.DefaultSpecial;
      _textEncoding: TEncoding = Nil): IZBase32;

    class function CreateBaseN(const _Alphabet: TBaseNcodingString;
      _blockMaxBitsCount: UInt32 = 32; _Encoding: TEncoding = Nil;
      _reverseOrder: Boolean = False{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
      ; _parallel: Boolean = False
{$ENDIF}): IBaseN;

    class function CreateBaseBigN(const _Alphabet: TBaseNcodingString;
      _blockMaxBitsCount: UInt32 = 64; _Encoding: TEncoding = Nil;
      _reverseOrder: Boolean = False;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
      _parallel: Boolean = False; {$ENDIF}
      _maxCompression: Boolean = False): IBaseBigN;

  end;

implementation

{ TBaseFactory }

class function TBaseFactory.CreateBase32(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase32.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase32;
begin
  result := TBase32.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBase64(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase64.DefaultSpecial;
  _textEncoding: TEncoding = Nil{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  ; _parallel: Boolean = False {$ENDIF}): IBase64;
begin
  result := TBase64.Create(_Alphabet, _Special,
    _textEncoding{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}, _parallel{$ENDIF});
end;

class function TBaseFactory.CreateBase85(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase85.DefaultSpecial;
  _prefixPostfix: Boolean = False; _textEncoding: TEncoding = Nil): IBase85;
begin
  result := TBase85.Create(_Alphabet, _Special, _prefixPostfix, _textEncoding);
end;

class function TBaseFactory.CreateBase91(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase91.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase91;
begin
  result := TBase91.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBase128(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase128.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase128;
begin
  result := TBase128.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBase256(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase256.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase256;
begin
  result := TBase256.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBase1024(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase1024.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase1024;
begin
  result := TBase1024.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBase4096(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TBase4096.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IBase4096;
begin
  result := TBase4096.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateZBase32(_Alphabet: TBaseNcodingString = '';
  _Special: TBaseNcodingChar = TZBase32.DefaultSpecial;
  _textEncoding: TEncoding = Nil): IZBase32;
begin
  result := TZBase32.Create(_Alphabet, _Special, _textEncoding);
end;

class function TBaseFactory.CreateBaseN(const _Alphabet: TBaseNcodingString;
  _blockMaxBitsCount: UInt32 = 32; _Encoding: TEncoding = Nil;
  _reverseOrder: Boolean = False{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  ; _parallel: Boolean = False{$ENDIF}): IBaseN;
begin
  result := TBaseN.Create(_Alphabet, _blockMaxBitsCount, _Encoding,
    _reverseOrder{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    , _parallel{$ENDIF});
end;

class function TBaseFactory.CreateBaseBigN(const _Alphabet: TBaseNcodingString;
  _blockMaxBitsCount: UInt32 = 64; _Encoding: TEncoding = Nil;
  _reverseOrder: Boolean = False;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
  _parallel: Boolean = False; {$ENDIF}
  _maxCompression: Boolean = False): IBaseBigN;
begin
  result := TBaseBigN.Create(_Alphabet, _blockMaxBitsCount, _Encoding,
    _reverseOrder{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    , _parallel{$ENDIF}, _maxCompression);
end;

end.
