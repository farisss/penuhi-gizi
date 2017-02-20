program GeometryGen;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

{$R *.RES}
{$R XP-THEME.RES}

begin

  Application.Initialize;
  Application.Title := 'Geometry Gen';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
