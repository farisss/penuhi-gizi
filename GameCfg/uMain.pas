unit uMain;

(*==============================================================================

  Project Richman game
  Copyright © Team-R 2014 - 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
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

type
  TResolution = packed record
    W, H: LongInt;
  end;

type
  TResArray = array[0..$FF] of TResolution;
  PResArray = ^TResArray;

type
  TfrmMain = class(TForm)
    GroupBox1: TGroupBox;
    cbxRes: TComboBox;
    cbxFs: TCheckBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    Bevel1: TBevel;
    imgBan: TImage;
    GroupBox2: TGroupBox;
    rbD3d8: TRadioButton;
    rbD3d9: TRadioButton;
    rbOgl: TRadioButton;
    GroupBox3: TGroupBox;
    Bevel2: TBevel;
    cbxVsync: TCheckBox;
    cbxSnd: TCheckBox;
    cbxLog: TCheckBox;
    Label1: TLabel;
    scFsaa: TScrollBar;
    lblFsaa: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scFsaaChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }

    procedure EnumDisp;
    procedure RefreshFSAA;

  public
    { Public declarations }

    ConfPath: string;
    Conf: TGameConfig;
    Devs: PResArray;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.EnumDisp;
var
  cnt: integer;
  xnt: integer;
  DevMode: TDevMode;
  l: integer;
  new: boolean;
  nmm: Pointer;
begin

  GetMem(Devs, SizeOf(TResolution));
  cnt:= 0;
  xnt:= 0;
  cbxRes.Items.Clear;
  while EnumDisplaySettings(nil, cnt, DevMode) do
    with DevMode do
      begin
      if dmBitsperPel = 32 then
        begin
        ReallocMem(Devs, (xnt+1)*SizeOf(TResolution));
        new:= TRUE;
        for l:= 0 to xnt do
          if (Devs^[l].W = dmPelsWidth) and (Devs^[l].H = dmPelsHeight) then
            begin
            new:= FALSE;
            Break;
          end;
        if new then
          begin
          Devs^[xnt].W:= dmPelsWidth;
          Devs^[xnt].H:= dmPelsHeight;
          cbxRes.Items.Add(Format('%dx%d', [dmPelsWidth, dmPelsHeight]));
          if (Devs^[xnt].W = Conf.DispWidth) and (Devs^[xnt].H = Conf.DispHeight) then
            cbxRes.ItemIndex:= xnt;
          Inc(xnt);
        end;
      end;
      Inc(cnt);
    end;

end;

procedure TfrmMain.RefreshFSAA;
begin

  if scFsaa.Position > 0 then
    lblFsaa.Caption:= Format('%d.0 X', [scFsaa.Position * 2])
  else
    lblFsaa.Caption:= 'Dimatikan';

end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin

  Close;

end;

procedure TfrmMain.btnOkClick(Sender: TObject);
var
  f: file;
begin

  // Pindahkan info ke buffer

  // Konfigurasi layar
  Conf.DispWidth:= Devs^[cbxRes.ItemIndex].W;
  Conf.DispHeight:=  Devs^[cbxRes.ItemIndex].H;
  Conf.DispFullScreen:= cbxFs.Checked;

  // Konfigurasi perender
  if rbD3d8.Checked then
    Conf.GraphRenderIndex:= 0
  else
  if rbD3d9.Checked then
    Conf.GraphRenderIndex:= 1
  else
    Conf.GraphRenderIndex:= 2;

  // Pengaturan lanjutan
  Conf.VSync:= cbxVsync.Checked;
  Conf.SoundOn:= cbxSnd.Checked;
  Conf.OutLog:= cbxLog.Checked;
  Conf.FSAAMul:= scFsaa.Position * 2;

  // Simpan pengaturan lalu keluar
  {$I-}
  AssignFile(f, ConfPath);
  ReWrite(f, 1);
  BlockWrite(f, Conf, SizeOf(TGameConfig));
  CloseFile(f);
  {$I+}

  Close;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  f: file;
  tx: TextFile;
  CfgLoc: string;
begin

  // Dapatkan informasi lokasi dari konfigurasi
  {$I-}
  AssignFile(tx, ChangeFileExt(ParamStr(0), '.dat'));
  Reset(tx);
  ReadLn(tx, CfgLoc);
  CloseFile(tx);
  {$I+}
  ConfPath:= ExtractFilePath(ParamStr(0)) + CfgLoc;

  // Baca konfigurasi game
  FillChar(Conf, SizeOf(TGameConfig), 0);
  {$I-}
  AssignFile(f, ConfPath);
  Reset(f, 1);
  if FileSize(f) = SizeOf(TGameConfig) then
    BlockRead(f, Conf, SizeOf(TGameConfig))
  else
    begin
    Conf.DispWidth:= 1024;
    Conf.DispHeight:= 768;
    Conf.DispFullScreen:= TRUE;
    Conf.GraphRenderIndex:= 1;
    Conf.VSync:= TRUE;
    Conf.SoundOn:= TRUE;
    Conf.OutLog:= TRUE;
    Conf.FSAAMul:= 0;
    ReWrite(f, 1);
    BlockWrite(f, Conf, SizeOf(TGameConfig));
  end;
  CloseFile(f);
  {$I+}

  // Baca konfigurasi layar
  EnumDisp;
  cbxFs.Checked:= Conf.DispFullScreen;
  // Baca konfigurasi perender
  case Conf.GraphRenderIndex of
    0: rbD3d8.Checked:= TRUE;
    1: rbD3d9.Checked:= TRUE;
  else
    rbOgl.Checked:= TRUE;
  end;
  // Pengaturan lanjutan
  cbxVsync.Checked:= Conf.VSync;
  cbxSnd.Checked:= Conf.SoundOn;
  cbxLog.Checked:= Conf.OutLog;
  scFsaa.Position:= Conf.FSAAMul div 2;
  RefreshFSAA;

end;

procedure TfrmMain.scFsaaChange(Sender: TObject);
begin

  RefreshFSAA;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin

  FreeMem(Devs, cbxRes.Items.Count*SizeOf(TResolution));

end;

end.
