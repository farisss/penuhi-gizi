
(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

// Application configuration switch

// Kalau sedang ditest, nyalakan saja
{.$DEFINE DEVMODE}

// Beta version
{$DEFINE BETA}

// Dynamic Linking
{$IFDEF MSWINDOWS}
  {$IFNDEF FPC}
    {$DEFINE ZGLDLL}
    {$DEFINE BUNDLL}
  {$ENDIF}
{$ENDIF}

// Wireframe isometric
{.$DEFINE CREATE_WF}

// Pakai ZlibEx daripada PasZlib
{$IFDEF MSWINDOWS}
  {$DEFINE USE_ZLIBEX}
{$ENDIF}

{$IFDEF FPC}
  {$UNDEF USE_ZLIBEX}
{$ENDIF}

// end...
