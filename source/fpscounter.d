import derelict.glfw3.glfw3;

class FpsCounter
{
	this(double smoothingFactor = 0.01)
	{
		this.smoothingFactor = smoothingFactor;
		lastTime = glfwGetTime();
	}

	void countFrame()
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

	private
	{
		double smoothingFactor = 0.01;
		double previousFrametime = 0;
		double previousSmoothFrametime = 0;
		double smoothFrametime = 0;
		double lastTime = 0;
	}
}
