/**
 * Calculate real-time FPS values with nice smoothing.
 *
 * Copyright © 2014 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT, see the LICENSE file.
 */

module fps_counter;

import std.conv;
import std.string;

import deimos.glfw.glfw3;

class FpsCounter
{
	this()
	{
		lastUpdateTime = lastMovingAverageCalculationTime = glfwGetTime();
	}

	void update()
	{
		// calculate frametime (time since last update)
		double currentTime = glfwGetTime();
		double frameTime = currentTime - lastUpdateTime;
		lastUpdateTime = currentTime;

		// prevent too large changes in the frametime
		if (frameTime > (2 * movingAverageFrameTime))
			frameTime = 2 * movingAverageFrameTime;

		// collect data for basic average calculation
		frameTimeSum += frameTime;
		frameTimeSumCounter++;

		// calculate exponential moving average (at maximum 15 times per second) using the basic average value
		// http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
		// the characteristics of this function are functions of the alpha value and the frequency of invocation
		if ((currentTime - lastMovingAverageCalculationTime) > (1.0 / 15))
		{
			double alpha = 0.25;
			movingAverageFrameTime = alpha * (frameTimeSum / frameTimeSumCounter) + (1.0 - alpha) * previousMovingAverageFrameTime;

			previousMovingAverageFrameTime = movingAverageFrameTime;
			lastMovingAverageCalculationTime = currentTime;

			frameTimeSum = 0;
			frameTimeSumCounter = 0;

			fpsString = to!dstring(format("%.0f", getFps()));
		}
	}

	double getFps()
	{
		return 1.0 / movingAverageFrameTime;
	}

	dstring getFpsString()
	{
		return fpsString;
	}

	private
	{
		double lastUpdateTime = 0;
		double frameTimeSum = 0;
		int frameTimeSumCounter = 0;
		double lastMovingAverageCalculationTime = 0;
		double movingAverageFrameTime = 1.0 / 30; // assume starting fps of 30, speeds up the startup ramp to either direction
		double previousMovingAverageFrameTime = 1.0 / 30;
		dstring fpsString;
	}
}
