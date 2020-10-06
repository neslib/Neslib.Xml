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
  FDocument.PreserveWhitespace := True;
  FDocument.LoadFromFile(AFilename);
end;

function TPerfTestVerySimpleXml.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.DocumentElement;
  for var I := 0 to Datasets.ChildNodes.Count - 1 do
  begin
    var Dataset := Datasets.ChildNodes[I];
    for var J := 0 to Dataset.ChildNodes.Count - 1 do
    begin
      var TableHead := Dataset.ChildNodes[J];
      if (TableHead.NodeName = 'tableHead') then
      begin
        for var K := 0 to TableHead.ChildNodes.Count - 1 do
        begin
          var Fields := TableHead.ChildNodes[K];
          if (Fields.NodeName = 'fields') then
          begin
            for var L := 0 to Fields.ChildNodes.Count - 1 do
            begin
              var Field := Fields.ChildNodes[L];
              if (Field.NodeName = 'field') then
              begin
                for var M := 0 to Field.ChildNodes.Count - 1 do
                begin
                  var Units := Field.ChildNodes[M];
                  if (Units.NodeName = 'units') and (Units.ChildNodes.Count > 0) then
                  begin
                    var Text := Units.ChildNodes[0];
                    if (Text.NodeType = ntText) and (Text.Text = 'arcsec') then
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

procedure TPerfTestVerySimpleXml.Traverse(const ANode: TXmlNode);
begin
  for var I := 0 to ANode.AttributeList.Count - 1 do
  begin
    var Attr := ANode.AttributeList[I];
    MarkAttribute(Attr.Name, Attr.Value);
  end;

  for var I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    var Child := ANode.ChildNodes[I];
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
end;

procedure TPerfTestVerySimpleXml.TraverseDocument;
begin
  MarkElement(''); { VerySimpleXml doesn't expose the root. So mark it manually. }
  Traverse(FDocument.DocumentElement);
end;

end.
