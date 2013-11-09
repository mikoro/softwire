@echo off

set sources=source\main.d
set libraries=lib\DerelictGLFW3.lib lib\DerelictGL3.lib lib\DerelictFT.lib

echo Compiling debug...
dmd -m32 -w -de -Iimport -odobj %sources% %libraries% -ofsoftwired -debug -g -unittest -L/SUBSYSTEM:CONSOLE

echo Compiling release...
dmd -m32 -w -de -Iimport -odobj %sources% %libraries% -ofsoftwire -release -O -inline -noboundscheck -L/SUBSYSTEM:WINDOWS