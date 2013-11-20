import framebuffer;

class Rasterizer
{
	static void drawRectangle(IFramebuffer framebuffer, uint x, uint y, uint width, uint height, int color)
	{
		foreach (i; y .. y + height)
		{
			int start = (x + i * framebuffer.width);
			int end = (x + i * framebuffer.width + width);

			framebuffer.data[start .. end] = color;
		}
	}
}
