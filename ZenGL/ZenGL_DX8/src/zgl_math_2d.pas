{
 *  Copyright (c) 2012 Andrey Kemka
 *
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *     you must not claim that you wrote the original software.
 *     If you use this software in a product, an acknowledgment
 *     in the product documentation would be appreciated but
 *     is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *     and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *     source distribution.
}
unit zgl_math_2d;

{$I zgl_config.cfg}

interface

const
  EPS = 0.000001;

  pi      = 3.141592654;
  rad2deg = 57.29578049;
  deg2rad = 0.017453292;

  ORIENTATION_LEFT  = -1;
  ORIENTATION_RIGHT = 1;
  ORIENTATION_ZERO  = 0;

type
  zglPPoint2D = ^zglTPoint2D;
  zglTPoint2D = record
    X, Y : Single;
end;

type
  zglPPoints2D = ^zglTPoints2D;
  zglTPoints2D = array[ 0..0 ] of zglTPoint2D;

type
  zglPLine = ^zglTLine;
  zglTLine = record
    x0, y0 : Single;
    x1, y1 : Single;
end;

type
  zglPRect = ^zglTRect;
  zglTRect = record
    X, Y, W, H : Single;
end;

type
  zglPCircle = ^zglTCircle;
  zglTCircle = record
    cX, cY : Single;
    Radius : Single;
end;

function min( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
function max( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}

procedure m_SinCos( Angle : Single; out s, c : Single ); {$IFDEF USE_ASM} assembler; {$ELSE} {$IFDEF USE_INLINE} inline; {$ENDIF} {$ENDIF}

procedure InitCosSinTables;
function  m_Cos( Angle : Integer ) : Single;
function  m_Sin( Angle : Integer ) : Single;
function  m_Distance( x1, y1, x2, y2 : Single ) : Single;
function  m_FDistance( x1, y1, x2, y2 : Single ) : Single;
function  m_Angle( x1, y1, x2, y2 : Single ) : Single;
function  m_Orientation( x, y, x1, y1, x2, y2 : Single ) : Integer;

{$IFDEF USE_TRIANGULATION}
procedure tess_Triangulate( Contour : zglPPoints2D; iLo, iHi : Integer; AddHoles : Boolean = FALSE );
procedure tess_AddHole( Contour : zglPPoints2D; iLo, iHi : Integer; LastHole : Boolean = TRUE );
function  tess_GetData( out TriPoints : zglPPoints2D ) : Integer;
{$ENDIF}

var
  cosTable : array[ 0..360 ] of Single;
  sinTable : array[ 0..360 ] of Single;

implementation
uses
  zgl_main,
  zgl_direct3d_all;

{$IFDEF USE_TRIANGULATION}
var
  tess        : Integer;
  tessMode    : Integer;
  tessHoles   : Boolean;
  tessFinish  : Boolean;
  tessCurrent : Integer;
  tessVertex  : array[ 0..2 ] of zglTPoint2D;
  tessVCount  : Integer;
  tessVerts   : array of zglTPoint2D;
{$ENDIF}

function ArcTan2( dx, dy : Single ) : Single;
begin
  Result := abs( ArcTan( dy / dx ) * ( 180 / pi ) );
end;

function min( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
begin
  if a > b Then Result := b else Result := a;
end;

function max( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
begin
  if a > b Then Result := a else Result := b;
end;

procedure m_SinCos( Angle : Single; out s, c : Single ); {$IFDEF USE_ASM} assembler; {$ELSE} {$IFDEF USE_INLINE} inline; {$ENDIF} {$ENDIF}
{$IFDEF USE_ASM}
asm
{$IFDEF CPUi386}
  FLD Angle
  FSINCOS
  FSTP [EDX]
  FSTP [EAX]
{$ENDIF}
end;
{$ELSE}
begin
  s := Sin( Angle );
  c := Cos( Angle );
end;
{$ENDIF}

procedure InitCosSinTables;
  var
    i         : Integer;
    rad_angle : Single;
begin
  for i := 0 to 360 do
    begin
      rad_angle := i * ( pi / 180 );
      cosTable[ i ] := cos( rad_angle );
      sinTable[ i ] := sin( rad_angle );
    end;
end;

function m_Cos( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := cosTable[ Angle ];
end;

function m_Sin( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := sinTable[ Angle ];
end;

function m_Distance( x1, y1, x2, y2 : Single ) : Single;
begin
  Result := sqrt( sqr( x1 - x2 ) + sqr( y1 - y2 ) );
end;

function m_FDistance( x1, y1, x2, y2 : Single ) : Single;
begin
  Result := sqr( x1 - x2 ) + sqr( y1 - y2 );
end;

function m_Angle( x1, y1, x2, y2 : Single ) : Single;
  var
    dx, dy : Single;
begin
  dx := ( X1 - X2 );
  dy := ( Y1 - Y2 );

  if dx = 0 Then
    begin
      if dy > 0 Then
        Result := 90
      else
        Result := 270;
      exit;
    end;

  if dy = 0 Then
    begin
      if dx > 0 Then
        Result := 0
      else
        Result := 180;
      exit;
    end;

  if ( dx < 0 ) and ( dy > 0 ) Then
    Result := 180 - ArcTan2( dx, dy )
  else
    if ( dx < 0 ) and ( dy < 0 ) Then
      Result := 180 + ArcTan2( dx, dy )
    else
      if ( dx > 0 ) and ( dy < 0 ) Then
        Result := 360 - ArcTan2( dx, dy )
      else
        Result := ArcTan2( dx, dy )
end;

function m_Orientation( x, y, x1, y1, x2, y2 : Single ) : Integer;
  var
    orientation : Single;
begin
  orientation := ( x2 - x1 ) * ( y - y1 ) - ( x - x1 ) * ( y2 - y1 );

  if orientation > 0 Then
    Result := ORIENTATION_RIGHT
  else
    if orientation < 0 Then
      Result := ORIENTATION_LEFT
    else
      Result := ORIENTATION_ZERO;
end;

// GLU Triangulation
{$IFDEF USE_TRIANGULATION}
procedure tessBegin( Mode : Integer ); stdcall;
begin
  tessMode    := Mode;
  tessCurrent := 0;
end;

procedure tessVertex2f( Vertex : zglPPoint2D ); stdcall;
begin
  if not Assigned( Vertex ) Then exit;

  if tessVCount + 3 > Length( tessVerts ) Then
    SetLength( tessVerts, Length( tessVerts ) + 65536 );

  tessVertex[ tessCurrent ] := Vertex^;
  INC( tessCurrent );
  if tessCurrent <> 3 Then exit;

  case tessMode of
    GL_TRIANGLES:
      begin
        tessVerts[ tessVCount ] := tessVertex[ 0 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 1 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 2 ]; INC( tessVCount );

        tessCurrent := 0;
      end;
    GL_TRIANGLE_STRIP:
      begin
        tessVerts[ tessVCount ] := tessVertex[ 1 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 2 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 0 ]; INC( tessVCount );

        tessVertex[ 0 ] := tessVertex[ 1 ];
        tessVertex[ 1 ] := tessVertex[ 2 ];
        tessCurrent    := 2;
      end;
    GL_TRIANGLE_FAN:
      begin
        tessVerts[ tessVCount ] := tessVertex[ 0 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 1 ]; INC( tessVCount );
        tessVerts[ tessVCount ] := tessVertex[ 2 ]; INC( tessVCount );

        tessVertex[ 1 ] := tessVertex[ 2 ];
        tessCurrent    := 2;
      end;
  end;
end;

procedure tess_Triangulate( Contour : zglPPoints2D; iLo, iHi : Integer; AddHoles : Boolean = FALSE );
  var
    i : Integer;
    v : array[ 0..2 ] of Double;
begin
  tessFinish  := FALSE;
  tessHoles   := AddHoles;
  tessVCount  := 0;
  tessCurrent := 0;
  v[ 2 ]      := 0;

  gluTessBeginPolygon( tess, nil );
  gluTessBeginContour( tess );
  for i := iLo to iHi do
    begin
      v[ 0 ] := Contour[ i ].X;
      v[ 1 ] := Contour[ i ].Y;
      gluTessVertex( tess, @v[ 0 ], @Contour[ i ] );
    end;
  gluTessEndContour( tess );
  if not AddHoles Then
    gluTessEndPolygon( tess );
end;

procedure tess_AddHole( Contour : zglPPoints2D; iLo, iHi : Integer; LastHole : Boolean = TRUE );
  var
    i : Integer;
    v : array[ 0..2 ] of Double;
begin
  if not tessHoles Then exit;
  v[ 2 ] := 0;

  gluTessBeginContour( tess );
  for i := iLo to iHi do
    begin
      v[ 0 ] := Contour[ i ].X;
      v[ 1 ] := Contour[ i ].Y;
      gluTessVertex( tess, @v[ 0 ], @Contour[ i ] );
    end;
  gluTessEndContour( tess );
  if LastHole Then
    begin
      tessFinish := TRUE;
      tessHoles  := FALSE;
      gluTessEndPolygon( tess );
    end;
end;

function tess_GetData( out TriPoints : zglPPoints2D ) : Integer;
begin
  if not tessFinish Then
    begin
      tessFinish := TRUE;
      gluTessEndPolygon( tess );
    end;
  if tessVCount > 0 Then
    begin
      zgl_GetMem( Pointer( TriPoints ), tessVCount * SizeOf( zglTPoint2D ) );
      Move( tessVerts[ 0 ], TriPoints[ 0 ], tessVCount * SizeOf( zglTPoint2D ) );
      Result := tessVCount;
    end else
      Result := 0;
end;
{$ENDIF}

initialization
  InitCosSinTables();
  {$IFDEF USE_TRIANGULATION}
  tess := gluNewTess();
  gluTessCallBack( tess, GLU_TESS_BEGIN,  @tessBegin    );
  gluTessCallBack( tess, GLU_TESS_VERTEX, @tessVertex2f );
  {$ENDIF}

finalization
  {$IFDEF USE_TRIANGULATION}
  gluDeleteTess( tess );
  {$ENDIF}

end.
