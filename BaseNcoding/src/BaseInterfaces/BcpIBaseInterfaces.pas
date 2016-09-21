unit BcpIBaseInterfaces;

{$I ..\Include\BaseNcoding.inc}

interface

uses
{$IFDEF SCOPEDUNITNAMES}
  System.SysUtils
{$ELSE}
    SysUtils
{$ENDIF}
    , BcpBaseNcodingTypes;

type

  IBase = interface(IInterface)
    ['{105A4B0A-69E8-41D1-9954-5D1CED996326}']

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
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase32 = interface(IInterface)
    ['{194EDF16-63BB-47AB-BF6A-F0E72B450F30}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase64 = interface(IInterface)
    ['{E57BB251-9048-4287-9782-F22B12602B12}']

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
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase85 = interface(IInterface)
    ['{A230687D-2037-482C-B207-E543683B5ED4}']

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
    function GetPrefixPostfix: Boolean;
    procedure SetPrefixPostfix(value: Boolean);
    property PrefixPostfix: Boolean read GetPrefixPostfix
      write SetPrefixPostfix;
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase91 = interface(IInterface)
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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase128 = interface(IInterface)
    ['{15410119-518E-4E56-A9AC-0093564B517F}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase256 = interface(IInterface)
    ['{66F55DDE-FC44-4BDC-93C7-94956212B66B}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase1024 = interface(IInterface)
    ['{4131E6DD-DAB7-4752-84D9-88B52E03CEF1}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBase4096 = interface(IInterface)
    ['{00E62467-D513-474C-8350-76A820B99A1B}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IZBase32 = interface(IInterface)
    ['{96264326-C333-4642-A9C6-BDEA183E6597}']

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
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBaseN = interface(IInterface)
    ['{5D0520CF-2A5A-4B3F-9263-7C2F1F822E8B}']

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
    function GetBlockMaxBitsCount: UInt32;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount;
    function GetReverseOrder: Boolean;
    property ReverseOrder: Boolean read GetReverseOrder;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

  IBaseBigN = interface(IInterface)
    ['{CEA46191-74D3-4354-AC89-A312E0758035}']

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
    function GetBlockMaxBitsCount: UInt32;
    property BlockMaxBitsCount: UInt32 read GetBlockMaxBitsCount;
    function GetReverseOrder: Boolean;
    property ReverseOrder: Boolean read GetReverseOrder;
    function GetMaxCompression: Boolean;
    property MaxCompression: Boolean read GetMaxCompression;
{$IFDEF SUPPORT_PARALLEL_PROGRAMMING}
    function GetParallel: Boolean;
    procedure SetParallel(value: Boolean);
    property Parallel: Boolean read GetParallel write SetParallel;
{$ENDIF}
    function GetName: TBaseNcodingString;
    property Name: TBaseNcodingString read GetName;

  end;

implementation

end.
