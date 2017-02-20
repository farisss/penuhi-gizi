unit GlobalStrings;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

resourcestring

  AppName = 'Penuhi Gizi!';
  AppGUID = '{F79F44CA-8904-4612-9A06-AFCB8B5196EE}';

  ZenGL_D3D8 = 'ZenGL_D3D8.dll';
  ZenGL_D3D9 = 'ZenGL_D3D9.dll';
  ZenGL_OGL  = 'ZenGL_OGL.dll';

  RescBundle_nm = 'BundRsc.kbd';
  SndsBundle_nm = 'BundSnd.kbd';
  SpchBundle_nm = 'BundSpc.kbd';
  GameInfo_nm   = 'GsInfo.gsd';
  SaveGame_nm   = 'PgSave.dat';
  PrefGame_nm   = 'PgPref.ini';

  scn_Unkn     = '[Unknown]';
  scn_Noth     = '[Idle]';
  scn_Init     = 'Initialization';
  scn_Menu     = 'MainMenu';
  scn_PostPlay = 'PostPlay';
  scn_Play     = 'Play';
  scn_Help     = 'Help';
  scn_Pref     = 'Preferences';
  scn_About    = 'About';

  psc_Role    = 'InRole';
  psc_Kocok   = 'InShake';
  psc_Run     = 'InRun';
  psc_Prop    = 'InProperties';
  psc_Paused  = 'InPaused';
  psc_Game    = 'InGame';
  psc_Gym     = 'InGym';
  psc_SetTrap = 'InSetTrap';
  psc_Travel  = 'InTravel';
  psc_Chance  = 'InChance';
  psc_Lose    = 'InLose';
  psc_Win     = 'InWin';

  cap_Error       = 'Error!';
  cap_AssertError = 'Assertion Error';
  cap_Conf        = 'Konfirmasi';

  msg_AssertMsg     = 'Condition: %s'#13#10'Do you want to continue this program execution?';
  msg_NoLib         = 'Tidak dapat memuat library ZenGL "%s"!';
  msg_NoBund        = 'Tidak dapat memuat bundel data "%s"!';
  msg_NoFBund       = 'Tidak dapat memuat file "%s" yang ada di dalam bundel!';
  msg_NoGsi         = 'Tidak dapat memuat GsInfo "%s"!';
  msg_VrfyErr       = 'Gagal memverifikasi file "%s" dalam bundel "%s", kemungkinan file rusak!';
  msg_CantInitSound = 'Tidak dapat menginisialisasi sound system!';

  msg_IsRunning = 'Game "%s" telah berjalan!';
  msg_ExitConf  = 'Apakah kamu yakin keluar dari game sekarang?';

implementation

end.
