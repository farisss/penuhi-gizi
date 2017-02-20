unit GlobalConst;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

const

  NativeResWi = 1024;
  NativeResHi = 768;
  NativeResW  = 1024.00;
  NativeResH  = 768.00;

  AlphaFadeDelay = 5;
  FlagAnimDelay = 75;

  // Konstanta permainan
  UangPangkal = 150000;

  // Jenis-jenis tempat
  Place_Start      = 0;
  Place_Lahan1     = 1;
  Place_Lahan2     = 2;
  Place_Lahan3     = 3;
  Place_Lahan4     = 4;
  Place_Lahan5     = 5;
  Place_Lahan6     = 6;
  Place_Lahan7     = 7;
  Place_Lahan8     = 8;
  Place_Game       = 9;
  Place_Kesempatan = 10;
  Place_Jebakan    = 11;
  Place_Travel     = 12;
  Place_RumahSakit = 13;
  Place_Minum      = 14;
  Place_Gym        = 15;
  Place_Sumbangan  = 16;

  ListSuppAva:array[0..2] of string = ('*.jpeg', '*.jpg', '*.png');
  ListJnsPkt: array[0..3] of string = ('Lahan', 'Paket 1', 'Paket 2', 'Paket 3');

  ListBtnNm: array[0..5] of string = ('NewGame_%s.png', 'LoadGame_%s.png', 'Help_%s.png', 'Settings_%s.png',
                                      'About_%s.png', 'Exit_%s.png');
  ListPPBtnNm: array[0..1] of string = ('BtnPlay_%s.png', 'BtnPlayAb_%s.png');
  ListBdkNm: array[0..3] of string = ('Bdk_Merah.png', 'Bdk_Kuning.png', 'Bdk_Hijau.png', 'Bdk_Biru.png');
  ListAreNm: array[0..3] of string = ('Area_Red.png', 'Area_Yellow.png', 'Area_Green.png', 'Area_Blue.png');
  ListPnlNm: array[0..3] of string = ('Panel_Merah.png', 'Panel_Kuning.png', 'Panel_Hijau.png', 'Panel_Biru.png');
  ListFlagNm: array[0..3] of string = ('Flag_Red_%d_%d_%d.png', 'Flag_Yellow_%d_%d_%d.png',
                                       'Flag_Green_%d_%d_%d.png', 'Flag_Blue_%d_%d_%d.png');
  ListDlgBtn: array[0..2] of string = ('ChanceYes_%s.png', 'ChanceNo_%s.png', 'ChanceOk_%s.png');
  ListPrpBtn: array[0..1] of string = ('PropOke_%s.png', 'PropSell_%s.png');

  // Harga hadiah jackpot
  ListJackpotRew: array[0..7] of Integer = (10000, 5000, 25000, 75000, 50000, 15000, 17500, 20000);

  PostPrcY: array[0..3] of Single = (276.00, 318.00, 360.00, 402.00);
  JackPrcX: array[0..2] of Single = (51.00, 322.00, 597.00);

  PanelTxX: array[0..3] of Single = (147.00, 742.00, 147.00, 742.00);
  PanelTxY: array[0..3] of Single = (37.00, 37.00, 652.00, 652.00);
  PanelTxYDf = 63.00;

  PostNmTxX: array[0..3] of Single = (237.00, 667.00, 237.00, 667.00);
  PostNmTxY: array[0..3] of Single = (252.00, 252.00, 470.00, 470.00);

  RoleFormX = 363.0;
  RoleFormY = 261.0;

  ShakeFormX = 218.00;
  ShakeFormY = 184.00;

  DlgFormX = 204.0;
  DlgFormY = 205.0;
  DlgTxX = 50.0;
  DlgTxY = 50.0;
  DlgTxW = 500.0;
  DlgTxH = 225.0;

implementation

end.
