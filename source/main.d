/**
 * Application main entry point and error handling.
 *
 * Copyright © 2014 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT, see the LICENSE file.
 */

module main;

import std.c.stdlib;
import std.conv;
import std.stdio;
import std.string;

import deimos.glfw.glfw3;

import logger;
import game_engine;
import ini_reader;
import settings;

private Logger log;

int main()
{
	glfwSetErrorCallback(&glfwErrorCallback);

	if (!glfwInit())
		return -1;

	scope(exit) { glfwTerminate(); }

	log = new ConsoleFileLogger("softwire.log");

	try
	{
		IniReader iniReader = new IniReader(log, "softwire.ini");
		Settings settings = new Settings(iniReader);
		GameEngine gameEngine = new GameEngine(log, settings);

		gameEngine.initialize();
		gameEngine.run();
	}
	catch(Throwable t)
	{
		log.logThrowable(t);
		return -1;
	}

	return 0;
}

extern(C) private nothrow
{
	void glfwErrorCallback(int error, const(char)* description)
	{
		try
		{
			string message = format("GLFW error: %s", to!string(description));

			if (log !is null)
				log.logError(message);
			else
				writeln(message);
		}
		catch(Throwable t)
		{
			exit(-1);
		}
	}
}
