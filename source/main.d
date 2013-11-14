import std.stdio;
import std.string;
import std.file;
import std.random;
import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import derelict.freetype.ft;

import fpscounter;

int screenWidth = 1280;
int screenHeight = 800;

int main()
{
	DerelictGLFW3.load();
	DerelictGL3.load();
	DerelictFT.load();

	glfwSetErrorCallback(&glfwErrorCallback);

	if (!glfwInit())
		return -1;

	//GLFWwindow* window = glfwCreateWindow(screenWidth, screenHeight, "Softwire", glfwGetPrimaryMonitor(), null);
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
	glfwSwapInterval(0);

	GLuint vertexArrayId;
	glGenVertexArrays(1, &vertexArrayId);
	glBindVertexArray(vertexArrayId);

	GLuint vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
	GLuint fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
	const(char*) vertexShaderStringZ = readText("data/basic.vs.glsl").toStringz();
	const(char*) fragmentShaderStringZ = readText("data/basic.fs.glsl").toStringz();

	glShaderSource(vertexShaderId, 1, &vertexShaderStringZ, null);
	glCompileShader(vertexShaderId);
	GLint infoLogLength;
	glGetShaderiv(vertexShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
	char[] strInfoLog = new char[infoLogLength + 1];
	glGetShaderInfoLog(vertexShaderId, infoLogLength, null, strInfoLog.ptr);
	writefln("Vertex shader: %s", strInfoLog);

	glShaderSource(fragmentShaderId, 1, &fragmentShaderStringZ, null);
	glCompileShader(fragmentShaderId);
	glGetShaderiv(fragmentShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
	strInfoLog = new char[infoLogLength + 1];
	glGetShaderInfoLog(fragmentShaderId, infoLogLength, null, strInfoLog.ptr);
	writefln("Fragment shader: %s", strInfoLog);

	GLuint programId = glCreateProgram();
	glAttachShader(programId, vertexShaderId);
	glAttachShader(programId, fragmentShaderId);
	glLinkProgram(programId);

	GLuint textureSamplerUniformId = glGetUniformLocation(programId, "in_textureSampler");

	float[] vertexBufferData =
	[
		-1.0, -1.0, 0.0,
		 1.0, -1.0, 0.0,
		 1.0,  1.0, 0.0,
		-1.0,  1.0, 0.0,

		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0
	];

	GLuint vertexBufferId;
	glGenBuffers(1, &vertexBufferId);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
	glBufferData(GL_ARRAY_BUFFER, (float.sizeof * vertexBufferData.length), vertexBufferData.ptr, GL_STATIC_DRAW);

	ubyte[] textureData = new ubyte[1920 * 1200 * 4];

	GLuint textureId;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1920, 1200, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(void*)0);
	
	GLuint samplerId;
	glGenSamplers(1, &samplerId);
	glSamplerParameteri(samplerId, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glSamplerParameteri(samplerId, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glSamplerParameteri(samplerId, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);

	int framebufferWidth, framebufferHeight;
	glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
	glViewport(0, 0, framebufferWidth, framebufferHeight);

	double lastPrintTime = glfwGetTime();

	FpsCounter fpsCounter = new FpsCounter(0.01);
	
	while (!glfwWindowShouldClose(window))
	{
		textureData[] = 127;

		glUseProgram(programId);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 1920, 1200, GL_RGBA, GL_UNSIGNED_BYTE, textureData.ptr);
		glUniform1i(textureSamplerUniformId, 0);
		glBindSampler(0, samplerId);

		glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(void*)(float.sizeof * 12));
		
		glClearColor(1.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

		glfwSwapBuffers(window);
		glfwPollEvents();

		fpsCounter.countFrame();

		double currentTime = glfwGetTime();
		
		if (currentTime - lastPrintTime >= 0.1)
		{
			lastPrintTime = currentTime;
			writeln(fpsCounter.getFps());
		}
	}

	glfwTerminate();
	readln();

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
