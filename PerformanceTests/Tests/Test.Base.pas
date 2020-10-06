unit Test.Base;

interface

type
  TPerfTest = class abstract
  private const
    SAMPLE_FILENAME        = 'nasa.xml';
    EXPECTED_ELEMENTS      = 476646;
    EXPECTED_ATTRIBUTES    = 56317;
    EXPECTED_TEXT_NODES    = 315276;
    EXPECTED_ARCSEC_FIELDS = 3;
  private
    class function GetAllocatedMemory: Int64; static;
  private
    FNumElements: Integer;
    FNumAttributes: Integer;
    FNumTextNodes: Integer;
  protected
    procedure MarkAttribute(const AName, AValue: String); overload;
    procedure MarkAttribute(const AName, AValue: UTF8String); overload;
    procedure MarkAttribute(const AName, AValue: AnsiString); overload;
    procedure MarkElement(const AName: String); overload;
    procedure MarkElement(const AName: UTF8String); overload;
    procedure MarkElement(const AName: AnsiString); overload;
    procedure MarkText(const AText: String); overload;
    procedure MarkText(const AText: UTF8String); overload;
    procedure MarkText(const AText: AnsiString); overload;
  protected
    procedure LoadDocument(const AFilename: String); virtual; abstract;
    procedure TraverseDocument; virtual; abstract;
    function QueryArcsecFields: Integer; virtual; abstract;
    procedure FreeDocument; virtual; abstract;
  public
    class function Title: String; virtual;
  public
    procedure Run;
  end;
  TPerfTestClass = class of TPerfTest;

implementation

uses
  System.SysUtils,
  System.Diagnostics,
  Winapi.Windows,
  Winapi.PsApi;

{ TPerfTest }

class function TPerfTest.GetAllocatedMemory: Int64;
var
  Counters: TProcessMemoryCounters;
begin
  try
    if (GetProcessMemoryInfo(GetCurrentProcess, @Counters, SizeOf(Counters))) then
      Result := Counters.WorkingSetSize
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

procedure TPerfTest.MarkAttribute(const AName, AValue: String);
begin
  Inc(FNumAttributes);
end;

procedure TPerfTest.MarkAttribute(const AName, AValue: UTF8String);
begin
  Inc(FNumAttributes);
end;

procedure TPerfTest.MarkAttribute(const AName, AValue: AnsiString);
begin
  Inc(FNumAttributes);
end;

procedure TPerfTest.MarkElement(const AName: AnsiString);
begin
  Inc(FNumElements);
end;

procedure TPerfTest.MarkElement(const AName: UTF8String);
begin
  Inc(FNumElements);
end;

procedure TPerfTest.MarkElement(const AName: String);
begin
  Inc(FNumElements);
end;

procedure TPerfTest.MarkText(const AText: String);
begin
  Inc(FNumTextNodes);
end;

procedure TPerfTest.MarkText(const AText: UTF8String);
begin
  Inc(FNumTextNodes);
end;

procedure TPerfTest.MarkText(const AText: AnsiString);
begin
  Inc(FNumTextNodes);
end;

procedure TPerfTest.Run;
var
  LoadMS, TraverseMS, QueryMS, FreeMS: Double;
begin
  WriteLn;

  var StartMem := GetAllocatedMemory;
  var Stopwatch := TStopwatch.StartNew;
  LoadDocument(SAMPLE_FILENAME);
  LoadMS := Stopwatch.Elapsed.TotalMilliseconds;
  var EndMem := GetAllocatedMemory;

  WriteLn(Format('Memory usage : %d KB', [(EndMem - StartMem) div 1024]));
  WriteLn(Format('Load time    : %.2f ms', [LoadMS]));

  Stopwatch := TStopwatch.StartNew;
  TraverseDocument;
  TraverseMS := Stopwatch.Elapsed.TotalMilliseconds;

  if (FNumElements <> EXPECTED_ELEMENTS) then
    WriteLn('ERROR: Invalid number of elements (expected=', EXPECTED_ELEMENTS, ', actual=', FNumElements, ')');

  if (FNumAttributes <> EXPECTED_ATTRIBUTES) then
    WriteLn('ERROR: Invalid number of attributes (expected=', EXPECTED_ATTRIBUTES, ', actual=', FNumAttributes, ')');

  if (FNumTextNodes <> EXPECTED_TEXT_NODES) then
    WriteLn('ERROR: Invalid number of text nodes (expected=', EXPECTED_TEXT_NODES, ', actual=', FNumTextNodes, ')');

  WriteLn(Format('Traverse time: %.2f ms', [TraverseMS]));

  Stopwatch := TStopwatch.StartNew;
  var NumArcsecFields := QueryArcsecFields;
  QueryMS := Stopwatch.Elapsed.TotalMilliseconds;

  if (NumArcsecFields <> EXPECTED_ARCSEC_FIELDS) then
    WriteLn('ERROR: Invalid number of "arcsec" fields (expected=', EXPECTED_ARCSEC_FIELDS, ', actual=', NumArcsecFields, ')');

  WriteLn(Format('Query time   : %.2f ms', [QueryMS]));

  Stopwatch := TStopwatch.StartNew;
  FreeDocument;
  FreeMS := Stopwatch.Elapsed.TotalMilliseconds;

  WriteLn(Format('Destroy time : %.2f ms', [FreeMS]));
end;

class function TPerfTest.Title: String;
begin
  Result := ClassName.SubString(9);
end;

end.
