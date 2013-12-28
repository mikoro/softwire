/**
 * Text rendering with the Freetype library.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module text;

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
		if (textColor.alpha == 0)
			return;

		foreach (character; text)
		{
			if (!(character in glyphs))
				generateGlyph(character);

			Glyph glyph = glyphs[character];

			int adjustedX = x + glyph.adjustX;
			int adjustedY = y - glyph.adjustY;

			x += glyph.advanceX;

			if (glyph.bitmapWidth == 0 || glyph.bitmapHeight == 0)
				continue;

			int clipLeft = 0;
			int clipRight = 0;
			int clipBottom = 0;
			int clipTop = 0;

			if (adjustedX < 0)
				clipLeft = -1 * adjustedX;

			if (adjustedX + glyph.bitmapWidth > framebuffer.width)
				clipRight = adjustedX + glyph.bitmapWidth - framebuffer.width;

			if (adjustedY < 0)
				clipBottom = -1 * adjustedY;

			if (adjustedY + glyph.bitmapHeight > framebuffer.height)
				clipTop = adjustedY + glyph.bitmapHeight - framebuffer.height;

			if (clipLeft >= glyph.bitmapWidth || clipRight >= glyph.bitmapWidth || clipBottom >= glyph.bitmapHeight || clipTop >= glyph.bitmapHeight)
				continue;

			foreach (i; clipBottom .. glyph.bitmapHeight - clipTop)
			{
				int framebufferIndex = adjustedX + (adjustedY + i) * framebuffer.width;
				int glyphBitmapIndex = i * glyph.bitmapWidth;

				foreach (j; clipLeft .. glyph.bitmapWidth - clipRight)
				{
					ubyte glyphPixelAlpha = glyph.bitmap[glyphBitmapIndex + j];

					if (glyphPixelAlpha == 0)
						continue;

					ubyte combinedAlpha = cast(ubyte)((glyphPixelAlpha / (255.0 / textColor.alpha)));
					Color combinedColor = Color(textColor, combinedAlpha);

					if (combinedColor.alpha == 255)
					{
						framebuffer.pixelData[framebufferIndex + j] = combinedColor.value;
						continue;
					}

					Color framebufferPixelColor = Color(&framebuffer.pixelData[framebufferIndex + j]);
					combinedColor.alphaBlendDirect(framebufferPixelColor);
				}
			}
		}
	}

	private
	{
		void generateGlyph(dchar character)
		{
			FT_Load_Char(face, character, FT_LOAD_FORCE_AUTOHINT | FT_LOAD_RENDER);
			FT_Bitmap* bitmap = &face.glyph.bitmap;

			Glyph glyph;
			glyph.bitmap = new ubyte[bitmap.width * bitmap.rows];
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
					glyph.bitmap[i * bitmap.width + j] = bufferPtr[j];

				bufferPtr += bitmap.pitch;
			}

			glyphs[character] = glyph;
		}

		struct Glyph
		{
			ubyte[] bitmap;
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
