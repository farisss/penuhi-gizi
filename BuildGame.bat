@echo off

echo * Cleaning files and old compiler output *
start /i /wait CleanUp.bat
echo.

echo * Compiling ZenGL libraries *
cd ZenGL
start /i /wait DccMake.bat
cd..
echo.

echo * Compiling DataBundle *
cd DataBundle
start /i /wait DccMake.bat
cd..
echo.

echo * Compiling Penuhi Gizi main executable Engine *
cd MainApp
start /i /wait DccMake.bat
cd..
echo.

echo * Compiling Game Configurator Frontend *
cd GameCfg
start /i /wait DccMake.bat
cd..
echo.

echo # DONE! #
exit