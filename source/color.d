/**
 * Helper functions for color calculations.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module color;

struct Color
{
	@disable this();

	this(ubyte red, ubyte green, ubyte blue, ubyte alpha)
	{
		color = alpha << 24 |  blue << 16 | green << 8 | red << 0;
		colorPtr = &color;
		colorArray = cast(ubyte*)colorPtr;
	}

	this(Color color)
	{
		this(color.value);
	}

	this(Color color, ubyte alpha)
	{
		this(color.value);
		this.alpha = alpha;
	}

	this(uint color)
	{
		this.color = color;
		this.colorPtr = &this.color;
		this.colorArray = cast(ubyte*)colorPtr;
	}

	this(uint* colorPtr)
	{
		this.colorPtr = colorPtr;
		this.colorArray = cast(ubyte*)colorPtr;
	}

	static Color lerp(Color startColor, Color endColor, double alpha)
	{
		Color newColor = Color(0, 0, 0, 0);

		newColor.red = cast(ubyte)((startColor.red + (endColor.red - startColor.red) * alpha) + 0.5);
		newColor.green = cast(ubyte)((startColor.green + (endColor.green - startColor.green) * alpha) + 0.5);
		newColor.blue = cast(ubyte)((startColor.blue + (endColor.blue - startColor.blue) * alpha) + 0.5);
		newColor.alpha = cast(ubyte)((startColor.alpha + (endColor.alpha - startColor.alpha) * alpha) + 0.5);

		return newColor;
	}

	/// Do alpha blending with another color and return a new color, originals are not modified.
	Color alphaBlend(Color otherColor)
	{
		Color newColor = Color(0, 0, 0, 255);

		int tempAlpha = alpha + 1;
		int tempInvAlpha = 257 - tempAlpha;

		newColor.red = cast(ubyte)((tempAlpha * red + tempInvAlpha * otherColor.red) >> 8);
		newColor.green = cast(ubyte)((tempAlpha * green + tempInvAlpha * otherColor.green) >> 8);
		newColor.blue = cast(ubyte)((tempAlpha * blue + tempInvAlpha * otherColor.blue) >> 8);

		return newColor;
	}

	void alphaBlendDirect(Color otherColor)
	{
		int tempAlpha = alpha + 1;
		int tempInvAlpha = 257 - tempAlpha;

		otherColor.red = cast(ubyte)((tempAlpha * red + tempInvAlpha * otherColor.red) >> 8);
		otherColor.green = cast(ubyte)((tempAlpha * green + tempInvAlpha * otherColor.green) >> 8);
		otherColor.blue = cast(ubyte)((tempAlpha * blue + tempInvAlpha * otherColor.blue) >> 8);
	}

	/// Do alpha blending using precalculated values (precalculateAlphaBlend must be called before) and modify the other color directly
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
