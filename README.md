<h1><img style="vertical-align:bottom" src="http://mikoro.github.io/images/softwire/logo.png" alt="Logo" title="Logo"> Softwire</h1>

Softwire is a simple rasterization test program written in the [D programming language](http://dlang.org). It runs natively (32-bit and 64-bit) on Windows, Linux and Mac OS X.

* Author: [Mikko Ronkainen](http://mikkoronkainen.com)
* Website: [github.com/mikoro/softwire](https://github.com/mikoro/softwire)

![Screenshot](http://mikoro.github.io/images/softwire/readme-screenshot.png "Screenshot")

## Download

**Windows**: [softwire-0.1.0-windows.zip](https://github.com/mikoro/softwire/releases/download/v0.1.0/softwire-0.1.0-windows.zip)

**Linux**: [softwire-0.1.0-linux.zip](https://github.com/mikoro/softwire/releases/download/v0.1.0/softwire-0.1.0-linux.zip)

**Mac**: [softwire-0.1.0-mac.zip](https://github.com/mikoro/softwire/releases/download/v0.1.0/softwire-0.1.0-mac.zip)

## Compilation

### Softwire

To compile, you will need the [LDC compiler](http://wiki.dlang.org/LDC) and [Make](http://www.gnu.org/software/make/). On Windows, [MSYS](http://www.mingw.org/wiki/MSYS) should be installed and the compilation should be run with it. On Mac OS X, you will need to install the [XCode Command Line Tools](https://developer.apple.com/xcode/).

The Makefile should detect the platform automatically and set all the compilation flags accordingly.

To compile the 32-bit release version:

    make release

To compile the 64-bit release version:

    make release 64BIT=1

And to enable the usage of all available CPU instructions, define the NATIVE flag, e.g:

    make release 64BIT=1 NATIVE=1

### External libraries

All the external libraries are compiled into static libraries and are statically linked to the program. The *library/name/build/build.txt* file contains the instructions on how to configure and compile the library for each platform and bitness. The resulting libraries are placed into the different *library/name/platform* directories and are then picked up by the Makefile.