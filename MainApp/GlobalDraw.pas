unit GlobalDraw;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  GlobalConst, GlobalUtils,
  {$IFDEF ZGLDLL}
  zglHeader
  {$ELSE}
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
  zgl_sprite_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils
  {$ENDIF};

  procedure SetupScreenScale(NewW, NewH: Single);
  procedure SetDrawEdge(Edge: Byte);

  // ZenGL extended functions
  procedure ssprite2d_DrawSc( Texture : zglPTexture; X, Y, W, H, Angle : Single; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  procedure pr2d_RectSc( X, Y, W, H : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = 0 );

  procedure LayarGelap;
  procedure TulisTeks(Text: string; font: zglPFont; X, Y: Single; Scale: Single = 1.0);
  procedure TulisHint(Text: string; font: zglPFont; ScW, ScH: Single; Scale: Single = 1.0);
  procedure TulisStatus(Text: string; font: zglPFont; ScW, ScH: Single; Scale: Single = 1.0);
  procedure TulisDiKotak(Text: string; font: zglPFont; Kotak: zglTRect; Scale: Single = 1.0);

var
  SWidth, SHeight: Single;
  FWidth, FHeight: Single;
  RWidth, RHeight: Single;
  XSc, YSc: Single;
  o_XSc, o_YSc: Single;
  ScRatio: Single;

implementation

//==============================================================================

procedure SetupScreenScale(NewW, NewH: Single);
begin

  SWidth:= NewW;
  SHeight:= NewH;
  AspectRatio(NewW, NewH, NativeResW, NativeResH, FWidth, FHeight, XSc, YSc);
  o_XSc:= XSc;
  o_YSc:= YSc;
  RWidth:= FWidth / NativeResW;
  RHeight:= FHeight / NativeResH;
  if (NativeResW / NativeResH) < (RWidth / RHeight) then
    ScRatio:= RWidth
  else
    ScRatio:= RHeight;

end;

//==============================================================================
// 0: Default
// 1: Left-Top
// 2: Right-Top
// 3: Left-Bottom
// 4: Right-Bottom
procedure SetDrawEdge(Edge: Byte);
begin

  case Edge of

    1: begin
         XSc:= 0;
         YSc:= 0;
       end;

    2: begin
         XSc:= o_Xsc * 2;
         YSc:= 0;
       end;

    3: begin
         XSc:= 0;
         YSc:= o_YSc * 2;
       end;

    4: begin
         XSc:= o_Xsc * 2;
         YSc:= o_YSc * 2;
       end;

  else

    XSc:= o_Xsc;
    YSc:= o_YSc;

  end;

end;

//==============================================================================
procedure ssprite2d_DrawSc( Texture : zglPTexture; X, Y, W, H, Angle : Single; Alpha : Byte = 255; FX : LongWord = FX_BLEND ); inline;
begin

  ssprite2d_Draw(Texture, XSc + (X * RWidth), YSc + (Y * RHeight), W * RWidth, H * RHeight, Angle, Alpha, FX);

end;

//==============================================================================
procedure pr2d_RectSc( X, Y, W, H : Single; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = 0 ); inline;
begin

  pr2d_Rect(XSc + (X * RWidth), YSc + (Y * RHeight), W * RWidth, H * RHeight, Color, Alpha, FX);

end;

//==============================================================================
procedure LayarGelap; inline;
begin

  pr2d_Rect(0, 0, SWidth, SHeight, $0, 127, PR2D_FILL);

end;

//==============================================================================
procedure TulisTeks(Text: string; font: zglPFont; X, Y: Single; Scale: Single);
var
  Ratot: Single;
  Xtot, Ytot: Single;
begin
  Ratot:= Scale * ScRatio;
  Xtot:= XSc + X * RWidth;
  Ytot:= YSc + Y * RHeight;
  text_DrawEx(font, Xtot-0.5, Ytot-0.5, Ratot, 0.0, Text, $FF, $000000);
  text_DrawEx(font, Xtot-0.5, Ytot+0.5, Ratot, 0.0, Text, $FF, $000000);
  text_DrawEx(font, Xtot+0.5, Ytot+0.5, Ratot, 0.0, Text, $FF, $000000);
  text_DrawEx(font, Xtot+0.5, Ytot-0.5, Ratot, 0.0, Text, $FF, $000000);
  text_DrawEx(font, Xtot, Ytot, Ratot, 0.0, Text);
end;

//==============================================================================
procedure TulisHint(Text: string; font: zglPFont; ScW, ScH: Single; Scale: Single);
var
  TxX, TxY: Single;
begin
  TxX:= (NativeResW - text_GetWidth(font, Text) - 8);
  TxY:= (NativeResH - text_GetHeight(font, TxX, Text));
  SetDrawEdge(4);
  try
    TulisTeks(Text, font, TxX, TxY, Scale);
  finally
    SetDrawEdge(0);
  end;
end;

//==============================================================================

procedure TulisStatus(Text: string; font: zglPFont; ScW, ScH: Single; Scale: Single);
var
  TxX, TxY: Single;
begin
  TxX:= (NativeResW - text_GetWidth(font, Text)) / 2;
  TxY:= 8;
  TulisTeks(Text, font, TxX, TxY, Scale);
end;

//==============================================================================

procedure TulisDiKotak(Text: string; font: zglPFont; Kotak: zglTRect; Scale: Single);
var
  NewRect: zglTRect;
begin

  NewRect.X:= XSc + Kotak.X * RWidth;
  NewRect.Y:= YSc + Kotak.Y * RHeight;
  NewRect.W:= Kotak.W * RWidth;
  NewRect.H:= Kotak.H * RHeight;
  text_DrawInRectEx(font, NewRect, Scale * ScRatio, 0.0, Text, $FF, $000000);

end;

//==============================================================================

end.
