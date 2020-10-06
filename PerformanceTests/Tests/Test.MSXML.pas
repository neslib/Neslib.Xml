unit Test.MSXML;

interface

uses
  Winapi.MSXML,
  Xml.Win.MSXMLDOM,
  Test.Base;

type
  TPerfTestMSXML = class(TPerfTest)
  private
    FDocument: IXMLDOMDocument;
  private
    procedure Traverse(const ANode: IXMLDOMNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  end;

implementation

{ TPerfTestMSXML }

procedure TPerfTestMSXML.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestMSXML.LoadDocument(const AFilename: String);
begin
  FDocument := MSXMLDOMDocumentFactory.CreateDOMDocument;
  FDocument.load(AFilename);
end;

function TPerfTestMSXML.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.childNodes[0];
  for var I := 0 to Datasets.childNodes.length - 1 do
  begin
    var Dataset := Datasets.childNodes[I];
    for var J := 0 to Dataset.childNodes.length - 1 do
    begin
      var TableHead := Dataset.childNodes[J];
      if (TableHead.nodeName = 'tableHead') then
      begin
        for var K := 0 to TableHead.childNodes.length - 1 do
        begin
          var Fields := TableHead.childNodes[K];
          if (Fields.nodeName = 'fields') then
          begin
            for var L := 0 to Fields.childNodes.length - 1 do
            begin
              var Field := Fields.childNodes[L];
              if (Field.nodeName = 'field') then
              begin
                for var M := 0 to Field.childNodes.length - 1 do
                begin
                  var Units := Field.childNodes[M];
                  if (Units.nodeName = 'units') then
                  begin
                    var Text := Units.childNodes[0];
                    if (Text.nodeType = NODE_TEXT) and (Text.text = 'arcsec') then
                      Inc(Result);

                    Break;
                  end;
                end;
                Break;
              end;
            end;
            Break;
          end;
        end;
        Break;
      end;
    end;
  end;
end;

procedure TPerfTestMSXML.Traverse(const ANode: IXMLDOMNode);
begin
  if (ANode.attributes <> nil) then
  begin
    for var I := 0 to ANode.attributes.length - 1 do
    begin
      var Attr := ANode.attributes[I];
      MarkAttribute(Attr.nodeName, Attr.nodeValue);
    end;
  end;

  if (ANode.hasChildNodes) then
  begin
    for var I := 0 to ANode.childNodes.length - 1 do
    begin
      var Child := Anode.childNodes[I];
      case Child.nodeType of
        NODE_ELEMENT:
          begin
            MarkElement(Child.nodeName);
            Traverse(Child);
          end;

        NODE_TEXT:
          MarkText(Child.text);
      end;
    end;
  end;
end;

procedure TPerfTestMSXML.TraverseDocument;
begin
  Traverse(FDocument);
end;

end.
