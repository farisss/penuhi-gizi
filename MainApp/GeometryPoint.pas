unit GeometryPoint;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  SysUtils, Math, GlobalTypes, GlobalUtils,
  {$IFDEF USE_ZLIBEX}
  ZlibEx
  {$ELSE}
  DZlib
  {$ENDIF};

  function  GetGeometryIndex(GeoPointer: PGPIHeader; X, Y: integer): Byte;
  function  GetGeometryIndexScale(GeoPointer: PGPIHeader; X, Y: integer; W, H: integer): Byte;
  procedure GetNearestPoint(GeoPointer: PGPIHeader; Index: integer; var X, Y: integer);
  procedure GetNearestPointScale(GeoPointer: PGPIHeader; Index: integer; var X, Y: integer; W, H: integer);
  function  LoadGeometryFromFile(Location: string): PGPIHeader;
  procedure UnloadGeometry(var Geometry: PGPIHeader);

implementation

//==============================================================================

function GetGeometryIndex(GeoPointer: PGPIHeader; X, Y: integer): Byte;
var
  loc: LongInt;
  Rs: PByte;
begin

  if InRange(X, 0, GeoPointer^.Width-1) and InRange(Y, 0, GeoPointer^.Height-1) then
    begin
    loc:= ((GeoPointer^.Height - Y - 1) * GeoPointer^.Width) + X;
    Rs:= Pointer(LongInt(GeoPointer) + 8 + loc);
    Result:= Rs^;
  end
  else
    Result:= $FF;

end;

//==============================================================================
function GetGeometryIndexScale(GeoPointer: PGPIHeader; X, Y: integer; W, H: integer): Byte;
var
  rx, ry: integer;
begin
  rx:= Round(X * (GeoPointer^.Width / W));
  ry:= Round(Y * (GeoPointer^.Height / H));
  Result:= GetGeometryIndex(GeoPointer, rx, ry);
end;

//==============================================================================

procedure GetNearestPoint(GeoPointer: PGPIHeader; Index: integer; var X, Y: integer);
var
  ex, ye: integer;
  nx, ny: integer;
  Rs: PByte;
begin

  nx:= GeoPointer^.Width;
  ny:= GeoPointer^.Height;
  Rs:= Pointer(LongInt(GeoPointer) + 8);
  for ye:= GeoPointer^.Height-1 downto 0 do
    for ex:= 0 to GeoPointer^.Width-1 do
      begin
      if Rs^ = Index then
        begin
        if ex < nx then
          nx:= ex;
        if ye < ny then
          ny:= ye
      end;
      Rs:= Pointer(LongInt(Rs) + 1);
    end;
  X:= nx;
  Y:= ny;

end;

//==============================================================================
procedure GetNearestPointScale(GeoPointer: PGPIHeader; Index: integer; var X, Y: integer; W, H: integer);
var
  rx, ry: integer;
begin

  GetNearestPoint(GeoPointer, Index, rx, ry);
  X:= Round(rx * (W / GeoPointer^.Width));
  Y:= Round(ry * (H / GeoPointer^.Height));

end;

//==============================================================================

function LoadGeometryFromFile(Location: string): PGPIHeader;
var
  fi: file;
  UnSz, fsz: LongInt;
  fcm, gout: Pointer;
  {$IFDEF USE_ZLIBEX}
  ousz: Integer;
  {$ENDIF}
begin

  {$I-}
  AssignFile(fi, Location);
  try
    Reset(fi, 1);
    fsz:= FileSize(fi) - SizeOf(LongInt);
    BlockRead(fi, UnSz, SizeOf(LongInt));
    GetMem(fcm, fsz);
    try
      BlockRead(fi, fcm^, fsz);
      {$IFDEF USE_ZLIBEX}
      ZDecompress(fcm, fsz, Pointer(gout), ousz);
      AssertX(UnSz = ousz, 'Error to load GPI: Decompression buffer mismatch!');
      {$ELSE}
      GetMem(gout, UnSz);
      DecompressToUserBuf(fcm, fsz, gout, UnSz);
      {$ENDIF}
      LogOut(Format('Loaded GPI file: %s', [ExtractFileName(Location)]));
    finally
      FreeMem(fcm, fsz);
    end;
  finally
    CloseFile(fi);
  end;
  {$I+}
  Result:= gout;

end;

//==============================================================================

procedure UnloadGeometry(var Geometry: PGPIHeader);
begin

  FreeMem(Geometry, Geometry^.Width * Geometry^.Height + SizeOf(TGPIHeader));
  Geometry:= nil;

end;

end.
