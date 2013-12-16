# Softwire

Softwire is my attempt at creating a simple 3D engine using only software rasterization.

[![video](http://img.youtube.com/vi/6dfNiyhZ7r8/0.jpg)](http://www.youtube.com/watch?v=6dfNiyhZ7r8)

At the moment it is very much work in progress and only contains some simple rasterization algorithms. The goal is to have some sort of a simple spaceship and being able to fly around with it.

Some notable features:

- Fast software rasterization of the primitive types: lines, rectangles, circles, triangles, etc.
- Fast TTF/OTF font rendering.
- Fast alpha blending supported for everything.
- Cross-platform: works on Windows, Linux, and Mac.
- Framebuffer is implemented as a textured quad in OpenGL, so it is fast.

All the core logic and functionality are written in the [D programming language](http://dlang.org/). Some external libraries have been used too, for example:

- [GLFW](http://www.glfw.org/) - used for all the cross platform window and input handling stuff.
- [Freetype](http://freetype.org/) - used to load TTF/OTF font files and to get the character bitmap data.
- [Assimp](http://assimp.sourceforge.net/) - used to read 3D model data from files exported from modeling software.
- [OpenGL](http://www.opengl.org/) - used to implement the framebuffer data transfer to the display as fast as possible.
- [Derelict](https://github.com/DerelictOrg) - used to interface all the above libraries in the D programming language.

## Download & Installation

No need for an installer, just extract the archive somewhere.

- Windows (32-bit): [softwire.zip](http://www.glfw.org/)
- Linux (32-bit): [softwire.tar.gz](http://www.glfw.org/)

## Instructions

Do this and do that.

## Version history

### 0.1.0 (15-12-2013)
- Initial version

## Compiling

### Windows

[GDC compiler](http://gdcproject.org/wiki/) needs to be installed &mdash; easiest way to do it is to use the [MinGW-GDC build script](https://github.com/venix1/MinGW-GDC). Put both the resulting GDC and MinGW-w64 (that is installed and used by the script) bin directories into your PATH. You need to use the MinGW installed by the build script, not the one you might have had installed earlier. This has only been tested on Windows 8.1 64-bit.

Then build the program with make:

```
mingw32-make -f Makefile.windows
```

The executable and other necessary files will be output to the **bin** directory.

### Linux

Install the GDC compiler (and possible D standard/runtime libraries) using your package manager of choice. Building has only been tested on Arch Linux 32-bit.

Compile the program with make:

```
make -f Makefile.linux
```

The executable and other necessary files will be output to the **bin** directory.

## Compiling external libraries

All the external libraries should be compiled to static libraries (release mode + debug info) and then put into the *library/platform* directory. On Windows, remember to use the MinGW installed and used by the MinGW-GDC build script to ensure binary compatability.

### GLFW

The version used is **3.0.3**. Download the [source code](http://sourceforge.net/projects/glfw/files/glfw/). You also have to install  [CMake](http://www.cmake.org/).



### Freetype

Need to statically compile glfw and freetype.

## License

Licensed under the MIT License. See the LICENSE.txt file.