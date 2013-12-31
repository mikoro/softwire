/**
 * Game initialization and main loop logic.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module game;

import std.conv;
import std.stdio;

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

		windowWidth = settings.windowWidth;
		windowHeight = settings.windowHeight;
		framebufferScale = settings.framebufferScale;

		window = glfwCreateWindow(windowWidth, windowHeight, "Softwire", settings.windowEnableFullscreen ? glfwGetPrimaryMonitor() : null, null);

		if (!window)
			throw new Exception("Could not create the window");

		glfwMakeContextCurrent(window);
		glfwSwapInterval(settings.windowEnableVsync ? 1 : 0);

		framebuffer = new Framebuffer(log);
		framebuffer.resize(cast(int)(windowWidth * framebufferScale + 0.5), cast(int)(windowHeight * framebufferScale + 0.5));
		framebuffer.useSmoothFiltering = settings.framebufferUseSmoothFiltering;

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

		int newWindowWidth, newWindowHeight;
		double mouseX, mouseY;

		glfwGetFramebufferSize(window, &newWindowWidth, &newWindowHeight);
		glfwGetCursorPos(window, &mouseX, &mouseY);

		if (newWindowWidth != windowWidth || newWindowHeight != windowHeight)
		{
			windowWidth = newWindowWidth;
			windowHeight = newWindowHeight;

			if (settings.framebufferEnableResizing)
				framebuffer.resize(cast(int)(windowWidth * framebufferScale + 0.5), cast(int)(windowHeight * framebufferScale + 0.5));

			glViewport(0, 0, windowWidth, windowHeight);
		}

		windowMouseX = cast(int)(mouseX + 0.5);
		windowMouseY = cast(int)(windowHeight - mouseY - 1 + 0.5);
		framebufferMouseX = cast(int)(((windowMouseX / cast(double)windowWidth) * framebuffer.width) + 0.5);
		framebufferMouseY = cast(int)(((windowMouseY / cast(double)windowHeight) * framebuffer.height) + 0.5);
	}

	void render(double interpolation)
	{
		framebuffer.clear(Color(0, 0, 0, 255), Color(0, 100, 180, 255));

		//rasterizer.drawCircle(framebuffer, 20, 20, 20, Color(255, 255, 255, 128));
		//rasterizer.drawRectangle(framebuffer, 100, 100, 1060, 580, Color(255, 255, 255, 128));
		bigText.drawText(framebuffer, -150, 300, "Softwire", Color(255, 0, 0, 200));
		//signatureText.drawText(framebuffer, 5, 10, "Softwire", Color(255, 255, 255, 64));

		text.drawText(framebuffer, 5, framebuffer.height - (16 * 1), "FPS: " ~ renderFpsCounter.getFpsString(), Color(255, 255, 255, 128));

		if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
		{
			rasterizer.drawCircle(framebuffer, framebufferMouseX, framebufferMouseY, 60, Color(0, 255, 0, 128));
			//rasterizer.drawRectangle(framebuffer, framebufferMouseX, framebufferMouseY, 1, 1, Color(255, 255, 255, 255));
			//text.drawText(framebuffer, framebufferMouseX, framebufferMouseY, "Tämä on jonkinlainen teksti.", Color(255, 255, 255, 128));
		}

		framebuffer.render();
		glfwSwapBuffers(window);

		renderFpsCounter.update();
	}

	private
	{
		Logger log;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		bool shouldRun;

		int windowWidth;
		int windowHeight;
		int windowMouseX;
		int windowMouseY;
		int framebufferMouseX;
		int framebufferMouseY;

		double framebufferScale;

		Text text;
		Text bigText;
		Text signatureText;

		FpsCounter renderFpsCounter;
	}
}
