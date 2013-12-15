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

On windows, you need MinGW32 and GDC.

```
make -f Makefile.windows release
```

### Linux

On Linux, you need GDC.

```
make -f Makefile.linux release
```

## Compiling external libraries

All the external libraries have been statically compiled and linked to the executable. Here are brief instructions on how to do the compilations.

### GLFW

Need to statically compile glfw and freetype.

### Freetype

Need to statically compile glfw and freetype.

## License

Licensed under the MIT License. See the LICENSE.txt file.