unit BcpBaseNcodingTypes;

interface

type
  /// <summary>
  /// alias for "string" type depending on the compiler.
  /// </summary>
  TBaseNcodingString = {$IFDEF FPC} UnicodeString {$ELSE} String {$ENDIF};
  /// <summary>
  /// alias for "char" type depending on the compiler.
  /// </summary>
  TBaseNcodingChar = {$IFDEF FPC} UnicodeChar {$ELSE} Char {$ENDIF};
  /// <summary>
  /// Represents a dynamic array of Integer.
  /// </summary>
  TBaseNcodingIntegerArray = array of Integer;
  /// <summary>
  /// Represents a dynamic array of UInt32.
  /// </summary>
  TBaseNcodingUInt32Array = array of UInt32;
  /// <summary>
  /// Represents a dynamic array of UInt64.
  /// </summary>
  TBaseNcodingUInt64Array = array of UInt64;
  /// <summary>
  /// Represents a dynamic array of Char.
  /// </summary>
  TBaseNcodingCharArray = array of TBaseNcodingChar;
  /// <summary>
  /// alias for "pchar" (pointer to a char) type depending on the compiler.
  /// </summary>
  PBaseNcodingChar = {$IFDEF FPC} PUnicodeChar {$ELSE} PChar {$ENDIF};

implementation

end.
