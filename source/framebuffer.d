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

import derelict.opengl3.gl;

import color;
import logger;

class Framebuffer
{
	this(Logger log)
	{
		this.log = log;

		log.logInfo("Loading OpenGL functions");

		DerelictGL.load();

		log.logInfo("OpenGL version: %s", DerelictGL.loadedVersion);

		glEnable(GL_TEXTURE_2D);
		glClearColor(1.0, 0.0, 0.0, 0.0); // base clear color is set to red which should never be visible (if it is, something is very wrong)
		glGenTextures(1, &textureId);

		// prevent color sampling errors on the framebuffer edges, especially when using linear filtering
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	void resize(int width, int height)
	{
		log.logInfo("Resizing framebuffer to %sx%s", width, height);

		this.width = width;
		this.height = height;

		pixelData.length = (width * height);
		depthData.length = (width * height);

		clear();
	}

	// clear framebuffer to black
	void clear()
	{
		pixelData[] = 0;
		depthData[] = float.max;
	}

	// clear framebuffer to given color
	void clear(Color color)
	{
		pixelData[] = color.value;
		depthData[] = float.max;
	}

	// clear framebuffer with a color gradient from bottom (start) to top (end)
	void clear(Color startColor, Color endColor)
	{
		foreach (y; 0 .. height)
		{
			double alpha = y / cast(double)height;
			pixelData[y * width .. y * width + width] = color.lerp(startColor, endColor, alpha).value;
		}

		depthData[] = float.max;
	}

	void render()
	{
		glClear(GL_COLOR_BUFFER_BIT);

		// transfer framebuffer data as a texture to the GPU
		// GL_UNSIGNED_INT_8_8_8_8_REV (ABGR) as a source format seems to be fastest at least on Windows and NVidia hardware
		// could use glTexSubImage2D but there was no performance difference
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, pixelData.ptr);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  0.0);
		glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  0.0);
		glEnd();

		glBindTexture(GL_TEXTURE_2D, 0);
	}

	// if the framebuffer is smaller than the actual window, the framebuffer (texture) will be scaled up by the hardware
	// linear filtering is smoother, nearest will be blocky
	@property void useSmoothFiltering(bool value)
	{
		_useSmoothFiltering = value;

		glBindTexture(GL_TEXTURE_2D, textureId);

		if (_useSmoothFiltering)
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

	@property bool useSmoothFiltering() { return _useSmoothFiltering; }

	int width;
	int height;
	uint[] pixelData;
	float[] depthData;

	private
	{
		Logger log;
		GLuint textureId;
		bool _useSmoothFiltering;
	}
}
