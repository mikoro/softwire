import std.conv;
import std.string;

import derelict.freetype.ft;

import logger;
import framebuffer;

class Text
{
	this(Logger logger, string fontFileName, int size)
	{
		this.logger = logger;

		if (!isFreetypeLoaded)
		{
			logger.logInfo("Loading Freetype functions");
			DerelictFT.load();
			isFreetypeLoaded = true;
		}

		logger.logInfo("Loading font data from %s", fontFileName);

		FT_Error error = FT_Init_FreeType(&library);

		if (error)
			throw new Exception(format("Could not initialize Freetype: %s", error));

		error = FT_New_Face(library, fontFileName.toStringz(), 0, &face);

		if (error)
			throw new Exception(format("Could not load font file: %s", error));

		FT_Set_Pixel_Sizes(face, 0, size);
	}

	void drawText(Framebuffer framebuffer, int x, int y, const(dchar[]) text)
	{
		int offsetX = x;

		foreach (character; text)
		{
			if (!(character in glyphs))
				generateGlyph(character);

			foreach (i; 0 .. glyphs[character].bitmapHeight)
			{
				int framebufferStart = offsetX + glyphs[character].adjustX + (y + glyphs[character].adjustY + i) * framebuffer.width;
				int framebufferEnd = framebufferStart + glyphs[character].bitmapWidth;
				int bitmapStart = i * glyphs[character].bitmapWidth;
				int bitmapEnd = bitmapStart + glyphs[character].bitmapWidth;

				framebuffer.data[framebufferStart .. framebufferEnd] = glyphs[character].bitmap[bitmapStart .. bitmapEnd];
			}

			offsetX += glyphs[character].advanceX;
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
			glyph.adjustX = face.glyph.bitmap_left;
			//glyph.adjustY = face.glyph.bitmap_top;
			glyph.advanceX = face.glyph.metrics.horiAdvance >> 6;

			const(ubyte)* bufferIndex = bitmap.buffer;

			foreach_reverse (i; 0 .. bitmap.rows)
			{
				foreach (j; 0 .. bitmap.width)
				{
					ubyte red = bufferIndex[j];
					ubyte green = bufferIndex[j];
					ubyte blue = bufferIndex[j];
					ubyte alpha = 0xff;

					glyph.bitmap[i * bitmap.width + j] = (alpha << 24) | (blue << 16) | (green << 8) | red;
				}

				bufferIndex += bitmap.pitch;
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

		Logger logger;
		Glyph[dchar] glyphs;

		FT_Library library;
		FT_Face face;

		static bool isFreetypeLoaded;
	}
}
