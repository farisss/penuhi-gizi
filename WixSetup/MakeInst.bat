@echo off

echo * Compiling MSI Installer *
echo.

echo Executing candle..
"C:\Program Files\WiX Toolset v3.9\bin\candle.exe" -nologo "PGSetup.wxs" -out "PGSetup.wixobj" -ext WixUIExtension

echo.
echo Executing Light...
"C:\Program Files\WiX Toolset v3.9\bin\light.exe" -nologo "PGSetup.wixobj" -out "PGSetup.msi" -ext WixUIExtension

echo.
echo * Begin create sfx *
echo.

del PenuhiGizi_Setup.exe
rem 7zr a PGSetup.7z PGSetup.msi -m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx
7zr a PGSetup.7z PGSetup.msi data.cab -m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx
copy /b 7zSD.sfx + config.txt + PGSetup.7z PenuhiGizi_Setup.exe

echo.
echo * Removing temporary files *
echo.

del PGSetup.wixobj
del PGSetup.7z

exit