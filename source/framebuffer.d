import std.string;

import derelict.opengl3.gl3;

class Framebuffer
{
	this()
	{
	}

	void initialize(int framebufferWidth, int framebufferHeight)
	{
		this.framebufferWidth = framebufferWidth;
		this.framebufferHeight = framebufferHeight;
		framebufferData = new ubyte[framebufferWidth * framebufferHeight * 4];
		framebufferData[] = 128;

		glGenVertexArrays(1, &vaoId);
		glBindVertexArray(vaoId);

		GLuint vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
		GLuint fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
		const(char*) vertexShaderStringZ = vertexShaderString.toStringz();
		const(char*) fragmentShaderStringZ = fragmentShaderString.toStringz();
		glShaderSource(vertexShaderId, 1, &vertexShaderStringZ, null);
		glCompileShader(vertexShaderId);
		glShaderSource(fragmentShaderId, 1, &fragmentShaderStringZ, null);
		glCompileShader(fragmentShaderId);
		shaderProgramId = glCreateProgram();
		glAttachShader(shaderProgramId, vertexShaderId);
		glAttachShader(shaderProgramId, fragmentShaderId);
		glLinkProgram(shaderProgramId);

		textureSamplerId = glGetUniformLocation(shaderProgramId, "in_textureSampler");

		glGenBuffers(1, &vertexAndUvBufferId);
		glBindBuffer(GL_ARRAY_BUFFER, vertexAndUvBufferId);
		glBufferData(GL_ARRAY_BUFFER, (float.sizeof * vertexAndUvData.length), vertexAndUvData.ptr, GL_STATIC_DRAW);

		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, framebufferWidth, framebufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(void*)0);

		glGenSamplers(1, &samplerId);
		glSamplerParameteri(samplerId, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glSamplerParameteri(samplerId, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glSamplerParameteri(samplerId, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	}

	void render()
	{
		glUseProgram(shaderProgramId);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, framebufferWidth, framebufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, framebufferData.ptr);
		glUniform1i(textureSamplerId, 0);
		glBindSampler(0, samplerId);

		glBindBuffer(GL_ARRAY_BUFFER, vertexAndUvBufferId);
		glEnableVertexAttribArray(0);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(void*)(float.sizeof * 12));

		glClearColor(1.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}

	private
	{
		int framebufferWidth;
		int framebufferHeight;
		ubyte[] framebufferData;

		GLuint vaoId;
		GLuint shaderProgramId;
		GLuint textureSamplerId;
		GLuint vertexAndUvBufferId;
		GLuint textureId;
		GLuint samplerId;

		static immutable float[] vertexAndUvData =
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

		string vertexShaderString = "
			#version 330

			layout (location = 0) in vec3 in_position;
			layout (location = 1) in vec2 in_uv;

			out vec2 pass_uv;

			void main()
			{
			gl_Position = vec4(in_position, 1.0);
			pass_uv = in_uv;
			}";

		string fragmentShaderString = "
			#version 330

			uniform sampler2D in_textureSampler;

			in vec2 pass_uv;

			out vec3 out_color;

			void main()
			{
			out_color = texture2D(in_textureSampler, pass_uv).rgb;
			}";
	}
}
