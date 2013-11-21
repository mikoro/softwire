import framebuffer;

class Rasterizer
{
	static void drawRectangle(Framebuffer framebuffer, int x, int y, int width, int height, int color)
	{
		foreach (i; y .. y + height)
		{
			int start = x + i * framebuffer.width;
			
			foreach(j; 0 .. width)
			{
				byte* bg = cast(byte*)&framebuffer.data[start + j];
				byte* fg = cast(byte*)&color;

				int alpha = (fg[3] & 0xff) + 1;
				int inverseAlpha = 257 - alpha;
				
				bg[0] = cast(byte)((alpha * (fg[0] & 0xff) + inverseAlpha * (bg[0] & 0xff)) >> 8);
				bg[1] = cast(byte)((alpha * (fg[1] & 0xff) + inverseAlpha * (bg[1] & 0xff)) >> 8);
				bg[2] = cast(byte)((alpha * (fg[2] & 0xff) + inverseAlpha * (bg[2] & 0xff)) >> 8);
				bg[3] = cast(byte)0xff;
			}
		}
	}
}
