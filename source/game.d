import std.c.stdlib;
import std.conv;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl;

import logger;
import settings;
import framebuffer;
import text;
import fpscounter;
import rasterizer;

class Game
{
	this(Logger logger)
	{
		this.logger = logger;
		settings = new Settings(logger, "settings.json");

		logger.logInfo("Loading GLFW 3 functions");

		DerelictGLFW3.load();

		glfwSetErrorCallback(&glfwErrorCallback);

		logger.logInfo("Initializing GLFW");

		if (!glfwInit())
			throw new Exception("Could not initialize GLFW");

		logger.logInfo("Creating the window");

		window = glfwCreateWindow(settings.displayWidth, settings.displayHeight, "Softwire", settings.isFullscreen ? glfwGetPrimaryMonitor() : null, null);

		if (!window)
			throw new Exception("Could not create the window");

		glfwMakeContextCurrent(window);
		glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
		glfwSetKeyCallback(window, &glfwKeyCallback);
		glfwSwapInterval(settings.vsyncEnabled ? 1 : 0);

		if (settings.useLegacyOpenGL)
			framebuffer = new FramebufferOpenGL1(logger, settings);
		else
			framebuffer = new FramebufferOpenGL3(logger, settings);

		text = new Text(logger, "data/fonts/aller.ttf", 14);
		renderFpsCounter = new FpsCounter();
		physicsFpsCounter = new FpsCounter();
	}

	~this()
	{
		glfwTerminate();
	}

	void mainloop()
	{
		logger.logInfo("Starting the mainloop");

		double timeStep = 1.0 / 60;
		double currentTime = glfwGetTime();
		double timeAccumulator = 0;

		while (!glfwWindowShouldClose(window))
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

		physicsFpsCounter.tick();
	}

	void render(double interpolation)
	{
		double mouseX, mouseY;
		glfwGetCursorPos(window, &mouseX, &mouseY);

		if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
		{
			rasterizer.drawRectangle(framebuffer, cast(int)mouseX - cast(int)10, cast(int)(settings.displayHeight) - cast(int)mouseY - 10, 20, 20, 0x7fffffff);
		}

		text.drawText(framebuffer, 5, framebuffer.height - 16, "Render FPS: " ~ renderFpsCounter.getRateLimitedFps(), 0x7fffffff);
		text.drawText(framebuffer, 5, framebuffer.height - 32, "Physics FPS: " ~ physicsFpsCounter.getRateLimitedFps(), 0x7fffffff);

		text.drawText(framebuffer, 5, framebuffer.height - 48, "X: " ~ to!dstring(mouseX), 0x7fffffff);
		text.drawText(framebuffer, 5, framebuffer.height - 64, "Y: " ~ to!dstring(mouseY), 0x7fffffff);
		
		framebuffer.render();
		framebuffer.clear();

		glfwSwapBuffers(window);

		renderFpsCounter.tick();
	}

	private
	{
		static Logger logger;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		Text text;
		FpsCounter renderFpsCounter;
		FpsCounter physicsFpsCounter;
	}
}

extern(C) private nothrow
{
	void glfwFramebufferSizeCallback(GLFWwindow* window, int framebufferWidth, int framebufferHeight)
	{
		glViewport(0, 0, framebufferWidth, framebufferHeight);
	}

	void glfwErrorCallback(int error, const(char)* description)
	{
		try
		{
			Game.logger.logError("GLFW: %s", to!string(description));
		}
		catch(Throwable t)
		{
			exit(-1);
		}
	}

	void glfwKeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
	{
		if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
	}
}
