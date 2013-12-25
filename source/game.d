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

import logger;
import settings;
import framebuffer;
import text;
import fpscounter;
import rasterizer;

class Game
{
	this(Logger log)
	{
		this.log = log;
		settings = new Settings(log, "softwire.conf");

		log.logInfo("Creating the window");

		window = glfwCreateWindow(settings.displayWidth, settings.displayHeight, "Softwire", settings.isFullscreen ? glfwGetPrimaryMonitor() : null, null);

		if (!window)
			throw new Exception("Could not create the window");

		glfwMakeContextCurrent(window);
		glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
		glfwSwapInterval(settings.vsyncEnabled ? 1 : 0);

		if (settings.useLegacyOpenGL)
			framebuffer = new FramebufferOpenGL1(log, settings);
		else
			framebuffer = new FramebufferOpenGL3(log, settings);

		shouldRun = true;
		text = new Text(log, "data/fonts/noto-bold.ttf", 14);
		renderFpsCounter = new FpsCounter();
	}

	void mainLoop()
	{
		log.logInfo("Starting the main loop");

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
		double mouseX, mouseY;
		glfwGetCursorPos(window, &mouseX, &mouseY);
		mouseY = settings.displayHeight - mouseY - 1;

		if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
		{
			rasterizer.drawCircle(framebuffer, cast(int)mouseX, cast(int)mouseY, 20, 0x7fffffff);
		}

		rasterizer.drawCircle(framebuffer, 20, 20, 20, 0x7fffffff);

		text.drawText(framebuffer, 5, framebuffer.height - 16, "FPS: " ~ renderFpsCounter.getRateLimitedFps(), 0x7fffffff);
		text.drawText(framebuffer, 5, framebuffer.height - 48, "X: " ~ to!dstring(mouseX), 0x7fffffff);
		text.drawText(framebuffer, 5, framebuffer.height - 64, "Y: " ~ to!dstring(mouseY), 0x7fffffff);
		
		framebuffer.render();
		glfwSwapBuffers(window);
		framebuffer.clear(0xff000000, 0xffB56300);

		renderFpsCounter.tick();
	}

	private
	{
		Logger log;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		bool shouldRun;
		Text text;
		FpsCounter renderFpsCounter;
	}
}

extern(C) private nothrow
{
	void glfwFramebufferSizeCallback(GLFWwindow* window, int framebufferWidth, int framebufferHeight)
	{
		glViewport(0, 0, framebufferWidth, framebufferHeight);
	}
}
