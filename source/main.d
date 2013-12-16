/**
 * Application main entry point.
 *
 * Copyright: Copyright (C) 2013 Mikko Ronkainen <firstname@mikkoronkainen.com>
 * License: MIT License
 */

module main;

import logger;
import game;

int main()
{
	Logger logger = new FileLogger("softwire.log");

	try
	{
		Game game = new Game(logger);
		game.mainloop();
	}
	catch(Exception ex)
	{
		logger.logThrowable(ex);
		return -1;
	}

	return 0;
}
