unit BaseTests;

interface

uses
  System.SysUtils, DUnitX.TestFramework, uBase;

type

  IBaseNcodingTests = interface
    ['{20A2197E-2906-446D-B319-DCEA726966C1}']

  end;

   [TestFixture]
   [Ignore]
  TBaseNcodingTests = class abstract(TInterfacedObject, IBaseNcodingTests)

  protected
    class var

      FConverter: IBase;

    /// <summary>
    /// Sample from http://en.wikipedia.org/wiki/Base64#Examples
    /// </summary>
  const
    Base64SampleString =
      'Man is distinguished, not only by his reason, but by this singular passion from '
      + 'other animals, which is a lust of the mind, that by a perseverance of delight '
      + 'in the continued and indefatigable generation of knowledge, exceeds the short '
      + 'vehemence of any carnal pleasure.';

    RusString =
      'Зарегистрируйтесь сейчас на Десятую Международную Конференцию по ' +
      'Unicode, которая состоится 10-12 марта 1997 года в Майнце в Германии. ' +
      'Конференция соберет широкий круг экспертов по вопросам глобального ' +
      'Интернета и Unicode, локализации и интернационализации, воплощению и ' +
      'применению Unicode в различных операционных системах и программных ' +
      'приложениях, шрифтах, верстке и многоязычных компьютерных системах.';

    GreekString = 'Σὲ γνωρίζω ἀπὸ τὴν κόψη τοῦ σπαθιοῦ τὴν τρομερή, ' +
      'σὲ γνωρίζω ἀπὸ τὴν ὄψη ποὺ μὲ βία μετράει τὴ γῆ. ' +
      '᾿Απ᾿ τὰ κόκκαλα βγαλμένη τῶν ῾Ελλήνων τὰ ἱερά ' +
      'καὶ σὰν πρῶτα ἀνδρειωμένη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!';

  public

    [TestCase('Base64SampleStringTest', Base64SampleString)]
    [TestCase('RusStringSampleStringTest', RusString)]
    [TestCase('GreekStringSampleStringTest', GreekString)]
    procedure EncodeDecodeTest(const str: String);

    [TestCase('Base64SampleStringTestDefaultEncoding', Base64SampleString)]
    procedure EncodeDecodeTestDefaultTextEncoding(const str: String);

    [TestCase('Base64SampleStringTestUnicodeEncoding', Base64SampleString)]
    [TestCase('RusStringSampleStringTestUnicodeEncoding', RusString)]
    [TestCase('GreekStringSampleStringTestUnicodeEncoding', GreekString)]
    procedure EncodeDecodeTestUnicodeTextEncoding(const str: String);

    [Test]
    procedure TailTests;

  end;

implementation

procedure TBaseNcodingTests.EncodeDecodeTest(const str: String);
var
  encoded, decoded: String;
begin
  encoded := FConverter.EncodeString(str);
  decoded := FConverter.DecodeToString(encoded);

  Assert.AreEqual(str, decoded);
end;

procedure TBaseNcodingTests.EncodeDecodeTestDefaultTextEncoding
  (const str: String);
var
  encoded, decoded: String;
begin
  FConverter.Encoding := TEncoding.Default;
  encoded := FConverter.EncodeString(str);
  decoded := FConverter.DecodeToString(encoded);

  Assert.AreEqual(str, decoded);
end;

procedure TBaseNcodingTests.EncodeDecodeTestUnicodeTextEncoding
  (const str: String);
var
  encoded, decoded: String;
begin
  FConverter.Encoding := TEncoding.Unicode;
  encoded := FConverter.EncodeString(str);
  decoded := FConverter.DecodeToString(encoded);

  Assert.AreEqual(str, decoded);
end;

procedure TBaseNcodingTests.TailTests;
var
  testChar: Char;
  strBuilder: TStringBuilder;
  bitsPerChar, bitsPerByte, charByteBitsLcm, maxTailLength, count, i: Integer;
  str, encoded: String;
  c: Char;
begin
  testChar := 'a';
  strBuilder := TStringBuilder.Create;
  try
    if ((FConverter.HaveSpecial) and (Trunc(FConverter.BitsPerChars) mod 1 = 0)
      and (TBase.IsPowerOf2(UInt32(Trunc(FConverter.BitsPerChars))))) then
    begin
      bitsPerChar := Trunc(FConverter.BitsPerChars);
      bitsPerByte := 8;
      charByteBitsLcm := TBase.LCM(bitsPerByte, bitsPerChar);
      maxTailLength := charByteBitsLcm div bitsPerByte - 1;

      for i := 0 to (maxTailLength + 2) do
      begin
        str := strBuilder.ToString();
        encoded := FConverter.EncodeString(str);
        count := 0;
        for c in encoded do
        begin
          if c = FConverter.Special then
            Inc(count);
        end;

        if i = 0 then
          Assert.AreEqual(0, count)
        else
          Assert.AreEqual
            ((maxTailLength - (i - 1) mod (maxTailLength + 1)), count);

        Assert.AreEqual(str, FConverter.DecodeToString(encoded));
        strBuilder.Append(testChar);
      end;

    end;
  finally
    strBuilder.Free;
  end;
end;

initialization

 TDUnitX.RegisterTestFixture(TBaseNcodingTests);

end.
