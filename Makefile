SOURCES = 	fpscounter.d \
			framebuffer.d \
			game.d \
			logger.d \
			main.d \
			rasterizer.d \
			settings.d \
			text.d

SOURCES := $(addprefix source/, $(SOURCES))

IMPORTS = import/deimos/glfw/glfw3.d
IMPORTS += $(addprefix import/derelict/util/, exception.d loader.d sharedlib.d system.d wintypes.d xtypes.d)
IMPORTS += $(addprefix import/derelict/opengl3/, arb.d cgl.d constants.d deprecatedConstants.d deprecatedFunctions.d ext.d functions.d gl.d gl3.d glx.d glxext.d internal.d types.d wgl.d wglext.d)
IMPORTS += $(addprefix import/freetype/, freetype.d types.d)

OBJECTS = misc/resources/softwire.res.o
LIBRARIES = $(addprefix library/windows/, glfw3.a freetype.a)

ARCH = i386
#ARCH = core-avx-i

CFLAGS = -m32 -march=$(ARCH) -Wall -Werror
LFLAGS = -lopengl32 -lgdi32 -Xlinker --subsystem=windows

.PHONY: default all pre-build debug release profile clean

default: release

all: debug release profile

pre-build:
ifeq "$(wildcard build)" ""
	@echo Creating a build directory and copying files...
	@mkdir build
	@xcopy data build\data /S /E /I /Y > nul
	@xcopy misc\settings.json build > nul
endif

debug: pre-build
	@echo Compiling debug build...
	@gdc $(CFLAGS) -fdebug -funittest -g $(SOURCES) $(IMPORTS) $(OBJECTS) $(LIBRARIES) -o build/softwired.exe $(LFLAGS)

release: pre-build
	@echo Compiling release build...
	@gdc $(CFLAGS) -frelease -fno-bounds-check -O3 $(SOURCES) $(IMPORTS) $(OBJECTS) $(LIBRARIES) -o build/softwire.exe $(LFLAGS)
	@strip -s build/softwire.exe

profile: pre-build
	@echo Compiling profile build...
	@gdc $(CFLAGS) -frelease -fno-bounds-check -O3 -g $(SOURCES) $(IMPORTS) $(OBJECTS) $(LIBRARIES) -o build/softwirep.exe $(LFLAGS)

clean:
	@echo Cleaning...
ifneq "$(wildcard build)" ""
	@rmdir /S /Q build
endif
