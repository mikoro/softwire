/**
 * Rasterization algorithms for various primitives.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module rasterizer;

import std.stdio;

import color;
import framebuffer;

void drawRectangle(Framebuffer framebuffer, int x, int y, int width, int height, Color rectangleColor)
{
	// if the alpha value is zero, nothing needs to be drawn
	if (rectangleColor.alpha == 0)
		return;

	// drawing outside the framebuffer is "allowed"
	// so calculate clipping values for each side to prevent actual writes outside the framebuffer
	int clipLeft = 0;
	int clipRight = 0;
	int clipBottom = 0;
	int clipTop = 0;

	if (x < 0)
		clipLeft = -1 * x;

	if (x + width > framebuffer.width)
		clipRight = x + width - framebuffer.width;

	if (y < 0)
		clipBottom = -1 * y;

	if (y + height > framebuffer.height)
		clipTop = y + height - framebuffer.height;

	// if the rectangle is completely outside the screen, do nothing
	if (clipLeft >= width || clipRight >= width || clipBottom >= height || clipTop >= height)
		return;

	// simple rectangle resterization
	// if the alpha is fully opaque, skip the alpha blending calculations
	if (rectangleColor.alpha == 255)
	{
		// starting from lower left, draw one line at a time upwards
		foreach (i; y + clipBottom .. y + height - clipTop)
		{
			int framebufferIndex = x + i * framebuffer.width;
			framebuffer.pixelData[framebufferIndex + clipLeft .. framebufferIndex + width - clipRight] = rectangleColor.value;
		}

		return;
	}

	rectangleColor.precalculateAlphaBlend();

	// do the same as above but using alpha blending
	foreach (i; y + clipBottom .. y + height - clipTop)
	{
		int framebufferIndex = x + i * framebuffer.width;

		// can't draw whole lines anymore because every pixel needs to be sampled for alpha blending
		foreach (j; clipLeft .. width - clipRight)
		{
			Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
			rectangleColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
		}
	}
}

void drawCircle(Framebuffer framebuffer, int x, int y, int radius, Color circleColor)
{
	if (circleColor.alpha == 0)
		return;

	int clipLeft = 0;
	int clipRight = 0;
	int clipBottom = 0;
	int clipTop = 0;

	if (x - radius < 0)
		clipLeft = radius - x;

	if (x + radius > framebuffer.width)
		clipRight = x + radius - framebuffer.width;

	if (y - radius < 0)
		clipBottom = radius - y;

	if (y + radius > framebuffer.height)
		clipTop = y + radius - framebuffer.height;

	int doubleRadius = radius * 2;

	if (clipLeft >= doubleRadius || clipRight >= doubleRadius || clipBottom >= doubleRadius || clipTop >= doubleRadius)
		return;

	int squaredRadius = radius * radius;

	if (circleColor.alpha == 255)
	{
		// brute force: go through every pixel inside a square encompassing the circle and if the pixel is inside the circle, draw the pixel
		foreach (i; y - radius + clipBottom .. y + radius - clipTop)
		{
			int framebufferIndex = x + i * framebuffer.width;
			int y2 = (i - y) * (i - y);

			foreach (j; -radius + clipLeft .. radius - clipRight)
			{
				if ((j * j + y2) <= squaredRadius)
					framebuffer.pixelData[framebufferIndex + j] = circleColor.value;
			}
		}

		return;
	}

	circleColor.precalculateAlphaBlend();

	foreach (i; y - radius + clipBottom .. y + radius - clipTop)
	{
		int framebufferIndex = x + i * framebuffer.width;
		int y2 = (i - y) * (i - y);

		foreach (j; -radius + clipLeft .. radius - clipRight)
		{
			if ((j * j + y2) <= squaredRadius)
			{
				Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
				circleColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
			}
		}
	}
}
