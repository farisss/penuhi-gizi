@echo off

rem echo * Compiling DataBundle Resources *
rem start /i /wait RescComp.bat
rem echo.

echo * Compiling DataBundle *
dcc32 DataBundle.dpr
echo.

exit