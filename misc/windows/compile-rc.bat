@echo off
:: Needs MinGW in path for windres

echo Compiling resource file for GDC
windres -i softwire.rc -o softwire.res.o -J rc -O coff -F pe-i386
