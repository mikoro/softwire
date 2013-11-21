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
				int framebufferStart = offsetX + glyphs[character].adjustX + (y - glyphs[character].adjustY + i) * framebuffer.width;
				int bitmapStart = i * glyphs[character].bitmapWidth;

				foreach (j; 0 .. glyphs[character].bitmapWidth)
				{
					byte* bg = cast(byte*)&framebuffer.data[framebufferStart + j];
					byte* fg = cast(byte*)&glyphs[character].bitmap[bitmapStart + j];

					int alpha = (fg[3] & 0xff) + 1;
					int inverseAlpha = 257 - alpha;

					bg[0] = cast(byte)((alpha * (fg[0] & 0xff) + inverseAlpha * (bg[0] & 0xff)) >> 8);
					bg[1] = cast(byte)((alpha * (fg[1] & 0xff) + inverseAlpha * (bg[1] & 0xff)) >> 8);
					bg[2] = cast(byte)((alpha * (fg[2] & 0xff) + inverseAlpha * (bg[2] & 0xff)) >> 8);
					bg[3] = cast(byte)0xff;
				}
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
			glyph.bitmap = new int[bitmap.rows * bitmap.width];
			glyph.bitmapWidth = bitmap.width;
			glyph.bitmapHeight = bitmap.rows;
			glyph.adjustX = face.glyph.metrics.horiBearingX >> 6;
			glyph.adjustY = (face.glyph.metrics.height - face.glyph.metrics.horiBearingY) >> 6;
			glyph.advanceX = face.glyph.metrics.horiAdvance >> 6;

			const(ubyte)* bufferIndex = bitmap.buffer;

			foreach_reverse (i; 0 .. bitmap.rows)
			{
				foreach (j; 0 .. bitmap.width)
					glyph.bitmap[i * bitmap.width + j] = ( bufferIndex[j] << 24) | 0xffffff;

				bufferIndex += bitmap.pitch;
			}

			glyphs[character] = glyph;
		}

		struct Glyph
		{
			int[] bitmap;
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
