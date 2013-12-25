/**
 * Settings class encapsulating a json/ini configuration file.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module settings;

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
	@property int framebufferScale() { return cast(int)json.object["framebuffer"].object["scale"].integer; }
	@property bool useLinearFiltering() { return cast(bool)json.object["framebuffer"].object["useLinearFiltering"].integer; }
	@property bool useLegacyOpenGL() { return cast(bool)json.object["framebuffer"].object["useLegacyOpenGL"].integer; }
 
	private
	{
		Logger logger;
		JSONValue json;
	}
}
