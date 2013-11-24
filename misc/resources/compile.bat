@echo off
rem Needs to be run from VS command line for rc, needs gcc/gdc in path for windres

echo Compiling resource file for DMD
rc /nologo /fo softwire.dmd.res softwire.rc

echo Compiling resource file for GDC
windres softwire.rc -o softwire.gdc.res.o
