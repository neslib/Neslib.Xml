unit Test.OXmlPDOM;

interface

uses
  OXmlPDOM,
  Test.Base;

type
  TPerfTestOXmlPDOM = class(TPerfTest)
  private
    FDocument: IXmlDocument;
  private
    procedure Traverse(const ANode: PXmlNode);
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
  OXmlUtils;

{ TPerfTestOXmlPDOM }

procedure TPerfTestOXmlPDOM.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestOXmlPDOM.LoadDocument(const AFilename: String);
begin
  FDocument := CreateXMLDoc;
  FDocument.WhiteSpaceHandling := wsTrim;
  FDocument.LoadFromFile(AFilename);
end;

function TPerfTestOXmlPDOM.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.DocumentElement;
  var Dataset := Datasets.FirstChild;
  while (Dataset <> nil) do
  begin
    var TableHead, Fields, Field, Units: PXMLNode;
    if (Dataset.FindChild('tableHead', TableHead))
      and (TableHead.FindChild('fields', Fields))
      and (Fields.FindChild('field', Field))
      and (Field.FindChild('units', Units)) then
    begin
      var Text := Units.FirstChild;
      if (Text <> nil) and (Text.NodeType = ntText) and (Text.Text = 'arcsec') then
        Inc(Result);
    end;
    Dataset := Dataset.NextSibling;
  end;
end;

class function TPerfTestOXmlPDOM.Title: String;
begin
  Result := 'OXml (record-based)';
end;

procedure TPerfTestOXmlPDOM.Traverse(const ANode: PXmlNode);
begin
  var Attr := ANode.FirstAttribute;
  while (Attr <> nil) do
  begin
    MarkAttribute(Attr.NodeName, Attr.NodeValue);
    Attr := Attr.NextSibling;
  end;

  var Child := ANode.FirstChild;
  while (Child <> nil) do
  begin
    case Child.NodeType of
      ntElement:
        begin
          MarkElement(Child.NodeName);
          Traverse(Child);
        end;

      ntText:
        MarkText(Child.Text);
    end;
    Child := Child.NextSibling;
  end;
end;

procedure TPerfTestOXmlPDOM.TraverseDocument;
begin
  Traverse(FDocument.Node);
end;

end.
