unit Test.VerySimpleXml;

interface

uses
  Xml.VerySimple,
  Test.Base;

type
  TPerfTestVerySimpleXml = class(TPerfTest)
  private
    FDocument: TXmlVerySimple;
  private
    procedure Traverse(const ANode: TXmlNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TPerfTestVerySimpleXml }

destructor TPerfTestVerySimpleXml.Destroy;
begin
  FDocument.Free;
  inherited;
end;

procedure TPerfTestVerySimpleXml.FreeDocument;
begin
  FDocument.Free;
  FDocument := nil;
end;

procedure TPerfTestVerySimpleXml.LoadDocument(const AFilename: String);
begin
  FDocument := TXmlVerySimple.Create;
  FDocument.Options := FDocument.Options - [doSimplifyTextNodes];  // do not simplify text nodes
  FDocument.LoadFromFile(AFilename);
end;

function TPerfTestVerySimpleXml.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Dataset := FDocument.Root.SelectNode('/datasets/dataset');

  while (Dataset <> nil) do
  begin
    var TableHead := Dataset.Find('tableHead');
    if Assigned(TableHead) then
    begin
      var Fields := Tablehead.Find('fields');
      if Assigned(Fields) then
      begin
        var Field := Fields.Find('field');
        if Assigned(Field) then
        begin
          var Units := Field.Find('units');
          if Assigned(Units) then
          begin
            var Text := Units.FirstChild;
            if (Text.NodeType = TXmlNodeType.ntText) and (Text.Text = 'arcsec') then
              Inc(Result);
          end;
        end;
      end;
    end;

    // You could use the simple XPath SelectNode function as well (albeit way slower)
    {var Units := Dataset.SelectNode('tableHead/fields/field/units');
    if Assigned(Units) then
    begin
      var Text := Units.FirstChild;
      if (Text.NodeType = TXmlNodeType.ntText) and (Text.Text = 'arcsec') then
        Inc(Result);
    end;}

    Dataset := Dataset.NextSibling;
  end;
end;

procedure TPerfTestVerySimpleXml.Traverse(const ANode: TXmlNode);
begin
  for var Attr in ANode.AttributeList do
    MarkAttribute(Attr.Name, Attr.Value);

  for var Child in ANode.ChildNodes do
    case Child.NodeType of
      ntElement:
        begin
          MarkElement(Child.NodeName);
          Traverse(Child);
        end;

      ntText:
        MarkText(Child.Text);
    end;
end;

procedure TPerfTestVerySimpleXml.TraverseDocument;
begin
  Traverse(FDocument.Root);
end;

end.
