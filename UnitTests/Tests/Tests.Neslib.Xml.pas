unit Tests.Neslib.Xml;

interface


uses
  DUnitX.TestFramework,
  Neslib.Xml,
  Neslib.Xml.IO,
  Neslib.Xml.Types,
  Tests.Neslib.Xml.Base;

type
  TTestXmlAttribute = class(TBaseXmlTest)
  public
    [Test] procedure TestEnumerator;
    [Test] procedure TestEquality;
    [Test] procedure TestConversion;
    [Test] procedure TestMutate;
    [Test] procedure TestTypes;
  end;

type
  TTestXmlNode = class(TBaseXmlTest)
  public
    [Test] procedure TestEnumerator;
    [Test] procedure TestElementByName;
    [Test] procedure TestElementByAttribute;
    [Test] procedure TestElementByAttributeAndElement;
    [Test] procedure TestNextSiblingByName;
    [Test] procedure TestPrevSiblingByName;
    [Test] procedure TestAttributeByName;
    [Test] procedure TestAddAttribute;
    [Test] procedure TestRemoveAttributeByName;
    [Test] procedure TestRemoveAttribute;
    [Test] procedure TestRemoveAllAttributes;
    [Test] procedure TestAddChild;
    [Test] procedure TestText;
    [Test] procedure RemoveChildByName;
    [Test] procedure RemoveChild;
    [Test] procedure RemoveAllChildren;
  end;

type
  TTestXmlDocument = class(TBaseXmlTest)
  public
    [Test] procedure TestBuildDocument;
    [Test] procedure TestEmptyDocument;
    [Test] procedure TestBuildSingleNode;
    [Test] procedure TestClear;
  end;

implementation

uses
  System.SysUtils,
  Neslib.SysUtils,
  Neslib.Utf8;

{ TTestXmlAttribute }

procedure TTestXmlAttribute.TestConversion;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<node attr1="42" attr2="-3.25" attr3="True" attr4="foo" attr5="98765456789"/>');
  var Attr1 := Doc.DocumentElement.FirstAttribute;
  var Attr2 := Attr1.Next;
  var Attr3 := Attr2.Next;
  var Attr4 := Attr3.Next;
  var Attr5 := Attr4.Next;

  Assert.IsFalse(Attr1.ToBoolean);
  Assert.IsTrue(Attr1.ToBoolean(True));
  Assert.AreEqual(42, Attr1.ToInteger);
  Assert.AreEqual(42, Attr1.ToInt32);
  Assert.AreEqual<Int64>(42, Attr1.ToInt64);
  Assert.AreEqual<Single>(42, Attr1.ToSingle);
  Assert.AreEqual<Double>(42, Attr1.ToDouble);

  Assert.IsFalse(Attr2.ToBoolean);
  Assert.IsTrue(Attr2.ToBoolean(True));
  Assert.AreEqual(0, Attr2.ToInteger);
  Assert.AreEqual(0, Attr2.ToInt32);
  Assert.AreEqual<Int64>(0, Attr2.ToInt64);
  Assert.AreEqual<Single>(-3.25, Attr2.ToSingle);
  Assert.AreEqual<Double>(-3.25, Attr2.ToDouble);

  Assert.IsTrue(Attr3.ToBoolean(False));
  Assert.IsTrue(Attr3.ToBoolean(True));
  Assert.AreEqual(0, Attr3.ToInteger);
  Assert.AreEqual(0, Attr3.ToInt32);
  Assert.AreEqual<Int64>(0, Attr3.ToInt64);
  Assert.AreEqual<Single>(0, Attr3.ToSingle);
  Assert.AreEqual<Double>(0, Attr3.ToDouble);

  Assert.IsFalse(Attr4.ToBoolean);
  Assert.IsTrue(Attr4.ToBoolean(True));
  Assert.AreEqual(1, Attr4.ToInteger(1));
  Assert.AreEqual(-2, Attr4.ToInt32(-2));
  Assert.AreEqual<Int64>(3, Attr4.ToInt64(3));
  Assert.AreEqual<Single>(1.5, Attr4.ToSingle(1.5));
  Assert.AreEqual<Double>(-2.75, Attr4.ToDouble(-2.75));

  Assert.IsFalse(Attr5.ToBoolean);
  Assert.IsTrue(Attr5.ToBoolean(True));
  Assert.AreEqual(0, Attr5.ToInteger);
  Assert.AreEqual(0, Attr5.ToInt32);
  Assert.AreEqual<Int64>(98765456789, Attr5.ToInt64);
  Assert.AreEqual<Single>(98765456789, Attr5.ToSingle);
  Assert.AreEqual<Double>(98765456789, Attr5.ToDouble);
end;

procedure TTestXmlAttribute.TestEnumerator;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<node attr1="foo" attr2="bar" attr3="baz"/>');
  var Count := 0;
  for var Attr in Doc.DocumentElement.Attributes do
  begin
    Inc(Count);
    case Count of
      1: begin
           Assert.AreEqual<XmlString>('attr1', Attr.Name);
           Assert.AreEqual<XmlString>('foo', Attr.Value);
         end;
      2: begin
           Assert.AreEqual<XmlString>('attr2', Attr.Name);
           Assert.AreEqual<XmlString>('bar', Attr.Value);
         end;
      3: begin
           Assert.AreEqual<XmlString>('attr3', Attr.Name);
           Assert.AreEqual<XmlString>('baz', Attr.Value);
         end;
    else
      Assert.Fail;
    end;
  end;
  Assert.AreEqual(3, Count);
end;

procedure TTestXmlAttribute.TestEquality;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<node attr1="foo" attr2="bar"/>');
  var Attr1 := Doc.DocumentElement.FirstAttribute;
  var Attr2 := Attr1.Next;
  var Attr3 := Attr2.Next;
  var Attr4 := Attr3.Next;

  Assert.IsTrue(Attr1 <> nil);
  Assert.IsFalse(Attr1 = nil);
  Assert.IsTrue(Attr1 = Attr1);
  Assert.IsFalse(Attr1 <> Attr1);
  Assert.IsFalse(Attr1 = Attr2);
  Assert.IsTrue(Attr1 <> Attr2);

  Assert.IsTrue(Attr2 <> nil);
  Assert.IsFalse(Attr2 = nil);
  Assert.IsTrue(Attr2 = Attr2);
  Assert.IsFalse(Attr2 <> Attr2);
  Assert.IsFalse(Attr2 = Attr3);
  Assert.IsTrue(Attr2 <> Attr3);

  Assert.IsTrue(Attr3 = nil);
  Assert.IsFalse(Attr3 <> nil);
  Assert.IsTrue(Attr3 = Attr3);
  Assert.IsFalse(Attr3 <> Attr3);
  Assert.IsTrue(Attr3 = Attr4);
  Assert.IsFalse(Attr3 <> Attr4);

  Assert.IsTrue(Attr4 = nil);
  Assert.IsFalse(Attr4 <> nil);
  Assert.IsTrue(Attr4 = Attr4);
  Assert.IsFalse(Attr4 <> Attr4);
end;

procedure TTestXmlAttribute.TestMutate;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<node attr="foo"/>');

  var Attr := Doc.DocumentElement.FirstAttribute;
  Assert.IsTrue(Attr <> nil);
  Attr.Name := 'ns:newattr';
  Attr.Value := 'bar & baz';

  var Xml := Doc.ToXml([]);
  Assert.AreEqual<XmlString>('<node ns:newattr="bar &amp; baz"/>', Xml);
end;

procedure TTestXmlAttribute.TestTypes;
begin
  var Doc := TXmlDocument.Create('node');
  var Node := Doc.DocumentElement;

  Node.AddAttribute('attr1', 'value');
  Node.AddAttribute('attr2', -1.25);
  Node.AddAttribute('attr3', $12345678);
  Node.AddAttribute('attr4', -$123456789);
  Node.AddAttribute('attr5', False);
  Node.AddAttribute('attr6', True);

  var Xml := Doc.ToXml([]);
  Assert.AreEqual<XmlString>('<node attr1="value" attr2="-1.25" attr3="305419896" attr4="-4886718345" attr5="false" attr6="true"/>', Xml);

  Assert.AreEqual<XmlString>('value', Node.AttributeByName('attr1').Value);
  Assert.AreEqual<Single>(0, Node.AttributeByName('attr1').ToSingle);
  Assert.AreEqual<Double>(0, Node.AttributeByName('attr1').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr1').ToInteger);
  Assert.AreEqual<Int64>(0, Node.AttributeByName('attr1').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr1').ToBoolean);

  Assert.AreEqual<XmlString>('-1.25', Node.AttributeByName('attr2').Value);
  Assert.AreEqual<Single>(-1.25, Node.AttributeByName('attr2').ToSingle);
  Assert.AreEqual<Double>(-1.25, Node.AttributeByName('attr2').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr2').ToInteger);
  Assert.AreEqual<Int64>(0, Node.AttributeByName('attr2').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr2').ToBoolean);

  Assert.AreEqual<XmlString>('305419896', Node.AttributeByName('attr3').Value);
  Assert.AreEqual<Single>($12345678, Node.AttributeByName('attr3').ToSingle);
  Assert.AreEqual<Double>($12345678, Node.AttributeByName('attr3').ToDouble);
  Assert.AreEqual<Integer>($12345678, Node.AttributeByName('attr3').ToInteger);
  Assert.AreEqual<Int64>($12345678, Node.AttributeByName('attr3').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr3').ToBoolean);

  Assert.AreEqual<XmlString>('-4886718345', Node.AttributeByName('attr4').Value);
  Assert.AreEqual<Single>(-$123456789, Node.AttributeByName('attr4').ToSingle);
  Assert.AreEqual<Double>(-$123456789, Node.AttributeByName('attr4').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr4').ToInteger); { Does not fit }
  Assert.AreEqual<Int64>(-$123456789, Node.AttributeByName('attr4').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr4').ToBoolean);

  Assert.AreEqual<XmlString>('false', Node.AttributeByName('attr5').Value);
  Assert.AreEqual<Single>(0, Node.AttributeByName('attr5').ToSingle);
  Assert.AreEqual<Double>(0, Node.AttributeByName('attr5').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr5').ToInteger);
  Assert.AreEqual<Int64>(0, Node.AttributeByName('attr5').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr5').ToBoolean);

  Assert.AreEqual<XmlString>('true', Node.AttributeByName('attr6').Value);
  Assert.AreEqual<Single>(0, Node.AttributeByName('attr6').ToSingle);
  Assert.AreEqual<Double>(0, Node.AttributeByName('attr6').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr6').ToInteger);
  Assert.AreEqual<Int64>(0, Node.AttributeByName('attr6').ToInt64);
  Assert.AreEqual<Boolean>(True, Node.AttributeByName('attr6').ToBoolean);

  { Non-existing attribute }

  Assert.AreEqual<XmlString>('', Node.AttributeByName('attr42').Value);
  Assert.AreEqual<Single>(0, Node.AttributeByName('attr42').ToSingle);
  Assert.AreEqual<Double>(0, Node.AttributeByName('attr42').ToDouble);
  Assert.AreEqual<Integer>(0, Node.AttributeByName('attr42').ToInteger);
  Assert.AreEqual<Int64>(0, Node.AttributeByName('attr42').ToInt64);
  Assert.AreEqual<Boolean>(False, Node.AttributeByName('attr42').ToBoolean);
end;

{ TTestXmlNode }

procedure TTestXmlNode.RemoveAllChildren;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/></root>');

  Doc.DocumentElement.RemoveAllChildren;
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.RemoveChild;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/></root>');

  var Node1 := Doc.DocumentElement.FirstChild;
  Assert.AreEqual<XmlString>('node1', Node1.Value);

  var Node2 := Node1.NextSibling;
  Assert.AreEqual<XmlString>('node2', Node2.Value);

  var Node3 := Node2.NextSibling;
  Assert.AreEqual<XmlString>('node3', Node3.Value);

  var Node4 := Node3.NextSibling;
  Assert.IsTrue(Node4 = nil);

  Doc.DocumentElement.RemoveChild(Node2);
  Assert.AreEqual<XmlString>('<root><node1/><node3/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild(Node1);
  Assert.AreEqual<XmlString>('<root><node3/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild(Node4);
  Assert.AreEqual<XmlString>('<root><node3/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild(Node3);
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.RemoveChildByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/></root>');

  Doc.DocumentElement.RemoveChild('node2');
  Assert.AreEqual<XmlString>('<root><node1/><node3/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild('node3');
  Assert.AreEqual<XmlString>('<root><node1/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild('node4');
  Assert.AreEqual<XmlString>('<root><node1/></root>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveChild('node1');
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestAddAttribute;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root attr1="A" attr2="B" attr3="C"/>');
  Doc.DocumentElement.AddAttribute('attr4', 'D');
  Doc.DocumentElement.AddAttribute('attr5', 42);
  Doc.DocumentElement.AddAttribute('attr6', 1.25);
  Doc.DocumentElement.AddAttribute('attr7', True);
  Assert.AreEqual<XmlString>('<root attr1="A" attr2="B" attr3="C" attr4="D" attr5="42" attr6="1.25" attr7="true"/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestAddChild;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/></root>');

  var Node1 := Doc.DocumentElement.FirstChild;
  Assert.AreEqual<XmlString>('node1', Node1.Value);

  var Node1a := Node1.AddChild(TXmlNodeType.Element, 'node1a');
  Assert.AreEqual<XmlString>('<root><node1><node1a/></node1></root>', Doc.ToXml([]));

  Node1.AddChild(TXmlNodeType.Text, 'foo');
  Assert.AreEqual<XmlString>('<root><node1><node1a/>foo</node1></root>', Doc.ToXml([]));

  Node1a.AddChild(TXmlNodeType.Comment, 'bar');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo</node1></root>', Doc.ToXml([]));

  Node1.AddChild(TXmlNodeType.CData, 'baz');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo<![CDATA[baz]]></node1></root>', Doc.ToXml([]));

  { Shortcuts }
  var Node1b := Node1.AddElement('node1b');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo<![CDATA[baz]]><node1b/></node1></root>', Doc.ToXml([]));

  Node1b.AddText('FOO');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo<![CDATA[baz]]><node1b>FOO</node1b></node1></root>', Doc.ToXml([]));

  Node1.AddComment('BAR');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo<![CDATA[baz]]><node1b>FOO</node1b><!--BAR--></node1></root>', Doc.ToXml([]));

  Node1b.AddCData('BAZ');
  Assert.AreEqual<XmlString>('<root><node1><node1a><!--bar--></node1a>foo<![CDATA[baz]]><node1b>FOO<![CDATA[BAZ]]></node1b><!--BAR--></node1></root>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestAttributeByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root attr1="A" attr2="B" attr3="C"/>');

  var Attr := Doc.DocumentElement.AttributeByName('attr1');
  Assert.AreEqual<XmlString>('A', Attr.Value);

  Attr := Doc.DocumentElement.AttributeByName('attr2');
  Assert.AreEqual<XmlString>('B', Attr.Value);

  Attr := Doc.DocumentElement.AttributeByName('attr3');
  Assert.AreEqual<XmlString>('C', Attr.Value);

  Attr := Doc.DocumentElement.AttributeByName('attr4');
  Assert.AreEqual<XmlString>('', Attr.Value);
end;

procedure TTestXmlNode.TestElementByAttribute;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1 attr="A"/><node2 attr="B"/><node3 attr="C"/></root>');

  var Node := Doc.DocumentElement.ElementByAttribute('attr', 'A');
  Assert.AreEqual<XmlString>('node1', Node.Value);

  Node := Doc.DocumentElement.ElementByAttribute('attr', 'B');
  Assert.AreEqual<XmlString>('node2', Node.Value);

  Node := Doc.DocumentElement.ElementByAttribute('attr', 'C');
  Assert.AreEqual<XmlString>('node3', Node.Value);

  Node := Doc.DocumentElement.ElementByAttribute('attr', 'D');
  Assert.AreEqual<XmlString>('', Node.Value);
end;

procedure TTestXmlNode.TestElementByAttributeAndElement;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node attr="A" id="1"/><node attr="B" id="2"/><node attr="C" id="3"/></root>');

  var Node := Doc.DocumentElement.ElementByAttribute('node', 'attr', 'A');
  Assert.AreEqual(1, Node.AttributeByName('id').ToInteger);

  Node := Doc.DocumentElement.ElementByAttribute('node', 'attr', 'B');
  Assert.AreEqual(2, Node.AttributeByName('id').ToInteger);

  Node := Doc.DocumentElement.ElementByAttribute('node', 'attr', 'C');
  Assert.AreEqual(3, Node.AttributeByName('id').ToInteger);

  Node := Doc.DocumentElement.ElementByAttribute('node', 'attr', 'D');
  Assert.AreEqual(0, Node.AttributeByName('id').ToInteger);

  Node := Doc.DocumentElement.ElementByAttribute('foo', 'attr', 'C');
  Assert.AreEqual(0, Node.AttributeByName('id').ToInteger);
end;

procedure TTestXmlNode.TestElementByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1><node2><node3></node3></node2></node1></root>');

  var Node := Doc.Root.ElementByName('root')
                      .ElementByName('node1')
                      .ElementByName('node2')
                      .ElementByName('node3');
  Assert.AreEqual<XmlString>('node3', Node.Value);

  Node := Doc.DocumentElement.ElementByName('node1')
                             .ElementByName('node2');
  Assert.AreEqual<XmlString>('node2', Node.Value);

  Node := Doc.DocumentElement.ElementByName('node3')
                             .ElementByName('node2');
  Assert.AreEqual<XmlString>('', Node.Value);
end;

procedure TTestXmlNode.TestEnumerator;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/></root>');
  var Count := 0;
  for var Node in Doc.DocumentElement do
  begin
    Inc(Count);
    case Count of
      1: Assert.AreEqual<XmlString>('node1', Node.Value);
      2: Assert.AreEqual<XmlString>('node2', Node.Value);
      3: Assert.AreEqual<XmlString>('node3', Node.Value);
    else
      Assert.Fail;
    end;
  end;
  Assert.AreEqual(3, Count);
end;

procedure TTestXmlNode.TestNextSiblingByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/><node4/></root>');

  var Node := Doc.DocumentElement.FirstChild;
  Assert.AreEqual<XmlString>('node1', Node.Value);

  Node := Node.NextSiblingByName('node3');
  Assert.AreEqual<XmlString>('node3', Node.Value);

  Node := Node.NextSiblingByName('node2');
  Assert.AreEqual<XmlString>('', Node.Value);
end;

procedure TTestXmlNode.TestPrevSiblingByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root><node1/><node2/><node3/><node4/></root>');

  var Node := Doc.DocumentElement.ElementByName('node4');
  Assert.AreEqual<XmlString>('node4', Node.Value);

  Node := Node.PrevSiblingByName('node2');
  Assert.AreEqual<XmlString>('node2', Node.Value);

  Node := Node.PrevSiblingByName('node3');
  Assert.AreEqual<XmlString>('', Node.Value);
end;

procedure TTestXmlNode.TestRemoveAllAttributes;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root attr1="A" attr2="B" attr3="C"/>');

  Doc.DocumentElement.RemoveAllAttributes;
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestRemoveAttribute;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root attr1="A" attr2="B" attr3="C"/>');

  var Attr1 := Doc.DocumentElement.AttributeByName('attr1');
  var Attr2 := Doc.DocumentElement.AttributeByName('attr2');
  var Attr3 := Doc.DocumentElement.AttributeByName('attr3');
  var Attr4 := Doc.DocumentElement.AttributeByName('attr4');

  Doc.DocumentElement.RemoveAttribute(Attr2);
  Assert.AreEqual<XmlString>('<root attr1="A" attr3="C"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute(Attr3);
  Assert.AreEqual<XmlString>('<root attr1="A"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute(Attr4);
  Assert.AreEqual<XmlString>('<root attr1="A"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute(Attr1);
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestRemoveAttributeByName;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<root attr1="A" attr2="B" attr3="C"/>');

  Doc.DocumentElement.RemoveAttribute('attr2');
  Assert.AreEqual<XmlString>('<root attr1="A" attr3="C"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute('attr1');
  Assert.AreEqual<XmlString>('<root attr3="C"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute('attr4');
  Assert.AreEqual<XmlString>('<root attr3="C"/>', Doc.ToXml([]));

  Doc.DocumentElement.RemoveAttribute('attr3');
  Assert.AreEqual<XmlString>('<root/>', Doc.ToXml([]));
end;

procedure TTestXmlNode.TestText;
begin
  var Doc := TXmlDocument.Create;

  Doc.Parse('<root/>');
  Assert.AreEqual('', Doc.DocumentElement.Text);

  Doc.Parse('<root>foo</root>');
  Assert.AreEqual('foo', Doc.DocumentElement.Text);
  Assert.AreEqual('foo', Doc.DocumentElement.FirstChild.Text);

  Doc.Parse('<root> foo </root>');
  Assert.AreEqual(' foo ', Doc.DocumentElement.Text);

  Doc.Parse('<root>foo<child/>bar</root>');
  Assert.AreEqual('foo bar', Doc.DocumentElement.Text);
  Assert.AreEqual('foo', Doc.DocumentElement.FirstChild.Text);

  Doc.Parse('<root>foo <child/>bar</root>');
  Assert.AreEqual('foo bar', Doc.DocumentElement.Text);
  Assert.AreEqual('foo ', Doc.DocumentElement.FirstChild.Text);

  Doc.Parse('<root>foo<child/> bar</root>');
  Assert.AreEqual('foo bar', Doc.DocumentElement.Text);
  Assert.AreEqual('foo', Doc.DocumentElement.FirstChild.Text);

  Doc.Parse('<root>foo <child/> bar</root>');
  Assert.AreEqual('foo  bar', Doc.DocumentElement.Text);
  Assert.AreEqual('foo ', Doc.DocumentElement.FirstChild.Text);
end;

{ TTestXmlDocument }

procedure TTestXmlDocument.TestBuildDocument;
begin
  var Document := TXmlDocument.Create;

  { <root> }
  var Root := Document.Root.AddElement('root');

  {   <!--This is a comment.--> }
  Root.AddComment('This is a comment.');

  {   <node1 /> }
  Root.AddChild(TXmlNodeType.Element, 'node1');

  {   <node2></node2> }
  Root.AddElement('node2'); { Shortcut for AddChild(TXmlNodeType.Element, 'node2') }

  {   <node3 attr="value" /> }
  var Node := Root.AddElement('node3');
  Node.AddAttribute('attr', 'value');

  {   <node4  attr1 = "value1"   attr2='value2'/> }
  Node := Root.AddElement('node4');
  Node.AddAttribute('attr1', 'value1');
  Node.AddAttribute('attr2', 'value2');

  {   <node5 attr="value">Ampersand: &amp;, LT: &lt;, GT: &gt;, Quotes: &quot; and &apos;, Decimal: &#65;, Hex: &#x42;</node5> }
  Node := Root.AddElement('node5');
  Node.AddAttribute('attr', 'value');
  Node.AddText('Ampersand: &, LT: <, GT: >, Quotes: " and '', Decimal: A, Hex: B');

  {  <node6>Text with <node6a somens:attr="value">embedded child node</node6a>.</node6> }
  Node := Root.AddElement('node6');
  Node.AddText('Text with ');
  var Child := Node.AddElement('node6a');
  Child.AddAttribute('somens:attr', 'value');
  Child.AddText('embedded child node');
  Node.AddText('.');

  {  <somens:node7>Text with <![CDATA[embedded "CDATA"]]>.</somens:node7> }
  Node := Root.AddElement('somens:node7');
  Node.AddText('Text with ');
  Node.AddCData('embedded "CDATA"');
  Node.AddText('.');

  CheckSampleDocument(Document);

  { Save document with and without indents and newlines.
    And check if loading the output results in the same document. }
  var PrettyXml := Document.ToXml([TXmlOutputOption.Indent]);
  var CompactXml := Document.ToXml([]);

  Document := nil;
  Document := TXmlDocument.Create;
  Document.Parse(PrettyXml);
  CheckSampleDocument(Document);

  Document := nil;
  Document := TXmlDocument.Create;
  Document.Parse(CompactXml);
  CheckSampleDocument(Document);
end;

procedure TTestXmlDocument.TestBuildSingleNode;
begin
  var Doc := TXmlDocument.Create;
  Doc.Root.AddChild(TXmlNodeType.Element, 'foo');
  Assert.AreEqual<XmlString>('<foo/>', Doc.ToXml([]));

  var Doc1 := TXmlDocument.Create('bar');
  Assert.AreEqual<XmlString>('<bar/>', Doc1.ToXml([]));
end;

procedure TTestXmlDocument.TestClear;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<foo>bar</foo>');
  Assert.IsTrue(Doc.DocumentElement <> nil);
  Assert.AreEqual<XmlString>('foo', Doc.DocumentElement.Value);

  Doc.Clear;
  Assert.IsTrue(Doc.DocumentElement = nil);

  Doc.Parse('<bar>baz</bar>');
  Assert.IsTrue(Doc.DocumentElement <> nil);
  Assert.AreEqual<XmlString>('bar', Doc.DocumentElement.Value);

  Doc.Parse('<baz>foo</baz>');
  Assert.IsTrue(Doc.DocumentElement <> nil);
  Assert.AreEqual<XmlString>('baz', Doc.DocumentElement.Value);
end;

procedure TTestXmlDocument.TestEmptyDocument;
begin
  var Doc := TXmlDocument.Create;
  Assert.AreEqual<XmlString>('', Doc.ToXml);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestXmlAttribute);
  TDUnitX.RegisterTestFixture(TTestXmlNode);
  TDUnitX.RegisterTestFixture(TTestXmlDocument);

end.
