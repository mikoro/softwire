/**
 * A framebuffer implementation using OpenGL textured quads.
 *
 * Framebuffer is a byte array, each pixel taking four bytes in the ABGR format.
 * 0,0 is the bottom left corner.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module framebuffer;

import std.string;

import derelict.opengl3.gl;
import derelict.opengl3.gl3;

import logger;
import settings;

class Framebuffer
{
	abstract void render();

	void clear()
	{
		data[] = 0;
	}

	void clear(uint color)
	{
		data[] = color;
	}

	void clear(uint startColor, uint endColor)
	{
		uint resultColor;
		ubyte* c1 = cast(ubyte*)&startColor;
		ubyte* c2 = cast(ubyte*)&endColor;
		ubyte* c3 = cast(ubyte*)&resultColor;

		foreach (y; 0 .. height)
		{
			double alpha = y / cast(double)height;
			c3[0] = cast(ubyte)((c1[0] + (c2[0] - c1[0]) * alpha) + 0.5);
			c3[1] = cast(ubyte)((c1[1] + (c2[1] - c1[1]) * alpha) + 0.5);
			c3[2] = cast(ubyte)((c1[2] + (c2[2] - c1[2]) * alpha) + 0.5);
			c3[3] = 0xff;

			data[y * width .. y * width + width] = resultColor;
		}
	}

	uint[] data;
	int width;
	int height;
}

class FramebufferOpenGL3 : Framebuffer
{
	this(Logger logger, Settings settings)
	{
		this.logger = logger;

		logger.logInfo("Loading OpenGL 3 functions");

		DerelictGL3.load();
		DerelictGL3.reload();

		logger.logInfo("OpenGL version: %s", DerelictGL3.loadedVersion);

		width = settings.displayWidth / settings.framebufferScale;
		height = settings.displayHeight / settings.framebufferScale;
		data = new uint[width * height];

		logger.logInfo("Compiling shaders");

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

		logger.logInfo("Allocating vertex and texture memory");

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
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, cast(void*)0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glGenSamplers(1, &samplerId);

		if (settings.useLinearFiltering)
		{
			glSamplerParameteri(samplerId, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glSamplerParameteri(samplerId, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		}
		else
		{
			glSamplerParameteri(samplerId, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glSamplerParameteri(samplerId, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		}

		glClearColor(1.0, 0.0, 0.0, 0.0);
	}

	~this()
	{
		glDeleteSamplers(1, &samplerId);
		glDeleteTextures(1, &textureId);
		glDeleteBuffers(1, &vertexAndUvBufferId);
		glDeleteVertexArrays(1, &vertexArrayObjectId);
		glDeleteProgram(shaderProgramId);
	}

	override void render()
	{
		glClear(GL_COLOR_BUFFER_BIT);

		glUseProgram(shaderProgramId);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, data.ptr);
		glBindSampler(0, samplerId);
		glUniform1i(textureSamplerId, 0);

		glBindVertexArray(vertexArrayObjectId);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glBindVertexArray(0);

		glBindSampler(0, 0);
		glBindTexture(GL_TEXTURE_2D, 0);
		glUseProgram(0);
	}

	private
	{
		Logger logger;

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

class FramebufferOpenGL1 : Framebuffer
{
	this(Logger logger, Settings settings)
	{
		this.logger = logger;

		logger.logInfo("Loading legacy OpenGL functions");

		DerelictGL.load();

		logger.logInfo("OpenGL version: %s", DerelictGL.loadedVersion);

		width = settings.displayWidth / settings.framebufferScale;
		height = settings.displayHeight / settings.framebufferScale;
		data = new uint[width * height];

		glEnable(GL_TEXTURE_2D);
		glClearColor(1.0, 0.0, 0.0, 0.0);

		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, cast(void*)0);

		if (settings.useLinearFiltering)
		{
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		}
		else
		{
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		}

		glBindTexture(GL_TEXTURE_2D, 0);
	}

	override void render()
	{
		glClear(GL_COLOR_BUFFER_BIT);

		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, data.ptr);
		
		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  0.0);
		glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  0.0);
		glEnd();

		glBindTexture(GL_TEXTURE_2D, 0);
	}

	private
	{
		Logger logger;

		GLuint textureId;
	}
}
