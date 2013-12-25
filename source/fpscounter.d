/**
 * Helper class for calculating FPS values.
 *
 * Copyright: Copyright © 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: GPLv3, see the LICENSE file
 */

module fpscounter;

import std.conv;
import std.string;

import deimos.glfw.glfw3;

class FpsCounter
{
	this(double smoothingFactor = 0.005, double rateLimitFrequency = 20.0)
	{
		this.smoothingFactor = smoothingFactor;
		this.rateLimitInterval = 1.0 / rateLimitFrequency;

		lastTime = lastRateLimitTime = glfwGetTime();
	}

	void tick()
	{
		// http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
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
