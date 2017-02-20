@echo off

echo * Builiding Penuhi Gizi! Game *
start /i /wait BuildGame.bat
echo.

echo * Striping unused relocation section *
StripReloc /b PenuhiGizi.exe
StripReloc /b GameCfg.exe
echo.

echo * Building Installer *

cd WixSetup
start /i /wait MakeInst.bat

rem cd Setup
rem "C:\Program Files\Altiris\Wise\Windows Installer Editor\WfWI.exe" /c PGSetup.wsi

echo.

echo # DONE! #
echo.

pause