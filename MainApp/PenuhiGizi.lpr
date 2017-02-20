program PenuhiGizi;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

{$I AppConf.inc}

{$IFDEF DEVMODE}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFNDEF FPC}
  {$IFDEF MSWINDOWS}
  FastShareMem,
  {$ENDIF}
  {$ENDIF} 
  SysUtils,
  // ZenGL
  {$IFDEF ZGLDLL}
  zglHeader,
  {$ELSE}
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_utils,
  {$ENDIF}
  Windows,
  GlobalConst in 'GlobalConst.pas',
  GlobalStrings in 'GlobalStrings.pas',
  GlobalUtils in 'GlobalUtils.pas',
  GameGlobal in 'GameGlobal.pas',
  GlobalTypes in 'GlobalTypes.pas',
  GeometryPoint in 'GeometryPoint.pas',
  GlobalDraw in 'GlobalDraw.pas',
  GameInfo in 'GameInfo.pas',
  GameSave in 'GameSave.pas',
  zglExUtils in 'zglExUtils.pas';

{$R *.res}

//==============================================================================

procedure CounterTimer;
begin
  {$IFDEF BETA}
  wnd_SetCaption(AnsiToUTF8(Format('%s (Beta) [fps:%d]', [AppName, zgl_Get(RENDER_FPS)])));
  {$ELSE}
  wnd_SetCaption(AnsiToUTF8(Format('%s [fps:%d]', [AppName, zgl_Get(RENDER_FPS)])));
  {$ENDIF}
end;

//==============================================================================

var
  f: File;
  {$IFDEF ZGLDLL}
  DirApp: string;
  {$ENDIF}
  InstMutex: THandle;
begin

  {$IFDEF MSWINDOWS}
  InstMutex:= CreateMutex(nil, TRUE, PChar(AppGUID));
  if GetLastError = ERROR_ALREADY_EXISTS then
    begin
    MessageBox(GetForegroundWindow, PChar(Format(msg_IsRunning, [AppName])), PChar(cap_Error), MB_ICONERROR);
    ExitProcess(0);
  end;
  {$ENDIF}

  try

    {$IFDEF DEVMODE}
    Writeln('Game - Penuhi Gizi!');
    Writeln('Copyright (C) Team Fajar Harapan 2015');
    Writeln('Coded by Faris Khowarizmi');
    Writeln('');
    Writeln('DataBundle module, Copyright (C) Faris Khowarizmi 2011 - 2014');
    Writeln('ZenGL module, Copyright (C) Andrey Kemka a.k.a Andru');
    Writeln('');
    {$ENDIF}

    FillChar(GameConf, SizeOf(TGameConfig), 0);
    {$I-}
    AssignFile(f, ChangeFileExt(ParamStr(0), '.cfg'));
    Reset(f, 1);
    if FileSize(f) = SizeOf(TGameConfig) then
      BlockRead(f, GameConf, SizeOf(TGameConfig))
    else
      begin
      GameConf.DispWidth:= NativeResWi;
      GameConf.DispHeight:= NativeResHi;
      GameConf.DispFullScreen:= TRUE;
      GameConf.GraphRenderIndex:= 1;
      GameConf.VSync:= TRUE;
      GameConf.SoundOn:= TRUE;
      GameConf.FSAAMul:= 0;
      ReWrite(f, 1);
      BlockWrite(f, GameConf, SizeOf(TGameConfig));
    end;
    CloseFile(f);
    {$I+}

    {$IFDEF ZGLDLL}
    DirApp:= ExtractFilePath(ParamStr(0));

    case GameConf.GraphRenderIndex of
      0:
        begin
          Assert(zglLoad(DirApp + ZenGL_D3D8), Format(msg_NoLib, [ZenGL_D3D8]));
          {$IFDEF DEVMODE}Writeln('Loadded as Direct3D 8 Rendering Engine');{$ENDIF}
        end;
      1:
        begin
          Assert(zglLoad(DirApp + ZenGL_D3D9), Format(msg_NoLib, [ZenGL_D3D9]));
          {$IFDEF DEVMODE}Writeln('Loadded as Direct3D 9 Rendering Engine');{$ENDIF}
        end;
    else
      Assert(zglLoad(DirApp + ZenGL_OGL), Format(msg_NoLib, [ZenGL_OGL]));
      {$IFDEF DEVMODE}Writeln('Loadded as OpenGL Rendering Engine');{$ENDIF}
    end;
    {$IFDEF DEVMODE}Writeln('');{$ENDIF}
    {$ENDIF}

    try

      // tambah timer fps
      timer_Add(@CounterTimer, 1000);

      zgl_Reg(SYS_LOAD, @GameInit);
      zgl_Reg(SYS_DRAW, @GameDraw);
      zgl_Reg(SYS_UPDATE, @GameUpdate);
      zgl_Reg(SYS_EXIT, @GameExit);

      wnd_SetCaption(AppName);
      wnd_ShowCursor(TRUE);

      scr_SetOptions(GameConf.DispWidth, GameConf.DispHeight, REFRESH_MAXIMUM, GameConf.DispFullScreen, GameConf.VSync);

      zgl_Disable(APP_USE_AUTOPAUSE);
      zgl_Init(GameConf.FSAAMul);

    finally

      {$IFDEF ZGLDLL}
      zglFree();
      {$ENDIF}

    end;

  finally

    {$IFDEF MSWINDOWS}
    ReleaseMutex(InstMutex);
    {$ENDIF}

  end;

end.
