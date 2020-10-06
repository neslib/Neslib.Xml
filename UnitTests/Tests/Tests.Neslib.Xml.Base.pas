unit Tests.Neslib.Xml.Base;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Neslib.Xml,
  Neslib.Xml.Types;

type
  TBaseXmlTest = class
  protected
    class function LoadResource(const AName: String): TBytes; static;
  protected
    procedure CheckSampleDocument(const ADocument: IXmlDocument);
  end;

implementation

{$R Resources.res}

uses
  System.Types,
  System.Classes;

{ TBaseXmlTest }

procedure TBaseXmlTest.CheckSampleDocument(const ADocument: IXmlDocument);
begin
  Assert.IsNotNull(ADocument);

  { <root> }
  var Root := ADocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('root', Root.Value);

  {   <!--This is a comment.--> }
  var Node := Root.FirstChild;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Comment, Node.NodeType);
  Assert.AreEqual<XmlString>('This is a comment.', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Assert.IsTrue(Node.FirstChild = nil);

  {   <node1 /> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node1', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Assert.IsTrue(Node.FirstChild = nil);

  {   <node2></node2> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node2', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Assert.IsTrue(Node.FirstChild = nil);

  {   <node3 attr="value" /> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node3', Node.Value);
  Assert.IsTrue(Node.FirstChild = nil);
  var Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('attr', Attr.Name);
  Assert.AreEqual<XmlString>('value', Attr.Value);
  Attr := Attr.Next;
  Assert.IsTrue(Attr = nil);

  {   <node4  attr1 = "value1"   attr2='value2'/> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node4', Node.Value);
  Assert.IsTrue(Node.FirstChild = nil);
  Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('attr1', Attr.Name);
  Assert.AreEqual<XmlString>('value1', Attr.Value);
  Attr := Attr.Next;
  Assert.AreEqual<XmlString>('attr2', Attr.Name);
  Assert.AreEqual<XmlString>('value2', Attr.Value);
  Attr := Attr.Next;
  Assert.IsTrue(Attr = nil);

  { <node5 attr="value">Ampersand: &amp;, LT: &lt;, GT: &gt;, Quotes: &quot; and &apos;, Decimal: &#65;, Hex: &#x42;</node5> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node5', Node.Value);
  Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('attr', Attr.Name);
  Assert.AreEqual<XmlString>('value', Attr.Value);
  Attr := Attr.Next;
  Assert.IsTrue(Attr = nil);
  var Child := Node.FirstChild;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('Ampersand: &, LT: <, GT: >, Quotes: " and '', Decimal: A, Hex: B', Child.Value);
  Assert.IsTrue(Child.FirstChild = nil);
  Assert.IsTrue(Child.NextSibling = nil);

  { <node6>Text with <node6a somens:attr="value">embedded child node</node6a>.</node6> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('node6', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Child := Node.FirstChild;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('Text with ', Child.Value);
  Assert.IsTrue(Child.FirstChild = nil);
  Child := Child.NextSibling;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Child.NodeType);
  Assert.AreEqual<XmlString>('node6a', Child.Value);
  Attr := Child.FirstAttribute;
  Assert.AreEqual<XmlString>('somens:attr', Attr.Name);
  Assert.AreEqual<XmlString>('value', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);
  var GrandChild := Child.FirstChild;
  Assert.IsTrue(GrandChild.Parent = Child);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, GrandChild.NodeType);
  Assert.AreEqual<XmlString>('embedded child node', GrandChild.Value);
  Child := Child.NextSibling;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('.', Child.Value);
  Assert.IsTrue(Child.FirstChild = nil);

  { <somens:node7>Text with <![CDATA[embedded "CDATA"]]>.</somens:node7> }
  Node := Node.NextSibling;
  Assert.IsTrue(Node.Parent = Root);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Node.NodeType);
  Assert.AreEqual<XmlString>('somens:node7', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Child := Node.FirstChild;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('Text with ', Child.Value);
  Assert.IsTrue(Child.FirstChild = nil);
  Child := Child.NextSibling;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.CData, Child.NodeType);
  Assert.AreEqual<XmlString>('embedded "CDATA"', Child.Value);
  Child := Child.NextSibling;
  Assert.IsTrue(Child.Parent = Node);
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('.', Child.Value);
  Assert.IsTrue(Child.NextSibling = nil);

  Assert.IsTrue(Node.NextSibling = nil);
end;

class function TBaseXmlTest.LoadResource(const AName: String): TBytes;
begin
  var Stream := TResourceStream.Create(HInstance, AName, RT_RCDATA);
  try
    SetLength(Result, Stream.Size);
    Stream.ReadBuffer(Result, Length(Result));
  finally
    Stream.Free;
  end;
end;

end.
