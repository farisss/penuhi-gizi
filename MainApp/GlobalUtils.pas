unit GlobalUtils;

(*==============================================================================

  Project Penuhi Gizi! game
  Copyright © Team Fajar Harapan 2015
  Coded by Faris Khowarizmi

  e-Mail: thekill96@gmail.com

==============================================================================*)

interface

{$I AppConf.inc}

uses
  Windows, SysUtils, GlobalTypes, GlobalConst, GlobalStrings,
  BundleStruct,
  {$IFDEF BUNDLL}
  BundleProcs,
  {$ELSE}
  BundleCore,
  {$ENDIF}
  {$IFDEF ZGLDLL}
  zglHeader
  {$ELSE}
  zgl_main,
  zgl_log,
  zgl_memory
  {$ENDIF};

  procedure LogOut(Log: string);
  procedure AssertX(Condition: boolean; Msg: string);
  function  GetFileFromBundle(BHandle: PBundleDefinition; Name: string): zglTMemory;
  procedure KocokDadu(var dadu1, dadu2: Byte);
  procedure AspectRatio(const AreaW, AreaH, OldW, OldH: Single; var W, H, L, T: Single);
  function  HitungTick(TickBegin: Double): Double;

implementation

//==============================================================================

procedure LogOut(Log: string); inline;
begin
  log_Add(AnsiToUTF8(Log));
  {$IFDEF DEVMODE}
  Writeln(Log);
  {$ENDIF}
end;

//==============================================================================

procedure AssertX(Condition: boolean; Msg: string);
var
  Parent: HWND;
  zenglWnd: boolean;
begin
  if not Condition then
    begin
    zenglWnd:= @zgl_Get <> nil;
    if zenglWnd then
      Parent:= DWORD(zgl_Get(WINDOW_HANDLE))
    else
      Parent:= GetForegroundWindow;
    ShowWindow(Parent*DWORD(zenglWnd), SW_HIDE);
    try
      LogOut(Msg);
      if MessageBox(Parent, PChar(Format(msg_AssertMsg, [Msg])), PChar(cap_AssertError), MB_ICONSTOP or MB_YESNO or MB_DEFBUTTON1) = IDNO then
        begin
        {$IFDEF MSWINDOWS}
        ExitProcess(0);
        {$ELSE}
        Halt;
        {$ENDIF}
      end;
    finally
      ShowWindow(Parent*DWORD(zenglWnd), SW_SHOW);
    end;
  end;
end;

//==============================================================================

function GetFileFromBundle(BHandle: PBundleDefinition; Name: string): zglTMemory;
var
  BunIdx: integer;
begin
  BunIdx:= GetFileOnBundle(BHandle, PChar(Name));
  AssertX(BunIdx >= 0, Format(msg_NoFBund, [Name]));
  LogOut('Read file from bundle: ' + Name);
  ReadBundleFileToMemory(BHandle, BunIdx, Result.Memory, Result.Size);
  Result.Position:= 0;
end;

//==============================================================================
procedure KocokDadu(var dadu1, dadu2: Byte);
var
  ch: ByteBool;
  d2: ShortInt;
begin

  Randomize();
  dadu1:= Random(6) + 1;
  Randomize();
  ch:= ByteBool(Random(2));
  //Randomize();
  if ch then
    d2:= dadu1 + Random(6) + 1
  else
    d2:= dadu1 - Random(6) - 1;
  if d2 > 6 then
    d2:= d2 - 6
  else
  if d2 < 1 then
    d2:= d2 + 6;
  dadu2:= d2;

end;

//==============================================================================
procedure AspectRatio(const AreaW, AreaH, OldW, OldH: Single; var W, H, L, T: Single);
begin

  if (OldW / OldH) < (AreaW / AreaH) then
    begin
    H:= AreaH;
    T:= 0;
    W:= (AreaH * OldW) / OldH;
    L:= (AreaW - W) / 2;
  end
  else
    begin
    W:= AreaW;
    L:= 0;
    H:= (AreaW * OldH) / OldW;
    T:= (AreaH - H) / 2;
  end;

end;

//==============================================================================
function HitungTick(TickBegin: Double): Double; inline;
begin

  Result:= timer_GetTicks - TickBegin;

end;

end.
