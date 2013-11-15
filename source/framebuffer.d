import std.random;
import std.string;

import derelict.opengl3.gl3;

class Framebuffer
{
	void initialize(int framebufferWidth, int framebufferHeight)
	{
		this.framebufferWidth = framebufferWidth;
		this.framebufferHeight = framebufferHeight;
		framebufferData = new ubyte[framebufferWidth * framebufferHeight * 4];
		framebufferData[] = 0;

		GLuint vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
		GLuint fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
		const(char*) vertexShaderStringZ = vertexShaderString.toStringz();
		const(char*) fragmentShaderStringZ = fragmentShaderString.toStringz();
		glShaderSource(vertexShaderId, 1, &vertexShaderStringZ, null);
		glShaderSource(fragmentShaderId, 1, &fragmentShaderStringZ, null);
		glCompileShader(vertexShaderId);
		glCompileShader(fragmentShaderId);
		shaderProgramId = glCreateProgram();
		glAttachShader(shaderProgramId, vertexShaderId);
		glAttachShader(shaderProgramId, fragmentShaderId);
		glLinkProgram(shaderProgramId);
		glDetachShader(shaderProgramId, vertexShaderId);
		glDetachShader(shaderProgramId, fragmentShaderId);
		glDeleteShader(vertexShaderId);
		glDeleteShader(fragmentShaderId);

		textureSamplerId = glGetUniformLocation(shaderProgramId, "in_textureSampler");

		glGenVertexArrays(1, &vertexArrayObjectId);
		glBindVertexArray(vertexArrayObjectId);
		glGenBuffers(1, &vertexAndUvBufferId);
		glBindBuffer(GL_ARRAY_BUFFER, vertexAndUvBufferId);
		glBufferData(GL_ARRAY_BUFFER, (float.sizeof * vertexAndUvData.length), vertexAndUvData.ptr, GL_STATIC_DRAW);
		glEnableVertexAttribArray(0);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
		glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(void*)(float.sizeof * 12));
		glBindVertexArray(0);

		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, framebufferWidth, framebufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(void*)0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glGenSamplers(1, &samplerId);
		glSamplerParameteri(samplerId, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glSamplerParameteri(samplerId, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glSamplerParameteri(samplerId, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	}

	void render()
	{
		glClearColor(1.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glUseProgram(shaderProgramId);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, framebufferWidth, framebufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, framebufferData.ptr);
		glBindSampler(0, samplerId);
		glUniform1i(textureSamplerId, 0);

		glBindVertexArray(vertexArrayObjectId);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glBindVertexArray(0);

		glBindSampler(0, 0);
		glBindTexture(GL_TEXTURE_2D, 0);
		glUseProgram(0);
	}

	void clear()
	{
		framebufferData[] = 0;
	}

	ubyte[] getFramebufferData()
	{
		return framebufferData;
	}

	void shutdown()
	{
		glDeleteSamplers(1, &samplerId);
		glDeleteTextures(1, &textureId);
		glDeleteBuffers(1, &vertexAndUvBufferId);
		glDeleteVertexArrays(1, &vertexArrayObjectId);
		glDeleteProgram(shaderProgramId);
	}

	private
	{
		int framebufferWidth;
		int framebufferHeight;
		ubyte[] framebufferData;

		GLuint vertexArrayObjectId;
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
