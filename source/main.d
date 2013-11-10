import std.stdio;
import std.string;
import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import derelict.freetype.ft;

int screenWidth = 1280;
int screenHeight = 800;

string vertexShaderString =
"#version 330\n"
"layout(location = 0) in vec4 position;"
"void main()"
"{"
"   gl_Position = position;"
"}";

string fragmentShaderString =
"#version 330\n"
"out vec4 outputColor;"
"void main()"
"{"
"   outputColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);"
"}";

int main()
{
	DerelictGLFW3.load();
	DerelictGL3.load();
	DerelictFT.load();

	glfwSetErrorCallback(&glfwErrorCallback);

	if (!glfwInit())
		return -1;

	GLFWwindow* window = glfwCreateWindow(screenWidth, screenHeight, "Softwire", null, null);

	if (!window)
	{
		glfwTerminate();
		return -1;
	}

	glfwMakeContextCurrent(window);
	DerelictGL3.reload();
	glfwSetFramebufferSizeCallback(window, &glfwFramebufferSizeCallback);
	glfwSetKeyCallback(window, &glfwKeyCallback);

	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	const(char*) vertexShaderStringZ = vertexShaderString.toStringz();
	const(char*) fragmentShaderStringZ = fragmentShaderString.toStringz();
	glShaderSource(vertexShader, 1, &vertexShaderStringZ, null);
	glCompileShader(vertexShader);
	glShaderSource(fragmentShader, 1, &fragmentShaderStringZ, null);
	glCompileShader(fragmentShader);

	GLuint program = glCreateProgram();
	glAttachShader(program, vertexShader);
	glAttachShader(program, fragmentShader);
	glLinkProgram(program);

	float[] vertexPositions =
	[
		0, 0.5, 0.0, 1.0,
		0.5, -0.5, 0.0, 1.0,
		-0.5, -0.5, 0.0, 1.0,
	];

	GLuint positionBufferObject;
	glGenBuffers(1, &positionBufferObject);
	glBindBuffer(GL_ARRAY_BUFFER, positionBufferObject);
	glBufferData(GL_ARRAY_BUFFER, (float.sizeof * vertexPositions.length), vertexPositions.ptr, GL_STATIC_DRAW);

	int framebufferWidth, framebufferHeight;
	glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
	glViewport(0, 0, framebufferWidth, framebufferHeight);

	while (!glfwWindowShouldClose(window))
	{
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glUseProgram(program);

		glBindBuffer(GL_ARRAY_BUFFER, positionBufferObject);
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, null);

		glDrawArrays(GL_TRIANGLES, 0, 3);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwTerminate();
	return 0;
}

private extern(C) nothrow
{
	void glfwFramebufferSizeCallback(GLFWwindow* window, int framebufferWidth, int framebufferHeight)
	{
		glViewport(0, 0, framebufferWidth, framebufferHeight);
	}

	void glfwErrorCallback(int error, const(char)* description)
	{
		printf("GLFW error: %s", description);
	}

	void glfwKeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
	{
		if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
			glfwSetWindowShouldClose(window, GL_TRUE);
	}
}
