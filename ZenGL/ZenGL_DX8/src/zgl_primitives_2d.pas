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
unit zgl_primitives_2d;

{$I zgl_config.cfg}

interface
uses
  zgl_fx,
  zgl_textures,
  zgl_math_2d;

const
  PR2D_FILL   = $010000;
  PR2D_SMOOTH = $020000;

procedure pr2d_Pixel( X, Y : Single; Color : LongWord; Alpha : Byte = 255 );
procedure pr2d_Line( X1, Y1, X2, Y2 : Single; Color : LongWord; Alpha : Byte = 255; FX : LongWord = 0 );
procedure pr2d_Rect( X, Y, W, H : Single; Color : LongWord; Alpha : Byte = 255; FX : LongWord = 0 );
procedure pr2d_Circle( X, Y, Radius : Single; Color : LongWord; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
procedure pr2d_Ellipse( X, Y, xRadius, yRadius : Single; Color : LongWord; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
procedure pr2d_TriList( Texture : zglPTexture; TriList, TexCoords : zglPPoints2D; iLo, iHi : Integer; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = FX_BLEND );

implementation
uses
  zgl_direct3d_all,
  zgl_render_2d;

procedure pr2d_Pixel( X, Y : Single; Color : LongWord; Alpha : Byte = 255 );
begin
  if ( not b2dStarted ) or batch2d_Check( GL_POINTS, FX_BLEND, nil ) Then
    begin
      glEnable( GL_BLEND );
      glBegin( GL_POINTS );
    end;

  glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
  glVertex2f( X + 0.5, Y + 0.5 );

  if not b2dStarted Then
    begin
      glEnd();
      glDisable( GL_BLEND );
    end;
end;

procedure pr2d_Line( X1, Y1, X2, Y2 : Single; Color : LongWord; Alpha : Byte = 255; FX : LongWord = 0 );
begin
  if ( not b2dStarted ) or batch2d_Check( GL_LINES, FX_BLEND or FX, nil ) Then
    begin
      if FX and PR2D_SMOOTH > 0 Then
        begin
          glEnable( GL_LINE_SMOOTH    );
          glEnable( GL_POLYGON_SMOOTH );
        end;
      glEnable( GL_BLEND );

      glBegin( GL_LINES );
    end;

  if FX and FX2D_VCA > 0 Then
    begin
      glColor4ubv( @fx2dVCA1[ 0 ] );
      glVertex2f( X1 + 0.5, Y1 + 0.5 );
      glColor4ubv( @fx2dVCA2[ 0 ] );
      glVertex2f( X2 + 0.5, Y2 + 0.5 );
    end else
      begin
        glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
        glVertex2f( X1 + 0.5, Y1 + 0.5 );
        glVertex2f( X2 + 0.5, Y2 + 0.5 );
      end;

  if not b2dStarted Then
    begin
      glEnd();

      if FX and PR2D_SMOOTH > 0 Then
        begin
          glDisable( GL_LINE_SMOOTH    );
          glDisable( GL_POLYGON_SMOOTH );
        end;
      glDisable( GL_BLEND );
    end;
end;

procedure pr2d_Rect( X, Y, W, H : Single; Color : LongWord; Alpha : Byte = 255; FX : LongWord = 0 );
begin
  if FX and PR2D_FILL > 0 Then
    begin
      if ( not b2dStarted ) or batch2d_Check( GL_TRIANGLES, FX_BLEND or FX, nil ) Then
        begin
          if FX and PR2D_SMOOTH > 0 Then
            begin
              glEnable( GL_LINE_SMOOTH    );
              glEnable( GL_POLYGON_SMOOTH );
            end;
          glEnable( GL_BLEND );
          glBegin( GL_TRIANGLES );
        end;

      if FX and FX2D_VCA > 0 Then
        begin
          glColor4ubv( @fx2dVCA1[ 0 ] );
          glVertex2f( X,     Y );

          glColor4ubv( @fx2dVCA2[ 0 ] );
          glVertex2f( X + W, Y );

          glColor4ubv( @fx2dVCA3[ 0 ] );
          glVertex2f( X + W, Y + H );

          glColor4ubv( @fx2dVCA3[ 0 ] );
          glVertex2f( X + W, Y + H );

          glColor4ubv( @fx2dVCA4[ 0 ] );
          glVertex2f( X,     Y + H );

          glColor4ubv( @fx2dVCA1[ 0 ] );
          glVertex2f( X,     Y );
        end else
          begin
            glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
            glVertex2f( X,     Y );
            glVertex2f( X + W, Y );
            glVertex2f( X + W, Y + H );
            glVertex2f( X + W, Y + H );
            glVertex2f( X,     Y + H );
            glVertex2f( X,     Y );
          end;

      if not b2dStarted Then
        begin
          glEnd();

          if FX and PR2D_SMOOTH > 0 Then
            begin
              glDisable( GL_LINE_SMOOTH    );
              glDisable( GL_POLYGON_SMOOTH );
            end;
          glDisable( GL_BLEND );
        end;
   end else
    begin
      X := X + 0.5;
      Y := Y + 0.5;
      W := W - 1;
      H := H - 1;

      if ( not b2dStarted ) or batch2d_Check( GL_LINES, FX_BLEND or FX, nil ) Then
        begin
          if FX and PR2D_SMOOTH > 0 Then
            begin
              glEnable( GL_LINE_SMOOTH    );
              glEnable( GL_POLYGON_SMOOTH );
            end;

          glEnable( GL_BLEND );
          glBegin( GL_LINES );
        end;

      if FX and FX2D_VCA > 0 Then
        begin
          glColor4ubv( @fx2dVCA1[ 0 ] );
          glVertex2f( X,     Y );

          glColor4ubv( @fx2dVCA2[ 0 ] );
          glVertex2f( X + W, Y );

          glVertex2f( X + W, Y );
          glColor4ubv( @fx2dVCA3[ 0 ] );
          glVertex2f( X + W, Y + H );

          glVertex2f( X + W, Y + H );
          glColor4ubv( @fx2dVCA4[ 0 ] );
          glVertex2f( X,     Y + H );

          glVertex2f( X,     Y + H );
          glColor4ubv( @fx2dVCA1[ 0 ] );
          glVertex2f( X,     Y );
        end else
          begin
            glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
            glVertex2f( X,     Y );
            glVertex2f( X + W, Y );

            glVertex2f( X + W, Y );
            glVertex2f( X + W, Y + H );

            glVertex2f( X + W, Y + H );
            glVertex2f( X,     Y + H );

            glVertex2f( X,     Y + H );
            glVertex2f( X,     Y );
          end;

      if not b2dStarted Then
        begin
          if FX and PR2D_SMOOTH > 0 Then
            begin
              glDisable( GL_LINE_SMOOTH    );
              glDisable( GL_POLYGON_SMOOTH );
            end;
          glEnd();
          glDisable( GL_BLEND );
        end;
    end;
end;

procedure pr2d_Circle( X, Y, Radius : Single; Color : LongWord; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
  var
    i : Integer;
    k : Single;
begin
  if Quality > 360 Then
    k := 360
  else
    k := 360 / Quality;

  if FX and PR2D_FILL = 0 Then
    begin
      if ( not b2dStarted ) or batch2d_Check( GL_LINES, FX_BLEND or FX, nil ) Then
        begin
          if FX and PR2D_SMOOTH > 0 Then
            begin
              glEnable( GL_LINE_SMOOTH    );
              glEnable( GL_POLYGON_SMOOTH );
            end;
          glEnable( GL_BLEND );

          glBegin( GL_LINES );
        end;

      glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
      for i := 0 to Quality - 1 do
        begin
          glVertex2f( X + Radius * cosTable[ Round( i * k ) ], Y + Radius * sinTable[ Round( i * k ) ] );
          glVertex2f( X + Radius * cosTable[ Round( ( i + 1 ) * k ) ], Y + Radius * sinTable[ Round( ( i + 1 ) * k ) ] );
        end;

      if not b2dStarted Then
        begin
          glEnd();

          if FX and PR2D_SMOOTH > 0 Then
            begin
              glDisable( GL_LINE_SMOOTH    );
              glDisable( GL_POLYGON_SMOOTH );
            end;
          glDisable( GL_BLEND );
        end;
    end else
      begin
        if ( not b2dStarted ) or batch2d_Check( GL_TRIANGLES, FX_BLEND or FX, nil ) Then
          begin
            if FX and PR2D_SMOOTH > 0 Then
              begin
                glEnable( GL_LINE_SMOOTH    );
                glEnable( GL_POLYGON_SMOOTH );
              end;
            glEnable( GL_BLEND );

            glBegin( GL_TRIANGLES );
          end;

        glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
        for i := 0 to Quality - 1 do
          begin
            glVertex2f( X, Y );
            glVertex2f( X + Radius * cosTable[ Round( i * k ) ], Y + Radius * sinTable[ Round( i * k ) ] );
            glVertex2f( X + Radius * cosTable[ Round( ( i + 1 ) * k ) ], Y + Radius * sinTable[ Round( ( i + 1 ) * k ) ] );
          end;

        if not b2dStarted Then
          begin
            glEnd();

            if FX and PR2D_SMOOTH > 0 Then
              begin
                glDisable( GL_LINE_SMOOTH    );
                glDisable( GL_POLYGON_SMOOTH );
              end;
            glDisable( GL_BLEND );
          end;
      end;
end;

procedure pr2d_Ellipse( X, Y, xRadius, yRadius : Single; Color : LongWord; Alpha : Byte = 255; Quality : Word = 32; FX : LongWord = 0 );
  var
    i : Integer;
    k : Single;
begin
  if Quality > 360 Then
    k := 360
  else
    k := 360 / Quality;

  if FX and PR2D_FILL = 0 Then
    begin
      if ( not b2dStarted ) or batch2d_Check( GL_LINES, FX_BLEND or FX, nil ) Then
        begin
          if FX and PR2D_SMOOTH > 0 Then
            begin
              glEnable( GL_LINE_SMOOTH    );
              glEnable( GL_POLYGON_SMOOTH );
            end;
          glEnable( GL_BLEND );

          glBegin( GL_LINES );
        end;

      glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
      for i := 0 to Quality - 1 do
        begin
          glVertex2f( X + xRadius * cosTable[ Round( i * k ) ], Y + yRadius * sinTable[ Round( i * k ) ] );
          glVertex2f( X + xRadius * cosTable[ Round( ( i + 1 ) * k ) ], Y + yRadius * sinTable[ Round( ( i + 1 ) * k ) ] );
        end;

      if not b2dStarted Then
        begin
          glEnd();

          if FX and PR2D_SMOOTH > 0 Then
            begin
              glDisable( GL_LINE_SMOOTH    );
              glDisable( GL_POLYGON_SMOOTH );
            end;
          glDisable( GL_BLEND );
        end;
    end else
      begin
        if ( not b2dStarted ) or batch2d_Check( GL_TRIANGLES, FX_BLEND or FX, nil ) Then
          begin
            if FX and PR2D_SMOOTH > 0 Then
              begin
                glEnable( GL_LINE_SMOOTH    );
                glEnable( GL_POLYGON_SMOOTH );
              end;
            glEnable( GL_BLEND );

            glBegin( GL_TRIANGLES );
          end;

        glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );
        for i := 0 to Quality - 1 do
          begin
            glVertex2f( X, Y );
            glVertex2f( X + xRadius * cosTable[ Round( i * k ) ], Y + yRadius * sinTable[ Round( i * k ) ] );
            glVertex2f( X + xRadius * cosTable[ Round( ( i + 1 ) * k ) ], Y + yRadius * sinTable[ Round( ( i + 1 ) * k ) ] );
          end;

        if not b2dStarted Then
          begin
            glEnd();

            if FX and PR2D_SMOOTH > 0 Then
              begin
                glDisable( GL_LINE_SMOOTH    );
                glDisable( GL_POLYGON_SMOOTH );
              end;
            glDisable( GL_BLEND );
          end;
      end;
end;

procedure pr2d_TriList( Texture : zglPTexture; TriList, TexCoords : zglPPoints2D; iLo, iHi : Integer; Color : LongWord = $FFFFFF; Alpha : Byte = 255; FX : LongWord = FX_BLEND );
  var
    i    : Integer;
    w, h : Single;
    mode : LongWord;
begin
  if FX and PR2D_FILL > 0 Then
    mode := GL_TRIANGLES
  else
    mode := GL_LINES;
  if ( not b2dStarted ) or batch2d_Check( mode, FX, Texture ) Then
    begin
      if FX and PR2D_SMOOTH > 0 Then
        begin
          glEnable( GL_LINE_SMOOTH    );
          glEnable( GL_POLYGON_SMOOTH );
        end;
      if ( FX and FX_BLEND > 0 ) or ( mode = GL_LINES ) Then
        glEnable( GL_BLEND )
      else
        glEnable( GL_ALPHA_TEST );

      if Assigned( Texture ) and ( mode = GL_TRIANGLES ) Then
        begin
          glEnable( GL_TEXTURE_2D );
          glBindTexture( GL_TEXTURE_2D, Texture.ID );
        end;

      glBegin( mode );
    end;

  glColor4ub( ( Color and $FF0000 ) shr 16, ( Color and $FF00 ) shr 8, Color and $FF, Alpha );

  if Assigned( Texture ) and ( mode = GL_TRIANGLES ) Then
    begin
      if not Assigned( TexCoords ) Then
        begin
          w := 1 / ( Texture.Width / Texture.U );
          h := 1 / ( Texture.Height / Texture.V );
          for i := iLo to iHi do
            begin
              glTexCoord2f( TriList[ i ].X * w, Texture.V - TriList[ i ].Y * h );
              glVertex2fv( @TriList[ i ] );
            end;
        end else
          for i := iLo to iHi do
            begin
              glTexCoord2fv( @TexCoords[ i ] );
              glVertex2fv( @TriList[ i ] );
            end;
    end else
      if Mode = GL_TRIANGLES Then
        begin
          for i := iLo to iHi do
            glVertex2fv( @TriList[ i ] );
        end else
          begin
            i := iLo;
            while i < iHi do
              begin
                glVertex2fv( @TriList[ i ] );
                glVertex2fv( @TriList[ i + 1 ] );
                INC( i );

                glVertex2fv( @TriList[ i ] );
                glVertex2fv( @TriList[ i + 1 ] );
                INC( i );

                glVertex2fv( @TriList[ i ] );
                glVertex2fv( @TriList[ i - 2 ] );
                INC( i );
              end;
          end;

  if not b2dStarted Then
    begin
      glEnd();

      if FX and PR2D_SMOOTH > 0 Then
        begin
          glDisable( GL_LINE_SMOOTH    );
          glDisable( GL_POLYGON_SMOOTH );
        end;
      if mode = GL_TRIANGLES Then
        glDisable( GL_TEXTURE_2D );
      glDisable( GL_BLEND );
      glDisable( GL_ALPHA_TEST );
    end;
end;

end.
