program BundleTest;

uses
  Forms,
  uTest in 'uTest.pas' {frmMain},
  BundleStruct in '..\Shared\BundleStruct.pas',
  BundleProcs in '..\Shared\BundleProcs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
