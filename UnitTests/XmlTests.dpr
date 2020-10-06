program XmlTests;

{$IFDEF MSWINDOWS}
  {$APPTYPE CONSOLE}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

uses
  System.SysUtils,
  {$IF Defined(MACOS) or Defined(ANDROID)}
  FMX.Forms,
  DUnitX.Loggers.MobileGUI,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF}
  DUnitX.TestFramework,
  Neslib.Xml.IO in '..\Neslib.Xml.IO.pas',
  Neslib.Xml in '..\Neslib.Xml.pas',
  Neslib.Xml.Types in '..\Neslib.Xml.Types.pas',
  Tests.Neslib.Xml.Base in 'Tests\Tests.Neslib.Xml.Base.pas',
  Tests.Neslib.Xml.IO in 'Tests\Tests.Neslib.Xml.IO.pas',
  Tests.Neslib.Xml in 'Tests\Tests.Neslib.Xml.pas';

{$R *.res}

begin
  TDUnitX.CheckCommandLine;

  {$IF Defined(MACOS) or Defined(ANDROID)}
  Application.Initialize;
  Application.CreateForm(TMobileGUITestRunner, MobileGUITestRunner);
  Application.Run;
  {$ELSE}
  try
    var Runner: ITestRunner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;

    var Logger: ITestLogger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);
    Runner.FailsOnNoAsserts := False;

    var Results: IRunResults := Runner.Execute;
    if (not Results.AllPassed) then
      ExitCode := EXIT_ERRORS;

    if (DebugHook <> 0) and (TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause) then
    begin
      Write('Done.. press <Enter> key to quit.');
      Readln;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  {$ENDIF}
end.
