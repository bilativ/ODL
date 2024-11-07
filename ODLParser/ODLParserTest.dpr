program ODLParserTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Classes,
  ODLParser in 'ODLParser.pas';

var
  FileName: string;
  Lines: TStringList;
  i: Integer;

procedure TestParser(const Lines: TArray<string>);
begin
  var p := TODLParser.Create;
  p.AddFile('MyFile', Length(Lines),
    function(i: integer): string
    begin
      result := Lines[i];
    end);
  p.Refresh;
  p.OutToText(
    procedure(const s: string)
    begin
      WriteLn(s);
    end
  );
end;


begin
  // Проверяем, передан ли параметр с именем файла
  if ParamCount = 0 then
  begin
    Writeln('Укажите имя текстового файла в качестве параметра.');
    Exit;
  end;

  FileName := ParamStr(1);
  Lines := TStringList.Create;

  try
    // Пытаемся загрузить файл в массив строк
    Lines.LoadFromFile(FileName);
    var Strings := Lines.ToStringArray;
    Writeln('Файл успешно загружен. Содержимое файла:');

    // Выводим каждую строку на экран
    for i := 0 to Lines.Count - 1 do
      Writeln(Strings[i]);

    TestParser(Strings);
    ReadLn;
  except
    on E: Exception do
      Writeln('Ошибка при загрузке файла: ', E.Message);
  end;

  Lines.Free;
end.

