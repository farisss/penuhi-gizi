program GameCfg;

(*==============================================================================

  Project Richman game
  Copyright © Team-R 2014 - 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

{$R *.RES}
{$R XP-THEME.RES}
{$R GameCfgVer.res}

begin
  Application.Initialize;
  Application.Title := 'Game Config';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
