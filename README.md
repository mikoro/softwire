<h1><img style="vertical-align:bottom" src="http://mikoro.github.io/images/softwire/logo.png" alt="Logo" title="Logo"> Softwire</h1>

Softwire is a simple 3D software rasterizer with some gameplay elements. It is written in the [D programming language](http://dlang.org) and runs natively (32-bit and 64-bit) on Windows, Linux and Mac OS X.

* Author: [Mikko Ronkainen](http://mikkoronkainen.com)
* Website: [github.com/mikoro/softwire](https://github.com/mikoro/brainfuck-interpreter)

![Screenshot](http://mikoro.github.io/images/softwire/readme-screenshot.png "Screenshot")

At the moment the project is very much work in progress. Only some basic rasterization algorithms are implemented. The goal is to have a simple space-shooter with basic gameplay.

Some interesting features:

- Written in the [D programming language](http://dlang.org) which compiles to fast native code, just like C or C++.
- Cross-platform support out-of-the-box, mostly thanks to the [LDC](http://wiki.dlang.org/LDC) and [LLVM](http://llvm.org/) compilers and the [GLFW library](http://www.glfw.org/).
- Fast rasterization algorithms for different kinds of primitives, e.g. lines, reactangles, circles and triangles.
- TrueType font rendering using the [Freetype font library](http://freetype.org/).
- OpenGL is used to transfer pixel data to the screen (textured quads) &mdash; the only speed bottleneck will be in the software rasterization and 3D math algorithms.
- Etc. TBD.

## Instructions

### Download

* **Windows**
    * [Download the latest Windows version](http://www.glfw.org/)
    * Works on Windows XP or newer
* **Linux**
    * [Download the latest Linux version](http://www.glfw.org/)
    * Needs X11 and OpenGL drivers installed
* **Mac OS X**
    * [Download the latest Mac OS X version](http://www.glfw.org/)
    * Works on Mac OS X 10.7 or newer

All the older (and current) versions can be found from the [Releases page](http://jeba).

### Installation

There is no installer, just extract the archive somewhere and it should just work.

### Configuration

To change the resolution or to switch to fullscreen (or a myriad of other things), edit the *softwire.ini* configuration file with a text editor.

### Gameplay

There will probably not be much to do, other than flying around in space.

- **WASD:**
- **F1:**

TBD

## Version history

### 0.1.0 (xx-xx-2014)
- Initial version

## Compilation

### Softwire

To compile, you will need the [LDC compiler](http://wiki.dlang.org/LDC) and [Make](http://www.gnu.org/software/make/). On Windows, [MSYS](http://www.mingw.org/wiki/MSYS) should be installed and the compilation should be run within it. On Mac OS X, you will need to install the [XCode Command Line Tools](https://developer.apple.com/xcode/).

The Makefile should detect the platform automatically and set all the compilation flags accordingly.

To compile the 32-bit release version:

    make release

To compile the 64-bit release version:

    make release 64BIT=1

And to enable the usage of all available CPU instructions, define the NATIVE flag, e.g:

    make release 64BIT=1 NATIVE=1

### External libraries

All the external libraries are compiled into static libraries and are statically linked to the program. The *library/name/build/build.txt* file contains the instructions on how to configure and compile the library for each platform and bitness. The resulting libraries are placed into the different *library/name/platform* directories and are then picked up by the Makefile.