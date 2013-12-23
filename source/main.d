/**
 * Application main entry point and error handling.
 *
 * Copyright: Copyright (C) 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT License
 */

module main;

import std.c.stdlib;
import std.conv;
import std.stdio;

import deimos.glfw.glfw3;

import logger;
import game;

private Logger mainLog;

int main()
{
	if (!glfwInit())
	{
		writeln("Could not initialize GLFW");
		return -1;
	}
	
	glfwSetErrorCallback(&glfwErrorCallback);
	
	mainLog = new FileLogger("softwire.log");

	try
	{
		Game game = new Game(mainLog);
		game.mainloop();
	}
	catch(Exception ex)
	{
		mainLog.logThrowable(ex);
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
			mainLog.logError("GLFW: %s", to!string(description));
		}
		catch(Throwable t)
		{
			exit(-1);
		}
	}
}
