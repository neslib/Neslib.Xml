program XmlPerfTests;

{$APPTYPE CONSOLE}
{$WARN SYMBOL_PLATFORM OFF}

{.$DEFINE USE_DIXML}
{.$DEFINE USE_OXML}

{$R *.res}

uses
  System.SysUtils,
  System.Variants,
  Winapi.ActiveX,
  {$IFDEF USE_DIXML}
  Test.DIXml,
  {$ENDIF }
  {$IFDEF USE_OXML}
  Test.OXmlCDOM,
  Test.OXmlPDOM,
  {$ENDIF }
  Test.Base in 'Tests\Test.Base.pas',
  Test.Delphi in 'Tests\Test.Delphi.pas',
  Neslib.Xml.IO in '..\Neslib.Xml.IO.pas',
  Neslib.Xml in '..\Neslib.Xml.pas',
  Neslib.Xml.Types in '..\Neslib.Xml.Types.pas',
  Test.Neslib in 'Tests\Test.Neslib.pas',
  Test.MSXML in 'Tests\Test.MSXML.pas',
  OmniXML in 'ThirdParty\OmniXml\OmniXML.pas',
  OmniXML_Dictionary in 'ThirdParty\OmniXml\OmniXML_Dictionary.pas',
  OmniXML_Types in 'ThirdParty\OmniXml\OmniXML_Types.pas',
  OmniXML_LookupTables in 'ThirdParty\OmniXml\OmniXML_LookupTables.pas',
  OmniXMLXPath in 'ThirdParty\OmniXml\OmniXMLXPath.pas',
  Test.OmniXML in 'Tests\Test.OmniXML.pas',
  Xml.VerySimple in 'ThirdParty\VerySimpleXml\Xml.VerySimple.pas',
  Test.VerySimpleXml in 'Tests\Test.VerySimpleXml.pas',
  SimpleXML in 'ThirdParty\SimpleXml\SimpleXML.pas',
  Test.SimpleXml in 'Tests\Test.SimpleXml.pas',
  ALStringList in 'ThirdParty\Alcinoe\ALStringList.pas',
  ALXmlDoc in 'ThirdParty\Alcinoe\ALXmlDoc.pas',
  ALAVLBinaryTree in 'ThirdParty\Alcinoe\ALAVLBinaryTree.pas',
  ALQuickSortList in 'ThirdParty\Alcinoe\ALQuickSortList.pas',
  ALString in 'ThirdParty\Alcinoe\ALString.pas',
  ALCommon in 'ThirdParty\Alcinoe\ALCommon.pas',
  ALHTML in 'ThirdParty\Alcinoe\ALHTML.pas',
  ALHttpClient in 'ThirdParty\Alcinoe\ALHttpClient.pas',
  ALMultiPartParser in 'ThirdParty\Alcinoe\ALMultiPartParser.pas',
  ALMime in 'ThirdParty\Alcinoe\ALMime.pas',
  Test.Alcinoe in 'Tests\Test.Alcinoe.pas',
  OmniXmlLng in 'ThirdParty\OmniXml\OmniXmlLng.pas',
  OmniWideSupp in 'ThirdParty\OmniXml\OmniWideSupp.pas',
  OmniEncoding in 'ThirdParty\OmniXml\OmniEncoding.pas',
  OmniTextReadWrite in 'ThirdParty\OmniXml\OmniTextReadWrite.pas',
  OmniBufferedStreams in 'ThirdParty\OmniXml\OmniBufferedStreams.pas';

const
  LIBRARY_COUNT = 7 {$IFDEF USE_DIXML}+1{$ENDIF}{$IFDEF USE_OXML}+2{$ENDIF};

const
  LIBRARIES: array [0..LIBRARY_COUNT - 1] of TPerfTestClass = (
    TPerfTestDelphi,
    TPerfTestMSXML,
    TPerfTestOmniXML,
    TPerfTestVerySimpleXml,
    TPerfTestSimpleXML,
    {$IFDEF USE_DIXML}
    TPerfTestDIXml,
    {$ENDIF}
    TPerfTestAlcinoe,
    {$IFDEF USE_OXML}
    TPerfTestOXmlCDOM,
    TPerfTestOXmlPDOM,
    {$ENDIF}
    TPerfTestNeslib);

procedure Run;
var
  S: String;
  Option: Integer;
begin
  { Initialize COM subsystem (only needed for MSXML) }
  CoInitialize(nil);

  { For libraries that use variants.
    Converts Null variants to empty strings instead of raising an exception. }
  NullStrictConvert := False;

  WriteLn('XML Performance Tests (', SizeOf(Pointer) * 8, '-bits)');
  WriteLn('Select XML library:');

  for var I := 0 to Length(LIBRARIES) - 1 do
    WriteLn('  ', I, '. ', LIBRARIES[I].Title);

//  Option := Length(LIBRARIES) - 1;

  while (True) do
  begin
    WriteLn;
    Write('Enter library number: ');
    ReadLn(S);

    Option := StrToIntDef(S, -1);
    if (Option >= 0) and (Option < LIBRARY_COUNT) then
      Break;

    WriteLn('Invalid option. Please try again.');
  end;{}

  WriteLn('Running test...');
  var Test := LIBRARIES[Option].Create;
  try
    Test.Run;
  finally
    Test.Free;
  end;

  WriteLn;
  WriteLn('Finished!');
end;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    Run;
    if (DebugHook <> 0) then
    begin
      Write('Press [Enter]...');
      ReadLn;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
