/**
 * Framebuffer implementation using OpenGL textured quads.
 *
 * Framebuffer is a byte array, each pixel taking four bytes in the ABGR format.
 * ABGR format (0xAABBGGRR) is used because it seems to be fastest on a (Intel) x86 + Windows (8, 64-bit) + NVidia (GTX 6xx+ series) combo.
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

		glClearColor(1.0, 0.0, 0.0, 0.0); // base clear color is set to red which should never be visible (if it is, something is very wrong)
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);

		// prevent color sampling errors on the framebuffer edges, especially when using linear filtering
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	void resize(int width, int height)
	{
		log.logInfo("Resizing framebuffer to %sx%s", width, height);

		this.width = width;
		this.height = height;

		// resize the arrays
		pixelData.length = (width * height);
		depthData.length = (width * height);

		clear();

		// allocate the texture memory
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, pixelData.ptr);
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

		// update the texture data
		// GL_UNSIGNED_INT_8_8_8_8_REV (ABGR) as a source format seems to be fastest at least on Windows and NVidia hardware
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, pixelData.ptr);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  0.0);
		glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  0.0);
		glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  0.0);
		glEnd();
	}

	// if the framebuffer is smaller than the actual window, the framebuffer (texture) will be scaled up by the hardware
	// linear filtering is smoother, nearest will be blocky
	@property void useSmoothFiltering(bool value)
	{
		_useSmoothFiltering = value;

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
