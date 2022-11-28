unit Neslib.Xml;

{$INCLUDE 'Neslib.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  Neslib.Utf8,
  Neslib.Xml.IO,
  Neslib.Xml.Types,
  Neslib.Collections;

type
  { The type of a TXmlNode }
  TXmlNodeType = (
    { The node is an element (eg. <node>), and may have child nodes. }
    Element,

    { The node represents a text string.
      This is the text between a start and end element.

      For example, given the XML string '<foo>bar</foo>', the <foo> element
      contains a single child node of type Text (with value 'bar').

      A single element may contain multiple text nodes in case these are
      seperated by a child node. For example, '<foo>bar<child/>baz</foo>'.
      Here, the <foo> node contains 3 child nodes:
      * A Text node with value 'bar'
      * An Element node with name 'child'
      * Another Text node with value 'baz' }
    Text,

    { The node represents a comment (as in <!--foo-->).
      The value of the node does not contain markup characters (eg. it is just
      'foo' in this example). }
    Comment,

    { The node represents a comment (as in <![CDATA[foo]]>).
      The value of the node does not contain markup characters (eg. it is just
      'foo' in this example). }
    CData);

type
  TXmlDocument = class;

  { A single attribute in a TXmlNode.
    Note that it is legal to access properties and methods of a nil-attribute.
    This will just not do anything. This way, you don't need to check the
    validity of an attribute before using it. }
  TXmlAttribute = record
  {$REGION 'Internal Declarations'}
  private const
    S_FALSE = 'false';
    S_TRUE  = 'true';
  private type
    TEnumerator = record
    private
      FCurrent: PUInt64;
    private
      function GetCurrent: TXmlAttribute; inline;
    public
      constructor Create(const ANode: PUInt64);
      function MoveNext: Boolean; inline;

      property Current: TXmlAttribute read GetCurrent;
    end;
  private
    FAttribute: PUInt64;
    function GetNameIndex: Integer;
    function GetName: XmlString; inline;
    procedure SetName(const AValue: XmlString);
    function GetNext: TXmlAttribute;
    procedure SetNext(const AValue: TXmlAttribute);
    function GetValue: XmlString;
    procedure SetValue(const AValue: XmlString); overload;
  private
    function GetBlock: PByte; inline;
    function GetDocument: TXmlDocument; inline;
    procedure Free; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { (In)equality operators that can be used to compare two attributes.
      You can also compare against nil-pointer (eg. if (MyAttr <> nil) then...') }
    class operator Equal(const ALeft: TXmlAttribute; const ARight: Pointer): Boolean; overload; inline; static;
    class operator Equal(const ALeft, ARight: TXmlAttribute): Boolean; overload; inline; static;
    class operator NotEqual(const ALeft: TXmlAttribute; const ARight: Pointer): Boolean; overload; inline; static;
    class operator NotEqual(const ALeft, ARight: TXmlAttribute): Boolean; overload; inline; static;

    { Tries to convert the value of the attribute to a Boolean.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to False.

      Returns:
        The attribute value as a Boolean, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToBoolean(const ADefault: Boolean = False): Boolean;

    { Tries to convert the value of the attribute to a 32-bit Integer.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to 0.

      Returns:
        The attribute value as an integer, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToInteger(const ADefault: Integer = 0): Integer; inline;

    { Tries to convert the value of the attribute to a 32-bit Integer.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to 0.

      Returns:
        The attribute value as an integer, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToInt32(const ADefault: Int32 = 0): Int32; inline;

    { Tries to convert the value of the attribute to a 64-bit Integer.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to 0.

      Returns:
        The attribute value as an integer, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToInt64(const ADefault: Int64 = 0): Int64; inline;

    { Tries to convert the value of the attribute to a single-precision
      floating-point value.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to 0.

      Returns:
        The attribute value as a Single, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToSingle(const ADefault: Single = 0): Single; inline;

    { Tries to convert the value of the attribute to a double-precision
      floating-point value.

      Parameters:
        ADefault: (optional) default value to return in case the value cannot
          be converted. Defaults to 0.

      Returns:
        The attribute value as a Double, or ADefault in case the value cannot
        be converted, or this attribute is nil. }
    function ToDouble(const ADefault: Double = 0): Double; inline;

    { Sets the value of this attribute to a Boolean value.

      Parameters:
        AValue: the value to set.

      Does nothing in case this attribute is nil. }
    procedure SetValue(const AValue: Boolean); overload; inline;

    { Sets the value of this attribute to a 32-bit Integer value.

      Parameters:
        AValue: the value to set.

      Does nothing in case this attribute is nil. }
    procedure SetValue(const AValue: Int32); overload; inline;

    { Sets the value of this attribute to a 64-bit Integer value.

      Parameters:
        AValue: the value to set.

      Does nothing in case this attribute is nil. }
    procedure SetValue(const AValue: Int64); overload; inline;

    { Sets the value of this attribute to a single-precision floating-point
      value.

      Parameters:
        AValue: the value to set.

      Does nothing in case this attribute is nil. }
    procedure SetValue(const AValue: Single); overload; inline;

    { Sets the value of this attribute to a double-precision floating-point
      value.

      Parameters:
        AValue: the value to set.

      Does nothing in case this attribute is nil. }
    procedure SetValue(const AValue: Double); overload; inline;

    { The name of this attribute.
      Returns an empty string when this attribute is nil.
      Setting the name has no effect if this attribute is nil. }
    property Name: XmlString read GetName write SetName;

    { The value of this attribute.
      Returns an empty string when this attribute is nil.
      Setting the value has no effect if this attribute is nil. }
    property Value: XmlString read GetValue write SetValue;

    { The next attribute in this list of attributes of a TXmlNode.
      Returns nil if this was the last attribute in the list. }
    property Next: TXmlAttribute read GetNext;
  end;

  { A set of attribute. This is a helper type that enables you to enumerate
    the attribute in a TXmlNode, as in:
      for var Attr in Node.Attributes do ... }
  TXmlAttributes = record
  {$REGION 'Internal Declarations'}
  private
    FNode: PUInt64;
  {$ENDREGION 'Internal Declarations'}
  public
    { Returns an attribute enumerator to enable for..in enumeration, as in:
        for var Attr in Node.Attributes do ... }
    function GetEnumerator: TXmlAttribute.TEnumerator; inline;
  end;

  { A single XML node.
    A single type is used for all supported types of nodes (Elements, Text,
    Comments and CData)
    Note that it is legal to access properties and methods of a nil-node.
    This will just not do anything. This way, you don't need to check the
    validity of a node before using it. For example, you can write:
      Node.ChildByName('foo').ChildByName('bar').Value := 'baz';
    This doesn't do anything is Node is nil, or any of the ChildByName methods
    return nil. }
  TXmlNode = record
  {$REGION 'Internal Declarations'}
  private type
    TEnumerator = record
    private
      FCurrent: PUInt64;
    private
      function GetCurrent: TXmlNode; inline;
    public
      constructor Create(const ANode: PUInt64);
      function MoveNext: Boolean; inline;

      property Current: TXmlNode read GetCurrent;
    end;
  private const
    ID_PARENT          = 0;
    ID_FIRST_CHILD     = 1;
    ID_NEXT_SIBLING    = 2;
    ID_PREV_SIBLING    = 3;
    ID_FIRST_ATTRIBUTE = 4;
  private
    FNode: PUInt64;
    function GetIsEmpty: Boolean; inline;
    function GetNodeType: TXmlNodeType; inline;
    function GetValue: XmlString;
    procedure SetValue(const AValue: XmlString);
    function GetText: XmlString;
    function GetValueIndex: Integer; inline;
    procedure SetValueIndex(const AValue: Integer); inline;
    function GetParent: TXmlNode;
    procedure SetParent(const AValue: TXmlNode);
    function GetAttributes: TXmlAttributes; inline;
    function GetFirstAttribute: TXmlAttribute;
    procedure SetFirstAttribute(const AValue: TXmlAttribute);
    function GetFirstChild: TXmlNode;
    procedure SetFirstChild(const AValue: TXmlNode);
    function GetNextSibling: TXmlNode;
    procedure SetNextSibling(const AValue: TXmlNode);
    function GetPrevSibling: TXmlNode;
    procedure SetPrevSibling(const AValue: TXmlNode);
    function GetPrevSiblingEx: TXmlNode;
    function GetDocument: TXmlDocument; inline;
  private
    procedure Free;
    procedure InternalAddChild(const AChild: TXmlNode);
    function InternalAddAttribute(const ANameIndex: Integer; const AValue: XmlString): TXmlAttribute;
    function GetBlock: PByte; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { (In)equality operators that can be used to compare two attributes.
      You can also compare against nil-pointer (eg. if (MyAttr <> nil) then...') }
    class operator Equal(const ALeft: TXmlNode; const ARight: Pointer): Boolean; overload; inline; static;
    class operator Equal(const ALeft, ARight: TXmlNode): Boolean; overload; inline; static;
    class operator NotEqual(const ALeft: TXmlNode; const ARight: Pointer): Boolean; overload; inline; static;
    class operator NotEqual(const ALeft, ARight: TXmlNode): Boolean; overload; inline; static;

    { Returns a nil node }
    class function Create: TXmlNode; inline; static;

    { Returns a node enumerator to enable for..in enumeration, as in:
        for var Child in Node do ... }
    function GetEnumerator: TEnumerator; inline;

    { Returns the first child element with a given name.

      Parameters:
        AElementName: the name to search for.

      Returns:
        The first child element with the given element name, or nil if there is
        none. }
    function ElementByName(const AElementName: XmlString): TXmlNode;

    { Returns the first child element with an attribute with a given name and
      value.

      Parameters:
        AAttributeName: the name of the attribute to search for.
        AAttributeValue: the value of the attribute to search for.

      Returns:
        The first child element with an attribute with the given name and value,
        or nil if there is none. }
    function ElementByAttribute(const AAttributeName,
      AAttributeValue: XmlString): TXmlNode; overload;

    { Returns the first child element of a given name, and with an attribute
      with a given name and value.

      Parameters:
        AElementName: the name of the element to search for.
        AAttributeName: the name of the attribute to search for.
        AAttributeValue: the value of the attribute to search for.

      Returns:
        The first child element with the given name that has an attribute with
        the given atrribute name and value, or nil if there is none. }
    function ElementByAttribute(const AElementName, AAttributeName,
      AAttributeValue: XmlString): TXmlNode; overload;

    { Returns the next sibling element with a given name.

      Parameters:
        AElementName: the name to search for.

      Returns:
        The next sibling element with the given element name, or nil if there is
        none. }
    function NextSiblingByName(const AElementName: XmlString): TXmlNode;

    { Returns the previous sibling element with a given name.

      Parameters:
        AElementName: the name to search for.

      Returns:
        The previous sibling element with the given element name, or nil if there
        is none. }
    function PrevSiblingByName(const AElementName: XmlString): TXmlNode;

    { Returns the first attribute with a given name.

      Parameters:
        AAttributeName: the attribute name to search for.

      Returns:
        The first attribute with the given name, or nil if there is none. }
    function AttributeByName(const AAttributeName: XmlString): TXmlAttribute;

    { Adds an attribute.

      Parameters:
        AName: the name of the attribute.
        AValue: the value of the attribute.

      Returns:
        The newly added attribute, or nil if this node is nil.

      This method does *not* check for duplicate attribute names. }
    function AddAttribute(const AName, AValue: XmlString): TXmlAttribute; overload;
    function AddAttribute(const AName: XmlString; const AValue: Boolean): TXmlAttribute; overload; inline;
    function AddAttribute(const AName: XmlString; const AValue: Int32): TXmlAttribute; overload; inline;
    function AddAttribute(const AName: XmlString; const AValue: Int64): TXmlAttribute; overload; inline;
    function AddAttribute(const AName: XmlString; const AValue: Single): TXmlAttribute; overload; inline;
    function AddAttribute(const AName: XmlString; const AValue: Double): TXmlAttribute; overload; inline;

    { Removes an attribute with a given name.

      Parameters:
        AName: the name of the attribute to remove.

      This method does nothing if there is no attribute with the given name,
      or if this node is nil. }
    procedure RemoveAttribute(const AName: XmlString); overload; inline;

    { Removes an attribute.

      Parameters:
        AAttr: the attribute to remove.

      This method does nothing if the attribute does not belong to this node,
      or if this node is nil. }
    procedure RemoveAttribute(const AAttr: TXmlAttribute); overload;

    { Removes all attributes from this node. }
    procedure RemoveAllAttributes;

    { Adds a child to this node.

      Parameters:
        AType: the type of node to add.
        AValue: the value of the node (depending on AType).

      Returns:
        The newly added child node, or nil in case this node is nil.

      It may be easier to use the shortcut methods AddElement, AddText,
      AddCData and AddComment instead. }
    function AddChild(const AType: TXmlNodeType; const AValue: XmlString): TXmlNode;

    { Adds a child element to this node.

      Parameters:
        AName: the name of the element.

      Returns:
        The newly added child element, or nil in case this node is nil.

      This is a shortcut for AddChild(TXmlNodeType.Element, AName). }
    function AddElement(const AName: XmlString): TXmlNode; inline;

    { Adds a child text node to this node.

      Parameters:
        AText: the text of the node.

      Returns:
        The newly added child text node, or nil in case this node is nil.

      This is a shortcut for AddChild(TXmlNodeType.Text, AText). }
    function AddText(const AText: XmlString): TXmlNode; inline;

    { Adds a child CData node to this node.

      Parameters:
        ACData: the CData.

      Returns:
        The newly added child CData node, or nil in case this node is nil.

      This is a shortcut for AddChild(TXmlNodeType.CData, ACData). }
    function AddCData(const ACData: XmlString): TXmlNode; inline;

    { Adds a child comment node to this node.

      Parameters:
        AComment: the comment.

      Returns:
        The newly added child comment node, or nil in case this node is nil.

      This is a shortcut for AddChild(TXmlNodeType.Comment, AComment). }
    function AddComment(const AComment: XmlString): TXmlNode; inline;

    { Removes a child element with a given name.

      Parameters:
        AElementName: the name of the child element to remove.

      This method does nothing if there is no child element with the given name,
      or if this node is nil. }
    procedure RemoveChild(const AElementName: XmlString); overload; inline;

    { Removes a child node.

      Parameters:
        AChild: the child node to remove.

      This method does nothing if the child node does not belong to this node,
      or if this node is nil. }
    procedure RemoveChild(const AChild: TXmlNode); overload;

    { Removes all child nodes from this node. }
    procedure RemoveAllChildren;

    { Whether the node is empty (nil) }
    property IsEmpty: Boolean read GetIsEmpty;

    { The type of the this node:
      * Element: the node is an element (eg. <node>), and may have child nodes.
      * Text: the node represents a text string. This is the text between a
        start and end element.

        For example, given the XML string '<foo>bar</foo>', the <foo> element
        contains a single child node of type Text (with value 'bar').

        A single element may contain multiple text nodes in case these are
        seperated by a child node. For example, '<foo>bar<child/>baz</foo>'.
        Here, the <foo> node contains 3 child nodes:
        - A Text node with value 'bar'
        - An Element node with name 'child'
        - Another Text node with value 'baz'
      * Comment: the node represents a comment (as in <!--foo-->). The Value of
        the node does not contain markup characters (eg. it is just 'foo' in
        this example).
      * CData: the node represents a comment (as in <![CDATA[foo]]>). The Value
        of the node does not contain markup characters (eg. it is just 'foo' in
        this example). }
    property NodeType: TXmlNodeType read GetNodeType;

    { The value of this node. Its meaning depents on the NodeType:
      * For Element nodes, this is the name of the element.
      * For Text nodes, this is the text.
      * For Comment nodes, this is the comment.
      * For CData nodes, this is the CData. }
    property Value: XmlString read GetValue write SetValue;

    { The text of this node. This differs from the Value property in case this
      is an Element:
      * For Element nodes, this is the concatenation of all direct children of
        this node that are of type Text or CData. A space will be added between
        concatenated strings if needed.
      * For Text nodes, this is the text.
      * For Comment nodes, this is the comment.
      * For CData nodes, this is the CData.

      For example, given this XML code:
        <node>foo<child/>bar</node>
      The the Text property of <node> will return 'foo bar' (with a space
      between them) }
    property Text: XmlString read GetText;

    { This parent of this node, or nil if this is the root of the document
      (See IXmlDocument.Root) }
    property Parent: TXmlNode read GetParent;

    { The attributes of this node. This returns a helper type that can be used
      to enumerate all attributes (as in: for var Attr in Node do...).
      Use FirstAttribute to enumerate the attributes yourself.

      Returns an empty set of attributes in case this is not an Element node. }
    property Attributes: TXmlAttributes read GetAttributes;

    { The first attribute of this node, or nil in case this is not an Element
      node, or if the element has no attributes, or this node is nil. You can
      use this to manually enumerate the attributes, as in:

      var Attr := Node.FirstAttribute;
      while (Attr <> nil) do
      begin
        DoSomethingWith(Attr);
        Attr := Attr.Next;
      end; }
    property FirstAttribute: TXmlAttribute read GetFirstAttribute;

    { The first child node of this node, or nil in case this is not an Element
      node, or if the element has no children, or this node is nil. You can use
      this to manually enumerate the child nodes, as in:

      var Child := Node.FirstChild;
      while (Child <> nil) do
      begin
        DoSomethingWith(Child);
        Child := Child.NextSibling;
      end; }
    property FirstChild: TXmlNode read GetFirstChild;

    { The next sibling of this node, or nil in case this is not an Element
      node, or this node is nil, or this node doesn't have any siblings. You can
      use this to manually enumerate the child nodes, as in:

      var Child := Node.FirstChild;
      while (Child <> nil) do
      begin
        DoSomethingWith(Child);
        Child := Child.NextSibling;
      end; }
    property NextSibling: TXmlNode read GetNextSibling;

    { The previous sibling of this node, or nil in case this is not an Element
      node, or this node is nil, or this node doesn't have any siblings. }
    property PrevSibling: TXmlNode read GetPrevSiblingEx;
  end;

  { A XML document. This is the entry point of this XML library.
    To create an instance, use TXmlDocument.Create. }
  IXmlDocument = interface
  ['{9C4D673A-2750-4DE3-B700-AA463996D2F3}']
    {$REGION 'Internal Declarations'}
    function GetRoot: TXmlNode;
    function GetDocumentElement: TXmlNode;
    function GetInternPool: TXmlStringInternPool;
    {$ENDREGION 'Internal Declarations'}

    { Clears the document. }
    procedure Clear;

    { Loads the document from a file.

      Parameters:
        AFilename: the name of the XML file to load.

      Raises:
        EXmlParserError if the XML file is invalid. }
    procedure Load(const AFilename: String); overload;

    { Loads the document from a stream.

      Parameters:
        AStream: the XML stream to load.

      Raises:
        EXmlParserError if the XML stream is invalid.

      Just clears the document in case AStream is nil. }
    procedure Load(const AStream: TStream); overload;

    { Loads the document from a UTF-8 encoded byte array.

      Parameters:
        ABytes: the byte array with UTF-8 encoding XML data.

      Raises:
        EXmlParserError if the XML data is invalid.

      Just clears the document in case ABytes is nil. }
    procedure Load(const ABytes: TBytes); overload;

    { Loads the document using an XML reader.

      Parameters:
        AReader: the XML reader used to load the XML data.

      Raises:
        EXmlParserError if the XML data is invalid.

      Just clears the document in case AReader is nil. }
    procedure Load(const AReader: TXmlReader); overload;

    { Parses an XML string into this document.

      Parameters:
        AXml: the XML data.

      Raises:
        EXmlParserError if the XML data is invalid. }
    procedure Parse(const AXml: XmlString);

    { Saves the XML document to a file.

      Parameters:
        AFilename: the name of the XML file to save to.
        AOptions: (optional) XML formatting options. }
    procedure Save(const AFilename: String;
      const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS); overload;

    { Saves the XML document to a stream.

      Parameters:
        AStream: the stream to save to.
        AOptions: (optional) XML formatting options.

      Does nothing if AStream is nil. }
    procedure Save(const AStream: TStream;
      const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS); overload;

    { Saves the XML document to an XML writer.

      Parameters:
        AWriter: the XML writer to use.

      Does nothing if AWriter is nil. }
    procedure Save(const AWriter: TXmlWriter); overload;

    { Converts the XML document to an UTF-8 encoded byte array.

      Parameters:
        AOptions: (optional) XML formatting options.

      The output XML as an UTF-8 encoded byte array. }
    function ToBytes(const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS): TBytes;

    { Converts the XML document to an XML string.

      Parameters:
        AOptions: (optional) XML formatting options.

      The output XML. }
    function ToXml(const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS): XmlString;

    { The Root of the document. Each document has an implicit root element
      without a name. This is *not* the first element in the XML file (use the
      DocumentElement property for that).

      For example, consider this XML:
        <!--some comment-->
        <foo>bar</foo>

      In this case, the Root node contains two child nodes: the first one is of
      type Comment (with Value 'some comment') and the second one is of type
      Element (with Value 'foo'). The second node is also the one returned by
      the DocumentElement property.

      Note that this property never returns nil. }
    property Root: TXmlNode read GetRoot;

    { The document element node of this document. This is the first child node
      that is of type Element.

      For example, consider this XML:
        <!--some comment-->
        <foo>bar</foo>

      In this case, the DocumentElement property returns the 'foo' element.

      Returns nil if the document is empty. }
    property DocumentElement: TXmlNode read GetDocumentElement;
  end;

  { Implements the IXmlDocument interface }
  TXmlDocument = class(TInterfacedObject, IXmlDocument)
  {$REGION 'Internal Declarations'}
  private class var
    FPageSize: Integer;
    {$IFDEF MSWINDOWS}
    FAllocationGranularity: Integer;
    {$ENDIF}
    {$IFDEF CPU64BITS}
    FBaseAddress: IntPtr;
    {$ENDIF}
  private
    FRoot: TXmlNode;
    FInternPool: TXmlStringInternPool;
    FPointerMap: TXmlPointerMap;
    FBlockCur: PByte;
    FBlockEnd: PByte;
    FFreeList: TStack<PUInt64>;
    FAllocations: TList<Pointer>;
    FNextBlock: PByte;
    FLastBlock: PByte;
    FClearing: Boolean;
  private
    constructor InternalCreate;
    procedure Grow;
    function AllocBlock: Pointer;
    function CreateNode(const AType: TXmlNodeType): TXmlNode;
    procedure ReturnNode(const ANode: TXmlNode); inline;
    function CreateAttribute(const ANameIndex: Integer;
      const AValue: XmlString): TXmlAttribute;
    procedure ReturnAttribute(const AAttr: TXmlAttribute); inline;
  {$IFDEF CPU64BITS}
  private
    class procedure StoreString(const ANodeOrAttr: PUInt64;
      const AValue: XmlString); static;
    class function RetrieveString(const ANodeOrAttr: PUInt64): XmlString; static;
  {$ENDIF}
  protected
    { IXmlDocument }
    function GetRoot: TXmlNode;
    function GetDocumentElement: TXmlNode;
    function GetInternPool: TXmlStringInternPool;

    procedure Clear;

    procedure Load(const AFilename: String); overload;
    procedure Load(const AStream: TStream); overload;
    procedure Load(const ABytes: TBytes); overload;

    procedure Load(const AReader: TXmlReader); overload;
    procedure Parse(const AXml: XmlString);

    procedure Save(const AFilename: String;
      const AOptions: TXmlOutputOptions); overload;
    procedure Save(const AStream: TStream;
      const AOptions: TXmlOutputOptions); overload;
    procedure Save(const AWriter: TXmlWriter); overload;
    function ToBytes(const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS): TBytes;
    function ToXml(const AOptions: TXmlOutputOptions): XmlString;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a new empty document }
    class function Create: IXmlDocument; overload;

    { Creates a new document with a document element.

      Parameters:
        AElementName: name of the element to add. }
    class function Create(const AElementName: XmlString): IXmlDocument; overload;

    destructor Destroy; override;
  end;

implementation

{$POINTERMATH ON}

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ELSE}
  Posix.UniStd,
  Posix.SysMman,
  {$ENDIF}
  Neslib.SysUtils;

const
  BLOCK_SIZE = 4096;
  MIN_DELTA  = 8;
  MAX_DELTA  = BLOCK_SIZE - 8;
  NIL_BITS   = 0;
  HASH_BITS  = $1FF;

type
  PUInt32 = PCardinal;

{ TXmlAttribute }

{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>>

  V: Value string pointer (32 bits)
  +: Whether V is actually an index into the "additional strings" of the string
     pool. Only used on 64-bit platforms when the string pointer does not fit
     into 32 bits.
  -: Unused (5 bits)
  N: Name Index (17 bits)
  >: next sibling (9 bits) }

class operator TXmlAttribute.Equal(const ALeft: TXmlAttribute;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FAttribute = ARight);
end;

class operator TXmlAttribute.Equal(const ALeft, ARight: TXmlAttribute): Boolean;
begin
  Result := (ALeft.FAttribute = ARight.FAttribute);
end;

procedure TXmlAttribute.Free;
begin
  if (FAttribute <> nil) then
  begin
    SetValue(''); // Decrease ref count
    var Doc := GetDocument;
    Assert(Doc <> nil);
    Doc.ReturnAttribute(Self);
  end;
end;

function TXmlAttribute.GetBlock: PByte;
begin
  Result := PByte(UIntPtr(FAttribute) and not (BLOCK_SIZE - 1));
end;

function TXmlAttribute.GetDocument: TXmlDocument;
begin
  var Block := GetBlock;
  if (Block = nil) then
    Result := nil
  else
    Result := TXmlDocument(PPointer(Block)^);
end;

function TXmlAttribute.GetName: XmlString;
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  var Index := GetNameIndex;
  if (Index <= 0) then
    Exit('');

  var Doc := GetDocument;
  Assert(Doc <> nil);
  Result := Doc.FInternPool.Get(Index);
end;

function TXmlAttribute.GetNameIndex: Integer;
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute = nil) then
    Result := 0
  else
  begin
    {$IFDEF CPU32BITS}
    Result := (PUInt32(FAttribute)^ shr 9) and $1FFFF;
    {$ELSE}
    Result := (FAttribute^ shr 9) and $1FFFF;
    {$ENDIF}
  end;
end;

function TXmlAttribute.GetNext: TXmlAttribute;
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute = nil) then
    Result.FAttribute := nil
  else
  begin
    var Bits: UIntPtr;
    {$IFDEF CPU32BITS}
    Bits := PUInt32(FAttribute)^ and $1FF;
    {$ELSE}
    Bits := FAttribute^ and $1FF;
    {$ENDIF}
    if (Bits = NIL_BITS) then
      Result.FAttribute := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FAttribute := Doc.FPointerMap.Get(FAttribute, 0);
    end
    else
    begin
      var Block := GetBlock;
      Result.FAttribute := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlAttribute.GetValue: XmlString;
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute = nil) then
    Exit('');

  {$IFDEF CPU32BITS}
  Result := XmlString(PPointer(FAttribute)[1]);
  {$ELSE}
  Result := TXmlDocument.RetrieveString(FAttribute);
  {$ENDIF}
end;

class operator TXmlAttribute.NotEqual(const ALeft,
  ARight: TXmlAttribute): Boolean;
begin
  Result := (ALeft.FAttribute <> ARight.FAttribute);
end;

class operator TXmlAttribute.NotEqual(const ALeft: TXmlAttribute;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FAttribute <> ARight);
end;

procedure TXmlAttribute.SetName(const AValue: XmlString);
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute <> nil) then
  begin
    var Doc := GetDocument;
    Assert(Doc <> nil);
    var Index: UIntPtr := Doc.FInternPool.Get(AValue);
    {$IFDEF CPU32BITS}
    PUInt32(FAttribute)^ := (PUInt32(FAttribute)^ and $FC0001FF) or (Index shl 9);
    {$ELSE}
    FAttribute^ := (FAttribute^ and $FFFFFFFFFC0001FF) or (Index shl 9);
    {$ENDIF}
  end;
end;

procedure TXmlAttribute.SetNext(const AValue: TXmlAttribute);
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute <> nil) then
  begin
    var Block := GetBlock;
    var Delta: IntPtr := PByte(AValue) - Block;
    if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
    begin
      var Bits: UIntPtr := Delta shr 3;
      {$IFDEF CPU32BITS}
      PUInt32(FAttribute)^ := (PUInt32(FAttribute)^ and $FFFFFE00) or Bits;
      {$ELSE}
      FAttribute^ := (FAttribute^ and $FFFFFFFFFFFFFE00) or Bits;
      {$ENDIF}
    end
    else
    begin
      {$IFDEF CPU32BITS}
      PUInt32(FAttribute)^ := PUInt32(FAttribute)^ or $000001FF;
      {$ELSE}
      FAttribute^ := FAttribute^ or $00000000000001FF;
      {$ENDIF}
      var Doc := TXmlDocument(PPointer(Block)^);
      Assert(Doc <> nil);
      Doc.FPointerMap.Map(FAttribute, 0, AValue.FAttribute);
    end;
  end;
end;

procedure TXmlAttribute.SetValue(const AValue: Int32);
begin
  {$IFDEF XML_UTF8}
  SetValue(IntToUtf8Str(AValue));
  {$ELSE}
  SetValue(IntToStr(AValue));
  {$ENDIF}
end;

procedure TXmlAttribute.SetValue(const AValue: Boolean);
begin
  if (AValue) then
    SetValue(S_TRUE)
  else
    SetValue(S_FALSE);
end;

procedure TXmlAttribute.SetValue(const AValue: Double);
begin
  {$IFDEF XML_UTF8}
  SetValue(FloatToUtf8Str(AValue, USFormatSettings));
  {$ELSE}
  SetValue(FloatToStr(AValue, USFormatSettings));
  {$ENDIF}
end;

procedure TXmlAttribute.SetValue(const AValue: Single);
begin
  {$IFDEF XML_UTF8}
  SetValue(FloatToUtf8Str(AValue, USFormatSettings));
  {$ELSE}
  SetValue(FloatToStr(AValue, USFormatSettings));
  {$ENDIF}
end;

procedure TXmlAttribute.SetValue(const AValue: Int64);
begin
  {$IFDEF XML_UTF8}
  SetValue(IntToUtf8Str(AValue));
  {$ELSE}
  SetValue(IntToStr(AValue));
  {$ENDIF}
end;

procedure TXmlAttribute.SetValue(const AValue: XmlString);
{ VVVVVVVV VVVVVVVV VVVVVVVV VVVVVVVV +-----NN NNNNNNNN NNNNNNN> >>>>>>>> }
begin
  if (FAttribute = nil) then
    Exit;

  {$IFDEF CPU32BITS}
  XmlString(PPointer(FAttribute)[1]) := AValue; // Increase ref count and decrease ref count of old value
  {$ELSE}
  TXmlDocument.StoreString(FAttribute, AValue);
  {$ENDIF}
end;

function TXmlAttribute.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := ADefault;
  var Value := GetValue;
  if (Value = '') then
    Exit;

  {$IFDEF XML_UTF8}
  Value := UpperCase(Value);
  {$ELSE}
  Value := Value.ToUpperInvariant;
  {$ENDIF}

  if (Value = 'TRUE') or (Value = 'YES') or (Value = '1') then
    Result := True
  else if (Value = 'FALSE') or (Value = 'NO') or (Value = '0') then
    Result := False;
end;

function TXmlAttribute.ToDouble(const ADefault: Double): Double;
begin
  Result := StrToFloatDef(Value, ADefault, USFormatSettings);
end;

function TXmlAttribute.ToInt32(const ADefault: Int32): Int32;
begin
  Result := StrToIntDef(Value, ADefault);
end;

function TXmlAttribute.ToInt64(const ADefault: Int64): Int64;
begin
  Result := StrToInt64Def(Value, ADefault);
end;

function TXmlAttribute.ToInteger(const ADefault: Integer): Integer;
begin
  Result := ToInt32(ADefault);
end;

function TXmlAttribute.ToSingle(const ADefault: Single): Single;
begin
  Result := StrToFloatDef(Value, ADefault, USFormatSettings);
end;

{ TXmlAttribute.TEnumerator }

constructor TXmlAttribute.TEnumerator.Create(const ANode: PUInt64);
begin
  var Node: TXmlNode;
  Node.FNode := ANode;
  FCurrent := Node.FirstAttribute.FAttribute;
end;

function TXmlAttribute.TEnumerator.GetCurrent: TXmlAttribute;
begin
  Result.FAttribute := FCurrent;
  FCurrent := Result.Next.FAttribute;
end;

function TXmlAttribute.TEnumerator.MoveNext: Boolean;
begin
  Result := (FCurrent <> nil);
end;

{ TXmlAttributes }

function TXmlAttributes.GetEnumerator: TXmlAttribute.TEnumerator;
begin
  Result := TXmlAttribute.TEnumerator.Create(FNode);
end;

{ TXmlNode }

{ For Elements:
  VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT

  For Text/Comment/CData:
  SSSSSSSS SSSSSSSS SSSSSSSS SSSSSSSS +--<<<<< <<<<>>>> >>>>>PPP PPPPPPTT

  T: Node Type (2 bits)
  P: Parent (9 bits)
  >: next sibling (9 bits)
  <: prev sibling (9 bits)
  C: first Child (9 bits)
  A: Attribute (9 bits)
  V: Value Index (17 bits)
  S: String pointer (32 bits)
  +: Whether S is actually an index into the "additional strings" of the string
     pool. Only used on 64-bit platforms when the string pointer does not fit
     into 32 bits.
  -: Unused (2 bits) }

function TXmlNode.AddAttribute(const AName: XmlString;
  const AValue: Int32): TXmlAttribute;
begin
  {$IFDEF XML_UTF8}
  Result := AddAttribute(AName, IntToUtf8Str(AValue));
  {$ELSE}
  Result := AddAttribute(AName, IntToStr(AValue));
  {$ENDIF}
end;

function TXmlNode.AddAttribute(const AName: XmlString;
  const AValue: Boolean): TXmlAttribute;
begin
  if (AValue) then
    Result := AddAttribute(AName, TXmlAttribute.S_TRUE)
  else
    Result := AddAttribute(AName, TXmlAttribute.S_FALSE);
end;

function TXmlNode.AddAttribute(const AName, AValue: XmlString): TXmlAttribute;
begin
  if (FNode = nil) then
  begin
    Result.FAttribute := nil;
    Exit;
  end;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var Index := Doc.FInternPool.Get(AName);
  Result := InternalAddAttribute(Index, AValue);
end;

function TXmlNode.AddAttribute(const AName: XmlString;
  const AValue: Double): TXmlAttribute;
begin
  {$IFDEF XML_UTF8}
  Result := AddAttribute(AName, FloatToUtf8Str(AValue, USFormatSettings));
  {$ELSE}
  Result := AddAttribute(AName, FloatToStr(AValue, USFormatSettings));
  {$ENDIF}
end;

function TXmlNode.AddCData(const ACData: XmlString): TXmlNode;
begin
  Result := AddChild(TXmlNodeType.CData, ACData);
end;

function TXmlNode.AddChild(const AType: TXmlNodeType;
  const AValue: XmlString): TXmlNode;
begin
  if (FNode = nil) then
  begin
    Result.FNode := nil;
    Exit;
  end;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  Result := Doc.CreateNode(AType);
  InternalAddChild(Result);
  Result.SetValue(AValue);
end;

function TXmlNode.AddComment(const AComment: XmlString): TXmlNode;
begin
  Result := AddChild(TXmlNodeType.Comment, AComment);
end;

function TXmlNode.AddElement(const AName: XmlString): TXmlNode;
begin
  Result := AddChild(TXmlNodeType.Element, AName);
end;

function TXmlNode.AddText(const AText: XmlString): TXmlNode;
begin
  Result := AddChild(TXmlNodeType.Text, AText);
end;

function TXmlNode.AddAttribute(const AName: XmlString;
  const AValue: Single): TXmlAttribute;
begin
  {$IFDEF XML_UTF8}
  Result := AddAttribute(AName, FloatToUtf8Str(AValue, USFormatSettings));
  {$ELSE}
  Result := AddAttribute(AName, FloatToStr(AValue, USFormatSettings));
  {$ENDIF}
end;

function TXmlNode.AddAttribute(const AName: XmlString;
  const AValue: Int64): TXmlAttribute;
begin
  {$IFDEF XML_UTF8}
  Result := AddAttribute(AName, IntToUtf8Str(AValue));
  {$ELSE}
  Result := AddAttribute(AName, IntToStr(AValue));
  {$ENDIF}
end;

function TXmlNode.AttributeByName(const AAttributeName: XmlString): TXmlAttribute;
begin
  Result.FAttribute := nil;
  if (FNode = nil) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var Index := Doc.FInternPool.Find(AAttributeName);
  if (Index < 0) then
    Exit;

  Result := GetFirstAttribute;
  while (Result <> nil) do
  begin
    if (Result.GetNameIndex = Index) then
      Exit;

    Result := Result.Next;
  end;
end;

class function TXmlNode.Create: TXmlNode;
begin
  Result.FNode := nil;
end;

function TXmlNode.ElementByAttribute(const AAttributeName,
  AAttributeValue: XmlString): TXmlNode;
begin
  Result.FNode := nil;
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var NameIndex := Doc.FInternPool.Find(AAttributeName);
  if (NameIndex < 0) then
    Exit;

  Result := FirstChild;
  while (Result <> nil) do
  begin
    var Attr := Result.FirstAttribute;
    while (Attr <> nil) do
    begin
      if (Attr.GetNameIndex = NameIndex) and (Attr.Value = AAttributeValue) then
        Exit;

      Attr := Attr.Next;
    end;
    Result := Result.NextSibling;
  end;
end;

function TXmlNode.ElementByAttribute(const AElementName, AAttributeName,
  AAttributeValue: XmlString): TXmlNode;
begin
  Result.FNode := nil;
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);

  var ElementNameIndex := Doc.FInternPool.Find(AElementName);
  if (ElementNameIndex < 0) then
    Exit;

  var AttrNameIndex := Doc.FInternPool.Find(AAttributeName);
  if (AttrNameIndex < 0) then
    Exit;

  Result := GetFirstChild;
  while (Result <> nil) do
  begin
    if (Result.GetNodeType = TXmlNodeType.Element) and (Result.GetValueIndex = ElementNameIndex) then
    begin
      var Attr := Result.FirstAttribute;
      while (Attr <> nil) do
      begin
        if (Attr.GetNameIndex = AttrNameIndex) and (Attr.Value = AAttributeValue) then
          Exit;

        Attr := Attr.Next;
      end;
    end;

    Result := Result.GetNextSibling;
  end;
end;

function TXmlNode.ElementByName(const AElementName: XmlString): TXmlNode;
begin
  Result.FNode := nil;
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var Index := Doc.FInternPool.Find(AElementName);
  if (Index < 0) then
    Exit;

  Result := GetFirstChild;
  while (Result <> nil) do
  begin
    if (Result.GetNodeType = TXmlNodeType.Element) and (Result.GetValueIndex = Index) then
      Exit;

    Result := Result.GetNextSibling;
  end;
end;

class operator TXmlNode.Equal(const ALeft, ARight: TXmlNode): Boolean;
begin
  Result := (ALeft.FNode = ARight.FNode);
end;

class operator TXmlNode.Equal(const ALeft: TXmlNode;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FNode = ARight);
end;

procedure TXmlNode.Free;
begin
  if (FNode <> nil) then
  begin
    if (GetNodeType <> TXmlNodeType.Element) then
      SetValue(''); // Decrease ref count

    var Attr := GetFirstAttribute;
    while (Attr <> nil) do
    begin
      var NextAttr := Attr.GetNext;
      Attr.Free;
      Attr := NextAttr;
    end;

    var Node := GetFirstChild;
    while (Node <> nil) do
    begin
      var Next := Node.GetNextSibling;
      Node.Free;
      Node := Next;
    end;

    var Doc := GetDocument;
    Assert(Doc <> nil);
    Doc.ReturnNode(Self);

    FNode := nil;
  end;
end;

function TXmlNode.GetAttributes: TXmlAttributes;
begin
  Result.FNode := FNode;
end;

function TXmlNode.GetBlock: PByte;
begin
  Result := PByte(UIntPtr(FNode) and not (BLOCK_SIZE - 1));
end;

function TXmlNode.GetDocument: TXmlDocument;
begin
  var Block := GetBlock;
  Result := TXmlDocument(PPointer(Block)^);
end;

function TXmlNode.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FNode);
end;

function TXmlNode.GetFirstAttribute: TXmlAttribute;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Result.FAttribute := nil
  else
  begin
    {$IFDEF CPU32BITS}
    var Bits: UIntPtr := (PUInt32(FNode)[1] shr 6) and $1FF;
    {$ELSE}
    var Bits: UIntPtr := (FNode^ shr 38) and $1FF;
    {$ENDIF}
    if (Bits = NIL_BITS) then
      Result.FAttribute := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FAttribute := Doc.FPointerMap.Get(FNode, ID_FIRST_ATTRIBUTE);
    end
    else
    begin
      var Block := GetBlock;
      Result.FAttribute := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlNode.GetFirstChild: TXmlNode;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Result.FNode := nil
  else
  begin
    var Bits: UIntPtr := (FNode^ shr 29) and $1FF;
    if (Bits = NIL_BITS) then
      Result.FNode := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FNode := Doc.FPointerMap.Get(FNode, ID_FIRST_CHILD);
    end
    else
    begin
      var Block := GetBlock;
      Result.FNode := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlNode.GetIsEmpty: Boolean;
begin
  Result := (FNode = nil);
end;

function TXmlNode.GetNextSibling: TXmlNode;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result.FNode := nil
  else
  begin
    {$IFDEF CPU32BITS}
    var Bits: UIntPtr := (PUInt32(FNode)^ shr 11) and $1FF;
    {$ELSE}
    var Bits: UIntPtr := (FNode^ shr 11) and $1FF;
    {$ENDIF}
    if (Bits = NIL_BITS) then
      Result.FNode := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FNode := Doc.FPointerMap.Get(FNode, ID_NEXT_SIBLING);
    end
    else
    begin
      var Block := GetBlock;
      Result.FNode := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlNode.GetNodeType: TXmlNodeType;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result := TXmlNodeType.Element
  else
    {$IFDEF CPU32BITS}
    Result := TXmlNodeType(PUInt32(FNode)^ and 3);
    {$ELSE}
    Result := TXmlNodeType(FNode^ and 3);
    {$ENDIF}
end;

function TXmlNode.GetParent: TXmlNode;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result.FNode := nil
  else
  begin
    {$IFDEF CPU32BITS}
    var Bits: UIntPtr := (PUInt32(FNode)^ shr 2) and $1FF;
    {$ELSE}
    var Bits: UIntPtr := (FNode^ shr 2) and $1FF;
    {$ENDIF}
    if (Bits = NIL_BITS) then
      Result.FNode := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FNode := Doc.FPointerMap.Get(FNode, ID_PARENT);
    end
    else
    begin
      var Block := GetBlock;
      Result.FNode := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlNode.GetPrevSibling: TXmlNode;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result.FNode := nil
  else
  begin
    {$IFDEF CPU32BITS}
    var Bits: UIntPtr := (PUInt32(FNode)^ shr 20) and $1FF;
    {$ELSE}
    var Bits: UIntPtr := (FNode^ shr 20) and $1FF;
    {$ENDIF}
    if (Bits = NIL_BITS) then
      Result.FNode := nil
    else if (Bits = HASH_BITS) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      Result.FNode := Doc.FPointerMap.Get(FNode, ID_PREV_SIBLING);
    end
    else
    begin
      var Block := GetBlock;
      Result.FNode := Pointer(Block + (Bits shl 3));
    end;
  end;
end;

function TXmlNode.GetPrevSiblingEx: TXmlNode;
{ As PrevSibling, but returns nil in case there is no "real" previous sibling
  (instead of the last child because PrevSibling is circular) }
begin
  Result := GetPrevSibling;
  if (Result.GetNextSibling = nil) then
    Result.FNode := nil;
end;

function TXmlNode.GetText: XmlString;
begin
  if (FNode = nil) then
    Result := ''
  else if (GetNodeType = TXmlNodeType.Element) then
  begin
    Result := '';
    var Child := GetFirstChild;
    while (Child <> nil) do
    begin
      if (Child.NodeType in [TXmlNodeType.Text, TXmlNodeType.CData]) then
      begin
        var ChildText := Child.Value;
        if (ChildText <> '') then
        begin
          if (Result <> '') and (Result[Low(XmlString) + Length(Result) - 1] <> ' ') and
            (ChildText <> '') and (ChildText[Low(XmlString)] <> ' ')
          then
            Result := Result + ' ';
          Result := Result + ChildText;
        end;
      end;
      Child := Child.GetNextSibling;
    end;
  end
  else
    Result := GetValue;
end;

function TXmlNode.GetValue: XmlString;
{ For Elements:
  VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT

  For Text/Comment/CData:
  SSSSSSSS SSSSSSSS SSSSSSSS SSSSSSSS +--<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result := ''
  else if (GetNodeType = TXmlNodeType.Element) then
  begin
    var Doc := GetDocument;
    Assert(Doc <> nil);
    Result := Doc.FInternPool.Get(GetValueIndex);
  end
  else
  begin
    {$IFDEF CPU32BITS}
    Result := XmlString(PPointer(FNode)[1]);
    {$ELSE}
    Result := TXmlDocument.RetrieveString(FNode);
    {$ENDIF}
  end;
end;

function TXmlNode.GetValueIndex: Integer;
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode = nil) then
    Result := 0
  else
  begin
    Assert(GetNodeType = TXmlNodeType.Element);
    {$IFDEF CPU32BITS}
    Result := PUInt32(FNode)[1] shr 15;
    {$ELSE}
    Result := FNode^ shr 47;
    {$ENDIF}
  end;
end;

function TXmlNode.InternalAddAttribute(const ANameIndex: Integer;
  const AValue: XmlString): TXmlAttribute;
begin
  var Doc := GetDocument;
  Assert(Doc <> nil);

  Result := Doc.CreateAttribute(ANameIndex, AValue);
  var Prev := GetFirstAttribute;
  if (Prev = nil) then
    SetFirstAttribute(Result)
  else
  begin
    while True do
    begin
      var Next := Prev.GetNext;
      if (Next = nil) then
        Break;

      Prev := Next;
    end;
    Prev.SetNext(Result);
  end;
end;

procedure TXmlNode.InternalAddChild(const AChild: TXmlNode);
begin
  Assert(FNode <> nil);
  Assert(NodeType = TXmlNodeType.Element);
  Assert(AChild <> nil);

  AChild.SetParent(Self);
  var Head := GetFirstChild;
  if (Head = nil) then
  begin
    SetFirstChild(AChild);
    AChild.SetPrevSibling(AChild);
  end
  else
  begin
    var Tail := Head.GetPrevSibling;
    Assert(Tail <> nil);
    Tail.SetNextSibling(AChild);
    AChild.SetPrevSibling(Tail);
    Head.SetPrevSibling(AChild);
  end;
end;

function TXmlNode.NextSiblingByName(const AElementName: XmlString): TXmlNode;
begin
  Result.FNode := nil;
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var Index := Doc.FInternPool.Find(AElementName);
  if (Index < 0) then
    Exit;

  Result := GetNextSibling;
  while (Result <> nil) do
  begin
    if (Result.GetValueIndex = Index) then
      Exit;

    Result := Result.NextSibling;
  end;
end;

class operator TXmlNode.NotEqual(const ALeft, ARight: TXmlNode): Boolean;
begin
  Result := (ALeft.FNode <> ARight.FNode);
end;

class operator TXmlNode.NotEqual(const ALeft: TXmlNode;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FNode <> ARight);
end;

function TXmlNode.PrevSiblingByName(const AElementName: XmlString): TXmlNode;
begin
  Result.FNode := nil;
  if (FNode = nil) or (GetNodeType <> TXmlNodeType.Element) then
    Exit;

  var Doc := GetDocument;
  Assert(Doc <> nil);
  var Index := Doc.FInternPool.Find(AElementName);
  if (Index < 0) then
    Exit;

  Result := GetPrevSibling;
  while (Result.NextSibling <> nil) do
  begin
    if (Result.GetValueIndex = Index) then
      Exit;

    Result := Result.GetPrevSibling;
  end;
  Result.FNode := nil;
end;

procedure TXmlNode.RemoveAllAttributes;
begin
  var Attr := FirstAttribute;
  if (Attr <> nil) then
  begin
    repeat
      var Next := Attr.Next;
      Attr.Free;
      Attr := Next;
    until (Attr = nil);
    SetFirstAttribute(Attr);
  end;
end;

procedure TXmlNode.RemoveAllChildren;
begin
  var Child := FirstChild;
  if (Child <> nil) then
  begin
    repeat
      var Next := Child.NextSibling;
      Child.Free;
      Child := Next;
    until (Child = nil);
    SetFirstChild(Child);
  end;
end;

procedure TXmlNode.RemoveAttribute(const AAttr: TXmlAttribute);
begin
  if (AAttr = nil) or (FNode = nil) then
    Exit;

  var Prev := FirstAttribute;
  if (Prev = nil) then
    Exit;

  if (AAttr = Prev) then
    SetFirstAttribute(AAttr.Next)
  else
  begin
    var Next := Prev.Next;
    while (Next <> nil) do
    begin
      if (AAttr = Next) then
      begin
        Prev.SetNext(AAttr.Next);
        Break;
      end;
      Prev := Next;
      Next := Next.Next;
    end;
    if (Next = nil) then
      Exit;
  end;

  AAttr.Free;
end;

procedure TXmlNode.RemoveChild(const AChild: TXmlNode);
begin
  if (AChild = nil) or (AChild.Parent <> Self) then
    Exit;

  var Node := FirstChild;
  if (Node = nil) then
    Exit;

  var Next := AChild.NextSibling;
  var Prev := AChild.GetPrevSibling;

  if (AChild = Node) then
  begin
    Next.SetPrevSibling(Prev);
    SetFirstChild(Next);
  end
  else
  begin
    Prev.SetNextSibling(Next);
    Next.SetPrevSibling(Prev);
    if (Next = nil) then
      Node.SetPrevSibling(Prev);
  end;

  AChild.Free;
end;

procedure TXmlNode.RemoveChild(const AElementName: XmlString);
begin
  var Child := ElementByName(AElementName);
  RemoveChild(Child);
end;

procedure TXmlNode.RemoveAttribute(const AName: XmlString);
begin
  var Attr := AttributeByName(AName);
  RemoveAttribute(Attr);
end;

procedure TXmlNode.SetFirstAttribute(const AValue: TXmlAttribute);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    Assert(GetNodeType = TXmlNodeType.Element);
    if (AValue.FAttribute = nil) then
    begin
      {$IFDEF CPU32BITS}
      PUInt32(FNode)[1] := PUInt32(FNode)[1] and $FFFF803F;
      {$ELSE}
      FNode^ := FNode^ and $FFFF803FFFFFFFFF;
      {$ENDIF}
    end
    else
    begin
      var Block := GetBlock;
      var Delta: Intptr := PByte(AValue) - Block;
      Assert((Delta and 7) = 0);
      if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
      begin
        {$IFDEF CPU32BITS}
        var Bits: UIntPtr := Delta shl 3; // = (Delta shr 3) shl 6;
        PUInt32(FNode)[1] := (PUInt32(FNode)[1] and $FFFF803F) or Bits;
        {$ELSE}
        var Bits: UIntPtr := Delta shl 35; // = (Delta shr 3) shl 38;
        FNode^ := (FNode^ and $FFFF803FFFFFFFFF) or Bits;
        {$ENDIF}
      end
      else
      begin
        {$IFDEF CPU32BITS}
        PUInt32(FNode)[1] := PUInt32(FNode)[1] or $00007FC0;
        {$ELSE}
        FNode^ := FNode^ or $00007FC000000000;
        {$ENDIF}

        var Doc := TXmlDocument(PPointer(Block)^);
        Assert(Doc <> nil);
        Doc.FPointerMap.Map(FNode, ID_FIRST_ATTRIBUTE, AValue.FAttribute);
      end;
    end;
  end;
end;

procedure TXmlNode.SetFirstChild(const AValue: TXmlNode);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    Assert(GetNodeType = TXmlNodeType.Element);
    if (AValue.FNode =  nil) then
      FNode^ := FNode^ and $FFFFFFC01FFFFFFF
    else
    begin
      var Block := GetBlock;
      var Delta: IntPtr := PByte(AValue) - Block;
      Assert((Delta and 7) = 0);
      if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
      begin
        var Bits: UInt64 := UInt64(Delta) shl 26; // = (Delta shr 3) shl 29;
        FNode^ := (FNode^ and $FFFFFFC01FFFFFFF) or Bits;
      end
      else
      begin
        FNode^ := FNode^ or $0000003FE0000000;
        var Doc := TXmlDocument(PPointer(Block)^);
        Assert(Doc <> nil);
        Doc.FPointerMap.Map(FNode, ID_FIRST_CHILD, AValue.FNode);
      end;
    end;
  end;
end;

procedure TXmlNode.SetNextSibling(const AValue: TXmlNode);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    if (AValue.FNode =  nil) then
    begin
      {$IFDEF CPU32BITS}
      PUInt32(FNode)^ := PUInt32(FNode)^ and $FFF007FF;
      {$ELSE}
      FNode^ := FNode^ and $FFFFFFFFFFF007FF;
      {$ENDIF}
    end
    else
    begin
      var Block := GetBlock;
      var Delta: IntPtr := PByte(AValue) - Block;
      Assert((Delta and 7) = 0);
      if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
      begin
        var Bits: UIntPtr := Delta shl 8; // = (Delta shr 3) shl 11;
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := (PUInt32(FNode)^ and $FFF007FF) or Bits;
        {$ELSE}
        FNode^ := (FNode^ and $FFFFFFFFFFF007FF) or Bits;
        {$ENDIF}
      end
      else
      begin
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := PUInt32(FNode)^ or $000FF800;
        {$ELSE}
        FNode^ := FNode^ or $00000000000FF800;
        {$ENDIF}

        var Doc := TXmlDocument(PPointer(Block)^);
        Assert(Doc <> nil);
        Doc.FPointerMap.Map(FNode, ID_NEXT_SIBLING, AValue.FNode);
      end;
    end;
  end;
end;

procedure TXmlNode.SetParent(const AValue: TXmlNode);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    if (AValue.FNode =  nil) then
    begin
      {$IFDEF CPU32BITS}
      PUInt32(FNode)^ := PUInt32(FNode)^ and $FFFFF803;
      {$ELSE}
      FNode^ := FNode^ and $FFFFFFFFFFFFF803;
      {$ENDIF}
    end
    else
    begin
      var Block := GetBlock;
      var Delta: IntPtr := PByte(AValue) - Block;
      Assert((Delta and 7) = 0);
      if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
      begin
        var Bits: UIntPtr := Delta shr 1; // = (Delta shr 3) shl 2;
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := (PUInt32(FNode)^ and $FFFFF803) or Bits;
        {$ELSE}
        FNode^ := (FNode^ and $FFFFFFFFFFFFF803) or Bits;
        {$ENDIF}
      end
      else
      begin
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := PUInt32(FNode)^ or $000007FC;
        {$ELSE}
        FNode^ := FNode^ or $00000000000007FC;
        {$ENDIF}
        var Doc := TXmlDocument(PPointer(Block)^);
        Assert(Doc <> nil);
        Doc.FPointerMap.Map(FNode, ID_PARENT, AValue.FNode);
      end;
    end;
  end;
end;

procedure TXmlNode.SetPrevSibling(const AValue: TXmlNode);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    if (AValue.FNode =  nil) then
    begin
      {$IFDEF CPU32BITS}
      PUInt32(FNode)^ := PUInt32(FNode)^ and $E00FFFFF;
      {$ELSE}
      FNode^ := FNode^ and $FFFFFFFFE00FFFFF;
      {$ENDIF}
    end
    else
    begin
      var Block := GetBlock;
      var Delta: IntPtr := PByte(AValue) - Block;
      Assert((Delta and 7) = 0);
      if (Delta >= MIN_DELTA) and (Delta < MAX_DELTA) then
      begin
        var Bits: UIntPtr := Delta shl 17; // = (Delta shr 3) shl 20;
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := (PUInt32(FNode)^ and $E00FFFFF) or Bits;
        {$ELSE}
        FNode^ := (FNode^ and $FFFFFFFFE00FFFFF) or Bits;
        {$ENDIF}
      end
      else
      begin
        {$IFDEF CPU32BITS}
        PUInt32(FNode)^ := PUInt32(FNode)^ or $1FF00000;
        {$ELSE}
        FNode^ := FNode^ or $000000001FF00000;
        {$ENDIF}
        var Doc := TXmlDocument(PPointer(Block)^);
        Assert(Doc <> nil);
        Doc.FPointerMap.Map(FNode, ID_PREV_SIBLING, AValue.FNode);
      end;
    end;
  end;
end;

procedure TXmlNode.SetValue(const AValue: XmlString);
{ For Elements:
  VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT

  For Text/Comment/CData:
  SSSSSSSS SSSSSSSS SSSSSSSS SSSSSSSS +--<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  if (FNode <> nil) then
  begin
    if (GetNodeType = TXmlNodeType.Element) then
    begin
      var Doc := GetDocument;
      Assert(Doc <> nil);
      SetValueIndex(Doc.FInternPool.Get(AValue));
    end
    else
    begin
      {$IFDEF CPU32BITS}
      XmlString(PPointer(FNode)[1]) := AValue; // Increase ref count and decrease ref count of old value
      {$ELSE}
      TXmlDocument.StoreString(FNode, AValue);
      {$ENDIF}
    end;
  end;
end;

procedure TXmlNode.SetValueIndex(const AValue: Integer);
{ VVVVVVVV VVVVVVVV VAAAAAAA AACCCCCC CCC<<<<< <<<<>>>> >>>>>PPP PPPPPPTT }
begin
  Assert(Cardinal(AValue) < (1 shl 17));
  if (FNode <> nil) then
  begin
    Assert(GetNodeType = TXmlNodeType.Element);
    {$IFDEF CPU32BITS}
    PUInt32(FNode)[1] := (PUInt32(FNode)[1] and $00007FFF) or (UIntPtr(AValue) shl 15);
    {$ELSE}
    FNode^ := (FNode^ and $00007FFFFFFFFFFF) or (UIntPtr(AValue) shl 47);
    {$ENDIF}
  end;
end;

{ TXmlNode.TEnumerator }

constructor TXmlNode.TEnumerator.Create(const ANode: PUInt64);
begin
  var Node: TXmlNode;
  Node.FNode := ANode;
  FCurrent := Node.FirstChild.FNode;
end;

function TXmlNode.TEnumerator.GetCurrent: TXmlNode;
begin
  Result.FNode := FCurrent;
  FCurrent := Result.NextSibling.FNode;
end;

function TXmlNode.TEnumerator.MoveNext: Boolean;
begin
  Result := (FCurrent <> nil);
end;

{ TXmlDocument }

{$IFDEF MSWINDOWS}
function TXmlDocument.AllocBlock: Pointer;
begin
  if (FNextBlock >= FLastBlock) then
  begin
    var Page := VirtualAlloc(nil, FAllocationGranularity, MEM_RESERVE, PAGE_NOACCESS);
    Assert(Page <> nil);
    FAllocations.Add(Page);
    FNextBlock := Page;
    FLastBlock := FNextBlock + FAllocationGranularity;
  end;

  Result := VirtualAlloc(FNextBlock, BLOCK_SIZE, MEM_COMMIT, PAGE_READWRITE);
  Assert(Result = FNextBlock);
  Assert((UIntPtr(Result) and (BLOCK_SIZE - 1)) = 0);
  FillChar(Result^, BLOCK_SIZE, 0);
  Inc(FNextBlock, BLOCK_SIZE);
end;
{$ELSE}
function TXmlDocument.AllocBlock: Pointer;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  if (FPageSize = BLOCK_SIZE) then
  begin
    { The page size matches the block size. This should be the case on macOS
      and Android. }
    Result := mmap(nil, BLOCK_SIZE, PROT_READ or PROT_WRITE, MAP_PRIVATE or MAP_ANON, -1, 0);
    Assert(Result <> nil);
    FAllocations.Add(Result);
  end
  else
  begin
    { The page size is a multiple of BLOCK_SIZE. This is the case on iOS. }
    Assert((FPageSize > BLOCK_SIZE) and ((FPageSize and (BLOCK_SIZE - 1)) = 0));

    if (FNextBlock >= FLastBlock) then
    begin
      var Page := mmap(nil, FPageSize, PROT_READ or PROT_WRITE, MAP_PRIVATE or MAP_ANON, -1, 0);
      Assert(Page <> nil);
      FAllocations.Add(Page);
      FNextBlock := Page;
      FLastBlock := FNextBlock + FPageSize;
    end;

    Result := FNextBlock;
    Inc(FNextBlock, BLOCK_SIZE);
  end;
  Assert((UIntPtr(Result) and (BLOCK_SIZE - 1)) = 0);
  FillChar(Result^, BLOCK_SIZE, 0);
  {$WARN SYMBOL_PLATFORM ON}
end;
{$ENDIF}

procedure TXmlDocument.Clear;
begin
  FClearing := True;
  try
    FRoot.Free;
    if (FInternPool <> nil) then
      FInternPool.Clear;
    if (FPointerMap <> nil) then
      FPointerMap.Clear;
    if (FFreeList <> nil) then
      FFreeList.Clear;
    {$IFDEF MSWINDOWS}
    if (FAllocations <> nil) then
    begin
      for var I := FAllocations.Count - 1 downto 0 do
        VirtualFree(FAllocations[I], 0, MEM_RELEASE);
      FAllocations.Clear;
      FNextBlock := nil;
      FLastBlock := nil;
    end;
    {$ENDIF}
    FBlockCur := nil;
    FBlockEnd := nil;
  finally
    FClearing := False;
  end;
end;

class function TXmlDocument.Create: IXmlDocument;
begin
  Result := TXmlDocument.InternalCreate;
end;

class function TXmlDocument.Create(const AElementName: XmlString): IXmlDocument;
begin
  Result := TXmlDocument.InternalCreate;
  Result.Root.AddElement(AElementName);
end;

function TXmlDocument.CreateAttribute(const ANameIndex: Integer;
  const AValue: XmlString): TXmlAttribute;
{ Value (32 bits), Unused(6 bits), NameIndex (17 bits), Next (9 bits) }
begin
  Assert(Cardinal(ANameIndex) < (1 shl 17));
  if (not FFreeList.TryPop(Result.FAttribute)) then
  begin
    if (FBlockCur >= FBlockEnd) then
      Grow;

    Result.FAttribute := Pointer(FBlockCur);
  end;
  Assert(Result.FAttribute^ = 0);

  {$IFDEF CPU32BITS}
  XmlString(PPointer(Result.FAttribute)[1]) := AValue; // Increase ref count
  {$ELSE}
  StoreString(Result.FAttribute, AValue);
  {$ENDIF}

  Result.FAttribute^ := Result.FAttribute^ or (Cardinal(ANameIndex) shl 9);
  Inc(FBlockCur, 8);
end;

function TXmlDocument.CreateNode(const AType: TXmlNodeType): TXmlNode;
begin
  if (not FFreeList.TryPop(Result.FNode)) then
  begin
    if (FBlockCur >= FBlockEnd) then
      Grow;

    Result.FNode := Pointer(FBlockCur);
  end;
  Result.FNode^ := Ord(AType);
  Inc(FBlockCur, 8);
end;

destructor TXmlDocument.Destroy;
begin
  Clear;
  FFreeList.Free;
  FPointerMap.Free;
  FInternPool.Free;
  FAllocations.Free;
  inherited;
end;

function TXmlDocument.GetDocumentElement: TXmlNode;
begin
  if (FRoot <> nil) then
  begin
    Result := FRoot.FirstChild;
    while (Result <> nil) do
    begin
      if (Result.NodeType = TXmlNodeType.Element) then
        Exit;

      Result := Result.NextSibling;
    end;
  end;
  Result.FNode := nil;
end;

function TXmlDocument.GetInternPool: TXmlStringInternPool;
begin
  Result := FInternPool;
end;

function TXmlDocument.GetRoot: TXmlNode;
begin
  if (FRoot = nil) then
    { No document loaded. Create a new root. }
    FRoot := CreateNode(TXmlNodeType.Element);

  Result := FRoot;
end;

procedure TXmlDocument.Grow;
begin
  var Block := AllocBlock;
  PPointer(Block)^ := Pointer(Self);
  FBlockCur := Block;
  Inc(FBlockCur, 8);
  FBlockEnd := Block;
  Inc(FBlockEnd, BLOCK_SIZE - 8);
//    PPointer(FBlockEnd)^ := FInternPool;
end;

constructor TXmlDocument.InternalCreate;
begin
  inherited Create;
  FInternPool := TXmlStringInternPool.Create;
  FPointerMap := TXmlPointerMap.Create;
  FFreeList := TStack<PUInt64>.Create;
  FAllocations := TList<Pointer>.Create;

  if (FPageSize = 0) then
  begin
    {$IFDEF MSWINDOWS}
    var Info: TSystemInfo;
    GetSystemInfo(Info);
    FPageSize := Info.dwPageSize;
    FAllocationGranularity := Info.dwAllocationGranularity;
    Assert(FPageSize = BLOCK_SIZE);
    {$ELSE}
    FPageSize := sysconf(_SC_PAGESIZE);
    {$ENDIF}

    {$IFDEF CPU64BITS}
    FBaseAddress := IntPtr(Self);
    {$ENDIF}
  end;
end;

procedure TXmlDocument.Load(const AStream: TStream);
begin
  if (AStream = nil) then
  begin
    Clear;
    Exit;
  end;

  var Reader := TXmlReader.Load(AStream, FInternPool);
  try
    Load(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TXmlDocument.Load(const ABytes: TBytes);
begin
  if (ABytes = nil) then
  begin
    Clear;
    Exit;
  end;

  var Reader := TXmlReader.Load(ABytes, FInternPool);
  try
    Load(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TXmlDocument.Load(const AFilename: String);
begin
  var Reader := TXmlReader.Load(AFilename, FInternPool);
  try
    Load(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TXmlDocument.Load(const AReader: TXmlReader);
begin
  Clear;
  if (AReader = nil) then
    Exit;

  FRoot := CreateNode(TXmlNodeType.Element);
  var CurNode := FRoot;
  var State: TXmlReaderState;
  while AReader.Next(State) do
  begin
    case State of
      TXmlReaderState.StartElement:
        begin
          Assert(CurNode <> nil);
          var NewNode := CreateNode(TXmlNodeType.Element);
          CurNode.InternalAddChild(NewNode);

          NewNode.SetValueIndex(AReader.ValueIndex);
          for var I := 0 to AReader.AttributeCount - 1 do
          begin
            var Attr := AReader.Attributes[I];
            NewNode.InternalAddAttribute(Attr.NameIndex, Attr.Value);
          end;

          if (not AReader.IsEmptyElement) then
            CurNode := NewNode;
        end;

      TXmlReaderState.EndElement:
        begin
          Assert(CurNode <> nil);

          if (CurNode = FRoot) then
            AReader.ParseError(@RS_XML_INVALID_END_ELEMENT);

          if (CurNode.GetValueIndex <> AReader.ValueIndex) then
            AReader.ParseError(@RS_XML_ELEMENT_NAME_MISMATCH);

          CurNode := CurNode.Parent;
        end;
    else
      Assert(State in [TXmlReaderState.Text, TXmlReaderState.Comment, TXmlReaderState.CData]);

      if (CurNode = FRoot) and (State = TXmlReaderState.CData) then
        AReader.ParseError(@RS_XML_CDATA_NOT_ALLOWED);

      var NewNode := CreateNode(TXmlNodeType(Ord(State) - 2));
      NewNode.Value := AReader.ValueString;
      CurNode.InternalAddChild(NewNode);
    end;
  end;
end;

procedure TXmlDocument.Parse(const AXml: XmlString);
begin
  var Reader := TXmlReader.Create(AXml, FInternPool);
  try
    Load(Reader);
  finally
    Reader.Free;
  end;
end;

procedure TXmlDocument.ReturnAttribute(const AAttr: TXmlAttribute);
begin
  if (not FClearing) then
  begin
    Assert(AAttr <> nil);
    AAttr.FAttribute^ := 0;
    FFreeList.Push(AAttr.FAttribute);
  end;
end;

procedure TXmlDocument.ReturnNode(const ANode: TXmlNode);
begin
  if (not FClearing) then
  begin
    Assert(ANode <> nil);
    ANode.FNode^ := 0;
    FFreeList.Push(ANode.FNode);
  end;
end;

procedure TXmlDocument.Save(const AFilename: String;
  const AOptions: TXmlOutputOptions);
begin
  var Bytes := ToBytes(AOptions);
  if (Bytes = nil) then
    Exit;

  var Stream := TFileStream.Create(AFilename, fmCreate or fmShareDenyWrite);
  try
    Stream.WriteBuffer(Bytes, Length(Bytes));
  finally
    Stream.Free;
  end;
end;

procedure TXmlDocument.Save(const AStream: TStream;
  const AOptions: TXmlOutputOptions);
begin
  if (AStream = nil) then
    Exit;

  var Bytes := ToBytes(AOptions);
  if (Bytes <> nil) then
    AStream.WriteBuffer(Bytes, Length(Bytes));
end;

procedure TXmlDocument.Save(const AWriter: TXmlWriter);
begin
  if (AWriter <> nil) and (FRoot <> nil) then
  begin
    var Root := FRoot.FirstChild;
    if (Root = nil) then
      Exit;

    var Node := Root;
    var Depth := 0;
    var NewLine := False;
    var Indent := True;

    repeat
      var Value := Node.GetValue;
      case Node.NodeType of
        TXmlNodeType.Element:
          begin
            if (NewLine) then
              AWriter.NewLine;

            if (Indent) then
              AWriter.Indent(Depth);

            NewLine := True;
            Indent := True;

            AWriter.Write('<');
            AWriter.Write(Value);

            var Attr := Node.FirstAttribute;
            while (Attr <> nil) do
            begin
              AWriter.Write(' ');
              AWriter.Write(Attr.Name);
              AWriter.Write('="');
              AWriter.WriteEncoded(Attr.Value, True);
              AWriter.Write('"');
              Attr := Attr.Next;
            end;

            var Child := Node.FirstChild;
            if (Child = nil) then
              AWriter.Write('/>')
            else
            begin
              AWriter.Write('>');
              Node := Child;
              Inc(Depth);
              Continue;
            end;
          end;

        TXmlNodeType.Text:
          begin
            AWriter.WriteEncoded(Value);
            NewLine := False;
            Indent := False;
          end;

        TXmlNodeType.Comment:
          begin
            if (NewLine) then
              AWriter.NewLine;

            if (Indent) then
              AWriter.Indent(Depth);

            AWriter.WriteComment(Value);

            NewLine := True;
            Indent := True;
          end;

        TXmlNodeType.CData:
          begin
            AWriter.WriteCData(Value);
            NewLine := False;
            Indent := False;
          end;
      else
        Assert(False);
      end;

      while (Node <> Root) do
      begin
        var Sibling := Node.NextSibling;
        if (Sibling <> nil) then
        begin
          Node := Sibling;
          Break;
        end;

        Node := Node.Parent;
        if (Node.NodeType = TXmlNodeType.Element) then
        begin
          Dec(Depth);

          if (NewLine) then
            AWriter.NewLine;

          if (Indent) then
            AWriter.Indent(Depth);

          AWriter.Write('</');
          AWriter.Write(Node.Value);
          AWriter.Write('>');

          NewLine := True;
          Indent := True;
        end;
      end;
    until (Node = Root);
    if (NewLine) then
      AWriter.NewLine;
  end;
end;

{$IFDEF CPU64BITS}
class function TXmlDocument.RetrieveString(
  const ANodeOrAttr: PUInt64): XmlString;
begin
  var SrcOffset := PInteger(ANodeOrAttr)[1];
  if (SrcOffset = 0) then
    { Node or attribute doesn't have a string value }
    Result := ''
  else
  begin
    var IsAdditionalString := (PInteger(ANodeOrAttr)[0] < 0);
    if (IsAdditionalString) then
    begin
      { Retrieve value from "additional string" pool. }
      var Block := PByte(UIntPtr(ANodeOrAttr) and not (BLOCK_SIZE - 1));
      Assert(Block <> nil);
      var Doc := TXmlDocument(PPointer(Block)^);
      Assert(Doc <> nil);
      Result := Doc.FInternPool.GetAdditionalString(SrcOffset);
    end
    else
    begin
      { Retrieve value directly }
      var SrcAddress := FBaseAddress + SrcOffset;
      Result := XmlString(SrcAddress);
    end;
  end;
end;

class procedure TXmlDocument.StoreString(const ANodeOrAttr: PUInt64;
  const AValue: XmlString);
begin
  var IsAdditionalString := (PInteger(ANodeOrAttr)[0] < 0);
  var DstOffset := PInteger(ANodeOrAttr)[1];
  if (AValue = '') then
  begin
    if (DstOffset <> 0) then
    begin
      { Clear the string }
      if (IsAdditionalString) then
      begin
        { Previously, an "additional string" was stored here. Clear it. }
        PCardinal(ANodeOrAttr)[0] := PCardinal(ANodeOrAttr)[0] and $7FFFFFFF;
      end
      else
      begin
        { Clear string if the node or attribute has a string value. }
        var DstAddress := FBaseAddress + DstOffset;
        XmlString(DstAddress) := ''; { This decreases the ref count }
      end;
      PCardinal(ANodeOrAttr)[1] := 0;
    end;
  end
  else
  begin
    var SrcOffset := IntPtr(AValue) - FBaseAddress;
    {$IFDEF XML_TESTING}
    if (SrcOffset >= -$FFFFF) and (SrcOffset <= $FFFFF) then
    {$ELSE}
    if (SrcOffset >= Int32.MinValue) and (SrcOffset <= Int32.MaxValue) then
    {$ENDIF}
    begin
      if (IsAdditionalString) then
      begin
        { Previously, an "additional string" was stored here. Clear it. }
        PCardinal(ANodeOrAttr)[0] := PCardinal(ANodeOrAttr)[0] and $7FFFFFFF;
        DstOffset := 0;
      end;

      var DstAddress: IntPtr := 0;
      if (DstOffset <> 0) then
        { Node or attribute already has a string value. Retrieve it. }
        DstAddress := FBaseAddress + DstOffset;

      { Assign string. This increases the reference count of the old value (if
        any) and increases the reference count of the new value. }
      XmlString(DstAddress) := AValue;

      { Store the source offset in the node or attribute }
      PInteger(ANodeOrAttr)[1] := SrcOffset;
    end
    else
    begin
      { SrcOffset does not fit in 32-bits. Clear the existing string (if any)
        and add the string as "additional string" to the pool. }
      if (not IsAdditionalString) then
      begin
        { There was a "regular" (or empty) string here. Replace it with
          an "additional string". }
        if (DstOffset <> 0) then
        begin
          { Clear "regular" string }
          var DstAddress := FBaseAddress + DstOffset;
          XmlString(DstAddress) := '';
        end;

        { Mark as "additional string" }
        PCardinal(ANodeOrAttr)[0] := PCardinal(ANodeOrAttr)[0] or $80000000;
      end;

      { Add additional string }
      var Block := PByte(UIntPtr(ANodeOrAttr) and not (BLOCK_SIZE - 1));
      Assert(Block <> nil);
      var Doc := TXmlDocument(PPointer(Block)^);
      Assert(Doc <> nil);
      PInteger(ANodeOrAttr)[1] := Doc.FInternPool.AddAdditionalString(AValue);
    end;
  end;
end;
{$ENDIF}

function TXmlDocument.ToBytes(const AOptions: TXmlOutputOptions): TBytes;
begin
  if (FRoot = nil) then
    Exit(nil);

  var Writer := TXmlWriter.Create(AOptions);
  try
    Save(Writer);
    Result := Writer.ToBytes;
  finally
    Writer.Free;
  end;
end;

function TXmlDocument.ToXml(const AOptions: TXmlOutputOptions): XmlString;
begin
  if (FRoot = nil) then
    Exit('');

  var Writer := TXmlWriter.Create(AOptions);
  try
    Save(Writer);
    Result := Writer.ToXml;
  finally
    Writer.Free;
  end;
end;

end.
