unit Neslib.Xml.Types;
{< Common XML types. }

{$INCLUDE 'Neslib.inc'}

interface

type
  { XmlChar and XmlString map to WideChar and String repectively.
    When compiled with the XML_UTF8 define, all strings and characters are
    UTF-8-based. This reduces memory and can increase speed, but may result in
    implicit conversions when using in your code. }
  {$IFDEF XML_UTF8}
  XmlChar = UTF8Char;
  PXmlChar = PUTF8Char;
  XmlString = UTF8String;
  {$ELSE}
  XmlChar = WideChar;
  PXmlChar = PWideChar;
  XmlString = String;
  {$ENDIF}

type
  { Support encodings of XML source files. }
  TXmlEncoding = (
    { UTF-8. This is the default encoding when no BOM is present, or the
      document starts with an UTF-8 BOM }
    Utf8,

    { Little-Endian UTF-16.
      Used when a document starts with a UTF-16 LE BOM. }
    Utf16,

    { Big-Endian UTF-16.
      Used when a document starts with a UTF-16 BE BOM. }
    Utf16BigEndian,

    { Little-Endian UTF-32.
      Used when a document starts with a UTF-32 LE BOM. }
    Utf32,

    { Big-Endian UTF-32.
      Used when a document starts with a UTF-32 BE BOM. }
    Utf32BigEndian);

type
  { Options to control XML output (eg. for IXmlDocument.Save and
    IXmlDocument.ToXml) }
  TXmlOutputOption = (
    { Whether you want indented (aka pretty-printed) output. If set, child nodes
      will be indented and line breaks will be inserted.
      Set by default.}
    Indent,

    { Whether to write and XML declaration (<?xml...>) at the beginning of the
      output.
      Set by default. }
    WriteDeclaration);
  TXmlOutputOptions = set of TXmlOutputOption;

const
  { Default XML output options }
  DEFAULT_XML_OUTPUT_OPTIONS = [TXmlOutputOption.Indent, TXmlOutputOption.WriteDeclaration];

type
  { A string interning pool.
    Is used internally to efficiently keep track of element and attribute
    names. You usually don't need to use this class yourself. }
  TXmlStringInternPool = class
  {$REGION 'Internal Declarations'}
  private type
    TItem = packed record
      HashCode: Integer;
      Index: Integer;
    end;
  private
    FItems: TArray<TItem>;
    FStrings: TArray<XmlString>;
    FCount: Integer;
    FGrowThreshold: Integer;
    {$IFDEF CPU64BITS}
    FAdditionalStrings: TArray<XmlString>;
    FAdditionalCount: Integer;
    {$ENDIF}
  private
    procedure Resize(ANewSize: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;

    { Clears to pool. }
    procedure Clear;

    { Retrieves the index of a string in the pool, or adds the string in case
      it is not in the pool yet.

      Parameters:
        AString: the string to get or add.

      Returns:
        The index of the (existing or newly added) string.

      To lookup a string without adding it, use the Find method instead. }
    function Get(const AString: XmlString): Integer; overload;

    { Retrieves the index of a string in the pool, or adds the string in case
      it is not in the pool yet.

      Parameters:
        AString: pointer to the first character in the string.
        ALength: number of characters in the string.

      Returns:
        The index of the (existing or newly added) string.

      To lookup a string without adding it, use the Find method instead. }
    function Get(const AString: PXmlChar; const ALength: Integer): Integer; overload;

    { Retrieves a string from the pool by index.

      Parameters:
        AIndex: the index of the string (as previously returned by one of the
          other Get methods). Must be between 0 and the number of strings in the
          pool. This is checked with an assertion.

      Returns:
        The string at this index. }
    function Get(const AIndex: Integer): XmlString; overload;


    { Retrieves the index of a string in the pool.

      Parameters:
        AString: the string to find.

      Returns:
        The index of the string, or -1 in case the pool does not contain the
        string.

      Use the Get method if you want to add the string to the pool in case it
      does not exist in the pool yet. }
    function Find(const AString: XmlString): Integer;

    {$IFDEF CPU64BITS}
    { Adds an "additional string" to the pool.
      An additional string is the value of an attribute or text/comment/cdata
      node, whose pointer doesn't fit into 32-bits (which should be very rare).
      In that case, this method is used to store the string and return its
      index.

      Parameters:
        AString: the string to add.

      Returns:
        The index of the added string.

      Note that these strings are stored seperately, and are not part of the
      main string interning pool. }
    function AddAdditionalString(const AString: XmlString): Integer;

    { Retrieves an "additional string" previously added using
      AddAdditionalString.

      Parameters:
        AIndex: the index of the string (as previously returned by
          AddAdditionalString). Must be between 0 and the number of additionl
          strings. This is checked with an assertion.

      Returns:
        The string at this index.

      See AddAdditionalString for more details. }
    function GetAdditionalString(const AIndex: Integer): XmlString;
    {$ENDIF}

    { The number of strings in the pool (excluding "additional strings"). }
    property Count: Integer read FCount;
  end;

type
  { Uses internally to map pointers.
    You don't need to use this class yourself. }
  TXmlPointerMap = class
  {$REGION 'Internal Declarations'}
  private type
    TItem = packed record
      HashCode: Integer;
      Key: UIntPtr;
      Value: Pointer;
    end;
  private
    FItems: TArray<TItem>;
    FCount: Integer;
    FGrowThreshold: Integer;
  private
    class function Hash(const AKey: UIntPtr): Integer; inline; static;
  private
    procedure Resize(ANewSize: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    { Clears the map }
    procedure Clear;

    { Maps a pointer.

      Parameters:
        AKey: the key
        AID: an identifier (between 0 and 7) that, in combination with AKey,
          uniquely identifies AValue
        AValue: the value to map to the combination of AKey and AID.

      If the map already contains an AKey/AID combination, then its value is
      overwritten. }
    procedure Map(const AKey: Pointer; const AID: Integer;
      const AValue: Pointer);

    { Retrieves a value.

      Parameters:
        AKey: the key
        AID: an identifier (between 0 and 7) that, in combination with AKey,
          uniquely identifies AValue

      Returns:
        The value for the AKey/AID combination, or nil in case the map does
        not contain the AKey/AID combination. }
    function Get(const AKey: Pointer; const AID: Integer): Pointer;
  end;

implementation

uses
  System.SysUtils,
  {$IFDEF XML_UTF8}
  System.AnsiStrings,
  {$ENDIF}
  Neslib.Hash;


const
  EMPTY_HASH = -1;

{ TXmlStringInternPool }

function TXmlStringInternPool.Get(const AString: XmlString): Integer;
begin
  if (FCount >= FGrowThreshold) then
     Resize(Length(FItems) * 2);

  var HashCode := MurmurHash2(Pointer(AString)^, Length(AString) * SizeOf(XmlChar));
  var Mask := Length(FItems) - 1;
  var Index := HashCode and Mask;

  while True do
  begin
    var HC := FItems[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (FStrings[FItems[Index].Index] = AString) then
      Exit(FItems[Index].Index);

    Index := (Index + 1) and Mask;
  end;

  FStrings[FCount] := AString;
  FItems[Index].HashCode := HashCode;
  FItems[Index].Index := FCount;
  Result := FCount;
  Inc(FCount);
  Assert(FCount <= (1 shl 17));
end;

{$IFDEF CPU64BITS}
function TXmlStringInternPool.AddAdditionalString(
  const AString: XmlString): Integer;
begin
  Result := FAdditionalCount;
  if (FAdditionalCount >= Length(FAdditionalStrings)) then
    SetLength(FAdditionalStrings, GrowCollection(Length(FAdditionalStrings), FAdditionalCount + 1));

  FAdditionalStrings[FAdditionalCount] := AString;
  Inc(FAdditionalCount);
end;
{$ENDIF}

procedure TXmlStringInternPool.Clear;
begin
  FItems := nil;
  FStrings := nil;
  FCount := 0;
  FGrowThreshold := 0;

  { Index 0 should be an empty string }
  Get('');

  {$IFDEF CPU64BITS}
  FAdditionalStrings := nil;
  FAdditionalCount := 0;
  AddAdditionalString('');
  {$ENDIF}
end;

constructor TXmlStringInternPool.Create;
begin
  inherited;
  Clear;
end;

function TXmlStringInternPool.Get(const AString: PXmlChar;
  const ALength: Integer): Integer;
begin
  if (FCount >= FGrowThreshold) then
     Resize(Length(FItems) * 2);

  var HashCode := MurmurHash2(AString^, ALength * SizeOf(XmlChar));
  var Mask := Length(FItems) - 1;
  var Index := HashCode and Mask;

  while True do
  begin
    var HC := FItems[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (System.{$IFDEF XML_UTF8}AnsiStrings{$ELSE}SysUtils{$ENDIF}.StrLComp(PXmlChar(FStrings[FItems[Index].Index]), AString, ALength) = 0) then
      Exit(FItems[Index].Index);

    Index := (Index + 1) and Mask;
  end;

  SetString(FStrings[FCount], AString, ALength);
  FItems[Index].HashCode := HashCode;
  FItems[Index].Index := FCount;
  Result := FCount;
  Inc(FCount);
  Assert(FCount <= (1 shl 17));
end;

function TXmlStringInternPool.Find(const AString: XmlString): Integer;
begin
  var HashCode := MurmurHash2(Pointer(AString)^, Length(AString) * SizeOf(XmlChar));
  var Mask := Length(FItems) - 1;
  var Index := HashCode and Mask;

  while True do
  begin
    var HC := FItems[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (FStrings[FItems[Index].Index] = AString) then
      Exit(FItems[Index].Index);

    Index := (Index + 1) and Mask;
  end;

  Result := -1;
end;

function TXmlStringInternPool.Get(const AIndex: Integer): XmlString;
begin
  Assert(Cardinal(AIndex) < Cardinal(FCount));
  Result := FStrings[AIndex];
end;

{$IFDEF CPU64BITS}
function TXmlStringInternPool.GetAdditionalString(
  const AIndex: Integer): XmlString;
begin
  Assert(Cardinal(AIndex) < Cardinal(FAdditionalCount));
  Result := FAdditionalStrings[AIndex];
end;
{$ENDIF}

procedure TXmlStringInternPool.Resize(ANewSize: Integer);
var
  OldItems, NewItems: TArray<TItem>;
begin
  if (ANewSize < 4) then
    ANewSize := 4;
  var NewMask := ANewSize - 1;
  SetLength(NewItems, ANewSize);
  SetLength(FStrings, ANewSize); // TODO : Could be less
  for var I := 0 to ANewSize - 1 do
    NewItems[I].HashCode := EMPTY_HASH;
  OldItems := FItems;

  for var I := 0 to Length(OldItems) - 1 do
  begin
    if (OldItems[I].HashCode <> EMPTY_HASH) then
    begin
      var NewIndex := OldItems[I].HashCode and NewMask;
      while (NewItems[NewIndex].HashCode <> EMPTY_HASH) do
        NewIndex := (NewIndex + 1) and NewMask;
      NewItems[NewIndex] := OldItems[I];
    end;
  end;

  FItems := NewItems;
  FGrowThreshold := (ANewSize * 3) shr 2; // 75%
end;

{ TXmlPointerMap }

procedure TXmlPointerMap.Clear;
begin
  FItems := nil;
  FCount := 0;
  FGrowThreshold := 0;
end;

function TXmlPointerMap.Get(const AKey: Pointer; const AID: Integer): Pointer;
begin
  if (FCount = 0) then
    Exit(nil);

  var Key := UIntPtr(AKey) + Cardinal(AID);
  var HashCode := Hash(Key);
  var Mask := Length(FItems) - 1;
  var Index := HashCode and Mask;

  while True do
  begin
    var HC := FItems[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Exit(nil);

    if (HC = HashCode) and (FItems[Index].Key = Key) then
      Exit(FItems[Index].Value);

    Index := (Index + 1) and Mask;
  end;
end;

{$IFOPT Q+}
  {$DEFINE Q_ON}
  {$OVERFLOWCHECKS OFF}
{$ENDIF}

class function TXmlPointerMap.Hash(const AKey: UIntPtr): Integer;
var
  H: UIntPtr;
begin
  // MurmurHash3 finalizer
  {$IFDEF CPU32BITS}
  H := AKey xor (AKey shr 16);
  H := H * $85ebca6b;
  H := H xor (H shr 13);
  H := H * $c2b2ae35;
  Result := (H xor (H shr 16)) and $7FFFFFFF;
  {$ELSE}
  H := AKey xor (AKey shr 33);
  H := H * $ff51afd7ed558ccd;
  H := H xor (H shr 33);
  H := H * $c4ceb9fe1a85ec53;
  Result := (H xor (H shr 33)) and $7FFFFFFF;
  {$ENDIF}
end;

{$IFDEF Q_ON}
  {$OVERFLOWCHECKS ON}
{$ENDIF}

procedure TXmlPointerMap.Map(const AKey: Pointer; const AID: Integer;
  const AValue: Pointer);
begin
  if (FCount >= FGrowThreshold) then
     Resize(Length(FItems) * 2);

  var Key := UIntPtr(AKey) + Cardinal(AID);
  var HashCode := Hash(Key);
  var Mask := Length(FItems) - 1;
  var Index := HashCode and Mask;

  while True do
  begin
    var HC := FItems[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (FItems[Index].Key = Key) then
    begin
      { Update }
      FItems[Index].Value := AValue;
      Exit;
    end;

    Index := (Index + 1) and Mask;
  end;

  FItems[Index].HashCode := HashCode;
  FItems[Index].Key := Key;
  FItems[Index].Value := AValue;
  Inc(FCount);
end;

procedure TXmlPointerMap.Resize(ANewSize: Integer);
var
  OldItems, NewItems: TArray<TItem>;
begin
  if (ANewSize < 4) then
    ANewSize := 4;
  var NewMask := ANewSize - 1;
  SetLength(NewItems, ANewSize);
  for var I := 0 to ANewSize - 1 do
    NewItems[I].HashCode := EMPTY_HASH;
  OldItems := FItems;

  for var I := 0 to Length(OldItems) - 1 do
  begin
    if (OldItems[I].HashCode <> EMPTY_HASH) then
    begin
      var NewIndex := OldItems[I].HashCode and NewMask;
      while (NewItems[NewIndex].HashCode <> EMPTY_HASH) do
        NewIndex := (NewIndex + 1) and NewMask;
      NewItems[NewIndex] := OldItems[I];
    end;
  end;

  FItems := NewItems;
  FGrowThreshold := (ANewSize * 3) shr 2; // 75%
end;

end.
