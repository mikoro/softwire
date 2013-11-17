import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import derelict.freetype.ft;

import logger;
import game;

int main()
{
	Logger logger = new FileLogger("softwire.log");

	try
	{
		logger.logInfo("Loading shared libraries");

		DerelictGLFW3.load();
		DerelictGL3.load();
		DerelictFT.load();

		Game game = new Game(logger);

		logger.logInfo("Initializing the game");

		game.initialize();

		logger.logInfo("Entering the mainloop");

		game.mainloop();

		logger.logInfo("Shutting down the game");

		game.shutdown();
	}
	catch(Exception ex)
	{
		logger.logThrowable(ex);
		return -1;
	}

	return 0;
}
