# Softwire makefile
# LDC compiler needed (http://wiki.dlang.org/LDC)
# Automatically detects platforms: Windows, Linux or Mac
# Define 64BIT=1 for 64-bit compilation
# Define NATIVE=1 for native compilation

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2)$(filter $(subst *,%,$2),$d))

SOURCE_FILES := $(call rwildcard, source/, *.d)
IMPORT_FILES := $(call rwildcard, import/, *.d)

ifndef 64BIT
	BITNESS = 32
	ifndef NATIVE
		CFLAGS = -m32 -mcpu=i686 -mattr=sse2
	else
		CFLAGS = -m32 -mcpu=native
	endif
else
	BITNESS = 64
	ifndef NATIVE
		CFLAGS = -m64 -mcpu=x86-64
	else
		CFLAGS = -m64 -mcpu=native
	endif
endif

CFLAGS += -w -de -od=obj -singleobj
CFLAGS_DEBUG := $(CFLAGS) -d-debug -unittest -g
CFLAGS_RELEASE := $(CFLAGS) -release -O3 -L-s
CFLAGS_PROFILE := $(CFLAGS) -release -O3 -g

UNAME := $(shell uname -s | tr "[:upper:]" "[:lower:]")
VERSION := $(shell cat VERSION)

ifneq "$(findstring mingw,$(UNAME))" ""
	PLATFORM = windows
	RESOURCES = misc/windows/softwire.res.o
	LFLAGS_DEBUG = -L-lopengl32 -L-lgdi32
	LFLAGS_RELEASE := $(LFLAGS_DEBUG) -L--subsystem=windows
	DISTDIR := softwire-$(VERSION)
	DISTDATADIR := softwire-$(VERSION)
endif
ifneq "$(findstring linux,$(UNAME))" ""
	PLATFORM = linux
	RESOURCES =
	LFLAGS_DEBUG = -L-lGL -L-lX11 -L-lXxf86vm -L-lXrandr -L-lXi
	LFLAGS_RELEASE := $(LFLAGS_DEBUG)
	DISTDIR := softwire-$(VERSION)
	DISTDATADIR := softwire-$(VERSION)
endif
ifneq "$(findstring darwin,$(UNAME))" ""
	PLATFORM = mac
	RESOURCES =
	LFLAGS_DEBUG = -L-framework -LCocoa -L-framework -LOpenGL -L-framework -LIOKit
	LFLAGS_RELEASE := $(LFLAGS_DEBUG)
	DISTDIR = Softwire.app
	DISTDATADIR = Softwire.app/Contents/Resources
endif

ifndef PLATFORM
$(error The platform was not detected correctly)
endif

LIBRARIES = library/glfw/$(PLATFORM)/libglfw$(BITNESS).a \
			library/freetype/$(PLATFORM)/libfreetype$(BITNESS).a

.PHONY: default all pre-build debug release profile doc dist clean
.SILENT:

default: release

all: debug release profile

pre-build:
	@echo "Target is $(PLATFORM) $(BITNESS)-bit"
ifeq "$(wildcard bin)" ""
	@echo "Preparing bin directory..."
	mkdir -p bin
	cp -R data bin
	cp misc/softwire.ini bin
endif

debug: pre-build
	@echo "Compiling debug version..."
	ldc2 $(CFLAGS_DEBUG) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -of=bin/softwired$(BITNESS) $(LFLAGS_DEBUG)

release: pre-build
	@echo "Compiling release version..."
	ldc2 $(CFLAGS_RELEASE) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -of=bin/softwire$(BITNESS) $(LFLAGS_RELEASE)

profile: pre-build
	@echo "Compiling profile version..."
	ldc2 $(CFLAGS_PROFILE) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -of=bin/softwirep$(BITNESS) $(LFLAGS_RELEASE)

doc:
	@echo "Creating documentation..."
	mkdir -p doc
	ldc2 $(SOURCE_FILES) -D -Dd=doc -Iimport -o-

dist:
	@echo "Building distribution..."
	mkdir -p $(DISTDIR) $(DISTDATADIR)
ifeq "$(PLATFORM)" "windows"
	cp bin/softwire32.exe $(DISTDIR)
endif
ifeq "$(PLATFORM)" "linux"
	cp bin/softwire{32,64} $(DISTDIR)
endif
ifeq "$(PLATFORM)" "mac"
	mkdir -p Softwire.app/Contents/MacOS
	cp misc/mac/Info.plist Softwire.app/Contents
	cp misc/mac/softwire.icns Softwire.app/Contents/Resources
	lipo -create -output Softwire.app/Contents/MacOS/softwire bin/softwire{32,64}
endif
	cp -R data $(DISTDATADIR)
	cp misc/softwire.ini $(DISTDATADIR)
	cp LICENSE $(DISTDATADIR)/license.txt
	7z a -tzip -mx9 -xr!.DS_Store softwire-$(VERSION)-$(PLATFORM).zip $(DISTDIR)
	rm -rf $(DISTDIR)

clean:
	@echo "Cleaning all..."
	rm -rf bin doc obj *.zip
