program GameEdit;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

{$R *.RES}
{$R XP-THEME.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
