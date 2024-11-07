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
  // ���������, ������� �� �������� � ������ �����
  if ParamCount = 0 then
  begin
    Writeln('������� ��� ���������� ����� � �������� ���������.');
    Exit;
  end;

  FileName := ParamStr(1);
  Lines := TStringList.Create;

  try
    // �������� ��������� ���� � ������ �����
    Lines.LoadFromFile(FileName);
    var Strings := Lines.ToStringArray;
    Writeln('���� ������� ��������. ���������� �����:');

    // ������� ������ ������ �� �����
    for i := 0 to Lines.Count - 1 do
      Writeln(Strings[i]);

    TestParser(Strings);
    ReadLn;
  except
    on E: Exception do
      Writeln('������ ��� �������� �����: ', E.Message);
  end;

  Lines.Free;
end.

