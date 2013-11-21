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
	@property bool isFullscreen() { return cast(bool)json.object["display"].object["fullscreen"].integer; }
	@property bool vsyncEnabled() { return cast(bool)json.object["display"].object["vsync"].integer; }
	@property uint framebufferWidth() { return cast(uint)json.object["framebuffer"].object["width"].uinteger; }
	@property uint framebufferHeight() { return cast(uint)json.object["framebuffer"].object["height"].uinteger; }
	@property bool useLegacyOpenGL() { return cast(bool)json.object["framebuffer"].object["useLegacyOpenGL"].integer; }
 
	private
	{
		Logger logger;
		JSONValue json;
	}
}
