/**
 * Implements rasterization algorithms for different primitives.
 *
 * Copyright: Copyright (C) 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT License, see the LICENSE.txt file
 */

module rasterizer;

import std.stdio;

import framebuffer;

void drawRectangle(Framebuffer framebuffer, int x, int y, int width, int height, uint color)
{
	ubyte* fg = cast(ubyte*)&color;

	if (fg[3] == 0)
		return;

	if (x < 0)
	{
		width += x;
		x = 0;
	}

	if (y < 0)
	{
		height += y;
		y = 0;
	}

	if (x + width > framebuffer.width)
		width -= ((x + width) - framebuffer.width);

	if (y + height > framebuffer.height)
		height -= ((y + height) - framebuffer.height);

	if (width <= 0 || height <= 0)
		return;

	if (fg[3] == 0xff)
	{
		foreach (i; y .. y + height)
		{
			uint framebufferStart = x + i * framebuffer.width;

			foreach(j; 0 .. width)
			{
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

	foreach (i; y .. y + height)
	{
		uint framebufferStart = x + i * framebuffer.width;

		foreach(j; 0 .. width)
		{
			ubyte* bg = cast(ubyte*)(&framebuffer.data[framebufferStart + j]);

			bg[0] = cast(ubyte)((afg0 + invAlpha * bg[0]) >> 8);
			bg[1] = cast(ubyte)((afg1 + invAlpha * bg[1]) >> 8);
			bg[2] = cast(ubyte)((afg2 + invAlpha * bg[2]) >> 8);
			bg[3] = 0xff;
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
