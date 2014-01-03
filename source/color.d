/**
 * Helper functions for color calculations.
 *
 * Color format is assumed to be 32-bit uint ABGR (0xAABBGGRR) and stored in little-endian order.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module color;

struct Color
{
	@disable this();

	// create a new color from an integer representation (fast)
	this(uint color)
	{
		this.color = color;
		this.colorPtr = &this.color;
		this.colorArray = cast(ubyte*)colorPtr;
	}

	// create a new color encapsulating existing color value and modify it directly (fast)
	this(uint* colorPtr)
	{
		this.colorPtr = colorPtr;
		this.colorArray = cast(ubyte*)colorPtr;
	}

	// copy another color (fast)
	this(Color color)
	{
		this(color.value);
	}

	// copy another color but set the alpha to another value (fast)
	this(Color color, ubyte alpha)
	{
		this(color.value);
		this.alpha = alpha;
	}

	// construct the color value from individual values (slow, do not call in a loop)
	this(ubyte red, ubyte green, ubyte blue, ubyte alpha)
	{
		color = alpha << 24 |  blue << 16 | green << 8 | red << 0;
		colorPtr = &color;
		colorArray = cast(ubyte*)colorPtr;
	}

	// alpha blend with another color and return a new color, originals are not modified
	Color alphaBlend(Color otherColor)
	{
		Color newColor = Color(0xFF000000);

		int tempAlpha = alpha + 1;
		int tempInvAlpha = 257 - tempAlpha;

		newColor.red = cast(ubyte)((tempAlpha * red + tempInvAlpha * otherColor.red) >> 8);
		newColor.green = cast(ubyte)((tempAlpha * green + tempInvAlpha * otherColor.green) >> 8);
		newColor.blue = cast(ubyte)((tempAlpha * blue + tempInvAlpha * otherColor.blue) >> 8);

		return newColor;
	}

	// alpha blend with another color and modify the other color directly
	void alphaBlendDirect(Color otherColor)
	{
		int tempAlpha = alpha + 1;
		int tempInvAlpha = 257 - tempAlpha;

		otherColor.red = cast(ubyte)((tempAlpha * red + tempInvAlpha * otherColor.red) >> 8);
		otherColor.green = cast(ubyte)((tempAlpha * green + tempInvAlpha * otherColor.green) >> 8);
		otherColor.blue = cast(ubyte)((tempAlpha * blue + tempInvAlpha * otherColor.blue) >> 8);
	}

	// alpha blend using precalculated values (precalculateAlphaBlend must be called before) and modify the other color directly
	void alphaBlendPrecalculatedDirect(Color otherColor)
	{
		otherColor.red = cast(ubyte)((precalcRed + precalcInvAlpha * otherColor.red) >> 8);
		otherColor.green = cast(ubyte)((precalcGreen + precalcInvAlpha * otherColor.green) >> 8);
		otherColor.blue = cast(ubyte)((precalcBlue + precalcInvAlpha * otherColor.blue) >> 8);
	}

	void precalculateAlphaBlend()
	{
		precalcAlpha = alpha + 1;
		precalcInvAlpha = 257 - precalcAlpha;
		precalcRed = precalcAlpha * red;
		precalcGreen = precalcAlpha * green;
		precalcBlue = precalcAlpha * blue;
	}

	@property uint value() { return *colorPtr; }
	@property void value(uint value) { *colorPtr = value; }

	@property ubyte red() { return colorArray[0]; }
	@property void red(ubyte value) { colorArray[0] = value; }

	@property ubyte green() { return colorArray[1]; }
	@property void green(ubyte value) { colorArray[1] = value; }

	@property ubyte blue() { return colorArray[2]; }
	@property void blue(ubyte value) { colorArray[2] = value; }

	@property ubyte alpha() { return colorArray[3]; }
	@property void alpha(ubyte value) { colorArray[3] = value; }

	private
	{
		uint color;
		uint* colorPtr;
		ubyte* colorArray;

		int precalcAlpha;
		int precalcInvAlpha;
		int precalcRed;
		int precalcGreen;
		int precalcBlue;
	}
}

// linearly interpolate between two color values
Color lerp(Color startColor, Color endColor, double alpha)
{
	Color newColor = Color(0);

	newColor.red = cast(ubyte)((startColor.red + (endColor.red - startColor.red) * alpha) + 0.5);
	newColor.green = cast(ubyte)((startColor.green + (endColor.green - startColor.green) * alpha) + 0.5);
	newColor.blue = cast(ubyte)((startColor.blue + (endColor.blue - startColor.blue) * alpha) + 0.5);
	newColor.alpha = cast(ubyte)((startColor.alpha + (endColor.alpha - startColor.alpha) * alpha) + 0.5);

	return newColor;
}
