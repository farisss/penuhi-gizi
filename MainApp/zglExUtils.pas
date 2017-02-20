unit zglExUtils;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  SysUtils, GlobalUtils, BundleStruct,
  {$IFDEF ZGLDLL}
  zglHeader
  {$ELSE}
  zgl_textures,
  zgl_sound,
  zgl_memory
  {$ENDIF};

  function tex_LoadFromBundle(const Bund: PBundleDefinition; const FileName: string; TransparentColor : LongWord = TEX_NO_COLORKEY; Flags : LongWord = TEX_DEFAULT_2D) : zglPTexture;
  function snd_LoadFromBundle(const Bund: PBundleDefinition; const FileName : UTF8String; SourceCount : Integer = 8 ) : zglPSound;

implementation

//==============================================================================

function tex_LoadFromBundle(const Bund: PBundleDefinition; const FileName: string; TransparentColor : LongWord = TEX_NO_COLORKEY; Flags : LongWord = TEX_DEFAULT_2D) : zglPTexture;
var
  Mem: zglTMemory;
  ext: string;
begin

  Mem:= GetFileFromBundle(Bund, FileName);
  ext:= ExtractFileExt(FileName);
  ext:= UpperCase(Copy(ext, 2, Length(ext)-1));
  try
    Result:= tex_LoadFromMemory(Mem, ext, TransparentColor, Flags);
  finally
    FreeMem(Mem.Memory, Mem.Size);
  end;

end;

//==============================================================================

function snd_LoadFromBundle(const Bund: PBundleDefinition; const FileName : UTF8String; SourceCount : Integer = 8 ) : zglPSound;
var
  Mem: zglTMemory;
  ext: string;
begin

  Mem:= GetFileFromBundle(Bund, FileName);
  ext:= ExtractFileExt(FileName);
  ext:= UpperCase(Copy(ext, 2, Length(ext)-1));
  try
    Result:= snd_LoadFromMemory(Mem, ext, SourceCount);
  finally
    FreeMem(Mem.Memory, Mem.Size);
  end;

end;

//==============================================================================

end.
