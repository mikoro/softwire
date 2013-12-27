/**
 * Rasterization algorithms for various primitives.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module rasterizer;

import std.stdio;

import framebuffer;

void drawRectangle(Framebuffer framebuffer, int x, int y, int width, int height, uint color)
{
	// shortcut to access parts of the color with array notation
	ubyte* fg = cast(ubyte*)&color;

	// if the alpha value is zero, nothing needs to be drawn
	if (fg[3] == 0)
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
	if (fg[3] == 0xff)
	{
		foreach (i; y + clipBottom .. y + height - clipTop)
		{
			int framebufferStart = x + i * framebuffer.width;
			framebuffer.data[framebufferStart + clipLeft .. framebufferStart + width - clipRight] = color;
		}

		return;
	}

	// do the same as above but with alpha blending
	// the +1 thing is done because >> 8 divides by 256
	int alpha = fg[3] + 1;
	int invAlpha = 257 - alpha;
	int afg0 = alpha * fg[0];
	int afg1 = alpha * fg[1];
	int afg2 = alpha * fg[2];

	foreach (i; y + clipBottom .. y + height - clipTop)
	{
		int framebufferStart = x + i * framebuffer.width;

		foreach(j; clipLeft .. width - clipRight)
		{
			ubyte* bg = cast(ubyte*)(&framebuffer.data[framebufferStart + j]);

			bg[0] = cast(ubyte)((afg0 + invAlpha * bg[0]) >> 8);
			bg[1] = cast(ubyte)((afg1 + invAlpha * bg[1]) >> 8);
			bg[2] = cast(ubyte)((afg2 + invAlpha * bg[2]) >> 8);
		}
	}
}

void drawCircle(Framebuffer framebuffer, int x, int y, int radius, uint color)
{
	ubyte* fg = cast(ubyte*)&color;

	if (fg[3] == 0)
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

	if (fg[3] == 0xff)
	{
		foreach (i; y - radius + clipBottom .. y + radius - clipTop)
		{
			int framebufferStart = x + i * framebuffer.width;
			int y2 = (i - y) * (i - y);

			foreach(j; -radius + clipLeft .. radius - clipRight)
			{
				if ((j * j + y2) <= squaredRadius)
					framebuffer.data[framebufferStart + j] = color;
			}
		}

		return;
	}

	uint alpha = fg[3] + 1;
	uint invAlpha = 257 - alpha;
	uint afg0 = alpha * fg[0];
	uint afg1 = alpha * fg[1];
	uint afg2 = alpha * fg[2];

	foreach (i; y - radius + clipBottom .. y + radius - clipTop)
	{
		int framebufferStart = x + i * framebuffer.width;
		int y2 = (i - y) * (i - y);

		foreach(j; -radius + clipLeft .. radius - clipRight)
		{
			if ((j * j + y2) <= squaredRadius)
			{
				ubyte* bg = cast(ubyte*)(&framebuffer.data[framebufferStart + j]);

				bg[0] = cast(ubyte)((afg0 + invAlpha * bg[0]) >> 8);
				bg[1] = cast(ubyte)((afg1 + invAlpha * bg[1]) >> 8);
				bg[2] = cast(ubyte)((afg2 + invAlpha * bg[2]) >> 8);
				bg[3] = 0xff;
			}
		}
	}
}
