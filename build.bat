@echo off

set sources=source\main.d source\game.d source\framebuffer.d source\fpscounter.d
set libraries=lib\DerelictGLFW3.lib lib\DerelictGL3.lib lib\DerelictFT.lib

echo Compiling debug...
dmd -m32 -w -de -Iimport -odobj %sources% %libraries% -ofsoftwired -debug -g -unittest -L/SUBSYSTEM:CONSOLE

if %ERRORLEVEL% == 0 (
echo Compiling release...
dmd -m32 -w -de -Iimport -odobj %sources% %libraries% -ofsoftwire -release -O -inline -noboundscheck -L/SUBSYSTEM:CONSOLE
)
