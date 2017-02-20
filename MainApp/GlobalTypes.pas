unit GlobalTypes;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  {$IFDEF ZGLDLL}
  zglHeader
  {$ELSE}
  zgl_fx,
  zgl_textures,
  zgl_math_2d,
  zgl_utils
  {$ENDIF};

type

  // Untuk pengaturan tersimpan
  TGameConfig = record
    GraphRenderIndex : Byte;
    DispWidth        : LongInt;
    DispHeight       : LongInt;
    DispFullScreen   : ByteBool;
    VSync            : ByteBool;
    SoundOn          : ByteBool;
    OutLog           : ByteBool;
    FSAAMul          : Byte;
  end;

  // Scene utama game
  TGameScene = (gsNothing, gsInit, gsMenu, gsPlay, gsPostPlay, gsHelp, gsPref,
                gsAbout);

  TPlaySubScene = (psIdle, psPause, psRole, psKocok, psRun, psProp, psGame,
                   psGym, psSetTrap, psTravel, psChance, psLose, psWin);

  TDialogScene = (dsNone, dsInfo, dsQuest);

  // Header GPI (Geometry Point Index)
  TGPIHeader = record
    Width: LongInt;
    Height: LongInt;
  end;
  PGPIHeader = ^TGPIHeader;

  // Tombol Menu
  TGMenuButton = packed record
    Texture: array[0..1] of zglPTexture;
    X, Y: Single;
    W, H: Single;
  end;

  // Untuk form/tampilan
  TGForm = packed record
    Texture: zglPTexture;
    GeoPoint: PGPIHeader;
    SelIndex: Byte;
    X, Y: Single;
    W, H: Single;
  end;

  TGPropForm = packed record
    Texture: array[0..7] of zglPTexture;
    GeoPoint: PGPIHeader;
    SelIndex: Byte;
    X, Y: Single;
    W, H: Single;
  end;

  (*TGDialog = packed record
    TextVal: string;
    ModalResult: boolean;
  end;*)

  TGPlace = record
    Nama: array[0..32] of char;
    Jenis: ShortInt;
    Pangan: ShortInt;
    Harga: LongInt;
    Jual: array[0..3] of LongInt;
    Beli: array[0..3] of LongInt;
    Sewa: array[0..3] of LongInt;
  end;
  TGPlaces = array[0..39] of TGPlace;
  PGPlaces = ^TGPlaces;

  TGPlaceOwner = packed record
    IndexPemain: ShortInt; // indeks pemain yang taroh
    Paket: ShortInt;       // no paket, 0 = tanah doang, 1, 2, dan 3 = paket 1,2,3. atau lokasi arah jebakan
    BonusGym: ByteBool;    // bonus untuk sewa jadi lebih mahal, karena nge-gym
  end;
  TGPlacesOwner = array[0..39] of TGPlaceOwner;

  // Pemain
  TGPlayer = packed record
    Nama         : array[0..32] of char;
    Play         : ByteBool;
    AvatarIndex  : LongInt;
    Lokasi       : Byte;
    Bidak        : zglPTexture;
    WarnaArea    : zglPTexture;
    Uang         : LongInt;
    Putaran      : LongInt;
    DiRumahSakit : Byte; // 0: tidak, >0: jumlah putaran sebelum keluar
    BebasSewa    : ByteBool; // kalo dapat kartu bebas sewa
  end;
  TGPlayers = array[0..3] of TGPlayer;

  // Panel Pemain
  TGPlayerPanel = packed record
    PanelTex: zglPTexture;
    Rect: zglTRect;
  end;

  TSaveGameHeader = record
    Header   : array[0..3] of char; // char "PGSv"
    VMajor   : Byte;
    VMinor   : Byte;
    SaveTime : TDateTime;
    PlayTime : TDateTime;
    DataSize : LongWord;
    Crc32    : LongWord;
  end;
  PSaveGameHeader = ^TSaveGameHeader;

  TSaveState = record
    OnRoleIndex : ShortInt;
    SubScene    : TPlaySubScene;
  end;

  TSaveGame = record
    Header    : TSaveGameHeader;
    State     : TSaveState;
    Player    : TGPlayers;
    PlacesOwn : TGPlacesOwner;
  end;

implementation

end.
