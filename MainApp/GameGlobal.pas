unit GameGlobal;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com                                   

==============================================================================*)

interface

{$I AppConf.inc}

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  SysUtils, Classes, Math,
  GlobalConst, GlobalStrings, GlobalTypes, GlobalUtils, GlobalDraw,
  GameInfo, GameSave, GeometryPoint,
  BundleStruct, BundleProcs,
  {$IFDEF ZGLDLL}
  zglHeader,
  {$ELSE}
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_resources,
  zgl_mouse,
  zgl_keyboard,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
  zgl_sprite_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_sound,
  zgl_sound_wav,
  zgl_sound_ogg,
  zgl_math_2d,
  zgl_ini,
  zgl_utils,
  {$ENDIF}
  zglExUtils;

var
  DirApp         : string;                     // Direktori utama game
  GameConf       : TGameConfig;                // Tempat penyimpanan konf. game
  GameRun        : boolean;                    // Game sedang berjalan atau tidak?
  RescBund       : PBundleDefinition;          // Handle dari bundel resource gambar
  SndsBund       : PBundleDefinition;          // Handle dari bundel sound system
  SpchBund       : PBundleDefinition;          // Handle dari bundel speech
  GameScene      : TGameScene;                 // Scene-scene game
  LastScene      : TGameScene;                 // Scene game yang terakhir
  PlayScene      : TPlaySubScene;              // Scene dalam permainan
  LastSPlay      : TPlaySubScene;              // Scene permainan yang terakhir
  BundPath       : string;                     // Lokasi tempat bundel data
  InitAfter      : boolean;                    // Sudah lewat tahap inisialisasi akhir?
  AfterInitAfter : boolean;                    // Setelah init after
  SavedData      : TSaveGame;                  // Tempat buffer game yang tersimpan

  TextBlinkTmr: zglPTimer;
  TextBlink: boolean;

  FWidth, FHeight: Single;
  NWidth, NHeight: LongInt;
  RWidth, RHeight: Single;
  XSc, YSc: LongInt;

  SVolMus: Single = 0.8;
  SVolSfx: Single = 1.0;
  SVolSpc: Single = 1.0;
  LastSpc: integer;

  procedure GameInit;
  procedure GameDraw;
  procedure GameUpdate(dt: Double);
  procedure GameExit;

implementation

var

  // Dialog resources
  DlgForm: TGForm;
  DlgChance: array[0..2] of TGMenuButton;
  DlgTxRect: zglTRect;
  DlgScene: TDialogScene;
  DlgTxVal: string;
  DlgRes: PBoolean;

  // Init resources
  InitTick: Double;
  InitFadeVal: byte;

  // MainMenu Resources
  MainMenuIndex: integer = $FF;
  MainMenuButton: array[0..5] of TGMenuButton;

  // Post-Play Resources
  PostPlayForm: TGForm;
  PostPlayBtns: array[0..1] of TGMenuButton;
  PostPlayAva: array[0..3] of zglTRect;
  NameEditIdx: integer;

  // Help Resources
  HelpForm: TGForm;
  HelpSubForm: array[0..6] of TGForm;
  HelpBackBtn: TGMenuButton;
  HelpSubIdx: ShortInt;

  // Help Resources
  PrefForm: TGForm;
  PrefBackBtn: TGMenuButton;
  PrefSetBtn: array[0..2, 0..1] of TGMenuButton;

  // About Resources
  AboutForm: TGForm;
  AboutBackBtn: TGMenuButton;

  // Play Resources
  MpRect: array[0..39] of zglTRect;             // Posisi pas tiap bidak
  MpSelRect: integer;                           // Indeks lokasi yang sedang dipilih
  Places: PGPlaces;                             // Informasi dasar tempat
  FlagsPos: array[0..39] of zglTRect;           // Posisi bendera tiap tempat
  FlagsAnim: Integer;                           // Posisi animasi bendera
  FlagsInv: Boolean;                            // Kalo true, nilai FlagsAnim ++ dan sebaliknya
  FlagsTmr: zglPTimer;                          // Timer buat animasi diatas
  PlacesOwn: TGPlacesOwner;                     // Kepunyaan Tempat
  Player: TGPlayers;                            // Pemain 4 orang
  PMoney: array[0..3] of LongInt;               // Tampilan animasi uang dalam permainan
  MoneyAnimTmr: zglPTimer;                      // Buat ubah animasi diatas
  PlayerPanel: array[0..3] of TGPlayerPanel;    // Panel deskripsi pemain
  RoleIndex: ShortInt;                          // Indeks pemain yang turun saat ini
  PlayAvaPos: array[0..3] of zglTRect;          // Posisi avatar di panel pemain
  AvaCount: LongInt;                            // Jumlah avatar yang dimuat

  // * Play Sub-Scene Resources *

  // Role
  InRoleForm: TGForm;                           //
  InRoleBtn: array[0..1] of TGMenuButton;       //
  InRoleSel: Byte;                              //
  PlyOutGame: boolean;                          // Pemain nyerah?

  // Kocok Dadu
  ShakeTick: Double;
  InShakeForm: TGForm;
  InShakeStop: TGMenuButton;
  DaduRect: array[0..1] of zglTRect;
  AngkaDadu: array[0..1] of Byte;
  DaduBerturut: Byte = 0;

  // Properti game
  PropForm: TGPropForm;
  PropPlcBtn: array[0..1] of TGMenuButton;
  PropPRect: array[0..3] of zglTRect;
  PropIdx: Byte;
  PropNextAfter: boolean = FALSE;
  PaketIdx: ShortInt;

  // Jackpot game
  JackForm: TGForm;
  JackBtn: array[0..1] of TGMenuButton;
  JackCount: Byte;
  JackRoll: boolean;
  JackIdx: array[0..2] of Byte;
  JackRct: array[0..2] of zglTRect;
  JackStart: Double;
  Jack2St: boolean;

  // Kesempatan
  ChncForm: TGForm;
  ChncBack: TGMenuButton;
  ChncIndex: Byte;
  ChncList: array[0..5] of Byte;

  // Properti menang
  WinIndex: ShortInt;
  WinDlg: boolean;
  WinReason: string;

  // Lain-lain
  LangkahJalan: ShortInt;
  RunTmr: zglPTimer;

  // Resource dasar
  tx_Intro      : zglPTexture;                  // Tekstur logo awal
  tx_Cursor     : zglPTexture;                  // Tekstur cursor
  tx_BgMono     : zglPTexture;                  // Background dasar game
  tx_MonoBoard  : zglPTexture;                  // Tekstur board
  tx_MpSelector : zglPTexture;                  // Penanda pilihan pada papan
  tx_LogoBan    : zglPTexture;                  // Tekstur Logo Menu
  tx_Paused     : zglPTexture;                  // Tekstur teks "Paused"
  tx_Dadu       : array[0..5] of zglPTexture;
  tx_Flags      : array[0..3, 0..2, 0..3, 0..2] of zglPTexture;
  tx_Foods      : array[0..39] of zglPTexture;
  tx_Kesmp      : array[0..6] of zglPTexture;
  tx_JackSlot   : array[0..7] of zglPTexture;
  tx_Avatars    : array of zglPTexture;

  sd_BackSound : zglPSound;                     // Digunakan untuk suara pengiring
  sd_Win       : zglPSound;
  sd_Lose      : zglPSound;
  // SFXs
  sd_Swoosh    : zglPSound;
  sd_Hit       : zglPSound;
  sd_DaduKocok : zglPSound;
  sd_DaduJatuh : zglPSound;
  sd_CashRegs  : zglPSound;
  sd_Ambulan   : zglPSound;
  sd_Coins     : zglPSound;
  sd_Next      : zglPSound;
  sd_Run       : zglPSound;
  sd_Transport : zglPSound;
  sd_Fall      : zglPSound;
  sd_Gym       : zglPSound;
  sd_Drink     : zglPSound;
  sd_JackBegin : zglPSound;
  sd_JackWin   : zglPSound;
  sd_Speech    : array of zglPSound;

  fnt_Bs_12: zglPFont;
  fnt_Bs_18: zglPFont;
  fnt_Bs_20: zglPFont;
  fnt_Bs_24: zglPFont;

  gp_MonoBoard: PGPIHeader;
  gp_MainMenu: PGPIHeader;

//==============================================================================

procedure PlayBackMusic(snd: zglPSound; Loop: boolean = TRUE); inline;
begin

  snd_Play(snd, Loop, 0, 0, 0, SVolMus);

end;

procedure PlaySubMusic(var snd: zglPSound; FileName: string); inline;
begin

  snd_Stop(sd_BackSound, 0);
  snd:= snd_LoadFromBundle(SndsBund, FileName);
  PlayBackMusic(snd, FALSE);

end;

procedure StopSubMusic(var snd: zglPSound); inline;
begin

  snd_Stop(snd, 0);
  snd_Del(snd);
  snd_Play(sd_BackSound, TRUE);

end;

procedure PlaySfx(snd: zglPSound); inline;
begin

  snd_Play(snd, FALSE, 0, 0, 0, SVolSfx);

end;

procedure PlaySpeech(index: integer); inline;
begin

  if snd_Get(sd_Speech[LastSpc], 0, SND_STATE_PLAYING) = 1 then
    snd_Stop(sd_Speech[LastSpc], 0);

  snd_Play(sd_Speech[index], FALSE, 0, 0, 0, SVolSpc);
  LastSpc:= index;

end;

//==============================================================================
procedure SavePreferences;
var
  loc: string;
begin

  loc:= DirApp + PrefGame_nm;

  ini_WriteKeyInt('SoundVolume', 'MusicVol', Round(SVolMus * 100));
  ini_WriteKeyInt('SoundVolume', 'SfxVol', Round(SVolSfx * 100));
  ini_WriteKeyInt('SoundVolume', 'SpeechVol', Round(SVolSpc * 100));

  ini_SaveToFile(loc);
  ini_Free;

end;

procedure LoadPreferences;
var
  loc: string;
begin

  loc:= DirApp + PrefGame_nm;
  ini_LoadFromFile(loc);

  SVolMus:= ini_ReadKeyInt('SoundVolume', 'MusicVol') / 100;
  SVolSfx:= ini_ReadKeyInt('SoundVolume', 'SfxVol') / 100;
  SVolSpc:= ini_ReadKeyInt('SoundVolume', 'SpeechVol') / 100;

  ini_Free;

end;

//==============================================================================
// 0: Volume musik pengiring
// 1: Volume sound effect (SFX)
// 2: Volume speech/pembawa acara :)
procedure IncVolume(VolIdx: integer);
begin

  case VolIdx of

    0: begin
         SVolMus:= SVolMus + 0.01;
         if SVolMus > 1.00 then
           SVolMus:= 1.00;
         snd_SetVolume(sd_BackSound, 0, SVolMus);
       end;

    1: begin
         SVolSfx:= SVolSfx + 0.01;
         if SVolSfx > 1.00 then
           SVolSfx:= 1.00;
       end;

    2: begin
         SVolSpc:= SVolSpc + 0.01;
         if SVolSpc > 1.00 then
           SVolSpc:= 1.00;
       end;

  end;

end;

procedure DecVolume(VolIdx: integer);
begin

  case VolIdx of

    0: begin
         SVolMus:= SVolMus - 0.01;
         if SVolMus < 0.00 then
           SVolMus:= 0.00;
         snd_SetVolume(sd_BackSound, 0, SVolMus);
       end;

    1: begin
         SVolSfx:= SVolSfx - 0.01;
         if SVolSfx < 0.00 then
           SVolSfx:= 0.00;
       end;

    2: begin
         SVolSpc:= SVolSpc - 0.01;
         if SVolSpc < 0.00 then
           SVolSpc:= 0.00;
       end;

  end;

end;

//==============================================================================
procedure KocokKesempatan;
var
  x, i: integer;
  sama: boolean;
begin

  ChncIndex:= 0;
  Randomize;
  for x:= 0 to 5 do
    repeat
      ChncList[x]:= Random(6);
      sama:= FALSE;
      if x > 0 then
        for i:= 0 to x-1 do
          if ChncList[i] = ChncList[x] then
            begin
            sama:= TRUE;
            Break;
          end;
    until not sama;

end;

//==============================================================================
procedure SceneChanged(OldEvent: TGameScene);

  //============================================================================
  function GetSceneName(Scn: TGameScene): string;
  begin

    case Scn of
      gsNothing: Result:= scn_Noth;
      gsInit: Result:= scn_Init;
      gsMenu: Result:= scn_Menu;
      gsPostPlay: Result:= scn_PostPlay;
      gsPlay: Result:= scn_Play;
      gsHelp: Result:= scn_Help;
    else
      Result:= scn_Unkn;
    end;

  end;

  //============================================================================
  procedure AfterInit;
  var
    l: integer;
    nx, ny: integer;
    sr: TSearchRec;
    AvaLoc: string;
    AvaFileList: TStringList;
  begin

    tex_Del(tx_Intro);

    // Load Place
    AssertX(LoadPlacesFromFile(Places, DirApp + GameInfo_nm), Format(msg_NoGsi, [GameInfo_nm]));

    // Load font
    fnt_Bs_12:= font_LoadFromMemory(GetFileFromBundle(RescBund, 'Bs_12pt.zfi'));
    //SetLength(fnt_Bs_12^.Pages, 1);
    fnt_Bs_12^.Pages[0]:= tex_LoadFromBundle(RescBund, 'Bs_12pt-page0.png');

    fnt_Bs_18:= font_LoadFromMemory(GetFileFromBundle(RescBund, 'Bs_18pt.zfi'));
    //SetLength(fnt_Bs_18^.Pages, 1);
    fnt_Bs_18^.Pages[0]:= tex_LoadFromBundle(RescBund, 'Bs_18pt-page0.png');

    fnt_Bs_20:= font_LoadFromMemory(GetFileFromBundle(RescBund, 'Bs_20pt.zfi'));
    //SetLength(fnt_Bs_20^.Pages, 1);
    fnt_Bs_20^.Pages[0]:= tex_LoadFromBundle(RescBund, 'Bs_20pt-page0.png');

    fnt_Bs_24:= font_LoadFromMemory(GetFileFromBundle(RescBund, 'Bs_24pt.zfi'));
    //SetLength(fnt_Bs_20^.Pages, 1);
    fnt_Bs_24^.Pages[0]:= tex_LoadFromBundle(RescBund, 'Bs_24pt-page0.png');

    // Load beberapa resource penting...
    tx_BgMono:= tex_LoadFromBundle(RescBund, 'MonoBg.png');
    tx_MonoBoard:= tex_LoadFromBundle(RescBund, 'MonpBoard.png');
    tx_MpSelector:= tex_LoadFromBundle(RescBund, 'selmb_blue.png');

    // Inisialisasi Dialog untuk semua
    DlgForm.Texture:= tex_LoadFromBundle(RescBund, 'CustDlg.png');
    DlgForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/CustdGm.gpi');
    DlgForm.X:= DlgFormX;
    DlgForm.Y:= DlgFormY;
    DlgForm.W:= DlgForm.Texture^.Width;
    DlgForm.H:= DlgForm.Texture^.Height;

    for l:= 0 to 2 do
      begin
      DlgChance[l].Texture[0]:= tex_LoadFromBundle(RescBund, Format(ListDlgBtn[l], ['Def']));
      DlgChance[l].Texture[1]:= tex_LoadFromBundle(RescBund, Format(ListDlgBtn[l], ['Sel']));
      DlgChance[l].X:= 538 + (110 * Byte(l > 0));
      DlgChance[l].Y:= 490;
      DlgChance[l].W:= DlgChance[l].Texture[0]^.Width;
      DlgChance[l].H:= DlgChance[l].Texture[0]^.Height;
    end;

    DlgTxRect.X:= DlgForm.X + DlgTxX;
    DlgTxRect.Y:= DlgForm.Y + DlgTxY;
    DlgTxRect.W:= DlgTxW;
    DlgTxRect.H:= DlgTxH;

    DlgScene:= dsNone;
    DlgTxVal:= '';

    // Load indeks geometri
    gp_MonoBoard:= LoadGeometryFromFile(DirApp + 'Geometry/BoardGm.gpi');
    for l:= 0 to 39 do
      begin

      GetNearestPoint(gp_MonoBoard, l, nx, ny);

      // Optimalkan lokasi selector
      MpRect[l].X:= nx+1;
      MpRect[l].Y:= ny+1;
      MpRect[l].W:= 90;
      MpRect[l].H:= 62;

      // Juga optimalkan lokasi bendera
      FlagsPos[l].X:= nx - 32;
      FlagsPos[l].Y:= ny - 40;
      FlagsPos[l].W:= 151;
      FlagsPos[l].H:= 105;

    end;

    // load avatar yang tersedia
    AvaLoc:= DirApp + 'Avatar';
    AvaFileList:= TStringList.Create;
    try
      AvaFileList.Clear;
      SetCurrentDir(AvaLoc);
      for l:= 0 to 2 do
        begin
        if FindFirst(ListSuppAva[l], faAnyFile, sr) = 0 then
          begin
          repeat
            {$IFDEF MSWINDOWS}
            AvaFileList.Add(AvaLoc + '\' + sr.Name);
            {$ELSE}
            AvaFileList.Add(AvaLoc + '/' + sr.Name);
            {$ENDIF}
          until FindNext(sr) <> 0;
          FindClose(sr);
        end;
      end;
      AvaCount:= AvaFileList.Count;
      SetLength(tx_Avatars, AvaCount);
      for l:= 0 to AvaCount-1 do
        begin
        tx_Avatars[l]:= tex_LoadFromFile(AvaFileList[l]);
        LogOut(Format('Loaded avatar: %s', [AvaFileList[l]]));
      end;

    finally

      AvaFileList.Free;

    end;

    // Load sound effect (SFXs)
    sd_Swoosh:= snd_LoadFromBundle(SndsBund, 'Swooshing.ogg');
    sd_Hit:= snd_LoadFromBundle(SndsBund, 'Hit.ogg');

  end;

  //============================================================================
  procedure AfterMenu;
  var
    x: integer;
  begin

    tex_Del(tx_logoBan);
    for x:= 0 to 5 do
      begin
      tex_Del(MainMenuButton[x].Texture[0]);
      tex_Del(MainMenuButton[x].Texture[1]);
    end;
    UnloadGeometry(gp_MainMenu);

  end;

  //============================================================================
  procedure AfterPostPlay;
  var
    x: integer;
  begin

    tex_Del(PostPlayForm.Texture);
    UnloadGeometry(PostPlayForm.GeoPoint);
    for x:= 0 to 1 do
      begin
      tex_Del(PostPlayBtns[x].Texture[0]);
      tex_Del(PostPlayBtns[x].Texture[1]);
    end;

    TextBlinkTmr^.Active:= FALSE;

  end;

  //============================================================================
  procedure AfterPlay;
  var
    l: integer;
    h, i, j: integer;
  begin

    MoneyAnimTmr^.Active:= FALSE;

    for l:= 0 to 3 do
      begin

      // Unload bidak, area dan panel
      tex_Del(Player[l].Bidak);
      tex_Del(Player[l].WarnaArea);
      tex_Del(PlayerPanel[l].PanelTex);

      // Load bendera
      for h:= 0 to 2 do // jumlah
        for i:= 0 to 3 do // posisi
          for j:= 0 to 2 do // index ragam bendera
            tex_Del(tx_Flags[l, h, i, j]);

    end;

    // Unload resource sub-scene role
    tex_Del(InRoleForm.Texture);
    UnloadGeometry(InRoleForm.GeoPoint);

    for i:= 0 to 1 do
      begin
      tex_Del(InRoleBtn[i].Texture[0]);
      tex_Del(InRoleBtn[i].Texture[1]);
    end;

    // Unload resource sub-scene kocok dadu
    tex_Del(InShakeForm.Texture);
    UnloadGeometry(InShakeForm.GeoPoint);

    for l:= 0 to 1 do
      tex_Del(InShakeStop.Texture[l]);

    for l:= 0 to 5 do
      tex_Del(tx_Dadu[l]);

    snd_Del(sd_DaduKocok);
    snd_Del(sd_DaduJatuh);

    // resource properties
    for l:= 0 to 7 do
      tex_Del(PropForm.Texture[l]);
    UnloadGeometry(PropForm.GeoPoint);
    
    for l:= 0 to 1 do
      begin
      tex_Del(PropPlcBtn[l].Texture[0]);
      tex_Del(PropPlcBtn[l].Texture[1]);
    end;

    // Gambar makanan di properties
    for l:= 0 to 39 do
      if (Places^[l].Jenis >= Place_Lahan1) and (Places^[l].Jenis <= Place_Lahan8) then
        tex_Del(tx_Foods[l]);

    // jackpot
    tex_Del(JackForm.Texture);
    UnloadGeometry(JackForm.GeoPoint);

    for l:= 0 to 1 do
      for i:= 0 to 1 do
        tex_Del(JackBtn[l].Texture[i]);

    // gambar slot
    for l:= 0 to 7 do
      tex_Del(tx_JackSlot[l]);

    // Kartu kesempatan
    tex_Del(ChncForm.Texture);
    UnloadGeometry(ChncForm.GeoPoint);

    for l:= 0 to 1 do
      tex_Del(ChncBack.Texture[l]);

    for l:= 0 to 5 do
      tex_Del(tx_Kesmp[l]);

    // Matikan timer bendera
    FlagsTmr^.Active:= FALSE;

    // Unload SFXs
    snd_Del(sd_CashRegs);
    snd_Del(sd_Ambulan);
    snd_Del(sd_Coins);
    snd_Del(sd_Next);
    snd_Del(sd_Run);
    snd_Del(sd_Transport);
    snd_Del(sd_Fall);
    snd_Del(sd_Gym);
    snd_Del(sd_Drink);
    snd_Del(sd_JackBegin);
    snd_Del(sd_JackWin);

    // sound speech
    for l:= 0 to SpchBund^.FileOnBundle-1 do
      snd_Del(sd_Speech[l]);
    sd_Speech:= nil;

    snd_Stop(sd_BackSound, 0);
    snd_Del(sd_BackSound);

  end;

  //============================================================================
  procedure AfterHelp;
  var
    l: integer;
  begin

    tex_Del(HelpForm.Texture);
    UnloadGeometry(HelpForm.GeoPoint);
    for l:= 0 to 6 do
      tex_Del(HelpSubForm[l].Texture);
    tex_Del(HelpBackBtn.Texture[0]);
    tex_Del(HelpBackBtn.Texture[1]);

  end;

  //============================================================================
  procedure AfterPreference;
  var
    l: integer;
  begin

    tex_Del(PrefForm.Texture);
    UnloadGeometry(PrefForm.GeoPoint);
    tex_Del(PrefBackBtn.Texture[0]);
    tex_Del(PrefBackBtn.Texture[1]);

    for l:= 0 to 2 do
      begin
      tex_Del(PrefSetBtn[l, 0].Texture[0]);
      tex_Del(PrefSetBtn[l, 0].Texture[1]);
      tex_Del(PrefSetBtn[l, 1].Texture[0]);
      tex_Del(PrefSetBtn[l, 1].Texture[1]);
    end;

  end;

  //============================================================================
  procedure AfterAbout;
  begin

    tex_Del(AboutForm.Texture);
    UnloadGeometry(AboutForm.GeoPoint);
    tex_Del(AboutBackBtn.Texture[0]);
    tex_Del(AboutBackBtn.Texture[1]);

  end;

  //============================================================================
  procedure BeforeInit;
  begin

    tx_Intro:= tex_LoadFromBundle(RescBund, 'intro_ak.png');

  end;

  //============================================================================
  procedure BeforeMenu;
  var
    x: integer;
    hmmn: Double;
  begin

    tx_LogoBan:= tex_LoadFromBundle(RescBund, 'Logo.png');

    // Load tombol main menu
    hmmn:= 192;
    for x:= 0 to 5 do
      begin
      MainMenuButton[x].Texture[0]:= tex_LoadFromBundle(RescBund, Format(ListBtnNm[x], ['Def']));
      MainMenuButton[x].Texture[1]:= tex_LoadFromBundle(RescBund, Format(ListBtnNm[x], ['Sel']));
      MainMenuButton[x].W:= MainMenuButton[x].Texture[0]^.Width;
      MainMenuButton[x].H:= MainMenuButton[x].Texture[0]^.Height;
      MainMenuButton[x].X:= (NativeResW - MainMenuButton[x].W) / 2;
      MainMenuButton[x].Y:= hmmn + (MainMenuButton[x].H / 2);
      hmmn:= hmmn + 81;
    end;

    gp_MainMenu:= LoadGeometryFromFile(DirApp + 'Geometry/MenuGm.gpi');

    // Ganti backsound ke thema menu
    if sd_BackSound = nil then
      begin
      sd_BackSound:= snd_LoadFromBundle(SndsBund, 'ThemeSong.ogg');
      PlayBackMusic(sd_BackSound);
    end;

  end;

  //============================================================================
  procedure BeforePostPlay;
  var
    xi: integer;
    nm: string;
    idx: integer;
    psp: TStringList;
    avidx: integer;
  begin

    PostPlayForm.Texture:= tex_LoadFromBundle(RescBund, 'NewPlayForm.png');
    PostPlayForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/PostpGm.gpi');
    PostPlayForm.X:= (NativeResW - PostPlayForm.Texture^.Width) / 2;
    PostPlayForm.Y:= (NativeResH - PostPlayForm.Texture^.Height) / 2;
    PostPlayForm.W:= PostPlayForm.Texture^.Width;
    PostPlayForm.H:= PostPlayForm.Texture^.Height;
    for xi:= 0 to 1 do
      begin
      PostPlayBtns[xi].Texture[0]:= tex_LoadFromBundle(RescBund, Format(ListPPBtnNm[xi], ['Def']));
      PostPlayBtns[xi].Texture[1]:= tex_LoadFromBundle(RescBund, Format(ListPPBtnNm[xi], ['Sel']));
      PostPlayBtns[xi].W:= PostPlayBtns[xi].Texture[0]^.Width;
      PostPlayBtns[xi].H:= PostPlayBtns[xi].Texture[0]^.Height;
      PostPlayBtns[xi].X:= 702 + (xi*120);
      PostPlayBtns[xi].Y:= 624;
    end;

    // Ganti nama tiap player
    psp:= TStringList.Create;
    try
      LogOut('Opening PlayerList...');
      psp.LoadFromFile(DirApp + 'PlayerList.txt');
      Randomize();
      idx:= Random(psp.Count);
      avidx:= Random(AvaCount);
      for xi:= 0 to 3 do
        begin
        // Lokasi gambar avatar
        PostPlayAva[xi].X:= PostPlayForm.X + 51 + (429 * Byte(xi mod 2));
        PostPlayAva[xi].Y:= PostPlayForm.Y + 141 + (218 * Byte(xi div 2));
        PostPlayAva[xi].W:= 100.00;
        PostPlayAva[xi].H:= 120.00;
        // Nama Player
        u_Sleep(10);
        nm:= psp[idx];
        Inc(idx);
        if idx >= psp.Count then
          idx:= 0;
        StrPCopy(@Player[xi].Nama, nm);
        // avatar
        Player[xi].AvatarIndex:= avidx;
        Inc(avidx);
        if avidx >= AvaCount then
          avidx:= 0;
      end;
    finally
      LogOut('Freeing PlayerList...');
      psp.Free;
    end;

    NameEditIdx:= $FF;
    TextBlinkTmr^.Active:= TRUE;

  end;

  //===========================================================================
  procedure BeforePlay;
  var
    l: integer;
    h, i, j: integer;
    nx, ny: integer;
  begin

    for l:= 0 to 3 do
      begin

      // Load bidak, area dan panel
      Player[l].Bidak:= tex_LoadFromBundle(RescBund, ListBdkNm[l]);
      Player[l].WarnaArea:= tex_LoadFromBundle(RescBund, ListAreNm[l]);

      PlayerPanel[l].PanelTex:= tex_LoadFromBundle(RescBund, ListPnlNm[l]);
      PlayerPanel[l].Rect.X:= (l mod 2) * (NativeResW - PlayerPanel[l].PanelTex^.Width);
      PlayerPanel[l].Rect.Y:= Byte(l > 1) * (NativeResH - PlayerPanel[l].PanelTex^.Height);
      PlayerPanel[l].Rect.W:= PlayerPanel[l].PanelTex^.Width;
      PlayerPanel[l].Rect.H:= PlayerPanel[l].PanelTex^.Height;

      PlayAvaPos[l].X:= 20 + (885 * Byte(l mod 2));
      PlayAvaPos[l].Y:= 12 + (614 * Byte(l div 2));
      PlayAvaPos[l].W:= 100;
      PlayAvaPos[l].H:= 120;

      // Load bendera
      for h:= 0 to 2 do // jumlah
        for i:= 0 to 3 do // posisi
          for j:= 0 to 2 do // index ragam bendera
            tx_Flags[l, h, i, j]:= tex_LoadFromBundle(RescBund, Format(ListFlagNm[l], [h+1, i, j]));

      FlagsTmr^.Active:= TRUE;

    end;

    // Load resource sub-scene role
    InRoleForm.Texture:= tex_LoadFromBundle(RescBund, 'InRole.png');
    InRoleForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/PlaycGm.gpi');
    InRoleForm.X:= RoleFormX;
    InRoleForm.Y:= RoleFormY;
    InRoleForm.W:= InRoleForm.Texture^.Width;
    InRoleForm.H:= InRoleForm.Texture^.Height;

    InRoleBtn[0].Texture[0]:= tex_LoadFromBundle(RescBund, 'kcb_Def.png');
    InRoleBtn[0].Texture[1]:= tex_LoadFromBundle(RescBund, 'kcb_Sel.png');
    InRoleBtn[1].Texture[0]:= tex_LoadFromBundle(RescBund, 'endp_Def.png');
    InRoleBtn[1].Texture[1]:= tex_LoadFromBundle(RescBund, 'endp_Sel.png');

    for i:= 0 to 1 do
      begin
      InRoleBtn[i].X:= 387.00 + ((273.00 - InRoleBtn[i].Texture[0]^.Width) / 2);
      InRoleBtn[i].Y:= 293.00 + (52.00 * i);
      InRoleBtn[i].W:= InRoleBtn[i].Texture[0]^.Width;
      InRoleBtn[i].H:= InRoleBtn[i].Texture[0]^.Height;
    end;

    // Load resource sub-scene kocok dadu
    InShakeForm.Texture:= tex_LoadFromBundle(RescBund, 'DaduForm.png');
    InShakeForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/DaduGm.gpi');
    InShakeForm.X:= ShakeFormX;
    InShakeForm.Y:= ShakeFormY;
    InShakeForm.W:= InShakeForm.Texture^.Width;
    InShakeForm.H:= InShakeForm.Texture^.Height;

    InShakeStop.Texture[0]:= tex_LoadFromBundle(RescBund, 'BtnStop_Def.png');
    InShakeStop.Texture[1]:= tex_LoadFromBundle(RescBund, 'BtnStop_Sel.png');
    GetNearestPoint(InShakeForm.GeoPoint, 0, nx, ny);
    InShakeStop.X:= nx + 8;
    InShakeStop.Y:= ny + 12;
    InShakeStop.W:= InShakeStop.Texture[0]^.Width;
    InShakeStop.H:= InShakeStop.Texture[0]^.Height;

    for l:= 0 to 1 do
      begin
      DaduRect[l].X:= InShakeForm.X + 41.00 + (l*261.00);
      DaduRect[l].Y:= InShakeForm.Y + 48.00;
      DaduRect[l].W:= 256;
      DaduRect[l].H:= 256;
    end;

    for l:= 0 to 5 do
      tx_Dadu[l]:= tex_LoadFromBundle(RescBund, Format('dadu_%d.png', [l+1]));

    sd_DaduKocok:= snd_LoadFromBundle(SndsBund, 'DiceShake.ogg');
    sd_DaduJatuh:= snd_LoadFromBundle(SndsBund, 'DiceThrow.ogg');

    // sekarang load resource properties
    for l:= 0 to 7 do
      PropForm.Texture[l]:= tex_LoadFromBundle(RescBund, Format('PropForm_k%d.png', [l+1]));
    PropForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/FoodGm.gpi');
    PropForm.X:= (NativeResW - PropForm.Texture[0]^.Width) / 2;
    PropForm.Y:= (NativeResH - PropForm.Texture[0]^.Height) / 2;
    PropForm.W:= PropForm.Texture[0]^.Width;
    PropForm.H:= PropForm.Texture[0]^.Height;

    for l:= 0 to 1 do
      begin
      PropPlcBtn[l].Texture[0]:= tex_LoadFromBundle(RescBund, Format(ListPrpBtn[l], ['Def']));
      PropPlcBtn[l].Texture[1]:= tex_LoadFromBundle(RescBund, Format(ListPrpBtn[l], ['Sel']));
      PropPlcBtn[l].X:= PropForm.X + 522.00 + (220.00 * Byte(l = 0));
      PropPlcBtn[l].Y:= PropForm.Y + 540.00;
      PropPlcBtn[l].W:= PropPlcBtn[l].Texture[0]^.Width;
      PropPlcBtn[l].H:= PropPlcBtn[l].Texture[0]^.Height;
    end;

    for l:= 0 to 3 do
      begin
      PropPRect[l].X:= PropForm.X + 390.00;
      PropPRect[l].Y:= PropForm.Y + (PostPrcY[l] - 10.00);
      PropPRect[l].W:= 470.00;
      PropPRect[l].H:= 42.00;
    end;

    // Gambar makanan di properties
    for l:= 0 to 39 do
      if (Places^[l].Jenis >= Place_Lahan1) and (Places^[l].Jenis <= Place_Lahan8) then
        tx_Foods[l]:= tex_LoadFromBundle(RescBund, Format('food_%d.jpg', [l+1]));

    // Load resource jackpot
    JackForm.Texture:= tex_LoadFromBundle(RescBund, 'JackForm.png');
    JackForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/JackGm.gpi');
    JackForm.X:= (NativeResW - JackForm.Texture^.Width) / 2;
    JackForm.Y:= (NativeResH - JackForm.Texture^.Height) / 2;
    JackForm.W:= JackForm.Texture^.Width;
    JackForm.H:= JackForm.Texture^.Height;

    JackBtn[0].Texture[0]:= tex_LoadFromBundle(RescBund, 'BtnRoll_Def.png');
    JackBtn[0].Texture[1]:= tex_LoadFromBundle(RescBund, 'BtnRoll_Sel.png');
    JackBtn[1].Texture[0]:= tex_LoadFromBundle(RescBund, 'BackBtn_Def.png');
    JackBtn[1].Texture[1]:= tex_LoadFromBundle(RescBund, 'BackBtn_Sel.png');
    for l:= 0 to 1 do
      begin
      JackBtn[l].X:= JackForm.X + 710.00;
      JackBtn[l].Y:= JackForm.Y + 400.00;
      JackBtn[l].W:= JackBtn[l].Texture[0]^.Width;
      JackBtn[l].H:= JackBtn[l].Texture[0]^.Height;
    end;

    // gambar slot
    for l:= 0 to 7 do
      tx_JackSlot[l]:= tex_LoadFromBundle(RescBund, Format('jckpt_%d.png', [l]));

    // lokasi slot
    for l:= 0 to 2 do
      begin
      JackRct[l].X:= JackForm.X + JackPrcX[l];
      JackRct[l].Y:= JackForm.Y + 94.00;
      JackRct[l].W:= 256;
      JackRct[l].H:= 256;
    end;

    // resource kesempatan
    ChncForm.Texture:= tex_LoadFromBundle(RescBund, 'ChcForm.png');
    ChncForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/ChncGm.gpi');
    ChncForm.X:= (NativeResW - ChncForm.Texture^.Width) / 2;
    ChncForm.Y:= (NativeResH - ChncForm.Texture^.Height) / 2;
    ChncForm.W:= ChncForm.Texture^.Width;
    ChncForm.H:= ChncForm.Texture^.Height;

    ChncBack.Texture[0]:= tex_LoadFromBundle(RescBund, 'ChanceOk_Def.png');
    ChncBack.Texture[1]:= tex_LoadFromBundle(RescBund, 'ChanceOk_Sel.png');
    ChncBack.W:= ChncBack.Texture[0]^.Width;
    ChncBack.H:= ChncBack.Texture[0]^.Height;
    ChncBack.X:= 768;
    ChncBack.Y:= 624;

    for l:= 0 to 5 do
      tx_Kesmp[l]:= tex_LoadFromBundle(RescBund, Format('ChCard_%d.jpg', [l]));

    // Unload sound theme lama
    snd_Stop(sd_BackSound, 0);
    snd_Del(sd_BackSound);

    // load yang baru di permainan
    sd_Backsound:= snd_LoadFromBundle(SndsBund, 'PlayTheme.ogg');
    PlayBackMusic(sd_Backsound);

    // SFX di permainan
    sd_CashRegs:= snd_LoadFromBundle(SndsBund, 'CashRegist.ogg');
    sd_Ambulan:= snd_LoadFromBundle(SndsBund, 'AmublanceSiren.ogg');
    sd_Coins:= snd_LoadFromBundle(SndsBund, 'GetCoins.ogg');
    sd_Next:= snd_LoadFromBundle(SndsBund, 'OnPlay.ogg');
    sd_Run:= snd_LoadFromBundle(SndsBund, 'TurnMove.ogg');
    sd_Transport:= snd_LoadFromBundle(SndsBund, 'Transport.ogg');
    sd_Fall:= snd_LoadFromBundle(SndsBund, 'FallNCrash.ogg');
    sd_Gym:= snd_LoadFromBundle(SndsBund, 'Gym.ogg');
    sd_Drink:= snd_LoadFromBundle(SndsBund, 'Drinking.ogg');
    sd_JackBegin:= snd_LoadFromBundle(SndsBund, 'PullMachine.ogg');
    sd_JackWin:= snd_LoadFromBundle(SndsBund, 'JackWin.ogg');

    // suara speech
    SetLength(sd_Speech, SpchBund^.FileOnBundle);
    for l:= 0 to SpchBund^.FileOnBundle-1 do
      sd_Speech[l]:= snd_LoadFromBundle(SpchBund, Format('speech_%.3d.ogg', [l+1]));

    // Kocok kesempatan
    KocokKesempatan;

    // Animasi uang yang berkurang atau nambah :)
    for l:= 0 to 3 do
      PMoney[l]:= 0;
    MoneyAnimTmr^.Active:= TRUE;

  end;

  //============================================================================
  procedure BeforeHelp;
  var
    l: integer;
  begin

    // Load petunjuk
    HelpForm.Texture:= tex_LoadFromBundle(RescBund, 'HelpForm.png');
    HelpForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/HelpGm.gpi');
    HelpForm.X:= (NativeResW - HelpForm.Texture^.Width) / 2;
    HelpForm.Y:= (NativeResH - HelpForm.Texture^.Height) / 2;
    HelpForm.W:= HelpForm.Texture^.Width;
    HelpForm.H:= HelpForm.Texture^.Height;

    HelpBackBtn.Texture[0]:= tex_LoadFromBundle(RescBund, 'BackBtn_Def.png');
    HelpBackBtn.Texture[1]:= tex_LoadFromBundle(RescBund, 'BackBtn_Sel.png');
    HelpBackBtn.W:= HelpBackBtn.Texture[0]^.Width;
    HelpBackBtn.H:= HelpBackBtn.Texture[0]^.Height;
    HelpBackBtn.X:= 768;
    HelpBackBtn.Y:= 624;

    for l:= 0 to 6 do
      begin
      HelpSubForm[l].Texture:= tex_LoadFromBundle(RescBund, Format('hlp_%d.png', [l]));
      HelpSubForm[l].X:= HelpForm.X + 40.00;
      HelpSubForm[l].Y:= HelpForm.Y + 75.00;
      HelpSubForm[l].W:= HelpSubForm[l].Texture^.Width;
      HelpSubForm[l].H:= HelpSubForm[l].Texture^.Height;
    end;
    HelpSubIdx:= 0;

  end;

  //============================================================================
  procedure BeforePreference;
  var
    l: integer;
  begin

    // Load preferensi
    PrefForm.Texture:= tex_LoadFromBundle(RescBund, 'PrefForm.png');
    PrefForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/PrefGm.gpi');
    PrefForm.X:= (NativeResW - PrefForm.Texture^.Width) / 2;
    PrefForm.Y:= (NativeResH - PrefForm.Texture^.Height) / 2;
    PrefForm.W:= PrefForm.Texture^.Width;
    PrefForm.H:= PrefForm.Texture^.Height;

    PrefBackBtn.Texture[0]:= tex_LoadFromBundle(RescBund, 'BackBtn_Def.png');
    PrefBackBtn.Texture[1]:= tex_LoadFromBundle(RescBund, 'BackBtn_Sel.png');
    PrefBackBtn.W:= PrefBackBtn.Texture[0]^.Width;
    PrefBackBtn.H:= PrefBackBtn.Texture[0]^.Height;
    PrefBackBtn.X:= 768;
    PrefBackBtn.Y:= 624;

    for l:= 0 to 2 do
      begin

      PrefSetBtn[l, 0].Texture[0]:= tex_LoadFromBundle(RescBund, 'MinusBtn_Def.png');
      PrefSetBtn[l, 0].Texture[1]:= tex_LoadFromBundle(RescBund, 'MinusBtn_Sel.png');
      PrefSetBtn[l, 1].Texture[0]:= tex_LoadFromBundle(RescBund, 'PlusBtn_Def.png');
      PrefSetBtn[l, 1].Texture[1]:= tex_LoadFromBundle(RescBund, 'PlusBtn_Sel.png');

      PrefSetBtn[l, 0].X:= 68 + PrefForm.X;
      PrefSetBtn[l, 0].Y:= 160 + (123 * l) + PrefForm.Y;
      PrefSetBtn[l, 0].W:= 45;
      PrefSetBtn[l, 0].H:= 61;

      PrefSetBtn[l, 1].X:= 800 + PrefForm.X;
      PrefSetBtn[l, 1].Y:= 160 + (123 * l) + PrefForm.Y;
      PrefSetBtn[l, 1].W:= 45;
      PrefSetBtn[l, 1].H:= 61;

    end;

  end;


  //============================================================================
  procedure BeforeAbout;
  begin

    // Load petunjuk
    AboutForm.Texture:= tex_LoadFromBundle(RescBund, 'AboutForm.png');
    AboutForm.GeoPoint:= LoadGeometryFromFile(DirApp + 'Geometry/HelpGm.gpi');
    AboutForm.X:= (NativeResW - AboutForm.Texture^.Width) / 2;
    AboutForm.Y:= (NativeResH - AboutForm.Texture^.Height) / 2;
    AboutForm.W:= AboutForm.Texture^.Width;
    AboutForm.H:= AboutForm.Texture^.Height;

    AboutBackBtn.Texture[0]:= tex_LoadFromBundle(RescBund, 'BackBtn_Def.png');
    AboutBackBtn.Texture[1]:= tex_LoadFromBundle(RescBund, 'BackBtn_Sel.png');
    AboutBackBtn.W:= AboutBackBtn.Texture[0]^.Width;
    AboutBackBtn.H:= AboutBackBtn.Texture[0]^.Height;
    AboutBackBtn.X:= 768;
    AboutBackBtn.Y:= 624;

  end;

  //============================================================================

begin

  // Deinisialisasi scene sebelumnya
  LogOut(Format('*** Leaving from scene "%s" ***', [GetSceneName(OldEvent)]));
  case OldEvent of
    gsInit     : AfterInit();
    gsMenu     : AfterMenu();
    gsPostPlay : AfterPostPlay();
    gsPlay     : AfterPlay();
    gsHelp     : AfterHelp();
    gsPref     : AfterPreference();
    gsAbout    : AfterAbout();
  end;

  LastScene:= OldEvent;

  // Lalu inisialisasikan scene selanjutnya
  LogOut(Format('*** Entering to scene "%s" ***', [GetSceneName(GameScene)]));
  case GameScene of
    gsInit     : BeforeInit();
    gsMenu     : BeforeMenu();
    gsPostPlay : BeforePostPlay();
    gsPlay     : BeforePlay();
    gsHelp     : BeforeHelp();
    gsPref     : BeforePreference();
    gsAbout    : BeforeAbout();
  end;

end;

//==============================================================================
procedure SubPlayChanged(OldScene: TPlaySubScene);

  //============================================================================
  function GetSceneName(Scn: TPlaySubScene): string;
  begin

    case Scn of
      psIdle    : Result:= scn_Noth;
      psRole    : Result:= psc_Role;
      psKocok   : Result:= psc_Kocok;
      psRun     : Result:= psc_Run;
      psProp    : Result:= psc_Prop;
      psPause   : Result:= psc_Paused;
      psGame    : Result:= psc_Game;
      psGym     : Result:= psc_Gym;
      psSetTrap : Result:= psc_SetTrap;
      psTravel  : Result:= psc_Travel;
      psChance  : Result:= psc_Chance;
      psLose    : Result:= psc_Lose;
      psWin     : Result:= psc_Win;
    else
      Result:= scn_Unkn;
    end;

  end;

  //============================================================================
  procedure AfterRole;
  begin

  end;

  //============================================================================
  procedure AfterKocok;
  begin

    snd_Stop(sd_DaduKocok, 0);
    snd_Stop(sd_DaduJatuh, 0);

  end;

  //============================================================================
  procedure AfterRun;
  begin

    RunTmr^.Active:= FALSE;

  end;

  //============================================================================
  procedure AfterProp;
  begin

  end;

  //============================================================================
  procedure AfterPaused;
  begin

    tex_Del(tx_Paused);

  end;

  //============================================================================
  procedure AfterGame;
  begin

  end;

  //============================================================================
  procedure AfterGym;
  begin

  end;

  //============================================================================
  procedure AfterSetTrap;
  begin

  end;

  //============================================================================
  procedure AfterTravel;
  begin

    PlaySfx(sd_Transport);

  end;

  //============================================================================
  procedure AfterChance;
  begin

  end;

  //============================================================================
  procedure AfterLose;
  begin

    StopSubMusic(sd_Lose);

  end;

  //============================================================================
  procedure AfterWin;
  begin

  end;

  //============================================================================
  procedure BeforeRole;
  begin

    if Player[RoleIndex].Uang > 0 then
      begin
      PlaySfx(sd_Next);
      PlaySpeech(RoleIndex);
    end;
    LogOut(Format('Sekarang giliran %s "%s" dari kotak %d', [Player[RoleIndex].Nama, Player[RoleIndex].Nama, Player[RoleIndex].Lokasi]));

  end;

  //============================================================================
  procedure BeforeKocok;
  begin

    snd_Play(sd_DaduKocok, TRUE, 0, 0, 0, SVolSfx);
    ShakeTick:= 0;

  end;

  //============================================================================
  procedure BeforeRun;
  begin

    LangkahJalan:= AngkaDadu[0] + AngkaDadu[1];
    RunTmr^.Active:= TRUE;
    if AngkaDadu[0] <> AngkaDadu[1] then // angka tak sama
      PlaySpeech(2 + AngkaDadu[0] + AngkaDadu[1]) //dari 4=2
    else
      PlaySpeech(14 + AngkaDadu[0]); // dari 15=1

  end;

  //============================================================================
  procedure BeforeProp;
  begin

  end;

  //============================================================================
  procedure BeforePaused;
  begin

    tx_Paused:= tex_LoadFromBundle(RescBund, 'Paused.png');

  end;

  //============================================================================
  procedure BeforeGame;
  begin

    PlaySpeech(36);

  end;

  //============================================================================
  procedure BeforeGym;
  begin

    PlaySpeech(24);

  end;

  //============================================================================
  procedure BeforeSetTrap;
  begin

    //PlaySpeech(22);

  end;

  //============================================================================
  procedure BeforeTravel;
  begin

    PlaySpeech(23);

  end;

  //============================================================================
  procedure BeforeChance;
  begin

    PlaySpeech(21);

  end;

  //============================================================================
  procedure BeforeLose;
  begin

    (*snd_Stop(sd_BackSound, 0);
    PlayBackMusic(sd_Lose);*)

  end;

  //============================================================================
  procedure BeforeWin;
  begin

  end;

  //============================================================================

begin

  res_BeginQueue(0);
  try

    LogOut(Format('*** Leaving from play sub-scene "%s" ***', [GetSceneName(OldScene)]));
    case OldScene of
      psRole    : AfterRole();
      psKocok   : AfterKocok();
      psRun     : AfterRun();
      psProp    : AfterProp();
      psPause   : AfterPaused();
      psGame    : AfterGame();
      psGym     : AfterGym();
      psSetTrap : AfterSetTrap();
      psTravel  : AfterTravel();
      psChance  : AfterChance();
      psLose    : AfterLose();
      psWin     : AfterWin();
    end;

    LastSPlay:= OldScene;

    LogOut(Format('*** Entering to play sub-scene "%s" ***', [GetSceneName(PlayScene)]));
    case PlayScene of
      psRole    : BeforeRole();
      psKocok   : BeforeKocok();
      psRun     : BeforeRun();
      psProp    : BeforeProp();
      psPause   : BeforePaused();
      psGame    : BeforeGame();
      psGym     : BeforeGym();
      psSetTrap : BeforeSetTrap();
      psTravel  : BeforeTravel();
      psChance  : BeforeChance();
      psLose    : BeforeLose();
      psWin     : BeforeWin();
    end;

  finally
    res_EndQueue();
  end;


end;

//==============================================================================
procedure AnimateFlags;
begin

  if (not FlagsInv) then
    begin
    Inc(FlagsAnim);
    if FlagsAnim > 2 then
      begin
      FlagsAnim:= 2;
      FlagsInv:= TRUE;
    end;
  end
  else
    begin
    Dec(FlagsAnim);
    if FlagsAnim < 0 then
      begin
      FlagsAnim:= 0;
      FlagsInv:= FALSE;
    end;
  end;

end;

//==============================================================================
procedure AnimateRun;
begin

  if LangkahJalan > 0 then
    begin
    Dec(LangkahJalan);
    Inc(Player[RoleIndex].Lokasi);
    PlaySfx(sd_Run);
    if Player[RoleIndex].Lokasi > 39 then
      begin
      Player[RoleIndex].Lokasi:= Player[RoleIndex].Lokasi - 40;
      // Tambah Counter putar
      Inc(Player[RoleIndex].Putaran);
      // Dapat uang start disini!
      Inc(Player[RoleIndex].Uang, Places^[0].Harga);
      PlaySfx(sd_CashRegs);
    end;
  end
  else
    LangkahJalan:= -1;

end;

//==============================================================================
procedure AnimateTextEdit;
begin

  TextBlink:= not TextBlink;

end;

//==============================================================================
procedure AnimateMoney;
var
  l: integer;
begin

  for l:= 0 to 3 do
    if Player[l].Uang > PMoney[l] then
      Inc(PMoney[l], 50)
    else
    if Player[l].Uang < PMoney[l] then
      Dec(PMoney[l], 50);

end;

//==============================================================================
procedure ShowDialog(Teks: string; Question: boolean = FALSE; QuestionResult: PBoolean = nil);
begin

  if DlgScene = dsNone then
    begin
    DlgTxVal:= Teks;
    DlgRes:= QuestionResult;
    if Question then
      DlgScene:= dsQuest
    else
      DlgScene:= dsInfo;
    LogOut('Dialog: ' + Teks);
  end;

end;

//==============================================================================
procedure NewGame;
var
  l: integer;
begin

  for l:= 0 to 3 do
    begin
    Player[l].Play:= TRUE;
    Player[l].Lokasi:= 0;
    Player[l].Uang:= UangPangkal;
    Player[l].Putaran:= 0;
    Player[l].DiRumahSakit:= 0;
  end;

  for l:= 0 to 39 do
    begin
    PlacesOwn[l].IndexPemain:= -1;
    PlacesOwn[l].Paket:= 0;
    PlacesOwn[l].BonusGym:= FALSE;
  end;

  GameScene:= gsPlay;
  // Ke idle sebelum role, untuk menginisialisasi objek
  PlayScene:= psIdle;
  Randomize();
  RoleIndex:= Random(4);

end;

//==============================================================================
procedure LoadGame;
var
  loc: string;
  l: integer;
begin

  loc:= DirApp + SaveGame_nm;
  if FileExists(loc) then
    begin
    if LoadGameData(SavedData, loc) then
      begin

      // Mulai meload game
      RoleIndex:= SavedData.State.OnRoleIndex;
      PlayScene:= SavedData.State.SubScene;

      for l:= 0 to 3 do
        Player[l]:= SavedData.Player[l];

      for l:= 0 to 39 do
        PlacesOwn[l]:= SavedData.PlacesOwn[l];

      GameScene:= gsPlay;

    end
    else
      ShowDialog('Data permainan tersimpan tidak valid!');
  end
  else
    ShowDialog('Tidak ada permainan yang tersimpan!');

end;

//==============================================================================
procedure SaveGame;
var
  loc: string;
  l: integer;
begin

  // Mulai save game
  SavedData.State.OnRoleIndex:= RoleIndex;
  if PlayScene = psPause then
    SavedData.State.SubScene:= LastSPlay
  else
    SavedData.State.SubScene:= PlayScene;

  for l:= 0 to 3 do
    SavedData.Player[l]:= Player[l];

  for l:= 0 to 39 do
    SavedData.PlacesOwn[l]:= PlacesOwn[l];

  loc:= DirApp + SaveGame_nm;
  if not SaveGameData(SavedData, loc) then
    ShowDialog('Tidak dapat menyimpan data permainan!');

end;

//==============================================================================
procedure BukaProperti(Index: Byte; NextAfter: boolean= FALSE);
begin

  PropIdx:= Index;
  PropNextAfter:= NextAfter;
  PlayScene:= psProp;

end;

//==============================================================================
procedure MasukRumahSakit;
begin

  Player[RoleIndex].DiRumahSakit:= 3;      // masukan 3 sebagai jumlah putaran yg dilewatkan!
  Player[RoleIndex].Lokasi:= 10;           // lokasi rumah sakit

end;

//==============================================================================
procedure SetMenang(Index: integer; Reason: string);
begin

  WinDlg:= FALSE;
  WinIndex:= Index;
  WinReason:= Reason;
  PlayScene:= psWin;

end;

//==============================================================================
procedure NextRole;

  procedure CheckPemain;
  var
    l, chk, p: integer;
  begin

    // cari player selanjutnya
    repeat
      Inc(RoleIndex);
      if RoleIndex > 3 then
        RoleIndex:= 0;
    until Player[RoleIndex].Play;

    // check masih ada player yang lain?
    chk:= 0;
    p:= 0;
    for l:= 0 to 3 do
      if Player[l].Play then
        begin
        Inc(chk);
        p:= l;
      end;

    if chk > 1 then // Masih ada pemain lain
      PlayScene:= psRole
    else
      SetMenang(p, 'Karena pemain lainnya telah kalah');

  end;

var
  l: integer;
  air, att: integer;
  sehat: array[0..4] of boolean; // 4 sehat 5 sempurna
  ass: boolean;
begin

  // set menang jika sudah memenuhi air minum
  air:= 0;
  att:= 0;
  for l:= 0 to 4 do
    sehat[l]:= FALSE;
  for l:= 0 to 39 do
    begin
    // 4 sehat 5 sempurna
    if (Places^[l].Jenis >= Place_Lahan1) and (Places^[l].Jenis <= Place_Lahan8) then
      begin
      if PlacesOwn[l].IndexPemain = RoleIndex then
        sehat[Places^[l].Pangan - 1]:= TRUE;
    end;
    // air
    if Places^[l].Jenis = Place_Minum then
      begin
      Inc(att);
      if PlacesOwn[l].IndexPemain = RoleIndex then
        Inc(air);
    end;
  end;

  if (sehat[0] = sehat[1]) and (sehat[1] = sehat[2]) and (sehat[2] = sehat[3]) and
     (sehat[3] = sehat[4]) and (sehat[4] = TRUE) then
    begin

    // Langsung menang
    SetMenang(RoleIndex, 'Karena telah memenuhi 4 sehat 5 sempurna');

  end
  else
  if air = att then // air dilibas habis :)
    begin

    // Langsung menang
    SetMenang(RoleIndex, 'Karena telah menguasai keempat depot air');

  end
  else
    begin

    if Player[RoleIndex].Uang >= 0 then // Player cukup uang?
      CheckPemain
    else
      begin // Player bangkrut?

      // Cek pemain masih punya asset?
      ass:= FALSE;
      for l:= 0 to 39 do
        if PlacesOwn[l].IndexPemain = RoleIndex then
          begin
          ass:= TRUE;
          Break;
        end;
      if ass then
        begin
        ShowDialog('Silahkan jual asset yang kamu punya karena kamu terlilit hutang!');
        PlayScene:= psRole;
      end
      else
        begin
        ShowDialog(Format('%s (Pemain %d) harus keluar karena bangkrut dan tidak dapat membayar hutang-hutang!', [Player[RoleIndex].Nama, RoleIndex+1]));
        Player[RoleIndex].Play:= FALSE;
        CheckPemain;
      end;

    end;

  end;

end;

//==============================================================================
procedure HasRun;
var
  CurTyp, CurLoc: Byte;
  ChgMode: boolean;
  bsewa: LongInt;
  l: integer;
  kmpl, a, o: integer;
  kgym: boolean;
begin

  ChgMode:= FALSE;
  CurTyp:= Places^[Player[RoleIndex].Lokasi].Jenis;
  CurLoc:= Player[RoleIndex].Lokasi;
  case CurTyp of

    // Di kotak Start
    Place_Start:
      begin

        ShowDialog('Kamu melewati start!');

      end;

    // Di kotak game
    Place_Game:
      begin

        for l:= 0 to 2 do
          JackIdx[l]:= 3; // 7-7-7!
        JackCount:= 0;
        PlayScene:= psGame;
        ChgMode:= TRUE;

      end;

    // Di kotak kesempatan
    Place_Kesempatan:
      begin

        PlayScene:= psChance;
        ChgMode:= TRUE;

      end;

    // Di kotak jebakan
    Place_Jebakan:
      begin

        if PlacesOwn[CurLoc].IndexPemain = -1 then
          begin
          PlaySpeech(22);
          ShowDialog('Silahkan pasang jebakan untuk pemain lainnya!');
          PlayScene:= psSetTrap;
          ChgMode:= TRUE;
        end
        else
          begin
          PlaySfx(sd_Fall);
          PlaySpeech(31);
          if PlacesOwn[CurLoc].IndexPemain <> RoleIndex then
            ShowDialog('Kamu masuk dalam jebakan yang dipasang lawan!')
          else
            ShowDialog('Kamu masuk dalam jebakan yang kamu pasang sendiri!');
          Player[RoleIndex].Lokasi:= PlacesOwn[CurLoc].Paket;
          PlacesOwn[CurLoc].IndexPemain:= -1;
          PlacesOwn[CurLoc].Paket:= 0;
          ChgMode:= TRUE;
          HasRun();
        end;

      end;

    // Di kotak travel
    Place_Travel:
      begin

        ShowDialog('Pilih tempat yang ingin kamu kunjungi!');
        PlayScene:= psTravel;
        ChgMode:= TRUE;

      end;

    // Di kotak Rumah Sakit
    Place_RumahSakit:
      begin

        PlaySfx(sd_Ambulan);
        if AngkaDadu[0] = AngkaDadu[1] then
          PlaySpeech(41)
        else
          PlaySpeech(25);
        ShowDialog('Kamu menetetap di rumah sakit karena sakit!');
        MasukRumahSakit();

      end;

    // Di kotak minum aer
    Place_Minum:
      begin

        PlacesOwn[CurLoc].IndexPemain:= RoleIndex;
        PlaySfx(sd_Drink);
        ShowDialog('Kamu menguasai air minum disini, segera cukupi kebutuhan air minum dengan minum ditempat lainnya!');

      end;

    // Di kotak GYM
    Place_Gym:
      begin

        kgym:= FALSE;
        for l:= 0 to 39 do
          if PlacesOwn[l].IndexPemain = RoleIndex then
            begin
            kgym:= TRUE;
            Break;
          end;
        if kgym then
          begin
          PlaySfx(sd_Gym);
          ShowDialog('Kamu mendapatkan kesempatan untuk kebugaran badan di Gym! Pilih tempat milikmu yang ingin kamu bina!');
          PlayScene:= psGym;
          ChgMode:= TRUE;
        end
        else
          ShowDialog('Kamu tidak mempunyai pangan untuk dibina!');

      end;

    // Di kotak sumbangan
    Place_Sumbangan:
      begin

        PlaySfx(sd_Coins);
        PlaySpeech(30);
        ShowDialog(Format('Kamu harus membayar sumbangan sebesar Rp %d,-!',
                          [Places^[CurLoc].Harga]));
        // kurangi duit karena bayar sumbangan
        Dec(Player[RoleIndex].Uang, Places^[CurLoc].Harga);

      end;

  else

    // Kalo dalam kotak makanan
    if (CurTyp >= Place_Lahan1) and (CurTyp <= Place_Lahan8) then
      begin

      if PlacesOwn[CurLoc].IndexPemain = -1 then
        begin
        // tidak ada pemilik! silahkan beli...
        BukaProperti(CurLoc, TRUE);
        ChgMode:= TRUE;
      end
      else
        begin
        // Bukan pemain yang punya?
        if PlacesOwn[CurLoc].IndexPemain <> RoleIndex then
          begin
          // biaya awal sewa
          bsewa:= Places^[CurLoc].Sewa[PlacesOwn[CurLoc].Paket];
          // pernah ikut pembinaan gym? + %50 dari harga sewa asli
          if PlacesOwn[CurLoc].BonusGym then
            bsewa:= bsewa + (bsewa div 2);
          // Kali lipat jika sama komplek dikuasai
          kmpl:= Places^[CurLoc].Jenis;
          a:= 0;
          o:= 0;
          for l:= 0 to 39 do
            if Places^[l].Jenis = kmpl then
              begin
              Inc(a);
              if PlacesOwn[l].IndexPemain = PlacesOwn[CurLoc].IndexPemain then
                Inc(o);
            end;
          PlaySfx(sd_Coins);
          if a = o then
            begin
            PlaySpeech(32);
            bsewa:= bsewa * 2;
          end;
          ShowDialog(Format('Kamu harus membayar sewa "%s" kepada %s sebesar Rp %d,-!',
                            [Places^[CurLoc].Nama, Player[PlacesOwn[CurLoc].IndexPemain].Nama, bsewa]));
          Inc(Player[PlacesOwn[CurLoc].IndexPemain].Uang, bsewa);
          if Player[RoleIndex].BebasSewa then
            Player[RoleIndex].BebasSewa:= FALSE
          else
            Dec(Player[RoleIndex].Uang, bsewa);
        end
        else // pemain yang punya?
          begin
          BukaProperti(CurLoc, TRUE);
          ChgMode:= TRUE;
        end;
      end;

    end;

  end;

  if not ChgMode then
    NextRole;

end;

//==============================================================================
procedure ProsesKesempatan(Index: Integer);
var
  l: integer;
begin

  case Index of

    // busung lapar
    0:
      begin
        PlaySpeech(25);
        MasukRumahSakit;
        HasRun;
      end;

    // obesitas
    1:
      begin
        MasukRumahSakit;
        HasRun;
      end;

    // Kartu Olahraga
    2:
      begin
        for l:= 0 to 39 do
          if PlacesOwn[l].IndexPemain = RoleIndex then
            PlacesOwn[l].BonusGym:= TRUE;
        NextRole;
      end;

    // parkir bebas
    3:
      begin
        PlaySpeech(23);
        PlayScene:= psTravel;
        //NextRole;
      end;

    // bebas sewa
    4:
      begin
        Player[RoleIndex].BebasSewa:= TRUE;
        NextRole;
      end;

    // sumbang makanan
    5:
      begin
        PlaySfx(sd_Coins);
        PlaySpeech(30);
        Dec(Player[RoleIndex].Uang, 20000);
        NextRole;
      end;
      
  end;

end;

//==============================================================================
procedure PlayerOut(Index: Integer);
var
  l: integer;
  Ass: LongInt;
begin

  // Jual semua asset ke kementrian
  Ass:= 0;
  for l:= 0 to 39 do
    if PlacesOwn[l].IndexPemain = Index then
      begin
      // Agregasi harga asset yang dimiliki
      Ass:= Ass + Places^[l].Jual[PlacesOwn[l].Paket];
      // Set ke default
      PlacesOwn[l].Paket:= 0;
      PlacesOwn[l].IndexPemain:= -1;
      PlacesOwn[l].BonusGym:= FALSE;
    end;
  PlaySubMusic(sd_Lose, 'Lose.ogg');
  ShowDialog(Format('%s (Pemain %d) kalah, dan telah keluar dari permainan!' + #13#10 +
                    'Total asset: Rp %d,-', [Player[Index].Nama, Index+1, Ass]));
  PlaySpeech(26+RoleIndex);
  Player[Index].Play:= FALSE;
  PlayScene:= psLose;

end;

//==============================================================================

procedure GameInit;

  procedure OpenBundle(var BundHandle: PBundleDefinition; FileName: string);
  var
    bstruct: PBundleFile;
    BundPath: WideString;
    fpos: string;
    l: integer;
  begin

    BundPath:= DirApp + FileName;
    LogOut('Assign Bundle: ' + BundPath);
    BundHandle:= AssignReadBundle(PWideChar(BundPath));
    AssertX(BundHandle <> nil, Format(msg_NoBund, [FileName]));

    LogOut(Format('Verify bundle data, found %d files.', [BundHandle^.FileOnBundle]));
    for l:= 0 to BundHandle^.FileOnBundle-1 do
      begin
      bstruct:= GetFileStruct(BundHandle, l);
      fpos:= bstruct^.BundleName;
      LogOut(Format('Verify file: %s; size: %d', [fpos, bstruct^.BundleSize]));
      AssertX(VerifyBundleFileChecksum(BundHandle, l), Format(msg_VrfyErr, [fpos, FileName]));
    end;
    LogOut(Format('Data verification for file "%s" finished!', [FileName]));

  end;

var
  sw, sh, sl, st: Single;
begin

  GameRun:= TRUE;
  wnd_ShowCursor(FALSE);
  GameScene:= gsNothing;

  // FPU-friendly width & height
  FWidth:= GameConf.DispWidth;
  FHeight:= GameConf.DispHeight;
  // Rasio perbandingan screen
  RWidth:= FWidth / NativeResW;
  RHeight:= FHeight / NativeResH;
  AspectRatio(FWidth, FHeight, NativeResW, NativeResH, sw, sh, sl, st);
  NWidth:= Round(sw);
  NHeight:= Round(sh);
  XSc:= Round(sl);
  YSc:= Round(st);
  SetupScreenScale(FWidth, FHeight);

  // sometimes, delphi 6 can't parse this!
  {$IFDEF VER140}
  DirApp:= ExtractFilePath(ParamStr(0));
  {$ELSE}
  DirApp:= PChar(zgl_Get(DIRECTORY_APPLICATION));
  {$ENDIF}

  // Verifikasi file bundle
  OpenBundle(RescBund, RescBundle_nm);
  OpenBundle(SndsBund, SndsBundle_nm);
  OpenBundle(SpchBund, SpchBundle_nm);

  // Inisialisasi sound system
  if (GameConf.SoundOn) then
    begin
    LogOut('Initialize sound system...');
    AssertX(snd_Init(), msg_CantInitSound);
    snd_Add(16);
  end;

  // Inisialisasi logo awal dan kursor
  tx_Cursor:= tex_LoadFromBundle(RescBund, 'curss.png');

  // Inisialisasi timer
  FlagsTmr:= timer_Add(@AnimateFlags, FlagAnimDelay);
  FlagsTmr^.Active:= FALSE;
  RunTmr:= timer_Add(@AnimateRun, 500);
  RunTmr^.Active:= FALSE;
  TextBlinkTmr:= timer_Add(@AnimateTextEdit, 500);
  TextBlinkTmr^.Active:= FALSE;
  MoneyAnimTmr:= timer_Add(@AnimateMoney, 5);
  MoneyAnimTmr^.Active:= FALSE;

  // Baca pengaturan
  LoadPreferences;

  // Inisialisasi pertama selesai
  LogOut('Post initialization finish!');
  InitAfter:= FALSE;

end;

//=== Rutin Penggambaran =======================================================

procedure GameDraw;

  //=== Penggambaran ketika inisialisasi =======================================
  procedure InitDraw;
  begin

    if (GameConf.DispWidth > 640) and (GameConf.DispHeight > 480) then
      ssprite2d_Draw(tx_Intro, (FWidth-800.00) / 2, (FHeight-600.00) / 2, 800, 600, 0, InitFadeVal, FX_BLEND)
    else
      ssprite2d_Draw(tx_Intro, 0, 0, FWidth, FHeight, 0, InitFadeVal, FX_BLEND);

  end;

  //=== Penggambaran utama =====================================================
  procedure MainDraw;

    //==========================================================================
    procedure MenuSubDraw;
    var
      xi: integer;
    begin

      LayarGelap;

      // gambarkan logo menu utama
      ssprite2d_DrawSc(tx_LogoBan, (NativeResW - 622) / 2, YSc + 48, 622, 140, 0, $FF, FX_BLEND);

      // gambarkan list menu
      for xi:= 0 to 5 do
        with MainMenuButton[xi] do
          ssprite2d_DrawSc(Texture[Byte(MainMenuIndex = xi) and 1], X, Y, W, H, 0, $FF, FX_BLEND);

    end;

    //==========================================================================
    procedure PostPlaySubDraw;
    var
      xi: integer;
    begin

      // buat layar agak gelap
      LayarGelap;

      ssprite2d_DrawSc(PostPlayForm.Texture, PostPlayForm.X, PostPlayForm.Y, PostPlayForm.W, PostPlayForm.H, 0, $FF, FX_BLEND);

      for xi:= 0 to 3 do
        begin
        // gambar avatar
        ssprite2d_DrawSc(tx_Avatars[Player[xi].AvatarIndex], PostPlayAva[xi].X, PostPlayAva[xi].Y, PostPlayAva[xi].W, PostPlayAva[xi].H, 0, $FF, FX_BLEND);
        // tulis nama pemain
        if (xi = NameEditIdx) and not(TextBlink) then
          TulisTeks(Player[xi].Nama + '|', fnt_Bs_18, PostNmTxX[xi], PostNmTxY[xi])
        else
          TulisTeks(Player[xi].Nama, fnt_Bs_18, PostNmTxX[xi], PostNmTxY[xi]);
      end;
      for xi:= 0 to 1 do
        with PostPlayBtns[xi] do
          ssprite2d_DrawSc(Texture[Byte(PostPlayForm.SelIndex = xi) and 1], X, Y, W, H, 0, $FF, FX_BLEND);

    end;

    //==========================================================================
    procedure PlaySubDraw;

      //========================================================================
      procedure DrawFlag(IndexLok, Pos: integer);
      begin

        if (Places^[IndexLok].Jenis >= Place_Lahan1) and (Places^[IndexLok].Jenis <= Place_Lahan8) then
          if PlacesOwn[IndexLok].Paket > 0 then
            ssprite2d_DrawSc(tx_Flags[PlacesOwn[IndexLok].IndexPemain, PlacesOwn[IndexLok].Paket-1, Pos, FlagsAnim], FlagsPos[IndexLok].X, FlagsPos[IndexLok].Y, FlagsPos[IndexLok].W, FlagsPos[IndexLok].H, 0, $FF, FX_BLEND);

      end;

      //========================================================================
      procedure PauseSubDraw;
      begin

        LayarGelap;

        ssprite2d_DrawSc(tx_Paused, ((NativeResW - 303) / 2), ((NativeResH - 78) / 2), 303, 78, 0, $FF, FX_BLEND);

        TulisHint('Esc: Kembali ke permainan, Space: Keluar', fnt_Bs_12, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure RoleSubDraw;
      var
        l: integer;
      begin

        if Player[RoleIndex].Uang >= 0 then
          begin

          ssprite2d_DrawSc(InRoleForm.Texture, InRoleForm.X, InRoleForm.Y, InRoleForm.W, InRoleForm.H, 0, $FF, FX_BLEND);
          for l:= 0 to 1 do
            ssprite2d_DrawSc(InRoleBtn[l].Texture[Byte(l = InRoleSel) and 1], InRoleBtn[l].X, InRoleBtn[l].Y, InRoleBtn[l].W, InRoleBtn[l].H, 0, $FF, FX_BLEND);

          TulisStatus(Format('Sekarang giliran %s!', [Player[RoleIndex].Nama]), fnt_Bs_20, NativeResW, NativeResH);

        end
        else
          begin

          TulisStatus('Pilih asset kamu yang ingin kamu jual!', fnt_Bs_20, NativeResW, NativeResH);

        end;

      end;

      //========================================================================
      procedure KocokSubDraw;
      var
        l: integer;
      begin

        LayarGelap;

        // Gambar tampilan form dadu
        ssprite2d_DrawSc(InShakeForm.Texture, InShakeForm.X, InShakeForm.Y, InShakeForm.W, InShakeForm.H, 0, $FF, FX_BLEND);

        // Gambar Dadu saat ini
        for l:= 0 to 1 do
          ssprite2d_DrawSc(tx_Dadu[AngkaDadu[l]-1], DaduRect[l].X, DaduRect[l].Y, DaduRect[l].W, DaduRect[l].H, 0, $FF, FX_BLEND);

        // Gambar tombol hentikan!
        ssprite2d_DrawSc(InShakeStop.Texture[Byte(InShakeForm.SelIndex = 0) and 1], InShakeStop.X, InShakeStop.Y, InShakeStop.W, InShakeStop.H, 0, $FF, FX_BLEND);

      end;

      //========================================================================
      procedure RunSubDraw;
      begin

        TulisStatus(Format('%s maju %d langkah.', [Player[RoleIndex].Nama, AngkaDadu[0] + AngkaDadu[1]]), fnt_Bs_20, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure PropSubDraw;
      var
        Pemilik: string;
        l: integer;
        bpkt: integer;
        kmpl: integer;
      begin

        LayarGelap;

        // Form properti
        kmpl:= Places^[PropIdx].Jenis - Place_Lahan1;
        ssprite2d_DrawSc(PropForm.Texture[kmpl], PropForm.X, PropForm.Y, PropForm.W, PropForm.H, 0, $FF, FX_BLEND);

        // Gambar pangan
        ssprite2d_DrawSc(tx_Foods[PropIdx], PropForm.X + 56, PropForm.Y + 85, 298 , 436 , 0, $FF, FX_BLEND);

        // Nama tempat
        TulisTeks(Places^[PropIdx].Nama, fnt_Bs_24, PropForm.X + 400.00, PropForm.Y + 124.00);

        // Harga tempat
        if (PlacesOwn[PropIdx].IndexPemain >= 0) then
          begin
          bpkt:= PlacesOwn[PropIdx].Paket;
          pr2d_RectSc(PropPRect[bpkt].X, PropPRect[bpkt].Y, PropPRect[bpkt].W, PropPRect[bpkt].H, $008A00, 127, PR2D_FILL);
        end;
        for l:= 0 to 3 do
          begin
          if (l = PaketIdx) then
            if (PlacesOwn[PropIdx].IndexPemain = RoleIndex) or (PlacesOwn[PropIdx].IndexPemain = -1) then
              pr2d_RectSc(PropPRect[PaketIdx].X, PropPRect[PaketIdx].Y, PropPRect[PaketIdx].W, PropPRect[PaketIdx].H, $008AFF, 127, PR2D_FILL);
          TulisTeks(ListJnsPkt[l], fnt_Bs_20, PropForm.X + 420.00, PropForm.Y + PostPrcY[l]);
          TulisTeks(IntToStr(Places^[PropIdx].Beli[l]), fnt_Bs_20, PropForm.X + 550.00, PropForm.Y + PostPrcY[l]);
          TulisTeks(IntToStr(Places^[PropIdx].Jual[l]), fnt_Bs_20, PropForm.X + 660.00, PropForm.Y + PostPrcY[l]);
          TulisTeks(IntToStr(Places^[PropIdx].Sewa[l]), fnt_Bs_20, PropForm.X + 770.00, PropForm.Y + PostPrcY[l]);
        end;
        // Pemilik tempat
        if PlacesOwn[PropIdx].IndexPemain <> -1 then
          Pemilik:= Format('%s (Pemain %d)', [Player[PlacesOwn[PropIdx].IndexPemain].Nama, PlacesOwn[PropIdx].IndexPemain+1])
        else
          Pemilik:= 'Tidak ada!';
        TulisTeks(Pemilik, fnt_Bs_24, PropForm.X + 400.00, PropForm.Y + 494.00);

        // Gambar tombol
        ssprite2d_DrawSc(PropPlcBtn[0].Texture[Byte(PropForm.SelIndex = 0) and 1], PropPlcBtn[0].X, PropPlcBtn[0].Y, PropPlcBtn[0].W, PropPlcBtn[0].H, 0, $FF, FX_BLEND);
        if PlacesOwn[PropIdx].IndexPemain = RoleIndex then
          ssprite2d_DrawSc(PropPlcBtn[1].Texture[Byte(PropForm.SelIndex = 1) and 1], PropPlcBtn[1].X, PropPlcBtn[1].Y, PropPlcBtn[1].W, PropPlcBtn[1].H, 0, $FF, FX_BLEND);

        TulisHint(Format('Uang kamu Rp %d,- dan kamu sudah putaran ke %d.', [Player[RoleIndex].Uang, Player[RoleIndex].Putaran]), fnt_Bs_12, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure GameSubDraw;
      var
        l: integer;
      begin

        LayarGelap;

        // Form jackpot
        ssprite2d_DrawSc(JackForm.Texture, JackForm.X, JackForm.Y, JackForm.W, JackForm.H, 0, $FF, FX_BLEND);

        // gambar slot
        for l:= 0 to 2 do
          ssprite2d_DrawSc(tx_JackSlot[JackIdx[l]], JackRct[l].X, JackRct[l].Y, JackRct[l].W, JackRct[l].H, 0, $FF, FX_BLEND);

        if not JackRoll then
          begin
          if JackCount >= 3 then
            ssprite2d_DrawSc(JackBtn[1].Texture[Byte(JackForm.SelIndex = 0) and 1], JackBtn[1].X, JackBtn[1].Y, JackBtn[1].W, JackBtn[1].H, 0, $FF, FX_BLEND)
          else
            ssprite2d_DrawSc(JackBtn[0].Texture[Byte(JackForm.SelIndex = 0) and 1], JackBtn[0].X, JackBtn[0].Y, JackBtn[0].W, JackBtn[0].H, 0, $FF, FX_BLEND);
        end;
        
      end;

      //========================================================================

      procedure GymSubDraw;
      begin

        TulisStatus('Pilih tempat yang ingin kamu bina di Gym!', fnt_Bs_20, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure SetTrapSubDraw;
      begin

        TulisStatus('Pilih tempat sebagai jebakan!', fnt_Bs_20, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure TravelSubDraw;
      begin

        TulisStatus('Pilih tempat yang ingin kamu kunjungi!', fnt_Bs_20, NativeResW, NativeResH);

      end;

      //========================================================================
      procedure ChanceSubDraw;
      begin

        LayarGelap;

        // Form kesempatan
        ssprite2d_DrawSc(ChncForm.Texture, ChncForm.X, ChncForm.Y, ChncForm.W, ChncForm.H, 0, $FF, FX_BLEND);

        // gambar kesempatan
        ssprite2d_DrawSc(tx_Kesmp[ChncList[ChncIndex]], ChncForm.X + 151, ChncForm.Y + 100, 600, 400, 0, $FF, FX_BLEND);

        // tombol kembali
        ssprite2d_DrawSc(ChncBack.Texture[Byte(ChncForm.SelIndex = 0) and 1], ChncBack.X, ChncBack.Y, ChncBack.W, ChncBack.H, 0, $FF, FX_BLEND);

      end;

      //========================================================================
      procedure LoseSubDraw;
      begin

      end;

      //========================================================================
      procedure WinSubDraw;
      begin

      end;

      //========================================================================

    var
      l, ply: integer;
    begin

      // warnai area yang ada pemiliknya
      for l:= 0 to 39 do
        begin
        if PlacesOwn[l].IndexPemain >= 0 then
          begin
          ply:= PlacesOwn[l].IndexPemain;
          ssprite2d_DrawSc(Player[ply].WarnaArea, MpRect[l].X, MpRect[l].Y, MpRect[l].W, MpRect[l].H, 0, 127, FX_BLEND);
        end;
      end;

      // Tandai pilihan kota
      if (MpSelRect <> $FF) and ((PlayScene = psRole) or (PlayScene = psGym) or (PlayScene = psTravel) or (PlayScene = psSetTrap)) then
        ssprite2d_DrawSc(tx_MpSelector, MpRect[MpSelRect].X, MpRect[MpSelRect].Y, MpRect[MpSelRect].W, MpRect[MpSelRect].H, 0, 127, FX_BLEND);

      // Gambar bendera buat komplek 1, 2, 7 dan 8
      for l:= 9 downto 1 do
        DrawFlag(l, 0);
      for l:= 31 to 39 do
        DrawFlag(l, 3);

      // Gambarkan Bidak
      for l:= 3 downto 0 do
        begin
        if Player[l].Play then
          ssprite2d_DrawSc(Player[l].Bidak, MpRect[Player[l].Lokasi].X, MpRect[Player[l].Lokasi].Y - 13, 90, 75, 0, $FF, FX_BLEND);
      end;

      // Gambar bendera buat komplek 3, 4, 5 dan 6
      for l:= 21 to 29 do
        DrawFlag(l, 2);
      for l:= 19 downto 11 do
        DrawFlag(l, 1);

      // Gambarkan Panel pemain
      for l:= 0 to 3 do
        begin
        if Player[l].Play then
          begin
          SetDrawEdge(l+1);
          // Panel
          ssprite2d_DrawSc(PlayerPanel[l].PanelTex, PlayerPanel[l].Rect.X, PlayerPanel[l].Rect.Y, PlayerPanel[l].Rect.W, PlayerPanel[l].Rect.H, 0, $FF, FX_BLEND);
          // Avatar
          ssprite2d_DrawSc(tx_Avatars[Player[l].AvatarIndex], PlayAvaPos[l].X, PlayAvaPos[l].Y, PlayAvaPos[l].W, PlayAvaPos[l].H, 0, $FF, FX_BLEND);
          // Nama pemain
          TulisTeks(Player[l].Nama, fnt_Bs_18, PanelTxX[l], PanelTxY[l]);
          // Jumlah uang
          TulisTeks('Rp ' + IntToStr(PMoney[l]) +',-', fnt_Bs_18, PanelTxX[l], PanelTxY[l] + PanelTxYDf);
          //TulisTeks('Rp ' + IntToStr(Player[l].Uang) +',-', fnt_Bs_18, PanelTxX[l], PanelTxY[l] + PanelTxYDf);
          // Tandai pemain yang naik
          if l = RoleIndex then
            pr2d_RectSc(PlayerPanel[l].Rect.X, PlayerPanel[l].Rect.Y, PlayerPanel[l].Rect.W, PlayerPanel[l].Rect.H, $FFFFFF, 16 * FlagsAnim, PR2D_FILL);
        end;
      end;
      SetDrawEdge(0);

      // Sekarang gambar pada sub-scene play
      case PlayScene of
        psRole    : RoleSubDraw();
        psKocok   : KocokSubDraw();
        psRun     : RunSubDraw();
        psProp    : PropSubDraw();
        psPause   : PauseSubDraw();
        psGame    : GameSubDraw();
        psGym     : GymSubDraw();
        psSetTrap : SetTrapSubDraw();
        psTravel  : TravelSubDraw();
        psChance  : ChanceSubDraw();
        psLose    : LoseSubDraw();
        psWin     : WinSubDraw();
      end;

    end;

    //==========================================================================
    procedure HelpSubDraw;
    begin

      LayarGelap;

      // Gambar form petunjuk
      ssprite2d_DrawSc(HelpForm.Texture, HelpForm.X, HelpForm.Y, HelpForm.W, HelpForm.H, 0, $FF, FX_BLEND);

      // Gambar teks petunjuk
      ssprite2d_DrawSc(HelpSubForm[HelpSubIdx].Texture, HelpSubForm[HelpSubIdx].X, HelpSubForm[HelpSubIdx].Y, HelpSubForm[HelpSubIdx].W, HelpSubForm[HelpSubIdx].H, 0, $FF, FX_BLEND);

      // Gambar tombol kembali
      ssprite2d_DrawSc(HelpBackBtn.Texture[Byte(HelpForm.SelIndex = 0) and 1], HelpBackBtn.X, HelpBackBtn.Y, HelpBackBtn.W, HelpBackBtn.H, 0, $FF, FX_BLEND);

      // Tulis petunjuk
      TulisHint(Format('Halaman %d dari %d. Tekan atas dan bawah untuk mengganti halaman', [HelpSubIdx+1, 7]), fnt_Bs_12, NativeResW, NativeResH);

    end;

    //==========================================================================
    procedure AboutSubDraw;
    begin

      LayarGelap;

      // Gambar form about
      ssprite2d_DrawSc(AboutForm.Texture, AboutForm.X, AboutForm.Y, AboutForm.W, AboutForm.H, 0, $FF, FX_BLEND);

      // Gambar tombol kembali
      ssprite2d_DrawSc(AboutBackBtn.Texture[Byte(AboutForm.SelIndex = 0) and 1], AboutBackBtn.X, AboutBackBtn.Y, AboutBackBtn.W, AboutBackBtn.H, 0, $FF, FX_BLEND);

    end;


  begin

    // Gambarkan latar belakangnya
    ssprite2d_Draw(tx_BgMono, 0, 0, FWidth, FHeight, 0, $FF, FX_BLEND);
    // Gambarkan papan monopolinya
    ssprite2d_DrawSc(tx_MonoBoard, 0, 0, NativeResW, NativeResH, 0, $FF, FX_BLEND);

    case GameScene of
      gsMenu     : MenuSubDraw();
      gsPostPlay : PostPlaySubDraw();
      gsPlay     : PlaySubDraw();
      gsHelp     : HelpSubDraw();
      gsAbout    : AboutSubDraw();
    end;

  end;

  //============================================================================
  procedure DialogDraw;
  var
    l: integer;
  begin

    LayarGelap;

    // Gambar form dialog
    ssprite2d_DrawSc(DlgForm.Texture, DlgForm.X, DlgForm.Y, DlgForm.W, DlgForm.H, 0, $FF, FX_BLEND);

    // Gambar teks petunjuk
    TulisDiKotak(DlgTxVal, fnt_Bs_20, DlgTxRect);

    // Gambar tombol kembali
    if DlgScene = dsInfo then
      ssprite2d_DrawSc(DlgChance[2].Texture[Byte(DlgForm.SelIndex = 1) and 1], DlgChance[2].X, DlgChance[2].Y, DlgChance[2].W, DlgChance[2].H, 0, $FF, FX_BLEND)
    else
    if DlgScene = dsQuest then
      for l:= 0 to 1 do
        ssprite2d_DrawSc(DlgChance[l].Texture[Byte(DlgForm.SelIndex = l) and 1], DlgChance[l].X, DlgChance[l].Y, DlgChance[l].W, DlgChance[l].H, 0, $FF, FX_BLEND)

  end;

  //============================================================================

{$IFDEF CREATE_WF}
var
  x: integer;
{$ENDIF}
begin

  if (GameScene <> gsInit) then
    MainDraw()
  else
    InitDraw();

  // Tampilkan dialog
  if DlgScene <> dsNone then
    DialogDraw();

  {$IFDEF CREATE_WF}
  for x:= 0 to 25 do
    begin
    pr2d_Line((FWidth/11)*x, 0, 0, (FHeight/12)*x, $FFFFFF);
    pr2d_Line((FWidth/11)*(x-12), 0, (FWidth/11)*x, FHeight, $FFFFFF);
  end;
  {$ENDIF}

  // Gambarkan kursor, gunakan fungsi asli ZenGL
  ssprite2d_Draw(tx_Cursor, mouse_X(), mouse_Y(), 16, 16, 0);

end;

//=== Update status game =======================================================

procedure GameUpdate(dt: Double);
var
  AbortPause: boolean;

  //============================================================================
  procedure InitUpdate(dt: Double);
  var
    InitDelay: Double;
  begin

    if not InitAfter then
      begin
      InitAfter:= not InitAfter;
      AfterInitAfter:= FALSE;
      InitFadeVal:= $FF;
      InitTick:= timer_GetTicks;
    end;

    InitDelay:= HitungTick(InitTick);
    if (not AfterInitAfter) then
      begin
      if (InitDelay >= 3000) then
        begin
        AfterInitAfter:= TRUE;
        InitTick:= timer_GetTicks;
      end;
    end
    else
      begin
      if InitDelay < 1000.00 then
        InitFadeVal:= not Trunc((InitDelay / 1000.00) * $FF);
      if InitDelay > 1000.00 then
        GameScene:= gsMenu;
    end;

  end;

  //============================================================================
  procedure MenuUpdate(dt: Double);
  var
    idx: integer;
  begin

    idx:= GetGeometryIndexScale(gp_MainMenu, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    if idx <> $FF then
      begin
      if MainMenuIndex <> idx then
        PlaySfx(sd_Swoosh);
      MainMenuIndex:= idx;
    end;

    if mouse_Click(M_BLEFT) then
      begin
      case idx of
        0: GameScene:= gsPostPlay;
        1: LoadGame;
        2: GameScene:= gsHelp;
        3: ShowDialog('Todo: buat pengaturan sound disini!');
        4: GameScene:= gsAbout;
        5: zgl_Exit();
      end;
      if idx <> $FF then
        PlaySfx(sd_Hit);
    end;

  end;

  //============================================================================
  {$HINTS OFF}
  procedure PostPlayUpdate(dt: Double);
  var
    idx: integer;
    avl, avr, pni: integer;
    sbf: string;
    noelse: boolean;
  begin

    idx:= GetGeometryIndexScale(PostPlayForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    if idx <> $FF then
      if idx <> PostPlayForm.SelIndex then
        PlaySfx(sd_Swoosh);

    PostPlayForm.SelIndex:= idx;
    avl:= idx - 6;
    avr:= idx - 10;
    pni:= idx - 2;

    if NameEditIdx <> $FF then
      begin
      sbf:= key_GetText();
      StrPCopy(Player[NameEditIdx].Nama, sbf);
    end;

    if mouse_Click(M_BLEFT) then
      begin
      noelse:= TRUE;
      case idx of
        0: NewGame();
        1: GameScene:= gsMenu;
      else
        noelse:= FALSE;
        if InRange(avl, 0, 3) then
          begin
          Dec(Player[avl].AvatarIndex);
          if Player[avl].AvatarIndex < 0 then
            Player[avl].AvatarIndex:= AvaCount-1;
        end
        else
        if InRange(avr, 0, 3) then
          begin
          Inc(Player[avr].AvatarIndex);
          if Player[avr].AvatarIndex >= AvaCount then
            Player[avr].AvatarIndex:= 0;
        end
        else
        if InRange(pni, 0, 3) then
          begin
          if NameEditIdx <> $FF then
            key_EndReadText();
          NameEditIdx:= pni;
          key_BeginReadText(Player[pni].Nama, 16);
        end
        else
          begin
          NameEditIdx:= $FF;
          key_EndReadText();
        end;
        if noelse then
          if NameEditIdx <> $FF then
            key_EndReadText();
      end;
      if idx <> $FF then
        PlaySfx(sd_Hit);
    end;

  end;
  {$HINTS ON}

  //============================================================================
  procedure PlayUpdate(dt: Double);

    //==========================================================================
    procedure RoleUpdate;
    var
      idx: integer;
      Desc: string;
    begin

      idx:= GetGeometryIndexScale(InRoleForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
      if idx <> $FF then
        if idx <> InRoleSel then
          if Player[RoleIndex].Uang >= 0 then
            PlaySfx(sd_Swoosh);
          
      InRoleSel:= idx;

      if mouse_Click(M_BLEFT) then
        begin
        if (idx = 0) then
          begin
          if (Player[RoleIndex].Uang >= 0) then
            begin
            PlaySfx(sd_Hit);
            PlayScene:= psKocok;
          end;
        end
        else
        if idx = 1 then
          begin
          if (Player[RoleIndex].Uang >= 0) then
            begin
            PlaySfx(sd_Hit);
            ShowDialog('Apakah anda yakin ingin keluar dari permainan ini?', TRUE, @PlyOutGame);
          end;
        end
        else
        if MpSelRect <> $FF then
          begin
          // kotak pangan
          if (Places^[MpSelRect].Jenis >= Place_Lahan1) and (Places^[MpSelRect].Jenis <= Place_Lahan8) then
            begin
            BukaProperti(MpSelRect);
          end
          else
            begin
            case Places^[MpSelRect].Jenis of
              Place_Start      : Desc:= 'Tempat awal bermain. Jika melewati tempat ini, kamu akan diberi Rp 20000 oleh kementrian kesehatan.';
              Place_Game       : Desc:= 'Jika kamu berhenti disini, kamu akan dapat permainan bonus yang penuh kejutan!';
              Place_Kesempatan : Desc:= 'Ambil salah satu kartu kesempatan, dan kamu akan dapatkan perintah sesuai kartu.';
              Place_Jebakan    : Desc:= 'Disini kamu bisa pasang jebakan untuk siapa saja untuk sekali kena!';
              Place_Travel     : Desc:= 'Kamu bisa pergi kemana saja yang kamu mau!';
              Place_RumahSakit : Desc:= 'Tempat kamu dirawat jika sakit. Kamu dapat keluar dari sini apabila mengocok dadu dengan angka yang sama atau melewati 3 putaran.';
              Place_Minum      : Desc:= 'Tempat depot air minum. Jika kamu menguasai keempat depot, kamu akan memenangkan permainan ini!';
              Place_Gym        : Desc:= 'Pembinaan pada pangan yang kamu pilih, jika sudah maka harga sewa pangan naik 50%!';
              Place_Sumbangan  : Desc:= 'Tempat dimana kamu dipungut sumbangan dari kementrian kesehatan sebesar Rp 20000,-!';
            else
              Desc:= '<No Description>';
            end;
            ShowDialog(Places^[MpSelRect].Nama + #13#10#13#10 + Desc);
          end;
          PlaySfx(sd_Hit);
        end;
      end;

      // Pemain nyerah
      if PlyOutGame then
        begin
        PlyOutGame:= FALSE;
        PlayerOut(RoleIndex);
      end;

    end;

    //==========================================================================
    procedure KocokUpdate;
    var
      idx: integer;
    begin

      if (ShakeTick = 0) then
        begin

        idx:= GetGeometryIndexScale(InShakeForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
        if idx <> $FF then
          if idx <> InShakeForm.SelIndex then
            PlaySfx(sd_Swoosh);

        InShakeForm.SelIndex:= idx;

        KocokDadu(AngkaDadu[0], AngkaDadu[1]);

        if mouse_Click(M_BLEFT) then
          if idx = 0 then
            begin
            LogOut(Format('Angka dadu yang keluar: %d dan %d', [AngkaDadu[0], AngkaDadu[1]]));
            // Sound efek dadu keluar
            snd_Stop(sd_DaduKocok, 0);
            PlaySfx(sd_Hit);
            PlaySfx(sd_DaduJatuh);
            // Aksi ketika mata dadu sama
            if AngkaDadu[0] = AngkaDadu[1] then
              Inc(DaduBerturut)
            else
              DaduBerturut:= 0;
            if Player[RoleIndex].DiRumahSakit = 0 then
              begin
              if DaduBerturut = 3 then
                begin
                DaduBerturut:= 0;
                ShowDialog('Kamu kena 3 kali dadu yang sama berturut-turut sehingga sakit! Pergi ke rumah sakit!');
                MasukRumahSakit;
                HasRun;
              end;
            end
            else
              begin
              if DaduBerturut > 0 then
                begin
                Player[RoleIndex].DiRumahSakit:= 0;
                PlaySpeech(34);
              end
              else
                begin
                ShowDialog('Kamu tetap di rumah sakit!');
                Dec(Player[RoleIndex].DiRumahSakit);
                NextRole;
              end;
            end;
            // Untuk delay sebelum jalan
            ShakeTick:= timer_GetTicks;
          end;

       end
       else
         begin

         if (HitungTick(ShakeTick) >= 1500) then
           PlayScene:= psRun;

       end;

    end;

    //==========================================================================
    procedure RunUpdate;
    begin

      if LangkahJalan = -1 then
        if (AngkaDadu[0] = AngkaDadu[1]) and (true) then // Angka sama
          PlayScene:= psKocok // Kocok dadunya...
        else
          HasRun();

    end;

    //==========================================================================
    procedure PropUpdate;
    var
      idx: integer;
      CurLoc: integer;
      spay: LongInt;
      l: integer;
      qplay: boolean; // qualified player, bisa pilih paket
      ptrn: integer;
      bangkrut: boolean;
    begin

      idx:= GetGeometryIndexScale(PropForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
      PaketIdx:= idx - 2;
      qplay:= (PropIdx = Player[RoleIndex].Lokasi) and ((PlacesOwn[PropIdx].IndexPemain = RoleIndex) or (PlacesOwn[PropIdx].IndexPemain = -1));
      if idx <> $FF then
        if (idx <> PropForm.SelIndex) then
          if (idx < 1) or (qplay) then
            PlaySfx(sd_Swoosh);
      PropForm.SelIndex:= idx;

      if mouse_Click(M_BLEFT) then
        case idx of
          0:
            begin
              if PropNextAfter then
                begin
                PlayScene:= psRole;
                NextRole();
              end
              else
                PlayScene:= LastSPlay;
              PlaySfx(sd_Hit);
            end;
          1:
            begin
              CurLoc:= Player[RoleIndex].Lokasi;
              if (PlacesOwn[CurLoc].IndexPemain = RoleIndex) or (Player[PlacesOwn[PropIdx].IndexPemain].Uang < 0) then
                begin
                // Harga jual
                spay:= 0;
                for l:= 0 to PlacesOwn[PropIdx].Paket do
                  spay:= spay + Places^[PropIdx].Jual[l];
                // Jual asset
                PlacesOwn[PropIdx].IndexPemain:= -1;
                PlacesOwn[PropIdx].Paket:= 0;
                PlacesOwn[PropIdx].BonusGym:= FALSE;
                // tambah uang penjualan
                bangkrut:= Player[RoleIndex].Uang < 0;
                Player[RoleIndex].Uang:= Player[RoleIndex].Uang + spay;
                PlaySfx(sd_CashRegs);
                ShowDialog(Format('Kamu telah menjual %s dengan harga Rp %d,-!', [Places^[PropIdx].Nama, spay]));
                if Bangkrut then
                  NextRole;
              end;
              PlaySfx(sd_Hit);
            end;
        else
          if (PaketIdx >= 0) and (PaketIdx <= 3) then
            if qplay then
              begin
              if PaketIdx > 1 then
                ptrn:= 1
              else
                ptrn:= 0;
              if Player[RoleIndex].Putaran >= ptrn then // putaran sudah memenuhi
                begin
                CurLoc:= Player[RoleIndex].Lokasi;
                if Player[RoleIndex].Uang >= Places^[CurLoc].Beli[PaketIdx] then // cukup uang
                  begin
                  if (PaketIdx <> PlacesOwn[CurLoc].Paket) or ((PlacesOwn[CurLoc].IndexPemain < 0) and (PlacesOwn[CurLoc].IndexPemain = -1)) then // beli paket yang sama?
                    begin
                    if ((PaketIdx-1 = PlacesOwn[CurLoc].Paket) and (PlacesOwn[CurLoc].IndexPemain = RoleIndex)) or (PaketIdx = 0) then // sudah beli paket sebelumnya?
                      begin
                      // Kurangi duit sesuai harga
                      spay:= Places^[CurLoc].Beli[PaketIdx];
                      Player[RoleIndex].Uang:= Player[RoleIndex].Uang - spay;
                      // Serah terima paket
                      PlacesOwn[CurLoc].IndexPemain:= RoleIndex;
                      PlacesOwn[CurLoc].Paket:= PaketIdx;
                      PlaySfx(sd_CashRegs);
                      ShowDialog(Format('Pangan %s sudah dibeli oleh %s seharga Rp %d,-', [Places^[CurLoc].Nama, Player[RoleIndex].Nama, spay]));
                    end
                    else
                      ShowDialog('Kamu harus membeli paket sebelumnya untuk membeli paket ini!');
                  end
                  else
                    ShowDialog('Kamu tidak bisa membeli paket yang sama!');
                end
                else
                  ShowDialog(Format('Anda kurang uang untuk membeli %s paket ini!', [Places^[CurLoc].Nama]));
              end
              else // belum?
                ShowDialog(Format('Anda belum bisa membeli pangan ini sekarang karena membutuhkan sekurang-kurangnya %d putaran!', [ptrn]));
          end;
          PlaySfx(sd_Hit);
        end;

    end;

    //==========================================================================
    procedure PauseUpdate;
    begin

      if key_Press(K_ESCAPE) then
        begin
        PlayScene:= LastSPlay;
        AbortPause:= TRUE;
      end
      else
      if key_Press(K_SPACE) then
        begin
        SaveGame;
        GameScene:= gsMenu;
      end;
      
    end;

    //==========================================================================
    procedure GameUpdate;
    var
      idx: integer;
      TimeNow: Double;
    begin

      if not JackRoll then // sedang diputar?
        begin

        idx:= GetGeometryIndexScale(JackForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
        if idx <> $FF then
          if (idx <> JackForm.SelIndex) then
            PlaySfx(sd_Swoosh);
        JackForm.SelIndex:= idx;

        if mouse_Click(M_BLEFT) and (idx = 0) then
          if (JackCount < 3) then
            begin

            PlaySfx(sd_JackBegin);
            Jack2St:= FALSE;
            JackRoll:= TRUE;
            JackStart:= timer_GetTicks;

          end
          else
            NextRole;

      end
      else
        begin

        TimeNow:= timer_GetTicks - JackStart;
        Randomize();
        if TimeNow < 5000 then
          begin
          JackIdx[2]:= Random(8);
          if JackIdx[2] > 7 then
            JackIdx[2]:= JackIdx[2] - 7;
          if TimeNow < 4000 then
            begin
            JackIdx[1]:= Random(8);
            if JackIdx[1] > 7 then
              JackIdx[1]:= JackIdx[1] - 7;
            if TimeNow < 3000 then
              begin
              JackIdx[0]:= Random(8);
              if JackIdx[0] > 7 then
                JackIdx[0]:= JackIdx[0] - 7;
            end;
          end
          else
            begin
            if not Jack2St then
              begin
              if Random(2) = 0 then
                JackIdx[1]:= JackIdx[0];
              Jack2St:= TRUE;
            end;
          end;
        end
        else
          begin

          if Random(2) = 0 then
            if (JackIdx[0] = JackIdx[1]) then
              JackIdx[2]:= JackIdx[1];

          if (JackIdx[0] = JackIdx[1]) and (JackIdx[1] = JackIdx[2]) then
            begin
            // Berhadiah jackpot
            PlaySfx(sd_JackWin);
            ShowDialog(Format('Selamat! Kamu berhasil mendapatkan Rp %d,-!', [ListJackpotRew[JackIdx[0]]]));
            Inc(Player[RoleIndex].Uang, ListJackpotRew[JackIdx[0]]);
          end;

          JackRoll:= FALSE;
          Inc(JackCount);

        end;

      end;

    end;

    //==========================================================================
    procedure GymUpdate;
    begin

      if mouse_Click(M_BLEFT) and (MpSelRect <> $FF) then
        begin
        if PlacesOwn[MpSelRect].IndexPemain = RoleIndex then
          begin
          PlacesOwn[Player[RoleIndex].Lokasi].BonusGym:= TRUE;
          NextRole();
        end
        else
          ShowDialog('Kamu harus pilih tempat kamu sendiri!');
      end;

    end;

    //==========================================================================
    procedure SetTrapUpdate;
    begin

      if mouse_Click(M_BLEFT) and (MpSelRect <> $FF) then
        begin
        PlacesOwn[Player[RoleIndex].Lokasi].IndexPemain:= RoleIndex;
        PlacesOwn[Player[RoleIndex].Lokasi].Paket:= MpSelRect;
        NextRole();
      end;

    end;

    //==========================================================================
    procedure TravelUpdate;
    begin

      if mouse_Click(M_BLEFT) and (MpSelRect <> $FF) then
        begin
        Player[RoleIndex].Lokasi:= MpSelRect;
        HasRun();
      end;

    end;

    //==========================================================================
    procedure ChanceUpdate;
    var
      idx: integer;
    begin

      idx:= GetGeometryIndexScale(ChncForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
      ChncForm.SelIndex:= idx;

      if mouse_Click(M_BLEFT) and (idx = 0) then
        begin
        // kesempatan here!
        ProsesKesempatan(ChncList[ChncIndex]);
        Inc(ChncIndex);
        if ChncIndex > 5 then
          KocokKesempatan;
      end;

    end;

    //==========================================================================
    procedure LoseUpdate;
    begin

      if DlgScene = dsNone then
        begin
        NextRole(); // Naik selanjutnya
      end;

    end;

    //==========================================================================
    procedure WinUpdate;
    var
      loc: string;
    begin

      if (not WinDlg) and (DlgScene = dsNone) then
        begin
        WinDlg:= TRUE;
        loc:= DirApp + SaveGame_nm;
        if FileExists(loc) then
          DeleteFile(loc);
        PlaySubMusic(sd_Win, 'Winner.ogg');
        PlaySpeech(37+RoleIndex);
        ShowDialog(Format('%s, %s (Pemain %d) adalah pemenangnya!', [WinReason, Player[WinIndex].Nama, WinIndex+1]));
      end;
      if DlgScene = dsNone then
        begin
        GameScene:= gsMenu;
        StopSubMusic(sd_Win);
      end;

    end;

    //==========================================================================

  var
    idx: integer;
    OldScn: TPlaySubScene;
  begin

    idx:= GetGeometryIndexScale(gp_MonoBoard, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    MpSelRect:= idx;

    // Kelola scene dalam permainan
    OldScn:= PlayScene;
    AbortPause:= FALSE;
    case PlayScene of
      psIdle    : PlayScene:= psRole;
      psRole    : RoleUpdate();
      psKocok   : KocokUpdate();
      psRun     : RunUpdate();
      psProp    : PropUpdate();
      psPause   : PauseUpdate();
      psGame    : GameUpdate();
      psGym     : GymUpdate();
      psSetTrap : SetTrapUpdate();
      psTravel  : TravelUpdate();
      psChance  : ChanceUpdate();
      psLose    : LoseUpdate();
      psWin     : WinUpdate();
    end;

    // Pause kalo tekan Esc
    if not AbortPause then
      if key_Press(K_ESCAPE) then
        PlayScene:= psPause;

    // Ada perubahan, panggil event scene
    if PlayScene <> OldScn then
      SubPlayChanged(OldScn);

  end;

  //============================================================================
  procedure HelpUpdate(dt: Double);
  var
    idx: integer;
  begin

    idx:= GetGeometryIndexScale(HelpForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    HelpForm.SelIndex:= idx;

    if key_Press(K_UP) then
      Dec(HelpSubIdx)
    else
    if key_Press(K_DOWN) then
      Inc(HelpSubIdx);
    if HelpSubIdx < 0 then
      HelpSubIdx:= 6
    else
    if HelpSubIdx > 6 then
      HelpSubIdx:= 0;
      
    if mouse_Click(M_BLEFT) then
      if idx = 0 then
        GameScene:= gsMenu;

  end;

  //============================================================================
  procedure AboutUpdate(dt: Double);
  var
    idx: integer;
  begin

    idx:= GetGeometryIndexScale(AboutForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    AboutForm.SelIndex:= idx;

    if mouse_Click(M_BLEFT) then
      if idx = 0 then
        GameScene:= gsMenu;

  end;

  //============================================================================
  procedure DialogUpdate(dt: Double);
  var
    idx: integer;
  begin

    idx:= GetGeometryIndexScale(DlgForm.GeoPoint, mouse_X() - XSc, mouse_Y() - YSc, NWidth, NHeight);
    if idx <> $FF then
      if (DlgForm.SelIndex <> idx) and ((idx = 1) or (DlgScene = dsQuest)) then
        PlaySfx(sd_Swoosh);

    DlgForm.SelIndex:= idx;

    if mouse_Click(M_BLEFT) then
      begin
      if DlgScene = dsInfo then
        begin
        if idx = 1 then
          begin
          if DlgRes <> nil then
            DlgRes^:= TRUE;
          PlaySfx(sd_Hit);
          DlgScene:= dsNone;
        end;
      end
      else
      if DlgScene = dsQuest then
        begin
        if idx = 0 then
          begin
          if DlgRes <> nil then
            DlgRes^:= TRUE;
          PlaySfx(sd_Hit);
          DlgScene:= dsNone;
        end
        else
        if idx = 1 then
          begin
          if DlgRes <> nil then
            DlgRes^:= FALSE;
          PlaySfx(sd_Hit);
          DlgScene:= dsNone;
        end;
      end;
    end;

  end;

  //============================================================================

var
  OldEv: TGameScene;
begin

  //if not GameLoading then
    begin
    if DlgScene = dsNone then
      begin
      OldEv:= GameScene;
      case GameScene of
        gsNothing  : GameScene:= gsInit;
        gsInit     : InitUpdate(dt);
        gsMenu     : MenuUpdate(dt);
        gsPostPlay : PostPlayUpdate(dt);
        gsPlay     : PlayUpdate(dt);
        gsHelp     : HelpUpdate(dt);
        gsAbout    : AboutUpdate(dt);
      end;

      if OldEv <> GameScene then
        SceneChanged(OldEv);

    end
    else
      DialogUpdate(dt);
  end;

  mouse_ClearState();
  key_ClearState();

end;

//==== Kalau game di exit ======================================================

procedure GameExit;
var
  OldEv: TGameScene;
begin

  // Simpan kalo masih main
  if GameScene = gsPlay then
    SaveGame;

  if DlgForm.GeoPoint <> nil then
    UnloadGeometry(DlgForm.GeoPoint);
  if gp_MonoBoard <> nil then
    UnloadGeometry(gp_MonoBoard);

  OldEv:= GameScene;
  GameScene:= gsNothing;
  SceneChanged(OldEv);

  GameRun:= FALSE;
  UnloadPlaces(Places);

  CloseBundle(RescBund);
  CloseBundle(SndsBund);
  CloseBundle(SpchBund);

  LogOut('Game Exit!');

end;

end.
