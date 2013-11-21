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
