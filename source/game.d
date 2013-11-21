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

		text = new Text(logger, "data/fonts/aller.ttf", 16);
		renderFpsCounter = new FpsCounter();
	}

	~this()
	{
		glfwTerminate();
	}

	void mainloop()
	{
		logger.logInfo("Starting the mainloop");

		while (!glfwWindowShouldClose(window))
		{
			Rasterizer.drawRectangle(framebuffer, 0, 0, framebuffer.width, framebuffer.height, 0x7f0000ff);
			text.drawText(framebuffer, 5, cast(int)framebuffer.height - 16, "FPS: " ~ to!dstring(cast(int)renderFpsCounter.getFps()));
			text.drawText(framebuffer, 5, 15, "The quick brown fox jumps over the lazy dog - Äiti öljyää Åkea.");
			
			framebuffer.render();
			glfwSwapBuffers(window);
			framebuffer.clear();

			renderFpsCounter.tick();

			glfwPollEvents();
		}
	}

	private
	{
		static Logger logger;
		Settings settings;
		GLFWwindow* window;
		Framebuffer framebuffer;
		Text text;
		Text text2;
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
