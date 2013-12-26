/**
 * Application main entry point and error handling.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module main;

import std.c.stdlib;
import std.conv;
import std.stdio;
import std.string;

import deimos.glfw.glfw3;

import logger;
import game;

private Logger log;

int main()
{
	glfwSetErrorCallback(&glfwErrorCallback);

	if (!glfwInit())
		return -1;

	scope(exit) { glfwTerminate(); }

	log = new FileAndConsoleLogger("softwire.log");

	try
	{
		Game game = new Game(log);
		game.mainLoop();
	}
	catch(Exception ex)
	{
		log.logThrowable(ex);
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

			writeln(message);

			if (log !is null)
				log.logError(message);
		}
		catch(Throwable t)
		{
			exit(-1);
		}
	}
}
