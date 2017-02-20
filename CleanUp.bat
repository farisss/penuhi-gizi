@echo off

cd dcu
del /q *.*
cd..
cd MainApp
del /q *.~*
cd..
cd GameCfg
del /q *.~*
cd..
cd Shared
del /q *.~*
cd..
cd GeoGen
del /q *.~*
cd..
cd GameEdit
del /q *.~*

exit