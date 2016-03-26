unit uBase1024;

{$ZEROBASEDSTRINGS ON}

interface

uses

  System.SysUtils,
  uBase,
  uUtils;

type

  IBase1024 = interface
    ['{4131E6DD-DAB7-4752-84D9-88B52E03CEF1}']

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

  end;

  TBase1024 = class(TBase, IBase1024)

  public

    const

    DefaultAlphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' +
      'ªµºÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûü' +
      'ýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋ'
      + 'ŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƀƁƂƃ' +
      'ƄƅƆƇƈƉƊƋƌƍƎƏƐƑƒƓƔƕƖƗƘƙƚƛƜƝƞƟƠơƢƣƤƥƦƧƨƩƪƫƬƭƮƯưƱƲƳƴ' +
      'ƵƶƷƸƹƺƻƼƽƾƿǀǁǂǃǄǅǆǇǈǉǊǋǌǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯǰǱǲǳǴǵǶǷǸǹǺǻǼǽǾǿȀȁȂȃȄȅȆȇȈȉȊ'
      + 'ȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȜȝȞȟȠȡȢȣȤȥȦȧȨȩȪȫȬȭȮȯȰȱȲȳȴȵȶȸȹȺȻȼȽȾȿɀɁ' +
      'ɂɃɄɅɆɇɈɉɊɋɌɍɎɏɐɑɒɓɔɕɖɗɘəɚɛɜɝɞɟɠɡɢɣɤɥɦɧɨɩɪɫɬɭɮɯɰɱɲɳɴɵɶɷɸɹɺɻɼɽ' +
      'ɾɿʀʁʂʃʄʅʆʇʈʉʊʋʌʍʎʏʐʑʒʓʔʕʖʗʘʙʚʛʜʝʞʟʠʡʢʣʤʥʦʧʨʩʪʫʬʭʮʯʰʱʲʳʴʵʶʷʸʹʺʻʼʽʾʿˀˁˆˇˈˉˊˋˌˍˎˏːˑˠˡˢˣˤˬˮʹͺ'
      + 'ͻͼͽΆΈΉΊΌΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπ' +
      'ρςστυφχψωϊϋόύώϐϑϒϓϔϕϖϗϘϙϚϛϜϝϞϟϠϡϢϣϤϥϦϧϨϩϪϫϬϭϮϯϰϱϲϳϴϵϷϸϹϺϻϼϽϾϿЀЁЂЃЄЅІЇЈ' +
      'ЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяѐёђѓє'
      + 'ѕіїјљњћќѝўџѠѡѢѣѤѥѦѧѨѩѪѫѬѭѮѯѰѱѲѳѴѵѶѷѸѹѺѻѼѽѾѿҀҁҊҋҌҍҎҏҐґҒғҔҕҖҗҘҙҚқҜҝҞҟҠҡҢңҤҥҦҧҨҩҪҫҬҭҮүҰұҲҳҴҵҶҷҸҹҺ'
      + 'һҼҽҾҿӀӁӂӃӄӅӆӇӈӉӊӋӌӍӎӏӐӑӒӓӔӕӖӗӘәӚӛӜӝӞӟӠӡӢӣӤӥӦӧӨөӪӫӬӭӮӯӰӱӲӳӴӵӶӷӸӹӺӻӼӽӾӿԀԁԂԃԄԅԆԇԈԉԊԋԌԍԎԏԐԑԒԓԚԛԜԝԱԲԳԴԵ'
      + 'ԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔ';

    DefaultSpecial = '=';

    constructor Create(const _Alphabet: String = DefaultAlphabet;
      _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);

    function Encode(data: TArray<Byte>): String; override;
    function Decode(const data: String): TArray<Byte>; override;

  end;

implementation

constructor TBase1024.Create(const _Alphabet: String = DefaultAlphabet;
  _Special: Char = DefaultSpecial; _textEncoding: TEncoding = Nil);
begin
  Inherited Create(1024, _Alphabet, _Special, _textEncoding);
  FHaveSpecial := True;
end;

function TBase1024.Encode(data: TArray<Byte>): String;
var
  dataLength, i, x1, x2, x3, x4, x5, length5, tempInt: Integer;
  tempResult: TStringBuilder;

begin
  if ((data = nil) or (Length(data) = 0)) then
  begin
    Exit('');
  end;

  dataLength := Length(data);

  tempResult := TStringBuilder.Create((dataLength + 4) div 5 * 4 + 1);

  try
    length5 := (dataLength div 5) * 5;
    i := 0;
    while i < length5 do
    begin
      x1 := data[i];
      x2 := data[i + 1];
      x3 := data[i + 2];
      x4 := data[i + 3];
      x5 := data[i + 4];

      tempResult.Append(Alphabet[x1 or ((x2 and $03) shl 8)]);
      tempResult.Append(Alphabet[(x2 shr 2) or ((x3 and $0F) shl 6)]);
      tempResult.Append(Alphabet[(x3 shr 4) or ((x4 and $3F) shl 4)]);
      tempResult.Append(Alphabet[(x4 shr 6) or (x5 shl 2)]);

      inc(i, 5);
    end;

    tempInt := dataLength - length5;

    Case tempInt of
      1:
        begin
          x1 := data[i];

          tempResult.Append(Alphabet[x1]);
          tempResult.Append(Special, 4);

        end;
      2:
        begin
          x1 := data[i];
          x2 := data[i + 1];

          tempResult.Append(Alphabet[x1 or ((x2 and $03) shl 8)]);
          tempResult.Append(Alphabet[x2 shr 2]);
          tempResult.Append(Special, 3);

        end;
      3:
        begin
          x1 := data[i];
          x2 := data[i + 1];
          x3 := data[i + 2];

          tempResult.Append(Alphabet[x1 or ((x2 and $03) shl 8)]);
          tempResult.Append(Alphabet[(x2 shr 2) or ((x3 and $0F) shl 6)]);
          tempResult.Append(Alphabet[x3 shr 4]);
          tempResult.Append(Special, 2);

        end;
      4:
        begin
          x1 := data[i];
          x2 := data[i + 1];
          x3 := data[i + 2];
          x4 := data[i + 3];

          tempResult.Append(Alphabet[x1 or ((x2 and $03) shl 8)]);
          tempResult.Append(Alphabet[(x2 shr 2) or ((x3 and $0F) shl 6)]);
          tempResult.Append(Alphabet[(x3 shr 4) or ((x4 and $3F) shl 4)]);
          tempResult.Append(Alphabet[x4 shr 6]);
          tempResult.Append(Special);

        end;

    end;

    result := tempResult.ToString;

  finally
    tempResult.Free;
  end;
end;

function TBase1024.Decode(const data: String): TArray<Byte>;
var
  lastSpecialInd, tailLength, i, srcInd, x1, x2, x3, x4, length5: Integer;

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
  SetLength(result, Length(data) div 4 * 5 - tailLength);
  i := 0;
  srcInd := 0;
  length5 := (Length(data) div 4 - 1) * 5;
  while i < length5 do
  begin
    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x3 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x4 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);

    result[i] := Byte(x1);
    result[i + 1] := Byte((x1 shr 8) and $03 or (x2 shl 2));
    result[i + 2] := Byte((x2 shr 6) and $0F or (x3 shl 4));
    result[i + 3] := Byte((x3 shr 4) and $3F or (x4 shl 6));
    result[i + 4] := Byte(x4 shr 2);
    inc(i, 5);
  end;

  if (tailLength = 0) then
  begin
    x1 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x2 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x3 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);
    x4 := FInvAlphabet[Ord(data[srcInd])];
    inc(srcInd);

    result[i] := Byte(x1);
    result[i + 1] := Byte((x1 shr 8) and $03 or (x2 shl 2));
    result[i + 2] := Byte((x2 shr 6) and $0F or (x3 shl 4));
    result[i + 3] := Byte((x3 shr 4) and $3F or (x4 shl 6));
    result[i + 4] := Byte(x4 shr 2);
  end;

  Case (tailLength) of
    4:
      begin

        x1 := FInvAlphabet[Ord(data[srcInd])];
        result[i] := Byte(x1);
      end;
    3:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];

        result[i] := Byte(x1);
        result[i + 1] := Byte((x1 shr 8) and $03 or (x2 shl 2));

      end;
    2:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x3 := FInvAlphabet[Ord(data[srcInd])];

        result[i] := Byte(x1);
        result[i + 1] := Byte((x1 shr 8) and $03 or (x2 shl 2));
        result[i + 2] := Byte((x2 shr 6) and $0F or (x3 shl 4));
      end;
    1:
      begin
        x1 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x2 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x3 := FInvAlphabet[Ord(data[srcInd])];
        inc(srcInd);
        x4 := FInvAlphabet[Ord(data[srcInd])];

        result[i] := Byte(x1);
        result[i + 1] := Byte((x1 shr 8) and $03 or (x2 shl 2));
        result[i + 2] := Byte((x2 shr 6) and $0F or (x3 shl 4));
        result[i + 3] := Byte((x3 shr 4) and $3F or (x4 shl 6));
      end;

  end;

end;

end.
