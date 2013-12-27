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

void drawRectangle(Framebuffer framebuffer, int x, int y, int width, int height, Color color)
{
	// if the alpha value is zero, nothing needs to be drawn
	if (color.alpha == 0)
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
	if (color.alpha == 255)
	{
		foreach (i; y + clipBottom .. y + height - clipTop)
		{
			int startIndex = x + i * framebuffer.width;
			framebuffer.pixelData[startIndex + clipLeft .. startIndex + width - clipRight] = color.value;
		}

		return;
	}

	color.precalculateAlphaBlend();

	// do the same as above but using alpha blending
	foreach (i; y + clipBottom .. y + height - clipTop)
	{
		int startIndex = x + i * framebuffer.width;

		foreach (j; clipLeft .. width - clipRight)
		{
			uint* destColor = &framebuffer.pixelData[startIndex + j];
			color.alphaBlendPrecalculatedDirect(Color(destColor));
		}
	}
}

void drawCircle(Framebuffer framebuffer, int x, int y, int radius, Color color)
{
	if (color.alpha == 0)
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

	if (color.alpha == 255)
	{
		foreach (i; y - radius + clipBottom .. y + radius - clipTop)
		{
			int startIndex = x + i * framebuffer.width;
			int y2 = (i - y) * (i - y);

			foreach (j; -radius + clipLeft .. radius - clipRight)
			{
				if ((j * j + y2) <= squaredRadius)
					framebuffer.pixelData[startIndex + j] = color.value;
			}
		}

		return;
	}

	color.precalculateAlphaBlend();

	foreach (i; y - radius + clipBottom .. y + radius - clipTop)
	{
		int startIndex = x + i * framebuffer.width;
		int y2 = (i - y) * (i - y);

		foreach (j; -radius + clipLeft .. radius - clipRight)
		{
			if ((j * j + y2) <= squaredRadius)
			{
				uint* destColor = &framebuffer.pixelData[startIndex + j];
				color.alphaBlendPrecalculatedDirect(Color(destColor));
			}
		}
	}
}
