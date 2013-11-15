import std.stdio;
import std.string;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

import framebuffer;
import fpscounter;

class Game
{
	void initialize()
	{
		glfwSetErrorCallback(&glfwErrorCallback);

		if (!glfwInit())
			throw new Exception("Could not initialize GLFW");

		window = glfwCreateWindow(displayWidth, displayHeight, "Softwire", null, null);

		if (!window)
			throw new Exception("Could not create the window");

		glfwMakeContextCurrent(window);
		DerelictGL3.reload();
		glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
		glfwSetKeyCallback(window, &glfwKeyCallback);
		glfwSwapInterval(0);

		framebuffer = new Framebuffer();
		framebuffer.initialize(displayWidth, displayHeight);
		renderFpsCounter = new FpsCounter();
	}

	void mainloop()
	{
		while (!glfwWindowShouldClose(window))
		{
			auto fb = framebuffer.getFramebufferData();

			fb[] = 128;

			framebuffer.render();
			framebuffer.clear();

			glfwSwapBuffers(window);
			glfwPollEvents();

			renderFpsCounter.tick();
			writeln(renderFpsCounter.getFps());

			GLenum error = glGetError();

			if (error != GL_NO_ERROR)
				throw new Exception(format("OpenGL error: %s", error));
		}
	}

	void shutdown()
	{
		framebuffer.shutdown();
		glfwTerminate();
	}

	private
	{
		GLFWwindow* window;

		int displayWidth = 1280;
		int displayHeight = 800;

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
		printf("GLFW error: %s\n", description);
	}

	void glfwKeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
	{
		if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
	}
}
