import std.stdio;
import derelict.glfw3.glfw3;
import derelict.opengl3.gl;
import derelict.freetype.ft;

int screenWidth = 1920;
int screenHeight = 1200;

int main()
{
	DerelictGLFW3.load();
	DerelictGL.load();
	DerelictFT.load();

	if (!glfwInit())
		return -1;

	GLFWwindow* window = glfwCreateWindow(screenWidth, screenHeight, "Softwire", glfwGetPrimaryMonitor(), null);

	if (!window)
	{
		glfwTerminate();
		return -1;
	}

	glfwMakeContextCurrent(window);
	DerelictGL.reload();

	while (!glfwWindowShouldClose(window))
	{
		glClear(GL_COLOR_BUFFER_BIT);

		glRotatef(0.1, 0.0, 0.0, 1.0);

		glBegin(GL_TRIANGLES);
		glColor3f(1.0, 0.9, 0.0);
		glVertex3f(-0.6, -0.4, 0.0);
		glColor3f(0.0, 1.0, 0.0);
		glVertex3f(0.6, -0.4, 0.);
		glColor3f(0.0, 0.0, 1.0);
		glVertex3f(0.0, 0.6, 0.0);
		glEnd();

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwTerminate();
	return 0;
}
