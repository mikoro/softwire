import framebuffer;

class Rasterizer
{
	static void drawRectangle(IFramebuffer framebuffer, uint x, uint y, uint width, uint height, int color)
	{
		foreach (i; y .. y + height)
		{
			framebuffer.data[(x + i * framebuffer.width) .. (x + width + i * framebuffer.width)] = color;
		}
	}
}