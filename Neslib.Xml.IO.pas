unit Neslib.Xml.IO;
{< Classes for reading and writing XML. }

{$INCLUDE 'Neslib.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  Neslib.Collections,
  Neslib.Xml.Types;

type
  { The current state of an IXmlReader. }
  TXmlReaderState = (
    { The end of the XML stream has been reached. }
    EndOfStream,

    { The reader is positioned at the start of an element (eg. <elem>). }
    StartElement,

    { The reader is positioned at the end of an element (eg. </elem>). }
    EndElement,

    { The reader is positioned at the text within an element (eg. the text
      'foo' in this example: <elem>foo</elem>) }
    Text,

    { The reader is positioned at a comment (eg. <!-- Comment -->) or a DTD
      definition. }
    Comment,

    { The reader is positioned at a CDATA section (eg. <![CDATA[ data ]]>) }
    CData);

type
  { Exception type that is raised on parsing errors. }
  EXmlParserError = class(Exception)
  {$REGION 'Internal Declarations'}
  private
    FXml: PXmlChar;
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FPosition: Integer;
    function GetColumnNumber: Integer;
    function GetLineNumber: Integer;
  private
    procedure CalcLineAndColumnNumber;
  public
    constructor Create(const AMsg: String; const AXml: PXmlChar;
      const APosition: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    { The line number of the error in the source text, starting at 1. }
    property LineNumber: Integer read GetLineNumber;

    { The column number of the error in the source text, starting at 1. }
    property ColumnNumber: Integer read GetColumnNumber;

    { The position of the error in the source text, starting at 0.
      The position is the offset (in characters) from the beginning of the
      text. }
    property Position: Integer read FPosition;
  end;

type
  { An attribute as read by a TXmlReader }
  TXmlReaderAttribute = record
  public
    { The index (in the string pool) of the name of the attribute }
    NameIndex: Integer;

    { The value of the attribute }
    Value: XmlString;
  end;

type
  { Class for reading data in XML format. }
  TXmlReader = class
  {$REGION 'Internal Declarations'}
  private
    FXml: XmlString;
    FValueIndex: Integer;
    FValueString: XmlString;
    FCurrent: PXmlChar;
    FPrev: PXmlChar;
    FAttributes: TList<TXmlReaderAttribute>;
    FEncoding: TXmlEncoding;
    FInternPool: TXmlStringInternPool;
    FIsEmptyElement: Boolean;
    function GetAttributeCount: Integer; //inline;
    function GetAttribute(const AIndex: Integer): TXmlReaderAttribute; //inline;
  private
    function SetValue(const AStart, AEnd: PXmlChar): Boolean;
    procedure ParseDeclaration;
    procedure ParseStartElement;
    procedure ParseEndElement;
    procedure ParseComment;
    procedure ParseCData;
    procedure AddAttribute(const ANameStart, ANameEnd, AValueStart,
      AValueEnd: PXmlChar);
  protected
    constructor Create(const AXml: XmlString; const AEncoding: TXmlEncoding;
      const AInternPool: TXmlStringInternPool); overload;
  public
    destructor Destroy; override;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a reader using a XML formatted string to parse.

      Parameters:
        AXml: the XML string to parse.
        AInternPool: a string intern pool used to store element and attribute
          names. }
    constructor Create(const AXml: XmlString;
      const AInternPool: TXmlStringInternPool); overload;

    { Creates a reader from a file.

      Parameters:
        AFilename: the name of the file to load.
        AInternPool: a string intern pool used to store element and attribute
          names.

      Returns:
        The reader. }
    class function Load(const AFilename: String;
      const AInternPool: TXmlStringInternPool): TXmlReader; overload; static;

    { Creates a reader from a stream.

      Parameters:
        AStream: the stream to load.
        AInternPool: a string intern pool used to store element and attribute
          names.

      Returns:
        The reader. }
    class function Load(const AStream: TStream;
      const AInternPool: TXmlStringInternPool): TXmlReader; overload; static;

    { Creates a reader from a byte array.

      Parameters:
        ABytes: the byte array containing the XML data.
        AInternPool: a string intern pool used to store element and attribute
          names.

      Returns:
        The reader. }
    class function Load(const ABytes: TBytes;
      const AInternPool: TXmlStringInternPool): TXmlReader; overload; static;

    { Encoding of the source file. }
    property Encoding: TXmlEncoding read FEncoding;
  public
    { Raises a parse exception.

      Parameters:
        AMsg: Pointer to a resource string with the error message.

      This method is used internally. }
    procedure ParseError(const AMsg: PResStringRec);

    { Reads the next piece of data from the XML stream.

      Parameters:
        AState: is set to the current state of the reader. That is, it indicates
          at what kind of data the reader is currently positioned. Depending
          on AState, you use one of the properties to get the details.

      Returns:
        True if more data is available, or False if the end of the stream has
        been reached.

      Raises:
        EXmlParserError if the XML data is invalid. }
    function Next(out AState: TXmlReaderState): Boolean;

    (*** The value of these properties depend on the AState argument returned
         by the Next function ***)

    { Whether the element is an empty element, as in <elem />.
      Only valid for TXmlReaderState.StartElement. }
    property IsEmptyElement: Boolean read FIsEmptyElement;

    { Index of the currently parsed value in the string intern pool, depending
      on the state:
      * TXmlReaderState.StartElement/EndElement: index of the name of the
        element.
      * Otherwise: not used }
    property ValueIndex: Integer read FValueIndex;

    { The currently parsed value, depending on the state:
      * TXmlReaderState.StartElement/EndElement: not used.
      * TXmlReaderState.Text: the text value. Note that text containing only
        whitespace is ignored. However, the text may contain leading or
        trailing whitespace.
      * TXmlReaderState.Comment: the comment.
      * TXmlReaderState.CData: the CData value. }
    property ValueString: XmlString read FValueString;

    { Number of attributes of the current element.
      Only valid for TXmlReaderState.StartElement. }
    property AttributeCount: Integer read GetAttributeCount;

    { The attributes of the current element.
      Only valid for TXmlReaderState.StartElement. }
    property Attributes[const AIndex: Integer]: TXmlReaderAttribute read GetAttribute;
  end;

type
  { A helper class for writing XML data. }
  TXmlWriter = class
  {$REGION 'Internal Declarations'}
  private const
    INDENT_SIZE = 2;
  private
    FBuffer: PByte;
    FSize: Integer;
    FCapacity: Integer;
    FIndentString: XmlString;
    FLineBreak: XmlChar;
  private
    procedure Append(const AValue; const ASize: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a new writer.

      Parameters:
        AOptions: (optional) XML formatting options.
          Defaults to pretty-printing and writing an XML declaration }
    constructor Create(const AOptions: TXmlOutputOptions = DEFAULT_XML_OUTPUT_OPTIONS);
    destructor Destroy; override;

    { Appends a new-line (#10) to the output if the TXmlOutputOption.Indent
      option is set. Otherwise, it doesn't do anything. }
    procedure NewLine; inline;

    { Appends an indent to the output if the TXmlOutputOption.Indent option is
      set. Otherwise, it doesn't do anything.

      Parameters:
        ADepth: the indentation depth. Each additional depth adds 2 additional
          spaces to the output. }
    procedure Indent(const ADepth: Integer);

    { Writes a single character to the output.

      Parameters:
        AValue: the character to write. }
    procedure Write(const AValue: XmlChar); overload; inline;

    { Writes a string (as-is) to the output.

      Parameters:
        AValue: the string to write.

      This method writes the string as-is. If the string can contain reserved
      characters (such as '&' and '<'), the use WriteEncoded instead. }
    procedure Write(const AValue: XmlString); overload; inline;

    { XML-encodes a string and writes it to the output.

      Parameters:
        AValue: the string to write.
        AForAttribute: (optional) flag indicating whether we are encoding an
          attribute (True) or not (False, default). When True, single quotes (')
          are not encoded, since the attribute value itself is enclosed in
          double quotes (").

      This method will replace reseverd characters (such as '&' and '<') to
      character entities (eg. '&amp;' and '&lt;'. }
    procedure WriteEncoded(const AValue: XmlString;
      const AForAttribute: Boolean = False);

    { Writes CData to the output.

      Parameters:
        ACData: the CData to write.

      If ACData contains text that is invalid inside a CData section (such as
      ']]>'), the only the part until the invalid text is written. }
    procedure WriteCData(const ACData: XmlString);

    { Writes a comment to the output.

      Parameters:
        AComment: the comment to write.

      If comment contains text that is invalid inside a comment section (such as
      '--'), the only the part until the invalid text is written. }
    procedure WriteComment(const AComment: XmlString);

    { Returns the data written (so far) as an XML string. }
    function ToXml: XmlString;

    { Returns the data written (so far) as an UTF-8 encoded byte array. }
    function ToBytes: TBytes;
  end;

resourcestring
  { Error messages that will be raised on parsing errors. }
  RS_XML_UNEXPECTED_EOF        = 'Unexpected end of XML data.';
  RS_XML_CHARACTER_REFERENCE   = 'Invalid character reference in XML data.';
  RS_XML_INVALID_COMMENT       = 'Invalid comment in XML data.';
  RS_XML_INVALID_CDATA         = 'Invalid CDATA in XML data.';
  RS_XML_EQUAL_EXPECTED        = 'Expected "=" after XML attribute name.';
  RS_XML_INVALID_QUOTE         = 'Attribute value must be enclosed in single or double quotes.';
  RS_XML_INVALID_END_ELEMENT   = 'End element is not allowed here.';
  RS_XML_ELEMENT_NAME_MISMATCH = 'Name of end element does not match start element.';
  RS_XML_CDATA_NOT_ALLOWED     = 'CDATA is not allowed here.';

implementation

uses
  System.Character,
  Neslib.Utf8;

procedure SwapEndian16(const ASource: Pointer; const ACount: Integer);
begin
  var P := PWord(ASource);
  for var I := 0 to ACount - 1 do
  begin
    P^ := (P^ shr 8) or (P^ shl 8);
    Inc(P);
  end;
end;

procedure SwapEndian32(const ASource: Pointer; const ACount: Integer);
begin
  var P := PCardinal(ASource);
  for var I := 0 to ACount - 1 do
  begin
    P^ := (P^ shr 24) or ((P^ and $00FF0000) shr 8) or ((P^ and $0000FF00) shl 8) or (P^ shl 24);
    Inc(P);
  end;
end;

function Utf32ToUtf16(const ASource: Pointer; const ACount: Integer): String;
begin
  SetLength(Result, ACount * 2);
  var Src := PCardinal(ASource);
  var Dst := PChar(Pointer(Result));
  var Start := Dst;
  for var I := 0 to ACount - 1 do
  begin
    if (Src^ >= $00010000) then
    begin
      Dst^ := Char((((Src^ - $00010000) shr 10) and $000003FF) or $D800);
      Inc(Dst);
      Dst^ := Char(((Src^ - $00010000) and $000003FF)or $DC00);
      Inc(Dst);
    end
    else
    begin
      Dst^ := Char(Src^);
      Inc(Dst);
    end;
    Inc(Src);
  end;
  SetLength(Result, Dst - Start);
end;

{$IFDEF XML_UTF8}
function Utf32ToUtf8(const ASource: Pointer; const ACount: Integer): UTF8String;
begin
  var Utf16 := Utf32ToUtf16(ASource, ACount);
  Result := Utf16ToUtf8(Utf16);
end;
{$ENDIF}

type
  TCharBuffer = record
  private const
    SIZE = 256;
  private type
    TBuffer = array [0..SIZE - 1] of XmlChar;
    PBuffer = ^TBuffer;
  private
    FStatic: TBuffer;
    FDynamic: PBuffer;
    FCurrent: PXmlChar;
    FCurrentEnd: PXmlChar;
    FDynamicCount: Integer;
  public
    procedure Initialize; inline;
    procedure Release; inline;
    procedure Append(const AChar: XmlChar); inline;
    function ToString: XmlString; inline;
  end;

{ TCharBuffer }

procedure TCharBuffer.Append(const AChar: XmlChar);
begin
  if (FCurrent < FCurrentEnd) then
  begin
    FCurrent^ := AChar;
    Inc(FCurrent);
    Exit;
  end;

  ReallocMem(FDynamic, (FDynamicCount + 1) * SizeOf(TBuffer));
  FCurrent := PXmlChar(FDynamic) + (FDynamicCount * SIZE);
  FCurrentEnd := FCurrent + SIZE;
  Inc(FDynamicCount);

  FCurrent^ := AChar;
  Inc(FCurrent);
end;

procedure TCharBuffer.Initialize;
begin
  FDynamic := nil;
  FCurrent := @FStatic;
  FCurrentEnd := FCurrent + SIZE;
  FDynamicCount := 0;
end;

procedure TCharBuffer.Release;
begin
  FreeMem(FDynamic);
end;

function TCharBuffer.ToString: XmlString;
begin
  if (FDynamic = nil) then
  begin
    var Start := PXmlChar(@FStatic);
    SetString(Result, Start, FCurrent - Start);
    Exit;
  end;

  var TrailingLength := SIZE - (FCurrentEnd - FCurrent);
  SetLength(Result, (FDynamicCount * SIZE) + TrailingLength);
  Move(FStatic, Result[Low(XmlString)], SizeOf(TBuffer));
  var StrIndex := Low(XmlString) + SIZE;

  var Src := FDynamic;
  for var I := 0 to FDynamicCount - 2 do
  begin
    Move(Src^, Result[StrIndex], SizeOf(TBuffer));
    Inc(Src);
    Inc(StrIndex, SIZE);
  end;

  Move(Src^, Result[StrIndex], TrailingLength * SizeOf(XmlChar));
end;

{ EXmlParserError }

procedure EXmlParserError.CalcLineAndColumnNumber;
begin
  var LineNum := 1;
  var P := FXml;
  var LineStart := P;
  for var I := 0 to FPosition - 1 do
  begin
    if (P^ = #10) then
    begin
      Inc(LineNum);
      LineStart := P + 1;
    end;
    Inc(P);
  end;
  FLineNumber := LineNum;
  FColumnNumber := P - LineStart + 1;
end;

constructor EXmlParserError.Create(const AMsg: String; const AXml: PXmlChar;
  const APosition: Integer);
begin
  inherited Create(AMsg);
  FXml := AXml;
  FPosition := APosition;
end;

function EXmlParserError.GetColumnNumber: Integer;
begin
  if (FColumnNumber = 0) then
    CalcLineAndColumnNumber;

  Result := FColumnNumber;
end;

function EXmlParserError.GetLineNumber: Integer;
begin
  if (FLineNumber = 0) then
    CalcLineAndColumnNumber;

  Result := FLineNumber;
end;

{ TXmlReader }

procedure TXmlReader.AddAttribute(const ANameStart, ANameEnd, AValueStart,
  AValueEnd: PXmlChar);
var
  Attr: TXmlReaderAttribute;
begin
  Attr.NameIndex := FInternPool.Get(ANameStart, ANameEnd - ANameStart);

  if SetValue(AValueStart, AValueEnd) then
    Attr.Value := FValueString
  else
    Attr.Value := '';

  FAttributes.Add(Attr);
end;

constructor TXmlReader.Create(const AXml: XmlString;
  const AInternPool: TXmlStringInternPool);
begin
  Create(AXml, TXmlEncoding.Utf16, AInternPool);
end;

constructor TXmlReader.Create(const AXml: XmlString;
  const AEncoding: TXmlEncoding; const AInternPool: TXmlStringInternPool);
begin
  inherited Create;
  FAttributes := TList<TXmlReaderAttribute>.Create;
  FXml := AXml;
  FEncoding := AEncoding;
  FInternPool := AInternPool;
  FCurrent := PXmlChar(FXml);
end;

destructor TXmlReader.Destroy;
begin
  FAttributes.Free;
  inherited;
end;

function TXmlReader.GetAttribute(const AIndex: Integer): TXmlReaderAttribute;
begin
  Result := FAttributes[AIndex];
end;

function TXmlReader.GetAttributeCount: Integer;
begin
  Result := FAttributes.Count;
end;

class function TXmlReader.Load(const AFilename: String;
  const AInternPool: TXmlStringInternPool): TXmlReader;
begin
  var Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := Load(Stream, AInternPool);
  finally
    Stream.Free;
  end;
end;

class function TXmlReader.Load(const ABytes: TBytes;
  const AInternPool: TXmlStringInternPool): TXmlReader;
begin
  var Stream := TBytesStream.Create(ABytes);
  try
    Result := Load(Stream, AInternPool);
  finally
    Stream.Free;
  end;
end;

class function TXmlReader.Load(const AStream: TStream;
  const AInternPool: TXmlStringInternPool): TXmlReader;
begin
  if (AStream = nil) then
    Exit(nil);

  { Try to detect encoding from Bom }
  var Bom: UInt32 := 0;
  var StartPos := AStream.Position;
  var Size := AStream.Size - StartPos;
  var BomSize: Integer;
  var Encoding: TXmlEncoding;

  AStream.Read(Bom, 4);
  if (Bom = $0000FEFF) then
  begin
    Encoding := TXmlEncoding.Utf32;
    BomSize := 4;
  end
  else if (Bom = $FFFE0000) then
  begin
    Encoding := TXmlEncoding.Utf32BigEndian;
    BomSize := 4;
  end
  else if ((Bom and $00FFFFFF) = $00BFBBEF) then
  begin
    Encoding := TXmlEncoding.Utf8;
    BomSize := 3;
  end
  else if ((Bom and $0000FFFF) = $0000FEFF) then
  begin
    Encoding := TXmlEncoding.Utf16;
    BomSize := 2;
  end
  else if ((Bom and $0000FFFF) = $0000FFFE) then
  begin
    Encoding := TXmlEncoding.Utf16BigEndian;
    BomSize := 2;
  end
  else
  begin
    { We assume UTF-8 if there is no BOM }
    Encoding := TXmlEncoding.Utf8;
    BomSize := 0;
  end;

  Dec(Size, BomSize);
  AStream.Position := StartPos + BomSize;

  { We can skip conversion if source encoding matches target encoding }
  var Xml: XmlString := '';
  {$IFDEF XML_UTF8}
  if (Encoding = TXmlEncoding.Utf8) then
  begin
    SetLength(Xml, Size);
    AStream.ReadBuffer(Xml[Low(XmlString)], Size);
  end
  {$ELSE}
  if (Encoding in [TXmlEncoding.Utf16, TXmlEncoding.Utf16BigEndian]) then
  begin
    SetLength(Xml, Size div 2);
    AStream.ReadBuffer(Xml[Low(XmlString)], Size);
    if (Encoding = TXmlEncoding.Utf16BigEndian) then
      SwapEndian16(Pointer(Xml), Length(Xml));
  end
  {$ENDIF}
  else
  begin
    { We need to convert }
    var Bytes: TBytes;
    SetLength(Bytes, Size);
    AStream.ReadBuffer(Bytes, Size);

    case Encoding of
      TXmlEncoding.Utf8:
        {$IFDEF XML_UTF8}
        Assert(False, 'Should be handled elsewhere');
        {$ELSE}
        Xml := Utf8ToUtf16(@Bytes[0], Size);
        {$ENDIF}

      TXmlEncoding.Utf16:
        {$IFDEF XML_UTF8}
        Xml := Utf16ToUtf8(@Bytes[0], Size div 2);
        {$ELSE}
        Assert(False, 'Should be handled elsewhere');
        {$ENDIF}

      TXmlEncoding.Utf16BigEndian:
        begin
          {$IFDEF XML_UTF8}
          SwapEndian16(@Bytes[0], Size div 2);
          Xml := Utf16ToUtf8(@Bytes[0], Size div 2);
          {$ELSE}
          Assert(False, 'Should be handled elsewhere');
          {$ENDIF}
        end;

      TXmlEncoding.Utf32:
        {$IFDEF XML_UTF8}
        Xml := Utf32ToUtf8(@Bytes[0], Size div 4);
        {$ELSE}
        Xml := Utf32ToUtf16(@Bytes[0], Size div 4);
        {$ENDIF}

      TXmlEncoding.Utf32BigEndian:
        begin
          SwapEndian32(@Bytes[0], Size div 4);
          {$IFDEF XML_UTF8}
          Xml := Utf32ToUtf8(@Bytes[0], Size div 4);
          {$ELSE}
          Xml := Utf32ToUtf16(@Bytes[0], Size div 4);
          {$ENDIF}
        end;
    else
      Assert(False);
    end;
  end;

  Result := TXmlReader.Create(Xml, Encoding, AInternPool);
end;

function TXmlReader.Next(out AState: TXmlReaderState): Boolean;
begin
  while (True) do
  begin
    FPrev := FCurrent;
    var P := FCurrent;
    var Start := P;

    { Scan until '<' }
    while (P^ <> #0) and (P^ <> '<') do
      Inc(P);

    if (P^ = #0) then
    begin
      AState := TXmlReaderState.EndOfStream;
      Exit(False);
    end;

    if (P <> Start) then
    begin
      if (SetValue(Start, P)) then
      begin
        AState := TXmlReaderState.Text;
        FCurrent := P;
        Exit(True);
      end;
    end;

    Inc(P);
    FCurrent := P;
    case P^ of
      '?': ParseDeclaration; { Ignore and parse next }

      '/': begin
             ParseEndElement;
             AState := TXmlReaderState.EndElement;
             Exit(True);
           end;

      '!': if (P[1] = '[') then
           begin
             ParseCData;
             AState := TXmlReaderState.CData;
             Exit(True);
           end
           else
           begin
             ParseComment;
             AState := TXmlReaderState.Comment;
             Exit(True);
           end;
    else
      ParseStartElement;
      AState := TXmlReaderState.StartElement;
      Exit(True);
    end;
  end;
end;

procedure TXmlReader.ParseCData;
begin
  var P := FCurrent;
  if (P[0] <> '!') or (P[1] <> '[') or (P[2] <> 'C') or (P[3] <> 'D')
    or (P[4] <> 'A') or (P[5] <> 'T') or (P[6] <> 'A') or (P[7] <> '[')
  then
    ParseError(@RS_XML_INVALID_CDATA);

  Inc(P, 8);
  var Start := P;

  { Move to end of CDATA. }
  while (P^ <> #0) and ((P[0] <> ']') or (P[1] <> ']') or (P[2] <> '>')) do
    Inc(P);

  if (P^ = #0) then
    ParseError(@RS_XML_UNEXPECTED_EOF);

  SetString(FValueString, Start, P - Start);
  FCurrent := P + 3;
end;

procedure TXmlReader.ParseComment;
begin
  var P := FCurrent;
  if (P[0] <> '!') or (P[1] <> '-') or (P[2] <> '-') then
    ParseError(@RS_XML_INVALID_COMMENT);

  Inc(P, 3);
  var Start := P;
  var Closed := False;

  { Move to end of comment. }
  while not Closed do
  begin
    if (P^ = #0) then
      ParseError(@RS_XML_UNEXPECTED_EOF);

    Closed := (P >= (Start + 2)) and (P^ = '>') and (P[-1] = '-') and (P[-2] = '-');
    Inc(P);
  end;

  SetString(FValueString, Start, P - Start - 3);
  FCurrent := P;
end;

procedure TXmlReader.ParseDeclaration;
begin
  var P := FCurrent;
  while (P^ <> #0) and (P^ <> '>') do
    Inc(P);

  if (P^ = #0) then
    ParseError(@RS_XML_UNEXPECTED_EOF);

  FCurrent := P + 1;
end;

procedure TXmlReader.ParseEndElement;
begin
  FIsEmptyElement := False;
  FAttributes.Clear;
  var P := FCurrent + 1;
  var Start := P;

  while (P^ <> #0) and (P^ <> '>') do
    Inc(P);

  if (P^ = #0) then
    ParseError(@RS_XML_UNEXPECTED_EOF);

  FValueIndex := FInternPool.Get(Start, P - Start);
  FCurrent := P + 1;
end;

procedure TXmlReader.ParseError(const AMsg: PResStringRec);
begin
  var Xml := PXmlChar(FXml);
  var Position := 0;
  if (FCurrent <> nil) then
    Position := FPrev - Xml;

  raise EXmlParserError.Create(LoadResString(AMsg), Xml, Position);
end;

procedure TXmlReader.ParseStartElement;
begin
  var P := FCurrent;
  var NameStart := P;
  FIsEmptyElement := False;
  FAttributes.Clear;

  { Move to first attribute or end of element }
  while (P^ > #$20) and (P^ <> '>') do
    Inc(P);

  var NameEnd := P;

  { Parse attributes }
  while (P^ <> '>') do
  begin
    if (P^ = #0) then
      ParseError(@RS_XML_UNEXPECTED_EOF);

    if (P^ = '/') then
    begin
      FIsEmptyElement := True;
      Inc(P);
    end
    else if (P^ <= #$20) then
      Inc(P)
    else
    begin
      { At attribute name }
      FPrev := P;
      var AttrNameStart := P;
      while (P^ > #$20) and (P^ <> '=') do
        Inc(P);

      if (P^ = #0) then
        ParseError(@RS_XML_UNEXPECTED_EOF);

      var AttrNameEnd := P;

      while (P^ > #0) and (P^ <= #$20) do
        Inc(P);

      FPrev := P;
      if (P^ <> '=') then
        ParseError(@RS_XML_EQUAL_EXPECTED);

      Inc(P);
      FPrev := P;
      while (P^ > #0) and (P^ <= #$20) do
        Inc(P);

      if (P^ = #0) then
        ParseError(@RS_XML_UNEXPECTED_EOF);

      { At attribute value }
      var QuoteChar := P^;
      if (QuoteChar <> '''') and (QuoteChar <> '"') then
        ParseError(@RS_XML_INVALID_QUOTE);
      Inc(P);
      FPrev := P;

      var AttrValueStart := P;
      while (P^ > #0) and (P^ <> QuoteChar) do
        Inc(P);

      if (P^ = #0) then
        ParseError(@RS_XML_UNEXPECTED_EOF);

      AddAttribute(AttrNameStart, AttrNameEnd, AttrValueStart, P);
      Inc(P);
    end;
  end;

  if (NameEnd > NameStart) and (NameEnd[-1] = '/') then
  begin
    FIsEmptyElement := True;
    Dec(NameEnd);
  end;

  FValueIndex := FInternPool.Get(NameStart, NameEnd - NameStart);
  FCurrent := P + 1;
end;

function TXmlReader.SetValue(const AStart, AEnd: PXmlChar): Boolean;
var
  Buf: TCharBuffer;
begin
  Result := False;
  Buf.Initialize;
  try
    var P := AStart;
    while (P < AEnd) do
    begin
      if (P^ = '&') then
      begin
        FPrev := P;
        Inc(P);
        var Start := P;
        while (P < AEnd) and (P^ <> ';') do
          Inc(P);

        if (P = AEnd) then
          ParseError(@RS_XML_CHARACTER_REFERENCE);

        if (Start^ = '#') then
        begin
          { Numeric reference }
          var S: XmlString;
          SetString(S, Start + 1, P - Start - 1);
          if (Start[1] = 'x') then
            { Hexadicimal }
            S[Low(XmlString)] := '$';

          var CodePoint: Cardinal;
          if (not TryStrToUInt(S, CodePoint)) then
            ParseError(@RS_XML_CHARACTER_REFERENCE);

          if (CodePoint < $80) then
            Buf.Append(XmlChar(CodePoint))
          else
          begin
            S := XmlString(Char.ConvertFromUtf32(Codepoint));
            for var C in S do
              Buf.Append(C);
          end;

          if (not Char.IsWhiteSpace(CodePoint)) then
            Result := True;
        end
        else if (Start^ = 'a') then
        begin
          { &amp; or &apos; }
          if (Start[1] = 'm') then
          begin
            if (Start[2] = 'p') and (Start[3] = ';') then
            begin
              Buf.Append('&');
              Result := True;
            end;
          end
          else if (Start[1] = 'p') then
          begin
            if (Start[2] = 'o') and (Start[3] = 's') and (Start[4] = ';') then
            begin
              Buf.Append('''');
              Result := True;
            end;
          end;
        end
        else if (Start^ = 'g') then
        begin
          { &gt; }
          if (Start[1] = 't') and (Start[2] = ';') then
          begin
            Buf.Append('>');
            Result := True;
          end;
        end
        else if (Start^ = 'l') then
        begin
          { &lt; }
          if (Start[1] = 't') and (Start[2] = ';') then
          begin
            Buf.Append('<');
            Result := True;
          end;
        end
        else if (Start^ = 'q') then
        begin
          { &quot; }
          if (Start[1] = 'u') and (Start[2] = 'o') and (Start[3] = 't') and (Start[4] = ';') then
          begin
           Buf.Append('"');
           Result := True;
          end;
        end
        else
          ParseError(@RS_XML_CHARACTER_REFERENCE);
      end
      else
      begin
        Buf.Append(P^);
        if (P^ > #$20) then
          Result := True;
      end;

      Inc(P);
    end;
    if (Result) then
      FValueString := Buf.ToString;
  finally
    Buf.Release;
  end;
end;

{ TXmlWriter }

procedure TXmlWriter.Append(const AValue; const ASize: Integer);
begin
  if ((FSize + ASize) > FCapacity) then
  begin
    repeat
      FCapacity := FCapacity shl 1;
    until (FCapacity >= (FSize + ASize));
    ReallocMem(FBuffer, FCapacity);
  end;
  Move(AValue, FBuffer[FSize], ASize);
  Inc(FSize, ASize);
end;

constructor TXmlWriter.Create(const AOptions: TXmlOutputOptions);
begin
  inherited Create;
  if (TXmlOutputOption.Indent in AOptions) then
    FLineBreak := #10;

  GetMem(FBuffer, 512);
  FCapacity := 512;

  if (TXmlOutputOption.WriteDeclaration in AOptions) then
    Write('<?xml version="1.0" encoding="UTF-8"?>');

  NewLine;
end;

destructor TXmlWriter.Destroy;
begin
  FreeMem(FBuffer);
  inherited;
end;

procedure TXmlWriter.Indent(const ADepth: Integer);
begin
  if (FLineBreak = #0) or (ADepth = 0) then
    Exit;

  var IndentCount := ADepth * INDENT_SIZE;
  var IndentLength := Length(FIndentString);
  if (IndentCount > IndentLength) then
  begin
    SetLength(FIndentString, IndentCount + 16);
    for var I := Low(XmlString) + IndentLength to Low(XmlString) + Length(FIndentString) - 1 do
      FIndentString[I] := ' ';
  end;

  Append(FIndentString[Low(XmlString)], IndentCount * SizeOf(XmlChar));
end;

procedure TXmlWriter.NewLine;
begin
  if (FLineBreak <> #0) then
    Write(FLineBreak);
end;

function TXmlWriter.ToBytes: TBytes;
begin
  if (FSize = 0) then
    Exit(nil);

  {$IFDEF XML_UTF8}
  SetLength(Result, FSize);
  Move(FBuffer^, Result[0], FSize);
  {$ELSE}
  var CharCount := FSize shr 1;
  SetLength(Result, (CharCount + 1) * 3);
  SetLength(Result, Utf16ToUtf8(FBuffer, CharCount, Pointer(Result)));
  {$ENDIF}
end;

function TXmlWriter.ToXml: XmlString;
begin
  SetString(Result, PXmlChar(FBuffer), FSize div SizeOf(XmlChar));
end;

procedure TXmlWriter.Write(const AValue: XmlChar);
begin
  Append(AValue, SizeOf(XmlChar));
end;

procedure TXmlWriter.Write(const AValue: XmlString);
begin
  if (AValue <> '') then
    Append(AValue[Low(XmlString)], Length(AValue) * SizeOf(XmlChar));
end;

procedure TXmlWriter.WriteEncoded(const AValue: XmlString;
  const AForAttribute: Boolean);
begin
  for var I := Low(XmlString) to Low(XmlString) + Length(AValue) - 1 do
  begin
    var C := AValue[I];
    case C of
      #0..#31:
        begin
          Write('&#');
          {$IFDEF XML_UTF8}
          Write(IntToUtf8Str(Ord(C)));
          {$ELSE}
          Write(IntToStr(Ord(C)));
          {$ENDIF}
          Write(';');
        end;

      '&' : Write('&amp;');
      '''': if (AForAttribute) then
              Write(C)
            else
              Write('&apos;');
      '"' : Write('&quot;');
      '<' : Write('&lt;');
      '>' : Write('&gt;');
    else
      Write(C);
    end;
  end;
end;

procedure TXmlWriter.WriteCData(const ACData: XmlString);
begin
  Write('<![CDATA[');

  {$IFDEF XML_UTF8}
  var CData := String(ACData);
  var I := CData.IndexOf(']]>');
  if (I < 0) then
    Write(ACData)
  else
  begin
    { Text contains illegal CData terminator. Only write part until terminator. }
    CData := CData.Substring(0, I);
    Write(UTF8String(CData));
  end;
  {$ELSE}
  var I := ACData.IndexOf(']]>');
  if (I < 0) then
    Write(ACData)
  else
    { Text contains illegal CData terminator. Only write part until terminator. }
    Write(ACData.Substring(0, I));
  {$ENDIF}

  Write(']]>');
end;

procedure TXmlWriter.WriteComment(const AComment: XmlString);
begin
  Write('<!--');

  {$IFDEF XML_UTF8}
  var Comment := String(AComment);
  var I := Comment.IndexOf('--');
  if (I < 0) then
    Write(AComment)
  else
  begin
    { Comment contains illegal '--'. Only write part until this. }
    Comment := Comment.Substring(0, I);
    Write(UTF8String(Comment));
  end;
  {$ELSE}
  var I := AComment.IndexOf('--');
  if (I < 0) then
    Write(AComment)
  else
    { Comment contains illegal '--'. Only write part until this. }
    Write(AComment.Substring(0, I));
  {$ENDIF}

  Write('-->');
end;

end.
