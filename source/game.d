import std.c.stdlib;
import std.conv;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

import logger;
import framebuffer;
import fpscounter;

class Game
{
	this(Logger logger)
	{
		this.logger = logger;
	}

	void initialize()
	{
		glfwSetErrorCallback(&glfwErrorCallback);

		logger.logInfo("Initializing GLFW");

		if (!glfwInit())
			throw new Exception("Could not initialize GLFW");

		logger.logInfo("Creating the window");

		window = glfwCreateWindow(displayWidth, displayHeight, "Softwire", null, null);

		if (!window)
			throw new Exception("Could not create the window");

		logger.logInfo("Loading OpenGL functions");
		
		glfwMakeContextCurrent(window);
		DerelictGL3.reload();

		logger.logInfo("OpenGL version: %s", DerelictGL3.loadedVersion);

		glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
		glfwSetKeyCallback(window, &glfwKeyCallback);
		glfwSwapInterval(0);

		framebuffer = new Framebuffer(logger);
		framebuffer.initialize(displayWidth, displayHeight);
		renderFpsCounter = new FpsCounter();
	}

	void mainloop()
	{
		while (!glfwWindowShouldClose(window))
		{
			framebuffer.data[] = 128;

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
		GLFWwindow* window;
		Framebuffer framebuffer;
		FpsCounter renderFpsCounter;

		int displayWidth = 1280;
		int displayHeight = 800;
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
