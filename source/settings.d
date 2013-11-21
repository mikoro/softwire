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

	@property int displayWidth() { return cast(int)json.object["display"].object["width"].integer; }
	@property int displayHeight() { return cast(int)json.object["display"].object["height"].integer; }
	@property bool isFullscreen() { return cast(bool)json.object["display"].object["fullscreen"].integer; }
	@property bool vsyncEnabled() { return cast(bool)json.object["display"].object["vsync"].integer; }
	@property int framebufferWidth() { return cast(int)json.object["framebuffer"].object["width"].integer; }
	@property int framebufferHeight() { return cast(int)json.object["framebuffer"].object["height"].integer; }
	@property bool useLinearFiltering() { return cast(bool)json.object["framebuffer"].object["useLinearFiltering"].integer; }
	@property bool useLegacyOpenGL() { return cast(bool)json.object["framebuffer"].object["useLegacyOpenGL"].integer; }
 
	private
	{
		Logger logger;
		JSONValue json;
	}
}
