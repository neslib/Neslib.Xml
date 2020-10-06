{ <- Illegal Characters? Simply remove! It is the UTF-8 Byte Order Mark.
     Open with UTF-8 enabled Editor if you want to read the Cyrillic Text
 ************************************************************
 SimpleXML - Библиотека для синтаксического разбора текстов XML
   и преобразования в иерархию XML-объектов.
   И наоборот: можно сформировать иерархию XML-объектов, и
   уже из нее получить текст XML.
   Достойная замена для MSXML. При использовании Ansi-строк
   работает быстрее и кушает меньше памяти.

 (с) Авторские права 2002,2003 Михаил Власов.
   Библиотека бесплатная и может быть использована по любому назначению.
   Разрешается внесение любых изменений и использование измененных
   библиотек без ограничений.
   Единственное требование: Данный текст должен присутствовать
   без изменений во всех модификациях библиотеки.

   Все пожелания приветствую по адресу misha@integro.ru
   Так же рекомендую посетить мою страничку: http://mv.rb.ru
   Там Вы всегда найдете самую последнюю версию библиотеки.
   Желаю приятного программирования, Михаил Власов.

   Translations: Yahoo Babel Fish / Samuel Soldat

SimpleXML - By Michael Vlasov. Library for XML parsing and convertion to
   XML objects hierarchy and vise versa. Worthy replacement for MSXML.
   While using ANSI strings works much faster.

 (c) Copyrights 2002, 2003 Michail Vlasov.
   This Library is free and can be used for any needs. The introduction of 
   any changes and the use of those changed library is permitted without
   limitations. Only requirement:
   This text must be present without changes in all modifications of library.

   All wishes I greet to misha@integro.ru So I recommend to visit my page: http://mv.rb.ru
   There you will always find the quite last version of library. I desire pleasant programming,
   Michail Vlasov. It must be present without changes in all modifications of library.

   -----------------------------------------------------------------------------------------------

   What's new:
   03-Dec-2009 so - Support for Delphi 2007/2009
                  - Character set conversions included (only some few)
                  - Make library thread safe by removing some global vars
                  - SelectSingleNode and SelectNodes understand XML Pathes
                  - FullPath return XML Path of current Node
                  - License change to Mozilla Public License Version 1.1
   23-Dec-2009 so - CloneNode copy data
   24-Dec-2009 so - Improved performance for parsing
   27-Dec-2009 so - Improved performance for hash and save
   03-Jan-2010 so - Minor bugs in russian error messages fixed
   14-Apr-2010 so - ExchangeChilds added                        
   06-Dec-2010 so - Minor Changes in error messages 
   16-Apr-2012 so - BOM support added
   16-Jul-2012 so - Error message in the case of 4-Byte-Unicode (not supported)
   12-Nov-2012 vz - Reformed logic saved long attributes - thanks to Vadim Zharkov
   23-Nov-2012 so - It is not possible to copy aNode from one Doc to another 
   23-Feb-2013 so - Bug in Get_Text
   24-Mar-2013 lg - Some new features - thanks to Lukas Gebauer
                  - Ansi-version can use UTF8-Strings (see XMLDefaultcodepage)
                  - Error messages with line and columne numbers
                  - OnTagBegin/OnTagEnd-Events
                  - 4 Byte-UTF8-Decoding
   03-Apr-2013 vb - DateTime strings are now somewhat more W3C compliant - thanks to Vladimir Belyaev

   -----------------------------------------------------------------------------------------------

 (c) Copyrights 2009 - 2013 Samuel Soldat.

                     Latest releases of SimpleXml.pas are made available through the
                      distribution site at: http://www.audio-data.de/simplexml.html

                        See readme.txt for an introduction and documentation.

              *********************************************************************
              * The contents of this file are used with permission, subject to    *
              * the Mozilla Public License Version 1.1 (the "License"); you may   *
              * not use this file except in compliance with the License. You may  *
              * obtain a copy of the License at                                   *
              * http:  www.mozilla.org/MPL/MPL-1.1.html                           *
              *                                                                   *
              * Software distributed under the License is distributed on an       *
              * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or    *
              * implied. See the License for the specific language governing      *
              * rights and limitations under the License.                         *
              *                                                                   *
              *  Contributor(s)                                                   *
              *  (mv)  Michail Vlasov    <misha@integro.ru>                       *
              *  (so)  Samuel Soldat     <samuel.soldat@audio-data.de>            *
              *                                                                   *
              *********************************************************************

   -----------------------------------------------------------------------------------------------
}
unit SimpleXML;

{$WARNINGS OFF}

interface

uses
  SysUtils, Types, Windows, Classes;
{$IF CompilerVersion>=18}{$DEFINE Regions}{$IFEND}
{$IFDEF Regions}{$REGION 'Constantes Declaration'}{$ENDIF}
const
  BinXmlSignatureSize = Length('< binary-xml >');
  BinXmlSignature: AnsiString = '< binary-xml >';

  BINXML_USE_WIDE_CHARS = 1;
  BINXML_COMPRESSED = 2;
  DefaultHashSize = 499;
  AnsiCodepage = CP_ACP;  // set CP_UTF8 if you want to use UTF8-encoded AnsiStrings

  XSTR_NULL = '{{null}}';

  SourceBufferSize=$4000;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Interfaces'}{$ENDIF}
type
  // TXmlString - тип строковых переменных, используемых в SimpleXML.
  // Может быть String или WideString.
  // TXmlString - The type of the string variables, used in SimpleXML.
  //  There can be String or WideString

  {$DEFINE English}

  {$IFNDEF Unicode}
    {.$DEFINE XML_WIDE_CHARS}
    {$IFDEF XML_WIDE_CHARS}
    PXmlChar = PWideChar;
    TXmlChar = WideChar;
    TXmlString = WideString;
    {$ELSE}
    PXmlChar = PChar;
    TXmlChar = Char;
    TXmlString = String;
    {$ENDIF}
  {$ELSE}
  PXmlChar = PChar;
  TXmlChar = Char;
  TXmlString = String;
  {$ENDIF}

  {$IF not Declared(RawByteString)}
  RawByteString=AnsiString;
  {$IFEND}
  {$IF not Declared(TBytes)}
  TBytes = TByteDynArray;
  {$IFEND}
  {$IF (CompilerVersion<20.00)}
  NativeInt = type Integer;     //Override NativeInt because in Delphi2007 SizeOf(NativeInt)<>SizeOf(Pointer)
  {$IFEND}

  TXmlNodeType = (NODE_INVALID, NODE_ELEMENT, NODE_TEXT, NODE_CDATA_SECTION,
                  NODE_PROCESSING_INSTRUCTION, NODE_COMMENT, NODE_DOCUMENT);
  
  IXmlDocument = interface;
  IXmlElement = interface;
  IXmlText = interface;
  IXmlCDATASection = interface;
  IXmlComment = interface;
  IXmlProcessingInstruction = interface;

  // IXmlBase - базовый интерфейс для всех интерфейсов SimpleXML.
  IXmlBase = interface
    // GetObject - возвращает ссылку на объект, реализующий интерфейс.
    function GetObject: TObject;
  end;

  // IXmlNameTable - таблица имен. Каждому имени сопоставляется некий
  // уникальный числовой идентификатор. Используется для хранения
  // азваний тэгов и атрибутов.
  IXmlNameTable = interface(IXmlBase)
    // GetID - возвращает числовой идентификатор указанной строки.
    function GetID(const aName: TXmlString): NativeInt;
    // GetID - возвращает строку, соответствующую указанному числовому
    // идентификатору.
    function GetName(anID: NativeInt): TXmlString;
  end;

  IXmlNode = interface;

  // IXmlNodeList - список узлов. Список организован в виде массива.
  // Доступ к элементам списка по индексу
  IXmlNodeList = interface(IXmlBase)
    // Get_Count - количество узлов в списке
    function Get_Count: Integer;
    // Get_Item - получить узел по индексу
    function Get_Item(anIndex: Integer): IXmlNode;
    procedure Exchange(Index1, Index2: Integer);
    // Get_XML - возвращает представление элементов списка в формате XML
    function Get_XML: TXmlString;

    property Count: Integer read Get_Count;
    property Item[anIndex: Integer]: IXmlNode read Get_Item; default;
    property XML: TXmlString read Get_XML;
  end;

  // IXmlNode - узел XML-дерева
  IXmlNode = interface(IXmlBase)
    // Get_NameTable - таблица имен, используемая данным узлом
    function Get_NameTable: IXmlNameTable;
    // Get_NodeName - возвращает название узла. Интерпретация названия узла
    // зависит от его типа
    function Get_NodeName: TXmlString;
    // Get_NodeNameID - возвращает код названия узла
    function Get_NodeNameID: NativeInt;
    // Get_NodeType - возвращает тип узла
    function Get_NodeType: TXmlNodeType;
    // Get_Text - возвращает текст узла
    function Get_Text: TXmlString;
    // Set_Text - изменяет текст узла
    procedure Set_Text(const aValue: TXmlString);
    // Get_DataType - возаращает тип данных узла в терминах вариантов
    function Get_DataType: Integer;
    // Get_TypedValue - возвращает 
    function Get_TypedValue: Variant;
    // Set_TypedValue - изменяет текст узла на типизированное значение
    procedure Set_TypedValue(const aValue: Variant);
    // Get_XML - возвращает представление узла и всех вложенных узлов
    // в формате XML.
    function Get_XML: TXmlString;

    // CloneNode - создает точную копию данного узла
    //  Если задан признак aDeep, то создастся копия
    //  всей ветви иерархии от данного узла.
    function CloneNode(aDeep: Boolean = True): IXmlNode;

    // Get_ParentNode - возвращает родительский узел
    function Get_ParentNode: IXmlNode;
    // Get_OwnerDocument - возвращает XML-документ,
    //  в котором расположен данный узел
    function Get_OwnerDocument: IXmlDocument;

    // Get_ChildNodes - возвращает список дочерних узлов
    function Get_ChildNodes: IXmlNodeList;
    // AppendChild - добавляет указанный узел в конец списка дочерних узлов
    procedure AppendChild(const aChild: IXmlNode);
    // InsertBefore - добавляет указанный узел в указанное место списка дочерних узлов
    procedure InsertBefore(const aChild, aBefore: IXmlNode);
    // ReplaceChild - заменяет указанный узел другим узлом
    procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
    // RemoveChild - удаляет указанный узел из списка дочерних узлов
    procedure RemoveChild(const aChild: IXmlNode);
    // ExchangeChild - Change node order
    procedure ExchangeChilds(const aChild1, aChild2: IXmlNode);

    // AppendElement - создает элемент и добавляет его в конец списка
    //  в конец списка дочерних объектов
    // created an element and add it to the end of the list as child node
    function AppendElement(aNameID: NativeInt): IXmlElement; overload;
    function AppendElement(const aName: TxmlString): IXmlElement; overload;

    // AppendText - создает текстовый узел и добавляет его 
    //  в конец списка дочерних объектов
    function AppendText(const aData: TXmlString): IXmlText; 

    // AppendCDATA - создает секцию CDATA и добавляет ее
    //  в конец списка дочерних объектов
    function AppendCDATA(const aData: TXmlString): IXmlCDATASection;

    // AppendComment - создает комментарий и добавляет его
    //  в конец списка дочерних объектов
    function AppendComment(const aData: TXmlString): IXmlComment; 

    // AppendProcessingInstruction - создает инструкцию и добавляет её
    //  в конец списка дочерних объектов
    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    
    // GetChildText - возвращает значение дочернего узла
    // SetChildText - добавляет или изменяет значение дочернего узла
    function GetChildText(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetChildText(const aName, aValue: TXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TXmlString); overload;

    // NeedChild - возвращает дочерний узел с указанным именем.
    //  Если узел не найден, то генерируется исключение
    function NeedChild(aNameID: NativeInt): IXmlNode; overload;
    function NeedChild(const aName: TXmlString): IXmlNode; overload;

    // EnsureChild - возвращает дочерний узел с указанным именем.
    //  Если узел не найден, то он будет создан
    function EnsureChild(aNameID: NativeInt): IXmlNode; overload;
    function EnsureChild(const aName: TXmlString): IXmlNode; overload;

    // RemoveAllChilds - удаляет все дочерние узлы
    procedure RemoveAllChilds;

    // SelectNodes - производит выборку узлов, удовлетворяющих
    //  указанным критериям
    function SelectNodes(const anExpression: TXmlString): IXmlNodeList;
    // SelectSingleNode - производит поиск первого узла, удовлетворяющего
    //  указанным критериям
    // SelectSingleNode - Get specified Node. You can indicate a complete path
    function SelectSingleNode(const anExpression: TXmlString): IXmlNode;
    // FullPath - Return full XML path to the XML Node - can used as anExpression
    function FullPath: TXmlString;
    // FindElement - производит поиск первого узла, удовлетворяющего
    //  указанным критериям
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;

    // Get_AttrCount - возвращает количество атрибутов
    function Get_AttrCount: Integer;
    // Get_AttrNameID - возвращает код названия атрибута
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    // Get_AttrName - возвращает название атрибута
    function Get_AttrName(anIndex: Integer): TXmlString;
    // RemoveAttr - удаляет атрибут
    procedure RemoveAttr(const aName: TXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    // RemoveAllAttrs - удаляет все атрибуты
    procedure RemoveAllAttrs;

    // AttrExists - проверяет, задан ли указанный атрибут.
    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TXmlString): Boolean; overload;

    // GetAttrType - возаращает тип данных атрибута в терминах вариантов
    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TXmlString): Integer; overload;

    // GetAttrType - возвращает тип атрибута
    //  Result
    // GetVarAttr - возвращает типизированное значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TXmlString; aValue: Variant); overload;

    // NeedAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то генерируется исключение
    function NeedAttr(aNameID: NativeInt): TXmlString; overload;
    function NeedAttr(const aName: TXmlString): TXmlString; overload;

    // GetAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetAttr(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetAttr(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetAttr(aNameID: NativeInt; const aValue: TXmlString); overload;
    procedure SetAttr(const aName, aValue: TXmlString); overload;

    // GetBytesAttr - return attribut as raw data 
    function GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes = nil): TBytes; overload;
    function GetBytesAttr(const aName: TXmlString; const aDefault: TBytes = nil): TBytes; overload;

    // GetBoolAttr - возвращает целочисленное значение указанного атрибута
    // SetBoolAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TXmlString; aValue: Boolean); overload;

    // GetIntAttr - возвращает целочисленное значение указанного атрибута
    // SetIntAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TXmlString; aValue: Integer); overload;

    // GetDateTimeAttr - возвращает целочисленное значение указанного атрибута
    // SetDateTimeAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TXmlString; aValue: TDateTime); overload;

    // GetFloatAttr - возвращает значение указанного атрибута в виде
    //  вещественного числа
    // SetFloatAttr - изменяет или добавляет указанный атрибут вещественным
    //  значением
    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TXmlString; aValue: Double); overload;

    // GetHexAttr - получение значения указанного атрибута в целочисленном виде.
    //  Строковое значение атрибута преобразуется в целое число. Исходная
    //  строка должна быть задана в шестнадцатиричном виде без префиксов
    //  ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //  генерируется исключение.
    //  Если атрибут не задан, возвращается значение параметра aDefault.
    // SetHexAttr - изменение значения указанного атрибута на строковое
    //  представление целого числа в шестнадцатиричном виде без префиксов
    //    ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //    генерируется исключение.
    //    Если атрибут не был задан, до он будет добавлен.
    //    Если был задан, то будет изменен.
    function GetHexAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    procedure SetHexAttr(const aName: TXmlString; aValue: Integer; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Integer; aDigits: Integer = 8); overload;

    //  GetEnumAttr - ищет значение атрибута в указанном списке строк и
    //    возвращает индекс  найденной строки. Если атрибут задан но не найден
    //    в списке, то генерируется исключение.
    //    Если атрибут не задан, возвращается значение параметра aDefault.
    function GetEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;

    function NeedEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString): Integer; overload;

    function Get_Values(const aName: String): Variant;
    procedure Set_Values(const aName: String; const aValue: Variant);

    function AsElement: IXmlElement;
    function AsText: IXmlText;
    function AsCDATASection: IXmlCDATASection;
    function AsComment: IXmlComment;
    function AsProcessingInstruction: IXmlProcessingInstruction;

    property NodeName: TXmlString read Get_NodeName;
    property NodeNameID: NativeInt read Get_NodeNameID;
    property NodeType: TXmlNodeType read Get_NodeType;
    property ParentNode: IXmlNode read Get_ParentNode;
    property OwnerDocument: IXmlDocument read Get_OwnerDocument;
    property NameTable: IXmlNameTable read Get_NameTable;
    property ChildNodes: IXmlNodeList read Get_ChildNodes;
    property AttrCount: Integer read Get_AttrCount;
    property AttrNames[anIndex: Integer]: TXmlString read Get_AttrName;
    property AttrNameIDs[anIndex: Integer]: NativeInt read Get_AttrNameID;
    property Text: TXmlString read Get_Text write Set_Text;
    property DataType: Integer read Get_DataType;
    property TypedValue: Variant read Get_TypedValue write Set_TypedValue;
    property XML: TXmlString read Get_XML;
    property Values[const aName: String]: Variant read Get_Values write Set_Values; default;
  end;

  IXmlElement = interface(IXmlNode)
    //  ReplaceTextByCDATASection - удаляет все текстовые элементы и добавляет
    //    одну секцию CDATA, содержащую указанный текст
    procedure ReplaceTextByCDATASection(const aText: TXmlString);

    //  ReplaceTextByBinaryData - удаляет все текстовые элементы и добавляет
    //    один текстовый элемент, содержащий указанные двоичные данные
    //    в формате "base64".
    //    Если параметр aMaxLineLength не равен нулю, то производится разбивка
    //    полученой строки на строки длиной aMaxLineLength.
    //    Строки разделяются парой символов #13#10 (CR,LF).
    //    После последней строки указанные символы не вставляются.
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
                                      aMaxLineLength: Integer);

    //  GetTextAsBinaryData - cобирает все текстовые элементы в одну строку и
    //    производит преобразование из формата "base64" в двоичные данные.
    //    При преобразовании игнорируются все пробельные символы (с кодом <= ' '),
    //    содержащиеся в исходной строке.
    function GetTextAsBinaryData: TBytes;

  end;

  IXmlCharacterData = interface(IXmlNode)
  end;

  IXmlText = interface(IXmlCharacterData)
  end;

  IXmlCDATASection = interface(IXmlCharacterData)
  end;

  IXmlComment = interface(IXmlCharacterData)
  end;

  IXmlProcessingInstruction = interface(IXmlNode)
  end;

  THookTag = procedure(Sender: TObject; aNode: IXmlNode) of object;

  IXmlDocument = interface(IXmlNode)
    function Get_DocumentElement: IXmlElement;
    function Get_BinaryXML: RawByteString;
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);
    function Get_OnTagEnd: THookTag;
    procedure Set_OnTagEnd(aValue: THookTag);
    function Get_OnTagBegin: THookTag;
    procedure Set_OnTagBegin(aValue: THookTag);

    function NewDocument(const aVersion, anEncoding: TXmlString;
      aRootElementNameID: NativeInt): IXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TXmlString): IXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IXmlElement; overload;
    function CreateElement(const aName: TXmlString): IXmlElement; overload;
    function CreateText(const aData: TXmlString): IXmlText;
    function CreateCDATASection(const aData: TXmlString): IXmlCDATASection;
    function CreateComment(const aData: TXmlString): IXmlComment;
    function CreateProcessingInstruction(const aTarget,
      aData: TXmlString): IXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;

    procedure LoadXML(const aXML: RawByteString);
    procedure LoadBinaryXML(const aXML: RawByteString);

    procedure Load(aStream: TStream); overload;
    procedure Load(const aFileName: String); overload;

    procedure LoadResource(aType, aName: PChar);

    procedure Save(aStream: TStream); overload;
    procedure Save(const aFileName: String); overload;

    procedure SaveBinary(aStream: TStream; anOptions: LongWord = 0); overload;
    procedure SaveBinary(const aFileName: String; anOptions: LongWord = 0); overload;

    property PreserveWhiteSpace: Boolean read Get_PreserveWhiteSpace write Set_PreserveWhiteSpace;
    property DocumentElement: IXmlElement read Get_DocumentElement;
    property BinaryXML: RawByteString read Get_BinaryXML;
    property OnTagBegin: THookTag read Get_OnTagBegin write Set_OnTagBegin;
    property OnTagEnd: THookTag read Get_OnTagEnd write Set_OnTagEnd;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Functions'}{$ENDIF}
function CreateNameTable(aHashTableSize: Integer = DefaultHashSize): IXmlNameTable;
function CreateXmlDocument(const aRootElementName: String = '';
                           const aVersion: String = '';    // '1.0'
                           const anEncoding: String = '';  // 'UTF-8'
                           const aNameTable: IXmlNameTable = nil): IXmlDocument;

function CreateXmlElement(const aName: TXmlString; const aNameTable: IXmlNameTable = nil): IXmlElement;
function LoadXmlDocumentFromXML(const aXML: RawByteString): IXmlDocument;
function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IXmlDocument;

function LoadXmlDocument(aStream: TStream): IXmlDocument; overload;
function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Globle Variables'}{$ENDIF}
var
  DefaultPreserveWhiteSpace: Boolean = False;
  DefaultIndentText: TXmlString = #9;
  XMLPathDelimiter: TXmlString = '\';
  {$if not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
  XMLCodepage: Word = AnsiCodepage;  //Codepage used for TXmlString
  {$ifend}

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper Functions'}{$ENDIF}
function XSTRToFloat(const s: TXmlString): Double;
function FloatToXSTR(v: Double): TXmlString;
function DateTimeToXSTR(v: TDateTime): TXmlString;
function XSTRToDateTime(const s: String): TDateTime;
function VarToXSTR(const v: TVarData): TXmlString;

function TextToXML(const aText: TXmlString): TXmlString;
function BinToBase64(const aBin; aSize: Integer; aMaxLineLength: Integer=80): TXmlString;
function Base64ToBin(const aBase64: TXmlString): TBytes;
function IsXmlDataString(const aData: RawByteString): Boolean;
function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
procedure PrepareToSaveXml(var anElem: IXmlElement; const aChildName: String);
function PrepareToLoadXml(var anElem: IXmlElement; const aChildName: String): Boolean;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}

implementation

uses
  SysConst, Variants, DateUtils;

{$IFDEF Regions}{$REGION 'Error Messages'}{$ENDIF}
resourcestring
  {$IFDEF English}
  SSimpleXmlError1 = 'Failed to get list item: Index %d out of range';
  SSimpleXmlError2 = 'Incomplete definition of the element';
  SSimpleXmlError3 = 'Invalid symbol in the name of the element';
  SSimpleXmlError4 = 'Error reading binary XML: incorrect node-type';
  SSimpleXmlError5 = 'Error writing binary XML: incorrect node-type';
  SSimpleXmlError6 = 'Incorrect value of the attribute "%0:s" at element "%1:s".'#13#10 +
                     'Allowed values are: '#13#10 + '%2:s';
  SSimpleXmlError7 = 'Attribute "%s" not found';
  SSimpleXmlError8 = 'Attribute "%s" not assigned';
  SSimpleXmlError9 = 'This feature is not supported by SimpleXML';
  SSimpleXmlError10 = 'Error: Child node "%s" not found';
  SSimpleXmlError11 = 'Name must start with letter or "_" at [%d:%d]';
  SSimpleXmlError12 = 'Number expected at [%d:%d]';
  SSimpleXmlError13 = 'Hexadecimal number expected at [%d:%d]';
  SSimpleXmlError14 = '"#" or XML entity symbol name expected at [%d:%d]';
  SSimpleXmlError15 = 'Unknown XML entity symbol name "%s" found at [%d:%d]';
  SSimpleXmlError16 = 'Character "%s" expected at [%d:%d]';
  SSimpleXmlError17 = 'Text "%s" expected at [%d:%d]';
  SSimpleXmlError18 = 'Character "<" cannot be used in the values of attributes at [%d:%d]';
  SSimpleXmlError19 = '"%s" expected at [%d:%d]';
  SSimpleXmlError20 = 'The value of the attribute is expected at [%d:%d]';
  SSimpleXmlError21 = 'Line constant expected at [%d:%d]';
  SSimpleXmlError22 = '"%s" expected at [%d:%d]';
  SSimpleXmlError23 = 'Error reading data';
  SSimpleXmlError24 = 'Error reading value: incorrect type';
  SSimpleXmlError25 = 'Unknown data type in variant';
  SSimpleXmlError26 = 'Encoding "%s" is not supported by SimpleXML';
  SSimpleXmlError27 = 'Unicode Encoding is not supported by SimpleXML';
  {$ELSE}
  {$IF CompilerVersion>=18}
  SSimpleXmlError1 = 'Ошибка получения элемента списка: индекс %d выходит за пределы';
  SSimpleXmlError2 = 'Не завершено определение элемента';
  SSimpleXmlError3 = 'Некорретный символ в имени элемента';
  SSimpleXmlError4 = 'Ошибка чтения двоичного XML: некорректный тип узла';
  SSimpleXmlError5 = 'Ошибка записи двоичного XML: некорректный тип узла';
  SSimpleXmlError6 = 'Неверное значение атрибута "%0:s" элемента "%1:s".'#13#10 +
                     'Допустимые значения:'#13#10 + '%2:s';
  SSimpleXmlError7 = 'Не найден атрибут "%s"';
  SSimpleXmlError8 = 'Не задан атрибут "%s"';
  SSimpleXmlError9 = 'Данная возможность не поддерживается SimpleXML';
  SSimpleXmlError10 = 'Ошибка: не найден дочерний элемент "%s".';
  SSimpleXmlError11 = 'Имя должно начинаться с буквы или "_" в [%d:%d]';
  SSimpleXmlError12 = 'Ожидается число в [%d:%d]';
  SSimpleXmlError13 = 'Ожидается шестнадцатеричное число в [%d:%d]';
  SSimpleXmlError14 = 'Ожидается "#" или имя упрамляющего символа в [%d:%d]';
  SSimpleXmlError15 = 'Некорректное имя управляющего символа "%s" в [%d:%d]';
  SSimpleXmlError16 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError17 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError18 = 'Символ "<" не может использоваться в значениях атрибутов в [%d:%d]';
  SSimpleXmlError19 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError20 = 'Ожидается значение атрибута в [%d:%d]';
  SSimpleXmlError21 = 'Ожидается строковая константа в [%d:%d]';
  SSimpleXmlError22 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError23 = 'Ошибка чтения данных.';
  SSimpleXmlError24 = 'Ошибка чтения значения: некорректный тип.';
  SSimpleXmlError25 = 'Ошибка записи значения: некорректный тип.';
  SSimpleXmlError26 = 'Данная Зашифрование "%s" не поддерживается SimpleXML';
  SSimpleXmlError27 = 'Unicode кодировка не поддерживается SimpleXML';
  {$ELSE}
  {$INCLUDE *_Cyrillic.inc}
  {$IFEND}
  {$ENDIF}
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Codepage Support'}{$ENDIF}
const
  XMLEncodingData: Array [0..22] of
      record
        Encoding: TXmlString;
        CodePage: Word;
      end = ((Encoding: 'UTF-8';        CodePage: CP_UTF8),
             (Encoding: 'WINDOWS-1250'; CodePage:  1250),
             (Encoding: 'WINDOWS-1251'; CodePage:  1251),
             (Encoding: 'WINDOWS-1252'; CodePage:  1252),
             (Encoding: 'WINDOWS-1253'; CodePage:  1253),
             (Encoding: 'WINDOWS-1254'; CodePage:  1254),
             (Encoding: 'WINDOWS-1255'; CodePage:  1255),
             (Encoding: 'WINDOWS-1256'; CodePage:  1256),
             (Encoding: 'WINDOWS-1257'; CodePage:  1257),
             (Encoding: 'WINDOWS-1258'; CodePage:  1258),
             (Encoding: 'ISO-8859-1';   CodePage: 28591),
             (Encoding: 'ISO-8859-2';   CodePage: 28592),
             (Encoding: 'ISO-8859-3';   CodePage: 28593),
             (Encoding: 'ISO-8859-4';   CodePage: 28594),
             (Encoding: 'ISO-8859-5';   CodePage: 28595),
             (Encoding: 'ISO-8859-6';   CodePage: 28596),
             (Encoding: 'ISO-8859-7';   CodePage: 28597),
             (Encoding: 'ISO-8859-8';   CodePage: 28598),
             (Encoding: 'ISO-8859-9';   CodePage: 28599),
             (Encoding: 'ISO-8859-13';  CodePage: 28603),
             (Encoding: 'ISO-8859-15';  CodePage: 28605),
             (Encoding: 'KOI8-R';       CodePage: 20866),
             (Encoding: 'KOI8-U';       CodePage: 21866));

function FindCodepage(const s: TXmlString): Word;
var 
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(XMLEncodingData) do
  begin
    if SameText(s, XMLEncodingData[i].Encoding)
    then begin
      Result := XMLEncodingData[i].CodePage;
      break;
    end;
  end;
end;

function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Integer; Source: PByte; var SourceBytes: Integer): Integer;
//After call SourceBytes is the number of bytes not transfered to dest
var
  uc: UCS4Char;
begin
  Result := 0;
  if (Source <> nil) and (Dest <> nil)
  then begin
    while (SourceBytes>0) and (Result < MaxDestChars) do
    begin
      if (Source^ and $80=0)
      then begin //1 Byte Source -> 7 Bit Unicode Char
        Dest^ := WideChar(Source^);
      end
      else
      if (Source^ and $E0=$C0)
      then begin //2 Byte Source -> 11 Bit Unicode Char
        if (SourceBytes>=2)
        then begin
          Dest^ := WideChar((Word(Source^) and $1F) shl 6); inc(Source);
          Dest^ := WideChar(Word(Dest^) or Word(Source^) and $3F);
          dec(SourceBytes);
        end
        else
          break;
      end
      else
      if (Source^ and $F0=$E0)
      then begin //3 Byte Source -> 16 Bit Unicode Char
        if (SourceBytes>=3)
        then begin
          Dest^ := WideChar((Word(Source^) and $F) shl 12); inc(Source);
          Dest^ := WideChar(Word(Dest^) or (Word(Source^) and $3F) shl 6); inc(Source);
          Dest^ := WideChar(Word(Dest^) or (Word(Source^) and $3F));
          dec(SourceBytes, 2);
        end
        else
          break;
      end
      else
      if (Source^ and $F8=$F0)
      then begin //4 Byte Source -> 21 Bit Unicode Char
        if (SourceBytes>=4) and ((Result + 1) < MaxDestChars)
        then begin
          //get UCS4 char...
          uc := (UCS4Char(Source^) and $8) shl 18; inc(Source);
          uc := uc or ((UCS4Char(Source^) and $3F) shl 12); inc(Source);
          uc := uc or ((UCS4Char(Source^) and $3F) shl 6); inc(Source);
          uc := uc or (UCS4Char(Source^) and $3F);
          dec(SourceBytes, 3);
          if (uc > $10FFFF) or ((uc >= $D800) and (uc <= $DFFF)) then
            Dest^ := WideChar('?') //invalid value!
          else begin
            //...and create surrogate pair of two WideChars
            dec(uc, $10000);
            Dest^ := WideChar(uc div $400 + $D800);
            inc(Dest);
            inc(Result);
            Dest^ := WideChar(uc mod $400 + $DC00);
          end;
        end
        else
          break;
      end;
      inc(Source);
      dec(SourceBytes);
      inc(Dest);
      Inc(Result);
    end;
  end;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper functions'}{$ENDIF}
function TextToXML(const aText: TXmlString): TXmlString;
const
  cLowerThan: TXmlString='&lt;';
  cGreaterThan: TXmlString='&gt;';
  cAmpersand: TXmlString='&amp;';
  cQuote: TXmlString='&quot;';
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Length(aText) do
    case aText[i] of
      '<', '>': Inc(j, 4);
      '&': Inc(j, 5);
      '"': Inc(j, 6);
      else
        Inc(j);
    end;
  if j = Length(aText) then
    Result := aText
  else begin
    SetLength(Result, j);
    j := 1;
    for i := 1 to Length(aText) do
      case aText[i] of
        '<': begin Move(PXmlChar(cLowerThan)^, Result[j], 4*SizeOf(TXmlChar)); Inc(j, 4) end;
        '>': begin Move(PXmlChar(cGreaterThan)^, Result[j], 4*SizeOf(TXmlChar)); Inc(j, 4) end;
        '&': begin Move(PXmlChar(cAmpersand)^, Result[j], 5*SizeOf(TXmlChar)); Inc(j, 5) end;
        '"': begin Move(PXmlChar(cQuote)^, Result[j], 6*SizeOf(TXmlChar)); Inc(j, 6) end;
        else begin Result[j] := aText[i]; Inc(j) end;
      end;
  end;
end;

function XSTRToFloat(const s: TXmlString): Double;
var
  code: Integer;
begin
  Val(s,  result, code);
  if (code>0) and (code<=2)
  then begin
    code := 0;
    if SameText(s, 'INF') or SameText(s, '+INF')
    then
      result :=  (1.0 / 0.0)
    else
    if SameText(s, '-INF')
    then
      result :=  (-1.0 / 0.0)
    else
    if SameText(s, 'NAN')
    then
      result :=  (0.0 / 0.0)
    else
      code := 1;
  end;
  if (code>0)
  then
    raise Exception.CreateFmt(SInvalidFloat, [s]);
end;

function FloatToXSTR(v: Double): TXmlString;
var
  i: Integer;
begin
  Str(v, Result);
  i := 1;
  while (Result[i]<=' ') do //Str(NaN, Result) => Result = '                    Nan'
    inc(i);
  if Result[i]<>'+' then dec(i);
  if i>0
  then
    Delete(Result, 1, i);
end;

function XSTRToDateTime(const s: String): TDateTime;
var
  aPos: Integer;

  function FetchTo(aStop: Char): Integer;
  var
    i: Integer;
  begin
    i := aPos;
    while (i <= Length(s)) and (s[i]>='0') and (s[i]<='9') do
      Inc(i);
    if i > aPos then
      Result := StrToInt(Copy(s, aPos, i - aPos))
    else
      Result := 0;
    if (i <= Length(s)) and (s[i] = aStop) then
      aPos := i + 1
    else
      aPos := Length(s) + 1;
  end;

var
  y, m, d, h, n, ss: Integer;
begin
  aPos := 1;
  y := FetchTo('-'); m := FetchTo('-'); d := FetchTo('T');
  h := FetchTo(':'); n := FetchTo(':'); ss := FetchTo(#0);
  Result := EncodeDateTime(y, m, d, h, n, ss, 0);
end;

function DateTimeToXSTR(v: TDateTime): TXmlString;
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDateTime(v, y, m, d, h, n, s, ms);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, n, s])
end;

function VarToXSTR(const v: TVarData): TXmlString;
const
  BoolStr: array[Boolean] of TXmlString = ('0', '1');
var
  p: Pointer;
begin
  case v.VType of
    varNull: Result := XSTR_NULL;
    varSmallint: Result := IntToStr(v.VSmallInt);
    varInteger: Result := IntToStr(v.VInteger);
    varSingle: Result := FloatToXSTR(v.VSingle);
    varDouble: Result := FloatToXSTR(v.VDouble);
    varCurrency: Result := FloatToXSTR(v.VCurrency);
    varDate: Result := DateTimeToXSTR(v.VDate);
    varOleStr: Result := v.VOleStr;
    varBoolean: Result := BoolStr[v.VBoolean = True];
    varShortInt: Result := IntToStr(v.VShortInt);
    varByte: Result := IntToStr(v.VByte);
    varWord: Result := IntToStr(v.VWord);
    varLongWord: Result := IntToStr(v.VLongWord);
    varInt64: Result := IntToStr(v.VInt64);
    varString: Result := TXmlString(AnsiString(v.VString));
    {$IFDEF Unicode}
    varUString: Result := String(v.VUString);
    {$ENDIF}
    varArray + varByte:
      begin
        p := VarArrayLock(Variant(v));
        try
          Result := BinToBase64(p^, VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1, 0);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      Result := Variant(v)
  end;
end;

procedure PrepareToSaveXml(var anElem: IXmlElement; const aChildName: String);
begin
  if aChildName <> '' then
    anElem := anElem.AppendElement(aChildName);
end;

function PrepareToLoadXml(var anElem: IXmlElement; const aChildName: String): Boolean;
begin
  if (aChildName <> '') and Assigned(anElem) then
    anElem := anElem.selectSingleNode(aChildName).AsElement;
  Result := Assigned(anElem);
end;

function LoadXMLResource(aModule: HMODULE; aName, aType: PChar; const aXMLDoc: IXmlDocument): boolean;
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  Result := false;

  aRSRC := FindResource(aModule, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := LoadResource(aModule, aRSRC);
    aSize := SizeofResource(aModule, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr), aSize);
        aXMLDoc.LoadXML(AStr);
        Result := true;
      end;
    end;
  end;
end;

function IsXmlDataString(const aData: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := Copy(aData, 1, BinXmlSignatureSize) = BinXmlSignature;
  if not Result then begin
    i := 1;
    while (i <= Length(aData)) and (aData[i] in [#10, #13, #9, ' ']) do
      Inc(i);
    Result := Copy(aData, i, Length('<?xml ')) = '<?xml ';
  end;
end;

function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
begin
  if Length(AData)>BinXmlSignatureSize
  then
    Result := CompareMem(Pointer(aData), Pointer(BinXmlSignature), BinXmlSignatureSize)
  else
    Result := False;
end;

type
  PChars = ^TChars;
  TChars = packed record a, b, c, d: TXmlChar end;
  POctet = ^TOctet;
  TOctet = packed record a, b, c: Byte; end;

const
  Base64Map: array [0..63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{$IFDEF ADDebug}
var
  DebugId: Integer;
{$ENDIF}

procedure OctetToChars(po: POctet; aCount: Integer; pc: PChars);
var
  o: Integer;
begin
  if aCount = 1 then begin
    o := po.a shl 16;
    pc^.a := TXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := '=';
    pc^.d := '=';
  end
  else if aCount = 2 then begin
    o := po.a shl 16 or po.b shl 8;
    pc^.a := TXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := TXmlChar(Base64Map[(o shr 6) and $3F]);
    pc^.d := '=';
  end
  else if aCount > 2 then begin
    o := po.a shl 16 or po.b shl 8 or po.c;
    pc^.a := TXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := TXmlChar(Base64Map[(o shr 6) and $3F]);
    pc^.d := TXmlChar(Base64Map[o and $3F]);
  end;
end;

function BinToBase64(const aBin; aSize, aMaxLineLength: Integer): TXmlString;
var
  o: POctet;
  c: PChars;
  aCount: Integer;
  i: Integer;
begin
  o := @aBin;
  aCount := aSize;
  SetLength(Result, ((aCount + 2) div 3)*4);
  c := PChars(Result);
  while aCount > 0 do begin
    OctetToChars(o, aCount, c);
    Inc(o);
    Inc(c);
    Dec(aCount, 3);
  end;
  if aMaxLineLength > 0 then begin
    i := aMaxLineLength;
    while i <= Length(Result) do begin
      Insert(#13#10, Result, i);
      Inc(i, 2 + aMaxLineLength);
    end
  end;
end;

function CharTo6Bit(c: TXmlChar): Byte;
begin
  if (c >= 'A') and (c <= 'Z') then
    Result := Ord(c) - Ord('A')
  else if (c >= 'a') and (c <= 'z') then
    Result := Ord(c) - Ord('a') + 26
  else if (c >= '0') and (c <= '9') then
    Result := Ord(c) - Ord('0') + 52
  else if c = '+' then
    Result := 62
  else if c = '/' then
    Result := 63
  else
    Result := 0
end;

procedure CharsToOctet(c: PChars; o: POctet);
var
  i: Integer;
begin
  if c.c = '=' then begin // 1 byte
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12;
    o.a := (i shr 16) and $FF;
  end
  else if c.d = '=' then begin // 2 bytes
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6;
    o.a := (i shr 16) and $FF;
    o.b := (i shr 8) and $FF;
  end
  else begin // 3 bytes
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6 or CharTo6Bit(c.d);
    o.a := (i shr 16) and $FF;
    o.b := (i shr 8) and $FF;
    o.c := i and $FF;
  end;
end;

function Base64ToBin(const aBase64: TXmlString): TBytes;
var
  o: POctet;
  c: PChars;
  aCount: Integer;
  TempBase64: TXmlString;
  p1, p2: PXmlChar;
  N: Integer;
begin
  SetLength(TempBase64, Length(aBase64));
  N := Length(aBase64);
  p1 := Pointer(aBase64);
  p2 := Pointer(TempBase64);
  while N > 0  do
  begin
    if p1^>' '
    then begin
      p2^ := p1^;
      inc(p2);
    end;
    inc(p1);
    dec(N);
  end;
  N := NativeInt(p2 - Pointer(TempBase64));

  if N < 4 then
    SetLength(Result, 0)
  else begin
    SetLength(TempBase64, N);
    aCount := ((N + 3) div 4)*3;
    if TempBase64[N - 1] = TXmlChar('=')
    then
      Dec(aCount, 2)
    else
    if TempBase64[N] = TXmlChar('=')
    then
      Dec(aCount);
    SetLength(Result, aCount);
    FillChar(Pointer(Result)^, aCount, '*');
    c := Pointer(TempBase64);
    o := Pointer(Result);
    while aCount > 0 do begin
      CharsToOctet(c, o);
      Inc(o);
      Inc(c);
      Dec(aCount, 3);
    end;
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Reader Declaration'}{$ENDIF}
type
  TBinXmlReader = class
  private
    FOptions: LongWord;
  public
    procedure Read(var aBuf; aSize: Integer); virtual; abstract;
     
    function ReadLongint: Longint;
    function ReadAnsiString: String;
    function ReadWideString: WideString;
    function ReadXmlString: TXmlString;
    procedure ReadVariant(var v: TVarData);
  end;

  TStmXmlReader = class(TBinXmlReader)
  private
    FStream: TStream;
    FBufStart: PAnsiChar;
//    FBufEnd,
    FBufPtr: PAnsiChar;
    FBufSize: Integer;
    FBufRemain: Integer;
    FRemainSize: Integer;
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
    destructor Destroy; override;

    procedure Read(var aBuf; aSize: Integer); override;
  end;

  TStrXmlReader = class(TBinXmlReader)
  private
    FData: RawByteString;
    FPtr: PByte;
    FRemain: Integer;
  public
    constructor Create(const aData: RawByteString);

    procedure Read(var aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Writer Declaration'}{$ENDIF}
  TBinXmlWriter = class
  private
    FOptions: LongWord;
  public
    procedure Write(const aBuf; aSize: Integer); virtual; abstract;
    
    procedure WriteLongint(aValue: Longint);
    procedure WriteAnsiString(const aValue: String);
    procedure WriteWideString(const aValue: WideString);
    procedure WriteXmlString(const aValue: TXmlString);
    procedure WriteVariant(const v: TVarData);
  end;

  TStmXmlWriter = class(TBinXmlWriter)
  private
    FStream: TStream;
    FBufStart: PAnsiChar;
    FBufPtr: PAnsiChar;
    FBufSize: Integer;
    FRemain: Integer;
  public
    constructor Create(aStream: TStream; anOptions: LongWord; aBufSize: Integer);
    destructor Destroy; override;

    procedure Write(const aBuf; aSize: Integer); override;
  end;

  TStrXmlWriter = class(TBinXmlWriter)
  private
    FData: RawByteString;
    FBufPtr: PByte;
    FBufSize: Integer;
    FRemain: Integer;
    procedure FlushBuf;
  public
    constructor Create(anOptions: LongWord; aBufSize: Integer);

    procedure Write(const aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Base Classes'}{$ENDIF}
  TXmlBase = class(TInterfacedObject, IXmlBase)
  protected
    // реализация интерфейса IXmlBase
    function GetObject: TObject;
  public
  end;

  TXMLStringDynArray = array of TXmlString;
  TXmlNameTable = class(TXmlBase, IXmlNameTable)
  private
    FNames: array of TXMLStringDynArray;
    FHashTable: array of TCardinalDynArray;

    FXmlTextNameID: NativeInt;
    FXmlCDATASectionNameID: NativeInt;
    FXmlCommentNameID: NativeInt;
    FXmlDocumentNameID: NativeInt;
    FXmlNameID: NativeInt;
    FEncodingNameId: NativeInt;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
  protected
    function GetKeyID(NameID: NativeInt): Integer;
    function GetNameID(aHashKey: Cardinal): NativeInt;
    function GetID(const aName: TXmlString): NativeInt;
    function GetName(anID: NativeInt): TXmlString;
  public
    constructor Create(aHashTableSize: Integer);
    {$IFDEF ADDebug}
    destructor Destroy; override;
    {$ENDIF}

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
  end;

{ TXmlBase }

function TXmlBase.GetObject: TObject;
begin
  Result := Self;
end;

{ TXmlNameTable }

constructor TXmlNameTable.Create(aHashTableSize: Integer);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  SetLength(FNames, aHashTableSize);
  SetLength(FHashTable, aHashTableSize);
  FXmlTextNameID := GetID('#text');
  FXmlCDATASectionNameID := GetID('#cdata-section');
  FXmlCommentNameID := GetID('#comment');
  FXmlDocumentNameID := GetID('#document');
  FXmlNameID := GetID('xml');
  FEncodingNameId := GetID('encoding');
end;

procedure TXmlNameTable.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  i: Integer;
begin
  for i := 0 to High(FNames) do
  begin
    SetLength(FNames[i], 0);
    SetLength(FHashTable[i], 0);
  end;
  aCount := aReader.ReadLongint;
  for i := 0 to aCount - 1 do
  begin
    GetID(aReader.ReadXmlString);
  end;
end;

procedure TXmlNameTable.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  i, j: Integer;
begin
  aCount := 0;
  for i := 0 to High(FNames) do
  begin
    inc(aCount, Length(FNames[i]));
  end;
  aWriter.WriteLongint(aCount);
  for i := 0 to High(FNames) do
  begin
    for j := 0 to High(FNames[i]) do
    begin
      aWriter.WriteXmlString(FNames[i][j]);
    end;
  end;
end;

function NameHashKey(const aName: TXmlString): Cardinal;{$IF CompilerVersion>=18}inline;{$IFEND}
var
  i: Integer;
  p: PXmlChar;
begin
  p := Pointer(aName);
  Result := 0;
  for i := 1 to Length(aName) do
  begin
    Inc(Result, Result shl 6 xor Ord(p^));
//    Result := Result shl 5 + Result + Ord(p^);
    inc(p);
  end;
end;

function TXmlNameTable.GetKeyID(NameID: NativeInt): Integer;
begin
  Result := NameHashKey(GetName(NameID));
end;

{$IFDEF ADDebug}
destructor TXmlNameTable.Destroy;
begin
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  inherited;
end;
{$ENDIF}

function TXmlNameTable.GetID(const aName: TXmlString): NativeInt;
var
  i, L: Integer;
  aHashKey: Cardinal;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TXMLStringDynArray;
begin
  Result := 0;
  if aName <> ''
  then begin
    aHashKey := NameHashKey(aName);
    aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
    NameList := @FNames[aHashIndex];
    aHashKeyList := @FHashTable[aHashIndex];
    L := Length(aHashKeyList^);
    for i := 0 to L-1 do
    begin
      if (aHashKeyList^[i] = aHashKey) and (NameList^[i]=aName)
      then begin
        Result := NativeInt(Pointer(NameList^[i]));
        exit;
      end;
    end;
    SetLength(aHashKeyList^, L+1);
    aHashKeyList^[L] := aHashKey;
    SetLength(NameList^, L+1);
    NameList^[L] := aName;
    Result := NativeInt(Pointer(NameList^[L]));
  end;
end;

function TXmlNameTable.GetName(anID: NativeInt): TXmlString;
begin
  if anID = 0
  then
    Result := ''
  else
    Result := TXmlString(Pointer(anID));
end;

function TXmlNameTable.GetNameID(aHashKey: Cardinal): NativeInt;
var
  i: Integer;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TXMLStringDynArray;
begin
  Result := 0;
  aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
  NameList := @FNames[aHashIndex];
  aHashKeyList := @FHashTable[aHashIndex];
  for i := 0 to High(aHashKeyList^) do
  begin
    if aHashKeyList^[i] = aHashKey
    then begin
      Result := NativeInt(Pointer(NameList^[i]));
      exit;
    end;
  end;
end;

function CreateNameTable(aHashTableSize: Integer): IXmlNameTable;
begin
  Result := TXmlNameTable.Create(aHashTableSize)
end;

type
  TXmlNode = class;
  TXmlToken = class
  private
    FValueBuf: TXmlString;
    FSize: Integer;
    FLength: Integer;
  public
    constructor Create;
    procedure Clear;
    procedure AppendChar(aChar: TXmlChar);
    procedure AppendText(aText: PXmlChar; aCount: Integer);
    function Text: TXmlString;
    property Length: Integer read FLength;
  end;

  TXmlSource = class
  private
    FTokenStack: array of TXmlToken;
    FTokenStackTop: Integer;
    FToken: TXmlToken;
    FStream: TStream;
    FBuffer: PXmlChar;
    FBufPtr: PXmlChar;
    FBufSize: Integer;
    FRemainBuff: array [0..3] of AnsiChar;
    FRemainSize: Integer;
    FCodepage: Word;
    FStreamOwner: Boolean;
    FSourceLine: Int64;
    FSourceCol: Int64;
    function ExpectQuotedText(aQuote: TXmlChar): TXmlString;
  protected
  public
    CurChar: TXmlChar;
    AutoCodepage: Boolean;
    constructor Create(aStream: TStream); overload;
    constructor Create(aString: RawByteString); overload;
    destructor Destroy; override;

    function EOF: Boolean;
    function Next: Boolean;
    procedure SetCodepage(Codepage: Word);

    procedure SkipBlanks;
    function ExpectXmlName: TXmlString;
    function ExpectXmlEntity: TXmlChar;
    procedure ExpectChar(aChar: TXmlChar);
    procedure ExpectText(aText: PXmlChar);
    function ExpectDecimalInteger: Integer;
    function ExpectHexInteger: Integer;
    function ParseTo(aText: PXmlChar): TXmlString;
    procedure ParseAttrs(aNode: TXmlNode);

    procedure NewToken;
    procedure AppendTokenChar(aChar: TXmlChar);
    procedure AppendTokenText(aText: PXmlChar; aCount: Integer);
    function AcceptToken: TXmlString;
    procedure DropToken;
  end;

  TXmlSaver = class
  private
    FCodepage: Word;
    FBuffer: Pointer;
    FBufferPtr: PAnsiChar;
    FBuffersize: Integer;
    FRemain: Integer;
    procedure SaveToBuffer(XmlStr: PXmlChar; L: Integer);
    procedure Save(const XmlStr: TXmlString); virtual; abstract;
    procedure FlushBuffer; virtual; abstract;
  public
    constructor Create(aBufSize: Integer);
    destructor Destroy; override;
  end;

  TXmlStmSaver = class(TXmlSaver)
  private
    FStream: TStream;
    procedure Save(const XmlStr: TXmlString); override;
    procedure FlushBuffer; override;
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
  end;
  
  TXmlNodeList = class(TXmlBase, IXmlNodeList)
  private
    FOwnerNode: TXmlNode;

    FItems: array of TXmlNode;
    FCount: Integer;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
    procedure Grow;
  protected
    function Get_Count: Integer;
    function Get_Item(anIndex: Integer): IXmlNode;
    function Get_XML: TXmlString;
  public
    constructor Create(anOwnerNode: TXmlNode);
    destructor Destroy; override;

    function IndexOf(aNode: TXmlNode): Integer;
    procedure ParseXML(aXML: TXmlSource; aNames: TXmlNameTable; aPreserveWhiteSpace: Boolean; HookTagEnd: THookTag; HookTagBegin: THookTag);
    procedure SaveXML(aXML: TXmlSaver);

    procedure LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TXmlNameTable);
    procedure SaveBinXml(aWriter: TBinXmlWriter);

    procedure Insert(aNode: TXmlNode; anIndex: Integer);
    function Remove(aNode: TXmlNode): Integer;
    procedure Delete(anIndex: Integer);
    procedure Replace(anIndex: Integer; aNode: TXmlNode);
    procedure Exchange(Index1, Index2: Integer);
    procedure Clear;
  end;

  PXmlAttrData = ^TXmlAttrData;
  TXmlAttrData = record
    NameID: NativeInt;
    Value: Variant;
  end;

  TXmlDocument = class;
  TXmlNode = class(TXmlBase, IXmlNode)
  private
    FParentNode: TXmlNode;
    // FNames - таблица имен. Задается извне
    FNames: TXmlNameTable;
    // Количество атрибутов в массиве FAttrs
    FAttrCount: Integer;
    // Массив атрибутов
    FAttrs: array of TXmlAttrData;
    // Список дочерних узлов
    FChilds: TXmlNodeList;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
    function GetChilds: TXmlNodeList; virtual;
    function FindFirstChild(aNameID: NativeInt): TXmlNode;
    function GetAttrsXML: TXmlString;
    function FindAttrData(aNameID: NativeInt): PXmlAttrData;
    function GetOwnerDocument: TXmlDocument;
    function GetXMLIntend: Integer;
    procedure SetNameTable(aValue: TXmlNameTable);
    procedure SetNodeNameID(aValue: Integer); virtual;
    function DoCloneNode(aDeep: Boolean): IXmlNode; virtual; abstract;

  protected
    // IXmlNode
    function Get_NameTable: IXmlNameTable;
    function Get_NodeName: TXmlString;

    function Get_NodeNameID: NativeInt; virtual; abstract;
    function Get_NodeType: TXmlNodeType;  
    function Get_Text: TXmlString; virtual; abstract;
    procedure Set_Text(const aValue: TXmlString); virtual; abstract;
    function CloneNode(aDeep: Boolean): IXmlNode;

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
    procedure SaveXML(aXMLSaver: TXmlSaver); virtual; abstract;

    function Get_DataType: Integer; virtual;
    function Get_TypedValue: Variant; virtual;
    procedure Set_TypedValue(const aValue: Variant); virtual;

    function Get_XML: TXmlString; virtual; abstract;

    function Get_OwnerDocument: IXmlDocument; virtual;
    function Get_ParentNode: IXmlNode;

    function Get_ChildNodes: IXmlNodeList; virtual;
    procedure AppendChild(const aChild: IXmlNode);

    function AppendElement(aNameID: NativeInt): IXmlElement; overload;
    function AppendElement(const aName: TxmlString): IXmlElement; overload;
    function AppendText(const aData: TXmlString): IXmlText;
    function AppendCDATA(const aData: TXmlString): IXmlCDATASection;
    function AppendComment(const aData: TXmlString): IXmlComment;
    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString): IXmlProcessingInstruction; overload;

    procedure InsertBefore(const aChild, aBefore: IXmlNode);
    procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
    procedure ExchangeChilds(const aChild1, aChild2: IXmlNode);
    procedure RemoveChild(const aChild: IXmlNode);
    function GetChildText(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetChildText(const aName, aValue: TXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TXmlString); overload;

    function NeedChild(aNameID: NativeInt): IXmlNode; overload;
    function NeedChild(const aName: TXmlString): IXmlNode; overload;
    function EnsureChild(aNameID: NativeInt): IXmlNode; overload;
    function EnsureChild(const aName: TXmlString): IXmlNode; overload;

    procedure RemoveAllChilds;

    function SelectNodes(const anExpression: TXmlString): IXmlNodeList;
    function SelectSingleNode(const anExpression: TXmlString): IXmlNode;
    function FullPath: TXmlString;
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;

    function Get_AttrCount: Integer;
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    function Get_AttrName(anIndex: Integer): TXmlString;
    procedure RemoveAttr(const aName: TXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    procedure RemoveAllAttrs;

    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TXmlString): Boolean; overload;

    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TXmlString): Integer; overload;

    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TXmlString; aValue: Variant); overload;

    function NeedAttr(aNameID: NativeInt): TXmlString; overload;
    function NeedAttr(const aName: TXmlString): TXmlString; overload;

    function GetAttr(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetAttr(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetAttr(aNameID: NativeInt; const aValue: TXmlString); overload;
    procedure SetAttr(const aName, aValue: TXmlString); overload;

    function GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes = nil): TBytes; overload;
    function GetBytesAttr(const aName: TXmlString; const aDefault: TBytes = nil): TBytes; overload;

    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TXmlString; aValue: Boolean); overload;

    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TXmlString; aValue: Integer); overload;

    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TXmlString; aValue: TDateTime); overload;

    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TXmlString; aValue: Double); overload;

    function GetHexAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    procedure SetHexAttr(const aName: TXmlString; aValue: Integer; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Integer; aDigits: Integer = 8); overload;

    function GetEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function NeedEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString): Integer; overload;


    function Get_Values(const aName: String): Variant;
    procedure Set_Values(const aName: String; const aValue: Variant);

    function AsElement: IXmlElement; virtual;
    function AsText: IXmlText; virtual;
    function AsCDATASection: IXmlCDATASection; virtual;
    function AsComment: IXmlComment; virtual;
    function AsProcessingInstruction: IXmlProcessingInstruction; virtual;

  public
    constructor Create(aNames: TXmlNameTable);
    destructor Destroy; override;
  end;

  TXmlElement = class(TXmlNode, IXmlElement)
  private
    FNameID: NativeInt;
    FData: Variant;
    procedure RemoveTextNodes;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function GetChilds: TXmlNodeList; override;

    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TXmlString; override;
    procedure Set_Text(const aValue: TXmlString); override;
    function Get_DataType: Integer; override;
    function Get_TypedValue: Variant; override;
    procedure Set_TypedValue(const aValue: Variant); override;
    function Get_XML: TXmlString; override;
    function AsElement: IXmlElement; override;
    function Get_ChildNodes: IXmlNodeList; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;

    // IXmlElement
    procedure ReplaceTextByCDATASection(const aText: TXmlString);
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
                                      aMaxLineLength: Integer);
    function GetTextAsBinaryData: TBytes;
  public
    constructor Create(aNames: TXmlNameTable; aNameID: NativeInt);
  end;

  TXmlCharacterData = class(TXmlNode, IXmlCharacterData)
  private
    FData: TXmlString;
  protected
    function Get_Text: TXmlString; override;
    procedure Set_Text(const aValue: TXmlString); override;
  public
    constructor Create(aNames: TXmlNameTable; const aData: TXmlString);
  end;

  TXmlText = class(TXmlNode, IXmlText)
  private
    FData: Variant;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TXmlString; override;
    procedure Set_Text(const aValue: TXmlString); override;
    function Get_DataType: Integer; override;
    function Get_TypedValue: Variant; override;
    procedure Set_TypedValue(const aValue: Variant); override;
    function Get_XML: TXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsText: IXmlText; override;
  public
    constructor Create(aNames: TXmlNameTable; const aData: Variant);
  end;

  TXmlCDATASection = class(TXmlCharacterData, IXmlCDATASection)
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_XML: TXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsCDATASection: IXmlCDATASection; override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  public
  end;

  TXmlComment = class(TXmlCharacterData, IXmlComment)
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_XML: TXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsComment: IXmlComment; override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  public
  end;

  TXmlProcessingInstruction = class(TXmlNode, IXmlProcessingInstruction)
  private
    FTargetNameID: NativeInt;
    FData: TXmlString;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TXmlString; override;
    procedure Set_Text(const aText: TXmlString); override;
    function Get_XML: TXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsProcessingInstruction: IXmlProcessingInstruction; override;
  public
    constructor Create(aNames: TXmlNameTable; aTargetID: NativeInt;
      const aData: TXmlString);
  end;

  TXmlDocument = class(TXmlNode, IXmlDocument)
  private
    FPreserveWhiteSpace: Boolean;
    FOnTagEnd: THookTag;
    FOnTagBegin: THookTag;

    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TXmlString; override;
    procedure Set_Text(const aText: TXmlString); override;
    function Get_XML: TXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);
    function Get_OnTagEnd: THookTag;
    procedure Set_OnTagEnd(aValue: THookTag);
    function Get_OnTagBegin: THookTag;
    procedure Set_OnTagBegin(aValue: THookTag);

    function NewDocument(const aVersion, anEncoding: TXmlString;
      aRootElementNameID: NativeInt): IXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TXmlString): IXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IXmlElement; overload;
    function CreateElement(const aName: TXmlString): IXmlElement; overload;
    function CreateText(const aData: TXmlString): IXmlText;
    function CreateCDATASection(const aData: TXmlString): IXmlCDATASection;
    function CreateComment(const aData: TXmlString): IXmlComment;
    function Get_DocumentElement: IXmlElement;
    function CreateProcessingInstruction(const aTarget,
      aData: TXmlString): IXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    procedure LoadXML(const aXML: RawByteString); overload;
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    procedure LoadXML(const aXML: TXmlString); overload;
    {$IFEND}

    procedure Load(aStream: TStream); overload;
    procedure Load(const aFileName: String); overload;

    procedure LoadResource(aType, aName: PChar);
     
    procedure Save(aStream: TStream); overload;
    procedure Save(const aFileName: String); overload;

    procedure SaveBinary(aStream: TStream; anOptions: LongWord); overload;
    procedure SaveBinary(const aFileName: String; anOptions: LongWord); overload;

    function Get_BinaryXML: RawByteString;
    procedure LoadBinaryXML(const aXML: RawByteString);
  public
    constructor Create(aNames: TXmlNameTable=nil);
  end;

const
  NodeClasses: array [TXmlNodeType] of TClass=
    (TObject, TXmlElement, TXmlText, TXmlCDATASection, 
     TXmlProcessingInstruction, TXmlComment, TXmlDocument);
  
{ TXmlNodeList }

procedure TXmlNodeList.Clear;
var
  i: Integer;
  aNode: TXmlNode;
begin
  for i := 0 to FCount - 1 do begin
    aNode := FItems[i];
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
  FCount := 0;
end;

procedure TXmlNodeList.Delete(anIndex: Integer);
var
  aNode: TXmlNode;
begin
  aNode := FItems[anIndex];
  Dec(FCount);
  if anIndex < FCount then
    Move(FItems[anIndex + 1], FItems[anIndex],
      (FCount - anIndex)*SizeOf(TXmlNode));
  if Assigned(aNode) then begin
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
end;

constructor TXmlNodeList.Create(anOwnerNode: TXmlNode);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  FOwnerNode := anOwnerNode;
end;

destructor TXmlNodeList.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  Clear;
  inherited;
end;

procedure TXmlNodeList.Exchange(Index1, Index2: Integer);
var
  Temp: TXmlNode;
begin
  if (Index1>=0) and (Index2>=0)
  then begin
    Temp := FItems[Index1];
    FItems[Index1] := FItems[Index2];
    FItems[Index2] := Temp;
  end;
end;

function TXmlNodeList.Get_Item(anIndex: Integer): IXmlNode;
begin
  if (anIndex < 0) or (anIndex >= FCount) then
    raise Exception.CreateFmt(SSimpleXmlError1, [anIndex]);
  Result := FItems[anIndex]
end;

function TXmlNodeList.Get_Count: Integer;
begin
  Result := FCount
end;

function TXmlNodeList.IndexOf(aNode: TXmlNode): Integer;
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    if FItems[i] = aNode then begin
      Result := i;
      Exit
    end;
  Result := -1;
end;

procedure TXmlNodeList.Grow;
var
  aDelta: Integer;
begin
  if Length(FItems) > 64 then
    aDelta := Length(FItems) div 4
  else
    if Length(FItems) > 8 then
      aDelta := 16
    else
      aDelta := 4;
  SetLength(FItems, Length(FItems) + aDelta);
end;

procedure TXmlNodeList.Insert(aNode: TXmlNode; anIndex: Integer);
begin
  if aNode <> nil
  then begin
    if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
       ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
    then begin
      aNode := aNode.DoCloneNode(True).GetObject as TXmlNode;
      if FOwnerNode<>nil
      then
        aNode.SetNameTable(FOwnerNode.FNames);
    end;
    aNode._AddRef;
    aNode.FParentNode := FOwnerNode;
  end;
  if anIndex = -1 then
    anIndex := FCount;
  if FCount = Length(FItems) then
    Grow;
  if anIndex < FCount then
    Move(FItems[anIndex], FItems[anIndex + 1],
         (FCount - anIndex)*SizeOf(TXmlNode));
  FItems[anIndex] := aNode;
  Inc(FCount);
end;

function TXmlNodeList.Remove(aNode: TXmlNode): Integer;
begin
  Result := IndexOf(aNode);
  if Result <> -1 then
    Delete(Result);
end;

procedure TXmlNodeList.Replace(anIndex: Integer; aNode: TXmlNode);
var
  anOldNode: TXmlNode;
begin
  anOldNode := FItems[anIndex];
  if aNode <> anOldNode
  then begin
    if Assigned(anOldNode)
    then begin
      if Assigned(FOwnerNode)
      then
        anOldNode.FParentNode := nil;
      anOldNode._Release;
    end;
    FItems[anIndex] := aNode;
    if (aNode<>nil)
    then begin
      if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
         ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
      then begin
        aNode := aNode.DoCloneNode(True).GetObject as TXmlNode;
        aNode.FParentNode := FOwnerNode;
        aNode.SetNameTable(FOwnerNode.FNames);
      end
      else
        aNode._AddRef;
    end;
  end;
end;

function TXmlNodeList.Get_XML: TXmlString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FCount - 1 do
    Result := Result + FItems[i].Get_XML;
end;

procedure TXmlNodeList.ParseXML(aXML: TXmlSource; aNames: TXmlNameTable; aPreserveWhiteSpace: Boolean; HookTagEnd: THookTag; HookTagBegin: THookTag);

  // на входе: символ текста
  // на выходе: символ разметки '<'
  procedure ParseText;
  var
    aText: TXmlString;
  begin
    aXml.NewToken;
    while not aXML.EOF and (aXML.CurChar <> '<') do
      if aXML.CurChar = '&' then
        aXml.AppendTokenChar(aXml.ExpectXmlEntity)
      else begin
        aXml.AppendTokenChar(aXML.CurChar);
        aXML.Next;
      end;
    if aPreserveWhiteSpace
    then
      aText := aXml.AcceptToken
    else
      aText := Trim(aXml.AcceptToken);
    if (aText<>'')
    then
      Insert(TXmlText.Create(aNames, aText), -1);
  end;

  // CurChar - '?'
  procedure ParseProcessingInstruction;
  var
    aTarget: TXmlString;
    aNode: TXmlProcessingInstruction;
    EncodingValue: TXmlString;
    NewCodepage: Word;
  begin
    aXML.Next;
    aTarget := aXML.ExpectXmlName;
    aNode := TXmlProcessingInstruction.Create(aNames, aNames.GetID(aTarget), '');
    Insert(aNode, -1);
    if aNode.FTargetNameID = aNames.FXmlNameID
    then begin
      aXml.ParseAttrs(aNode);
      aXml.ExpectText('?>');
      if aXML.AutoCodepage
      then begin
        EncodingValue := aNode.GetVarAttr(aNames.FEncodingNameId, '');
        if EncodingValue<>''
        then begin
          NewCodepage := FindCodepage(EncodingValue);
          if NewCodepage=0
          then
            raise Exception.CreateFmt(SSimpleXmlError26, [EncodingValue]);
          aXML.SetCodepage(NewCodepage);
        end
        else
          aXML.SetCodepage(CP_UTF8);
      end;
    end
    else
      aNode.FData := aXml.ParseTo('?>');
  end;

  // на входе: первый '--'
  // на выходе: символ после '-->'
  procedure ParseComment;
  begin
    aXml.ExpectText('--');
    Insert(TXmlComment.Create(aNames, aXml.ParseTo('-->')), -1);
  end;

  // на входе: '[CDATA['
  // на выходе: символ после ']]>'
  procedure ParseCDATA;
  begin
    aXml.ExpectText('[CDATA[');
    Insert(TXmlCDATASection.Create(aNames, aXml.ParseTo(']]>')), -1);
  end;

  // на входе: 'DOCTYPE'
  // на выходе: символ после '>'
  procedure ParseDOCTYPE;
  begin
    aXml.ExpectText('DOCTYPE');
    aXml.ParseTo('>');
  end;

  // на входе: 'имя-элемента'
  // на выходе: символ после '>'
  procedure ParseElement;
  var
    aNameID: NativeInt;
    aNode: TXmlElement;
  begin
    aNameID := aNames.GetID(aXml.ExpectXmlName);
    if aXml.EOF then
      raise Exception.Create(SSimpleXMLError2);
    if not ((aXml.CurChar <= ' ') or (aXml.CurChar = '/') or (aXml.CurChar = '>')) then
      raise Exception.Create(SSimpleXMLError3);
    aNode := TXmlElement.Create(aNames, aNameID);
    Insert(aNode, -1);
    aXml.ParseAttrs(aNode);
    if assigned(HookTagBegin) then
      HookTagBegin(Self, aNode);
    if aXml.CurChar = '/' then
      aXml.ExpectText('/>')
    else begin
      aXml.ExpectChar('>');
      aNode.GetChilds.ParseXML(aXml, aNames, aPreserveWhiteSpace, HookTagEnd, HooktagBegin);
      aXml.ExpectChar('/');
      aXml.ExpectText(PXmlChar(aNames.GetName(aNameID)));
      aXml.SkipBlanks;
      aXml.ExpectChar('>');
    end;
    if assigned(HookTagEnd) then
      HookTagEnd(Self, aNode);
  end;

begin
  while not aXML.EOF do
  begin
    ParseText;
    if aXML.CurChar = '<'
    then begin// символ разметки
      if aXML.Next
      then begin
        if aXML.CurChar = '/'
        then // закрывающий тэг элемента
          Exit
        else
        if aXML.CurChar = '?'
        then begin// инструкция
          ParseProcessingInstruction;
        end
        else 
        if aXML.CurChar = '!' 
        then begin
          if aXML.Next 
          then begin
            if aXML.CurChar = '-' 
            then // коментарий
              ParseComment
            else 
            if aXML.CurChar = '[' 
            then // секция CDATA
              ParseCDATA
            else
              ParseDOCTYPE;
          end;
        end
        else // открывающий тэг элемента
          ParseElement;
      end;
    end;
  end;
end;

procedure TXmlNodeList.LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TXmlNameTable);
var
  i: Integer;
  aNodeType: TXmlNodeType;
  aNode: TXmlNode;
  aNameID: LongInt;
begin
  Clear;
  SetLength(FItems, aCount);
  for i := 0 to aCount - 1 do begin
    aReader.Read(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TXmlElement.Create(aNames, aNameID);
          Insert(aNode, -1);
          aReader.ReadVariant(TVarData(TXmlElement(aNode).FData));
          aNode.LoadBinXml(aReader);
        end;
      NODE_TEXT:
        begin
          aNode := TXmlText.Create(aNames, Unassigned);
          Insert(aNode, -1);
          aReader.ReadVariant(TVarData(TXmlText(aNode).FData));
        end;
      NODE_CDATA_SECTION:
        Insert(TXmlCDATASection.Create(aNames, aReader.ReadXmlString), -1);
      NODE_PROCESSING_INSTRUCTION:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TXmlProcessingInstruction.Create(aNames, aNameID,
            aReader.ReadXmlString);
          Insert(aNode, -1);
          aNode.LoadBinXml(aReader);
        end;
      NODE_COMMENT:
        Insert(TXmlComment.Create(aNames, aReader.ReadXmlString), -1);
      else
        raise Exception.Create(SSimpleXMLError4);
    end
  end;
end;

procedure TXmlNodeList.SaveBinXml(aWriter: TBinXmlWriter);
const
  EmptyVar: TVarData = (VType:varEmpty);
var
  aCount: LongInt;
  i: Integer;
  aNodeType: TXmlNodeType;
  aNode: TXmlNode;
begin
  aCount := FCount;
  for i := 0 to aCount - 1 do begin
    aNode := FItems[i];
    aNodeType := aNode.Get_NodeType;
    aWriter.Write(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        with TXmlElement(aNode) do begin
          aWriter.WriteLongint(FNames.GetKeyID(FNameID));
          if Assigned(FChilds) and (FChilds.FCount > 0) or VarIsEmpty(FData) then
            aWriter.WriteVariant(EmptyVar)
          else
            aWriter.WriteVariant(TVarData(FData));
          SaveBinXml(aWriter);
        end;
      NODE_TEXT:
        aWriter.WriteVariant(TVarData(TXmlText(aNode).FData));
      NODE_CDATA_SECTION:
        aWriter.WriteXmlString(TXmlCDATASection(aNode).FData);
      NODE_PROCESSING_INSTRUCTION:
        begin
          with TXmlProcessingInstruction(aNode) do
          begin
            aWriter.WriteLongint(FNames.GetKeyID(FTargetNameID));
            aWriter.WriteXmlString(FData);
          end;
          aNode.SaveBinXml(aWriter);
        end;
      NODE_COMMENT:
        aWriter.WriteXmlString(TXmlComment(aNode).FData);
      else
        raise Exception.Create(SSimpleXmlError5);
    end
  end;
end;

procedure TXmlNodeList.SaveXML(aXML: TXmlSaver);
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    FItems[i].SaveXML(aXML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Node Implementation'}{$ENDIF}
{ TXmlNode }

constructor TXmlNode.Create(aNames: TXmlNameTable);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if aNames<>nil
  then
    FNames := aNames
  else
    FNames := TXmlNameTable.Create(DefaultHashSize);
  FNames._AddRef;
end;

destructor TXmlNode.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if Assigned(FChilds) then
    FChilds._Release;
  FNames._Release;
  inherited;
end;

function TXmlNode.GetChilds: TXmlNodeList;
begin
  if not Assigned(FChilds) then begin
    FChilds := TXmlNodeList.Create(Self);
    FChilds._AddRef;
  end;
  Result := FChilds;
end;

procedure TXmlNode.AppendChild(const aChild: IXmlNode);
begin
  GetChilds.Insert(aChild.GetObject as TXmlNode, -1);
end;

function TXmlNode.Get_AttrCount: Integer;
begin
  Result := FAttrCount;
end;

function TXmlNode.Get_AttrName(anIndex: Integer): TXmlString;
begin
  Result := FNames.GetName(FAttrs[anIndex].NameID);
end;

function TXmlNode.Get_AttrNameID(anIndex: Integer): NativeInt;
begin
  Result := FAttrs[anIndex].NameID;
end;

function TXmlNode.Get_ChildNodes: IXmlNodeList;
begin
  Result := GetChilds
end;

function TXmlNode.Get_NameTable: IXmlNameTable;
begin
  Result := FNames
end;

function TXmlNode.GetAttr(const aName, aDefault: TXmlString): TXmlString;
begin
  Result := GetAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetAttr(aNameID: NativeInt; const aDefault: TXmlString): TXmlString;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := aData.Value
  else
    Result := aDefault
end;

function TXmlNode.GetBoolAttr(aNameID: NativeInt; aDefault: Boolean): Boolean;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := aData.Value
  else
    Result := aDefault
end;

function TXmlNode.GetBoolAttr(const aName: TXmlString; aDefault: Boolean): Boolean;
begin
  Result := GetBoolAttr(FNames.GetID(aName), aDefault)
end;

procedure CopyWordToByteArray(s: PWord; d: PByte; Size: Integer);
begin
  while Size>0 do
  begin
    d^ := PByte(s)^;
    inc(s); inc(d); dec(Size);
  end;
end;

function TXmlNode.GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes): TBytes;
var
  aData: PXmlAttrData;
  temp: TXmlString;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData)
  then begin
    temp := aData.Value;
    SetLength(Result, Length(temp));
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    CopyWordToByteArray(Pointer(temp), Pointer(Result), Length(Result));
    {$ELSE}
    move(Pointer(temp)^, Pointer(Result)^, Length(Result));
    {$IFEND}
  end
  else
    Result := aDefault
end;

function TXmlNode.GetBytesAttr(const aName: TXmlString; const aDefault: TBytes): TBytes;
begin
  Result := GetBytesAttr(FNames.GetID(aName), aDefault);
end;

function TXmlNode.FindFirstChild(aNameID: NativeInt): TXmlNode;
var
  i: Integer;
begin
  if Assigned(FChilds) then
    for i := 0 to FChilds.FCount - 1 do begin
      Result := FChilds.FItems[i];
      if Result.Get_NodeNameID = aNameID then
        Exit
    end;
  Result := nil
end;

function TXmlNode.FullPath: TXmlString;
var
  aParent: TXmlNode;
begin
  aParent := FParentNode;
  if (aParent<>nil)
  then begin
    Result := Get_NodeName;
    while (aParent<>nil) and (aParent.ClassType<>TXmlDocument) do
    begin
      Result := aParent.Get_NodeName + XMLPathDelimiter + Result;
      aParent := aParent.FParentNode;
    end;
  end;
end;

function TXmlNode.GetChildText(aNameID: NativeInt;
                               const aDefault: TXmlString): TXmlString;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild.Get_Text
  else
    Result := aDefault
end;

function TXmlNode.GetChildText(const aName: TXmlString;
                               const aDefault: TXmlString): TXmlString;
begin
  Result := GetChildText(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetEnumAttr(const aName: TXmlString;
                              const aValues: array of TXmlString;
                              aDefault: Integer): Integer;
begin
  Result := GetEnumAttr(FNames.GetID(aName), aValues, aDefault);
end;

function EnumAttrValue(aNode: TXmlNode; anAttrData: PXmlAttrData;
                       const aValues: array of TXmlString): Integer;
var
  anAttrValue: TXmlString;
  s: TXmlString;
  i: Integer;
begin
  anAttrValue := anAttrData.Value;
  for Result := 0 to Length(aValues) - 1 do
    if AnsiCompareText(anAttrValue, aValues[Result]) = 0 then
      Exit;
  if Length(aValues) = 0 then
    s := ''
  else begin
    s := aValues[0];
    for i := 1 to Length(aValues) - 1 do
      s := s + #13#10 + aValues[i];
  end;
  raise Exception.CreateFmt(SSimpleXmlError6,
    [aNode.FNames.GetName(anAttrData.NameID), aNode.Get_NodeName, s]);
end;

function TXmlNode.GetEnumAttr(aNameID: NativeInt;
                              const aValues: array of TXmlString; 
                              aDefault: Integer): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    Result := aDefault;
end;

function TXmlNode.NeedEnumAttr(const aName: TXmlString;
                               const aValues: array of TXmlString): Integer;
begin
  Result := NeedEnumAttr(FNames.GetID(aName), aValues)
end;

function TXmlNode.NeedEnumAttr(aNameID: NativeInt;
                               const aValues: array of TXmlString): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    raise Exception.CreateFmt(SSimpleXMLError7, [FNames.GetName(aNameID)]);
end;

function TXmlNode.GetFloatAttr(const aName: TXmlString; aDefault: Double): Double;
begin
  Result := GetFloatAttr(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetFloatAttr(aNameID: NativeInt; aDefault: Double): Double;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    if VarIsNumeric(aData.Value) then
      Result := aData.Value
    else
      Result := XSTRToFloat(aData.Value)
  else
    Result := aDefault
end;

function TXmlNode.GetHexAttr(aNameID: NativeInt; aDefault: Integer): Integer;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := StrToInt('$' + anAttr.Value)
  else
    Result := aDefault;
end;

function TXmlNode.GetHexAttr(const aName: TXmlString; aDefault: Integer): Integer;
begin
  Result := GetHexAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetIntAttr(aNameID: NativeInt; aDefault: Integer): Integer;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := anAttr.Value
  else
    Result := aDefault;
end;

function TXmlNode.GetIntAttr(const aName: TXmlString; aDefault: Integer): Integer;
begin
  Result := GetIntAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.NeedAttr(aNameID: NativeInt): TXmlString;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then
    raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);
  Result := anAttr.Value
end;

function TXmlNode.NeedAttr(const aName: TXmlString): TXmlString;
begin
  Result := NeedAttr(FNames.GetID(aName))
end;

function TXmlNode.GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := anAttr.Value
  else
    Result := aDefault;
end;

function TXmlNode.GetVarAttr(const aName: TXmlString; 
                             const aDefault: Variant): Variant;
begin
  Result := GetVarAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetXMLIntend: Integer;
var
  aParentNode: TXmlNode;
begin
  Result := 0;
  aParentNode := FParentNode;
  while (aParentNode<>nil) and not (aParentNode is TXmlDocument) do
  begin
    aParentNode := aParentNode.FParentNode;
    inc(Result);
  end;
end;

function TXmlNode.Get_NodeName: TXmlString;
begin
  Result := FNames.GetName(Get_NodeNameID);
end;

function TXmlNode.Get_NodeType: TXmlNodeType;
begin
  Result := High(TXmlNodeType);
  while (Result>Low(TXmlNodeType)) and (NodeClasses[Result]<>ClassType) do
    dec(Result);
end;

function TXmlNode.GetOwnerDocument: TXmlDocument;
var
  aResult: TXmlNode;
begin
  aResult := Self;
  while (aResult<>nil) and not (aResult is TXmlDocument) do
    aResult := aResult.FParentNode;
  Result := TXmlDocument(aResult);
end;

function TXmlNode.Get_OwnerDocument: IXmlDocument;
var
  aDoc: TXmlDocument;
begin
  aDoc := GetOwnerDocument;
  if Assigned(aDoc) then
    Result := aDoc
  else
    Result := nil;
end;

function TXmlNode.Get_ParentNode: IXmlNode;
begin
  Result := FParentNode
end;

function TXmlNode.Get_TypedValue: Variant;
begin
  Result := Get_Text
end;

procedure TXmlNode.InsertBefore(const aChild, aBefore: IXmlNode);
var
  i: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  if Assigned(aBefore) then
    i := aChilds.IndexOf(aBefore.GetObject as TXmlNode)
  else
    i := aChilds.FCount;
  GetChilds.Insert(aChild.GetObject as TXmlNode, i)
end;

procedure TXmlNode.RemoveAllAttrs;
begin
  FAttrCount := 0; 
end;

procedure TXmlNode.RemoveAllChilds;
begin
  if Assigned(FChilds) then
    FChilds.Clear
end;

procedure TXmlNode.RemoveAttr(const aName: TXmlString);
begin
  RemoveAttr(FNames.GetID(aName));
end;

procedure TXmlNode.RemoveAttr(aNameID: NativeInt);
var
  a1, a2: PXmlAttrData;
  i: Integer;
begin
  a1 := @FAttrs[0];
  i := 0;
  while (i < FAttrCount) and (a1.NameID <> aNameID) do begin
    Inc(a1);
    Inc(i)
  end;
  if i < FAttrCount then begin
    a2 := a1;
    Inc(a2);
    while i < FAttrCount - 1 do begin
      a1^ := a2^;
      Inc(a1);
      Inc(a2);
      Inc(i)
    end;
    VarClear(a1.Value);
    Dec(FAttrCount);
  end;
end;

procedure TXmlNode.RemoveChild(const aChild: IXmlNode);
begin
  GetChilds.Remove(aChild.GetObject as TXmlNode)
end;

procedure TXmlNode.ReplaceChild(const aNewChild, anOldChild: IXmlNode);
var
  i: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  i := aChilds.IndexOf(anOldChild.GetObject as TXmlNode);
  if i <> -1 then
    aChilds.Replace(i, aNewChild.GetObject as TXmlNode)
end;

function NameCanBeginWith(aChar: TXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or IsCharAlphaW(aChar)
  {$ELSE}
  Result := (aChar = '_') or IsCharAlpha(aChar)
  {$ENDIF}
end;

function NameCanContain(aChar: TXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or (aChar = '-') or (aChar = ':') or (aChar = '.') or
    IsCharAlphaNumericW(aChar)
  {$ELSE}
    {$IFDEF Unicode}
    Result := CharInSet(aChar, ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ELSE}
    Result := (aChar in ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ENDIF}
  {$ENDIF}
end;

function IsName(const s: TXmlString): Boolean;
var
  i: Integer;
begin
  if s = '' then
    Result := False
  else if not NameCanBeginWith(s[1]) then
    Result := False
  else begin
    for i := 2 to Length(s) do
      if not NameCanContain(s[i]) then begin
        Result := False;
        Exit
      end;
    Result := True;
  end;
end;

const
  ntComment = -2;
  ntNode = -3;
  ntProcessingInstruction = -4;
  ntText = -5;
    
type
  TAxis = (axAncestor, axAncestorOrSelf, axAttribute, axChild,
    axDescendant, axDescendantOrSelf, axFollowing, axFollowingSibling,
    axParent, axPreceding, axPrecedingSibling, axSelf);

  TPredicate = class
    function Check(aNode: TXmlNode): Boolean; virtual; abstract;
  end;

  TLocationStep = class
    Next: TLocationStep;
    Axis: TAxis;
    NodeTest: Integer;
    Predicates: TList;
  end;
  


function TXmlNode.SelectNodes(const anExpression: TXmlString): IXmlNodeList;
var
  aNodes: TXmlNodeList;
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  iChild: IXmlNode;
  aNameID: NativeInt;
  i, p: Integer;
begin
  if IsName(anExpression) 
  then begin
    aNodes := TXmlNodeList.Create(Self);
    Result := aNodes;
    aChilds := GetChilds;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) then
        aNodes.Insert(aChild, aNodes.FCount);
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      iChild := SelectSingleNode(copy(anExpression, 1, p-1));
      if iChild<>nil
      then
        Result := iChild.SelectNodes(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end;
end;

function TXmlNode.SelectSingleNode(const anExpression: TXmlString): IXmlNode;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aNameID: NativeInt;
  i, p: Integer;
begin
  Result := nil;
  if IsName(anExpression) 
  then begin
    aChilds := GetChilds;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do 
    begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) 
      then begin
        Result := aChild;
        Exit;
      end
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      Result := SelectSingleNode(copy(anExpression, 1, p-1));
      if Result<>nil 
      then
        Result := Result.SelectSingleNode(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end
end;

function TXmlNode.FindElement(const anElementName, anAttrName: String;
                              const anAttrValue: Variant): IXmlElement;
var
  aChild: TXmlNode;
  aNameID, anAttrNameID: NativeInt;
  i: Integer;
  pa: PXmlAttrData;
begin
  if Assigned(FChilds) then begin
    aNameID := FNames.GetID(anElementName);
    anAttrNameID := FNames.GetID(anAttrName);

    for i := 0 to FChilds.FCount - 1 do begin
      aChild := FChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) then begin
        pa := aChild.FindAttrData(anAttrNameID);
        try
          if Assigned(pa) and VarSameValue(pa.Value, anAttrValue) then begin
            Result := aChild.AsElement;
            Exit
          end
        except
          // Исключительная ситуация может возникнуть в том случае,
          // если произойдет сбой в функции VarSameValue.
          // Иными словами - если значения нельзя сравнивать.
        end;
      end
    end;
  end;
  Result := nil;
end;

procedure TXmlNode.Set_TypedValue(const aValue: Variant);
begin
  Set_Text(aValue)
end;

procedure TXmlNode.SetAttr(const aName, aValue: TXmlString);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetAttr(aNameID: NativeInt; const aValue: TXmlString);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetBoolAttr(aNameID: NativeInt; aValue: Boolean);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetBoolAttr(const aName: TXmlString; aValue: Boolean);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(const aName: TXmlString;
                                const aValue: TXmlString);
begin
  SetChildText(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(aNameID: NativeInt; const aValue: TXmlString);
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then begin
    aChild := TXmlElement.Create(FNames, aNameID);
    with GetChilds do
      Insert(aChild, FCount);
  end;
  aChild.Set_Text(aValue)
end;

procedure TXmlNode.SetFloatAttr(aNameID: NativeInt; aValue: Double);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetFloatAttr(const aName: TXmlString; aValue: Double);
begin
  SetVarAttr(FNames.GetID(aName), aValue);
end;

procedure TXmlNode.SetHexAttr(const aName: TXmlString; 
                              aValue, aDigits: Integer);
begin
  SetVarAttr(FNames.GetID(aName), IntToHex(aValue, aDigits))
end;

procedure TXmlNode.SetHexAttr(aNameID: NativeInt; aValue, aDigits: Integer);
begin
  SetVarAttr(aNameID, IntToHex(aValue, aDigits))
end;

procedure TXmlNode.SetIntAttr(aNameID: NativeInt; aValue: Integer);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetIntAttr(const aName: TXmlString; aValue: Integer);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(const aName: TXmlString; aValue: Variant);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(aNameID: NativeInt; const aValue: Variant);
var
  anAttr: PXmlAttrData;
var
  aDelta: Integer;
begin
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then begin
    if FAttrCount = Length(FAttrs) then begin
      if FAttrCount > 64 then
        aDelta := FAttrCount div 4
      else if FAttrCount > 8 then
        aDelta := 16
      else
        aDelta := 4;
      SetLength(FAttrs, FAttrCount + aDelta);
    end;
    anAttr := @FAttrs[FAttrCount];
    anAttr.NameID := aNameID;
    Inc(FAttrCount);
  end;
  anAttr.Value := aValue
end;

function TXmlNode.FindAttrData(aNameID: NativeInt): PXmlAttrData;
var
  i: Integer;
begin
  if Length(FAttrs)>0
  then begin
    Result := @FAttrs[0];
    for i := 0 to FAttrCount - 1 do
      if Result.NameID = aNameID then
        Exit
      else
        Inc(Result);
  end;
  Result := nil;
end;

function TXmlNode.AsElement: IXmlElement;
begin
  Result := nil
end;

function TXmlNode.AsCDATASection: IXmlCDATASection;
begin
  Result := nil
end;

function TXmlNode.AsComment: IXmlComment;
begin
  Result := nil
end;

function TXmlNode.AsText: IXmlText;
begin
  Result := nil
end;

function TXmlNode.AsProcessingInstruction: IXmlProcessingInstruction;
begin
  Result := nil
end;

function TXmlNode.AppendCDATA(const aData: TXmlString): IXmlCDATASection;
var
  aChild: TXmlCDATASection;
begin
  aChild := TXmlCDATASection.Create(FNames, aData);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendComment(const aData: TXmlString): IXmlComment;
var
  aChild: TXmlComment;
begin
  aChild := TXmlComment.Create(FNames, aData);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendElement(const aName: TxmlString): IXmlElement;
var
  aChild: TXmlElement;
begin
  aChild := TXmlElement.Create(FNames, FNames.GetID(aName));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendElement(aNameID: NativeInt): IXmlElement;
var
  aChild: TXmlElement;
begin
  aChild := TXmlElement.Create(FNames, aNameID);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(const aTarget,
  aData: TXmlString): IXmlProcessingInstruction;
var
  aChild: TXmlProcessingInstruction;
begin
  aChild := TXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(aTargetID: NativeInt;
  const aData: TXmlString): IXmlProcessingInstruction;
var
  aChild: TXmlProcessingInstruction;
begin
  aChild := TXmlProcessingInstruction.Create(FNames, aTargetID, aData);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendText(const aData: TXmlString): IXmlText;
var
  aChild: TXmlText;
begin
  aChild := TXmlText.Create(FNames, aData);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.GetAttrsXML: TXmlString;
var
  a: PXmlAttrData;
  i: Integer;
begin
  Result := '';
  if FAttrCount > 0 then begin
    a := @FAttrs[0];
    for i := 0 to FAttrCount - 1 do begin
      Result := Result + ' ' + FNames.GetName(a.NameID) + '="' + TextToXML(VarToXSTR(TVarData(a.Value))) + '"';
      Inc(a);
    end;
  end;
end;

procedure TXmlNode.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты //Load attributes
  RemoveAllAttrs;
  aCount := aReader.ReadLongint;
  SetLength(FAttrs, aCount);
  FAttrCount := aCount;
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    a.NameID := FNames.GetNameID(aReader.ReadLongint);
    aReader.ReadVariant(TVarData(a.Value));
    Inc(a);
  end;

  // Считать дочерние узлы //Load childs
  aCount := aReader.ReadLongint;
  if aCount > 0 then
    GetChilds.LoadBinXml(aReader, aCount, FNames);
end;

procedure TXmlNode.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты  //Save attributes
  aCount := FAttrCount;
  aWriter.WriteLongint(aCount);
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    aWriter.WriteLongint(FNames.GetKeyID(a.NameID));
    aWriter.WriteVariant(TVarData(a.Value));
    Inc(a);
  end;

  // Записать дочерние узлы //Save Childs
  if Assigned(FChilds) then begin
    aWriter.WriteLongint(FChilds.FCount);
    FChilds.SaveBinXml(aWriter);
  end
  else
    aWriter.WriteLongint(0);
end;

function TXmlNode.Get_DataType: Integer;
begin
  {$IF Defined(Unicode)}
  Result := varUString;
  {$ELSEIF Defined(XML_WIDE_CHARS)}
  Result := varOleStr;
  {$ELSE}
  Result := varString;
  {$IFEND}
end;

function TXmlNode.AttrExists(aNameID: NativeInt): Boolean;
begin
  Result := FindAttrData(aNameID) <> nil
end;

function TXmlNode.AttrExists(const aName: TXmlString): Boolean;
begin
  Result := FindAttrData(FNames.GetID(aName)) <> nil
end;

function TXmlNode.GetAttrType(aNameID: NativeInt): Integer;
var
  a: PXmlAttrData;
begin
  a := FindAttrData(aNameID);
  if Assigned(a) then
    Result := TVarData(a.Value).VType
  else
    {$IF Defined(Unicode)}
    Result := varUString;
    {$ELSEIF Defined(XML_WIDE_CHARS)}
    Result := varOleStr;
    {$ELSE}
    Result := varString;
    {$IFEND}
end;

function TXmlNode.GetAttrType(const aName: TXmlString): Integer;
begin
  Result := GetAttrType(FNames.GetID(aName));
end;

function TXmlNode.Get_Values(const aName: String): Variant;
var
  aChild: IXmlNode;
begin
  if aName = '' then
    Result := Get_TypedValue
  else if aName[1] = '@' then
    Result := GetVarAttr(Copy(aName, 2, Length(aName) - 1), '')
  else begin
    aChild := SelectSingleNode(aName);
    if Assigned(aChild) then
      Result := aChild.TypedValue
    else
      Result := ''
  end
end;

procedure TXmlNode.Set_Values(const aName: String; const aValue: Variant);
var
  aChild: IXmlNode;
begin
  if aName = '' then
    Set_TypedValue(aValue)
  else if aName[1] = '@' then
    SetVarAttr(Copy(aName, 2, Length(aName) - 1), aValue)
  else begin
    aChild := SelectSingleNode(aName);
    if not Assigned(aChild) then
      aChild := AppendElement(aName);
    aChild.TypedValue := aValue;
  end
end;

function TXmlNode.GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime): TDateTime;
var
  anAttr: PXmlAttrData;
  aVarType: Word;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then begin
    aVarType := VarType(anAttr.Value);
    {$IFDEF Unicode}
    if (aVarType=varUString) or (aVarType=varString) or (aVarType=varOleStr) then
    {$ELSE}
    if (aVarType=varString) or (aVarType=varOleStr) then
    {$ENDIF}
      Result := XSTRToDateTime(anAttr.Value)
    else
      Result := VarAsType(anAttr.Value, varDate)
  end
  else
    Result := aDefault;
end;

function TXmlNode.GetDateTimeAttr(const aName: TXmlString;
  aDefault: TDateTime): TDateTime;
begin
  Result := GetDateTimeAttr(FNames.GetID(aName), aDefault)
end;

procedure TXmlNode.SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime);
begin
  SetVarAttr(aNameID, VarAsType(aValue, varDate))
end;

procedure TXmlNode.SetDateTimeAttr(const aName: TXmlString;
                                         aValue: TDateTime);
begin
  SetVarAttr(aName, VarAsType(aValue, varDate))
end;

function TXmlNode.EnsureChild(aNameID: NativeInt): IXmlNode;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild
  else
    Result := AppendElement(aNameID)
end;

function TXmlNode.EnsureChild(const aName: TXmlString): IXmlNode;
begin
  Result := EnsureChild(FNames.GetID(aName))
end;

procedure TXmlNode.ExchangeChilds(const aChild1, aChild2: IXmlNode);
var
  i1, i2: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  i1 := aChilds.IndexOf(aChild1.GetObject as TXmlNode);
  i2 := aChilds.IndexOf(aChild2.GetObject as TXmlNode);
  if (i1 <> -1) and (i2 <> -1) then
    aChilds.Exchange(i1, i2);
end;

function TXmlNode.NeedChild(aNameID: NativeInt): IXmlNode;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then
    raise Exception.CreateFmt(SSimpleXmlError10, [FNames.GetName(aNameID)]);
  Result := aChild
end;

function TXmlNode.NeedChild(const aName: TXmlString): IXmlNode;
begin
  Result := NeedChild(FNames.GetID(aName));
end;

procedure TXmlNode.SetNameTable(aValue: TXmlNameTable);
var
  i: Integer;
begin
  if aValue <> FNames
  then begin
    //Merge different Nametables
    SetNodeNameID(aValue.GetID(Get_NodeName));
    for i := 0 to High(FAttrs) do
      with FAttrs[i] do
        NameID := aValue.GetID(FNames.GetName(NameID));
    if Assigned(FChilds) then
      for i := 0 to FChilds.FCount - 1 do
        FChilds.FItems[i].SetNameTable(aValue);
    FNames._Release;
    FNames := aValue;
    FNames._AddRef;
  end;
end;

procedure TXmlNode.SetNodeNameID(aValue: Integer);
begin
//Do nothing here for Classes with read only name - like '#text'
end;
  
function TXmlNode.CloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := DoCloneNode(aDeep)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Element Implementation'}{$ENDIF}
{ TXmlElement }

constructor TXmlElement.Create(aNames: TXmlNameTable; aNameID: NativeInt);
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Create %s (%s)', [Classname, aNames.GetName(aNameID)])));
  {$ENDIF}
  inherited Create(aNames);
  FNameID := aNameID;
end;

function TXmlElement.Get_NodeNameID: NativeInt;
begin
  Result := FNameID
end;

function TXmlElement.GetChilds: TXmlNodeList;
begin
  Result := inherited GetChilds;
  if not TVarData(FData).VType in [varEmpty, varNull] then begin
    AppendChild(TXmlText.Create(FNames, FData));
    VarClear(FData);
  end;
end;

function TXmlElement.Get_Text: TXmlString;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aChildText: TXmlString;
  i: Integer;
begin
  Result := '';
  aChilds := FChilds;
  if Assigned(aChilds) and (aChilds.FCount>0)
  then begin
    for i := 0 to aChilds.FCount - 1 do
    begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType=TXmlText) or (aChild.ClassType=TXmlCDATASection)//or (aChild.ClassType=TXmlElement)
      then begin
        aChildText := aChild.Get_Text;
        if aChildText <> '' 
        then begin
          if Result = '' 
          then
            Result := aChildText
          else
            Result := Result + ' ' + aChildText
        end;
      end
    end;
  end
  else if VarIsEmpty(FData) then
    Result := ''
  else
    Result := VarToXSTR(TVarData(FData))
end;

function TXmlElement.GetTextAsBinaryData: TBytes;
begin
  Result := Base64ToBin(Get_Text);
end;

procedure TXmlElement.ReplaceTextByBinaryData(const aData; aSize: Integer;
                                              aMaxLineLength: Integer);
begin
  RemoveTextNodes;
  GetChilds.Insert(TXmlText.Create(FNames, BinToBase64(aData, aSize, aMaxLineLength)), -1);
end;

procedure TXmlElement.RemoveTextNodes;
var
  i: Integer;
  aNode: TXmlNode;
begin
  if Assigned(FChilds) then
    for i := FChilds.FCount - 1 downto 0 do begin
      aNode := FChilds.FItems[i];
      if (aNode.ClassType=TXmlText) or (aNode.ClassType=TXmlCDATASection) 
      then
        FChilds.Remove(aNode);
    end;
end;

procedure TXmlElement.ReplaceTextByCDATASection(const aText: TXmlString);

  procedure AddCDATASection(const aText: TXmlString);
  var
    i: Integer;
    aChilds: TXmlNodeList;
  begin
    i := Pos(']]>', aText);
    aChilds := GetChilds;
    if i = 0 then
      aChilds.Insert(TXmlCDATASection.Create(FNames, aText), aChilds.FCount)
    else begin
      aChilds.Insert(TXmlCDATASection.Create(FNames, Copy(aText, 1, i)), aChilds.FCount);
      AddCDATASection(Copy(aText, i + 1, Length(aText) - i - 1));
    end;
  end;

begin
  RemoveTextNodes;
  AddCDATASection(aText);
end;

procedure TXmlElement.Set_Text(const aValue: TXmlString);
begin
  if Assigned(FChilds) then
    FChilds.Clear;
  FData := aValue;
end;

function TXmlElement.AsElement: IXmlElement;
begin
  Result := Self
end;

function GetIndentStr(XMLIntend: Integer): TXmlString;
var
  i: Integer;
begin
  SetLength(Result, XMLIntend*Length(DefaultIndentText));
  for i := 0 to XMLIntend - 1 do
    Move(DefaultIndentText[1], Result[i*Length(DefaultIndentText) + 1], Length(DefaultIndentText)*SizeOf(TXmlChar));
end;

function HasCRLF(const s: TXmlString): Boolean;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if (s[i] = #13) or (s[i] = #10) then begin
      Result := True;
      Exit
    end;
  Result := False;
end;

function EndWithCRLF(const s: TXmlString): Boolean;
begin
  Result :=
    (Length(s) > 1) and
    (s[Length(s) - 1] = #13) and
    (s[Length(s)] = #10);
end;

function TXmlElement.Get_XML: TXmlString;
var
  aChildsXML: TXmlString;
  aTag: TXmlString;
  aXMLIntend: Integer;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace 
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0) then
      aChildsXML := FChilds.Get_XML
    else if VarIsEmpty(FData) then
      aChildsXML := ''
    else
      aChildsXML := TextToXML(VarToXSTR(TVarData(FData)));

    aTag := FNames.GetName(FNameID);
    Result := '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>'
  end
  else begin
    aXMLIntend := GetXMLIntend;
    if Assigned(FChilds) and (FChilds.FCount > 0) 
    then 
      aChildsXML := FChilds.Get_XML
    else 
    if VarIsEmpty(FData) 
    then
      aChildsXML := ''
    else
      aChildsXML := TextToXML(VarToXSTR(TVarData(FData)));
    aTag := FNames.GetName(FNameID);
    Result := #13#10 + GetIndentStr(aXMLIntend) + '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else if HasCRLF(aChildsXML) then
      if EndWithCRLF(aChildsXML) then
        Result := Result + '>' + aChildsXML + GetIndentStr(aXMLIntend) + '</' + aTag + '>'
      else
        Result := Result + '>' + aChildsXML + #13#10 + GetIndentStr(aXMLIntend) + '</' + aTag + '>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>';
  end;
end;

function TXmlElement.Get_TypedValue: Variant;
begin
  if Assigned(FChilds) and (FChilds.FCount > 0) then
    Result := Get_Text
  else 
    Result := FData
end;

procedure TXmlElement.Set_TypedValue(const aValue: Variant);
begin
  if Assigned(FChilds) then
    FChilds.Clear;
  FData := aValue;
end;

function TXmlElement.Get_DataType: Integer;
begin
  if (Assigned(FChilds) and (FChilds.FCount > 0)) or VarIsEmpty(FData) 
  then begin
    {$IF Defined(Unicode)}
    Result := varUString;
    {$ELSEIF Defined(XML_WIDE_CHARS)}
    Result := varOleStr;
    {$ELSE}
    Result := varString;
    {$IFEND}
  end
  else
    Result := TVarData(FData).VType;
end;

function TXmlElement.Get_ChildNodes: IXmlNodeList;
begin
  Result := inherited Get_ChildNodes;
end;

procedure TXmlElement.SaveXML(aXMLSaver: TXmlSaver);
var
  aTag: TXmlString;
  aXMLIntend: TXmlString;
begin
  aTag := FNames.GetName(FNameID);
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      aXMLSaver.Save('</' + aTag + '>');
    end
    else
    if VarIsEmpty(FData)
    then
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '/>')
    else begin
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '>');
      aXMLSaver.Save(TextToXML(VarToXSTR(TVarData(FData))));
      aXMLSaver.Save('</' + aTag + '>');
    end;
  end
  else begin
    aXMLIntend := #13#10 + GetIndentStr(GetXMLIntend);
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      if (FChilds.FCount > 1) or (FChilds.FItems[0] is TXmlElement)
      then
        aXMLSaver.Save(aXMLIntend + '</' + aTag + '>')
      else
        aXMLSaver.Save('</' + aTag + '>');
    end
    else
    if VarIsEmpty(FData)
    then
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '/>')
    else begin
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '>');
      aXMLSaver.Save(TextToXML(VarToXSTR(TVarData(FData))));
      aXMLSaver.Save('</' + aTag + '>');
    end;
  end;
end;

procedure TXmlElement.SetNodeNameID(aValue: Integer);
begin
  FNameID := aValue
end;

function TXmlElement.DoCloneNode(aDeep: Boolean): IXmlNode;
var
  aClone: TXmlElement;
  i: Integer;
begin
  aClone := TXmlElement.Create(FNames, FNameID);
  Result := aClone;
  aClone.FData := FData;
  SetLength(aClone.FAttrs, FAttrCount);
  aClone.FAttrCount := FAttrCount;
  for i := 0 to FAttrCount - 1 do
    aClone.FAttrs[i] := FAttrs[i];
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0)
  then begin
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlCharacterData Implementation'}{$ENDIF}

constructor TXmlCharacterData.Create(aNames: TXmlNameTable;
  const aData: TXmlString);
begin
  inherited Create(aNames);
  FData := aData;
end;

function TXmlCharacterData.Get_Text: TXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace  
  then
    Result := FData
  else
    Result := Trim(FData);
end;

procedure TXmlCharacterData.Set_Text(const aValue: TXmlString);
begin
  FData := aValue
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlText Implementation'}{$ENDIF}

function TXmlText.AsText: IXmlText;
begin
  Result := Self;
end;

constructor TXmlText.Create(aNames: TXmlNameTable; const aData: Variant);
begin
  inherited Create(aNames);
  FData := aData;
end;

function TXmlText.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlText.Create(FNames, FData);
end;

function TXmlText.Get_DataType: Integer;
begin
  Result := TVarData(FData).VType
end;

function TXmlText.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlTextNameID
end;

function TXmlText.Get_Text: TXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace 
  then
    Result := VarToXSTR(TVarData(FData))
  else
    Result := Trim(VarToXSTR(TVarData(FData)));
end;

function TXmlText.Get_TypedValue: Variant;
begin
  Result := FData
end;

function TXmlText.Get_XML: TXmlString;
begin
  Result := TextToXML(VarToXSTR(TVarData(FData)));
end;

procedure TXmlText.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;

procedure TXmlText.Set_Text(const aValue: TXmlString);
begin
  FData := aValue
end;

procedure TXmlText.Set_TypedValue(const aValue: Variant);
begin
  FData := aValue
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlCDATASection Implementation'}{$ENDIF}
function TXmlCDATASection.AsCDATASection: IXmlCDATASection;
begin
  Result := Self
end;

function TXmlCDATASection.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlCDATASection.Create(FNames, FData);
end;

function TXmlCDATASection.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCDATASectionNameID
end;

function GenCDATAXML(const aValue: TXmlString): TXmlString;
var
  i: Integer;
begin
  i := Pos(']]>', aValue);
  if i = 0 then
    Result := '<![CDATA[' + aValue + ']]>'
  else
    Result := '<![CDATA[' + Copy(aValue, 1, i) + ']]>' + GenCDATAXML(Copy(aValue, i + 1, Length(aValue) - i - 1));
end;

function TXmlCDATASection.Get_XML: TXmlString;
begin
  Result := GenCDATAXML(FData); 
end;

procedure TXmlCDATASection.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlComment Implementation'}{$ENDIF}

function TXmlComment.AsComment: IXmlComment;
begin
  Result := Self
end;

function TXmlComment.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlComment.Create(FNames, FData);
end;

function TXmlComment.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCommentNameID
end;

function TXmlComment.Get_XML: TXmlString;
begin
  Result := '<!--' + FData + '-->'
end;

procedure TXmlComment.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlDocument Implementation'}{$ENDIF}

constructor TXmlDocument.Create(aNames: TXmlNameTable);
begin
  inherited Create(aNames);
  FPreserveWhiteSpace := DefaultPreserveWhiteSpace;
end;

function TXmlDocument.CreateCDATASection(
  const aData: TXmlString): IXmlCDATASection;
begin
  Result := TXmlCDATASection.Create(FNames, aData)
end;

function TXmlDocument.CreateComment(const aData: TXmlString): IXmlComment;
begin
  Result := TXmlComment.Create(FNames, aData) 
end;

function TXmlDocument.CreateElement(aNameID: NativeInt): IXmlElement;
begin
  Result := TXmlElement.Create(FNames, aNameID)
end;

function TXmlDocument.CreateElement(const aName: TXmlString): IXmlElement;
begin
  Result := TXmlElement.Create(FNames, FNames.GetID(aName));
end;

function TXmlDocument.CreateProcessingInstruction(const aTarget,
  aData: TXmlString): IXmlProcessingInstruction;
begin
  Result := TXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData)
end;

function TXmlDocument.CreateProcessingInstruction(aTargetID: NativeInt;
  const aData: TXmlString): IXmlProcessingInstruction;
begin
  Result := TXmlProcessingInstruction.Create(FNames, aTargetID, aData)
end;

function TXmlDocument.CreateText(const aData: TXmlString): IXmlText;
begin
  Result := TXmlText.Create(FNames, aData)
end;

function TXmlDocument.DoCloneNode(aDeep: Boolean): IXmlNode;
var
  aClone: TXmlDocument;
  i: Integer;
begin
  aClone := TXmlDocument.Create(FNames);
  Result := aClone;
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;

function TXmlDocument.Get_BinaryXML: RawByteString;
var
  aWriter: TStrXmlWriter;
begin
  aWriter := TStrXmlWriter.Create(0, $10000);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
    aWriter.FlushBuf;
    Result := aWriter.FData;
  finally
    aWriter.Free
  end
end;

function TXmlDocument.Get_DocumentElement: IXmlElement;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  i: Integer;
begin
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if aChild.ClassType = TXmlElement then begin
      Result := TXmlElement(aChild);
      Exit
    end
  end;
  Result := nil;
end;

function TXmlDocument.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlDocumentNameID
end;

function TXmlDocument.Get_OnTagBegin: THookTag;
begin
  if Self<>nil
  then
    Result := FOnTagBegin
  else
    Result := nil;
end;

function TXmlDocument.Get_OnTagEnd: THookTag;
begin
  if Self<>nil
  then
    Result := FOnTagEnd
  else
    Result := nil;
end;

function TXmlDocument.Get_PreserveWhiteSpace: Boolean;
begin
  if Self<>nil
  then
    Result := FPreserveWhiteSpace
  else
    Result := DefaultPreserveWhiteSpace;
end;

function TXmlDocument.Get_Text: TXmlString;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aChildText: TXmlString;
  i: Integer;
begin
  Result := '';
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if  (aChild.ClassType=TXmlText) or (aChild.ClassType=TXmlCDATASection) //or (aChild.ClassType=TXmlElement)
    then begin
      aChildText := aChild.Get_Text;
      if aChildText <> '' 
      then begin
        if Result = '' 
        then
          Result := aChildText
        else
          Result := Result + ' ' + aChildText
      end;
    end
  end;
end;

function TXmlDocument.Get_XML: TXmlString;
begin
  Result := GetChilds.Get_XML
end;

procedure TXmlDocument.Load(aStream: TStream);
var
  aXml: TXmlSource;
  aBinarySign: AnsiString;
  aReader: TBinXmlReader;
  Bom: array [0..3] of Byte;
  BomLen: Integer;
  BomType: (btNone, btUTF16BE, btUTF16LE, btUTF32BE, btUTF32LE, btUTF8);
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  if aStream.Size > BinXmlSignatureSize
  then begin
    SetLength(aBinarySign, BinXmlSignatureSize);
    aStream.ReadBuffer(Pointer(aBinarySign)^, BinXmlSignatureSize);
    if aBinarySign = BinXmlSignature
    then begin
      aReader := TStmXmlReader.Create(aStream, $10000);
      try
        FNames.LoadBinXml(aReader);
        LoadBinXml(aReader);
      finally
        aReader.Free
      end;
      Exit;
    end;
    aStream.Position := aStream.Position - BinXmlSignatureSize;
  end;
  if aStream.Size > Length(Bom)
  then begin
    aStream.ReadBuffer(Bom, Length(Bom));
    aStream.Seek(-Length(Bom), soFromCurrent);
    if PDWord(@Bom)^=$FFFE0000
    then begin
      BomType := btUTF32BE;
      BomLen := 4;
    end
    else
    if PDWord(@Bom)^=$0000FEFF
    then begin
      BomType := btUTF32LE;
      BomLen := 4;
    end
    else
    if PWord(@Bom)^=$FEFF
    then begin
      BomType := btUTF16LE;
      BomLen := 2;
    end
    else
    if PWord(@Bom)^=$FFFE
    then begin
      BomType := btUTF16BE;
      BomLen := 2;
    end
    else
    if (Bom[0]=$EF) and (Bom[1]=$BB) and (Bom[2]=$BF)
    then begin
      BomType := btUTF8;
      BomLen := 3;
    end
    else begin
      BomType := btNone;
      BomLen := 0;
    end;
    if not (BomType in [btNone, btUTF8])
    then
      raise Exception.Create(SSimpleXmlError27);
    aStream.Seek(BomLen, soFromCurrent);
  end;
  aXml := TXmlSource.Create(aStream);
  try
    GetChilds.ParseXML(aXml, FNames, FPreserveWhiteSpace, FOnTagEnd, FOnTagBegin);
  finally
    aXml.Free
  end
end;

procedure TXmlDocument.Load(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    Load(aFile);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.LoadBinaryXML(const aXML: RawByteString);
var
  aReader: TStrXmlReader;
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  aReader := TStrXmlReader.Create(aXML);
  try
    FNames.LoadBinXml(aReader);
    LoadBinXml(aReader);
  finally
    aReader.Free
  end
end;

procedure TXmlDocument.LoadResource(aType, aName: PChar);
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  aRSRC := FindResource(HInstance, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := Windows.LoadResource(HInstance, aRSRC);
    aSize := SizeofResource(HInstance, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr)^, aSize);
        LoadXML(AStr);
      end;
    end;
  end;
end;

procedure TXmlDocument.LoadXML(const aXML: RawByteString);
var
  aSource: TXmlSource;
begin
  if XmlIsInBinaryFormat(aXML)
  then begin
    LoadBinaryXML(aXML)
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TXmlSource.Create(aXML);
    try
      GetChilds.ParseXML(aSource, FNames, FPreserveWhiteSpace, FOnTagEnd, FOnTagBegin);
    finally
      aSource.Free
    end
  end
end;

{$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
procedure TXmlDocument.LoadXML(const aXML: TXmlString);
var
  aSource: TXmlSource;
  Temp: RawByteString;
begin
  if XmlIsInBinaryFormat(AnsiString(copy(aXml, 1, BinXmlSignatureSize)))
  then begin
    SetLength(Temp, Length(aXML));
    CopyWordToByteArray(Pointer(aXML), Pointer(Temp), Length(aXML));
    LoadBinaryXML(Temp);
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TXmlSource.Create(AnsiToUTF8(aXML));
    try
      aSource.AutoCodepage := False;
      GetChilds.ParseXML(aSource, FNames, FPreserveWhiteSpace, FOnTagEnd, FOnTagBegin);
    finally
      aSource.Free
    end
  end
end;
{$IFEND}


function TXmlDocument.NewDocument(const aVersion, anEncoding,
                                  aRootElementName: TXmlString): IXmlElement;
begin
  Result := NewDocument(aVersion, anEncoding, FNames.GetID(aRootElementName));
end;

function TXmlDocument.NewDocument(const aVersion, anEncoding: TXmlString;
                                  aRootElementNameID: NativeInt): IXmlElement;
var
  aChilds: TXmlNodeList;
  aNode: TXmlNode;
  aValue: TXmlString;
begin
  aChilds := GetChilds;
  aChilds.Clear;
  aNode := TXmlProcessingInstruction.Create(FNames, FNames.FXmlNameID, '');
  if aVersion = '' then
    aValue := '1.0'
  else
    aValue := aVersion;
  aNode.SetAttr('version', aValue);
  if anEncoding = '' then
    aValue := XMLEncodingData[0].Encoding
  else
    aValue := anEncoding;
  aNode.SetAttr(FNames.FEncodingNameId, aValue);
  aChilds.Insert(aNode, 0);
  aNode := TXmlElement.Create(FNames, aRootElementNameID);
  aChilds.Insert(aNode, 1);
  Result := TXmlElement(aNode);
end;

procedure TXmlDocument.Save(aStream: TStream);
var
  EncodingStr: TXmlString;
  aNode: TXmlNode;
  XMLSaver: TXMLSaver;
begin
  XMLSaver := TXMLStmSaver.Create(aStream, 4096);
  try
    aNode := FindFirstChild(FNames.FXmlNameID);
    if aNode<>nil
    then begin
      EncodingStr := aNode.GetVarAttr(FNames.FEncodingNameId, '');
      if EncodingStr<>''
      then begin
        XMLSaver.FCodepage := FindCodepage(EncodingStr);
        if XMLSaver.FCodepage=0
        then
          raise Exception.CreateFmt(SSimpleXmlError26, [EncodingStr]);
      end;
    end;
    SaveXML(XMLSaver);
  finally
    XMLSaver.Free;
  end;
end;

procedure TXmlDocument.Save(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    Save(aFile);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.SaveBinary(aStream: TStream; anOptions: LongWord);
var
  aWriter: TBinXmlWriter;
begin
  aWriter := TStmXmlWriter.Create(aStream, anOptions, 65536);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
  finally
    aWriter.Free
  end
end;

procedure TXmlDocument.SaveBinary(const aFileName: String; anOptions: LongWord);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    SaveBinary(aFile, anOptions);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.SaveXML(aXMLSaver: TXmlSaver);
begin
  GetChilds.SaveXML(aXMLSaver);
end;

procedure TXmlDocument.Set_OnTagBegin(aValue: THookTag);
begin
  FOnTagBegin := aValue;
end;

procedure TXmlDocument.Set_OnTagEnd(aValue: THookTag);
begin
  FOnTagEnd := aValue;
end;

procedure TXmlDocument.Set_PreserveWhiteSpace(aValue: Boolean);
begin
  FPreserveWhiteSpace := aValue;
end;

procedure TXmlDocument.Set_Text(const aText: TXmlString);
var
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  aChilds.Clear;
  aChilds.Insert(TXmlText.Create(FNames, aText), 0);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlProcessingInstruction Implementation'}{$ENDIF}

function TXmlProcessingInstruction.AsProcessingInstruction: IXmlProcessingInstruction;
begin
  Result := Self
end;

constructor TXmlProcessingInstruction.Create(aNames: TXmlNameTable;
  aTargetID: NativeInt; const aData: TXmlString);
begin
  inherited Create(aNames);
  FTargetNameID := aTargetID;
  FData := aData;
end;

function TXmlProcessingInstruction.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlProcessingInstruction.Create(FNames, FTargetNameID, FData);
end;

function TXmlProcessingInstruction.Get_NodeNameID: NativeInt;
begin
  Result := FTargetNameID
end;

function TXmlProcessingInstruction.Get_Text: TXmlString;
begin
  Result := FData;
end;

function TXmlProcessingInstruction.Get_XML: TXmlString;
begin
  if FData = '' then
    Result := '<?' + FNames.GetName(FTargetNameID) + GetAttrsXML + '?>'
  else
    Result := '<?' + FNames.GetName(FTargetNameID) + ' ' + FData + '?>'
end;

procedure TXmlProcessingInstruction.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;

procedure TXmlProcessingInstruction.SetNodeNameID(aValue: Integer);
begin
  FTargetNameID := aValue
end;

procedure TXmlProcessingInstruction.Set_Text(const aText: TXmlString);
begin
  FData := aText
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlSource Implementation'}{$ENDIF}

procedure TXmlSource.NewToken;
begin
  Inc(FTokenStackTop);
  if FTokenStackTop < Length(FTokenStack) then begin
    FToken := FTokenStack[FTokenStackTop];
    FToken.Clear
  end
  else begin
    SetLength(FTokenStack, FTokenStackTop + 1);
    FToken := TXmlToken.Create;
    FTokenStack[FTokenStackTop] := FToken;
  end
end;

function TXmlSource.Next: Boolean;
  procedure FillBuffer;
  var
    TempSrc: array [0..SourceBufferSize-1] of AnsiChar;
    {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
    TempDest: array [0..SourceBufferSize-1] of WideChar;
    {$IFEND}
    Size: Integer;
    P: PByte;
  begin
    if FCodePage=0
    then begin
      FBufSize := FStream.Read(TempSrc, 1);
      FBuffer^ := TXmlChar(TempSrc[0]);
    end
    else begin
      if FRemainSize>0
      then begin
        move(FRemainBuff, TempSrc, FRemainSize);
        P := @TempSrc;
        inc(P, FRemainSize);
        Size := FStream.Read(P^, SourceBufferSize - FRemainSize) + FRemainSize;
        FRemainSize := 0;
      end
      else
        Size := FStream.Read(TempSrc, SourceBufferSize);
      if Size>0
      then begin
        if FCodepage=CP_UTF8
        then begin
          P := @TempSrc; inc(P, Size);
          {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
          FBufSize := Utf8ToUnicode(FBuffer, SourceBufferSize, @TempSrc, Size);
          {$ELSE}
          FBufSize := Utf8ToUnicode(@TempDest, SourceBufferSize, @TempSrc, Size);
          {$IFEND}
          if (Size>0) and (Size<=SizeOf(FRemainBuff))
          then begin
            dec(P, Size);
            move(P^, FRemainBuff, Size);
            FRemainSize := Size;
          end;
        end
        else begin
          {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
          FBufSize := MultiByteToWideChar(FCodepage, 0, @TempSrc, Size, FBuffer, SourceBufferSize);
          {$ELSE}
          FBufSize := MultiByteToWideChar(FCodepage, 0, @TempSrc, Size, @TempDest, SourceBufferSize);
          {$IFEND}
        end;
      end;
      {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
      FBufSize := WideCharToMultiByte(XMLCodepage, 0, @TempDest, FBufSize, FBuffer, SourceBufferSize, nil, nil);
      {$IFEND}
    end;
    if FBufSize=0
    then
      FBufSize := -1;
    FBufPtr := FBuffer;
  end;
begin
  Result := FBufSize>0;
  if Result
  then begin
    CurChar := FBufPtr^;
    dec(FBufSize);
    Inc(FBufPtr);
    Inc(FSourceCol);
    if CurChar = #$0a then
    begin
      Inc(FSourceLine);
      FSourceCol := 0;
    end;
  end
  else
  if FBufSize=0
  then begin
    FillBuffer;
    Result := Next;
  end
  else begin
    CurChar := #0;
    Result := False;
  end;
end;

function TXmlSource.AcceptToken: TXmlString;
begin
  Result := FToken.Text;
  DropToken;
end;

procedure TXmlSource.SetCodepage(Codepage: Word);
begin
  FCodepage := Codepage;
end;

procedure TXmlSource.SkipBlanks;
begin
  while not EOF and (CurChar <= ' ') do
    Next;
end;

// на входе - первый символ имени
// на выходе - первый символ, который не является допустимым для имен
function TXmlSource.ExpectXmlName: TXmlString;
begin
  if not NameCanBeginWith(CurChar) then
    raise Exception.CreateFmt(SSimpleXmlError11, [FSourceLine, FSourceCol]);
  NewToken;
  AppendTokenChar(CurChar);
  while Next and NameCanContain(CurChar) do
    AppendTokenChar(CurChar);
  Result := AcceptToken;
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для чисел
function TXmlSource.ExpectDecimalInteger: Integer;
var
  s: TXmlString;
  e: Integer;
begin
  NewToken;
  while (CurChar >= '0') and (CurChar <= '9') do begin
    AppendTokenChar(CurChar);
    Next;
  end;
  s := AcceptToken;
  if Length(s) = 0 then
    raise Exception.CreateFmt(SSimpleXmlError12, [FSourceLine, FSourceCol]);
  Val(s, Result, e);
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для
// щестнадцатиричных чисел
function TXmlSource.ExpectHexInteger: Integer;
var
  s: TXmlString;
  e: Integer;
begin
  NewToken;
  {$IFDEF XML_WIDE_CHARS}
  while (CurChar >= '0') and (CurChar <= '9') or
    (CurChar >= 'A') and (CurChar <= 'F') or
    (CurChar >= 'a') and (CurChar <= 'f') do begin
  {$ELSE}
  {$IFDEF Unicode}
  while CharInSet(CurChar, ['0'..'9', 'A'..'F', 'a'..'f']) do begin
  {$ELSE}
  while CurChar in ['0'..'9', 'A'..'F', 'a'..'f'] do begin
  {$ENDIF}
  {$ENDIF}
    AppendTokenChar(CurChar);
    Next;
  end;
  s := '$';
  s := s + AcceptToken;
  if Length(s) = 1 then
    raise Exception.CreateFmt(SSimpleXmlError13, [FSourceLine, FSourceCol]);
  Val(s, Result, e);
end;

// на входе: "&"
// на выходе: следующий за ";"
function TXmlSource.ExpectXmlEntity: TXmlChar;
var
  s: TXmlString;
begin
  if not Next then
    raise Exception.CreateFmt(SSimpleXmlError14, [FSourceLine, FSourceCol]);
  if CurChar = '#' then begin
    if not Next then
      raise Exception.CreateFmt(SSimpleXmlError12, [FSourceLine, FSourceCol]);
    if CurChar = 'x' then begin
      Next;
      Result := TXmlChar(ExpectHexInteger);
    end
    else
      Result := TXmlChar(ExpectDecimalInteger);
    ExpectChar(';');
  end
  else begin
    s := ExpectXmlName;
    ExpectChar(';');
    if s = 'amp' then
      Result := '&'
    else if s = 'quot' then
      Result := '"'
    else if s = 'lt' then
      Result := '<'
    else if s = 'gt' then
      Result := '>'
    else if s = 'apos' then
      Result := ''''
    else
      raise Exception.CreateFmt(SSimpleXmlError15 , [s, FSourceLine, FSourceCol]);
  end
end;

function TXmlSource.EOF: Boolean;
begin
  Result := FBufSize<0;
end;

procedure TXmlSource.ExpectChar(aChar: TXmlChar);
begin
  if EOF or (CurChar <> aChar) then
    raise Exception.CreateFmt(SSimpleXmlError16, [aChar, FSourceLine, FSourceCol]);
  Next;
end;

procedure TXmlSource.ExpectText(aText: PXmlChar);
begin
  while aText^ <> #0 do begin
    if (CurChar <> aText^) or EOF then
      raise Exception.CreateFmt(SSimpleXmlError17, [aText, FSourceLine, FSourceCol]);
    Inc(aText);
    Next;
  end;
end;

// на входе: открывающая кавычка
// на выходе: символ, следующий за закрывающей кавычкой
function TXmlSource.ExpectQuotedText(aQuote: TXmlChar): TXmlString;
begin
  NewToken;
  Next;
  while not EOF and (CurChar <> aQuote) do begin
    if CurChar = '&' then
      AppendTokenChar(ExpectXmlEntity)
    else if CurChar = '<' then
      raise Exception.CreateFmt(SSimpleXmlError18, [FSourceLine, FSourceCol])
    else begin
      AppendTokenChar(CurChar);
      Next;
    end
  end;
  if EOF then
    raise Exception.CreateFmt(SSimpleXmlError19, [aQuote, FSourceLine, FSourceCol]);
  Next;
  Result := AcceptToken;
end;

procedure TXmlSource.ParseAttrs(aNode: TXmlNode);
var
  aName: TXmlString;
  aValue: TXmlString;
begin
  SkipBlanks;
  while not EOF and NameCanBeginWith(CurChar) do begin
    aName := ExpectXmlName;
    SkipBlanks;
    ExpectChar('=');
    SkipBlanks;
    if EOF then
      raise Exception.CreateFmt(SSimpleXmlError20, [FSourceLine, FSourceCol]);
    if (CurChar = '''') or (CurChar = '"') then
      aValue := ExpectQuotedText(CurChar)
    else
      raise Exception.CreateFmt(SSimpleXmlError21, [FSourceLine, FSourceCol]);
    aNode.SetAttr(aName, aValue);
    SkipBlanks;
  end;
end;

function StrEquals(p1, p2: PXmlChar; aLen: Integer): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  while aLen > 0 do
    if p1^ <> p2^ then begin
      Result := False;
      Exit
    end
    else if (p1^ = #0) or (p2^ = #0) then begin
      Result := p1^ = p2^;
      Exit
    end
    else begin
      Inc(p1);
      Inc(p2);
      Dec(aLen);
    end;
  Result := True;
  {$ELSE}
  Result := StrLComp(p1, p2, aLen) = 0
  {$ENDIF}
end;

// на входе: первый символ текста
// на выходе: символ, следующий за последним символом ограничителя
function TXmlSource.ParseTo(aText: PXmlChar): TXmlString;
var
  aCheck: PXmlChar;
  p: PXmlChar;
begin
  NewToken;
  aCheck := aText;
  while not EOF do begin
    if CurChar = aCheck^ then begin
      Inc(aCheck);
      Next;
      if aCheck^ = #0 then begin
        Result := AcceptToken;
        Exit;
      end;
    end
    else if aCheck = aText then begin
      AppendTokenChar(CurChar);
      Next;
    end
    else begin
      p := aText + 1;
      while (p < aCheck) and not StrEquals(p, aText, aCheck - p) do
        Inc(p);
      AppendTokenText(aText, p - aText);
      if p < aCheck then
        aCheck := p
      else
        aCheck := aText;
    end;
  end;
  raise Exception.CreateFmt(SSimpleXmlError22, [aText, FSourceLine, FSourceCol]);
end;

function CalcUTF8Len(c: AnsiChar): Integer;
begin
  if Byte(c) and $80=0
  then
    Result := 1
  else
  if Byte(c) and $E0=$C0
  then
    Result := 2
  else
  if Byte(c) and $F0=$E0
  then
    Result := 3
  else
  if Byte(c) and $F8=$F0
  then
    Result := 4
  else
    Result := 0;
end;

procedure TXmlSource.AppendTokenChar(aChar: TXmlChar);
begin
  FToken.AppendChar(aChar);
end;

procedure TXmlSource.AppendTokenText(aText: PXmlChar; aCount: Integer);
begin
  FToken.AppendText(aText, aCount)
end;

constructor TXmlSource.Create(aStream: TStream);
begin
  inherited Create;
  FStream := aStream;
  FTokenStackTop := -1;
  FCodepage := 0;
  AutoCodepage := True;  //Set Codepage according XML encoding property
  GetMem(FBuffer, SourceBufferSize*SizeOf(TXmlChar));
  FBufPtr := FBuffer;
  FSourceLine := 1;
  FSourceCol := 0;
  Next;
end;

constructor TXmlSource.Create(aString: RawByteString);
var
  aStream: TStream;
begin
  aStream := TMemoryStream.Create;
  aStream.WriteBuffer(Pointer(aString)^, Length(aString));
  aStream.Position := 0;
  FStreamOwner := True;
  Create(aStream);
end;

procedure TXmlSource.DropToken;
begin
  Dec(FTokenStackTop);
  if FTokenStackTop >= 0 then
    FToken := FTokenStack[FTokenStackTop]
  else
    FToken := nil
end;

destructor TXmlSource.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(FTokenStack) - 1 do
    FTokenStack[i].Free;
  FreeMem(FBuffer);
  if FStreamOwner
  then
    FStream.Free;
  inherited;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlToken Implementation'}{$ENDIF}

procedure TXmlToken.AppendChar(aChar: TXmlChar);
begin
  if FLength >= FSize 
  then begin
    Inc(FSize);
    SetLength(FValueBuf, FSize);
  end;
  Inc(FLength);
  FValueBuf[FLength] := aChar;
end;

procedure TXmlToken.AppendText(aText: PXmlChar; aCount: Integer);
begin
  if FLength >= System.Length(FValueBuf) 
  then begin
    Inc(FSize, aCount);
    SetLength(FValueBuf, FSize);
  end;
  Move(aText^, FValueBuf[FLength+1], aCount*sizeof(TXmlChar));
  Inc(FLength, aCount);
end;

procedure TXmlToken.Clear;
begin
  FLength := 0;
end;

constructor TXmlToken.Create;
begin
  inherited Create;
  SetLength(FValueBuf, 32);
  FSize := 32;
end;

function TXmlToken.Text: TXmlString;
begin
  SetLength(Result, FLength);
  if FLength>0 
  then
    Move(Pointer(FValueBuf)^, Pointer(Result)^, FLength*sizeof(TXmlChar));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlSaver Implementation'}{$ENDIF}

constructor TXmlSaver.Create(aBufSize: Integer);
begin
  GetMem(FBuffer, aBufSize);
  FBufferPtr := FBuffer;
  FBuffersize := aBufSize;
  FRemain := aBufSize;
  FCodepage := CP_UTF8;
end;

destructor TXmlSaver.Destroy;
begin
  FlushBuffer;
  FreeMem(FBuffer);
  inherited;
end;

procedure TXmlSaver.SaveToBuffer(XmlStr: PXmlChar; L: Integer);
var
  P: Integer;
{$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
  Temp: PWideChar;
{$IFEND}
begin
  if L>(FRemain div 3)
  then
    FlushBuffer;
  P := FBuffersize div 3;
  while L>P do
  begin
    SaveToBuffer(XmlStr, P);
    FlushBuffer;
    dec(L, P);
    inc(XmlStr, P);
  end;
  if (L<>0)
  then begin
    {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
    GetMem(Temp, L*SizeOf(WideChar));
    try
      L := MultiByteToWideChar(XMLCodepage, 0, XmlStr, L, Temp, L);
      L := WideCharToMultiByte(FCodepage, 0, Temp, L, FBufferPtr, FRemain, nil, nil);
    finally
      FreeMem(Temp);
    end;
    {$ELSE}
    L := WideCharToMultiByte(FCodepage, 0, XmlStr, L, FBufferPtr, FRemain, nil, nil);
    {$IFEND}
    inc(FBufferPtr, L);
    dec(FRemain, L);
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlStmSaver Implementation'}{$ENDIF}

constructor TXmlStmSaver.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create(aBufSize);
  FStream := aStream;
end;

procedure TXmlStmSaver.FlushBuffer;
begin
  if FRemain<FBuffersize
  then begin
    FStream.WriteBuffer(FBuffer^, FBuffersize-FRemain);
    FBufferPtr := FBuffer;
    FRemain := FBuffersize;
  end;
end;

procedure TXmlStmSaver.Save(const XmlStr: TXmlString);
begin
  SaveToBuffer(Pointer(XmlStr), Length(XmlStr));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Reader Implementation'}{$ENDIF}
{ TStmXmlReader }

constructor TStmXmlReader.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FRemainSize := aStream.Size - aStream.Position;
  FBufSize := aBufSize;
  GetMem(FBufStart, aBufSize);
  Read(FOptions, sizeof(FOptions));
end;

destructor TStmXmlReader.Destroy;
begin
  FreeMem(FBufStart);
  inherited;
end;

procedure TStmXmlReader.Read(var aBuf; aSize: Integer);
var
  aDst: PAnsiChar;
begin
  if aSize > FRemainSize then
    raise Exception.Create(SSimpleXmlError23);

  if aSize <= FBufRemain
  then begin
    Move(FBufPtr^, aBuf, aSize);
    Inc(IntPtr(FBufPtr), aSize);
    Dec(FRemainSize, aSize);
    Dec(FBufRemain, aSize);
  end
  else begin
    aDst := @aBuf;
    Move(FBufPtr^, aDst^, FBufRemain);
    Inc(aDst, FBufRemain);
    FStream.ReadBuffer(aDst^, aSize - FBufRemain);
    Dec(FRemainSize, aSize);

    if FRemainSize < FBufSize
    then
      FBufRemain := FRemainSize
    else
      FBufRemain := FBufSize;
    FBufPtr := FBufStart;
    if FBufRemain > 0
    then
      FStream.ReadBuffer(FBufStart^, FBufRemain);
  end;
end;

{ TStrXmlReader }

constructor TStrXmlReader.Create(const aData: RawByteString);
var
  aSig: array [1..BinXmlSignatureSize] of AnsiChar;
begin
  inherited Create;
  FData := aData;
  FRemain := Length(aData);
  FPtr := Pointer(FData);
  Read(aSig, BinXmlSignatureSize);
  Read(FOptions, sizeof(FOptions));
end;

procedure TStrXmlReader.Read(var aBuf; aSize: Integer);
begin
  if aSize > FRemain then
    raise Exception.Create(SSimpleXmlError23);
  Move(FPtr^, aBuf, aSize);
  Inc(IntPtr(FPtr), aSize);
  Dec(FRemain, aSize);
end;

{ TBinXmlReader }

function TBinXmlReader.ReadAnsiString: String;
var
  aLength: LongInt;
  Temp: RawByteString;
begin
  aLength := ReadLongint;
  if aLength = 0 then
    Result := ''
  else begin
    SetLength(Temp, aLength);
    Read(Pointer(Temp)^, aLength);
    Result := UTF8ToAnsi(Temp);
  end
end;

function TBinXmlReader.ReadLongint: Longint;
var
  b: Byte;
begin
  Result := 0;
  Read(Result, 1);
  if Result >= $80 then
    if Result = $FF then
      Read(Result, sizeof(Result))
    else begin
      Read(b, 1);
      Result := (Result and $7F) shl 8 or b;
    end
end;

procedure TBinXmlReader.ReadVariant(var v: TVarData);
var
  aDataType: Word;
  aSize: Longint;
  p: Pointer;
begin
  VarClear(Variant(v));
  aDataType := ReadLongint;
  case aDataType of
    varEmpty: ;
    varNull: ;
    varSmallint:
      Read(v.VSmallint, sizeof(SmallInt));
    varInteger:
      Read(v.VInteger, sizeof(Integer));
    varSingle:
      Read(v.VSingle, sizeof(Single));
    varDouble:
      Read(v.VDouble, sizeof(Double));
    varCurrency:
      Read(v.VCurrency, sizeof(Currency));
    varDate:
      Read(v.VDate, sizeof(TDateTime));
    varOleStr:
      Variant(v) := ReadWideString;
    varBoolean:
      Read(v.VBoolean, sizeof(WordBool));
    varShortInt:
      Read(v.VShortInt, sizeof(ShortInt));
    varByte:
      Read(v.VByte, sizeof(Byte));
    varWord:
      Read(v.VWord, sizeof(Word));
    varLongWord:
      Read(v.VLongWord, sizeof(LongWord));
    varInt64:
      Read(v.VInt64, sizeof(Int64));
    varString:
      Variant(v) := ReadAnsiString;
    {$IFDEF Unicode}
    varUString: 
      Variant(v) := ReadAnsiString;
    {$ENDIF}
    varArray + varByte:
      begin
        aSize := ReadLongint;
        Variant(v) := VarArrayCreate([0, aSize - 1], varByte);
        p := VarArrayLock(Variant(v));
        try
          Read(p^, aSize);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      raise Exception.Create(SSimpleXmlError24);
  end;
  v.VType := aDataType;
end;

function TBinXmlReader.ReadWideString: WideString;
var
  aLength: LongInt;
begin
  aLength := ReadLongint;
  if aLength = 0 then
    Result := ''
  else begin
    SetLength(Result, aLength);
    Read(Pointer(Result)^, aLength*sizeof(WideChar));
  end
end;

function TBinXmlReader.ReadXmlString: TXmlString;
begin
  if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then
    Result := ReadWideString
  else
    Result := TXmlString(ReadAnsiString)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Writer Implementation'}{$ENDIF}
{ TStmXmlWriter }

constructor TStmXmlWriter.Create(aStream: TStream; anOptions: LongWord;
                                 aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FOptions := anOptions;
  FBufSize := aBufSize;
  FRemain := aBufSize;
  GetMem(FBufStart, aBufSize);
  FBufPtr := FBufStart;
  Write(Pointer(BinXmlSignature)^, BinXmlSignatureSize);
  Write(FOptions, sizeof(FOptions));
end;

destructor TStmXmlWriter.Destroy;
begin
  if Cardinal(FBufPtr) > Cardinal(FBufStart) then
    FStream.WriteBuffer(FBufStart^, Integer(FBufPtr) - Integer(FBufStart));
  FreeMem(FBufStart);
  inherited;
end;

procedure TStmXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(FBufPtr, aSize);
    Dec(FRemain, aSize);
  end
  else begin
    if FRemain < FBufSize
    then begin
      FStream.WriteBuffer(FBufStart^, FBufSize-FRemain);
      FBufPtr := FBufStart;
      FRemain := FBufSize;
    end;
    FStream.WriteBuffer(aBuf, aSize);
  end
end;

{ TStrXmlWriter }

constructor TStrXmlWriter.Create(anOptions: LongWord; aBufSize: Integer);
begin
  inherited Create;
  SetLength(FData, aBufSize);
  FRemain := aBufSize;
  FOptions := anOptions;
  FBufPtr := Pointer(FData);
  Write(Pointer(BinXmlSignature)^, BinXmlSignatureSize);
  Write(FOptions, sizeof(FOptions));
end;

procedure TStrXmlWriter.FlushBuf;
begin
  if FRemain>0
  then
    SetLength(FData, Length(FData)-FRemain);
end;

procedure TStrXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(IntPtr(FBufPtr), aSize);
    Dec(FRemain, aSize);
  end
  else begin
    SetLength(FData, Length(FData) + FBufSize + aSize);
    Move(aBuf, FBufPtr^, aSize);
    Inc(IntPtr(FBufPtr), aSize);
    FRemain := FBufSize;
  end
end;

{ TBinXmlWriter }

procedure TBinXmlWriter.WriteAnsiString(const aValue: String);
var
  Temp: RawByteString;
begin
  if Length(aValue) > 0 
  then begin
    Temp := AnsiToUTF8(aValue);
    WriteLongint(Length(Temp));
    Write(Pointer(Temp)^, Length(Temp));
  end
  else
    WriteLongint(0);
end;

procedure TBinXmlWriter.WriteLongint(aValue: Longint);
var
  b: array [0..1] of Byte;
begin
  if aValue < 0 then begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end
  else if aValue < $80 then
    Write(aValue, 1)
  else if aValue <= $7FFF then begin
    b[0] := (aValue shr 8) or $80;
    b[1] := aValue and $FF;
    Write(b, 2);
  end
  else begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end;
end;

procedure TBinXmlWriter.WriteVariant(const v: TVarData);
var
  aSize: Integer;
  p: Pointer;
begin
  WriteLongint(v.VType);
  case v.VType of
    varEmpty: ;
    varNull: ;
    varSmallint:
      Write(v.VSmallint, sizeof(SmallInt));
    varInteger:
      Write(v.VInteger, sizeof(Integer));
    varSingle:
      Write(v.VSingle, sizeof(Single));
    varDouble:
      Write(v.VDouble, sizeof(Double));
    varCurrency:
      Write(v.VCurrency, sizeof(Currency));
    varDate:
      Write(v.VDate, sizeof(TDateTime));
    varOleStr:
      WriteWideString(Variant(v));
    varBoolean:
      Write(v.VBoolean, sizeof(WordBool));
    varShortInt:
      Write(v.VShortInt, sizeof(ShortInt));
    varByte:
      Write(v.VByte, sizeof(Byte));
    varWord:
      Write(v.VWord, sizeof(Word));
    varLongWord:
      Write(v.VLongWord, sizeof(LongWord));
    varInt64:
      Write(v.VInt64, sizeof(Int64));
    varString:
      WriteAnsiString(String(AnsiString(v.VString)));
    {$IFDEF Unicode}
    varUString: 
      WriteAnsiString(String(v.VUString));
    {$ENDIF}
    varArray + varByte:
      begin
        aSize := VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1;
        WriteLongint(aSize);
        p := VarArrayLock(Variant(v));
        try
          Write(p^, aSize);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      raise Exception.Create(SSimpleXmlError25);
  end;
end;

procedure TBinXmlWriter.WriteWideString(const aValue: WideString);
var
  aLength: LongInt;
begin
  aLength := Length(aValue);
  WriteLongint(aLength);
  if aLength > 0 then
    Write(Pointer(aValue)^, aLength*sizeof(WideChar));
end;


procedure TBinXmlWriter.WriteXmlString(const aValue: TXmlString);
begin
  if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then
    WriteWideString(aValue)
  else
    WriteAnsiString(aValue)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Function Implementation'}{$ENDIF}

function CreateXmlElement(const aName: TXmlString; const aNameTable: IXmlNameTable): IXmlElement;
var
  aNameTableImpl: TXmlNameTable;
begin
  if Assigned(aNameTable) then
    aNameTableImpl := aNameTable.GetObject as TXmlNameTable
  else
    aNameTableImpl := TXmlNameTable.Create(DefaultHashSize);
  Result := TXmlElement.Create(aNameTableImpl, aNameTableImpl.GetID(aName));
end;

function CreateXmlDocument(const aRootElementName: String;
                           const aVersion: String;
                           const anEncoding: String;
                           const aNameTable: IXmlNameTable): IXmlDocument;
var
  aNameTableImpl: TXmlNameTable;
begin
  if Assigned(aNameTable)
  then
    aNameTableImpl := aNameTable.GetObject as TXmlNameTable
  else
    aNameTableImpl := nil;
  Result := TXmlDocument.Create(aNameTableImpl);
  if aRootElementName <> '' then
    Result.NewDocument(aVersion, anEncoding, aRootElementName);
end;

function LoadXmlDocumentFromXML(const aXML: RawByteString): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.LoadXML(aXML);
end;

function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.LoadBinaryXML(aXML);
end;

function LoadXmlDocument(aStream: TStream): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.Load(aStream);
end;

function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
begin
  Result := TXmlDocument.Create;
  Result.Load(aFileName);
end;

function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;
begin
  Result := TXmlDocument.Create;
  Result.LoadResource(aResType, aResName);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}

end.
