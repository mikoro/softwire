all: debug release

debug: debug-i386 debug-core

release: release-i386 release-core

debug-i386:
	dub build --compiler=gdc --build=debug --config=debug-i386 -v
  
debug-core:
	dub build --compiler=gdc --build=debug --config=debug-core -v

release-i386:
	dub build --compiler=gdc --build=release --config=release-i386 -v
  
release-core:
	dub build --compiler=gdc --build=release --config=release-core -v

