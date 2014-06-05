/**
 * Game initialization and running logic.
 *
 * Copyright © 2014 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT, see the LICENSE file.
 */

module game_engine;

import std.math;

import deimos.glfw.glfw3;
import derelict.opengl3.gl;

import color;
import fps_counter;
import framebuffer;
import logger;
import rasterizer;
import settings;
import text_rasterizer;

class GameEngine
{
	this(Logger log, Settings settings)
	{
		this.log = log;
		this.settings = settings;
	}

	void initialize()
	{
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

		text = new TextRasterizer(log, "data/fonts/dejavu-sans-mono-regular.ttf", 14);
		bigText = new TextRasterizer(log, "data/fonts/dejavu-sans-bold.ttf", 200);
		signatureText = new TextRasterizer(log, "data/fonts/alexbrush-regular.ttf", 32);
		renderFpsCounter = new FpsCounter();
	}

	void run()
	{
		double timeStep = 1.0 / 60;
		double currentTime = glfwGetTime();
		double timeAccumulator = 0;

		// http://gafferongames.com/game-physics/fix-your-timestep/
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

	private void update(double timeStep)
	{
		glfwPollEvents();

		if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
			shouldRun = false;

		if (glfwWindowShouldClose(window))
			shouldRun = false;

		if (glfwGetKey(window, GLFW_KEY_F10) == GLFW_PRESS)
		{
			if (!keyHandled[GLFW_KEY_F10])
			{
				framebuffer.useSmoothFiltering = !framebuffer.useSmoothFiltering;
				keyHandled[GLFW_KEY_F10] = true;
			}
		}
		else
			keyHandled[GLFW_KEY_F10] = false;

		if (glfwGetKey(window, GLFW_KEY_F11) == GLFW_PRESS)
		{
			if (!keyHandled[GLFW_KEY_F11])
			{
				framebufferScale *= 0.5;
				framebuffer.resize(cast(int)(windowWidth * framebufferScale + 0.5), cast(int)(windowHeight * framebufferScale + 0.5));
				keyHandled[GLFW_KEY_F11] = true;
			}
		}
		else
			keyHandled[GLFW_KEY_F11] = false;

		if (glfwGetKey(window, GLFW_KEY_F12) == GLFW_PRESS)
		{
			if (!keyHandled[GLFW_KEY_F12])
			{
				framebufferScale *= 2.0;

				if (framebufferScale > 1.0)
					framebufferScale = 1.0;

				framebuffer.resize(cast(int)(windowWidth * framebufferScale + 0.5), cast(int)(windowHeight * framebufferScale + 0.5));
				keyHandled[GLFW_KEY_F12] = true;
			}
		}
		else
			keyHandled[GLFW_KEY_F12] = false;

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

	private void render(double interpolation)
	{
		framebuffer.clear(Color(0, 0, 0, 255), Color(0, 100, 180, 255));

		bigText.drawText(framebuffer, (framebuffer.width - 930) / 2 - 15, framebuffer.height / 2 - 50, "Softwire", Color(0, 64, 255, 128));
		
		double angle = 0;
		double angleDelta = (PI * 2.0) / 400;
		foreach (i; 0 .. 400)
		{
			int xx0 = cast(int)(cos(angle) * (framebuffer.width - 1) / 2.0 + (framebuffer.width - 1) / 2.0 + 0.5);
			int yy0 = cast(int)(sin(angle) * (framebuffer.height - 1) / 2.0 + (framebuffer.height - 1) / 2.0 + 0.5);
			int xx1 = cast(int)(cos(angle + PI) * (framebuffer.width - 1) / 2.0 + (framebuffer.width - 1) / 2.0 + 0.5);
			int yy1 = cast(int)(sin(angle + PI) * (framebuffer.height - 1) / 2.0 + (framebuffer.height - 1) / 2.0 + 0.5);
			rasterizer.drawLine(framebuffer, xx0, yy0, xx1, yy1, Color(255, 255, 255, 32));
			angle += angleDelta;
		}

		double time = glfwGetTime();
		int x0 = cast(int)(cos(time) * (framebuffer.width - 1) / 2.0 + (framebuffer.width - 1) / 2.0 + 0.5);
		int y0 = cast(int)(sin(time) * (framebuffer.height - 1) / 2.0 + (framebuffer.height - 1) / 2.0 + 0.5);
		int x1 = cast(int)(cos(time + 2.0 * PI * (1.0/3.0)) * (framebuffer.width - 1) / 2.0 + (framebuffer.width - 1) / 2.0 + 0.5);
		int y1 = cast(int)(sin(time + 2.0 * PI * (1.0/3.0)) * (framebuffer.height - 1) / 2.0 + (framebuffer.height - 1) / 2.0 + 0.5);
		int x2 = cast(int)(cos(time + 2.0 * PI * (2.0/3.0)) * (framebuffer.width - 1) / 2.0 + (framebuffer.width - 1) / 2.0 + 0.5);
		int y2 = cast(int)(sin(time + 2.0 * PI * (2.0/3.0)) * (framebuffer.height - 1) / 2.0 + (framebuffer.height - 1) / 2.0 + 0.5);
		rasterizer.drawFilledTriangle(framebuffer, x0, y0, x1, y1, x2, y2, Color(0, 0, 0, 64));

		rasterizer.drawClippedFilledCircle(framebuffer, cast(int)((framebuffer.width - 1) / 2.0 + 0.5), cast(int)((framebuffer.height - 1) / 2.0 + 0.5), cast(int)((framebuffer.height - 1) / 4.0 + 0.5), Color(100, 200, 255, 128));
		
		if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
			rasterizer.drawClippedFilledCircle(framebuffer, framebufferMouseX, framebufferMouseY, 100, Color(255, 0, 0, 128));
		
		text.drawText(framebuffer, 5, framebuffer.height - (16 * 1), "FPS: " ~ renderFpsCounter.getFpsString(), Color(255, 255, 255, 128));

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
		bool shouldRun = true;

		int windowWidth;
		int windowHeight;
		int windowMouseX;
		int windowMouseY;
		int framebufferMouseX;
		int framebufferMouseY;

		double framebufferScale;

		bool[int] keyHandled;

		TextRasterizer text;
		TextRasterizer bigText;
		TextRasterizer signatureText;

		FpsCounter renderFpsCounter;
	}
}
