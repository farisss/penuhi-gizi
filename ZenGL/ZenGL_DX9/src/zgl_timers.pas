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
unit zgl_timers;

{$I zgl_config.cfg}

interface
uses
  Windows;

type
  zglPTimer = ^zglTTimer;
  zglTTimer = record
    Active     : Boolean;
    Custom     : Boolean;
    UserData   : Pointer;
    Interval   : LongWord;
    LastTick   : Double;
    OnTimer    : procedure;
    OnTimerEx  : procedure( Timer : zglPTimer );

    prev, next : zglPTimer;
end;

type
  zglPTimerManager = ^zglTTimerManager;
  zglTTimerManager = record
    Count : Integer;
    First : zglTTimer;
end;

function  timer_Add( OnTimer : Pointer; Interval : LongWord; UseSenderForCallback : Boolean = FALSE; UserData : Pointer = nil ) : zglPTimer;
procedure timer_Del( var Timer : zglPTimer );

procedure timer_MainLoop;
function  timer_GetTicks : Double;
procedure timer_Reset;

var
  managerTimer  : zglTTimerManager;
  canKillTimers : Boolean = TRUE;

implementation
uses
  zgl_application,
  zgl_main;

var
  timersToKill   : Word = 0;
  aTimersToKill  : array[ 0..1023 ] of zglPTimer;
  timerFrequency : Int64;
  timerFreq      : Single;
  timerStart     : Double;

function timer_Add( OnTimer : Pointer; Interval : LongWord; UseSenderForCallback : Boolean = FALSE; UserData : Pointer = nil ) : zglPTimer;
begin
  Result := @managerTimer.First;
  while Assigned( Result.next ) do
    Result := Result.next;

  zgl_GetMem( Pointer( Result.next ), SizeOf( zglTTimer ) );
  Result.next.Active    := TRUE;
  Result.next.Custom    := UseSenderForCallback;
  Result.next.UserData  := UserData;
  Result.next.Interval  := Interval;
  if UseSenderForCallback Then
    Result.next.OnTimerEx := OnTimer
  else
    Result.next.OnTimer := OnTimer;
  Result.next.LastTick  := timer_GetTicks();
  Result.next.prev      := Result;
  Result.next.next      := nil;
  Result := Result.next;
  INC( managerTimer.Count );
end;

procedure timer_Del( var Timer : zglPTimer );
begin
  if not Assigned( Timer ) Then exit;

  if not canKillTimers Then
    begin
      INC( timersToKill );
      aTimersToKill[ timersToKill ] := Timer;
      Timer := nil;
      exit;
    end;

  if Assigned( Timer.Prev ) Then
    Timer.prev.next := Timer.next;
  if Assigned( Timer.next ) Then
    Timer.next.prev := Timer.prev;
  FreeMem( Timer );
  Timer := nil;

  DEC( managerTimer.Count );
end;

procedure timer_MainLoop;
  var
    i     : Integer;
    t     : Double;
    timer : zglPTimer;
begin
  canKillTimers := FALSE;

  timer := @managerTimer.First;
  if timer <> nil Then
    for i := 0 to managerTimer.Count do
      begin
        if timer.Active then
          begin
            t := timer_GetTicks();
            while t >= timer.LastTick + timer.Interval do
              begin
                timer.LastTick := timer.LastTick + timer.Interval;
                if timer.Custom Then
                  timer.OnTimerEx( timer )
                else
                  timer.OnTimer();
                if t < timer_GetTicks() - timer.Interval Then
                  break
                else
                  t := timer_GetTicks();
              end;
          end else timer.LastTick := timer_GetTicks();

        timer := timer.next;
      end;

  canKillTimers := TRUE;
  for i := 1 to timersToKill do
    timer_Del( aTimersToKill[ i ] );
  timersToKill  := 0;
end;

function timer_GetTicks : Double;
  var
    t : int64;
    m : LongWord;
begin
  m := SetThreadAffinityMask( GetCurrentThread(), 1 );
  QueryPerformanceCounter( t );
  Result := 1000 * t * timerFreq - timerStart;
  SetThreadAffinityMask( GetCurrentThread(), m );
end;

procedure timer_Reset;
  var
    currTimer : zglPTimer;
begin
  appdt := timer_GetTicks();
  currTimer := @managerTimer.First;
  while Assigned( currTimer ) do
    begin
      currTimer.LastTick := timer_GetTicks();
      currTimer := currTimer.next;
    end;
end;

initialization
  SetThreadAffinityMask( GetCurrentThread(), 1 );
  QueryPerformanceFrequency( timerFrequency );
  timerFreq := 1 / timerFrequency;
  timerStart := timer_GetTicks();

end.
