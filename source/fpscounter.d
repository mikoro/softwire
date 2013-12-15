/**
 * Calculates FPS from frametimes using exponential moving average.
 *
 * See http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average for details.
 * Also provides rate limited updates so that the visible result only updates X times per seconds.
 *
 * Copyright: Copyright (C) 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT License, see the LICENSE.txt file
 */

module fpscounter;

import std.conv;
import std.string;

import deimos.glfw.glfw3;

class FpsCounter
{
	this(double smoothingFactor = 0.05, double rateLimitFrequency = 10.0)
	{
		this.smoothingFactor = smoothingFactor;
		this.rateLimitInterval = 1.0 / rateLimitFrequency;

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
