unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Gauges, DZlib, Math, Spin;

type
  TGPIHeader = record
    Width: Cardinal;
    Height: Cardinal;
  end;
  PGPIHeader = ^TGPIHeader;

type
  TfrmMain = class(TForm)
    ScrollBox1: TScrollBox;
    GroupBox1: TGroupBox;
    lblInp: TLabel;
    Button1: TButton;
    GroupBox2: TGroupBox;
    lblOut: TLabel;
    Button2: TButton;
    rgCol: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    imgPrev: TImage;
    odlg: TOpenDialog;
    sdlg: TSaveDialog;
    prgs: TGauge;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    spMin: TSpinEdit;
    Label2: TLabel;
    spMax: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    Outloc: string;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.Button1Click(Sender: TObject);
begin

  if odlg.Execute then
    begin
    lblInp.Caption:= ExtractFileName(odlg.FileName);
    imgPrev.Picture.Bitmap.LoadFromFile(odlg.FileName);
    imgPrev.AutoSize:= TRUE;
    if Outloc = '' then
      begin
      OutLoc:= ChangeFileExt(odlg.FileName, '.gpi');
      sdlg.FileName:= OutLoc;
      lblOut.Caption:= ExtractFileName(OutLoc);
    end;
  end;

end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin

  if sdlg.Execute then
    begin
    OutLoc:= sdlg.FileName;
    lblOut.Caption:= ExtractFileName(sdlg.FileName);
  end;

end;

procedure TfrmMain.BitBtn2Click(Sender: TObject);
begin

  Close;

end;

procedure TfrmMain.BitBtn1Click(Sender: TObject);
var
  fout: THandle;
  fin: Graphics.TBitmap;
  fsize, osz: LongInt;
  regsz: Cardinal;
  Gpim, Cpim: Pointer;
  hstr: PGPIHeader;
  ProgPtr: PByte;
  bf: PByte;
  nlc: LongWord;
  bmi: Windows.TBitmap;
  l: integer;
  ho, lo: integer;
begin

  prgs.Progress:= 0;
  prgs.Show;
  try
    fin:= TBitmap.Create;
    fout:= CreateFile(PChar(OutLoc), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    try
      fin.LoadFromFile(odlg.FileName);
      fin.PixelFormat:= pf24Bit;
      GetObject(fin.Handle, SizeOf(Windows.TBitmap), @bmi);
      SetFilePointer(fout, 0, nil, FILE_BEGIN);
      regsz:= bmi.bmWidth * bmi.bmHeight;
      fsize:= regsz + SizeOf(TGPIHeader);
      GetMem(Gpim, fsize);
      try
        if bmi.bmBitsPixel <> 24 then
          begin
          ShowMessage('Not 24-bit bitmap! '+IntToStr(bmi.bmBitsPixel));
          exit;
        end;
        hstr:= Gpim;
        hstr^.Width:= bmi.bmWidth;
        hstr^.Height:= bmi.bmHeight;
        ProgPtr:= Pointer(LongInt(bmi.bmBits) + rgCol.ItemIndex);
        bf:= Pointer(LongInt(Gpim) + SizeOf(TGPIHeader));
        ho:= spMax.Value;
        lo:= spMin.Value;
        for l:= 0 to regsz-1 do
          begin
          if InRange(ProgPtr^, lo, ho) then
            bf^:= ProgPtr^
          else
            bf^:= $FF;
          ProgPtr:= Pointer(LongInt(ProgPtr) + 3);
          bf:= Pointer(LongInt(bf)+1);
          prgs.Progress:= Round((l/regsz)*100);
          Application.ProcessMessages;
        end;
        CompressBuf(Gpim, fsize, Cpim, osz);
        try
          WriteFile(fout, fsize, SizeOf(LongInt), nlc, nil);
          WriteFile(fout, Cpim^, osz, nlc, nil);
        finally
          FreeMem(Cpim);
        end;
      finally
        FreeMem(Gpim);
        Gpim:= nil;
      end;
    finally
      CloseHandle(fout);
      fin.Free;
    end;
  finally
    prgs.Hide;
  end;

end;

end.
