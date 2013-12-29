/**
 * Game initialization and main loop logic.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module game;

import std.conv;

import deimos.glfw.glfw3;
import derelict.opengl3.gl;

import color;
import fpscounter;
import framebuffer;
import logger;
import rasterizer;
import settings;
import text;

class Game
{
	this(Logger log)
	{
		this.log = log;
		settings = new Settings(log, "softwire.ini");

		log.logInfo("Creating the window");

		window = glfwCreateWindow(settings.get!int("window", "width"), settings.get!int("window", "height"), "Softwire", settings.get!bool("window", "fullscreen") ? glfwGetPrimaryMonitor() : null, null);

		if (!window)
			throw new Exception("Could not create the window");

		glfwMakeContextCurrent(window);
		glfwSwapInterval(settings.get!bool("window", "vsync") ? 1 : 0);

		if (settings.get!bool("framebuffer", "legacyOpenGL"))
			framebuffer = new FramebufferOpenGL1(log, settings);
		else
			framebuffer = new FramebufferOpenGL3(log, settings);

		shouldRun = true;
		text = new Text(log, "data/fonts/dejavu-sans-mono-regular.ttf", 14);
		bigText = new Text(log, "data/fonts/dejavu-sans-bold.ttf", 400);
		signatureText = new Text(log, "data/fonts/alexbrush-regular.ttf", 32);
		renderFpsCounter = new FpsCounter();
	}

	void mainLoop()
	{
		log.logInfo("Entering the main loop");

		double timeStep = 1.0 / 60;
		double currentTime = glfwGetTime();
		double timeAccumulator = 0;

		while (shouldRun)
		{
			double newTime = glfwGetTime();
			double frameTime = newTime - currentTime;
			currentTime = newTime;

			if (frameTime > 0.25)
				frameTime = 0.25;

			timeAccumulator += frameTime;

			while (timeAccumulator >= timeStep)
			{
				update(timeStep);
				timeAccumulator -= timeStep;
			}

			double interpolation = timeAccumulator / timeStep;
			render(interpolation);
		}
	}

	void update(double timeStep)
	{
		glfwPollEvents();

		if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
			shouldRun = false;

		if (glfwWindowShouldClose(window))
			shouldRun = false;
	}

	void render(double interpolation)
	{
		int windowWidth, windowHeight, framebufferWidth, framebufferHeight, mouseX, mouseY, scaledMouseX, scaledMouseY;
		double tempMouseX, tempMouseY;

		glfwGetWindowSize(window, &windowWidth, &windowHeight);
		glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
		glfwGetCursorPos(window, &tempMouseX, &tempMouseY);
		mouseX = cast(int)(tempMouseX + 0.5);
		mouseY = cast(int)(-tempMouseY + framebufferHeight - 1 + 0.5);
		scaledMouseX = cast(int)(((mouseX / cast(double)framebufferWidth) * framebuffer.width) + 0.5);
		scaledMouseY = cast(int)(((mouseY / cast(double)framebufferHeight) * framebuffer.height) + 0.5);

		//rasterizer.drawCircle(framebuffer, 20, 20, 20, Color(255, 255, 255, 128));
		rasterizer.drawRectangle(framebuffer, 100, 100, 1060, 580, Color(255, 255, 255, 128));

		text.drawText(framebuffer, 5, framebuffer.height - (16 * 1), "FPS: " ~ renderFpsCounter.getFpsString(), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 3), "W w: " ~ to!dstring(windowWidth), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 4), "W h: " ~ to!dstring(windowHeight), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 5), "F w: " ~ to!dstring(framebufferWidth), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 6), "F h: " ~ to!dstring(framebufferHeight), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 7), "M x: " ~ to!dstring(mouseX), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 8), "M y: " ~ to!dstring(mouseY), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 9), "S x: " ~ to!dstring(scaledMouseX), Color(255, 255, 255, 128));
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 10), "S y: " ~ to!dstring(scaledMouseY), Color(255, 255, 255, 128));

		bigText.drawText(framebuffer, -150, 300, "Softwire", Color(255, 0, 0, 200));
		signatureText.drawText(framebuffer, 5, 10, "Softwire", Color(255, 255, 255, 64));

		if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
		{
			rasterizer.drawCircle(framebuffer, scaledMouseX, scaledMouseY, 60, Color(0, 255, 0, 128));
			//rasterizer.drawRectangle(framebuffer, scaledMouseX, scaledMouseY, 1, 1, Color(255, 255, 255, 255));
			//text.drawText(framebuffer, scaledMouseX, scaledMouseY, "Tämä on jonkinlainen teksti.", Color(255, 255, 255, 128));
		}

		glViewport(0, 0, framebufferWidth, framebufferHeight);

		framebuffer.render();
		glfwSwapBuffers(window);
		framebuffer.clear(Color(0, 0, 0, 255), Color(0, 100, 180, 255));

		renderFpsCounter.update();
	}

	private
	{
		Logger log;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		bool shouldRun;
		Text text;
		Text bigText;
		Text signatureText;
		FpsCounter renderFpsCounter;
	}
}
