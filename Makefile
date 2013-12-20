# Makefile for compiling Softwire
# Needs LDC compiler
# Automatically detects platforms: Windows, Linux or Mac (on Windows, needs to be run from MinGW MSYS)
# Define 64BIT=1 on the command line to enable 64-bit build

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2)$(filter $(subst *,%,$2),$d))

SOURCE_FILES := $(call rwildcard, source/, *.d)
IMPORT_FILES := $(call rwildcard, import/, *.d)

ifndef 64BIT
	BITNESS = 32
	CFLAGS = -m32 -mcpu=i686 -mattr=sse2
else
	BITNESS = 64
	CFLAGS = -m64 -mcpu=x86_64 -mattr=avx
endif

CFLAGS += -w -de -od=obj -singleobj
CFLAGS_DEBUG := $(CFLAGS) -g
CFLAGS_RELEASE := $(CFLAGS) -O5 -release -L-s
CFLAGS_PROFILE := $(CFLAGS) -O5 -release -g

UNAME := $(shell uname -s | tr "[:upper:]" "[:lower:]")

ifneq "$(findstring mingw,$(UNAME))" ""
	PLATFORM = windows
	RESOURCES = misc/windows/softwire.res.o
	LFLAGS = -L-lopengl32 -L-lgdi32 -L--subsystem=windows
endif
ifneq "$(findstring linux,$(UNAME))" ""
	PLATFORM = linux
	RESOURCES = 
	LFLAGS = -L-lGL -L-lX11 -L-lXxf86vm -L-lXrandr -L-lXi -L-lpng -L-ldl
endif
ifneq "$(findstring darwin,$(UNAME))" ""
	PLATFORM = mac
	RESOURCES = 
	LFLAGS = -L-lGL -L-lX11 -L-lXxf86vm -L-lXrandr -L-lXi -L-lpng -L-ldl
endif

ifndef PLATFORM
$(error The platform was not detected correctly)
endif

LIBRARIES = library/glfw/$(PLATFORM)/libglfw$(BITNESS).a \
			library/freetype/$(PLATFORM)/libfreetype$(BITNESS).a

DEBUG_EXE := softwired$(BITNESS)
RELEASE_EXE := softwire$(BITNESS)
PROFILE_EXE := softwirep$(BITNESS)

VERSION := $(shell cat VERSION)

.PHONY: default all pre-build debug release profile doc dist clean
.SILENT: pre-build debug release profile doc dist clean

default: release

all: debug release profile

pre-build:
	echo "Target is $(PLATFORM) $(BITNESS)-bit"
ifeq "$(wildcard bin)" ""
	echo "Preparing bin directory..."
	mkdir -p bin
	cp -R data bin
	cp misc/softwire.conf bin
endif

debug: pre-build
	echo "Compiling debug version..."
	ldc2 $(CFLAGS_DEBUG) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -of=bin/$(DEBUG_EXE) $(LFLAGS)

release: pre-build
	echo "Compiling release version..."
	ldc2 $(CFLAGS_RELEASE) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -of=bin/$(RELEASE_EXE) $(LFLAGS)

profile: pre-build
	echo "Compiling profile version..."
	ldc2 $(CFLAGS_PROFILE) $(SOURCE_FILES) $(IMPORT_FILES) $(LIBRARIES) $(RESOURCES) -o bin/$(PROFILE_EXE) $(LFLAGS)

doc:
	echo "Creating documentation..."
	mkdir -p doc
	ldc2 -c $(SOURCE_FILES) -fdoc -fdoc-dir=doc -Iimport -Isource -o doc/doc.o

dist:
	echo "Building distribution..."
	cp -R bin softwire-$(VERSION)
	pandoc -f markdown_github -t html5 -o softwire-$(VERSION)/readme.html --template=misc/pandoc/html5.template README.md
	7z a -tzip -mx9 softwire-$(PLATFORM)-$(VERSION).zip softwire-$(VERSION)
	rm -rf softwire-$(VERSION)

clean:
	echo "Cleaning all..."
	rm -rf bin doc obj *.zip
