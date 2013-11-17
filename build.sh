#!/bin/bash

SOURCES="source/main.d source/logger.d source/game.d source/framebuffer.d source/fpscounter.d"
LIBRARIES="-L-Llib -L-ldl -L-lDerelictGLFW3 -L-lDerelictGL3 -L-lDerelictFT"

echo Compiling debug...
dmd -m32 -w -de -Iimport -odobj $SOURCES $LIBRARIES -ofsoftwired -debug -g -unittest

echo Compiling release...
dmd -m32 -w -de -Iimport -odobj $SOURCES $LIBRARIES -ofsoftwire -release -O -inline -noboundscheck -L-Llib

