/**
 * Settings class encapsulating an ini configuration file.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module settings2;

import std.stdio;

import logger;

class Settings2
{
	this(Logger log, string fileName)
	{
		this.log = log;

		File file = File(fileName, "r");
		string line;

    	while ((line = file.readln()) !is null)
    	{

    	}
	}

	private
	{
		Logger log;
		string[string][string] values;
	}
}
