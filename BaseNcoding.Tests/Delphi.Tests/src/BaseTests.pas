unit BaseTests;

interface

uses
  Classes,
  SysUtils,
  uIBaseInterfaces;

type

  TBaseNcodingTests = class
  public
    class var

      FConverter: IBase;

    /// <summary>
    /// Sample from http://en.wikipedia.org/wiki/Base64#Examples
    /// </summary>
  const

    SArray: array [0 .. 2] of string =
      ('Man is distinguished, not only by his reason, but by this singular passion from '

      + 'other animals, which is a lust of the mind, that by a perseverance of delight '
      + 'in the continued and indefatigable generation of knowledge, exceeds the short '
      + 'vehemence of any carnal pleasure.',
      'Зарегистрируйтесь сейчас на Десятую Международную Конференцию по ' +
      'Unicode, которая состоится 10-12 марта 1997 года в Майнце в Германии. ' +
      'Конференция соберет широкий круг экспертов по вопросам глобального ' +
      'Интернета и Unicode, локализации и интернационализации, воплощению и ' +
      'применению Unicode в различных операционных системах и программных ' +
      'приложениях, шрифтах, верстке и многоязычных компьютерных системах.',
      'Σὲ γνωρίζω ἀπὸ τὴν κόψη τοῦ σπαθιοῦ τὴν τρομερή, ' +
      'σὲ γνωρίζω ἀπὸ τὴν ὄψη ποὺ μὲ βία μετράει τὴ γῆ. ' +
      '᾿Απ᾿ τὰ κόκκαλα βγαλμένη τῶν ῾Ελλήνων τὰ ἱερά ' +
      'καὶ σὰν πρῶτα ἀνδρειωμένη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!');

  public
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

constructor TBaseNcodingTests.Create();
begin
  inherited Create();
end;

destructor TBaseNcodingTests.Destroy();
begin
  inherited Destroy;
end;

end.
