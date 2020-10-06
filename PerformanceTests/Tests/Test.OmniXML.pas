unit Test.OmniXML;

interface

uses
  OmniXML,
  Test.Base;

type
  TPerfTestOmniXML = class(TPerfTest)
  private
    FDocument: IXMLDocument;
  private
    procedure Traverse(const ANode: IXMLNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  end;

implementation

{ TPerfTestOmniXML }

procedure TPerfTestOmniXML.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestOmniXML.LoadDocument(const AFilename: String);
begin
  FDocument := CreateXMLDoc;
  FDocument.PreserveWhiteSpace := False;
  FDocument.Load(AFilename);
end;

function TPerfTestOmniXML.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.ChildNodes.Item[0];
  for var I := 0 to Datasets.ChildNodes.Length - 1 do
  begin
    var Dataset := Datasets.ChildNodes.Item[I];
    for var J := 0 to Dataset.ChildNodes.Length - 1 do
    begin
      var TableHead := Dataset.ChildNodes.Item[J];
      if (TableHead.NodeName = 'tableHead') then
      begin
        for var K := 0 to TableHead.ChildNodes.Length - 1 do
        begin
          var Fields := TableHead.ChildNodes.Item[K];
          if (Fields.NodeName = 'fields') then
          begin
            for var L := 0 to Fields.ChildNodes.Length - 1 do
            begin
              var Field := Fields.ChildNodes.Item[L];
              if (Field.NodeName = 'field') then
              begin
                for var M := 0 to Field.ChildNodes.Length - 1 do
                begin
                  var Units := Field.ChildNodes.Item[M];
                  if (Units.NodeName = 'units') then
                  begin
                    var Text := Units.ChildNodes.Item[0];
                    if (Text.NodeType = TEXT_NODE) and (Text.Text = 'arcsec') then
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

procedure TPerfTestOmniXML.Traverse(const ANode: IXMLNode);
begin
  if (ANode.Attributes <> nil) then
  begin
    for var I := 0 to ANode.Attributes.Length - 1 do
    begin
      var Attr := ANode.Attributes.Item[I];
      MarkAttribute(Attr.NodeName, Attr.NodeValue);
    end;
  end;

  if (ANode.HasChildNodes) then
  begin
    for var I := 0 to ANode.ChildNodes.Length - 1 do
    begin
      var Child := Anode.ChildNodes.Item[I];
      case Child.nodeType of
        ELEMENT_NODE:
          begin
            MarkElement(Child.NodeName);
            Traverse(Child);
          end;

        TEXT_NODE:
          MarkText(Child.Text);
      end;
    end;
  end;
end;

procedure TPerfTestOmniXML.TraverseDocument;
begin
  Traverse(FDocument);
end;

end.
