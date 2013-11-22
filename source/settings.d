import std.json;
import std.file;

import logger;

class Settings
{
	this(Logger logger, string fileName)
	{
		this.logger = logger;

		logger.logInfo("Parsing settings file");

		json = parseJSON(readText(fileName));
	}

	@property uint displayWidth() { return cast(uint)json.object["display"].object["width"].uinteger; }
	@property uint displayHeight() { return cast(uint)json.object["display"].object["height"].uinteger; }
	@property bool isFullscreen() { return cast(bool)json.object["display"].object["fullscreen"].uinteger; }
	@property bool vsyncEnabled() { return cast(bool)json.object["display"].object["vsync"].uinteger; }
	@property uint framebufferScale() { return cast(uint)json.object["framebuffer"].object["scale"].uinteger; }
	@property bool useLinearFiltering() { return cast(bool)json.object["framebuffer"].object["useLinearFiltering"].uinteger; }
	@property bool useLegacyOpenGL() { return cast(bool)json.object["framebuffer"].object["useLegacyOpenGL"].uinteger; }
 
	private
	{
		Logger logger;
		JSONValue json;
	}
}
