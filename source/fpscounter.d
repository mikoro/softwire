import std.conv;
import std.string;

import deimos.glfw.glfw3;

class FpsCounter
{
	this(double smoothingFactor = 0.05, double rateLimitInterval = 0.025)
	{
		this.smoothingFactor = smoothingFactor;
		this.rateLimitInterval = rateLimitInterval;

		lastTime = lastRateLimitTime = glfwGetTime();
	}

	void tick()
	{
		smoothFrametime = smoothingFactor * previousFrametime + (1.0 - smoothingFactor) * previousSmoothFrametime;

		double currentTime = glfwGetTime();
		previousFrametime = currentTime - lastTime;
		previousSmoothFrametime = smoothFrametime;
		lastTime = currentTime;
	}

	double getFps()
	{
		return 1.0 / smoothFrametime;
	}

	dstring getRateLimitedFps()
	{
		double currentTime = glfwGetTime();

		if ((currentTime - lastRateLimitTime) > rateLimitInterval)
		{
			rateLimitedFps = to!dstring(format("%.1f", getFps()));
			lastRateLimitTime = currentTime;
		}

		return rateLimitedFps;
	}

	private
	{
		double smoothingFactor = 0;
		double previousFrametime = 0;
		double previousSmoothFrametime = 0;
		double smoothFrametime = 0;
		double lastTime = 0;
		double lastRateLimitTime = 0;
		double rateLimitInterval = 0;
		dstring rateLimitedFps;
	}
}
