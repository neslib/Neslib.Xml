unit Test.SimpleXml;

interface

uses
  SimpleXML,
  Test.Base;

type
  TPerfTestSimpleXML = class(TPerfTest)
  private
    FDocument: IXmlDocument;
  private
    procedure Traverse(const ANode: IXmlNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  end;

implementation

{ TPerfTestSimpleXML }

procedure TPerfTestSimpleXML.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestSimpleXML.LoadDocument(const AFilename: String);
begin
  FDocument := CreateXmlDocument;
  FDocument.Load(AFilename);
end;

function TPerfTestSimpleXML.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.ChildNodes[0];
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
                  if (Units.NodeName = 'units') then
                  begin
                    var Text := Units.ChildNodes[0];
                    if (Text.NodeType = NODE_TEXT) and (Text.Text = 'arcsec') then
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

procedure TPerfTestSimpleXML.Traverse(const ANode: IXmlNode);
begin
  for var I := 0 to ANode.AttrCount - 1 do
    MarkAttribute(ANode.AttrNames[I], ANode.GetAttr(ANode.AttrNameIDs[I]));

  if (ANode.ChildNodes <> nil) then
  begin
    for var I := 0 to ANode.ChildNodes.Count - 1 do
    begin
      var Child := ANode.ChildNodes[I];
      case Child.NodeType of
        NODE_ELEMENT:
          begin
            MarkElement(Child.NodeName);
            Traverse(Child);
          end;

        NODE_TEXT:
          MarkText(Child.Text);
      end;
    end;
  end;
end;

procedure TPerfTestSimpleXML.TraverseDocument;
begin
  Traverse(FDocument);
end;

end.
