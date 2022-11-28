unit Tests.Neslib.Xml.IO;

interface

uses
  DUnitX.TestFramework,
  Neslib.Xml,
  Neslib.Xml.IO,
  Neslib.Xml.Types,
  Tests.Neslib.Xml.Base;

type
  TTestXmlReader = class(TBaseXmlTest)
  private
    procedure ExpectParseError(const AXml: XmlString; const AErrorMsg: String;
      const ALine, AColumn: Integer);
  public
    [Test] procedure TestXmlReader;
    [Test] procedure TestParseSingleNode;
    [Test] procedure TestParseError_StartsWithCloseElement;
    [Test] procedure TestParseError_StartsWithCData;
    [Test] procedure TestParseError_EofInCData;
    [Test] procedure TestParseError_EofInComment;
    [Test] procedure TestParseError_EofInDeclaration;
    [Test] procedure TestParseError_EofInStartElement;
    [Test] procedure TestParseError_EofInEndElement;
    [Test] procedure TestParseError_EofInAttributeName;
    [Test] procedure TestParseError_EofInAttributeValue;
    [Test] procedure TestParseError_UnterminatedCharacterReference;
    [Test] procedure TestParseError_InvalidNumericCharacterReference;
    [Test] procedure TestParseError_UnknownCharacterReference;
    [Test] procedure TestParseError_InvalidCommentPrefix;
    [Test] procedure TestParseError_InvalidCommentSuffix;
    [Test] procedure TestParseError_InvalidCData;
    [Test] procedure TestParseError_MissingEqualInAttribute;
    [Test] procedure TestParseError_InvalidAttributeQuote;
    [Test] procedure TestParseError_ElementNameMismatch;
    [Test] procedure TestIssue9_CommentsAtStart;
  end;

type
  TTestEncoding = class(TBaseXmlTest)
  private
    FDocument: IXmlDocument;
  public
    [Setup] procedure Setup;
  public
    [Test] procedure TestLoadDocument;
    [Test] procedure TestLoadDocumentUtf8;
    [Test] procedure TestLoadDocumentUtf16;
    [Test] procedure TestLoadDocumentUtf16BigEndian;
    [Test] procedure TestLoadDocumentUtf32;
    [Test] procedure TestLoadDocumentUtf32BigEndian;
  end;

implementation

{ TTestXmlReader }

procedure TTestXmlReader.TestXmlReader;
begin
  var Pool := TXmlStringInternPool.Create;
  try
    var Reader := TXmlReader.Load(LoadResource('SAMPLE'), Pool);
    try
      Assert.AreEqual<TXmlEncoding>(TXmlEncoding.Utf8, Reader.Encoding);

      { <?xml version="1.0"?> should be skipped }

      var State: TXmlReaderState;

      { <root> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('root', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(0, Reader.AttributeCount);

      {   <!--This is a comment.--> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Comment, State);
      Assert.AreEqual<XmlString>('This is a comment.', Reader.ValueString);

      {   <node1 /> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsTrue(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node1', Pool.Get(Reader.ValueIndex));

      {   <node2> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node2', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(0, Reader.AttributeCount);

      {   </node2> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('node2', Pool.Get(Reader.ValueIndex));

      {   <node3 attr="value" /> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsTrue(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node3', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(1, Reader.AttributeCount);
      Assert.AreEqual<XmlString>('attr', Pool.Get(Reader.Attributes[0].NameIndex));
      Assert.AreEqual<XmlString>('value', Reader.Attributes[0].Value);

      {   <node4  attr1 = "value1"   attr2='value2'/> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsTrue(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node4', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(2, Reader.AttributeCount);
      Assert.AreEqual<XmlString>('attr1', Pool.Get(Reader.Attributes[0].NameIndex));
      Assert.AreEqual<XmlString>('value1', Reader.Attributes[0].Value);
      Assert.AreEqual<XmlString>('attr2', Pool.Get(Reader.Attributes[1].NameIndex));
      Assert.AreEqual<XmlString>('value2', Reader.Attributes[1].Value);

      {   <node5 attr="value"> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node5', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(1, Reader.AttributeCount);
      Assert.AreEqual<XmlString>('attr', Pool.Get(Reader.Attributes[0].NameIndex));
      Assert.AreEqual<XmlString>('value', Reader.Attributes[0].Value);

      {   Ampersand: &amp;, LT: &lt;, GT: &gt;, Quotes: &quot; and &apos;, Decimal: &#65;, Hex: &#x42; }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('Ampersand: &, LT: <, GT: >, Quotes: " and '', Decimal: A, Hex: B', Reader.ValueString);

      {   </node5> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('node5', Pool.Get(Reader.ValueIndex));

      {   <node6> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node6', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(0, Reader.AttributeCount);

      {   Text with  }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('Text with ', Reader.ValueString);

      {     <node6a somens:attr="value"> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('node6a', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(1, Reader.AttributeCount);
      Assert.AreEqual<XmlString>('somens:attr', Pool.Get(Reader.Attributes[0].NameIndex));
      Assert.AreEqual<XmlString>('value', Reader.Attributes[0].Value);

      {     embedded child node }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('embedded child node', Reader.ValueString);

      {     </node6a> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('node6a', Pool.Get(Reader.ValueIndex));

      {   . }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('.', Reader.ValueString);

      {   </node6> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('node6', Pool.Get(Reader.ValueIndex));

      {   <somens:node7> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.StartElement, State);
      Assert.IsFalse(Reader.IsEmptyElement);
      Assert.AreEqual<XmlString>('somens:node7', Pool.Get(Reader.ValueIndex));
      Assert.AreEqual(0, Reader.AttributeCount);

      {   Text with  }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('Text with ', Reader.ValueString);

      {   <![CDATA[embedded "CDATA"]]> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.CData, State);
      Assert.AreEqual<XmlString>('embedded "CDATA"', Reader.ValueString);

      {   . }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.Text, State);
      Assert.AreEqual<XmlString>('.', Reader.ValueString);

      {   </somens:node7> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('somens:node7', Pool.Get(Reader.ValueIndex));

      { </root> }
      Assert.IsTrue(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndElement, State);
      Assert.AreEqual<XmlString>('root', Pool.Get(Reader.ValueIndex));

      { EOF }
      Assert.IsFalse(Reader.Next(State));
      Assert.AreEqual<TXmlReaderState>(TXmlReaderState.EndOfStream, State);
    finally
      Reader.Free;
    end;
  finally
    Pool.Free;
  end;
end;

procedure TTestXmlReader.ExpectParseError(const AXml: XmlString;
  const AErrorMsg: String; const ALine, AColumn: Integer);
begin
  var Doc := TXmlDocument.Create;
  try
    Doc.Parse(AXml);
    Assert.Fail('Should raise an exception');
  except
    on E: EXmlParserError do
    begin
      Assert.AreEqual(AErrorMsg, E.Message);
      Assert.AreEqual(ALine, E.LineNumber);
      Assert.AreEqual(AColumn, E.ColumnNumber);
    end
    else
      Assert.Fail('EXmlParserError expected');
  end;
end;

procedure TTestXmlReader.TestIssue9_CommentsAtStart;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<!-- Comment at start of file -->'#10+
            '<element>'#10+
            '</element>');

  var Root := Doc.Root;

  { <!-- Comment at start of file --> }
  var Comment := Root.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Comment, Comment.NodeType);
  Assert.AreEqual<XmlString>(' Comment at start of file ', Comment.Value);

  { <element> }
  var Element := Comment.NextSibling;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Element.NodeType);
  Assert.AreEqual<XmlString>('element', Element.Value);
end;

procedure TTestXmlReader.TestParseError_ElementNameMismatch;
begin
  ExpectParseError('<foo></Foo>', RS_XML_ELEMENT_NAME_MISMATCH, 1, 6);
end;

procedure TTestXmlReader.TestParseError_EofInAttributeName;
begin
  ExpectParseError('<foo bar', RS_XML_UNEXPECTED_EOF, 1, 6);
end;

procedure TTestXmlReader.TestParseError_EofInAttributeValue;
begin
  ExpectParseError('<foo bar="baz', RS_XML_UNEXPECTED_EOF, 1, 11);
end;

procedure TTestXmlReader.TestParseError_EofInCData;
begin
  ExpectParseError('<![CDATA[foo', RS_XML_UNEXPECTED_EOF, 1, 1);
end;

procedure TTestXmlReader.TestParseError_EofInComment;
begin
  ExpectParseError('<!--foo', RS_XML_UNEXPECTED_EOF, 1, 1);
end;

procedure TTestXmlReader.TestParseError_EofInDeclaration;
begin
  ExpectParseError('<?xml', RS_XML_UNEXPECTED_EOF, 1, 1);
end;

procedure TTestXmlReader.TestParseError_EofInEndElement;
begin
  ExpectParseError('<foo></foo', RS_XML_UNEXPECTED_EOF, 1, 6);
end;

procedure TTestXmlReader.TestParseError_EofInStartElement;
begin
  ExpectParseError('<foo', RS_XML_UNEXPECTED_EOF, 1, 1);
end;

procedure TTestXmlReader.TestParseError_InvalidAttributeQuote;
begin
  ExpectParseError('<foo attr=value />', RS_XML_INVALID_QUOTE, 1, 11);
end;

procedure TTestXmlReader.TestParseError_InvalidCData;
begin
  ExpectParseError('<foo><![CDAT[bar]]></foo>', RS_XML_INVALID_CDATA, 1, 6);
end;

procedure TTestXmlReader.TestParseError_InvalidCommentPrefix;
begin
  ExpectParseError('<foo><!-bar--></foo>', RS_XML_INVALID_COMMENT, 1, 6);
end;

procedure TTestXmlReader.TestParseError_InvalidCommentSuffix;
begin
  ExpectParseError('<foo><!--bar-></foo>', RS_XML_INVALID_COMMENT, 1, 6);
end;

procedure TTestXmlReader.TestParseError_InvalidNumericCharacterReference;
begin
  ExpectParseError('<foo>A &#1a B</foo>', RS_XML_CHARACTER_REFERENCE, 1, 8);
end;

procedure TTestXmlReader.TestParseError_MissingEqualInAttribute;
begin
  ExpectParseError('<foo attr "value" />', RS_XML_EQUAL_EXPECTED, 1, 11);
end;

procedure TTestXmlReader.TestParseError_StartsWithCData;
begin
  ExpectParseError('<![CDATA[foo]]>', RS_XML_CDATA_NOT_ALLOWED, 1, 1);
end;

procedure TTestXmlReader.TestParseError_StartsWithCloseElement;
begin
  ExpectParseError('</foo>', RS_XML_INVALID_END_ELEMENT, 1, 1);
end;

procedure TTestXmlReader.TestParseError_UnknownCharacterReference;
begin
  ExpectParseError('<foo>A &bar; B</foo>', RS_XML_CHARACTER_REFERENCE, 1, 8);
end;

procedure TTestXmlReader.TestParseError_UnterminatedCharacterReference;
begin
  ExpectParseError('<foo>A &amp B</foo>', RS_XML_CHARACTER_REFERENCE, 1, 8);
end;

procedure TTestXmlReader.TestParseSingleNode;
begin
  var Doc := TXmlDocument.Create;
  Doc.Parse('<foo/>');
  Assert.AreEqual<XmlString>('<foo/>', Doc.ToXml([]));
end;

{ TTestEncoding }

procedure TTestEncoding.Setup;
begin
  FDocument := TXmlDocument.Create;
end;

procedure TTestEncoding.TestLoadDocument;
begin
  FDocument.Load(LoadResource('SAMPLE'));
  CheckSampleDocument(FDocument);
end;

procedure TTestEncoding.TestLoadDocumentUtf16;
begin
  FDocument.Load(LoadResource('SAMPLE_UTF16'));

  var Root := FDocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('encoding', Root.Value);
  Assert.IsTrue(Root.NextSibling = nil);

  var Attr := Root.FirstAttribute;
  Assert.AreEqual<XmlString>('name', Attr.Name);
  Assert.AreEqual<XmlString>('utf16 with BOM', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);

  var Child := Root.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('世界您好', Child.Value);

  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);
end;

procedure TTestEncoding.TestLoadDocumentUtf16BigEndian;
begin
  FDocument.Load(LoadResource('SAMPLE_UTF16_BE'));

  var Root := FDocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('encoding', Root.Value);
  Assert.IsTrue(Root.NextSibling = nil);

  var Attr := Root.FirstAttribute;
  Assert.AreEqual<XmlString>('name', Attr.Name);
  Assert.AreEqual<XmlString>('utf16 big-endian with BOM', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);

  var Child := Root.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('世界您好', Child.Value);

  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);
end;

procedure TTestEncoding.TestLoadDocumentUtf32;
begin
  FDocument.Load(LoadResource('SAMPLE_UTF32'));

  var Root := FDocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('encoding', Root.Value);
  Assert.IsTrue(Root.NextSibling = nil);

  var Attr := Root.FirstAttribute;
  Assert.AreEqual<XmlString>('name', Attr.Name);
  Assert.AreEqual<XmlString>('utf32 with BOM', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);

  var Child := Root.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('世界您好', Child.Value);

  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);
end;

procedure TTestEncoding.TestLoadDocumentUtf32BigEndian;
begin
  FDocument.Load(LoadResource('SAMPLE_UTF32_BE'));

  var Root := FDocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('encoding', Root.Value);
  Assert.IsTrue(Root.NextSibling = nil);

  var Attr := Root.FirstAttribute;
  Assert.AreEqual<XmlString>('name', Attr.Name);
  Assert.AreEqual<XmlString>('utf32 big-endian with BOM', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);

  var Child := Root.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('世界您好', Child.Value);

  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);
end;

procedure TTestEncoding.TestLoadDocumentUtf8;
begin
  FDocument.Load(LoadResource('SAMPLE_UTF8'));

  { <sample> }
  var Root := FDocument.DocumentElement;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Element, Root.NodeType);
  Assert.AreEqual<XmlString>('sample', Root.Value);

  {   <encoding name="utf8 with BOM">世界您好</encoding> }
  var Node := Root.FirstChild;
  Assert.AreEqual<XmlString>('encoding', Node.Value);
  var Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('name', Attr.Name);
  Assert.AreEqual<XmlString>('utf8 with BOM', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);

  var Child := Node.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('世界您好', Child.Value);
  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);

  {   <世界>non-Ansi element name</世界> }
  Node := Node.NextSibling;
  Assert.AreEqual<XmlString>('世界', Node.Value);
  Assert.IsTrue(Node.FirstAttribute = nil);
  Child := Node.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('non-Ansi element name', Child.Value);
  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);

  {   <node 您好="non-Ansi attribute name"/> }
  Node := Node.NextSibling;
  Assert.AreEqual<XmlString>('node', Node.Value);
  Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('您好', Attr.Name);
  Assert.AreEqual<XmlString>('non-Ansi attribute name', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);
  Assert.IsTrue(Node.FirstChild = nil);

  {   <界您 世好="世您">界好</界您> }
  Node := Node.NextSibling;
  Assert.AreEqual<XmlString>('界您', Node.Value);
  Attr := Node.FirstAttribute;
  Assert.AreEqual<XmlString>('世好', Attr.Name);
  Assert.AreEqual<XmlString>('世您', Attr.Value);
  Assert.IsTrue(Attr.Next = nil);
  Child := Node.FirstChild;
  Assert.AreEqual<TXmlNodeType>(TXmlNodeType.Text, Child.NodeType);
  Assert.AreEqual<XmlString>('界好', Child.Value);
  Assert.IsTrue(Child.FirstAttribute = nil);
  Assert.IsTrue(Child.NextSibling = nil);

  Assert.IsTrue(Node.NextSibling = nil);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
  TDUnitX.RegisterTestFixture(TTestXmlReader);
  TDUnitX.RegisterTestFixture(TTestEncoding);

end.
