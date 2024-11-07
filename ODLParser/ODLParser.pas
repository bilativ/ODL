unit ODLParser;

interface

type

  TWriteLn=reference to procedure(const s: string);

  TODLParser=class;
  TGetString=reference to function(i: integer): string;

  TPageArray<T>=record
  public type
    PType=^T;
  private type
    TPage=TArray<T>;
  private
    fPages: TArray<TPage>;
    fFreeItems: array of integer;
    fPageCapacity: integer;
    fCount: integer;
  private
    function GetCount: integer;
    function GetPItem(i: integer): PType;
    function GetItem(i: integer): T;
    procedure SetItem(i: integer; const Value: T);
    function GetIsFree(i: integer): boolean;
    function GetFreeCount: integer;
    function GetMemCount: integer;
  public
    constructor Create(PageCapacity: integer);
    property Count: integer read GetCount;
    property FreeCount: integer read GetFreeCount;
    property MemCount: integer read GetMemCount;
    procedure Clear;
    property PItem[i: integer]: PType read GetPItem; default;
    property Item[i: integer]: T read GetItem write SetItem;
    property IsFree[i: integer]: boolean read GetIsFree;
    function GetNew: PType;
    function Add(const item: T):integer;
    procedure Delete(i: integer);
  end;

  PODLNode=^TODLNode;
  TODLNode=record
  private
    fName: integer;
    fValue: string;
    iFile: integer;
    iLine: integer;
    fOwner: TODLParser;
    fRefCount: integer;
    function GetFullTypeName: string;
    function GetName: string;
    function GetTypeName: string;
    function GetFileName: string;
  public
    Child, Parent, Sibling: PODLNode;
    TypeParent, TypeChild, TypeSibling: PODLNode;
    property Owner: TODLParser read fOwner;
    constructor Create(const Owner: TODLParser; const Name: string);
    property Name: string read GetName;
    property TypeName: string read GetTypeName;
    property FullTypeName: string read GetFullTypeName;
    property RawValue: string read fValue;
    property FileName: string read GetFileName;
    property LineNumber: integer read iLine;
    procedure OutToText(const WriteLn: TWriteLn);
  end;

  TODLWord=record
  private
    Hash: int64;
    RefCount: integer;
  public
    Text: string;
    constructor Create(const Text: string);
  end;

  TODLFile=class
  private
    function GetDefCount: integer;
  protected
    id: integer;
    fFileName: string;
    fRootNodes:TArray<PODLNode>;
    fOwner: TODLParser;
    fGetString: TGetString;
    fStringCount: integer;
    function GetNodeCount: integer;
    function GetNode(i: integer): PODLNode;
    function GetLine(i: integer): string;
  public
    constructor Create(const Name: string; StringCount: integer; GetString: TGetString);
    procedure Clear;
    property FileName: string read fFileName write fFileName;
    property LineCount: integer read fStringCount;
    property Line[i: integer]: string read GetLine;
    property GetString: TGetString read fGetString;
    procedure Update(NewCount: integer; NewString: TGetString);
    procedure UpdateRange(si, ti: integer; NewCount: integer; GetString: TGetString);
    property NodeCount: integer read GetDefCount;
    property Node[i: integer]: PODLNode read GetNode;
    procedure Refresh;
  end;

  TODLWords=class
  protected
    fWords: TPageArray<TODLWord>;
  protected
    function GetCount: integer;
    function GetWordCount: integer;
    function GetWord(i: integer): TODLWord;
    function SearchInsertWord(const word: string): integer;
  public
    constructor Create;
    property Index[const word: string]: integer read SearchInsertWord;
    procedure DeleteWord(const word: string);
    property Count: integer read GetCount;
    property Word[i: integer]: TODLWord read GetWord; default;

  end;


//  TODLProp=record
//  private
//    fNode: PODLNode;
//    function PropByName(const path: string): TODLProp; overload;
//    function PropByIndex(i: integer): TODLProp; overload;
//    function GetIsNull: boolean;
//    function GetFullTypeName: string;
//    function GetName: string;
//    function GetPropByName(const path: string): TODLProp;
//    function GetPropCount: integer;
//    function GetRawValue: string;
//    function GetTypeName: string;
//  public
//    property Count: integer read GetPropCount;
//    property Prop[const path: string]: TODLProp read GetPropByName; default;
//    property Prop[i: integer]: TODLProp read GetPropByIndex; default;
//    property Name: string read GetName;
//    property RawValue: string read GetRawValue;
//    property TypeName: string read GetTypeName;
//    property FullTypeName: string read GetFullTypeName;
//    function AsInteger: integer;
//    function AsBoolean: boolean;
//    function AsDouble: double;
//    function ToString: string;
//    property IsNull: boolean read GetIsNull;
//    class operator implicit(const prop: TODLProp): double;
//    class operator implicit(const prop: TODLProp): string;
//    class operator implicit(const prop: TODLProp): integer;
//    class operator implicit(const prop: TODLProp): boolean;
//    class operator explicit(const def: string): TODLProp;
//    class operator Equal(const prop: TODLProp; const name: string): boolean;
//  end;

  TODLNodeArray = TPageArray<TODLNode>;

  TODLParser=class
  private
    function GetFile(i: integer): TODLFile;
    function GetFileCount: integer;
    function GetWord(i: integer): TODLWord;
    function GetWordCount: integer;
  protected
    fWords: TODLWords;
    fFiles: TArray<TODLFile>;
    fNodes: TODLNodeArray;
    fRootNode: PODLNode;
    function NewNode: PODLNode;
    procedure FreeNode(nd: PODLNode);
    property WordCount: integer read GetWordCount;
    property Word[i: integer]: TODLWord read GetWord;
  public
    constructor Create;
    procedure Clear;
    property FileCount: integer read GetFileCount;
    property Words: TODLWords read fWords;
    function AddFile(const Name: string; StringCount: integer; GetString: TGetString): TODLFile;
    property ODLFile[i: integer]: TODLFile read GetFile;
    procedure DeleteFile(i: integer);
    property RootNode: PODLNode read fRootNode;
    procedure Refresh;
    procedure OutToText(const WriteLn: TWriteLn);
    //property RootProp: TODLProp read GetRootProp;
  end;

implementation

{ TODLNode }

constructor TODLNode.Create(const Owner: TODLParser; const Name: string);
begin
  fOwner := Owner;
  fName := Owner.words.SearchInsertWord(Name);
end;

function TODLNode.GetFileName: string;
begin

end;

function TODLNode.GetFullTypeName: string;
begin

end;

function TODLNode.GetName: string;
begin
  result := Owner.Words.GetWord(fName).text;
end;

function TODLNode.GetTypeName: string;
begin

end;

procedure TODLNode.OutToText(const WriteLn: TWriteLn);
begin
  WriteLn('TODLNode');
    WriteLn(' Name:'+self.Name);
    WriteLn(' Value:'+self.RawValue);
  if Parent<>nil then
    WriteLn('  Parent:'+Parent.Name);
  if Child<>nil then
    WriteLn('  Child:'+Child.Name);
  if Sibling<>nil then
    WriteLn('  Sibling:'+Sibling.Name);
  if TypeParent<>nil then
    WriteLn('  Parent:'+TypeParent.Name);
  if TypeChild<>nil then
    WriteLn('  Child:'+TypeChild.Name);
  if TypeSibling<>nil then
    WriteLn('  Sibling:'+TypeSibling.Name);
end;

{ TODLFile }

procedure TODLFile.Clear;
begin

end;

constructor TODLFile.Create(const Name: string; StringCount: integer;
  GetString: TGetString);
begin
  fFileName := Name;
  fStringCount := StringCount;
  fGetString := GetString;
end;

function TODLFile.GetDefCount: integer;
begin

end;

function TODLFile.GetLine(i: integer): string;
begin
  result := fGetString(i);
end;

function TODLFile.GetNode(i: integer): PODLNode;
begin

end;

function TODLFile.GetNodeCount: integer;
begin

end;

procedure TODLFile.Refresh;
begin

end;

procedure TODLFile.Update(NewCount: integer; NewString: TGetString);
begin

end;

procedure TODLFile.UpdateRange(si, ti, NewCount: integer;
  GetString: TGetString);
begin

end;

{ TODLParser }

function TODLParser.AddFile(const Name: string; StringCount: integer;
  GetString: TGetString): TODLFile;
begin
  result := TODLFile.Create(Name, StringCount, GetString);
  result.fOwner := self;
  fFiles := fFiles+[result];
end;

procedure TODLParser.Clear;
begin

end;

constructor TODLParser.Create;
begin
  fWords := TODLWords.Create;
  fNodes := TODLNodeArray.Create(100);
  fNodes.Add(TODLNode.Create(self, '$RootNode'));
end;

procedure TODLParser.DeleteFile(i: integer);
begin

end;

procedure TODLParser.FreeNode(nd: PODLNode);
begin

end;

function TODLParser.GetFile(i: integer): TODLFile;
begin

end;

function TODLParser.GetFileCount: integer;
begin

end;

function TODLParser.GetWord(i: integer): TODLWord;
begin
  result := fWords.Word[i];
end;

function TODLParser.GetWordCount: integer;
begin

end;

function TODLParser.NewNode: PODLNode;
begin
  result := PODLNode(fNodes.GetNew);
end;

procedure TODLParser.OutToText(const WriteLn: TWriteLn);
begin
  WriteLn(self.ClassName+'.OutToText');
  for var i := 0 to fNodes.Count-1 do begin
    if fNodes[i]<>nil then
      fNodes[i].OutToText(WriteLn);
    WriteLn('');
  end;
  WriteLn('Not Implemented!');
end;

procedure TODLParser.Refresh;
begin
  for var i := 0 to high(fFiles) do begin
    fFiles[i].Refresh;
  end;
end;

{ TODLWords }

function TODLWords.SearchInsertWord(const word: string): integer;
begin
  result := fWords.Add(TODLWord.Create(word));
end;

constructor TODLWords.Create;
begin
  fWords := TPageArray<TODLWord>.Create(100);
end;

procedure TODLWords.DeleteWord(const word: string);
begin

end;

function TODLWords.GetCount: integer;
begin

end;

function TODLWords.GetWord(i: integer): TODLWord;
begin
  result := fWords.Item[i];
end;

function TODLWords.GetWordCount: integer;
begin

end;

{ TPageArray<T> }

function TPageArray<T>.Add(const item: T): integer;
begin
  var PageIndex := fCount mod Length(fPages);
  var ItemIndex := fCount-PageIndex*fPageCapacity;
  if PageIndex>High(fPages) then
    SetLength(fPages, Length(fPages)+1);
  fPages[PageIndex][ItemIndex] := item;
  result := fCount;
  inc(fCount);
end;

procedure TPageArray<T>.Clear;
begin
  fCount := 0;
  SetLength(fPages, 1);
end;

constructor TPageArray<T>.Create(PageCapacity: integer);
begin
  fpageCapacity := PageCapacity;
  SetLength(fPages, 1);
  SetLength(fPages[0], fPageCapacity);
end;

procedure TPageArray<T>.Delete(i: integer);
begin

end;

function TPageArray<T>.GetCount: integer;
begin
  result := fCount;
end;

function TPageArray<T>.GetFreeCount: integer;
begin

end;

function TPageArray<T>.GetIsFree(i: integer): boolean;
begin

end;

function TPageArray<T>.GetItem(i: integer): T;
begin
  var pi := PItem[i];
  if pi<>nil then
    result := pi^;
end;

function TPageArray<T>.GetMemCount: integer;
begin

end;

function TPageArray<T>.GetNew: PType;
begin
  var i := self.Add(Default(T));
  result := self[i];
end;

function TPageArray<T>.GetPItem(i: integer): PType;
begin
  result := nil;
  if (i>=0) and (i<fCount) then begin
    var PageIndex := i mod Length(fPages);
    var ItemIndex := i-PageIndex*fPageCapacity;
    result := @fPages[PageIndex][ItemIndex];
  end;
end;

procedure TPageArray<T>.SetItem(i: integer; const Value: T);
begin
  var pi := self[i];
  if pi<>nil then
    pi^ := Value;
end;

{ TODLProp }
//
//function TODLProp.AsBoolean: boolean;
//begin
//
//end;
//
//function TODLProp.AsDouble: double;
//begin
//
//end;
//
//function TODLProp.AsInteger: integer;
//begin
//
//end;
//
//class operator TODLProp.Equal(const prop: TODLProp;
//  const name: string): boolean;
//begin
//
//end;
//
//class operator TODLProp.explicit(const def: string): TODLProp;
//begin
//
//end;
//
//function TODLProp.GetFullTypeName: string;
//begin
//
//end;
//
//function TODLProp.GetIsNull: boolean;
//begin
//
//end;
//
//function TODLProp.GetName: string;
//begin
//
//end;
//
//function TODLProp.GetPropByName(const path: string): TODLProp;
//begin
//
//end;
//
//function TODLProp.GetPropCount: integer;
//begin
//
//end;
//
//function TODLProp.GetRawValue: string;
//begin
//
//end;
//
//function TODLProp.GetTypeName: string;
//begin
//
//end;
//
//class operator TODLProp.implicit(const prop: TODLProp): double;
//begin
//
//end;
//
//class operator TODLProp.implicit(const prop: TODLProp): boolean;
//begin
//
//end;
//
//class operator TODLProp.implicit(const prop: TODLProp): integer;
//begin
//
//end;
//
//class operator TODLProp.implicit(const prop: TODLProp): string;
//begin
//
//end;
//
//function TODLProp.PropByIndex(i: integer): TODLProp;
//begin
//
//end;
//
//function TODLProp.PropByName(const path: string): TODLProp;
//begin
//
//end;
//
//function TODLProp.ToString: string;
//begin
//
//end;

{ TODLWord }

constructor TODLWord.Create(const Text: string);
begin
  self.Text := Text;
end;

end.
