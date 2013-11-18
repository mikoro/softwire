import std.c.stdlib;
import std.conv;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

import logger;
import settings;
import framebuffer;
import fpscounter;
import rasterizer;

class Game
{
	this(Logger logger)
	{
		this.logger = logger;
	}

	void initialize()
	{
		settings = new Settings(logger, "settings.json");

		glfwSetErrorCallback(&glfwErrorCallback);

		logger.logInfo("Initializing GLFW");

		if (!glfwInit())
			throw new Exception("Could not initialize GLFW");

		logger.logInfo("Creating the window");

		window = glfwCreateWindow(settings.displayWidth, settings.displayHeight, "Softwire", settings.isFullscreen ? glfwGetPrimaryMonitor() : null, null);

		if (!window)
			throw new Exception("Could not create the window");

		logger.logInfo("Loading OpenGL functions");
		
		glfwMakeContextCurrent(window);
		DerelictGL3.reload();

		logger.logInfo("OpenGL version: %s", DerelictGL3.loadedVersion);

		glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
		glfwSetKeyCallback(window, &glfwKeyCallback);
		glfwSwapInterval(settings.vsyncEnabled ? 1 : 0);

		framebuffer = new Framebuffer(logger);
		framebuffer.initialize(settings.framebufferWidth, settings.framebufferHeight);
		renderFpsCounter = new FpsCounter();
	}

	void mainloop()
	{
		while (!glfwWindowShouldClose(window))
		{
			Rasterizer.drawRectangle(framebuffer, 0, 0, settings.framebufferWidth, settings.framebufferHeight, 0x1188ccff);
			Rasterizer.drawRectangle(framebuffer, 1, 1, 8, 8, 0xffaa33ff);

			framebuffer.render();
			framebuffer.clear();

			glfwSwapBuffers(window);
			glfwPollEvents();

			renderFpsCounter.tick();
		}
	}

	void shutdown()
	{
		framebuffer.shutdown();
		glfwTerminate();
	}

	private
	{
		static Logger logger;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		FpsCounter renderFpsCounter;
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
