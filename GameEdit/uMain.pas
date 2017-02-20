unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, dzlib;

type
  TGPlace = record
    Nama: array[0..32] of char;
    Jenis: ShortInt;
    Pangan: ShortInt;
    Harga: LongInt;
    Jual: array[0..3] of LongInt;
    Beli: array[0..3] of LongInt;
    Sewa: array[0..3] of LongInt;
  end;
  TPlaces = array[0..39] of TGPlace;
  PPlaces = ^TPlaces;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    edtLoc: TEdit;
    btnLoad: TButton;
    btnSave: TButton;
    grpData: TGroupBox;
    btnLeft: TButton;
    lblLoc: TLabel;
    btnRight: TButton;
    Label3: TLabel;
    edtPlc: TEdit;
    Label4: TLabel;
    cbxType: TComboBox;
    grpAdv: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edtHb0: TEdit;
    edtHb1: TEdit;
    edtHb2: TEdit;
    edtHb3: TEdit;
    Label11: TLabel;
    edtHj0: TEdit;
    edtHj1: TEdit;
    edtHj2: TEdit;
    edtHj3: TEdit;
    Label12: TLabel;
    edtHs0: TEdit;
    edtHs1: TEdit;
    edtHs2: TEdit;
    edtHs3: TEdit;
    Label13: TLabel;
    edtPjk: TEdit;
    odlg: TOpenDialog;
    sdlg: TSaveDialog;
    Label2: TLabel;
    cbxPgn: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLeftClick(Sender: TObject);
    procedure btnRightClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure edtPlcChange(Sender: TObject);
    procedure cbxTypeChange(Sender: TObject);
    procedure edtPjkChange(Sender: TObject);
    procedure edtHb0Change(Sender: TObject);
    procedure edtHb1Change(Sender: TObject);
    procedure edtHb2Change(Sender: TObject);
    procedure edtHb3Change(Sender: TObject);
    procedure edtHj0Change(Sender: TObject);
    procedure edtHj1Change(Sender: TObject);
    procedure edtHj2Change(Sender: TObject);
    procedure edtHj3Change(Sender: TObject);
    procedure edtHs0Change(Sender: TObject);
    procedure edtHs1Change(Sender: TObject);
    procedure edtHs2Change(Sender: TObject);
    procedure edtHs3Change(Sender: TObject);
    procedure cbxPgnChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    Bfr: PPlaces;
    Idx: integer;

    procedure ReloadLoc;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.ReloadLoc;
begin

  lblLoc.Caption:= Format('Data ke %d dari 40', [Idx+1]);

  edtPlc.Text:= Bfr^[Idx].Nama;
  cbxType.ItemIndex:= Bfr^[Idx].Jenis+1;
  edtPjk.Text:= IntToStr(Bfr^[Idx].Harga);
  cbxPgn.ItemIndex:= Bfr^[Idx].Pangan;

  edtHb0.Text:= IntToStr(Bfr^[Idx].Beli[0]);
  edtHb1.Text:= IntToStr(Bfr^[Idx].Beli[1]);
  edtHb2.Text:= IntToStr(Bfr^[Idx].Beli[2]);
  edtHb3.Text:= IntToStr(Bfr^[Idx].Beli[3]);

  edtHj0.Text:= IntToStr(Bfr^[Idx].Jual[0]);
  edtHj1.Text:= IntToStr(Bfr^[Idx].Jual[1]);
  edtHj2.Text:= IntToStr(Bfr^[Idx].Jual[2]);
  edtHj3.Text:= IntToStr(Bfr^[Idx].Jual[3]);

  edtHs0.Text:= IntToStr(Bfr^[Idx].Sewa[0]);
  edtHs1.Text:= IntToStr(Bfr^[Idx].Sewa[1]);
  edtHs2.Text:= IntToStr(Bfr^[Idx].Sewa[2]);
  edtHs3.Text:= IntToStr(Bfr^[Idx].Sewa[3]);

end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  x: integer;
begin

  GetMem(Bfr, SizeOf(TPlaces));
  FillChar(Bfr^, SizeOf(TPlaces), 0);
  for x:= 0 to 39 do
    Bfr^[x].Jenis:= -1;
  Idx:= 0;
  ReloadLoc;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin

  FreeMem(Bfr, SizeOf(TPlaces));

end;

procedure TfrmMain.btnLeftClick(Sender: TObject);
begin

  Dec(Idx);
  if Idx < 0 then
    Idx:= 39;
  ReloadLoc;

end;

procedure TfrmMain.btnRightClick(Sender: TObject);
begin

  Inc(Idx);
  if Idx > 39 then
    Idx:= 0;
  ReloadLoc;

end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  f: THandle;
  nlc: Integer;
  Cmpr: Pointer;
  csz: integer;
begin

  if edtLoc.Text = '' then
    begin
    if sdlg.Execute then
      edtLoc.Text:= sdlg.FileName
    else
      Exit;
  end;

  f:= CreateFile(PChar(edtLoc.Text), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  try
    SetFilePointer(f, 0, nil, FILE_BEGIN);
    CompressBuf(Bfr, SizeOf(TPlaces), Cmpr, csz);
    try
      WriteFile(f, Cmpr^, csz, nlc, nil);
    finally
      FreeMem(Cmpr, csz);
    end;
  finally
    CloseHandle(f);
  end;

  Beep;
  ReloadLoc;

end;

procedure TfrmMain.btnLoadClick(Sender: TObject);
var
  f: THandle;
  nlc: Integer;
  fsz: Integer;
  bf: Pointer;
  bbf: Pointer;
  oi: Integer;
begin

  if odlg.Execute then
    edtLoc.Text:= odlg.FileName
  else
    Exit;

  f:= CreateFile(PChar(edtLoc.Text), GENERIC_READ, 0, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  try
    SetFilePointer(f, 0, nil, FILE_BEGIN);
    fsz:= GetFileSize(f, nil);
    GetMem(bf, fsz);
    try
      ReadFile(f, bf^, fsz, nlc, nil);
      bbf:= bfr;
      DecompressBuf(bf, fsz, 0, bbf, oi);
      bfr:= bbf;
    finally
      FreeMem(bf, fsz);
    end;
  finally
    CloseHandle(f);
  end;

  Beep;
  ReloadLoc;

end;

procedure TfrmMain.edtPlcChange(Sender: TObject);
begin

  FillChar(Bfr^[Idx].Nama, 33, 0);
  StrPCopy(Bfr^[Idx].Nama, edtPlc.Text);

end;

procedure TfrmMain.cbxTypeChange(Sender: TObject);
begin

  Bfr^[Idx].Jenis:= cbxType.ItemIndex-1;

end;

procedure TfrmMain.edtPjkChange(Sender: TObject);
begin

  try
    Bfr^[Idx].Harga:= StrToInt(edtPjk.Text);
  except end;

end;

procedure TfrmMain.edtHb0Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Beli[0]:= StrToInt(edtHb0.Text);
  except end;

end;

procedure TfrmMain.edtHb1Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Beli[1]:= StrToInt(edtHb1.Text);
  except end;

end;

procedure TfrmMain.edtHb2Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Beli[2]:= StrToInt(edtHb2.Text);
  except end;

end;

procedure TfrmMain.edtHb3Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Beli[3]:= StrToInt(edtHb3.Text);
  except end;

end;

procedure TfrmMain.edtHj0Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Jual[0]:= StrToInt(edtHj0.Text);
  except end;

end;

procedure TfrmMain.edtHj1Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Jual[1]:= StrToInt(edtHj1.Text);
  except end;

end;

procedure TfrmMain.edtHj2Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Jual[2]:= StrToInt(edtHj2.Text);
  except end;

end;

procedure TfrmMain.edtHj3Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Jual[3]:= StrToInt(edtHj3.Text);
  except end;

end;

procedure TfrmMain.edtHs0Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Sewa[0]:= StrToInt(edtHs0.Text);
  except end;

end;

procedure TfrmMain.edtHs1Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Sewa[1]:= StrToInt(edtHs1.Text);
  except end;

end;

procedure TfrmMain.edtHs2Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Sewa[2]:= StrToInt(edtHs2.Text);
  except end;

end;

procedure TfrmMain.edtHs3Change(Sender: TObject);
begin

  try
    Bfr^[Idx].Sewa[3]:= StrToInt(edtHs3.Text);
  except end;

end;

procedure TfrmMain.cbxPgnChange(Sender: TObject);
begin

  Bfr^[Idx].Pangan:= cbxPgn.ItemIndex;

end;

end.
