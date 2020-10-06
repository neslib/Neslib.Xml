unit Test.Delphi;

interface

uses
  Xml.XmlDoc,
  Xml.XmlDom,
  Xml.XmlIntf,
  Test.Base;

type
  TPerfTestDelphi = class(TPerfTest)
  private
    FDocument: IXMLDocument;
  private
    procedure Traverse(const ANode: IXMLNode);
  protected
    procedure LoadDocument(const AFilename: String); override;
    procedure TraverseDocument; override;
    function QueryArcsecFields: Integer; override;
    procedure FreeDocument; override;
  public
    class function Title: String; override;
  end;

implementation

{ TPerfTestDelphi }

procedure TPerfTestDelphi.FreeDocument;
begin
  FDocument := nil;
end;

procedure TPerfTestDelphi.LoadDocument(const AFilename: String);
begin
  FDocument := TXMLDocument.Create(nil);
  FDocument.LoadFromFile(AFilename);
end;

function TPerfTestDelphi.QueryArcsecFields: Integer;
begin
  Result := 0;
  var Datasets := FDocument.Node.ChildNodes[0];
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

class function TPerfTestDelphi.Title: String;
begin
  Result := 'Delphi (Default)';
end;

procedure TPerfTestDelphi.Traverse(const ANode: IXMLNode);
begin
  for var I := 0 to ANode.AttributeNodes.Count - 1 do
  begin
    var Attr := ANode.AttributeNodes[I];
    MarkAttribute(Attr.NodeName, Attr.NodeValue);
  end;

  if (ANode.HasChildNodes) then
  begin
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
end;

procedure TPerfTestDelphi.TraverseDocument;
begin
  Traverse(FDocument.Node);
end;

end.
