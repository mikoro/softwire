/**
 * Text rendering with the Freetype library.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module text;

import std.conv;
import std.string;

import derelict.freetype.ft;

import color;
import logger;
import framebuffer;

class Text
{
	this(Logger log, string fontFileName, int size)
	{
		this.log = log;

		log.logInfo("Loading font from %s", fontFileName);

		FT_Error error = FT_Init_FreeType(&library);

		if (error)
			throw new Exception(format("Could not initialize Freetype: %s", error));

		error = FT_New_Face(library, fontFileName.toStringz(), 0, &face);

		if (error)
			throw new Exception(format("Could not load font file: %s", error));

		FT_Set_Pixel_Sizes(face, 0, size);
	}

	void drawText(Framebuffer framebuffer, int x, int y, dstring text, Color textColor)
	{
		foreach (character; text)
		{
			if (!(character in glyphs))
				generateGlyph(character);

			foreach (i; 0 .. glyphs[character].bitmapHeight)
			{
				int framebufferIndex = x + glyphs[character].adjustX + (y - glyphs[character].adjustY + i) * framebuffer.width;
				int glyphBitmapIndex = i * glyphs[character].bitmapWidth;

				foreach (j; 0 .. glyphs[character].bitmapWidth)
				{
					Color glyphPixelColor = Color(&glyphs[character].bitmap[glyphBitmapIndex + j]);

					if (textColor.alpha == 0 || glyphPixelColor.alpha == 0)
						continue;

					ubyte combinedAlpha = cast(ubyte)((glyphPixelColor.alpha / (255.0 / textColor.alpha)) + 0.5);
					Color combinedPixelColor = Color(textColor.red, textColor.green, textColor.blue, combinedAlpha);

					if (combinedPixelColor.alpha == 255)
					{
						framebuffer.pixelData[framebufferIndex + j] = combinedPixelColor.value;
						continue;
					}

					Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
					combinedPixelColor.alphaBlendDirect(framebufferPixelColor);
				}
			}

			x += glyphs[character].advanceX;
		}
	}

	private
	{
		void generateGlyph(dchar character)
		{
			FT_Load_Char(face, character, FT_LOAD_FORCE_AUTOHINT | FT_LOAD_RENDER);
			FT_Bitmap* bitmap = &face.glyph.bitmap;

			Glyph glyph;
			glyph.bitmap = new uint[bitmap.rows * bitmap.width];
			glyph.bitmapWidth = bitmap.width;
			glyph.bitmapHeight = bitmap.rows;

			// http://freetype.org/freetype2/docs/glyphs/glyphs-3.html
			glyph.adjustX = cast(int)(face.glyph.metrics.horiBearingX >> 6);
			glyph.adjustY = cast(int)((face.glyph.metrics.height - face.glyph.metrics.horiBearingY) >> 6);
			glyph.advanceX = cast(int)(face.glyph.metrics.horiAdvance >> 6);

			const(ubyte)* bufferPtr = bitmap.buffer;

			// http://freetype.org/freetype2/docs/glyphs/glyphs-7.html
			foreach_reverse (i; 0 .. bitmap.rows)
			{
				foreach (j; 0 .. bitmap.width)
					glyph.bitmap[i * bitmap.width + j] = (bufferPtr[j] << 24) | 0x00ffffff; // use the alpha value combined with a white color

				bufferPtr += bitmap.pitch;
			}

			glyphs[character] = glyph;
		}

		struct Glyph
		{
			uint[] bitmap;
			int bitmapWidth;
			int bitmapHeight;
			int adjustX;
			int adjustY;
			int advanceX;
		}

		Logger log;
		Glyph[dchar] glyphs;

		FT_Library library;
		FT_Face face;
	}
}
