unit GameInfo;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  SysUtils, GlobalTypes, GlobalUtils,
  {$IFDEF USE_ZLIBEX}
  ZlibEx
  {$ELSE}
  DZlib
  {$ENDIF};

  function  LoadPlacesFromFile(var Places: PGPlaces; Location: string): boolean;
  procedure UnloadPlaces(var Places: PGPlaces);

implementation

//==============================================================================

function LoadPlacesFromFile(var Places: PGPlaces; Location: string): boolean;
var
  fi: file;
  fsz: LongInt;
  fcm: Pointer;
  pout: PGPlaces;
  {$IFDEF USE_ZLIBEX}
  ousz: Integer;
  {$ENDIF}
begin

  try
    {$I-}
    AssignFile(fi, Location);
    try
      Reset(fi, 1);
      fsz:= FileSize(fi);
      GetMem(fcm, fsz);
      try
        BlockRead(fi, fcm^, fsz);
        {$IFDEF USE_ZLIBEX}
        ZDecompress(fcm, fsz, Pointer(pout), ousz);
        AssertX(SizeOf(TGPlaces) = ousz, 'Error to load GSD: Decompression buffer mismatch!');
        {$ELSE}
        GetMem(pout, SizeOf(TGPlaces));
        DecompressToUserBuf(fcm, fsz, pout, SizeOf(TGPlaces));
        {$ENDIF}
        Places:= pout;
        Result:= TRUE;
        LogOut(Format('Loaded GSD file: %s', [ExtractFileName(Location)]));
      finally
        FreeMem(fcm, fsz);
      end;
    finally
      CloseFile(fi);
    end;
    {$I+}
  except
    Result:= FALSE;
  end;

end;

//==============================================================================

procedure UnloadPlaces(var Places: PGPlaces);
begin
  FreeMem(Places, SizeOf(TGPlaces));
end;

//==============================================================================

end.
