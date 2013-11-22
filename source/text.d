import std.conv;
import std.string;

import derelict.freetype.ft;

import logger;
import framebuffer;

class Text
{
	this(Logger logger, string fontFileName, uint size)
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

	void drawText(Framebuffer framebuffer, uint x, uint y, dstring text, uint color)
	{
		uint offsetX = x;

		foreach (character; text)
		{
			if (!(character in glyphs))
				generateGlyph(character);

			foreach (i; 0 .. glyphs[character].bitmapHeight)
			{
				uint framebufferStart = offsetX + glyphs[character].adjustX + (y - glyphs[character].adjustY + i) * framebuffer.width;
				uint bitmapStart = i * glyphs[character].bitmapWidth;

				foreach (j; 0 .. glyphs[character].bitmapWidth)
				{
					ubyte* fg1 = cast(ubyte*)&color;
					ubyte* fg2 = cast(ubyte*)&glyphs[character].bitmap[bitmapStart + j];

					if (fg1[3] == 0 || fg2[3] == 0)
						continue;

					ubyte finalAlpha = cast(ubyte)(fg2[3] / (255.0 / fg1[3]));
					uint finalColor = (finalAlpha << 24) | (color & 0x00ffffff);
					ubyte* fg3 = cast(ubyte*)&finalColor;

					if (fg3[3] == 0xff)
					{
						framebuffer.data[framebufferStart + j] = finalColor;
						continue;
					}

					ubyte* bg = cast(ubyte*)(&framebuffer.data[framebufferStart + j]);

					uint alpha = fg3[3] + 1;
					uint invAlpha = 257 - alpha;

					bg[0] = cast(ubyte)((alpha * fg3[0] + invAlpha * bg[0]) >> 8);
					bg[1] = cast(ubyte)((alpha * fg3[1] + invAlpha * bg[1]) >> 8);
					bg[2] = cast(ubyte)((alpha * fg3[2] + invAlpha * bg[2]) >> 8);
					bg[3] = 0xff;
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
			glyph.bitmap = new uint[bitmap.rows * bitmap.width];
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
			uint[] bitmap;
			uint bitmapWidth;
			uint bitmapHeight;
			uint adjustX;
			uint adjustY;
			uint advanceX;
		}

		Logger logger;
		Glyph[dchar] glyphs;

		FT_Library library;
		FT_Face face;

		static bool isFreetypeLoaded;
	}
}
