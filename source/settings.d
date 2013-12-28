/**
 * Settings class encapsulating an ini configuration file.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module settings;

import std.conv;
import std.regex;
import std.stdio;
import std.string;

import logger;

class Settings
{
	this(Logger log, string fileName)
	{
		this.log = log;
		this.fileName = fileName;

		log.logInfo("Reading settings from %s", fileName);

		File file = File(fileName, "r");
		string line;

		string sectionName = "unknown";

		while ((line = file.readln()) !is null)
		{
			if (match(line, commentRegex))
				continue;

			auto sectionMatch = match(line, sectionRegex);

			if (sectionMatch)
			{
				sectionName = sectionMatch.captures[1];
				continue;
			}

			auto valueMatch = match(line, valueRegex);

			if (valueMatch)
			{
				string keyName = valueMatch.captures[1];
				string keyValue = valueMatch.captures[2];

				sections[sectionName][keyName] = keyValue;
			}
		}
	}

	T get(T)(string sectionName, string keyName)
	{
		if (sectionName !in sections)
			throw new Exception(format("Could not find section \"%s\" in %s", sectionName, fileName));

		if (keyName !in sections[sectionName])
			throw new Exception(format("Could not find key \"%s::%s\" in %s", sectionName, keyName, fileName));

		T result;

		try
		{
			result = to!T(sections[sectionName][keyName]);
		}
		catch(Exception ex)
		{
			throw new Exception(format("Could not convert key \"%s::%s=%s\" to %s in %s: %s", sectionName, keyName, sections[sectionName][keyName], typeid(T).toString(), fileName, ex.msg));
		}

		return result;
	}

	private
	{
		Logger log;
		string fileName;
		string[string][string] sections;

		enum commentRegex = regex(r"^\s*[#;].*");
		enum sectionRegex = regex(r"^\s*\[(\S+)\].*");
		enum valueRegex = regex(r"^\s*(\S+)\s*=\s*(\S+).*");
	}
}
