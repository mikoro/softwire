/**
 * Wrapper class for an IniReader.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module settings;

import ini_reader;

class Settings
{
	this(IniReader iniReader)
	{
		this.iniReader = iniReader;
	}

	@property int windowWidth() { return iniReader.get!int("window", "width"); }
	@property int windowHeight() { return iniReader.get!int("window", "height"); }
	@property bool windowEnableFullscreen() { return iniReader.get!bool("window", "enableFullscreen"); }
	@property bool windowEnableVsync() { return iniReader.get!bool("window", "enableVsync"); }

	@property double framebufferScale() { return iniReader.get!double("framebuffer", "scale"); }
	@property bool framebufferEnableResizing() { return iniReader.get!bool("framebuffer", "enableResizing"); }
	@property bool framebufferUseSmoothFiltering() { return iniReader.get!bool("framebuffer", "useSmoothFiltering"); }

	private
	{
		IniReader iniReader;
	}
}
