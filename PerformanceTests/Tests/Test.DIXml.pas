unit Test.DIXml;

interface

uses
  DIXml,
  Test.Base;

type
  TPerfTestDIXml = class(TPerfTest)
  private
    FDocument: xmlDocPtr;
  private
    procedure Traverse(const ANode: xmlNodePtr);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  end;

implementation

{ TPerfTestDIXml }

procedure TPerfTestDIXml.FreeDocument;
begin
  if (FDocument <> nil) then
  begin
    xmlFreeDoc(FDocument);
    FDocument := nil;
  end;
  xmlCleanupParser;
end;

procedure TPerfTestDIXml.LoadDocument(const AFilename: String);
begin
  xmlInitParser;
  FDocument := xmlReadFile(PAnsiChar(UTF8String(AFilename)), nil, XML_PARSE_NOBLANKS);
end;

function TPerfTestDIXml.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.Children;
  var Dataset := Datasets.Children;
  while (Dataset <> nil) do
  begin
    var TableHead := Dataset.Children;
    while (TableHead <> nil) do
    begin
      if (TableHead.Name = 'tableHead') then
      begin
        var Fields := TableHead.Children;
        while (Fields <> nil) do
        begin
          if (Fields.Name = 'fields') then
          begin
            var Field := Fields.Children;
            while (Field <> nil) do
            begin
              if (Field.Name = 'field') then
              begin
                var Units := Field.Children;
                while (Units <> nil) do
                begin
                  if (Units.Name = 'units') then
                  begin
                    var Text := Units.Children;
                    if (Text <> nil) and (Text.Type_ = XML_TEXT_NODE) and (Text.Content = 'arcsec') then
                      Inc(Result);
                    Break;
                  end;
                  Units := Units.Next;
                end;
                Break;
              end;
              Field := Field.Next;
            end;
            Break;
          end;
          Fields := Fields.Next;
        end;
        Break;
      end;
      TableHead := TableHead.Next;
    end;
    Dataset := Dataset.Next;
  end;
end;

procedure TPerfTestDIXml.Traverse(const ANode: xmlNodePtr);
begin
  var Attr := ANode.Properties;
  while (Attr <> nil) do
  begin
    var AttrValue := xmlGetProp(ANode, Attr.Name);
    MarkAttribute(UTF8String(Attr.Name), UTF8String(AttrValue));
    FreeMem(AttrValue);
    Attr := Attr.Next;
  end;

  var Child := ANode.Children;
  while (Child <> nil) do
  begin
    case Child.Type_ of
      XML_ELEMENT_NODE:
        begin
          MarkElement(UTF8String(Child.Name));
          Traverse(Child);
        end;

      XML_TEXT_NODE:
        MarkText(UTF8String(Child.Content));
    end;
    Child := Child.Next;
  end;
end;

procedure TPerfTestDIXml.TraverseDocument;
begin
  { DIXml does not expose document root, so mark it manually. }
  MarkElement('');
  Traverse(xmlDocGetRootElement(FDocument));
end;

end.
