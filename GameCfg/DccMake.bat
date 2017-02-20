@echo off

rem echo * Compiling GameConf Resources *
rem start /i /wait RescComp.bat
rem echo.

echo * Compiling GameConf *
"C:\Program Files\Borland\Delphi 2\BIN\dcc32.exe" GameCfg.dpr
move GameCfg.exe ..\
echo.

exit