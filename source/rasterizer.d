import framebuffer;

void drawRectangle(Framebuffer framebuffer, uint x, uint y, uint width, uint height, uint color)
{
	ubyte* fg = cast(ubyte*)&color;

	if (fg[3] == 0)
		return;

	if (fg[3] == 0xff)
	{
		foreach (i; y .. y + height)
		{
			uint start = x + i * framebuffer.width;

			foreach(j; 0 .. width)
			{
				framebuffer.data[start + j] = color;
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
		uint start = x + i * framebuffer.width;

		foreach(j; 0 .. width)
		{
			ubyte* bg = cast(ubyte*)(&framebuffer.data[start + j]);

			bg[0] = cast(ubyte)((afg0 + invAlpha * bg[0]) >> 8);
			bg[1] = cast(ubyte)((afg1 + invAlpha * bg[1]) >> 8);
			bg[2] = cast(ubyte)((afg2 + invAlpha * bg[2]) >> 8);
			bg[3] = 0xff;
		}
	}
}
