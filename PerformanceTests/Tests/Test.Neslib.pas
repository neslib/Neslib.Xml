unit Test.Neslib;

interface

uses
  Neslib.Xml,
  Test.Base;

type
  TPerfTestNeslib = class(TPerfTest)
  private
    FDocument: IXmlDocument;
  private
    procedure Traverse(const ANode: TXmlNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  public
    class function Title: String; override;
  end;

implementation

uses
  Neslib.Xml.Types;

{ TPerfTestNeslib }

procedure TPerfTestNeslib.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestNeslib.LoadDocument(const AFilename: String);
begin
  FDocument := TXmlDocument.Create;
  FDocument.Load(AFilename);
end;

function TPerfTestNeslib.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.DocumentElement;
  var Dataset := Datasets.FirstChild;
  while (Dataset <> nil) do
  begin
    var Units := Dataset.ElementByName('tableHead')
                        .ElementByName('fields')
                        .ElementByName('field')
                        .ElementByName('units');
    var Text := Units.FirstChild;
    if (Text.NodeType = TXmlNodeType.Text) and (Text.Value = 'arcsec') then
      Inc(Result);
    Dataset := Dataset.NextSibling;
  end;
end;

class function TPerfTestNeslib.Title: String;
begin
  {$IFDEF XML_UTF8}
  Result := 'Neslib (UTF-8 mode)';
  {$ELSE}
  Result := 'Neslib (Unicode mode)';
  {$ENDIF}
end;

procedure TPerfTestNeslib.Traverse(const ANode: TXmlNode);
begin
  var Attr := ANode.FirstAttribute;
  while (Attr <> nil) do
  begin
    MarkAttribute(Attr.Name, Attr.Value);

    Attr := Attr.Next;
  end;

  var Child := ANode.FirstChild;
  while (Child <> nil) do
  begin
    case Child.NodeType of
      TXmlNodeType.Element:
        begin
          MarkElement(Child.Value);
          Traverse(Child);
        end;

      TXmlNodeType.Text:
        MarkText(Child.Value);
    end;
    Child := Child.NextSibling;
  end;
end;

procedure TPerfTestNeslib.TraverseDocument;
begin
  Traverse(FDocument.Root);
end;

end.
