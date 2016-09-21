unit BcpIntegerX;

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
{$IFDEF FPC}
    , fgl
{$ELSE}
{$IFDEF SCOPEDUNITNAMES}
    , System.Generics.Collections
{$ELSE}
    , Generics.Collections
{$ENDIF}
{$ENDIF};

type

  /// <summary>
  /// alias for "char" type depending on the compiler.
  /// </summary>
  TIntegerXChar = {$IFDEF FPC} UnicodeChar {$ELSE} Char {$ENDIF};
  /// <summary>
  /// Represents a dynamic array of Char.
  /// </summary>
  TIntegerXCharArray = array of TIntegerXChar;
  /// <summary>
  /// Represents a dynamic array of Integer.
  /// </summary>
  TIntegerXIntegerArray = array of Integer;
  /// <summary>
  /// Represents a dynamic array of UInt32.
  /// </summary>
  TIntegerXUInt32Array = array of UInt32;

  /// <summary>
  /// Extended Precision Integer.
  /// </summary>
  /// <remarks>
  /// <para>Inspired by the Microsoft.Scripting.Math.BigInteger code,
  /// the java.math.BigInteger code, but mostly by Don Knuth's Art of Computer Programming, Volume 2.</para>
  /// <para>The same as most other BigInteger representations, this implementation uses a sign/magnitude representation.</para>
  /// <para>The magnitude is represented by an array of UInt32 in big-endian order.
  /// <para>TIntegerX's are immutable.</para>
  /// </remarks>
  TIntegerX = record

  strict private
    /// <summary>
    /// The sign of the integer.  Must be -1, 0, +1.
    /// </summary>
    _sign: SmallInt;

    /// <summary>
    /// The magnitude of the integer (big-endian).
    /// </summary>
    /// <remarks>
    /// <para>Big-endian = _data[0] is the most significant digit.</para>
    /// <para> Some invariants:</para>
    /// <list>
    /// <item>If the integer is zero, then _data must be length zero array and _sign must be zero.</item>
    /// <item>No leading zero UInt32.</item>
    /// <item>Must be non-null.  For zero, a zero-length array is used.</item>
    /// </list>
    /// These invariants imply a unique representation for every value.
    /// They also force us to get rid of leading zeros after every operation that might create some.
    /// </remarks>
    _data: TIntegerXUInt32Array;

    /// <summary>
    /// Getter function for <see cref="TIntegerX.Precision" />
    /// </summary>
    function GetPrecision: UInt32;

    /// <summary>
    /// Getter function for <see cref="TIntegerX.Zero" />
    /// </summary>
    class function GetZero: TIntegerX; static;
    /// <summary>
    /// Getter function for <see cref="TIntegerX.One" />
    /// </summary>
    class function GetOne: TIntegerX; static;
    /// <summary>
    /// Getter function for <see cref="TIntegerX.Two" />
    /// </summary>
    class function GetTwo: TIntegerX; static;
    /// <summary>
    /// Getter function for <see cref="TIntegerX.Five" />
    /// </summary>
    class function GetFive: TIntegerX; static;
    /// <summary>
    /// Getter function for <see cref="TIntegerX.Ten" />
    /// </summary>
    class function GetTen: TIntegerX; static;
    /// <summary>
    /// Getter function for <see cref="TIntegerX.NegativeOne" />
    /// </summary>
    class function GetNegativeOne: TIntegerX; static;

    /// <summary>
    /// Append a sequence of digits representing <paramref name="rem"/> to the <see cref="StringBuilder"/> or <see cref="String"/>,
    /// possibly adding leading null chars if specified.
    /// </summary>
    /// <param name="sb">The <see cref="StringBuilder"/> or <see cref="String"/> to append characters to</param>
    /// <param name="rem">The 'super digit' value to be converted to its string representation</param>
    /// <param name="radix">The radix for the conversion</param>
    /// <param name="charBuf">A character buffer used for temporary storage, big enough to hold the string
    /// representation of <paramref name="rem"/></param>
    /// <param name="leadingZeros">Whether or not to pad with the leading zeros if the value is not large enough to fill the buffer</param>
    /// <remarks>Pretty much identical to DLR BigInteger.AppendRadix</remarks>
    class procedure AppendDigit(var sb:
{$IFDEF FPC} String{$ELSE} TStringBuilder{$ENDIF}; rem: UInt32; radix: UInt32;
      var charBuf: TIntegerXCharArray; leadingZeros: Boolean); static;
    /// <summary>
    /// Convert an (extended) digit to its value in the given radix.
    /// </summary>
    /// <param name="c">The character to convert</param>
    /// <param name="radix">The radix to interpret the character in</param>
    /// <param name="v">Set to the converted value</param>
    /// <returns><value>true</value> if the conversion is successful; <value>false</value> otherwise</returns>
    class function TryComputeDigitVal(c: Char; radix: Integer; out v: UInt32)
      : Boolean; static;
    /// <summary>
    /// Return an indication of the relative values of two UInt32 arrays treated as unsigned big-endian values.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns><value>-1</value> if the first is less than second; <value>0</value> if equal; <value>+1</value> if greater</returns>
    class function Compare(x: TIntegerXUInt32Array; y: TIntegerXUInt32Array)
      : SmallInt; overload; static;

    /// <summary>
    /// Compute the greatest common divisor of two <see cref="TIntegerX"/> values.
    /// </summary>
    /// <param name="a">The first value</param>
    /// <param name="b">The second value</param>
    /// <returns>The greatest common divisor</returns>
    /// <remarks>Does the standard Euclidean algorithm until the two values are approximately
    /// the same length, then switches to a binary gcd algorithm.</remarks>
    class function HybridGcd(a: TIntegerX; b: TIntegerX): TIntegerX; static;
    /// <summary>
    /// Return the greatest common divisor of two uint values.
    /// </summary>
    /// <param name="a">The first value</param>
    /// <param name="b">The second value</param>
    /// <returns>The greatest common divisor</returns>
    /// <remarks>Uses Knuth, 4.5.5, Algorithm B, highly optimized for getting rid of powers of 2.
    /// </remarks>
    class function BinaryGcd(a: UInt32; b: UInt32): UInt32; overload; static;
    /// <summary>
    /// Compute the greatest common divisor of two <see cref="TIntegerX"/> values.
    /// </summary>
    /// <param name="a">The first value</param>
    /// <param name="b">The second value</param>
    /// <returns>The greatest common divisor</returns>
    /// <remarks>Intended for use when the two values have approximately the same magnitude.</remarks>
    class function BinaryGcd(a: TIntegerX; b: TIntegerX): TIntegerX;
      overload; static;
    /// <summary>
    /// Returns the number of trailing zero bits in a UInt32 value.
    /// </summary>
    /// <param name="val">The value</param>
    /// <returns>The number of trailing zero bits </returns>
    class function TrailingZerosCount(val: UInt32): Integer; static;

    class function BitLengthForUInt32(x: UInt32): UInt32; static;

    /// <summary>
    /// Counts Leading zero bits.
    /// This algo is in a lot of places.
    /// </summary>
    /// <param name="x">value to count leading zero bits on.</param>
    /// <returns>leading zero bit count.</returns>
    /// <seealso href="http://aggregate.org/MAGIC/#Leading%20Zero%20Count">[Leading Zero Count]</seealso>

    class function LeadingZeroCount(x: UInt32): UInt32; static;
    /// <summary>
    /// This algo is in a lot of places.
    /// </summary>
    /// <param name="x"></param>
    /// <returns></returns>
    /// <seealso href="http://aggregate.org/MAGIC/#Population%20Count%20(Ones%20Count)">[Ones Count]</seealso>

    class function BitCount(x: UInt32): UInt32; overload; static;

    /// <summary>
    /// Returns the index of the lowest set bit in this instance's magnitude.
    /// </summary>
    /// <returns>The index of the lowest set bit</returns>
    function GetLowestSetBit(): Integer;

    /// <summary>
    /// Returns the specified uint-digit pretending the number
    /// is a little-endian two's complement representation.
    /// </summary>
    /// <param name="n">The index of the digit to retrieve</param>
    /// <returns>The uint at the given index.</returns>
    /// <remarks>If iterating through the data array, better to use
    /// the incremental version that keeps track of whether or not
    /// the first nonzero has been seen.</remarks>
    function Get2CDigit(n: Integer): UInt32; overload;
    /// <summary>
    /// Returns the specified uint-digit pretending the number
    /// is a little-endian two's complement representation.
    /// </summary>
    /// <param name="n">The index of the digit to retrieve</param>
    /// <param name="seenNonZero">Set to true if a nonZero byte is seen</param>
    /// <returns>The UInt32 at the given index.</returns>
    function Get2CDigit(n: Integer; var seenNonZero: Boolean): UInt32; overload;
    /// <summary>
    /// Returns an UInt32 of all zeros or all ones depending on the sign (pos, neg).
    /// </summary>
    /// <returns>The UInt32 corresponding to the sign</returns>
    function Get2CSignExtensionDigit(): UInt32;
    /// <summary>
    /// Returns the index of the first nonzero digit (there must be one), pretending the value is little-endian.
    /// </summary>
    /// <returns></returns>
    function FirstNonzero2CDigitIndex(): Integer;
    /// <summary>
    /// Return the twos-complement of the integer represented by the UInt32 array.
    /// </summary>
    /// <param name="a"></param>
    /// <returns></returns>
    class function MakeTwosComplement(a: TIntegerXUInt32Array)
      : TIntegerXUInt32Array; static;
    /// <summary>
    /// Add two UInt32 arrays (big-endian).
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class function Add(x: TIntegerXUInt32Array; y: TIntegerXUInt32Array)
      : TIntegerXUInt32Array; overload; static;
    /// <summary>
    /// Add one digit.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="newDigit"></param>
    /// <returns></returns>
    class function AddSignificantDigit(x: TIntegerXUInt32Array;
      newDigit: UInt32): TIntegerXUInt32Array; overload; static;
    /// <summary>
    /// Subtract one instance from another (larger first).
    /// </summary>
    /// <param name="xs"></param>
    /// <param name="ys"></param>
    /// <returns></returns>
    class function Subtract(xs: TIntegerXUInt32Array; ys: TIntegerXUInt32Array)
      : TIntegerXUInt32Array; overload; static;
    /// <summary>
    /// Multiply two big-endian UInt32 arrays.
    /// </summary>
    /// <param name="xs"></param>
    /// <param name="ys"></param>
    /// <returns></returns>
    class function Multiply(xs: TIntegerXUInt32Array; ys: TIntegerXUInt32Array)
      : TIntegerXUInt32Array; overload; static;
    /// <summary>
    /// Return the quotient and remainder of dividing one <see cref="TIntegerX"/> by another.
    /// </summary>
    /// <param name="x">The dividend</param>
    /// <param name="y">The divisor</param>
    /// <param name="q">Set to the quotient</param>
    /// <param name="r">Set to the remainder</param>
    /// <remarks>Algorithm D in Knuth 4.3.1.</remarks>
    class procedure DivMod(x: TIntegerXUInt32Array; y: TIntegerXUInt32Array;
      out q: TIntegerXUInt32Array; out r: TIntegerXUInt32Array);
      overload; static;

    /// <summary>
    ///
    /// </summary>
    /// <param name="xnorm"></param>
    /// <param name="r"></param>
    /// <param name="shift"></param>
    class procedure Unnormalize(xnorm: TIntegerXUInt32Array;
      out r: TIntegerXUInt32Array; shift: Integer); static;

    /// <summary>
    /// Do a multiplication and addition in place.
    /// </summary>
    /// <param name="data">The subject of the operation, receives the result</param>
    /// <param name="mult">The value to multiply by</param>
    /// <param name="addend">The value to add in</param>

    class procedure InPlaceMulAdd(var data: TIntegerXUInt32Array; mult: UInt32;
      addend: UInt32); static;
    /// <summary>
    /// Return a (possibly new) UInt32 array with leading zero uints removed.
    /// </summary>
    /// <param name="data">The UInt32 array to prune</param>
    /// <returns>A (possibly new) UInt32 array with leading zero UInt32's removed.</returns>
    class function RemoveLeadingZeros(data: TIntegerXUInt32Array)
      : TIntegerXUInt32Array; static;

    class function StripLeadingZeroBytes(a: TBytes)
      : TIntegerXUInt32Array; static;
    class function makePositive(a: TBytes): TIntegerXUInt32Array; static;

    /// <summary>
    /// Do a division in place and return the remainder.
    /// </summary>
    /// <param name="data">The value to divide into, and where the result appears</param>
    /// <param name="index">Starting index in <paramref name="data"/> for the operation</param>
    /// <param name="divisor">The value to dif</param>
    /// <returns>The remainder</returns>
    /// <remarks>Pretty much identical to DLR BigInteger.div, except DLR's is little-endian
    /// and this is big-endian.</remarks>
    class function InPlaceDivRem(var data: TIntegerXUInt32Array;
      var index: Integer; divisor: UInt32): UInt32; static;
    /// <summary>
    /// Divide a big-endian UInt32 array by a UInt32 divisor, returning the quotient and remainder.
    /// </summary>
    /// <param name="data">A big-endian UInt32 array</param>
    /// <param name="divisor">The value to divide by</param>
    /// <param name="quotient">Set to the quotient (newly allocated)</param>
    /// <returns>The remainder</returns>
    class function CopyDivRem(data: TIntegerXUInt32Array; divisor: UInt32;
      out quotient: TIntegerXUInt32Array): UInt32; static;

    function signInt(): Integer;

    function getInt(n: Integer): Integer;

    function firstNonzeroIntNum(): Integer;

  const
    /// <summary>
    /// The number of bits in one 'digit' of the magnitude.
    /// </summary>
    BitsPerDigit = 32; // UInt32 implementation
    /// <summary>
    /// Exponent bias in the 64-bit floating point representation.
    /// </summary>
    DoubleExponentBias = 1023;

    /// <summary>
    /// The size in bits of the significand in the 64-bit floating point representation.
    /// </summary>
    DoubleSignificandBitLength = 52;

    /// <summary>
    /// How much to shift to accommodate the exponent and the binary digits of the significand.
    /// </summary>
    DoubleShiftBias = DoubleExponentBias + DoubleSignificandBitLength;

    /// <summary>
    /// The minimum radix allowed in parsing.
    /// </summary>
    MinRadix = 2;

    /// <summary>
    /// The maximum radix allowed in parsing.
    /// </summary>
    MaxRadix = 36;

    /// <summary>
    /// Max UInt32 value.
    /// </summary>
    MaxUInt32Value = 4294967295;

    /// <summary>
    /// Min SmallInt value.
    /// </summary>
    MinSmallIntValue = -32768;

    /// <summary>
    /// Max SmallInt value.
    /// </summary>
    MaxSmallIntValue = 32767;

    /// <summary>
    /// Min ShortInt value.
    /// </summary>
    MinShortIntValue = -128;

    /// <summary>
    /// Max ShortInt value.
    /// </summary>
    MaxShortIntValue = 127;

    /// <summary>
    /// Max Word value.
    /// </summary>
    MaxWordValue = 65535;

  class var

    /// <summary>
    /// FUIntLogTable.
    /// </summary>
    FUIntLogTable: TIntegerXUInt32Array;

    /// <summary>
    /// The maximum number of digits in radix[i] that will fit into a UInt32.
    /// </summary>
    /// <remarks>
    /// <para>FRadixDigitsPerDigit[i] = floor(log_i (2^32 - 1))</para>
    /// </remarks>
    FRadixDigitsPerDigit: TIntegerXIntegerArray;

    /// <summary>
    /// The super radix (power of given radix) that fits into a UInt32.
    /// </summary>
    /// <remarks>
    /// <para>FSuperRadix[i] = 2 ^ FRadixDigitsPerDigit[i]</para>
    /// </remarks>
    FSuperRadix: TIntegerXUInt32Array;

    /// <summary>
    /// The number of bits in one digit of radix[i] times 1024.
    /// </summary>
    /// <remarks>
    /// <para>FBitsPerRadixDigit[i] = ceiling(1024*log_2(i))</para>
    /// <para>The value is multiplied by 1024 to avoid fractions.  Users will need to divide by 1024.</para>
    /// </remarks>
    FBitsPerRadixDigit: TIntegerXIntegerArray;

    /// <summary>
    /// The value at index i is the number of trailing zero bits in the value i.
    /// </summary>
    FTrailingZerosTable: TBytes;

  strict private

    class constructor CreateIntegerXState();

  public
    /// <summary>
    /// Support for TDecimalX, to compute precision.
    /// </summary>
    property Precision: UInt32 read GetPrecision;
    /// <summary>
    /// A Zero.
    /// </summary>
    class property Zero: TIntegerX read GetZero;
    /// <summary>
    /// A Positive One.
    /// </summary>
    class property One: TIntegerX read GetOne;
    /// <summary>
    /// A Two.
    /// </summary>
    class property Two: TIntegerX read GetTwo;
    /// <summary>
    /// A Five.
    /// </summary>
    class property Five: TIntegerX read GetFive;
    /// <summary>
    /// A Ten.
    /// </summary>
    class property Ten: TIntegerX read GetTen;
    /// <summary>
    /// A Negative One.
    /// </summary>
    class property NegativeOne: TIntegerX read GetNegativeOne;

    /// <summary>
    /// Create a <see cref="TIntegerX"/> from an unsigned Int64 value.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: UInt64): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from an unsigned integer value.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: UInt32): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from an (signed) Int64 value.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: Int64): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from an (signed) Integer value.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: Integer): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from a double value.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: Double): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from a string.
    /// </summary>
    /// <param name="v">The value</param>
    /// <returns>A <see cref="TIntegerX"/>.</returns>
    class function Create(v: String): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from a string representation (radix 10).
    /// </summary>
    /// <param name="x">The string to convert</param>
    /// <returns>A <see cref="TIntegerX"/></returns>
    /// <exception cref="EFormatException">Thrown if there is a bad minus sign (more than one or not leading)
    /// or if one of the digits in the string is not valid for the given radix.</exception>
    class function Parse(x: String): TIntegerX; overload; static;
    /// <summary>
    /// Create a <see cref="TIntegerX"/> from a string representation in the given radix.
    /// </summary>
    /// <param name="s">The string to convert</param>
    /// <param name="radix">The radix of the numeric representation</param>
    /// <returns>A <see cref="TIntegerX"/></returns>
    /// <exception cref="EFormatException">Thrown if there is a bad minus sign (more than one or not leading)
    /// or if one of the digits in the string is not valid for the given radix.</exception>
    class function Parse(s: String; radix: Integer): TIntegerX;
      overload; static;
    /// <summary>
    /// Try to create a <see cref="TIntegerX"/> from a string representation (radix 10)
    /// </summary>
    /// <param name="s">The string to convert</param>
    /// <param name="v">Set to the  <see cref="TIntegerX"/> corresponding to the string, if possible; set to null otherwise</param>
    /// <returns><c>True</c> if the string is parsed successfully; <c>false</c> otherwise</returns>
    class function TryParse(s: String; out v: TIntegerX): Boolean;
      overload; static;
    /// <summary>
    /// Try to create a <see cref="TIntegerX"/> from a string representation in the given radix)
    /// </summary>
    /// <param name="s">The string to convert</param>
    /// <param name="radix">The radix of the numeric representation</param>
    /// <param name="v">Set to the <see cref="TIntegerX"/> corresponding to the string, if possible; set to null otherwise</param>
    /// <returns><c>True</c> if the string is parsed successfully; <c>false</c> otherwise</returns>
    /// <remarks>
    /// <para>This is pretty much the same algorithm as in the Java implementation.
    /// That's pretty much what is in Knuth ACPv2ed3, Sec. 4.4, Method 1b.
    /// That's pretty much what you'd do by hand.</para>
    /// <para>The only enhancement is that instead of doing one digit at a time, you translate a group of contiguous
    /// digits into a UInt32, then do a multiply by the radix and add of the UInt32.
    /// The size of each group of digits is the maximum number of digits in the radix
    /// that will fit into a UInt32.</para>
    /// <para>Once you've decided to make that enhancement to Knuth's algorithm, you pretty much
    /// end up with the Java version's code.</para>
    /// </remarks>
    class function TryParse(s: String; radix: Integer; out v: TIntegerX)
      : Boolean; overload; static;
    /// <summary>
    /// Convert a substring in a given radix to its equivalent numeric value as a UInt32.
    /// </summary>
    /// <param name="val">The string containing the substring to convert</param>
    /// <param name="startIndex">The start index of the substring</param>
    /// <param name="len">The length of the substring</param>
    /// <param name="radix">The radix</param>
    /// <param name="u">Set to the converted value, or 0 if the conversion is unsuccessful</param>
    /// <returns><value>true</value> if successful, <value>false</value> otherwise</returns>
    /// <remarks>The length of the substring must be small enough that the converted value is guaranteed to fit
    /// into a UInt32.</remarks>
    class function TryParseUInt(val: String; startIndex: Integer; len: Integer;
      radix: Integer; out u: UInt32): Boolean; static;
    /// <summary>
    /// Extract the sign bit from a byte-array representaition of a double.
    /// </summary>
    /// <param name="v">A byte-array representation of a double</param>
    /// <returns>The sign bit, either 0 (positive) or 1 (negative)</returns>
    class function GetDoubleSign(v: TBytes): Integer; static;
    /// <summary>
    /// Extract the significand (AKA mantissa, coefficient) from a byte-array representation of a double.
    /// </summary>
    /// <param name="v">A byte-array representation of a double</param>
    /// <returns>The significand</returns>
    class function GetDoubleSignificand(v: TBytes): UInt64; static;

    /// <summary>
    /// Extract the exponent from a byte-array representation of a double.
    /// </summary>
    /// <param name="v">A byte-array representation of a double</param>
    /// <returns>The exponent</returns>
    class function GetDoubleBiasedExponent(v: TBytes): Word; static;
    /// <summary>
    /// Algorithm from Hacker's Delight, section 11-4. for internal use only
    /// </summary>
    /// <param name="v">value to use.</param>
    /// <returns>The Precision</returns>
    class function UIntPrecision(v: UInt32): UInt32; static;
    /// <summary>
    ///
    /// </summary>
    /// <param name="xnorm"></param>
    /// <param name="xnlen"></param>
    /// <param name="x"></param>
    /// <param name="xlen"></param>
    /// <param name="shift"></param>
    /// <remarks>
    /// <para>Assume Length(xnorm) := xlen + 1 or xlen;</para>
    /// <para>Assume shift in [0,31]</para>
    /// <para>This should be private, but I wanted to test it.</para>
    /// </remarks>
    class procedure Normalize(var xnorm: TIntegerXUInt32Array; xnlen: Integer;
      x: TIntegerXUInt32Array; xlen: Integer; shift: Integer); static;
    /// <summary>
    /// Implicitly convert from Byte to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: Byte): TIntegerX;

    /// <summary>
    /// Implicitly convert from ShortInt to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: ShortInt): TIntegerX;
    /// <summary>
    /// Implicitly convert from SmallInt to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: SmallInt): TIntegerX;
    /// <summary>
    /// Implicitly convert from Word to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: Word): TIntegerX;
    /// <summary>
    /// Implicitly convert from UInt32 to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: UInt32): TIntegerX;
    /// <summary>
    /// Implicitly convert from Integer to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: Integer): TIntegerX;
    /// <summary>
    /// Implicitly convert from UInt64 to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: UInt64): TIntegerX;
    /// <summary>
    /// Implicitly convert from Int64 to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Implicit(v: Int64): TIntegerX;
    /// <summary>
    /// Explicitly convert from double to <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="v">The value to convert</param>
    /// <returns>The equivalent <see cref="TIntegerX"/></returns>
    class operator Explicit(self: Double): TIntegerX;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to Double.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent double</returns>
    class operator Explicit(i: TIntegerX): Double;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to Byte.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent byte</returns>
    class operator Explicit(self: TIntegerX): Byte;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to ShortInt.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent ShortInt</returns>
    class operator Explicit(self: TIntegerX): ShortInt;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to Word.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent Word</returns>
    class operator Explicit(self: TIntegerX): Word;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to SmallInt.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent SmallInt</returns>
    class operator Explicit(self: TIntegerX): SmallInt;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to UInt32.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent UInt32</returns>
    class operator Explicit(self: TIntegerX): UInt32;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to Integer.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent Integer</returns>
    class operator Explicit(self: TIntegerX): Integer;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to Int64.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent Int64</returns>
    class operator Explicit(self: TIntegerX): Int64;
    /// <summary>
    /// Explicitly convert from <see cref="TIntegerX"/> to UInt64.
    /// </summary>
    /// <param name="i">The <see cref="TIntegerX"/> to convert</param>
    /// <returns>The equivalent UInt64</returns>
    class operator Explicit(self: TIntegerX): UInt64;
    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for equivalent numeric values.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if equivalent; <value>false</value> otherwise</returns>
    class operator Equal(x: TIntegerX; y: TIntegerX): Boolean;

    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for non-equivalent numeric values.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if not equivalent; <value>false</value> otherwise</returns>
    class operator NotEqual(x: TIntegerX; y: TIntegerX): Boolean;

    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for &lt;.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if &lt;; <value>false</value> otherwise</returns>
    class operator LessThan(x: TIntegerX; y: TIntegerX): Boolean;
    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for &lt;=.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if &lt;=; <value>false</value> otherwise</returns>
    class operator LessThanOrEqual(x: TIntegerX; y: TIntegerX): Boolean;
    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for &gt;.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if &gt;; <value>false</value> otherwise</returns>
    class operator GreaterThan(x: TIntegerX; y: TIntegerX): Boolean;
    /// <summary>
    /// Compare two <see cref="TIntegerX"/>'s for &gt;=.
    /// </summary>
    /// <param name="x">First value to compare</param>
    /// <param name="y">Second value to compare</param>
    /// <returns><value>true</value> if &gt;=; <value>false</value> otherwise</returns>
    class operator GreaterThanOrEqual(x: TIntegerX; y: TIntegerX): Boolean;
    /// <summary>
    /// Compute <paramref name="x"/> + <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The sum</returns>
    class operator Add(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute <paramref name="x"/> - <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The difference</returns>
    class operator Subtract(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute the plus of <paramref name="x"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <returns>The positive</returns>
    class operator Positive(x: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute the negation of <paramref name="x"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <returns>The negation</returns>
    class operator Negative(x: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute <paramref name="x"/> * <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The product</returns>
    class operator Multiply(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute <paramref name="x"/> div <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The quotient</returns>
    class operator IntDivide(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Compute <paramref name="x"/> mod <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The modulus</returns>
    class operator modulus(x: TIntegerX; y: TIntegerX): TIntegerX;
    /// <summary>
    /// Compute <paramref name="x"/> + <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The sum</returns>
    class function Add(x: TIntegerX; y: TIntegerX): TIntegerX; overload; static;

    /// <summary>
    /// Compute <paramref name="x"/> - <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The difference</returns>
    class function Subtract(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Compute the negation of <paramref name="x"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The negation</returns>
    class function Negate(x: TIntegerX): TIntegerX; overload; static;

    /// <summary>
    /// Compute <paramref name="x"/> * <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The product</returns>
    class function Multiply(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Compute <paramref name="x"/> div <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The quotient</returns>
    class function Divide(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns <paramref name="x"/> mod <paramref name="y"/>.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The modulus</returns>
    class function Modulo(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Compute the quotient and remainder of dividing one <see cref="TIntegerX"/> by another.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <param name="remainder">Set to the remainder after division</param>
    /// <returns>The quotient</returns>
    class function DivRem(x: TIntegerX; y: TIntegerX; out remainder: TIntegerX)
      : TIntegerX; overload; static;

    /// <summary>
    /// Compute the absolute value.
    /// </summary>
    /// <param name="x"></param>
    /// <returns>The absolute value</returns>
    class function Abs(x: TIntegerX): TIntegerX; overload; static;

    /// <summary>
    /// Returns a <see cref="TIntegerX"/> raised to an int power.
    /// </summary>
    /// <param name="x">The value to exponentiate</param>
    /// <param name="exp">The exponent</param>
    /// <returns>The exponent</returns>
    class function Power(x: TIntegerX; exp: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns a <see cref="TIntegerX"/> raised to an <see cref="TIntegerX"/> power modulo another <see cref="TIntegerX"/>
    /// </summary>
    /// <param name="x"></param>
    /// <param name="power"></param>
    /// <param name="modulo"></param>
    /// <returns> x ^ e mod m</returns>
    class function ModPow(x: TIntegerX; Power: TIntegerX; Modulo: TIntegerX)
      : TIntegerX; overload; static;

    /// <summary>
    /// Returns the greatest common divisor.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns>The greatest common divisor</returns>
    class function Gcd(x: TIntegerX; y: TIntegerX): TIntegerX; overload; static;

    /// <summary>
    /// Returns the bitwise-AND.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class operator BitwiseAnd(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Returns the bitwise-OR.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class operator BitwiseOr(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Returns the bitwise-complement.
    /// </summary>
    /// <param name="x"></param>
    /// <remarks>
    /// ** In Delphi, You cannot overload the bitwise not operator, as
    /// BitwiseNot is not supported by the compiler, You have to overload the logical 'not' operator instead.
    /// </remarks>
    /// <returns></returns>
    class operator LogicalNot(x: TIntegerX): TIntegerX;

    /// <summary>
    /// Returns the bitwise-XOR.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class operator BitwiseXor(x: TIntegerX; y: TIntegerX): TIntegerX;

    /// <summary>
    /// Returns the left-shift of a <see cref="TIntegerX"/> by an integer shift.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="shift"></param>
    /// <returns></returns>
    class operator LeftShift(x: TIntegerX; shift: Integer): TIntegerX;

    /// <summary>
    /// Returns the right-shift of a <see cref="TIntegerX"/> by an integer shift.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="shift"></param>
    /// <returns></returns>
    class operator RightShift(x: TIntegerX; shift: Integer): TIntegerX;

    /// <summary>
    /// Returns the bitwise-AND.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class function BitwiseAnd(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns the bitwise-OR.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class function BitwiseOr(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns the bitwise-XOR.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class function BitwiseXor(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns the bitwise complement.
    /// </summary>
    /// <param name="x"></param>
    /// <returns></returns>
    class function BitwiseNot(x: TIntegerX): TIntegerX; overload; static;

    /// <summary>
    /// Returns the bitwise x and (not y).
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    class function BitwiseAndNot(x: TIntegerX; y: TIntegerX): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns  x shl shift.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="shift"></param>
    /// <returns></returns>
    class function LeftShift(x: TIntegerX; shift: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Returns x shr shift.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="shift"></param>
    /// <returns></returns>
    class function RightShift(x: TIntegerX; shift: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Test if a specified bit is set.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="n"></param>
    /// <returns></returns>
    class function TestBit(x: TIntegerX; n: Integer): Boolean; overload; static;

    /// <summary>
    /// Set the specified bit.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="n"></param>
    /// <returns></returns>
    class function SetBit(x: TIntegerX; n: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Set the specified bit to its negation.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="n"></param>
    /// <returns></returns>
    class function FlipBit(x: TIntegerX; n: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Clear the specified bit.
    /// </summary>
    /// <param name="x"></param>
    /// <param name="n"></param>
    /// <returns></returns>
    class function ClearBit(x: TIntegerX; n: Integer): TIntegerX;
      overload; static;

    /// <summary>
    /// Calculates Arithmetic shift right.
    /// </summary>
    /// <param name="value">Integer value to compute 'Asr' on.</param>
    /// <param name="ShiftBits"> number of bits to shift value to.</param>
    /// <returns>Shifted value.</returns>
    /// <seealso href="http://stackoverflow.com/questions/21940986/">[Delphi ASR Implementation for Integer]</seealso>
    class function Asr(value: Integer; ShiftBits: Integer): Integer; overload;
      static; inline;

    /// <summary>
    /// Calculates Arithmetic shift right.
    /// </summary>
    /// <param name="value">Int64 value to compute 'Asr' on.</param>
    /// <param name="ShiftBits"> number of bits to shift value to.</param>
    /// <returns>Shifted value.</returns>
    /// <seealso href="http://github.com/Spelt/ZXing.Delphi/blob/master/Lib/Classes/Common/MathUtils.pas">[Delphi ASR Implementation for Int64]</seealso>

    class function Asr(value: Int64; ShiftBits: Integer): Int64; overload;
      static; inline;

    /// <summary>
    /// Returns Self + y.
    /// </summary>
    /// <param name="y">The augend.</param>
    /// <returns>The sum</returns>
    function Add(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns Self - y
    /// </summary>
    /// <param name="y">The subtrahend</param>
    /// <returns>The difference</returns>
    function Subtract(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns the negation of this value.
    /// </summary>
    /// <returns>The negation</returns>
    function Negate(): TIntegerX; overload;
    /// <summary>
    /// Returns Self * y
    /// </summary>
    /// <param name="y">The multiplicand</param>
    /// <returns>The product</returns>
    function Multiply(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns Self div y.
    /// </summary>
    /// <param name="y">The divisor</param>
    /// <returns>The quotient</returns>
    function Divide(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns Self mod y
    /// </summary>
    /// <param name="y">The divisor</param>
    /// <returns>The modulus</returns>
    function Modulo(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns the quotient and remainder of this divided by another.
    /// </summary>
    /// <param name="y">The divisor</param>
    /// <param name="remainder">The remainder</param>
    /// <returns>The quotient</returns>
    function DivRem(y: TIntegerX; out remainder: TIntegerX): TIntegerX;
      overload;
    /// <summary>
    /// Returns the absolute value of this instance.
    /// </summary>
    /// <returns>The absolute value</returns>
    function Abs(): TIntegerX; overload;
    /// <summary>
    /// Returns the value of this instance raised to an integral power.
    /// </summary>
    /// <param name="exp">The exponent</param>
    /// <returns>The exponetiated value</returns>
    /// <exception cref="EArgumentOutOfRangeException">Thrown if the exponent is negative.</exception>
    function Power(exp: Integer): TIntegerX; overload;
    /// <summary>
    /// Returns (Self ^ power) mod modulus
    /// </summary>
    /// <param name="power">The exponent</param>
    /// <param name="modulus"></param>
    /// <returns></returns>
    function ModPow(Power: TIntegerX; modulus: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns the greatest common divisor of this and another value.
    /// </summary>
    /// <param name="y">The other value</param>
    /// <returns>The greatest common divisor</returns>
    function Gcd(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Return the bitwise-AND of this instance and another <see cref="TIntegerX"/>
    /// </summary>
    /// <param name="y">The value to AND to this instance.</param>
    /// <returns>The bitwise-AND</returns>
    function BitwiseAnd(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Return the bitwise-OR of this instance and another <see cref="TIntegerX"/>
    /// </summary>
    /// <param name="y">The value to OR to this instance.</param>
    /// <returns>The bitwise-OR</returns>
    function BitwiseOr(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Return the bitwise-XOR of this instance and another <see cref="TIntegerX"/>
    /// </summary>
    /// <param name="y">The value to XOR to this instance.</param>
    /// <returns>The bitwise-XOR</returns>
    function BitwiseXor(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns the bitwise complement of this instance.
    /// </summary>
    /// <returns>The bitwise complement</returns>
    function OnesComplement(): TIntegerX; overload;
    /// <summary>
    /// Return the bitwise-AND-NOT of this instance and another <see cref="TIntegerX"/>
    /// </summary>
    /// <param name="y">The value to OR to this instance.</param>
    /// <returns>The bitwise-AND-NOT</returns>
    function BitwiseAndNot(y: TIntegerX): TIntegerX; overload;
    /// <summary>
    /// Returns the value of the given bit in this instance.
    /// </summary>
    /// <param name="n">Index of the bit to check</param>
    /// <returns><value>true</value> if the bit is set; <value>false</value> otherwise</returns>
    /// <exception cref="EArithmeticException">Thrown if the index is negative.</exception>
    /// <remarks>The value is treated as if in twos-complement.</remarks>
    function TestBit(n: Integer): Boolean; overload;
    /// <summary>
    /// Set the n-th bit.
    /// </summary>
    /// <param name="n">Index of the bit to set</param>
    /// <returns>An instance with the bit set</returns>
    /// <exception cref="EArithmeticException">Thrown if the index is negative.</exception>
    /// <remarks>The value is treated as if in twos-complement.</remarks>
    function SetBit(n: Integer): TIntegerX; overload;
    /// <summary>
    /// Clears the n-th bit.
    /// </summary>
    /// <param name="n">Index of the bit to clear</param>
    /// <returns>An instance with the bit cleared</returns>
    /// <exception cref="EArithmeticException">Thrown if the index is negative.</exception>
    /// <remarks>The value is treated as if in twos-complement.</remarks>
    function ClearBit(n: Integer): TIntegerX; overload;
    /// <summary>
    /// Toggles the n-th bit.
    /// </summary>
    /// <param name="n">Index of the bit to toggle</param>
    /// <returns>An instance with the bit toggled</returns>
    /// <exception cref="EArithmeticException">Thrown if the index is negative.</exception>
    /// <remarks>The value is treated as if in twos-complement.</remarks>
    function FlipBit(n: Integer): TIntegerX; overload;
    /// <summary>
    /// Returns the value of this instance left-shifted by the given number of bits.
    /// </summary>
    /// <param name="shift">The number of bits to shift.</param>
    /// <returns>An instance with the magnitude shifted.</returns>
    /// <remarks><para>The value is treated as if in twos-complement.</para>
    /// <para>A negative shift count will be treated as a positive right shift.</para></remarks>
    function LeftShift(shift: Integer): TIntegerX; overload;
    /// <summary>
    /// Returns the value of this instance right-shifted by the given number of bits.
    /// </summary>
    /// <param name="shift">The number of bits to shift.</param>
    /// <returns>An instance with the magnitude shifted.</returns>
    /// <remarks><para>The value is treated as if in twos-complement.</para>
    /// <para>A negative shift count will be treated as a positive left shift.</para></remarks>
    function RightShift(shift: Integer): TIntegerX; overload;
    /// <summary>
    /// Try to convert to an Integer.
    /// </summary>
    /// <param name="ret">Set to the converted value</param>
    /// <returns><value>true</value> if successful; <value>false</value> if the value cannot be represented.</returns>
    function AsInt32(out ret: Integer): Boolean;

    /// <summary>
    /// Try to convert to an Int64.
    /// </summary>
    /// <param name="ret">Set to the converted value</param>
    /// <returns><value>true</value> if successful; <value>false</value> if the value cannot be represented.</returns>
    function AsInt64(out ret: Int64): Boolean;

    /// <summary>
    /// Try to convert to an UInt32.
    /// </summary>
    /// <param name="ret">Set to the converted value</param>
    /// <returns><value>true</value> if successful; <value>false</value> if the value cannot be represented.</returns>
    function AsUInt32(out ret: UInt32): Boolean;

    /// <summary>
    /// Try to convert to an UInt64.
    /// </summary>
    /// <param name="ret">Set to the converted value</param>
    /// <returns><value>true</value> if successful; <value>false</value> if the value cannot be represented.</returns>
    function AsUInt64(out ret: UInt64): Boolean;
    /// <summary>
    /// Converts the value of this instance to an equivalent byte value
    /// </summary>
    /// <returns>The converted value</returns>
    /// <exception cref="EOverflowException">Thrown if the value cannot be represented in a byte.</exception>
    function ToByte(): Byte;
    /// <summary>
    /// Converts the value of this instance to an equivalent SmallInt value
    /// </summary>
    /// <returns>The converted value</returns>
    /// <exception cref="EOverflowException">Thrown if the value cannot be represented in a SmallInt.</exception>
    function ToSmallInt(): SmallInt;
    /// <summary>
    /// Converts the value of this instance to an equivalent ShortInt value
    /// </summary>
    /// <returns>The converted value</returns>
    /// <exception cref="EOverflowException">Thrown if the value cannot be represented in a ShortInt.</exception>
    function ToShortInt(): ShortInt;
    /// <summary>
    /// Converts the value of this instance to an equivalent Word value
    /// </summary>
    /// <returns>The converted value</returns>
    /// <exception cref="EOverflowException">Thrown if the value cannot be represented in a Word.</exception>
    function ToWord(): Word;
    /// <summary>
    /// Convert to an equivalent UInt32
    /// </summary>
    /// <returns>The equivalent value</returns>
    /// <exception cref="EOverflowException">Thrown if the magnitude is too large for the conversion</exception>
    function ToUInt32(): UInt32;

    /// <summary>
    /// Convert to an equivalent Integer
    /// </summary>
    /// <returns>The equivalent value</returns>
    /// <exception cref="EOverflowException">Thrown if the magnitude is too large for the conversion</exception>
    function ToInteger(): Integer;

    /// <summary>
    /// Convert to an equivalent UInt64
    /// </summary>
    /// <returns>The equivalent value</returns>
    /// <exception cref="EOverflowException">Thrown if the magnitude is too large for the conversion</exception>
    function ToUInt64(): UInt64;

    /// <summary>
    /// Convert to an equivalent Int64
    /// </summary>
    /// <returns>The equivalent value</returns>
    /// <exception cref="EOverflowException">Thrown if the magnitude is too large for the conversion</exception>
    function ToInt64(): Int64;

    /// <summary>
    /// Convert to an equivalent Double
    /// </summary>
    /// <returns>The equivalent value</returns>
    /// <exception cref="EOverflowException">Thrown if the magnitude is too large for the conversion</exception>
    function ToDouble: Double;
    /// <summary>
    /// Compares this instance to another specified instance and returns an indication of their relative values.
    /// </summary>
    /// <param name="other"></param>
    /// <returns></returns>
    function CompareTo(other: TIntegerX): Integer;
    /// <summary>
    /// Indicates whether this instance is equivalent to another object of the same type.
    /// </summary>
    /// <param name="other">The object to compare this instance against</param>
    /// <returns><value>true</value> if equivalent; <value>false</value> otherwise</returns>
    function Equals(other: TIntegerX): Boolean;
    /// <summary>
    /// Returns an indication of the relative values of the two <see cref="TIntegerX"/>'s
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns><value>-1</value> if the first is less than second; <value>0</value> if equal; <value>+1</value> if greater</returns>
    class function Compare(x: TIntegerX; y: TIntegerX): Integer;
      overload; static;

    /// <summary>
    /// Converts the numeric value of this <see cref="TIntegerX"/> to its string representation in radix 10.
    /// </summary>
    /// <returns>The string representation in radix 10</returns>
    function ToString(): String; overload;
    /// <summary>
    /// Converts the numeric value of this <see cref="TIntegerX"/> to its string representation in the given radix.
    /// </summary>
    /// <param name="radix">The radix for the conversion</param>
    /// <returns>The string representation in the given radix</returns>
    /// <exception cref="EArgumentOutOfRangeException">Thrown if the radix is out of range [2,36].</exception>
    /// <remarks>
    /// <para>Compute a set of 'super digits' in a 'super radix' that is computed based on the <paramref name="radix"/>;
    /// specifically, it is based on how many digits in the given radix can fit into a UInt32 when converted.  Each 'super digit'
    /// is then translated into a string of digits in the given radix and appended to the result string.
    /// </para>
    /// <para>The Java and the DLR code are very similar.</para>
    /// </remarks>
    function ToString(radix: UInt32): String; overload;
    /// <summary>
    /// Returns true if this instance is positive.
    /// </summary>
    function IsPositive: Boolean;
    /// <summary>
    /// Returns true if this instance is negative.
    /// </summary>
    function IsNegative: Boolean;
    /// <summary>
    /// Returns the sign (-1, 0, +1) of this instance.
    /// </summary>
    function Signum: Integer;
    /// <summary>
    /// Returns true if this instance has value 0.
    /// </summary>
    function IsZero: Boolean;
    /// <summary>
    /// Return true if this instance has an odd value.
    /// </summary>
    function IsOdd: Boolean;
    /// <summary>
    /// Return the magnitude as a big-endian array of UInt32's.
    /// </summary>
    /// <returns>The magnitude</returns>
    /// <remarks>The returned array can be manipulated as you like = unshared.</remarks>
    function GetMagnitude(): TIntegerXUInt32Array;

    function BitLength(): UInt32;

    function BitCount(): UInt32; overload;

    function ToByteArray(): TBytes;

    /// <summary>
    /// Creates a copy of a <see cref="TIntegerX"/>.
    /// </summary>
    /// <param name="copy">The <see cref="TIntegerX"/> to copy.</param>
    constructor Create(copy: TIntegerX); overload;

    constructor Create(val: TBytes); overload;
    /// <summary>
    /// Creates a <see cref="TIntegerX"/> from sign/magnitude data.
    /// </summary>
    /// <param name="sign">The sign (-1, 0, +1)</param>
    /// <param name="data">The magnitude (big-endian)</param>
    /// <exception cref="EArgumentException">Thrown when the sign is not one of -1, 0, +1,
    /// or if a zero sign is given on a non-empty magnitude.</exception>
    /// <remarks>
    /// <para>Leading zero (UInt32) digits will be removed.</para>
    /// <para>The sign will be set to zero if a zero-length array is passed.</para>
    /// </remarks>
    constructor Create(Sign: Integer; data: TIntegerXUInt32Array); overload;

    class var
    /// <summary>
    /// <see cref="TFormatSettings" /> used in <see cref="TIntegerX" />.
    /// </summary>
      _FS: TFormatSettings;

  end;

  EArithmeticException = EMathError;
  EOverflowException = EOverflow;
  EInvalidOperationException = EInvalidOp;
  EDivByZeroException = EDivByZero;
  EFormatException = class(Exception);

var

  /// <summary>
  /// Temporary Variable to Hold <c>Zero </c><see cref="TIntegerX" />.
  /// </summary>
  ZeroX: TIntegerX;
  /// <summary>
  /// Temporary Variable to Hold <c>One </c><see cref="TIntegerX" />.
  /// </summary>
  OneX: TIntegerX;
  /// <summary>
  /// Temporary Variable to Hold <c>Two </c><see cref="TIntegerX" />.
  /// </summary>
  TwoX: TIntegerX;
  /// <summary>
  /// Temporary Variable to Hold <c>Five </c><see cref="TIntegerX" />.
  /// </summary>
  FiveX: TIntegerX;
  /// <summary>
  /// Temporary Variable to Hold <c>Ten </c><see cref="TIntegerX" />.
  /// </summary>
  TenX: TIntegerX;
  /// <summary>
  /// Temporary Variable to Hold <c>NegativeOne </c><see cref="TIntegerX" />.
  /// </summary>
  NegativeOneX: TIntegerX;

resourcestring
  NaNOrInfinite = 'Infinity/NaN not supported in TIntegerX (yet)';
  InvalidSign = 'Sign must be -1, 0, or +1';
  InvalidSign2 = 'Zero sign on non-zero data';
  InvalidFormat = 'Invalid input format';
  OverFlowUInt32 = 'TIntegerX magnitude too large for UInt32';
  OverFlowInteger = 'TIntegerX magnitude too large for Integer';
  OverFlowUInt64 = 'TIntegerX magnitude too large for UInt64';
  OverFlowInt64 = 'TIntegerX magnitude too large for Int64';
  OverFlowByte = 'TIntegerX value won''t fit in byte';
  OverFlowSmallInt = 'TIntegerX value won''t fit in a SmallInt';
  OverFlowShortInt = 'TIntegerX value won''t fit in a ShortInt';
  OverFlowWord = 'TIntegerX value won''t fit in a Word';
  BogusCompareResult = 'Bogus result from Compare';
  ExponentNegative = 'Exponent must be non-negative';
  PowerNegative = 'power must be non-negative';
  NegativeAddress = 'Negative bit address';
  CarryOffLeft = 'Carry off left end.';
  ValueOverFlow = 'Value can''t fit in specified type';
  ZeroLengthValue = 'Zero length BigInteger';

implementation

class constructor TIntegerX.CreateIntegerXState();
begin
  // Create a Zero TIntegerX (a big integer with value as Zero)
  ZeroX := TIntegerX.Create(0, Nil);
  // Create a One TIntegerX (a big integer with value as One)
  OneX := TIntegerX.Create(1, TIntegerXUInt32Array.Create(1));
  // Create a Two TIntegerX (a big integer with value as Two)
  TwoX := TIntegerX.Create(1, TIntegerXUInt32Array.Create(2));
  // Create a Five TIntegerX (a big integer with value as Five)
  FiveX := TIntegerX.Create(1, TIntegerXUInt32Array.Create(5));
  // Create a Ten TIntegerX (a big integer with value as Ten)
  TenX := TIntegerX.Create(1, TIntegerXUInt32Array.Create(10));
  // Create a NegativeOne TIntegerX (a big integer with value as NegativeOne)
  NegativeOneX := TIntegerX.Create(-1, TIntegerXUInt32Array.Create(1));

{$IFDEF FPC}
  _FS := DefaultFormatSettings;
{$ELSE}
{$IFDEF SUPPORT_TFORMATSETTINGS_CREATE_INSTANCE}
  _FS := TFormatSettings.Create;

{$ELSE}
  GetLocaleFormatSettings(0, _FS);
{$ENDIF}
{$ENDIF}
  FUIntLogTable := TIntegerXUInt32Array.Create(0, 9, 99, 999, 9999, 99999,
    999999, 9999999, 99999999, 999999999, MaxUInt32Value);

  FRadixDigitsPerDigit := TIntegerXIntegerArray.Create(0, 0, 31, 20, 15, 13, 12,
    11, 10, 10, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6,
    6, 6, 6, 6, 6, 6);

  FSuperRadix := TIntegerXUInt32Array.Create(0, 0, $80000000, $CFD41B91,
    $40000000, $48C27395, $81BF1000, $75DB9C97, $40000000, $CFD41B91, $3B9ACA00,
    $8C8B6D2B, $19A10000, $309F1021, $57F6C100, $98C29B81, $10000000, $18754571,
    $247DBC80, $3547667B, $4C4B4000, $6B5A6E1D, $94ACE180, $CAF18367, $B640000,
    $E8D4A51, $1269AE40, $17179149, $1CB91000, $23744899, $2B73A840, $34E63B41,
    $40000000, $4CFA3CC1, $5C13D840, $6D91B519, $81BF1000);

  FBitsPerRadixDigit := TIntegerXIntegerArray.Create(0, 0, 1024, 1624, 2048,
    2378, 2648, 2875, 3072, 3247, 3402, 3543, 3672, 3790, 3899, 4001, 4096,
    4186, 4271, 4350, 4426, 4498, 4567, 4633, 4696, 4756, 4814, 4870, 4923,
    4975, 5025, 5074, 5120, 5166, 5210, 5253, 5295);

  FTrailingZerosTable := TBytes.Create(0, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0,
    1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1,
    0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
    6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3,
    0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0,
    1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 7, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1,
    0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0,
    2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2,
    0, 1, 0, 6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0,
    1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1,
    0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0);

end;

class function TIntegerX.Create(v: UInt64): TIntegerX;
var
  most: UInt32;
begin
  if (v = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end;

  most := UInt32(v shr BitsPerDigit);
  if (most = 0) then
  begin
    result := TIntegerX.Create(1, TIntegerXUInt32Array.Create(UInt32(v)));
    Exit;
  end
  else
    result := TIntegerX.Create(1, TIntegerXUInt32Array.Create(most, UInt32(v)));
end;

class function TIntegerX.Create(v: UInt32): TIntegerX;
begin
  if (v = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end
  else
  begin
    result := TIntegerX.Create(1, TIntegerXUInt32Array.Create(v));
    Exit;
  end;
end;

class function TIntegerX.Create(v: Int64): TIntegerX;
var
  most: UInt32;
  Sign: SmallInt;
begin
  if (v = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end
  else
  begin
    Sign := 1;
    if (v < 0) then
    begin
      Sign := -1;
      v := -v;
    end;
    // No need to use ASR (Arithmetic Shift Right) since sign is checked above and a negative "v" is
    // multiplied by a negative sign making it positive
    most := UInt32(v shr BitsPerDigit);
    if (most = 0) then
    begin
      result := TIntegerX.Create(Sign, TIntegerXUInt32Array.Create(UInt32(v)));
      Exit;
    end
    else
      result := TIntegerX.Create(Sign, TIntegerXUInt32Array.Create(most,
        UInt32(v)));
  end;
end;

class function TIntegerX.Create(v: Integer): TIntegerX;
begin
  result := TIntegerX.Create(Int64(v));
end;

class function TIntegerX.Create(v: Double): TIntegerX;
var
  dbytes: TBytes;
  significand: UInt64;
  exp: Integer;
  tempRes, res: TIntegerX;
begin
  if (IsNaN(v)) or (IsInfinite(v)) then
  begin
    raise EOverflowException.Create(NaNOrInfinite);
  end;
  SetLength(dbytes, SizeOf(v));
  Move(v, dbytes[0], SizeOf(v));

  significand := TIntegerX.GetDoubleSignificand(dbytes);
  exp := TIntegerX.GetDoubleBiasedExponent(dbytes);

  if (significand = 0) then
  begin
    if (exp = 0) then
    begin
      result := TIntegerX.Zero;
      Exit;
    end;
    if v < 0.0 then
      tempRes := TIntegerX.NegativeOne
    else
      tempRes := TIntegerX.One;

    // TODO: Avoid extra allocation
    tempRes := tempRes.LeftShift(exp - DoubleExponentBias);
    result := tempRes;
    Exit;
  end
  else
  begin
    significand := significand or UInt64($10000000000000);
    res := TIntegerX.Create(significand);
    // TODO: Avoid extra allocation
    if exp > 1075 then
      res := res shl (exp - DoubleShiftBias)
    else
      res := res shr (DoubleShiftBias - exp);
    if v < 0.0 then
      result := res * (-1)
    else
      result := res;

  end;
end;

class function TIntegerX.Create(v: String): TIntegerX;
begin
  result := Parse(v);
end;

class function TIntegerX.GetDoubleSign(v: TBytes): Integer;
begin
  result := v[7] and $80;
end;

class function TIntegerX.GetDoubleSignificand(v: TBytes): UInt64;

var
  i1, i2: UInt32;
begin
  i1 := (UInt32(v[0]) or (UInt32(v[1]) shl 8) or (UInt32(v[2]) shl 16) or
    (UInt32(v[3]) shl 24));
  i2 := (UInt32(v[4]) or (UInt32(v[5]) shl 8) or (UInt32(v[6] and $F) shl 16));

  result := UInt64(UInt64(i1) or (UInt64(i2) shl 32));
end;

class function TIntegerX.GetDoubleBiasedExponent(v: TBytes): Word;
begin
  result := Word(((Word(v[7] and $7F)) shl Word(4)) or
    ((Word(v[6] and $F0)) shr 4));
end;

class function TIntegerX.Asr(value: Integer; ShiftBits: Integer): Integer;

begin
  result := value shr ShiftBits;
  if (value and $80000000) > 0 then
    // if you don't want to cast ($FFFFFFFF) to an Integer, simply replace it with (-1) to avoid range check error.
    result := result or (Integer($FFFFFFFF) shl (32 - ShiftBits));
end;

class function TIntegerX.Asr(value: Int64; ShiftBits: Integer): Int64;
begin
  result := value shr ShiftBits;
  if (value and $8000000000000000) > 0 then
    result := result or ($FFFFFFFFFFFFFFFF shl (64 - ShiftBits));
end;

constructor TIntegerX.Create(copy: TIntegerX);
begin
  _sign := copy._sign;
  _data := copy._data;
end;

constructor TIntegerX.Create(val: TBytes);
begin
  if (Length(val) = 0) then
    raise EArgumentException.Create(ZeroLengthValue);

  if (ShortInt(val[0]) < 0) then
  begin
    _data := makePositive(val);
    _sign := -1;

  end
  else
  begin
    _data := StripLeadingZeroBytes(val);
    if Length(_data) = 0 then
      _sign := 0
    else
      _sign := 1;

  end;
end;

constructor TIntegerX.Create(Sign: Integer; data: TIntegerXUInt32Array);
begin
  if ((Sign < -1) or (Sign > 1)) then
    raise EArgumentException.Create(InvalidSign);

  data := RemoveLeadingZeros(data);

  if (Length(data) = 0) then
    Sign := 0
  else if (Sign = 0) then
    raise EArgumentException.Create(InvalidSign2);

  _sign := SmallInt(Sign);
  _data := data;
end;

class function TIntegerX.Parse(x: String): TIntegerX;
begin
  result := Parse(x, 10);
end;

class function TIntegerX.Parse(s: String; radix: Integer): TIntegerX;
var
  v: TIntegerX;
begin

  if (TryParse(s, radix, v)) then
  begin
    result := v;
    Exit;
  end;
  raise EFormatException.Create(InvalidFormat);
end;

class function TIntegerX.TryParse(s: String; out v: TIntegerX): Boolean;
begin
  result := TryParse(s, 10, v);
end;

class function TIntegerX.TryParse(s: String; radix: Integer;
  out v: TIntegerX): Boolean;
var
  Sign: SmallInt;
  len, minusIndex, plusIndex, index, numDigits, numBits, numUints, groupSize,
    firstGroupLen: Integer;
  mult, u: UInt32;
  data: TIntegerXUInt32Array;
begin
  if ((radix < MinRadix) or (radix > MaxRadix)) then
  begin
    v := Default (TIntegerX);
    result := false;
    Exit;
  end;

  Sign := 1;
  len := Length(s);

  // zero length bad,
  // hyphen only bad, plus only bad,
  // hyphen not leading bad, plus not leading bad
  // (overkill) both hyphen and minus present (one would be caught by the tests above)
  minusIndex := LastDelimiter('-', s) - 1;
  plusIndex := LastDelimiter('+', s) - 1;

  if ((len = 0) or ((minusIndex = 0) and (len = 1)) or
    ((plusIndex = 0) and (len = 1)) or (minusIndex > 0) or (plusIndex > 0)) then
  begin
    v := Default (TIntegerX);
    result := false;
    Exit;
  end;
  index := 0;
  if (plusIndex <> -1) then
    index := 1

  else if (minusIndex <> -1) then
  begin
    Sign := -1;
    index := 1;
  end;

  // skip leading zeros
  while ((index < len) and (s[index + 1] = '0')) do
    Inc(index);

  if (index = len) then
  begin
    v := TIntegerX.Create(TIntegerX.Zero);
    result := true;
    Exit;
  end;

  numDigits := len - index;

  // We can compute size of magnitude.  May be too large by one UInt32.
  numBits := TIntegerX.Asr((numDigits * FBitsPerRadixDigit[radix]), 10) + 1;
  numUints := (numBits + BitsPerDigit - 1) div BitsPerDigit;

  SetLength(data, numUints);

  groupSize := FRadixDigitsPerDigit[radix];

  // the first group may be short
  // the first group is the initial value for _data.

  firstGroupLen := numDigits mod groupSize;
  if (firstGroupLen = 0) then
    firstGroupLen := groupSize;
  if (not TryParseUInt(s, index, firstGroupLen, radix, data[Length(data) - 1]))
  then
  begin
    v := Default (TIntegerX);
    result := false;
    Exit;
  end;

  index := index + firstGroupLen;

  mult := FSuperRadix[radix];
  while index < len do
  begin
    if (not TryParseUInt(s, index, groupSize, radix, u)) then
    begin
      v := Default (TIntegerX);
      result := false;
      Exit;
    end;
    InPlaceMulAdd(data, mult, u);
    index := index + groupSize;
  end;

  v := TIntegerX.Create(Sign, RemoveLeadingZeros(data));
  result := true;
end;

function TIntegerX.ToString(): String;
begin
  result := ToString(10);
end;

function TIntegerX.ToString(radix: UInt32): String;
var
  len, index, i: Integer;
  LSuperRadix, rem: UInt32;
  working: TIntegerXUInt32Array;
{$IFDEF FPC}
  rems: TFPGList<UInt32>;
  sb: String;
{$ELSE}
  rems: TList<UInt32>;
  sb: TStringBuilder;
{$ENDIF}
  charBuf: TIntegerXCharArray;
begin
  if ((radix < UInt32(MinRadix)) or (radix > UInt32(MaxRadix))) then
    raise EArgumentOutOfRangeException.Create
      (Format('Radix %u is out of range. MinRadix = %d , MaxRadix = %d',
      [radix, MinRadix, MaxRadix], _FS));

  if (_sign = 0) then
  begin
    result := '0';
    Exit;
  end;

  len := Length(_data);

  working := copy(_data, 0, Length(_data));
  LSuperRadix := FSuperRadix[radix];

  // TODO: figure out max, pre-allocate space (in List)
{$IFDEF FPC}
  rems := TFPGList<UInt32>.Create;
{$ELSE}
  rems := TList<UInt32>.Create;
{$ENDIF};
  try
    index := 0;
    while (index < len) do
    begin
      rem := InPlaceDivRem(working, index, LSuperRadix);
      rems.Add(rem);
    end;
{$IFNDEF FPC}
    sb := TStringBuilder.Create(rems.Count * FRadixDigitsPerDigit[radix] + 1);
{$ELSE}
    sb := '';
{$ENDIF};
    try

      if (_sign < 0) then
{$IFNDEF FPC}
        sb.Append('-');
{$ELSE}
        sb := '-';
{$ENDIF}
      SetLength(charBuf, (FRadixDigitsPerDigit[radix]));

      AppendDigit(sb, rems[rems.Count - 1], radix, charBuf, false);
      i := rems.Count - 2;
      while i >= 0 do
      begin
        AppendDigit(sb, rems[i], radix, charBuf, true);
        Dec(i);
      end;
{$IFNDEF FPC}
      result := sb.ToString();
{$ELSE}
      result := sb;
{$ENDIF}
    finally
{$IFNDEF FPC}
      sb.Free;
{$ENDIF}
    end;
  finally
    rems.Free;
  end;

end;

class procedure TIntegerX.AppendDigit(var sb:
{$IFDEF FPC} String{$ELSE}TStringBuilder{$ENDIF}; rem: UInt32; radix: UInt32;
  var charBuf: TIntegerXCharArray; leadingZeros: Boolean);
const

  symbols = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  bufLen, i: Integer;
  digit: UInt32;
  tempStr: String;
begin
  tempStr := '';
  bufLen := Length(charBuf);
  i := bufLen - 1;
  while ((i >= 0) and (rem <> 0)) do
  begin
    digit := rem mod radix;
    rem := rem div radix;
    charBuf[i] := symbols[Integer(digit) + 1];
    Dec(i);
  end;

  if (leadingZeros) then
  begin
    while i >= 0 do
    begin
      charBuf[i] := '0';
      Dec(i);
    end;
    SetString(tempStr, PChar(@charBuf[0]), Length(charBuf));
{$IFNDEF FPC}
    sb.Append(tempStr);
{$ELSE}
    sb := sb + tempStr;
{$ENDIF}
  end
  else
  begin
    SetString(tempStr, PChar(@charBuf[0]), Length(charBuf));
{$IFNDEF FPC}
    sb.Append(tempStr, i + 1, bufLen - i - 1);
{$ELSE}
    sb := sb + copy(tempStr, i + 2, bufLen - i - 1 + 1);
{$ENDIF}
  end;
end;

class function TIntegerX.TryParseUInt(val: String; startIndex: Integer;
  len: Integer; radix: Integer; out u: UInt32): Boolean;
var
  tempRes: UInt64;
  i: Integer;
  v: UInt32;
begin
  u := 0;
  tempRes := 0;
  i := 0;
  while i < len do
  begin

    if (not TryComputeDigitVal(val[startIndex + i + 1], radix, v)) then
    begin
      result := false;
      Exit;
    end;
    tempRes := tempRes * UInt32(radix) + v;
    if (tempRes > MaxUInt32Value) then
    begin
      result := false;
      Exit;
    end;
    Inc(i);
  end;
  u := UInt32(tempRes);
  result := true;
end;

class function TIntegerX.TryComputeDigitVal(c: Char; radix: Integer;
  out v: UInt32): Boolean;
begin
  v := MaxUInt32Value;

  if ((Ord('0') <= Ord(c)) and (Ord(c) <= Ord('9'))) then
    v := UInt32(Ord(c) - Ord('0'))
  else if ((Ord('a') <= Ord(c)) and (Ord(c) <= Ord('z'))) then
    v := UInt32(10 + Ord(c) - Ord('a'))
  else if ((Ord('A') <= Ord(c)) and (Ord(c) <= Ord('Z'))) then
    v := UInt32(10 + Ord(c) - Ord('A'));

  result := v < UInt32(radix);
end;

class operator TIntegerX.Implicit(v: Byte): TIntegerX;
begin
  result := Create(UInt32(v));
end;

class operator TIntegerX.Implicit(v: ShortInt): TIntegerX;
begin
  result := Create(Integer(v));
end;

class operator TIntegerX.Implicit(v: SmallInt): TIntegerX;
begin
  result := Create(Integer(v));
end;

class operator TIntegerX.Implicit(v: Word): TIntegerX;
begin
  result := Create(UInt32(v));
end;

class operator TIntegerX.Implicit(v: UInt32): TIntegerX;
begin
  result := Create(v);
end;

class operator TIntegerX.Implicit(v: Integer): TIntegerX;
begin
  result := Create(v);
end;

class operator TIntegerX.Implicit(v: UInt64): TIntegerX;
begin
  result := Create(v);
end;

class operator TIntegerX.Implicit(v: Int64): TIntegerX;
begin
  result := Create(v);
end;

class operator TIntegerX.Explicit(self: Double): TIntegerX;
begin
  result := Create(self);
end;

class operator TIntegerX.Explicit(i: TIntegerX): Double;
begin
  result := i.ToDouble();
end;
{$OVERFLOWCHECKS ON}

class operator TIntegerX.Explicit(self: TIntegerX): Byte;
var
  tmp: Integer;
begin

  if (self.AsInt32(tmp)) then
  begin
    result := Byte(tmp);
    Exit;
  end;
  raise EOverflowException.Create(ValueOverFlow);
end;
{$OVERFLOWCHECKS OFF}
{$OVERFLOWCHECKS ON}

class operator TIntegerX.Explicit(self: TIntegerX): ShortInt;
var
  tmp: Integer;
begin

  if (self.AsInt32(tmp)) then
  begin
    result := ShortInt(tmp);
    Exit;
  end;

  raise EOverflowException.Create(ValueOverFlow);
end;
{$OVERFLOWCHECKS OFF}
{$OVERFLOWCHECKS ON}

class operator TIntegerX.Explicit(self: TIntegerX): Word;
var
  tmp: Integer;
begin
  if (self.AsInt32(tmp)) then
  begin
    result := Word(tmp);
    Exit;
  end;

  raise EOverflowException.Create(ValueOverFlow);
end;

{$OVERFLOWCHECKS OFF}
{$OVERFLOWCHECKS ON}

class operator TIntegerX.Explicit(self: TIntegerX): SmallInt;
var
  tmp: Integer;
begin
  if (self.AsInt32(tmp)) then
  begin
    result := SmallInt(tmp);
    Exit;
  end;

  raise EOverflowException.Create(ValueOverFlow);
end;
{$OVERFLOWCHECKS OFF}

class operator TIntegerX.Explicit(self: TIntegerX): UInt32;
var
  tmp: UInt32;
begin
  if (self.AsUInt32(tmp)) then
  begin
    result := tmp;
    Exit;
  end;

  raise EOverflowException.Create(ValueOverFlow);
end;

class operator TIntegerX.Explicit(self: TIntegerX): Integer;
var
  tmp: Integer;
begin
  if (self.AsInt32(tmp)) then
  begin
    result := tmp;
    Exit;
  end;
  raise EOverflowException.Create(ValueOverFlow);
end;

class operator TIntegerX.Explicit(self: TIntegerX): Int64;
var
  tmp: Int64;
begin
  if (self.AsInt64(tmp)) then
  begin
    result := tmp;
    Exit;
  end;
  raise EOverflowException.Create(ValueOverFlow);
end;

class operator TIntegerX.Explicit(self: TIntegerX): UInt64;
var
  tmp: UInt64;
begin
  if (self.AsUInt64(tmp)) then
  begin
    result := tmp;
    Exit;
  end;
  raise EOverflowException.Create(ValueOverFlow);
end;

class operator TIntegerX.Equal(x: TIntegerX; y: TIntegerX): Boolean;
begin
  result := Compare(x, y) = 0;
end;

class operator TIntegerX.NotEqual(x: TIntegerX; y: TIntegerX): Boolean;
begin
  result := Compare(x, y) <> 0;
end;

class operator TIntegerX.LessThan(x: TIntegerX; y: TIntegerX): Boolean;
begin
  result := Compare(x, y) < 0;
end;

class operator TIntegerX.LessThanOrEqual(x: TIntegerX; y: TIntegerX): Boolean;
begin
  result := Compare(x, y) <= 0;
end;

class operator TIntegerX.GreaterThan(x: TIntegerX; y: TIntegerX): Boolean;
begin
  result := Compare(x, y) > 0;
end;

class operator TIntegerX.GreaterThanOrEqual(x: TIntegerX; y: TIntegerX)
  : Boolean;
begin
  result := Compare(x, y) >= 0;
end;

class operator TIntegerX.Add(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Add(y);
end;

class operator TIntegerX.Subtract(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Subtract(y);
end;

class operator TIntegerX.Positive(x: TIntegerX): TIntegerX;
begin
  result := x;
end;

class operator TIntegerX.Negative(x: TIntegerX): TIntegerX;
begin
  result := x.Negate();
end;

class operator TIntegerX.Multiply(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Multiply(y);
end;

class operator TIntegerX.IntDivide(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Divide(y);
end;

class operator TIntegerX.modulus(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Modulo(y);
end;

class function TIntegerX.Add(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Add(y);
end;

class function TIntegerX.Subtract(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Subtract(y);
end;

class function TIntegerX.Negate(x: TIntegerX): TIntegerX;
begin
  result := x.Negate();
end;

class function TIntegerX.Multiply(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Multiply(y);
end;

class function TIntegerX.Divide(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Divide(y);
end;

class function TIntegerX.Modulo(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Modulo(y);
end;

class function TIntegerX.DivRem(x: TIntegerX; y: TIntegerX;
  out remainder: TIntegerX): TIntegerX;
begin
  result := x.DivRem(y, remainder);
end;

class function TIntegerX.Abs(x: TIntegerX): TIntegerX;
begin
  result := x.Abs();
end;

class function TIntegerX.Power(x: TIntegerX; exp: Integer): TIntegerX;
begin
  result := x.Power(exp);
end;

class function TIntegerX.ModPow(x: TIntegerX; Power: TIntegerX;
  Modulo: TIntegerX): TIntegerX;
begin
  result := x.ModPow(Power, Modulo);
end;

class function TIntegerX.Gcd(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.Gcd(y);
end;

class operator TIntegerX.BitwiseAnd(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseAnd(y);
end;

class operator TIntegerX.BitwiseOr(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseOr(y);
end;

class operator TIntegerX.LogicalNot(x: TIntegerX): TIntegerX;
begin
  result := x.OnesComplement();
end;

class operator TIntegerX.BitwiseXor(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseXor(y);
end;

class operator TIntegerX.LeftShift(x: TIntegerX; shift: Integer): TIntegerX;
begin
  result := x.LeftShift(shift);
end;

class operator TIntegerX.RightShift(x: TIntegerX; shift: Integer): TIntegerX;
begin
  result := x.RightShift(shift);
end;

class function TIntegerX.BitwiseAnd(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseAnd(y);
end;

class function TIntegerX.BitwiseOr(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseOr(y);
end;

class function TIntegerX.BitwiseXor(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseXor(y);
end;

class function TIntegerX.BitwiseNot(x: TIntegerX): TIntegerX;
begin
  result := x.OnesComplement();
end;

class function TIntegerX.BitwiseAndNot(x: TIntegerX; y: TIntegerX): TIntegerX;
begin
  result := x.BitwiseAndNot(y);
end;

class function TIntegerX.LeftShift(x: TIntegerX; shift: Integer): TIntegerX;
begin
  result := x.LeftShift(shift);
end;

class function TIntegerX.RightShift(x: TIntegerX; shift: Integer): TIntegerX;
begin
  result := x.RightShift(shift);
end;

class function TIntegerX.TestBit(x: TIntegerX; n: Integer): Boolean;
begin
  result := x.TestBit(n);
end;

class function TIntegerX.SetBit(x: TIntegerX; n: Integer): TIntegerX;
begin
  result := x.SetBit(n);
end;

class function TIntegerX.FlipBit(x: TIntegerX; n: Integer): TIntegerX;
begin
  result := x.FlipBit(n);
end;

class function TIntegerX.ClearBit(x: TIntegerX; n: Integer): TIntegerX;
begin
  result := x.ClearBit(n);
end;

function TIntegerX.AsInt32(out ret: Integer): Boolean;
begin
  ret := 0;
  case (Length(_data)) of

    0:
      begin
        result := true;
        Exit;
      end;
    1:
      begin
        if (_data[0] > UInt32($80000000)) then
        begin
          result := false;
          Exit;
        end;
        if ((_data[0] = UInt32($80000000)) and (_sign = 1)) then
        begin
          result := false;
          Exit;
        end;
        ret := (Integer(_data[0])) * _sign;
        result := true;
        Exit;
      end
  else
    begin
      result := false;
      Exit;
    end;
  end;
end;

function TIntegerX.AsInt64(out ret: Int64): Boolean;
var
  tmp: UInt64;
begin
  ret := 0;
  case (Length(_data)) of

    0:
      begin
        result := true;
        Exit;
      end;
    1:
      begin
        ret := _sign * Int64(_data[0]);
        result := true;
        Exit;
      end;
    2:
      begin
        tmp := (UInt64(_data[0]) shl 32) or (UInt64(_data[1]));
        if (tmp > ($8000000000000000)) then
        begin
          result := false;
          Exit;
        end;
        if ((tmp = ($8000000000000000)) and (_sign = 1)) then
        begin
          result := false;
          Exit;
        end;
        ret := (Int64(tmp)) * _sign;
        result := true;
        Exit;
      end;
  else
    begin
      result := false;
      Exit;
    end;
  end;
end;

function TIntegerX.AsUInt32(out ret: UInt32): Boolean;
begin
  ret := 0;
  if (_sign = 0) then
  begin
    result := true;
    Exit;
  end;
  if (_sign < 0) then
  begin
    result := false;
    Exit;
  end;
  if (Length(_data) > 1) then
  begin
    result := false;
    Exit;
  end;
  ret := _data[0];
  result := true;
end;

function TIntegerX.AsUInt64(out ret: UInt64): Boolean;
begin
  ret := 0;

  if (_sign < 0) then
  begin
    result := false;
    Exit;
  end;

  case (Length(_data)) of

    0:
      begin
        result := true;
        Exit;
      end;
    1:
      begin
        ret := UInt64(_data[0]);
        result := true;
        Exit;
      end;
    2:
      begin

        ret := UInt64(_data[1]) or (UInt64(_data[0]) shl 32);
        result := true;
        Exit;
      end;
  else
    begin
      result := false;
      Exit;
    end;

  end;
end;

function TIntegerX.ToByte(): Byte;
var
  ret: UInt32;
begin

  if (AsUInt32(ret) and (ret <= $FF)) then
  begin
    result := Byte(ret);
    Exit;
  end;
  raise EOverflowException.Create(OverFlowByte);
end;

function TIntegerX.ToSmallInt(): SmallInt;
var
  ret: Integer;
begin

  if (AsInt32(ret) and (MinSmallIntValue <= ret) and (ret <= MaxSmallIntValue))
  then
  begin
    result := SmallInt(ret);
    Exit;
  end;
  raise EOverflowException.Create(OverFlowSmallInt);
end;

function TIntegerX.ToShortInt(): ShortInt;
var
  ret: Integer;
begin

  if (AsInt32(ret) and (MinShortIntValue <= ret) and (ret <= MaxShortIntValue))
  then
  begin
    result := ShortInt(ret);
    Exit;
  end;
  raise EOverflowException.Create(OverFlowShortInt);
end;

function TIntegerX.ToWord(): Word;
var
  ret: UInt32;
begin
  if (AsUInt32(ret) and (ret <= MaxWordValue)) then
  begin
    result := Word(ret);
    Exit;
  end;
  raise EOverflowException.Create(OverFlowWord);
end;

function TIntegerX.ToUInt32(): UInt32;
var
  ret: UInt32;
begin
  if (AsUInt32(ret)) then
  begin
    result := ret;
    Exit;
  end;
  raise EOverflowException.Create(OverFlowUInt32);
end;

function TIntegerX.ToInteger(): Integer;
var
  ret: Integer;
begin
  if (AsInt32(ret)) then
  begin
    result := ret;
    Exit;
  end;
  raise EOverflowException.Create(OverFlowInteger);
end;

function TIntegerX.ToUInt64(): UInt64;
var
  ret: UInt64;
begin
  if (AsUInt64(ret)) then
  begin
    result := ret;
    Exit;
  end;
  raise EOverflowException.Create(OverFlowUInt64);
end;

function TIntegerX.ToInt64(): Int64;
var
  ret: Int64;
begin
  if (AsInt64(ret)) then
  begin
    result := ret;
    Exit;
  end;
  raise EOverflowException.Create(OverFlowInt64);
end;

function TIntegerX.ToDouble: Double;
begin
  result := StrtoFloat(self.ToString(10), _FS);
end;

function TIntegerX.CompareTo(other: TIntegerX): Integer;
begin
  result := Compare(self, other);
end;

function TIntegerX.Equals(other: TIntegerX): Boolean;
begin
  result := self = other;
end;

class function TIntegerX.Compare(x: TIntegerX; y: TIntegerX): Integer;
begin

  if x._sign = y._sign then
  begin
    result := x._sign * Compare(x._data, y._data);
    Exit;
  end
  else
  begin
    if x._sign < y._sign then
    begin
      result := -1;
      Exit;
    end
    else
    begin
      result := 1;
      Exit;
    end;
  end;

end;

class function TIntegerX.Compare(x: TIntegerXUInt32Array;
  y: TIntegerXUInt32Array): SmallInt;
var
  xlen, ylen, i: Integer;
begin
  xlen := Length(x);
  ylen := Length(y);

  if (xlen < ylen) then
  begin
    result := -1;
    Exit;
  end;

  if (xlen > ylen) then
  begin
    result := 1;
    Exit;
  end;
  i := 0;
  while i < xlen do
  begin
    if (x[i] < y[i]) then
    begin
      result := -1;
      Exit;
    end;
    if (x[i] > y[i]) then
    begin
      result := 1;
      Exit;
    end;
    Inc(i);
  end;

  result := 0;
end;

function TIntegerX.Add(y: TIntegerX): TIntegerX;
var
  c: Integer;

begin
  if (self._sign = 0) then
  begin
    result := y;
    Exit;
  end;

  if (y._sign = 0) then
  begin
    result := self;
    Exit;
  end;

  if (self._sign = y._sign) then
  begin
    result := TIntegerX.Create(_sign, Add(self._data, y._data));
    Exit;
  end
  else
  begin
    c := Compare(self._data, y._data);

    case (c) of

      - 1:
        begin
          result := TIntegerX.Create(-self._sign,
            Subtract(y._data, self._data));
          Exit;
        end;

      0:
        begin
          result := TIntegerX.Create(TIntegerX.Zero);
          Exit;
        end;

      1:
        begin
          result := TIntegerX.Create(self._sign, Subtract(self._data, y._data));
          Exit;
        end;

    else
      raise EInvalidOperationException.Create(BogusCompareResult);

    end;
  end;
end;

function TIntegerX.Subtract(y: TIntegerX): TIntegerX;
var
  cmp: Integer;
  mag: TIntegerXUInt32Array;
begin
  if (y._sign = 0) then
  begin
    result := self;
    Exit;
  end;

  if (self._sign = 0) then
  begin
    result := y.Negate();
    Exit;
  end;

  if (self._sign <> y._sign) then
  begin
    result := TIntegerX.Create(self._sign, Add(self._data, y._data));
    Exit;
  end;

  cmp := Compare(self._data, y._data);

  if (cmp = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end;
  if cmp > 0 then
    mag := Subtract(self._data, y._data)
  else
    mag := Subtract(y._data, self._data);
  result := TIntegerX.Create(cmp * self._sign, mag);
end;

function TIntegerX.Negate(): TIntegerX;
begin
  result := TIntegerX.Create(-self._sign, self._data);
end;

function TIntegerX.Multiply(y: TIntegerX): TIntegerX;
var
  mag: TIntegerXUInt32Array;
begin
  if (self._sign = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end;
  if (y._sign = 0) then
  begin
    result := TIntegerX.Zero;
    Exit;
  end;

  mag := Multiply(self._data, y._data);
  result := TIntegerX.Create(self._sign * y._sign, mag);
end;

function TIntegerX.Divide(y: TIntegerX): TIntegerX;
var
  rem: TIntegerX;
begin
  result := DivRem(y, rem);
end;

function TIntegerX.Modulo(y: TIntegerX): TIntegerX;
var
  rem: TIntegerX;
begin
  DivRem(y, rem);
  result := rem;
end;

function TIntegerX.DivRem(y: TIntegerX; out remainder: TIntegerX): TIntegerX;
var
  q, r: TIntegerXUInt32Array;
begin

  DivMod(_data, y._data, q, r);

  remainder := TIntegerX.Create(_sign, r);
  result := TIntegerX.Create(_sign * y._sign, q);
end;

function TIntegerX.Abs(): TIntegerX;
begin
  if _sign > -0 then
    result := self
  else
    result := self.Negate();
end;

function TIntegerX.Power(exp: Integer): TIntegerX;
var
  mult, tempRes: TIntegerX;
begin
  if (exp < 0) then
    raise EArgumentOutOfRangeException.Create(ExponentNegative);

  if (exp = 0) then
  begin
    result := TIntegerX.One;
    Exit;
  end;

  if (_sign = 0) then
  begin
    result := self;
    Exit;
  end;

  // Exponentiation by repeated squaring
  mult := self;
  tempRes := TIntegerX.One;
  while (exp <> 0) do
  begin
    if ((exp and 1) <> 0) then
      tempRes := tempRes * mult;
    if (exp = 1) then
      break;
    mult := mult * mult;
    exp := exp shr 1;
  end;
  result := tempRes;
end;

function TIntegerX.ModPow(Power: TIntegerX; modulus: TIntegerX): TIntegerX;
var
  mult, tempRes: TIntegerX;
begin
  // TODO: Look at Java implementation for a more efficient version
  if (Power < 0) then
    raise EArgumentOutOfRangeException.Create(PowerNegative);

  if (Power._sign = 0) then
  begin
    result := TIntegerX.One;
    Exit;
  end;

  if (_sign = 0) then
  begin
    result := self;
    Exit;
  end;

  // Exponentiation by repeated squaring
  mult := self;
  tempRes := TIntegerX.One;
  while (Power <> TIntegerX.Zero) do
  begin
    if (Power.IsOdd) then
    begin
      tempRes := tempRes * mult;
      tempRes := tempRes mod modulus;
    end;

    if (Power = TIntegerX.One) then
      break;
    mult := mult * mult;
    mult := mult mod modulus;
    Power := Power shr 1;
  end;
  result := tempRes;
end;

function TIntegerX.Gcd(y: TIntegerX): TIntegerX;
begin
  // We follow Java and do a hybrid/binary gcd

  if (y._sign = 0) then
    self.Abs()
  else if (self._sign = 0) then
  begin
    result := y.Abs();
    Exit;
  end;

  // TODO: get rid of unnecessary object creation?
  result := HybridGcd(self.Abs(), y.Abs());
end;

class function TIntegerX.HybridGcd(a: TIntegerX; b: TIntegerX): TIntegerX;
var
  r: TIntegerX;
begin
  while (Length(b._data) <> 0) do
  begin
    if (System.Abs(Length(a._data) - Length(b._data)) < 2) then
    begin
      result := BinaryGcd(a, b);
      Exit;
    end;

    a.DivRem(b, r);
    a := b;
    b := r;
  end;
  result := a;
end;

class function TIntegerX.BinaryGcd(a: TIntegerX; b: TIntegerX): TIntegerX;
var
  s1, s2, tsign, k, lb: Integer;
  t: TIntegerX;
  x, y: UInt32;
begin
  // From Knuth, 4.5.5, Algorithm B

  // TODO: make this create fewer values, do more in-place manipulations

  // Step B1: Find power of 2
  s1 := a.GetLowestSetBit();
  s2 := b.GetLowestSetBit();
  k := Min(s1, s2);
  if (k <> 0) then
  begin
    a := a.RightShift(k);
    b := b.RightShift(k);
  end;

  // Step B2: Initialize

  if (k = s1) then
  begin
    t := b;
    tsign := -1;
  end
  else
  begin
    t := a;
    tsign := 1;
  end;

  lb := t.GetLowestSetBit();
  while ((lb) >= 0) do
  begin
    // Steps B3 and B4  Halve t until not even.
    t := t.RightShift(lb);
    // Step B5: reset max(u,v)
    if (tsign > 0) then
      a := t
    else
      b := t;

    // One word?

    if ((a.AsUInt32(x)) and (b.AsUInt32(y))) then
    begin
      x := BinaryGcd(x, y);
      t := TIntegerX.Create(x);
      if (k > 0) then
        t := t.LeftShift(k);
      result := t;
      Exit;
    end;

    // Step B6: Subtract
    // TODO: Clean up extra object creation here.
    t := a - b;
    if (t.IsZero) then
      break;

    if (t.IsPositive) then
      tsign := 1
    else
    begin
      tsign := -1;
      t := t.Abs();
    end;
    lb := t.GetLowestSetBit();
  end;

  if (k > 0) then
    a := a.LeftShift(k);
  result := a;
end;

class function TIntegerX.BinaryGcd(a: UInt32; b: UInt32): UInt32;
var
  y, aZeros, bZeros, t: Integer;
  x: UInt32;
begin
  // From Knuth, 4.5.5, Algorithm B
  if (b = 0) then
  begin
    result := a;
    Exit;
  end;
  if (a = 0) then
  begin
    result := b;
    Exit;
  end;

  aZeros := 0;
  x := a and $FF;
  while ((x) = 0) do
  begin
    a := a shr 8;
    aZeros := aZeros + 8;
    x := a and $FF;
  end;

  y := FTrailingZerosTable[x];
  aZeros := aZeros + y;
  a := a shr y;

  bZeros := 0;
  x := b and $FF;
  while ((x) = 0) do
  begin
    b := b shr 8;
    bZeros := bZeros + 8;
    x := b and $FF;
  end;
  y := FTrailingZerosTable[x];
  bZeros := bZeros + y;
  b := b shr y;
  if aZeros < bZeros then
    t := aZeros
  else
    t := bZeros;

  while (a <> b) do
  begin
    if (a > b) then
    begin
      a := a - b;
      x := a and $FF;
      while ((x) = 0) do
      begin
        a := a shr 8;
        x := a and $FF;
      end;
      a := a shr FTrailingZerosTable[x];
    end
    else
    begin
      b := b - a;
      x := b and $FF;
      while ((x) = 0) do
      begin
        b := b shr 8;
        x := b and $FF;
      end;
      b := b shr FTrailingZerosTable[x];
    end;
  end;
  result := a shl t;
end;

class function TIntegerX.TrailingZerosCount(val: UInt32): Integer;
var
  byteVal: UInt32;
begin
  byteVal := val and $FF;
  if (byteVal <> 0) then
  begin
    result := FTrailingZerosTable[byteVal];
    Exit;
  end;

  byteVal := (val shr 8) and $FF;
  if (byteVal <> 0) then
  begin
    result := FTrailingZerosTable[byteVal] + 8;
    Exit;
  end;

  byteVal := (val shr 16) and $FF;
  if (byteVal <> 0) then
  begin
    result := FTrailingZerosTable[byteVal] + 16;
    Exit;
  end;

  byteVal := (val shr 24) and $FF;
  result := FTrailingZerosTable[byteVal] + 24;
end;

class function TIntegerX.BitLengthForUInt32(x: UInt32): UInt32;
begin
  result := 32 - LeadingZeroCount(x);
end;

class function TIntegerX.LeadingZeroCount(x: UInt32): UInt32;
begin
  x := x or (x shr 1);
  x := x or (x shr 2);
  x := x or (x shr 4);
  x := x or (x shr 8);
  x := x or (x shr 16);

  result := UInt32(32) - BitCount(x);
end;

class function TIntegerX.BitCount(x: UInt32): UInt32;
begin
  x := x - ((x shr 1) and $55555555);
  x := (((x shr 2) and $33333333) + (x and $33333333));
  x := (((x shr 4) + x) and $0F0F0F0F);
  x := x + (x shr 8);
  x := x + (x shr 16);
  result := (x and $0000003F);
end;

function TIntegerX.GetLowestSetBit(): Integer;
var
  j: Integer;
begin
  if (_sign = 0) then
  begin
    result := -1;
    Exit;
  end;
  j := Length(_data) - 1;
  while ((j > 0) and (_data[j] = 0)) do
  begin
    Dec(j);
  end;
  result := ((Length(_data) - j - 1) shl 5) + TrailingZerosCount(_data[j]);
end;

function TIntegerX.BitwiseAnd(y: TIntegerX): TIntegerX;
var
  rlen, i: Integer;
  tempRes: TIntegerXUInt32Array;
  xdigit, ydigit: UInt32;
  seenNonZeroX, seenNonZeroY: Boolean;

begin
  rlen := Max(Length(_data), Length(y._data));
  SetLength(tempRes, rlen);

  seenNonZeroX := false;
  seenNonZeroY := false;
  i := 0;
  while i < rlen do
  begin
    xdigit := Get2CDigit(i, seenNonZeroX);
    ydigit := y.Get2CDigit(i, seenNonZeroY);
    tempRes[rlen - i - 1] := xdigit and ydigit;
    Inc(i);
  end;

  // result is negative only if both this and y are negative
  if ((self.IsNegative) and (y.IsNegative)) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.BitwiseOr(y: TIntegerX): TIntegerX;
var
  rlen, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZeroX, seenNonZeroY: Boolean;
  xdigit, ydigit: UInt32;
begin
  rlen := Max(Length(_data), Length(y._data));
  SetLength(tempRes, rlen);

  seenNonZeroX := false;
  seenNonZeroY := false;
  i := 0;
  while i < rlen do
  begin
    xdigit := Get2CDigit(i, seenNonZeroX);
    ydigit := y.Get2CDigit(i, seenNonZeroY);
    tempRes[rlen - i - 1] := xdigit or ydigit;
    Inc(i);
  end;

  // result is negative only if either this or y is negative
  if ((self.IsNegative) or (y.IsNegative)) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.BitwiseXor(y: TIntegerX): TIntegerX;
var
  rlen, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZeroX, seenNonZeroY: Boolean;
  xdigit, ydigit: UInt32;
begin
  rlen := Max(Length(_data), Length(y._data));
  SetLength(tempRes, rlen);

  seenNonZeroX := false;
  seenNonZeroY := false;
  i := 0;
  while i < rlen do
  begin
    xdigit := Get2CDigit(i, seenNonZeroX);
    ydigit := y.Get2CDigit(i, seenNonZeroY);
    tempRes[rlen - i - 1] := xdigit xor ydigit;
    Inc(i);
  end;

  // result is negative only if either x and y have the same sign.
  if (self.Signum = y.Signum) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.OnesComplement(): TIntegerX;
var
  len, i: Integer;
  tempRes: TIntegerXUInt32Array;
  xdigit: UInt32;
  seenNonZero: Boolean;
begin
  len := Length(_data);
  SetLength(tempRes, len);
  seenNonZero := false;
  i := 0;
  while i < len do
  begin
    xdigit := Get2CDigit(i, seenNonZero);
    tempRes[len - i - 1] := not xdigit;
    Inc(i);
  end;

  if (self.IsNegative) then
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes))
  else
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)));
end;

function TIntegerX.BitwiseAndNot(y: TIntegerX): TIntegerX;
var
  rlen, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZeroX, seenNonZeroY: Boolean;
  xdigit, ydigit: UInt32;
begin
  rlen := Max(Length(_data), Length(y._data));
  SetLength(tempRes, rlen);

  seenNonZeroX := false;
  seenNonZeroY := false;
  i := 0;
  while i < rlen do
  begin
    xdigit := Get2CDigit(i, seenNonZeroX);
    ydigit := y.Get2CDigit(i, seenNonZeroY);
    tempRes[rlen - i - 1] := xdigit and (not ydigit);
    Inc(i);
  end;

  // result is negative only if either this is negative and y is positive
  if ((self.IsNegative) and (y.IsPositive)) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.TestBit(n: Integer): Boolean;
begin
  if (n < 0) then
    raise EArithmeticException.Create(NegativeAddress);

  result := (Get2CDigit(n div 32) and (1 shl (n mod 32))) <> 0;
end;

function TIntegerX.SetBit(n: Integer): TIntegerX;
var
  index, len, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZero: Boolean;
begin
  // This will work if the bit is already set.
  if (TestBit(n)) then
  begin
    result := self;
    Exit;
  end;

  index := n div 32;
  SetLength(tempRes, Max(Length(_data), index + 1));

  len := Length(tempRes);

  seenNonZero := false;
  i := 0;
  while i < len do
  begin
    tempRes[len - i - 1] := Get2CDigit(i, seenNonZero);
    Inc(i);
  end;

  tempRes[len - index - 1] := tempRes[len - index - 1] or
    (UInt32(1) shl (n mod 32));

  if (self.IsNegative) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.ClearBit(n: Integer): TIntegerX;
var
  index, len, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZero: Boolean;
begin

  // This will work if the bit is already clear.
  if (not TestBit(n)) then
  begin
    result := self;
    Exit;
  end;

  index := n div 32;
  SetLength(tempRes, Max(Length(_data), index + 1));

  len := Length(tempRes);

  seenNonZero := false;
  i := 0;
  while i < len do
  begin
    tempRes[len - i - 1] := Get2CDigit(i, seenNonZero);
    Inc(i);
  end;

  tempRes[len - index - 1] := tempRes[len - index - 1] and
    (not(UInt32(1) shl (n mod 32)));

  if (self.IsNegative) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.FlipBit(n: Integer): TIntegerX;
var
  index, len, i: Integer;
  tempRes: TIntegerXUInt32Array;
  seenNonZero: Boolean;
begin
  if (n < 0) then
    raise EArithmeticException.Create(NegativeAddress);

  index := n div 32;
  SetLength(tempRes, Max(Length(_data), index + 1));

  len := Length(tempRes);

  seenNonZero := false;
  i := 0;
  while i < len do
  begin
    tempRes[len - i - 1] := Get2CDigit(i, seenNonZero);
    Inc(i);
  end;

  tempRes[len - index - 1] := tempRes[len - index - 1]
    xor (UInt32(1) shl (n mod 32));

  if (self.IsNegative) then
    result := TIntegerX.Create(-1,
      RemoveLeadingZeros(MakeTwosComplement(tempRes)))
  else
    result := TIntegerX.Create(1, RemoveLeadingZeros(tempRes));
end;

function TIntegerX.LeftShift(shift: Integer): TIntegerX;
var
  digitShift, bitShift, xlen, rShift, i, j: Integer;
  tempRes: TIntegerXUInt32Array;
  highBits: UInt32;
begin
  if (shift = 0) then
  begin
    result := self;
    Exit;
  end;

  if (_sign = 0) then
  begin
    result := self;
    Exit;
  end;

  if (shift < 0) then
  begin
    result := RightShift(-shift);
    Exit;
  end;

  digitShift := shift div BitsPerDigit;
  bitShift := shift mod BitsPerDigit;

  xlen := Length(_data);

  if (bitShift = 0) then
  begin
    SetLength(tempRes, xlen + digitShift);
    Move(_data[0], tempRes[0], Length(_data) * SizeOf(UInt32));
  end
  else
  begin
    rShift := BitsPerDigit - bitShift;
    highBits := _data[0] shr rShift;

    if (highBits = 0) then
    begin
      SetLength(tempRes, xlen + digitShift);
      i := 0;
    end
    else
    begin
      SetLength(tempRes, xlen + digitShift + 1);

      tempRes[0] := highBits;
      i := 1;
    end;
    j := 0;
    while j < xlen - 1 do
    begin
      tempRes[i] := (_data[j] shl bitShift) or (_data[j + 1] shr rShift);
      Inc(j);
      Inc(i);
    end;

    tempRes[i] := _data[xlen - 1] shl bitShift;
  end;

  result := TIntegerX.Create(_sign, tempRes);
end;

function TIntegerX.RightShift(shift: Integer): TIntegerX;
var
  digitShift, bitShift, xlen, lShift, rlen, i, j: Integer;
  tempRes: TIntegerXUInt32Array;
  highBits: UInt32;
begin

  if (shift = 0) then
  begin
    result := self;
    Exit;
  end;

  if (_sign = 0) then
  begin
    result := self;
    Exit;
  end;

  if (shift < 0) then
  begin
    result := LeftShift(-shift);
    Exit;
  end;

  digitShift := shift div BitsPerDigit;
  bitShift := shift mod BitsPerDigit;

  xlen := Length(_data);

  if (digitShift >= xlen) then
  begin
    if _sign >= 0 then
    begin
      result := TIntegerX.Zero;
      Exit;
    end
    else
    begin
      result := TIntegerX.NegativeOne;
      Exit;
    end;

  end;

  if (bitShift = 0) then
  begin
    rlen := xlen - digitShift;
    SetLength(tempRes, rlen);
    i := 0;
    while i < rlen do
    begin
      tempRes[i] := _data[i];
      Inc(i);
    end;
  end

  else
  begin
    highBits := _data[0] shr bitShift;

    if (highBits = 0) then
    begin
      rlen := xlen - digitShift - 1;
      SetLength(tempRes, rlen);
      i := 0;
    end
    else
    begin
      rlen := xlen - digitShift;
      SetLength(tempRes, rlen);
      tempRes[0] := highBits;
      i := 1;
    end;

    lShift := BitsPerDigit - bitShift;
    j := 0;
    while j < xlen - digitShift - 1 do
    begin
      tempRes[i] := (_data[j] shl lShift) or (_data[j + 1] shr bitShift);
      Inc(j);
      Inc(i);
    end;
  end;

  result := TIntegerX.Create(_sign, tempRes);
end;

function TIntegerX.Get2CDigit(n: Integer): UInt32;
var
  digit: UInt32;
begin
  if (n < 0) then
  begin
    result := 0;
    Exit;
  end;
  if (n >= Length(_data)) then
  begin
    result := Get2CSignExtensionDigit();
    Exit;
  end;

  digit := _data[Length(_data) - n - 1];

  if (_sign >= 0) then
  begin
    result := digit;
    Exit;
  end;

  if (n <= FirstNonzero2CDigitIndex()) then
  begin
    result := (not digit) + 1;
    Exit;
  end
  else
    result := not digit;
end;

function TIntegerX.Get2CDigit(n: Integer; var seenNonZero: Boolean): UInt32;
var
  digit: UInt32;
begin
  if (n < 0) then
  begin
    result := 0;
    Exit;
  end;
  if (n >= Length(_data)) then
  begin
    result := Get2CSignExtensionDigit();
    Exit;
  end;

  digit := _data[Length(_data) - n - 1];

  if (_sign >= 0) then
  begin
    result := digit;
    Exit;
  end;

  if (seenNonZero) then
  begin
    result := not digit;
    Exit;
  end
  else
  begin
    if (digit = 0) then
    begin
      result := 0;
      Exit;
    end
    else
    begin
      seenNonZero := true;
      result := not digit + 1;
    end;
  end;
end;

function TIntegerX.Get2CSignExtensionDigit(): UInt32;
begin
  if _sign < 0 then
    result := MaxUInt32Value
  else
    result := 0;
end;

function TIntegerX.FirstNonzero2CDigitIndex(): Integer;
var
  i: Integer;
begin
  // The Java version caches this value on first computation
  i := Length(_data) - 1;
  while (i >= 0) and (_data[i] = 0) do
  begin
    Dec(i);
  end;
  result := Length(_data) - i - 1;

end;

class function TIntegerX.MakeTwosComplement(a: TIntegerXUInt32Array)
  : TIntegerXUInt32Array;
var
  i: Integer;
  digit: UInt32;
begin
  i := Length(a) - 1;
  digit := 0; // to prevent exit on first test
  while ((i >= 0) and (digit = 0)) do
  begin
    digit := not a[i] + 1;
    a[i] := digit;
    Dec(i);
  end;
  while i >= 0 do
  begin
    a[i] := not a[i];
    Dec(i);
  end;
  result := a;
end;

function TIntegerX.Signum: Integer;
begin
  result := _sign;
end;

function TIntegerX.IsPositive: Boolean;
begin
  result := _sign > 0;
end;

function TIntegerX.IsNegative: Boolean;
begin
  result := _sign < 0;
end;

function TIntegerX.IsZero: Boolean;
begin
  result := _sign = 0;
end;

function TIntegerX.IsOdd: Boolean;
begin

  begin
    result := ((_data <> Nil) and (Length(_data) > 0) and
      ((_data[Length(_data) - 1] and 1) <> 0));
  end;
end;

function TIntegerX.GetMagnitude(): TIntegerXUInt32Array;
begin
  result := copy(self._data, 0, Length(self._data));
end;

function TIntegerX.BitLength(): UInt32;
var
  m: TIntegerXUInt32Array;
  len, n, magBitLength, i: UInt32;
  pow2: Boolean;
begin
  m := self._data;
  len := Length(m);
  if len = 0 then
  begin
    n := 0;
  end
  else
  begin
    magBitLength := ((len - 1) shl 5) + BitLengthForUInt32(m[0]);
    if Signum < 0 then
    begin
      pow2 := BitCount(m[0]) = 1;
      i := 1;
      while ((i < len) and (pow2)) do
      begin
        pow2 := m[i] = 0;
        Inc(i);
      end;
      if pow2 then
        n := magBitLength - 1
      else
        n := magBitLength;
    end
    else
    begin
      n := magBitLength;
    end;
  end;
  result := n;
end;

function TIntegerX.BitCount(): UInt32;
var
  bc, i, len, magTrailingZeroCount, j: UInt32;
  m: TIntegerXUInt32Array;
begin
  m := self._data;
  bc := 0;
  i := 0;
  len := Length(self._data);
  while i < len do
  begin
    bc := bc + BitCount(m[i]);
    Inc(i);
  end;
  if (Signum < 0) then
  begin
    // Count the trailing zeros in the magnitude
    magTrailingZeroCount := 0;
    j := len - 1;
    while m[j] = 0 do
    begin
      magTrailingZeroCount := magTrailingZeroCount + 32;
      Dec(j);
    end;

    magTrailingZeroCount := magTrailingZeroCount +
      UInt32(TrailingZerosCount(m[j]));
    bc := bc + magTrailingZeroCount - UInt32(1);
  end;
  result := bc;
end;

function TIntegerX.ToByteArray(): TBytes;
var
  byteLen, i, bytesCopied, nextInt, intIndex: Integer;
begin
  byteLen := Integer(self.BitLength() div 8) + 1;
  SetLength(result, byteLen);
  i := byteLen - 1;
  bytesCopied := 4;
  nextInt := 0;
  intIndex := 0;
  while i >= 0 do
  begin
    if (bytesCopied = 4) then
    begin
      nextInt := getInt(intIndex);
      Inc(intIndex);
      bytesCopied := 1;
    end
    else
    begin
      nextInt := Asr(nextInt, 8);
      Inc(bytesCopied);
    end;
    result[i] := Byte(nextInt);
    Dec(i);
  end;

end;

function TIntegerX.GetPrecision: UInt32;
var
  digits: UInt32;
  work: TIntegerXUInt32Array;
  index: Integer;

begin
  if (self.IsZero) then
  begin
    result := 1; // 0 is one digit
    Exit;
  end;

  digits := 0;
  work := self.GetMagnitude(); // need a working copy.
  index := 0;

  while (index < Pred(Length(work))) do
  begin
    InPlaceDivRem(work, index, UInt32(1000000000));
    digits := digits + 9;
  end;

  if (index = Pred(Length(work))) then
    digits := digits + UIntPrecision(work[index]);

  result := digits;

end;

class function TIntegerX.UIntPrecision(v: UInt32): UInt32;
var
  i: UInt32;
begin

  i := 1;
  while true do
  begin
    if (v <= FUIntLogTable[i]) then
    begin
      result := i;
      Exit;
    end;
    Inc(i);
  end;
  result := 0;
end;

class function TIntegerX.Add(x: TIntegerXUInt32Array; y: TIntegerXUInt32Array)
  : TIntegerXUInt32Array;
var
  temp, tempRes: TIntegerXUInt32Array;
  xi, yi: Integer;
  sum: UInt64;
begin

  // make sure x is longer, y shorter, swapping if necessary
  if (Length(x) < Length(y)) then
  begin
    temp := x;
    x := y;
    y := temp;
  end;

  xi := Length(x);
  yi := Length(y);
  SetLength(tempRes, xi);

  sum := 0;

  // add common parts, with carry
  while (yi > 0) do
  begin
    Dec(xi);
    Dec(yi);
    sum := (sum shr BitsPerDigit) + x[xi] + y[yi];
    tempRes[xi] := UInt32(sum);
  end;

  // copy longer part of x, while carry required
  sum := sum shr BitsPerDigit;
  while ((xi > 0) and (sum <> 0)) do
  begin
    Dec(xi);
    sum := (UInt64(x[xi])) + 1;
    tempRes[xi] := UInt32(sum);
    sum := sum shr BitsPerDigit;
  end;

  // copy remaining part, no carry required
  while (xi > 0) do
  begin
    Dec(xi);
    tempRes[xi] := x[xi];
  end;

  // if carry still required, we must grow
  if (sum <> 0) then
    tempRes := AddSignificantDigit(tempRes, UInt32(sum));

  result := tempRes;
end;

class function TIntegerX.AddSignificantDigit(x: TIntegerXUInt32Array;
  newDigit: UInt32): TIntegerXUInt32Array;
var
  tempRes: TIntegerXUInt32Array;
  i: Integer;
begin
  SetLength(tempRes, Length(x) + 1);
  tempRes[0] := newDigit;
  i := 0;
  while i < Length(x) do
  begin
    tempRes[i + 1] := x[i];
    Inc(i);
  end;
  result := tempRes;
end;

class function TIntegerX.Subtract(xs: TIntegerXUInt32Array;
  ys: TIntegerXUInt32Array): TIntegerXUInt32Array;
var
  xlen, ylen, ix, iy: Integer;
  tempRes: TIntegerXUInt32Array;
  borrow: Boolean;
  x, y: UInt32;
begin
  // Assume xs > ys
  xlen := Length(xs);
  ylen := Length(ys);
  SetLength(tempRes, xlen);

  borrow := false;
  ix := xlen - 1;
  iy := ylen - 1;
  while iy >= 0 do
  begin
    x := xs[ix];
    y := ys[iy];
    if (borrow) then
    begin
      if (x = 0) then
      begin
        x := $FFFFFFFF;
        borrow := true;
      end
      else
      begin
        x := x - 1;
        borrow := false;
      end;
    end;
    borrow := borrow or (y > x);
    tempRes[ix] := x - y;
    Dec(iy);
    Dec(ix);
  end;

  while ((borrow) and (ix >= 0)) do
  begin
    tempRes[ix] := xs[ix] - 1;
    borrow := tempRes[ix] = $FFFFFFFF;
    Dec(ix);
  end;

  while ix >= 0 do
  begin
    tempRes[ix] := xs[ix];
    Dec(ix);
  end;

  result := RemoveLeadingZeros(tempRes);
end;

class function TIntegerX.Multiply(xs: TIntegerXUInt32Array;
  ys: TIntegerXUInt32Array): TIntegerXUInt32Array;
var
  xlen, ylen, xi, zi, yi: Integer;
  zs: TIntegerXUInt32Array;
  x, product: UInt64;
begin
  xlen := Length(xs);
  ylen := Length(ys);
  SetLength(zs, xlen + ylen);
  xi := xlen - 1;
  while xi >= 0 do
  begin
    x := xs[xi];
    zi := xi + ylen;
    product := 0;
    yi := ylen - 1;
    while yi >= 0 do
    begin
      product := product + x * ys[yi] + zs[zi];
      zs[zi] := UInt32(product);
      product := product shr BitsPerDigit;
      Dec(yi);
      Dec(zi);
    end;

    while (product <> 0) do
    begin
      product := product + zs[zi];
      zs[zi] := UInt32(product);
      Inc(zi);
      product := product shr BitsPerDigit;
    end;
    Dec(xi);
  end;

  result := RemoveLeadingZeros(zs);
end;

class procedure TIntegerX.DivMod(x: TIntegerXUInt32Array;
  y: TIntegerXUInt32Array; out q: TIntegerXUInt32Array;
  out r: TIntegerXUInt32Array);
const
  SuperB: UInt64 = $100000000;
var
  ylen, xlen, cmp, shift, j, k, i: Integer;
  rem: UInt32;
  toptwo, qhat, rhat, val, carry: UInt64;
  borrow, temp: Int64;
  xnorm, ynorm: TIntegerXUInt32Array;

begin
  // Handle some special cases first.

  ylen := Length(y);

  // Special case: divisor = 0
  if (ylen = 0) then
    raise EDivByZeroException.Create('');

  xlen := Length(x);

  // Special case: dividend = 0
  if (xlen = 0) then
  begin
    SetLength(q, 0);
    SetLength(r, 0);
    Exit;
  end;

  cmp := Compare(x, y);

  // Special case: dividend = divisor
  if (cmp = 0) then
  begin
    q := TIntegerXUInt32Array.Create(1);
    r := TIntegerXUInt32Array.Create(0);
    Exit;
  end;

  // Special case: dividend < divisor
  if (cmp < 0) then
  begin
    SetLength(q, 0);
    r := copy(x, 0, Length(x));
    Exit;
  end;

  // Special case: divide by single digit (UInt32)
  if (ylen = 1) then
  begin
    rem := CopyDivRem(x, y[0], q);
    r := TIntegerXUInt32Array.Create(rem);
    Exit;
  end;

  // Okay.
  // Special cases out of the way, let do Knuth's algorithm.
  // This is almost exactly the same as in DLR's BigInteger.
  // TODO:  Look at the optimizations in the Colin Plumb C library
  // (used in the Java BigInteger code).

  // D1. Normalize
  // Using suggestion to take d = a power of 2 that makes v(n-1) >= b/2.

  shift := Integer(LeadingZeroCount(y[0]));
  SetLength(xnorm, xlen + 1);
  SetLength(ynorm, ylen);

  Normalize(xnorm, xlen + 1, x, xlen, shift);
  Normalize(ynorm, ylen, y, ylen, shift);
  SetLength(q, xlen - ylen + 1);
  r := Nil;

  // Main loop:
  // D2: Initialize j
  // D7: Loop on j
  // Our loop goes the opposite way because of big-endian
  j := 0;
  while j <= (xlen - ylen) do
  begin
    // D3: Calculate qhat.
    toptwo := xnorm[j] * SuperB + xnorm[j + 1];
    qhat := toptwo div ynorm[0];
    rhat := toptwo mod ynorm[0];

    // adjust if estimate is too big
    while (true) do
    begin
      if ((qhat < SuperB) and ((qhat * ynorm[1]) <= (SuperB * rhat +
        xnorm[j + 2]))) then
        break;
      Dec(qhat);
      // qhat := qhat - 1;
      rhat := rhat + UInt64(ynorm[0]);
      if (rhat >= SuperB) then
        break;
    end;
    // D4: Multiply and subtract
    // Read Knuth very carefully when it comes to
    // possibly being too large, borrowing, readjusting.
    // It sucks.

    borrow := 0;
    k := ylen - 1;
    while k >= 0 do
    begin
      i := j + k + 1;
      val := ynorm[k] * qhat;
      temp := Int64(xnorm[i]) - Int64(UInt32(val)) - borrow;
      xnorm[i] := UInt32(temp);
      val := val shr BitsPerDigit;
      temp := TIntegerX.Asr(temp, BitsPerDigit);
      borrow := Int64(val) - temp;
      Dec(k);
    end;
    temp := Int64(xnorm[j]) - borrow;
    xnorm[j] := UInt32(temp);

    // D5: Test remainder
    // We now know the quotient digit at this index
    q[j] := UInt32(qhat);

    // D6: Add back
    // If we went negative, add ynorm back into the xnorm.
    if (temp < 0) then
    begin
      Dec(q[j]);
      carry := 0;
      k := ylen - 1;
      while k >= 0 do
      begin
        i := j + k + 1;
        carry := UInt64(ynorm[k]) + xnorm[i] + carry;
        xnorm[i] := UInt32(carry);
        carry := carry shr BitsPerDigit;
        Dec(k);
      end;

      carry := carry + UInt64(xnorm[j]);
      xnorm[j] := UInt32(carry);
    end;

    Inc(j);
  end;
  Unnormalize(xnorm, r, shift);
end;

class procedure TIntegerX.Normalize(var xnorm: TIntegerXUInt32Array;
  xnlen: Integer; x: TIntegerXUInt32Array; xlen: Integer; shift: Integer);

var
  sameLen: Boolean;
  offset, rShift, i: Integer;
  carry, xi: UInt32;
begin
  sameLen := xnlen = xlen;
  if sameLen then
    offset := 0
  else
    offset := 1;

  if (shift = 0) then
  begin
    // just copy, with the added zero at the most significant end.
    if (not sameLen) then
      xnorm[0] := 0;
    i := 0;
    while i < xlen do
    begin
      xnorm[i + offset] := x[i];
      Inc(i);
    end;
    Exit;
  end;

  rShift := BitsPerDigit - shift;
  carry := 0;
  i := xlen - 1;
  while i >= 0 do
  begin
    xi := x[i];
    xnorm[i + offset] := (xi shl shift) or carry;
    carry := xi shr rShift;
    Dec(i);
  end;

  if (sameLen) then
  begin
    if (carry <> 0) then
      raise EInvalidOperationException.Create(CarryOffLeft);
  end
  else
    xnorm[0] := carry;
end;

class procedure TIntegerX.Unnormalize(xnorm: TIntegerXUInt32Array;
  out r: TIntegerXUInt32Array; shift: Integer);

var
  len, lShift, i: Integer;
  carry, lval: UInt32;
begin
  len := Length(xnorm);
  SetLength(r, len);

  if (shift = 0) then
  begin
    i := 0;
    while i < len do
    begin
      r[i] := xnorm[i];
      Inc(i);
    end;
  end
  else
  begin
    lShift := BitsPerDigit - shift;
    carry := 0;
    i := 0;
    while i < len do
    begin
      lval := xnorm[i];
      r[i] := (lval shr shift) or carry;
      carry := lval shl lShift;
      Inc(i);
    end;

  end;

  r := RemoveLeadingZeros(r);
end;

class procedure TIntegerX.InPlaceMulAdd(var data: TIntegerXUInt32Array;
  mult: UInt32; addend: UInt32);

var
  len, i: Integer;
  sum, product, carry: UInt64;

begin
  len := Length(data);

  // Multiply
  carry := 0;
  i := len - 1;
  while i >= 0 do
  begin
    product := (UInt64(data[i])) * mult + carry;
    data[i] := UInt32(product);
    carry := product shr BitsPerDigit;
    Dec(i);
  end;

  // Add
  sum := (UInt64(data[len - 1])) + addend;
  data[len - 1] := UInt32(sum);
  carry := sum shr BitsPerDigit;
  i := len - 2;
  while ((i >= 0) and (carry > 0)) do
  begin

    sum := (UInt64(data[i])) + carry;
    data[i] := UInt32(sum);
    carry := sum shr BitsPerDigit;
    Dec(i);
  end;

end;

class function TIntegerX.RemoveLeadingZeros(data: TIntegerXUInt32Array)
  : TIntegerXUInt32Array;
var
  len, index, i: Integer;
  tempRes: TIntegerXUInt32Array;
begin
  len := Length(data);
  index := 0;
  while ((index < len) and (data[index] = 0)) do
    Inc(index);

  if (index = 0) then
  begin
    result := data;
    Exit;
  end;

  // we have leading zeros. Allocate new array.
  SetLength(tempRes, len - index);
  i := 0;
  while (i < (len - index)) do
  begin
    tempRes[i] := data[index + i];
    Inc(i);
  end;
  result := tempRes;
end;

class function TIntegerX.StripLeadingZeroBytes(a: TBytes): TIntegerXUInt32Array;
var
  byteLength, keep, intLength, b, i, bytesRemaining, bytesToTransfer,
    j: Integer;
begin
  byteLength := Length(a);
  keep := 0;
  // Find first nonzero byte
  while ((keep < byteLength) and (a[keep] = 0)) do
  begin
    Inc(keep);
  end;

  // Allocate new array and copy relevant part of input array
  intLength := Asr(((byteLength - keep) + 3), 2);
  SetLength(result, intLength);
  b := byteLength - 1;

  i := intLength - 1;
  while i >= 0 do
  begin
    result[i] := (a[b] and $FF);
    Dec(b);
    bytesRemaining := b - keep + 1;
    bytesToTransfer := Min(3, bytesRemaining);
    j := 8;
    while j <= (bytesToTransfer shl 3) do
    begin
      result[i] := result[i] or ((a[b] and $FF) shl j);
      Dec(b);
      Inc(j, 8);
    end;
    Dec(i);
  end;

end;

class function TIntegerX.makePositive(a: TBytes): TIntegerXUInt32Array;
var
  keep, k, byteLength, extraByte, intLength, b, i, numBytesToTransfer, j,
    mask: Integer;
begin

  byteLength := Length(a);

  // Find first non-sign ($ff) byte of input
  keep := 0;
  while ((keep < byteLength) and (ShortInt(a[keep]) = -1)) do
  begin
    Inc(keep);
  end;

  { /* Allocate output array.  If all non-sign bytes are $00, we must
    * allocate space for one extra output byte. */ }
  k := keep;
  while ((k < byteLength) and (ShortInt(a[k]) = 0)) do
  begin
    Inc(k);
  end;
  if k = byteLength then
    extraByte := 1
  else
    extraByte := 0;
  intLength := ((byteLength - keep + extraByte) + 3) div 4;
  SetLength(result, intLength);

  { /* Copy one's complement of input into output, leaving extra
    * byte (if it exists) = $00 */ }
  b := byteLength - 1;
  i := intLength - 1;
  while i >= 0 do
  begin

    result[i] := (a[b]) and $FF;
    Dec(b);
    numBytesToTransfer := Min(3, b - keep + 1);
    if (numBytesToTransfer < 0) then
      numBytesToTransfer := 0;
    j := 8;
    while j <= 8 * numBytesToTransfer do
    begin

      result[i] := result[i] or ((a[b] and $FF) shl j);
      Dec(b);
      Inc(j, 8);
    end;

    // Mask indicates which bits must be complemented

    mask := Asr(UInt32(-1), (8 * (3 - numBytesToTransfer)));
    result[i] := (not result[i]) and mask;
    Dec(i);
  end;

  // Add one to one's complement to generate two's complement
  i := Length(result) - 1;
  while i >= 0 do
  begin
    result[i] := Integer((result[i] and $FFFFFFFF) + 1);
    if (result[i] <> 0) then
      break;

    Dec(i);
  end;

end;

class function TIntegerX.InPlaceDivRem(var data: TIntegerXUInt32Array;
  var index: Integer; divisor: UInt32): UInt32;
var
  rem: UInt64;
  seenNonZero: Boolean;
  len, i: Integer;
  q: UInt32;
begin
  rem := 0;
  seenNonZero := false;
  len := Length(data);
  i := index;
  while i < len do
  begin
    rem := rem shl BitsPerDigit;
    rem := rem or data[i];
    q := UInt32(rem div divisor);
    data[i] := q;
    if (q = 0) then
    begin
      if (not seenNonZero) then
        Inc(index);
    end
    else
      seenNonZero := true;
    rem := rem mod divisor;
    Inc(i);
  end;

  result := UInt32(rem);
end;

class function TIntegerX.CopyDivRem(data: TIntegerXUInt32Array; divisor: UInt32;
  out quotient: TIntegerXUInt32Array): UInt32;
var
  rem: UInt64;
  len, i: Integer;
  q: UInt32;
begin
  SetLength(quotient, Length(data));

  rem := 0;
  len := Length(data);
  i := 0;
  while i < len do
  begin
    rem := rem shl BitsPerDigit;
    rem := rem or data[i];
    q := UInt32(rem div divisor);
    quotient[i] := q;
    rem := rem mod divisor;
    Inc(i);
  end;

  quotient := RemoveLeadingZeros(quotient);
  result := UInt32(rem);
end;

function TIntegerX.signInt(): Integer;
begin
  if self.Signum < 0 then
    result := -1
  else
    result := 0;
end;

function TIntegerX.getInt(n: Integer): Integer;
var
  magInt: Integer;
begin
  if (n < 0) then
  begin
    result := 0;
    Exit;
  end;
  if (n >= Length(self._data)) then
  begin
    result := signInt();
    Exit;
  end;

  magInt := self._data[Length(self._data) - n - 1];

  if Signum >= 0 then
    result := magInt
  else
  begin
    if n <= firstNonzeroIntNum() then
      result := -magInt
    else
      result := not magInt;
  end;

end;

function TIntegerX.firstNonzeroIntNum(): Integer;
var
  fn, i, mlen: Integer;
begin

  // Search for the first nonzero int
  mlen := Length(self._data);
  i := mlen - 1;

  while ((i >= 0) and (self._data[i] = 0)) do
  begin
    Dec(i);
  end;

  fn := mlen - i - 1;
  result := fn;
end;

class function TIntegerX.GetZero: TIntegerX;

begin
  result := ZeroX;
end;

class function TIntegerX.GetOne: TIntegerX;
begin
  result := OneX;
end;

class function TIntegerX.GetTwo: TIntegerX;
begin
  result := TwoX;
end;

class function TIntegerX.GetFive: TIntegerX;
begin
  result := FiveX;
end;

class function TIntegerX.GetTen: TIntegerX;
begin
  result := TenX;
end;

class function TIntegerX.GetNegativeOne: TIntegerX;
begin
  result := NegativeOneX;
end;

end.
