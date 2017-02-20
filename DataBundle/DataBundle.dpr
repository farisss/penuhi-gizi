library DataBundle;

(*==============================================================================

  Khayalan Data Bundle
  Since 7 Juli 2013
  Port to fpc began from National Edication Day (2nd May 2014)
  Written by Faris Khowarizmi
  Copyright © Khayalan Software 2013-2014

  Website: http://www.khayalan.web.id
  e-Mail: thekill96@gmail.com

  Program ini dapat dikembangkan secara bebas.
  Penulis tidak bertanggung jawab atas kesalahan yang ditimbulkan oleh program
  ini!

==============================================================================*)

{$ifdef fpc}
  {$mode delphi}
{$endif}

uses
  {$IFDEF MSWINDOWS}
  FastShareMem,
  {$ENDIF}
  BundleCore in 'BundleCore.pas';

exports
  AssignReadBundle,
  CreateBundleFile,
  AssignWriteBundle,
  CloseBundle,
  FreeBundle,
  GetFileStruct,
  GetFileOnBundle,
  SetFileBundlePos,
  GetFileBundleSize,
  ReadBundleBuffer,
  ReadBundleFileToMemory,
  VerifyBundleFileChecksum;

{$R *.res}

begin
end.

