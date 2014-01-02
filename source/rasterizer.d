/**
 * Rasterization algorithms for various primitives.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module rasterizer;

import std.algorithm;
import std.math;
import std.stdio;

import color;
import framebuffer;

// draw a single pixel, cannot draw outside the framebuffer
void drawPixel(Framebuffer framebuffer, int x, int y, Color pixelColor)
in
{
	assert(x >= 0);
	assert(x < framebuffer.width);
	assert(y >= 0);
	assert(y < framebuffer.height);
}
body
{
	if (pixelColor.alpha == 255)
		framebuffer.pixelData[x + y * framebuffer.width] = pixelColor.value;
	else
	{
		Color framebufferPixelColor = Color(&framebuffer.pixelData[x + y * framebuffer.width]);
		pixelColor.alphaBlendDirect(framebufferPixelColor);
	}
}

// draw a single pixel wide line, cannot draw outside the framebuffer
// http://en.wikipedia.org/wiki/Bresenham's_line_algorithm#Optimization
void drawLine(Framebuffer framebuffer, int x0, int y0, int x1, int y1, Color lineColor)
in
{
	assert(x0 >= 0 && x1 >= 0);
	assert(x0 < framebuffer.width && x1 < framebuffer.width);
	assert(y0 >= 0 && y1 >= 0);
	assert(y0 < framebuffer.height && y1 < framebuffer.height);
}
body
{
	bool steep = abs(y1 - y0) > abs(x1 - x0);

	if (steep)
	{
		swap(x0, y0);
		swap(x1, y1);
	}

	if (x0 > x1)
	{
		swap(x0, x1);
		swap(y0, y1);
	}

	int deltaX = x1 - x0;
	int deltaY = abs(y1 - y0);
	int error = deltaX / 2;
	int stepY = (y0 < y1 ? 1 : -1);
	int y = y0;

	if (lineColor.alpha == 255)
	{
		foreach (x; x0 .. x1 + 1)
		{
			if (steep)
				framebuffer.pixelData[y + x * framebuffer.width] = lineColor.value;
			else
				framebuffer.pixelData[x + y * framebuffer.width] = lineColor.value;

			error -= deltaY;

			if (error < 0)
			{
				y += stepY;
				error += deltaX;
			}
		}

		return;
	}

	lineColor.precalculateAlphaBlend();

	foreach (x; x0 .. x1 + 1)
	{
		if (steep)
		{
			Color framebufferPixelColor = Color(&framebuffer.pixelData[y + x * framebuffer.width]);
			lineColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
		}
		else
		{
			Color framebufferPixelColor = Color(&framebuffer.pixelData[x + y * framebuffer.width]);
			lineColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
		}

		error -= deltaY;

		if (error < 0)
		{
			y += stepY;
			error += deltaX;
		}
	}
}

// draw a solid color filled rectangle, can go outside the framebuffer
void drawClippedFilledRectangle(Framebuffer framebuffer, int x, int y, int width, int height, Color rectangleColor)
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
		clipLeft = abs(x);

	if (x + width > framebuffer.width)
		clipRight = x + width - framebuffer.width;

	if (y < 0)
		clipBottom = abs(y);

	if (y + height > framebuffer.height)
		clipTop = y + height - framebuffer.height;

	// if the rectangle is completely outside the screen, nothing needs to be drawn
	if (clipLeft >= width || clipRight >= width || clipBottom >= height || clipTop >= height)
		return;

	// if the color is opaque, skip the alpha blending calculations
	if (rectangleColor.alpha == 255)
	{
		// starting from lower left, draw one complete line at a time and go upwards
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

		// can't draw whole lines at once anymore because every pixel needs to be sampled for alpha blending
		foreach (j; clipLeft .. width - clipRight)
		{
			Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
			rectangleColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
		}
	}
}

// draw a solid color filled circle, can go outside the framebuffer
void drawClippedFilledCircle(Framebuffer framebuffer, int x, int y, int radius, Color circleColor)
{
	if (circleColor.alpha == 0)
		return;

	int clipLeft = 0;
	int clipRight = 0;
	int clipBottom = 0;
	int clipTop = 0;

	if (x - radius < 0)
		clipLeft = radius - x;

	if (x + radius > (framebuffer.width - 1))
		clipRight = x + radius - (framebuffer.width - 1);

	if (y - radius < 0)
		clipBottom = radius - y;

	if (y + radius > (framebuffer.height - 1))
		clipTop = y + radius - (framebuffer.height - 1);

	int doubleRadius = radius * 2;

	if (clipLeft > doubleRadius || clipRight > doubleRadius || clipBottom > doubleRadius || clipTop > doubleRadius)
		return;

	int squaredRadius = radius * radius;

	if (circleColor.alpha == 255)
	{
		// brute force: go through every pixel inside a square encompassing the circle and if the pixel is inside the circle, draw the pixel
		foreach (i; y - radius + clipBottom .. y + radius + 1 - clipTop)
		{
			int framebufferIndex = x + i * framebuffer.width;
			int squaredY = (i - y) * (i - y);

			foreach (j; -radius + clipLeft .. radius + 1 - clipRight)
			{
				if ((j * j + squaredY) <= squaredRadius)
					framebuffer.pixelData[framebufferIndex + j] = circleColor.value;
			}
		}

		return;
	}

	circleColor.precalculateAlphaBlend();

	foreach (i; y - radius + clipBottom .. y + radius + 1 - clipTop)
	{
		int framebufferIndex = x + i * framebuffer.width;
		int squaredY = (i - y) * (i - y);

		foreach (j; -radius + clipLeft .. radius + 1 - clipRight)
		{
			if ((j * j + squaredY) <= squaredRadius)
			{
				Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
				circleColor.alphaBlendPrecalculatedDirect(framebufferPixelColor);
			}
		}
	}
}
