@echo off

echo * Attempt to compile ZenGL for OpenGL DLL! *
cd "ZenGL_OGL\src\Delphi\Delphi 7\"
start /i /wait DccMake.bat
cd..\..\..\..\
echo.

echo * Attempt to compile ZenGL for Direct3D8! *
cd "ZenGL_DX8\src\Delphi\Delphi 7\"
start /i /wait DccMake.bat
cd..\..\..\..\
echo.

echo * Attempt to compile ZenGL for OpenGL DLL! *
cd "ZenGL_DX9\src\Delphi\Delphi 7\"
start /i /wait DccMake.bat
cd..\..\..\..\
echo.

exit